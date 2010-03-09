asserteq = require('pl.test').asserteq
lexer = require 'pl.lexer'
seq = require 'pl.seq'
List = require ('pl.list').List
copy2 = seq.copy2

s = '20 = hello'
 asserteq(copy2(lexer.scan (s,nil,{space=false},{number=false})),
    {{'number','20'},{'space',' '},{'=','='},{'space',' '},{'iden','hello'}})

 asserteq(copy2(lexer.scan (s,nil,{space=true},{number=true})),
    {{'number',20},{'=','='},{'iden','hello'}})

asserteq(copy2(lexer.lua('test(20 and a > b)',{space=true})),
    {{'iden','test'},{'(','('},{'number',20},{'keyword','and'},{'iden','a'},
      {'>','>'},{'iden','b'},{')',')'}} )

lines = [[
for k,v in pairs(t) do
    if type(k) == 'number' then
        print(v) -- array-like case
    else
        print(k,v)
    end
end
]]

ls = List()
for tp,val in lexer.lua(lines,{space=true,comments=true}) do
    assert(tp ~= 'space' and tp ~= 'comment')
    if tp == 'keyword' then ls:append(val) end
end
asserteq(ls,List{'for','in','do','if','then','else','end','end'})

tok = lexer.scan([[
    'help'  "help" "dolly you're fine" "a \"quote\" here"
]],nil,{space=true,string=true})
print(tok())
print(tok())
print(tok())
print(tok())

