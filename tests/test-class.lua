require 'pl'
asserteq = test.asserteq
T = test.tuple

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

function B:foo ()
    self.eee = 1
end

asserteq(B(),{a=1,b=2})

-- can continue this chain

C = class(B)

function C:_init ()
    self:super()
    self.c = 3
end

function C:foo ()
    self:base('foo')
--    self:base():foo()  -- more convenient, but also more expensive
end

c = C()
c:foo()

asserteq(c,{a=1,b=2,c=3,eee=1})
--- call chains with ancestors
local A = class()
function A:_init()
  self.init_chain = "A"
end
local B = class(A)
local C = class(B)
function C:_init()
  self:super()
  self.init_chain = self.init_chain.."C"
end
local D = class(C)
local E = class(D)
function E:_init()
  self:super()
  self.init_chain = self.init_chain.."E"
end
local F = class(E)
local G = class(F)
function G:_init()
  self:super()
  self.init_chain = self.init_chain.."G"
end

local i = G()
assert(i.init_chain == "ACEG")

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

----- properties -----

local MyProps = class(class.properties)
local setted_a, got_b

function MyProps:_init ()
    self._a = 1
    self._b = 2
end

function MyProps:set_a (v)
    setted_a = true
    self._a = v
end

function MyProps:get_b ()
    got_b = true
    return self._b
end

function MyProps:set (a,b)
    self._a = a
    self._b = b
end

local mp = MyProps()

mp.a = 10

asserteq(mp.a,10)
asserteq(mp.b,2)
asserteq(setted_a and got_b, true)

class.MoreProps(MyProps)
local setted_c

function MoreProps:_init()
    self:super()
    self._c = 3
end

function MoreProps:set_c (c)
    setted_c = true
    self._c = c
end

mm = MoreProps()

mm:set(10,20)
mm.c = 30

asserteq(setted_c, true)
asserteq(T(mm.a, mm.b, mm.c),T(10,20,30))





