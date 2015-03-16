vectorp = (a) -> toString.call(a) == '[object Array]'

listp = (a) -> vectorp(a) and a.__list == true

recordp = (a) -> Object.prototype.toString.call(a) == '[object Object]'

cons = (a, b = nil) ->
  # Supporting an identity
  l = if not (a?) then [] else if (nilp a) then b else [a, b]
  l.__list = true
  l

nil = cons()

car = (a) -> a[0]

cdr = (a) -> a[1]

nilp = (a) -> listp(a) and a.length == 0

vectorToList = (v, p) ->
  p = if p? then p else 0
  if p >= v.length then return nil
  # Annoying, but since lists are represented as nested arrays, they
  # have to be intercepted first.  The use of duck-typing here is
  # frustrating, but I suppose the eventual runtime will be doing
  # something like this anyway for base types.
  item = if listp(v[p]) then v[p] else if vectorp(v[p]) then vectorToList(v[p]) else v[p]
  cons(item, vectorToList(v, p + 1))

list = (v...) -> vectorToList v

listToVector = (l, v = []) ->
  return v if nilp l
  v.push if listp (car l) then listToVector(car l) else (car l)
  listToVector (cdr l), v

# This is the simplified version. It can't be used stock with reader,
# because read() returns a rich version decorated with extra
# information.

listToString = (l) ->
  return "" if nilp l
  if listp (car l)
    "(" + (listToString(car l)).replace(/\ *$/, "") + ") " + listToString(cdr l)
  else
    p = if typeof (car l) == 'string' then '"' else ''
    p + (car l).toString() + p + ' ' + listToString(cdr l)

module.exports =
  cons: cons
  nil: nil
  car: car
  cdr: cdr
  list: list
  nilp: nilp
  listp: listp
  vectorp: vectorp
  recordp: recordp
  vectorToList: vectorToList
  listToVector: listToVector
  listToString: listToString
  cadr: (l) -> car (cdr l)
  cddr: (l) -> cdr (cdr l)
  cdar: (l) -> cdr (car l)
  caddr: (l) -> car (cdr (cdr l))
  cdddr: (l) -> cdr (cdr (cdr l))
  cadar: (l) -> car (cdr (car l))
  cddar: (l) -> cdr (cdr (car l))
  caadr: (l) -> car (car (cdr l))
  cdadr: (l) -> cdr (car (cdr l))
