fs = require 'fs'
{parse} = require './lisp_parser'
lisp = require './parser'
{scope} = require './scope'
{inspect} = require 'util'

module.exports =
  run: (pathname) ->
    text = fs.readFileSync(pathname, 'utf8')
    ast = parse(text)
    return lisp(ast, scope)
    
