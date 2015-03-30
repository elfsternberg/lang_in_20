lib/lisp_parser.js: lib/lisp_parser.peg
	node_modules/.bin/pegjs $< $@

tests: lib/lisp_parser.js
	node_modules/.bin/coffee bin/lisp test.scm


