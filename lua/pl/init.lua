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
    end;
end

local _hook
setmetatable(_G,{
    hook = function(handler)
        _hook = handler
    end,
    __index = function(t,name)
        local found = modules[name]
        -- either true, or the name of the module containing this class.
        -- either way, we load the required module and make it globally available.
        if found then
            if found == true then
                -- e..g pretty.dump causes pl.pretty to become available as 'pretty'
                rawset(_G,name,require('pl.'..name))                
            else
            -- e.g. 'List' causes pl.list to be loaded as above, and then
            -- 'List' becomes global.                
                rawset(_G,found,require('pl.'..found))
                rawset(_G,name,_G[found][name])            
                --print('name',name,'found',found)
            end
            return _G[name]
        elseif _hook then
            return _hook(t,name)
        end
    end
})

if PENLIGHT_STRICT then require 'pl.strict' end
