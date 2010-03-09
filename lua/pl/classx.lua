--- extra classes: MultiMap, OrderedMap and Typed List.
-- @class module
-- @name pl.classx

local function module(...) end
module 'pl.classx'

local classes = require 'pl.class'
local tablex = require 'pl.tablex'
local utils = require 'pl.utils'
local List = require 'pl.list' . List
local class,Map = classes.class,classes.Map
local index_by,tsort,concat = tablex.index_by,table.sort,table.concat
local append,extend,slice = List.append,List.extend,List.slice
local append = table.insert
local is_type = utils.is_type

pl.classx = {}

-- MultiMap is a standard MT
local MultiMap = utils.stdmt.MultiMap

class(Map,nil,MultiMap)
MultiMap._name = 'MultiMap'

function MultiMap:_init (t)
    self:update(t)
end

--- update a MultiMap using a table.
-- @param t either a Multimap or a map-like table.
function MultiMap:update (t)
    if not t then return end
    if Map:class_of(t) then
        for k,v in pairs(t) do
            self[k] = List()
            self[k]:append(v)
        end
    else
        for k,v in pairs(t) do
            self[k] = List(v)
        end
    end
end

--- add a new value to a key.
-- @param key the key
-- @param val the value
function MultiMap:set (key,val)
    if not self[key] then
        self[key] = List()
    end
    self[key]:append(val)
end

local OrderedMap = class(Map)
OrderedMap._name = 'OrderedMap'

function OrderedMap:_init (t)
    self._keys = List()
    if t then self:update(t) end
end

--- update an OrderedMap using a table.
-- @param t map-like table.
function OrderedMap:update (t)
    local keys = self._keys
    for k,v in pairs(t) do
        keys:append(k)
        self[k] = v
    end
end

--- set the key's value.
-- @param key the key
-- @param val the value
function OrderedMap:set (key,val)
    self._keys:append(key)
    self[key] = val
end

--- return the keys in order.
-- (Not a copy!)
function OrderedMap:keys ()
    return self._keys
end

--- return the values in order.
-- this is relatively expensive.
function OrderedMap:values ()
    return List(index_by(self,self._keys))
end

--- sort the keys.
function OrderedMap:sort (cmp)
    tsort(self._keys,cmp)
end

--- iterate over key-value pairs in order.
function OrderedMap:iter ()
    local i = 0
    local keys = self._keys
    local n,idx = #keys
    return function()
        i = i + 1
        if i > #keys then return nil end
        idx = keys[i]
        return idx,self[idx]
    end
end

function OrderedMap:__tostring ()
    local res = {}
    for i,v in ipairs(self._keys) do
        res[i] = tostring(v)..'='..tostring(self[v])
    end
    return '{'..concat(res,',')..'}'
end

local function name_of_type (tp)
    local tname = type(tp)
    if tname == 'table' then
        if rawget(tp,'_class') then
            tname = rawget(tp,'_name')
            if tname then return tname end
        end
        return '<table>'
    else
        return tname
    end
end

--- construct a specific TypedList.
-- For example, class.StringList(TypedList,'string')
-- @class table
-- @name TypedList
local TypedList = class(List)
TypedList._name = 'TypedList'


function TypedList._class_init (klass,type)
    klass._type = type
    klass._name = 'TypedList<'..name_of_type(type)..'>'
end

--- append a value to the list.
-- Will throw an error if the value is not of the correct type.
-- @param val a value of the correct type.
-- @return the list
function TypedList:append (val)
    if not is_type(val,self._type) then error ('not a '..name_of_type(self._type)) end
    return append(self,val)
end

--- extend the list using another list.
-- @param L a list of the same type.
-- @return the list
function TypedList:extend (L)
    if self._class ~= L._class then error ('cannot extend with another List type') end
    return extend(self,L)
end

--- return a slice of the list
-- @param i1 start of slice
-- @param i2 end of slice
-- @return a new typed list
-- @see pl.List:slice
function TypedList:slice (i1,i2)
    return setmetatable(slice(self,i1,i2),self._class)
end

pl.classx.OrderedMap = OrderedMap
pl.classx.MultiMap = MultiMap
pl.classx.TypedList = TypedList

return pl.classx

