lispeval = require './eval'
{cons, nil, nilp, car, cdr, listToVector} = require './lists'

module.exports = 
  create_vm_expression_evaluator: (defining_scope, params, body) ->
    (cells, scope) ->
      args = listToVector(cells).map (i) -> lispeval i, scope
      body.apply null, args

  create_lisp_expression_evaluator: (defining_scope, params, body) ->
    (cells, scope) ->
      new_scope = (cmap = (cells, params, nscope) ->
        return nscope if (nilp cells) or (nilp params)
        nscope[(car params)] = lispeval (car cells), scope
        cmap((cdr cells), (cdr params), nscope))(cells, params, {})
      inner = cons(new_scope, defining_scope)
      (nval = (body, memo) ->
        return memo if nilp body
        nval((cdr body), lispeval((car body), inner)))(body)

  create_special_form_evaluator: (defining_scope, params, body) ->
    (cells, scope) -> body(cells, scope)

