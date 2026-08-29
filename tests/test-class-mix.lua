_G.___w = false

local class = require("pl.class")
local tablex = require("pl.tablex")

local function subclass_hack (base, model)
    return tablex.update(class(base), model)
end

-- print("duck")
_G.___w = "foo"
local foo = class({
        -- attr = "original base",
        _init = function (self)
            print("Init foo class")
            self.attr = "foo"
        end,
        finish = function (self, arg)
            print("Finish foo class "..arg.." as "..self.attr.."\n")
        end
    })

_G.___w = "bar"
local bar = class(foo, nil, {
        _init = function (self, arg)
            print("Init bar class")
            self:super(arg)
            self.attr = "bar"
        end
    })

_G.___w = "baz"
local baz = class(foo)
function baz:_init (arg)
    print("Init baz class")
    self:super(arg)
end

_G.___w = "qiz"
local qiz = subclass_hack(foo, {
    attr = "qiz",
    _init = function (self, arg)
        print("Init qiz class")
        self:super(arg)
    end
})

_G.___w = "zar"
local zar = class({
    _base = foo,
    _init = function (self, arg)
        print("Init zar class")
        self._base._init(self, arg)
        -- self:super(arg)
        self.attr = "zar"
    end
})

-- Base class works as expected
foo():finish("1st")

-- This does *not* work as expected, it functions as an instance of foo
bar():finish("2nd")

-- This syntax works, its just cumbersome
local c = baz()
c.attr = "baz"
c:finish("3rd")

-- This hack to do what I expected pl.class to do in the bar class
qiz():finish("4th")

-- This gets the job done, but there is no super() function available
zar():finish("5th")
