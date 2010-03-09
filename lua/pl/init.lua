-- entry point for loading all PL libraries only on demand!

local modules = {
    utils = true,path=true,dir=true,tablex=true,stringio=true,sip=true,
    input=true,seq=true,lexer=true,stringx=true,
    config=true,pretty=true,data=true,func=true,text=true,
    operator=true,lapp=true,array2d=true,
    comprehension=true,luabalanced=true,
    test = true, app = true, file = true,
    -- classes --
    List = 'list', Map = 'class', Set = 'class', class = 'class',
    OrderedMap = 'classx', MultiMap = 'classx', TypedList = 'classx',
}
utils = require 'pl.utils'

for name,klass in pairs(utils.stdmt) do
    klass.__index = function(t,key)
        return require ('pl.'..modules[name])[name][key]
    end
end


local _hook
setmetatable(_G,{
    hook = function(handler)
        _hook = handler
    end,
    __index = function(t,name)
        local found = modules[name]
        local modname
        if found then
            if type(found) == 'string' then
                return require('pl.'..found) [name]
            else
                rawset(_G,name,require('pl.'..name))
                return _G[name]
            end
        elseif _hook then
            return _hook(t,name)
        end
    end
})

-- remove the comment if you want Penlight to always run in strict mode
require 'pl.strict'
