parser = require './parser'
lispeval = require './eval'
{cons, car, cdr, nilp} = require './lists'
{create_expression_evaluator, create_special_form_evaluator} = require './fn'
lookup = require './lookup'

scope = cons
  '+': create_expression_evaluator scope, [], (a, b) -> a + b
  '-': create_expression_evaluator scope, [], (a, b) -> a - b
  '*': create_expression_evaluator scope, [], (a, b) -> a * b
  '/': create_expression_evaluator scope, [], (a, b) -> a / b
  '==': create_expression_evaluator scope, [], (a, b) -> a == b

  'define': create_special_form_evaluator scope, [], (list, scope) ->
    current = (car scope)
    current[list[0].value] = lispeval(list[1], scope)

  'lambda': create_special_form_evaluator scope, [], (list, scope) ->
    params = list[0].value.map (n) -> return n.value
    create_expression_evaluator(scope, params, list.slice(1))
        
  'if': create_special_form_evaluator scope, [], (list, scope) ->
    lispeval(list[if lispeval(list[0], scope) then 1 else 2], scope)


module.exports =
  lookup: lookup
  scope: scope
