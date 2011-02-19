--- MultiMap.
-- @class module
-- @name pl.MultiMap

local function module(...) end
--[[
module ('pl.classx')
]]

local classes = require 'pl.class'
local tablex = require 'pl.tablex'
local utils = require 'pl.utils'
local List = require 'pl.List' 

local index_by,tsort,concat = tablex.index_by,table.sort,table.concat
local append,extend,slice = List.append,List.extend,List.slice
local append = table.insert
local is_type = utils.is_type

local class = require 'pl.class'
local Map = require 'pl.Map'

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

--- add a new value to a key.  Setting a nil value removes the key.
-- @param key the key
-- @param val the value
function MultiMap:set (key,val)
    if val == nil then
        self[key] = nil
    else
        if not self[key] then
            self[key] = List()
        end
        self[key]:append(val)
    end
end

return MultiMap
