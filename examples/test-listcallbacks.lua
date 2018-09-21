-- demonstrates how to use a list of callbacks
local List = require 'pl.List'
local utils = require 'pl.utils'
local actions = List()
local L = utils.string_lambda

actions:append(function() print 'hello' end)
actions:append(L '|| print "yay"')

-- '()' is a shortcut for operator.call or function(x) return x() end
actions:foreach '()'
