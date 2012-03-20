require 'pl'
asserteq = test.asserteq

A = class()

function A:_init ()
    self.a = 1
end

-- calling base class' ctor automatically
A1 = class(A)

asserteq(A1(),{a=1})

-- explicitly calling base ctor with super

B = class(A)

function B:_init ()
    self:super()
    self.b = 2
end

asserteq(B(),{a=1,b=2})

-- can continue this chain

C = class(B)

function C:_init ()
    self:super()
    self.c = 3
end

--- metamethods!

function C:__tostring ()
    return ("%d:%d:%d"):format(self.a,self.b,self.c)
end

function C.__eq (c1,c2)
    return c1.a == c2.a and c1.b == c2.b and c1.c == c2.c
end

asserteq(C(),{a=1,b=2,c=3})

asserteq(tostring(C()),"1:2:3")

asserteq(C()==C(),true)






