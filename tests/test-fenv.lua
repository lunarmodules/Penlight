
require 'pl.utils'

function test()
    return X + Y + Z
end

t = {X = 1, Y = 2, Z = 3}

setfenv(test,t)

assert(test(),6)

t.X = 10

assert(test(),15)

local print,getfenv,_G = print,getfenv,_G

function test2()
    setfenv(1,{X=2})
    print(getfenv(1),_G,X)
end

test2()



