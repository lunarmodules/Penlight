require 'pl'
require 'pl.strict'
utils.printf("that's fine!\n")
res,err = pcall(function()
   print(x)
end)
assert(err,"variable 'x' is not declared")

