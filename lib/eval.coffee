lookup = require './lookup'
{car, cdr} = require './lists'

lispeval = (element, scope) ->

  switch element.type
    when 'number' then parseInt(element.value, 10)
    when 'symbol'
      lookup(scope, element.value)
    when 'list'
      proc = lispeval((car element.value), scope)
      args = (cdr element.value)
      proc args, scope
    else throw new Error ("Unrecognized type in parse: #{element.type}")

module.exports = lispeval

