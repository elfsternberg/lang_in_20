parser = require './parser'
lispeval = require './eval'

{Proc, Syntax} = require './fn'

class Scope
  constructor: (@parent) ->
    @_symbols = {}

  lookup: (name) ->
    if @_symbols[name]?
      return @_symbols[name]

    if @parent
      return @parent.lookup(name)

    throw new Error "Unknown variable '#{name}'"

  define: (name, body) ->
    @set name, (new Proc(this, [], body))

  syntax: (name, body) ->
    @set name, (new Syntax(this, [], body))

  fork: -> new Scope(@)

  set: (name, value) ->
    @_symbols[name] = value
  
class Toplevel extends Scope
  constructor: (@parent = null) ->
    super
    @define '+', (a, b) -> a + b
    @define '-', (a, b) -> a - b
    @define '*', (a, b) -> a * b
    @define '==', (a, b) -> a == b

    @syntax 'define', (list, scope) ->
      scope.set(list[0].value, lispeval(list[1], scope))

    @syntax 'lambda', (list, scope) ->
      params = list[0].value.map (n) -> return n.value
      new Proc(scope, params, list.slice(1))

    @syntax 'if', (list, scope) ->
        lispeval(list[if lispeval(list[0], scope) then 1 else 2], scope)

Scope.Toplevel = Toplevel

module.exports = Scope            
