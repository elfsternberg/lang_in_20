{car, cdr, cons, nil, nilp, pairp, vectorToList} = require './lists'

NEWLINES   = ["\n", "\r", "\x0B", "\x0C"]
WHITESPACE = [" ", "\t"].concat(NEWLINES)

EOF = new (class)
EOO = new (class)

class Source
  constructor: (@inStream) ->
    @index = 0
    @max = @inStream.length - 1
    @line = 0
    @column = 0

  peek: -> @inStream[@index]

  position: -> [@line, @column]

  next: ->
    c = @peek()
    return EOF if @done()
    @index++
    [@line, @column] = if @peek() in NEWLINES then [@line + 1, 0] else [@line, @column + 1]
    c

  done: -> @index > @max

# IO -> IO
skipWS = (inStream) -> 
  while inStream.peek() in WHITESPACE then inStream.next()

# (type, value, line, column) -> (node {type, value, line, column)}
makeObj = (type, value, line, column) ->
  vectorToList([type, value, line, column])  

# msg -> (IO -> Node => Error)
handleError = (message) ->
  (line, column) -> makeObj('error', message, line, column)

# IO -> Node => Comment
readComment = (inStream) ->
  [line, column] = inStream.position()
  r = (while inStream.peek() != "\n" and not inStream.done()
    inStream.next()).join("")
  if not inStream.done()
    inStream.next()
  makeObj 'comment', r, line, column

# IO -> (Node => Literal => String) | Error
readString = (inStream) ->
  [line, column] = inStream.position()
  inStream.next()
  string = until inStream.peek() == '"' or inStream.done()
    if inStream.peek() == '\\'
      inStream.next()
    inStream.next()
  if inStream.done()
    return handleError("end of file seen before end of string.")(line, column)
  inStream.next()
  makeObj 'string', (string.join ''), line, column

# (String) -> (Node => Literal => Number) | Nothing
readMaybeNumber = (symbol) ->
  if symbol[0] == '+'
    return readMaybeNumber symbol.substr(1)
  if symbol[0] == '-'
    ret = readMaybeNumber symbol.substr(1)
    return if ret? then -1 * ret else undefined
  if symbol.search(/^0x[0-9a-fA-F]+$/) > -1
    return parseInt(symbol, 16)
  if symbol.search(/^0[0-9a-fA-F]+$/) > -1
    return parseInt(symbol, 8)
  if symbol.search(/^[0-9]+$/) > -1
    return parseInt(symbol, 10)
  if symbol.search(/^nil$/) > -1
    return nil
  undefined

# (IO, macros) -> (IO, Node => Number | Symbol) | Error
readSymbol = (inStream, tableKeys) ->
  [line, column] = inStream.position()
  symbol = (until (inStream.done() or inStream.peek() in tableKeys or inStream.peek() in WHITESPACE)
    inStream.next()).join ''
  number = readMaybeNumber symbol
  if number?
    return makeObj 'number', number, line, column
  makeObj 'symbol', symbol, line, column
  

# (Delim, TypeName) -> IO -> (IO, node) | Error
makeReadPair = (delim, type) ->
  # IO -> (IO, Node) | Error
  (inStream) ->
    inStream.next()
    skipWS inStream
    [line, column] = inStream.position()
    if inStream.peek() == delim
      inStream.next()
      return makeObj(type, nil, line, column)

    # IO -> (IO, Node) | Error
    readEachPair = (inStream) ->
      [line, column] = inStream.position()
      obj = read inStream, true, null, true
      if inStream.peek() == delim then return cons obj, nil
      if inStream.done() then return handleError("Unexpected end of input")(line, column)
      return obj if (car obj) == 'error'
      cons obj, readEachPair(inStream)

    ret = makeObj type, readEachPair(inStream), line, column
    inStream.next()
    ret

# Type -> (IO -> (IO, Node))
prefixReader = (type) ->
  # IO -> (IO, Node)
  (inStream) ->
    [line, column] = inStream.position()
    inStream.next()
    [line1, column1] = inStream.position()
    obj = read inStream, true, null, true
    return obj if (car obj) == 'error'
    makeObj "list", cons((makeObj("symbol", type, line1, column1)), cons(obj)), line, column

# I really wanted to make anything more complex than a list (like an
# object or a vector) something handled by a read macro.  Maybe in a
# future revision I can vertically de-integrate these.

readMacros =
  '"': readString
  '(': makeReadPair ')', 'list'
  ')': handleError "Closing paren encountered"
  '[': makeReadPair ']', 'vector'
  ']': handleError "Closing bracket encountered"
  '{': makeReadPair('}', 'record', (res) ->
      res.length % 2 == 0 and true or mkerr "record key without value")
  '}': handleError "Closing curly without corresponding opening."
  "`": prefixReader 'back-quote'
  "'": prefixReader 'quote'
  ",": prefixReader 'unquote'
  ";": readComment


# Given a stream, reads from the stream until a single complete lisp
# object has been found and returns the object

# IO -> Form
read = (inStream, eofErrorP = false, eofError = EOF, recursiveP = false, inReadMacros = null, keepComments = false) ->
  inStream = if inStream instanceof Source then inStream else new Source inStream
  inReadMacros = if InReadMacros? then inReadMacros else readMacros
  inReadMacroKeys = (i for i of inReadMacros)

  c = inStream.peek()

  # (IO, Char) -> (IO, Node) | Error
  matcher = (inStream, c) ->
    if inStream.done()
      return if recursiveP then handleError('EOF while processing nested object')(inStream) else nil
    if c in WHITESPACE
      inStream.next()
      return nil
    if c == ';'
      return readComment(inStream)
    ret = if c in inReadMacroKeys then inReadMacros[c](inStream) else readSymbol(inStream, inReadMacroKeys)
    skipWS inStream
    ret

  while true
    form = matcher inStream, c
    skip = (not nilp form) and (car form == 'comment') and not keepComments
    break if (not skip and not nilp form) or inStream.done()
    c = inStream.peek()
    null
  form

# readForms assumes that the string provided contains zero or more
# forms.  As such, it always returns a list of zero or more forms.

# IO -> (Form* | Error)
readForms = (inStream) ->
    inStream = if inStream instanceof Source then inStream else new Source inStream
    return nil if inStream.done()

    # IO -> (FORM*, IO) | Error
    [line, column] = inStream.position()
    readEach = (inStream) ->
      obj = read inStream, true, null, false
      return nil if (nilp obj)
      return obj if (car obj) == 'error'
      cons obj, readEach inStream

    obj = readEach inStream
    if (car obj) == 'error' then obj else makeObj "list", obj, line, column

exports.read = read
exports.readForms = readForms
