fs = require 'fs'
{readForms} = require './reader'
lispeval = require './eval'
scope = require './scope'
{car, cdr, nilp} = require './lists'

module.exports =
  run: (pathname) ->
    text = fs.readFileSync(pathname, 'utf8')
    root = scope
    ast = readForms(text)
    (nval = (body, memo) ->
      return memo if nilp body
      nval((cdr body), lispeval((car body), root)))(ast.value)


    
