lispeval = require './eval'

class Proc
  constructor: (@scope, @params, @body) ->
  apply: (cells, scope) ->
    args = (cells.map (i) -> lispeval(i, scope))
    if @body instanceof Function
      @body.apply(this, args)
    else
      inner = @scope.fork()
      @params.forEach((name, i) -> inner.set(name, args[i]))
      @body.map((e) -> lispeval(e, inner)).pop()
  
class Syntax extends Proc
  apply: (cells, scope) ->
    return @body(cells, scope)
    

module.exports =
  Proc: Proc
  Syntax: Syntax            
