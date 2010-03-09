--if _VERSION == "Lua 5.2" then return print 'broken for Lua 5.2' end
local asserteq = require 'pl.test' . asserteq
local app = require 'pl.lapp'


function check (spec,args,match)
    arg = args
    local args = app(spec)
    for k,v in pairs(args) do
        if type(v) == 'userdata' then args[k]:close(); args[k] = '<file>' end
    end
    asserteq(args,match)
end

local parmtest = [[
Testing 'array' parameter handling
    -o,--output... (string)
    -v...
]]


check (parmtest,{'-o','one'},{output={'one'},v={false}})
check (parmtest,{'-o','one','-v'},{output={'one'},v={true}})
check (parmtest,{'-o','one','-vv'},{output={'one'},v={true,true}})
check (parmtest,{'-o','one','-o','two'},{output={'one','two'},v={false}})


local simple = [[
Various flags and option types
    -p          A simple optional flag, defaults to false
    -q,--quiet  A simple flag with long name
    -o  (string)  A required option with argument
    <input> (default stdin)  Optional input file parameter
]]

check(simple,
    {'-o','in'},
    {quiet=false,p=false,o='in',input='<file>'})

check(simple,
    {'-o','help','-q','tests/test-lapp.lua'},
    {quiet=true,p=false,o='help',input='<file>',input_name='tests/test-lapp.lua'})




