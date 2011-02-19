--- OrderedMap.
-- @class module
-- @name pl.OrderedMap

local function module(...) end
--[[
module ('pl.classx')
]]

local classes = require 'pl.class'
local tablex = require 'pl.tablex'
local utils = require 'pl.utils'
local List = require 'pl.List' 
local class,Map = classes.class,classes.Map
local index_by,tsort,concat = tablex.index_by,table.sort,table.concat
local append,extend,slice = List.append,List.extend,List.slice
local append = table.insert
local is_type = utils.is_type

local classx = {}

local class = require 'pl.class'
local Map = require 'pl.Map'

local OrderedMap = class(Map)
OrderedMap._name = 'OrderedMap'

function OrderedMap:_init (t)
    self._keys = List()
    if t then self:update(t) end
end

local assert_arg,raise = utils.assert_arg,utils.raise

--- update an OrderedMap using a table.
-- If the table is itself an OrderedMap, then its entries will be appended. <br>
-- if it s a table of the form {{key1=val1},{key2=val2},...} these will be appended. <br>
-- Otherwise, it is assumed to be a map-like table, and order of extra entries is arbitrary.
-- @param t a table.
function OrderedMap:update (t)
   assert_arg(1,t,'table')
   if OrderedMap:class_of(t) then
       for k,v in t:iter() do
           self:set(k,v)
       end
   elseif #t > 0 then -- an array must contain {key=val} tables
       if type(t[1]) == 'table' then
           for _,pair in ipairs(t) do
               local key,value = next(pair)
               if not key then return raise 'empty pair initialization table' end
               self:set(key,value)
           end
       else
           return raise 'cannot use an array to initialize an OrderedMap'
       end
   else
       for k,v in pairs(t) do
           self:set(k,v)
       end
   end
end

--- set the key's value.   This key will be appended at the end of the map. <br>
-- If the value is nil, then the key is removed.
-- @param key the key
-- @param val the value
function OrderedMap:set (key,val)
   if not self[key] then -- ensure that keys are unique
       self._keys:append(key)
   elseif val == nil then -- removing a key-value pair
       self._keys:remove_value(key)
   end
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
        local val = self[v]
        local vs = tostring(val)
        if type(val) ~= 'number' then
            vs = '"'..vs..'"'
        end
        res[i] = tostring(v)..'='..vs
    end
    return '{'..concat(res,',')..'}'
end

return OrderedMap



