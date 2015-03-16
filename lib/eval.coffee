lookup = require './lookup'

lispeval = (element, scope) ->
  switch element.type
    when 'boolean' then element.value == '#t'
    when 'number' then parseInt(element.value, 10)
    when 'symbol'
      lookup(scope, element.value)
    when 'list'
      proc = lispeval(element.value[0], scope)
      args = element.value.slice(1)
      proc args, scope

    else throw new Error ("Unrecognized type in parse")

module.exports = lispeval
