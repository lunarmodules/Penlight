--- Useful test utilities.
--
--    test.asserteq({1,2},{1,2}) -- can compare tables
--    test.asserteq(1.2,1.19,0.02) -- compare FP numbers within precision
--    T = test.tuple -- used for comparing multiple results
--    test.asserteq(T(string.find(" me","me")),T(2,3))
--
-- Dependencies: `pl.utils`, `pl.tablex`, `pl.pretty`, `pl.path`, `debug`
-- @module pl.test

local tablex = require 'pl.tablex'
local utils = require 'pl.utils'
local pretty = require 'pl.pretty'
local path = require 'pl.path'
local print,type,unpack = print,type,utils.pack
local clock = os.clock
local debug = require 'debug'
local io,debug = io,debug

local function dump(x)
    if type(x) == 'table' and not (getmetatable(x) and getmetatable(x).__tostring) then
        return pretty.write(x,' ',true)
    elseif type(x) == 'string' then
        return '"'..x..'"'
    else
        return tostring(x)
    end
end

local test = {}

local function complain (x,y,msg,where)
    local i = debug.getinfo(3 + (where or 0))
    local err = io.stderr
    err:write(path.basename(i.short_src)..':'..i.currentline..': assertion failed\n')
    err:write("got:\t",dump(x),'\n')
    err:write("needed:\t",dump(y),'\n')
    utils.quit(1,msg or "these values were not equal")
end

--- general test complain message.
-- Useful for composing new test functions (see tests/tablex.lua for an example)
-- @param x a value
-- @param y value to compare first value against
-- @param msg message
-- @param where extra level offset for errors
-- @function complain
test.complain = complain

--- like assert, except takes two arguments that must be equal and can be tables.
-- If they are plain tables, it will use tablex.deepcompare.
-- @param x any value
-- @param y a value equal to x
-- @param eps an optional tolerance for numerical comparisons
-- @param where extra level offset
function test.asserteq (x,y,eps,where)
    local res = x == y
    if not res then
        res = tablex.deepcompare(x,y,true,eps)
    end
    if not res then
        complain(x,y,nil,where)
    end
end

--- assert that the first string matches the second.
-- @param s1 a string
-- @param s2 a string
-- @param where extra level offset
function test.assertmatch (s1,s2,where)
    if not s1:match(s2) then
        complain (s1,s2,"these strings did not match",where)
    end
end

--- assert that the function raises a particular error.
-- @param fn a function or a table of the form {function,arg1,...}
-- @param e a string to match the error against
-- @param where extra level offset
function test.assertraise(fn,e,where)
    local ok, err
    if type(fn) == 'table' then
        ok, err = pcall(unpack(fn))
    else
        ok, err = pcall(fn)
    end
    if not err or err:match(e)==nil then
        complain (err,e,"these errors did not match",where)
    end
end

--- a version of asserteq that takes two pairs of values.
-- <code>x1==y1 and x2==y2</code> must be true. Useful for functions that naturally
-- return two values.
-- @param x1 any value
-- @param x2 any value
-- @param y1 any value
-- @param y2 any value
-- @param where extra level offset
function test.asserteq2 (x1,x2,y1,y2,where)
    if x1 ~= y1 then complain(x1,y1,nil,where) end
    if x2 ~= y2 then complain(x2,y2,nil,where) end
end

-- tuple type --

local tuple_mt = {}

function tuple_mt.__tostring(self)
    local ts = {}
    for i=1, self.n do
        local s = self[i]
        ts[i] = type(s) == 'string' and ('%q'):format(s) or tostring(s)
    end
    return 'tuple(' .. table.concat(ts, ', ') .. ')'
end

function tuple_mt.__eq(a, b)
    if a.n ~= b.n then return false end
    for i=1, a.n do
        if a[i] ~= b[i] then return false end
    end
    return true
end

--- encode an arbitrary argument list as a tuple.
-- This can be used to compare to other argument lists, which is
-- very useful for testing functions which return a number of values.
-- @usage asserteq(tuple( ('ab'):find 'a'), tuple(1,1))
function test.tuple(...)
    return setmetatable(table.pack(...), tuple_mt)
end

--- Time a function. Call the function a given number of times, and report the number of seconds taken,
-- together with a message.  Any extra arguments will be passed to the function.
-- @param msg a descriptive message
-- @param n number of times to call the function
-- @param fun the function
-- @param ... optional arguments to fun
function test.timer(msg,n,fun,...)
    local start = clock()
    for i = 1,n do fun(...) end
    utils.printf("%s: took %7.2f sec\n",msg,clock()-start)
end

return test
