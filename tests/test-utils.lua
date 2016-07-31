local utils = require 'pl.utils'
local path = require 'pl.path'
local test = require 'pl.test'
local asserteq, T = test.asserteq, test.tuple

--- escaping magic chars
local escape = utils.escape
asserteq(escape '[a]','%[a%]')
asserteq(escape '$(bonzo)','%$%(bonzo%)')

--- useful patterns
local P = utils.patterns
asserteq(("+0.1e10"):match(P.FLOAT) ~= nil, true)
asserteq(("-23430"):match(P.INTEGER) ~= nil, true)
asserteq(("my_little_pony99"):match(P.IDEN) ~= nil, true)

--- splitting strings ---
local split = utils.split
asserteq(split("hello dolly"),{"hello","dolly"})
asserteq(split("hello,dolly",","),{"hello","dolly"})
asserteq(split("hello,dolly,",","),{"hello","dolly"})

local first,second = utils.splitv("hello:dolly",":")
asserteq(T(first,second),T("hello","dolly"))

----- table of values to table of strings
asserteq(utils.array_tostring{1,2,3},{"1","2","3"})
-- writing into existing table
local tmp = {}
utils.array_tostring({1,2,3},tmp)
asserteq(tmp,{"1","2","3"})

--- memoizing a function
local kount = 0
local f = utils.memoize(function(x)
    kount = kount + 1
    return x*x
end)
asserteq(f(2),4)
asserteq(f(10),100)
asserteq(f(2),4)
-- actual function only called twice
asserteq(kount,2)

-- string lambdas
local L = utils.string_lambda
local g = L"|x| x:sub(1,1)"
asserteq(g("hello"),"h")

local f = L"|x,y| x - y"
asserteq(f(10,2),8)

-- alternative form for _one_ argument
asserteq(L("2 * _")(4), 8)

local List = require 'pl.List'
local ls = List{10,20,30}

-- string lambdas can be used throughout Penlight
asserteq(ls:map"_+1", {11,21,31})

-- because they use this common function
local function test_fn_arg(f)
    f = utils.function_arg(1,f)
    asserteq(f(10),11)
end

test_fn_arg (function (x) return x + 1 end)
test_fn_arg  '_ + 1'
test.assertraise(function() test_fn_arg {} end, 'not a callable object')
test.assertraise(function() test_fn_arg (0) end, 'must be callable')

-- partial application

local f1 = utils.bind1(f,10)
asserteq(f1(2), 8)

local f2 = utils.bind2(f,2)
asserteq(f2(10), 8)

--- extended type checking

local is_type = utils.is_type
-- anything without a metatable works as regular type() function
asserteq(is_type("one","string"),true)
asserteq(is_type({},"table"),true)

-- but otherwise the type of an object is considered to be its metatable
asserteq(is_type(ls,List),true)

-- compatibility functions
local chunk = utils.load 'return 42'
asserteq(chunk(),42)

chunk = utils.load 'a = 42'
chunk()
asserteq(a,42)

local t = {}
chunk = utils.load ('b = 42','<str>','t',t)
chunk()
asserteq(t.b,42)

chunk,err = utils.load ('a = ?','<str>')
assert(err,[[[string "<str>"]:1: unexpected symbol near '?']])

asserteq(utils.quote_arg("foo"), [[foo]])
if path.is_windows then
    asserteq(utils.quote_arg(""), '^"^"')
    asserteq(utils.quote_arg('"'), '^"')
    asserteq(utils.quote_arg([[ \]]), [[^" \\^"]])
    asserteq(utils.quote_arg([[foo\\ bar\\" baz\]]), [[^"foo\\ bar\\\\\^" baz\\^"]])
    asserteq(utils.quote_arg("%path% ^^!()"), [[^"^%path^% ^^^^^!()^"]])
else
    asserteq(utils.quote_arg(""), "''")
    asserteq(utils.quote_arg("'"), [[''\''']])
    asserteq(utils.quote_arg([['a\'b]]), [[''\''a\'\''b']])
end

----- importing module tables wholesale ---
utils.import(math)
asserteq(type(sin),"function")
asserteq(type(abs),"function")





