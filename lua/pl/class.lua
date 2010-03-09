--- Wrapper classes: Map and Set.
-- Provides a reuseable and convenient framework for creating classes in Lua.
-- See the Guide for further <a href="../../index.html#class">discussion</a>
-- @class module
-- @name pl.class

local function module(...) end
module 'pl.class'


-- utils keeps the predefined metatables for these useful interfaces,
-- so that other modules (such as tablex) can tag their output accordingly.
-- However, users are not required to use this module.
local tablex = require 'pl.tablex'
local utils = require 'pl.utils'
local stdmt = utils.stdmt
local List = require 'pl.list' . List
local rawset = rawset
local is_callable = utils.is_callable
local tmakeset,deepcompare,merge,keys,difference,tupdate = tablex.makeset,tablex.deepcompare,tablex.merge,tablex.keys,tablex.difference,tablex.update
local pretty_write = require 'pl.pretty' . write
local Map = stdmt.Map
local Set = stdmt.Set
local List = stdmt.List

pl.class = {Set = Set, Map = Map}


-- this trickery is necessary to prevent the inheritance of 'super' and
-- the resulting recursive call problems.
local function call_ctor (c,obj,...)
    -- nice alias for the base class ctor
    if rawget(c,'_base') then obj.super = c._base._init end
    local res = c._init(obj,...)
    obj.super = nil
    return res
end

local function is_a(self,klass)
    local m = getmetatable(self)
    if not m then return false end --*can't be an object!
    while m do
        if m == klass then return true end
        m = rawget(m,'_base')
    end
    return false
end

local function class_of(klass,obj)
    if type(klass) ~= 'table' or not rawget(klass,'is_a') then return false end
    return klass.is_a(obj,klass)
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
        error("must derive from a table type")
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
    c.catch = function(handler)
        c._handler = handler
        mt.__index = handler
    end
    c.is_a = is_a
    c.class_of = class_of
    c._class = c
    -- any object can have a specified delegate which is called with unrecognized methods
    -- if _handler exists and obj[key] is nil, then pass onto handler!
    c.delegate = function(self,obj)
        mt.__index = function(tbl,key)
            local method = obj[key]
            if method then
                return function(self,...)
                    return method(obj,...)
                end
            elseif self._handler then
                return self._handler(tbl,key)
            end
        end
    end
    return c
end

--- create a new class, derived from a given base class.
-- supporting two class creation syntaxes:
-- either 'Name = class()' or'class.Name()'
-- @class function
-- @name class
-- @param base optional base class
-- @param c_arg optional parameter to class ctor
-- @param c optional table to be used as class
local class = setmetatable({},{
    __call = function(fun,...)
        return _class(...)
    end,
    __index = function(tbl,key)
        local env = getfenv(2)
        return function(...)
            local c = _class(...)
            c._name = key
            rawset(env,key,c)
            return c
        end
    end
})

pl.class.class = class


-- the Map class ---------------------
class(nil,nil,Map)

local function makemap (m)
    return setmetatable(m,Map)
end

function Map:_init (t)
    local mt = getmetatable(t)
    if mt == Set or mt == Map then
        self:update(t)
    else
        return t -- otherwise assumed to be a map-like table
    end
end

local values,keys = tablex.values,tablex.keys

--- list of keys.
function Map:keys ()
    return List(keys(self))
end

--- list of values.
function Map:values ()
    return List(values(self))
end

--- return an iterator over all key-value pairs.
function Map:iter ()
    return pairs(self)
end

--- return a List of all key-value pairs, sorted by the keys.
function Map:items()
    local ls = List (tablex.pairmap (function (k,v) return List {k,v} end, self))
	ls:sort(function(t1,t2) return t1[1] < t2[1] end)
	return ls
end

-- Will return the existing value, or if it doesn't exist it will set
-- a default value and return it.
function Map:setdefault(key, defaultval)
   return self[key] or self:set(key,defaultval) or defaultval
end

--- size of map.
-- note: this is a relatively expensive operation!
-- @class function
-- @name Map:len
Map.len = tablex.size

--- put a value into the map.
-- @param key the key
-- @param val the value
function Map:set (key,val)
    self[key] = val
end

--- get a value from the map.
-- @param key the key
-- @return the value, or nil if not found.
function Map:get (key)
    return rawget(self,key)
end

local index_by = tablex.index_by

-- get a list of values indexed by a list of keys.
-- @param keys a list-like table of keys
-- @return a new list
function Map:getvalues (keys)
    return List(index_by(self,keys))
end

Map.iter = pairs

Map.update = tablex.update

function Map:__eq (m)
    -- note we explicitly ask deepcompare _not_ to use __eq!
    return deepcompare(self,m,true)
end

function Map:__tostring ()
    return pretty_write(self,'')
end

-- the Set class --------------------
class(Map,nil,Set)

local function makeset (t)
    return setmetatable(t,Set)
end

function Set:_init (t)
    local mt = getmetatable(t)
    if mt == Set or mt == Map then
        for k in pairs(t) do self[k] = true end
    else
        for _,v in ipairs(t) do self[v] = true end
    end
end

function Set:__tostring ()
    return '['..self:keys():join ','..']'
end

--- add a value to a set.
-- @param key a value
function Set:set (key)
    self[key] = true
end

--- remove a value from a set.
-- @param key a value
function Set:unset (key)
    self[key] = nil
end

--- get a list of the values in a set.
-- @class function
-- @name Set:values
Set.values = Map.keys

--- map a function over the values of a set.
-- @param fn a function
-- @param ... extra arguments to pass to the function.
-- @return a new set
function Set:map (fn,...)
    fn = utils.function_arg(fn)
    local res = {}
    for k in pairs(self) do
        res[fn(k,...)] = true
    end
    return makeset(res)
end

--- union of two sets (also +).
-- @param set another set
-- @return a new set
function Set:union (set)
    return merge(self,set,true)
end
Set.__add = Set.union

--- intersection of two sets (also *).
-- @param set another set
-- @return a new set
function Set:intersection (set)
    return merge(self,set,false)
end
Set.__mul = Set.intersection

--- new set with elements in the set that are not in the other (also -).
-- @param set another set
-- @return a new set
function Set:difference (set)
    return difference(self,set,false)
end
Set.__sub = Set.difference

-- a new set with elements in _either_ the set _or_ other but not both (also ^).
-- @param set another set
-- @return a new set
function Set:symmetric_difference (set)
    return difference(self,set,true)
end
Set.__pow = Set.symmetric_difference

--- is the first set a subset of the second?.
-- @return true or false
function Set:issubset (set)
    for k in pairs(self) do
        if not set[k] then return false end
    end
    return true
end
Set.__lt = Set.subset

--- is the set empty?.
-- @return true or false
function Set:issempty ()
    return next(self) == nil
end

--- are the sets disjoint? (no elements in common).
-- Uses naive definition, i.e. that intersection is empty
-- @param set another set
-- @return true or false
function Set:isdisjoint (set)
    return self:intersection(set):isempty()
end


return pl.class
