if _VERSION == "Lua 5.2" then
    require 'debug'
	getfenv = function(level)
		return debug.getfenv(debug.getinfo(level+1,'f').func)
	end
	setfenv = function(level,env)
        if type(level) == 'number' then
            level = debug.getinfo(level+1,'f').func
        end
		return debug.setfenv(level,env)
	end
    unpack = table.unpack
    string.gfind = string.gmatch
else
    local dir_separator = package.config:sub(1,1)
    function package.searchpath (mod,path)
        mod = mod:gsub('%.',dir_separator)
        for m in path:gmatch('[^;]+') do
            local nm = m:gsub('?',mod)
            local f = io.open(nm,'r')
            if f then f:close(); return nm end
        end
    end
end
