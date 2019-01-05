local asserteq = require 'pl.test' . asserteq


-- strings ---
require 'pl.stringx'.import() ---> convenient!
local s = '123'
assert (s:isdigit())
assert (not s:isspace())
s = 'here the dog is just a dog'
assert (s:startswith('here'))
assert (s:endswith('dog'))
assert (s:count('dog') == 2)
s = '  here we go    '
asserteq (s:lstrip() , 'here we go    ')
asserteq (s:rstrip() , '  here we go')
asserteq (s:strip() , 'here we go')
asserteq (('hello'):center(20,'+') , '+++++++hello++++++++')

asserteq (('hello dolly'):title() , 'Hello Dolly')
asserteq (('h bk bonzo TOK fred m'):title() , 'H Bk Bonzo Tok Fred M')
