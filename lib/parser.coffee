lispeval = require './eval'

lisp = (ast, scope) ->
  ast.map((e) -> lispeval(e, scope)).pop()

module.exports = lisp
    

