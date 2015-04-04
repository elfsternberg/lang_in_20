lispeval = require './eval'
{cons, car, cdr, nilp, nil} = require './lists'
{create_lisp_expression_evaluator, create_vm_expression_evaluator, create_special_form_evaluator} = require './fn'

scope = cons
  '+': create_vm_expression_evaluator scope, [], (a, b) -> a + b
  '-': create_vm_expression_evaluator scope, [], (a, b) -> a - b
  '*': create_vm_expression_evaluator scope, [], (a, b) -> a * b
  '/': create_vm_expression_evaluator scope, [], (a, b) -> a / b
  '==': create_vm_expression_evaluator scope, [], (a, b) -> a == b
  '#t': true
  '#f': false

  'define': create_special_form_evaluator scope, [], (nodes, scope) ->
    current = (car scope)
    current[(car nodes).value] = lispeval((car cdr nodes), scope)

  'lambda': create_special_form_evaluator scope, [], (nodes, scope) ->
    param_nodes = (car nodes).value
    reducer = (l) ->
      if (nilp l) then nil else cons((car l).value, reducer(cdr l))
    param_names = reducer(param_nodes)

    create_lisp_expression_evaluator(scope, param_names, (cdr nodes))
        
  'if': create_special_form_evaluator scope, [], (nodes, scope) ->
    if lispeval((car nodes), scope)
      lispeval((car cdr nodes), scope)
    else
      lispeval((car cdr cdr nodes), scope)

module.exports = scope
