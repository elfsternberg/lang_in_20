lispeval = require './eval'
{cons} = require './lists'

module.exports = 
  create_expression_evaluator: (defining_scope, params, body) ->
    if body instanceof Function
      (cells, scope) ->
        args = cells.map (i) -> lispeval i, scope
        body.apply null, args
    else
      (cells, scope) ->
        args = cells.map (i) -> lispeval i, scope
        new_scope = {}
        params.forEach (name, i) -> new_scope[name] = args[i]
        inner = cons(new_scope, defining_scope)
        body.map((i) -> lispeval i, inner).pop()
  
  create_special_form_evaluator: (defining_scope, params, body) ->
    (cells, scope) -> body(cells, scope)

