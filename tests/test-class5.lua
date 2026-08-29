-- Another syntax for creating a class inheriting methods from a base class
-- while also using a table for input methods.
local class = require('pl.class')

-- From a plain table of methods
local A = class({
    info = "foo",
    _init = function (self)
      self.info = "A"
    end
  })

-- From a plain table of methods, inherit from a base
local B = class(A, nil, {
    _init = function(self)
      print("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
      -- self._base._init(self)
      -- self:super()
      self.info = self.info .. "B"
    end
  })

-- -- From a base plus a plain table
-- local C = class(B, nil, {
-- -- local C = class({
--     -- _base = B,
--     _init = function(self)
--       -- self._base._init(self)
--       -- self:super()
--       self.info = self.info .. "C"
--     end
--   })

local foo = B()
print("DEBUG:"..foo.info)
assert(foo.info == "AB")
