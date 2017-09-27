local test = require 'pl.test'
local asserteq = test.asserteq

local compat = require "pl.compat"
local coroutine = require "coroutine"

local code_generator = coroutine.wrap(function()
    local result = {"ret", "urn \"Hello World!\""}
    for _,v in ipairs(result) do
        coroutine.yield(v)
    end
    coroutine.yield(nil)
end)

local f, err = compat.load(code_generator)
asserteq(err, nil)
asserteq(f(), "Hello World!")
