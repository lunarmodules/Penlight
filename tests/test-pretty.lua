require 'pl.compat52'
local pretty = require 'pl.pretty'
local asserteq = require('pl.test').asserteq

t1 = {
    'one','two','three',{1,2,3},
    alpha=1,beta=2,gamma=3,['&']=true,[0]=false,
    _fred = {true,true},
    s = [[
hello dolly
you're so fine
]]
}

s = pretty.write(t1) --,' ',true)
t2,err = pretty.read(s)
if err then return print(err) end
asserteq(t1,t2)

res,err = pretty.read [[
  {
	['function'] = true,
	['do'] = true,
  }
]]
assert(res)

res,err = pretty.read [[
  {
	['function'] = true,
	['do'] = function() return end
  }
]]
assert(err == 'cannot have Lua keywords in table definition')

-- Check to make sure that no spaces exist when write is told not to
local tbl = { "a", 2, "c", false, 23, 453, "poot", 34 }
asserteq( pl.pretty.write( tbl, "" ), [[{"a",2,"c",false,23,453,"poot",34}]] )
