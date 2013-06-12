--- Provides a reuseable and convenient framework for creating classes in Lua.
-- Two possible notations:
--
--    B = class(A)
--    class.B(A)
--
-- The latter form creates a named class (and a global).
--
-- See the Guide for further @{01-introduction.md.Simplifying_Object_Oriented_Programming_in_Lua|discussion}
-- @module pl.class

local error, getmetatable, io, pairs, rawget, rawset, setmetatable, tostring, type =
    _G.error, _G.getmetatable, _G.io, _G.pairs, _G.rawget, _G.rawset, _G.setmetatable, _G.tostring, _G.type
-- this trickery is necessary to prevent the inheritance of 'super' and
-- the resulting recursive call problems.
local function call_ctor (c,obj,...)
    -- nice alias for the base class ctor
    local base = rawget(c,'_base')
    if base then
        local parent_ctor = rawget(base,'_init')
        if parent_ctor then
            rawset(obj,'super',function(obj,...)
                call_ctor(base,obj,...)
            end)
        end
    end
    local res = c._init(obj,...)
    rawset(obj,'super',nil)
    return res
end

--- initializes an __instance__ upon creation.
-- @function class:_init
-- @param ... parameters passed to the constructor
-- @usage local Cat = class()
-- function Cat:_init(name)
--   --self:super(name)   -- call the ancestor initializer if needed
--   self.name = name
-- end
-- 
-- local pussycat = Cat("pussycat")
-- print(pussycat.name)  --> pussycat

--- checks whether an __instance__ is derived from some class.
-- Works the other way around as `class_of`.
-- @function instance:is_a
-- @param some_class class to check against
-- @return `true` if the __instance__ is derived from `some_class`
-- @usage local pussycat = Lion()  -- assuming Lion derives from Cat
-- if pussycat:is_a(Cat) then
--   -- it's true
-- end
local function is_a(self,klass)
    local m = getmetatable(self)
    if not m then return false end --*can't be an object!
    while m do
        if m == klass then return true end
        m = rawget(m,'_base')
    end
    return false
end

--- checks whether an __instance__ is derived from some class.
-- Works the other way around as `is_a`.
-- @function class:class_of
-- @param some_instance instance to check against
-- @return `true` if the __instance__ is derived from `class`
-- @usage local pussycat = Lion()  -- assuming Lion derives from Cat
-- if Cat:class_of(pussycat) then
--   -- it's true
-- end
local function class_of(klass,obj)
    if type(klass) ~= 'table' or not rawget(klass,'is_a') then return false end
    return klass.is_a(obj,klass)
end

--- Access to base class methods.
-- NOTE: the initializer `_init` has a different way to call its ancestor
-- @function instance:base
-- @param method_name Name of the method to call on the base class
-- @param ... parameters passed to the base class method
-- @usage local Cat = class()
-- function Cat:say(text)
--   print(text)
-- end
-- 
-- local Lion = class(Cat)
-- function Lion:say(text)
--   self:base("say", "roar... "..text)
-- end
--
-- local pussycat = Lion()
-- pussycat:say("hello world")  --> 'roar... hello world'
local function base_method(self,method,...)
    local m = getmetatable(self)
    if not m then return nil end
    if not method then return setmetatable({},{
        __index = function(tbl,key)
            return function(...) return m._base[key](self,...) end
        end
    }) else
        return m._base[method](self,...)
    end
end

local function _class_tostring (obj)
    local mt = obj._class
    local name = rawget(mt,'_name')
    setmetatable(obj,nil)
    local str = tostring(obj)
    setmetatable(obj,mt)
    if name then str = name ..str:gsub('table','') end
    return str
end

local function tupdate(td,ts)
    for k,v in pairs(ts) do
        td[k] = v
    end
end

local function _class(base,c_arg,c)
    c = c or {}     -- a new class instance, which is the metatable for all objects of this type
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    local mt = {}   -- a metatable for the class instance

    if type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
        tupdate(c,base)
        c._base = base
        -- inherit the 'not found' handler, if present
        if rawget(c,'_handler') then mt.__index = c._handler end
    elseif base ~= nil then
        error("must derive from a table type",3)
    end

    c.__index = c
    setmetatable(c,mt)
    c._init = nil

    if base and rawget(base,'_class_init') then
        base._class_init(c,c_arg)
    end

    -- expose a ctor which can be called by <classname>(<args>)
    mt.__call = function(class_tbl,...)
        local obj = {}
        setmetatable(obj,c)

        if rawget(c,'_init') then -- explicit constructor
            local res = call_ctor(c,obj,...)
            if res then -- _if_ a ctor returns a value, it becomes the object...
                obj = res
                setmetatable(obj,c)
            end
        elseif base and rawget(base,'_init') then -- default constructor
            -- make sure that any stuff from the base class is initialized!
            call_ctor(base,obj,...)
        end

        if base and rawget(base,'_post_init') then
            base._post_init(obj)
        end

        if not rawget(c,'__tostring') then
            c.__tostring = _class_tostring
        end
        return obj
    end
    -- Call Class.catch to set a handler for methods/properties not found in the class!
    c.catch = function(self, handler)
        if type(self) == "function" then
          -- called using . notation instead of : notation
          handler = self
        end
        c._handler = handler
        mt.__index = handler
    end
    c.is_a = is_a
    c.class_of = class_of
    c.base = base_method
    c._class = c

    return c
end

--- create a new class, derived from a given base class.
-- Supporting two class creation syntaxes:
-- either `Name = class(base)` or `class.Name(base)`. The latter syntax
-- creates a global `Name`, the former only creates a global if `Name` hasn't been 
-- declared `local`.
-- @function class
-- @param base optional base class
-- @param c_arg optional parameter to class constructor
-- @param c optional table to be used as class
local class
class = setmetatable({},{
    __call = function(fun,...)
        return _class(...)
    end,
    __index = function(tbl,key)
        if key == 'class' then
            io.stderr:write('require("pl.class").class is deprecated. Use require("pl.class")\n')
            return class
        end
        local env = _G
        return function(...)
            local c = _class(...)
            c._name = key
            rawset(env,key,c)
            return c
        end
    end
})

class.properties = class()

function class.properties._class_init(klass)
    klass.__index = function(t,key)
        -- normal class lookup!
        local v = klass[key]
        if v then return v end
        -- is it a getter?
        v = rawget(klass,'get_'..key)
        if v then
            return v(t)
        end
        -- is it a field?
        return rawget(t,'_'..key)
    end
    klass.__newindex = function (t,key,value)
        -- if there's a setter, use that, otherwise directly set table
        local p = 'set_'..key
        local setter = klass[p]
        if setter then
            setter(t,value)
        else
            rawset(t,key,value)
        end
    end
end


return class

