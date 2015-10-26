---- testing types
local types = require 'pl.types'
local asserteq = require 'pl.test'.asserteq
local List = require 'pl.List'

local list = List()
local array = {10,20,30}
local map = {one=1,two=2}

-- extened type() function
asserteq(types.type(array),'table')
asserteq(types.type('hello'),'string')
-- knows about Lua file objects
asserteq(types.type(io.stdin),'file')
-- and class names
asserteq(types.type(list),'List')

asserteq(types.is_integer(10),true)
asserteq(types.is_integer(10.1),false)
-- do note that for Lua < 5.3, 10.0 is the same as 10; an integer.

asserteq(types.is_callable(asserteq),true)
asserteq(types.is_callable(List),true)

asserteq(types.is_indexable(array),true)
asserteq(types.is_iterable(array),true)
asserteq(types.is_indexable('hello'),nil)
asserteq(types.is_indexable(10),nil)

asserteq(types.is_empty(nil),true)
asserteq(types.is_empty({}),true)
asserteq(types.is_empty(""),true)
asserteq(types.is_empty("   ",true),true)

-- a more relaxed kind of truthiness....
asserteq(types.to_bool('yes'),true)
asserteq(types.to_bool('true'),true)
asserteq(types.to_bool(1),true)
asserteq(types.to_bool(0),false)