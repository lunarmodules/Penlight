-- test-pylib.lua
local List = require 'pl.List'
local text = require 'pl.text'
local Template = text.Template
local asserteq = require 'pl.test' . asserteq

l = List{10,20,30,40,50}
s = List{1,2,3,4,5}

-- test using: lua pylist.lua
local lst = List()
lst:append(20)
lst:extend{30,40,50}
lst:put(10)
asserteq (lst,List{10,20,30,40,50})
asserteq (lst:len(),5)
lst:insert(3,11)
lst:remove_value(40)
asserteq (lst,List{10,20,11,30,50})
asserteq (lst:contains(11),true)
asserteq (lst:contains(40),false)
local q=lst:pop()
asserteq( lst:index(30),4 )
asserteq( lst:count(10),1 )
lst:sort()
lst:reverse()
asserteq (lst , List{30,20,11,10})
asserteq (lst[#lst] , 10)
asserteq (lst[#lst-2] , 20)
asserteq (tostring(lst) , '{30,20,11,10}')

lst = List {10,20,30,40,50}
asserteq (lst:slice(2),{20,30,40,50})
asserteq (lst:slice(-2),{40,50})
asserteq (lst:slice(nil,3),{10,20,30})
asserteq (lst:slice(2,4),{20,30,40})
asserteq (lst:slice(-4,-2),{20,30,40})

lst = List.range(0,9)
seq = List{0,1,2,3,4,5,6,7,8,9}
asserteq(List.range(4),{1,2,3,4})
asserteq(List.range(0,8,2),{0,2,4,6,8})
asserteq(List.range(0,1,0.2),{0,0.2,0.4,0.6,0.8,1},1e-9)
asserteq(lst, seq)
asserteq(lst:reduce '+', 45)

local part = seq:partition(function(v) return v % 2 end)
asserteq (part[0], List{0,2,4,6,8})
asserteq (part[1], List{1,3,5,7,9})

asserteq (List('abcd'),List{'a','b','c','d'})
local caps = List()
List('abcd'):foreach(function(v) caps:append(v:upper()) end)
asserteq (caps,List{'A','B','C','D'})
ls = List{10,20,30,40}
ls:slice_assign(2,3,{21,31})
asserteq (ls , List{10,21,31,40})
asserteq (ls:remove(2), List{10,31,40})
asserteq (ls:clear(), List{})
asserteq (ls:len(), 0)

-- strings ---
require 'pl.stringx'.import() ---> convenient!
s = '123'
assert (s:isdigit())
assert (not s:isspace())
s = 'here the dog is just a dog'
assert (s:startswith('here'))
assert (s:endswith('dog'))
assert (s:count('dog') == 2)
assert (List.split(s) == List{'here', 'the', 'dog', 'is', 'just', 'a', 'dog'})
assert (List.split('foo;bar;baz', ';') == List{'foo', 'bar', 'baz'})
s = '  here we go    '
asserteq (s:lstrip() , 'here we go    ')
asserteq (s:rstrip() , '  here we go')
asserteq (s:strip() , 'here we go')
asserteq (('hello'):center(20,'+') , '+++++++hello++++++++')

t = Template('${here} is the $answer')
asserteq(t:substitute {here = 'one', answer = 'two'} , 'one is the two')

asserteq (('hello dolly'):title() , 'Hello Dolly')
asserteq (('h bk bonzo TOK fred m'):title() , 'H Bk Bonzo Tok Fred M')
