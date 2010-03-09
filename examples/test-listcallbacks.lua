-- demonstrates how to use a list of callbacks
require 'pl'
-- shortcut so we can use 'string lambdas'
L = utils.function_arg
actions = List()

actions:append(function() print 'hello' end)
actions:append(L '|| print "yay"')

-- '()' is a shortcut for operator.call or function(x) return x() end
actions:foreach '()'
