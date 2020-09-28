-- Another syntax for creating a class inheriting methods from a base class
-- while also using a table for input methods.
local class = require('pl.class')

local A = class({
    _init = function (self)
      self.info = "A"
    end
  })

local B = class(A, nil, {
    _init = function(self)
      self:super()
      self.info = self.info .. "B"
    end
  })

local C = class(B, nil, {
    _init = function(self)
      self:super()
      self.info = self.info .. "C"
    end
  })

local foo = C()
assert(foo.ino == "ABC")
