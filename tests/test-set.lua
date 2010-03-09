require 'pl'
classes = require 'pl.class'
classx = require 'pl.classx'
asserteq = require 'pl.test' . asserteq
asserteq2 = require 'pl.test' . asserteq2
S = classes.Set
M = classes.Map
class = classes.class
MultiMap = classx.MultiMap
OrderedMap = classx.OrderedMap

s1 = S{1,2}
s2 = S{1,2}
-- equality
asserteq(s1,s2)
-- union
asserteq(S{1,2} + S{2,3},S{1,2,3})
-- intersection
asserteq(S{1,2} * S{2,3}, S{2})
-- symmetric_difference
asserteq(S{1,2} ^ S{2,3}, S{1,3})

m = M{one=1,two=2}
asserteq(m,M{one=1,two=2})
m:update {three=3,four=4}
asserteq(m,M{one=1,two=2,three=3,four=4})

class.Animal()

function Animal:_init(name)
    self.name = name
end

function Animal:__tostring()
  return self.name..': '..self:speak()
end

class.Dog(Animal)

function Dog:speak()
  return 'bark'
end

class.Cat(Animal)

function Cat:_init(name,breed)
    self:super(name)  -- must init base!
    self.breed = breed
end

function Cat:speak()
  return 'meow'
end

Lion = class(Cat)

function Lion:speak()
  return 'roar'
end

fido = Dog('Fido')
felix = Cat('Felix','Tabby')
leo = Lion('Leo','African')

asserteq(tostring(fido),'Fido: bark')
asserteq(tostring(felix),'Felix: meow')
asserteq(tostring(leo),'Leo: roar')

assert(Dog:class_of(fido))
assert(fido:is_a(Dog))

assert(leo:is_a(Animal))

m = MultiMap()
m:set('john',1)
m:set('jane',3)
m:set('john',2)

ms = MultiMap{john={1,2},jane={3}}

asserteq(m,ms)

m = OrderedMap()
m:set('one',1)
m:set('two',2)
m:set('three',3)

asserteq(m:values(),List{1,2,3})

-- usually exercized like this:
--for k,v in m:iter() do print(k,v) end

fn = m:iter()
asserteq2 ('one',1,fn())
asserteq2 ('two',2,fn())
asserteq2 ('three',3,fn())
