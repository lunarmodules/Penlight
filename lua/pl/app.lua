--- Application support functions.
-- <p>See <a href="../../index.html#app">the Guide</a>
-- @class module
-- @name pl.app

local utils = require 'pl.utils'
local path = require 'pl.path'
local lfs = require 'lfs'

--[[
module ('pl.app',utils._module)
]]

local app = {}

local function check_script_name ()
    if _G.arg == nil then utils.error('no command line args available\nWas this run from a main script?') end
    return _G.arg[0]
end

--- add the current script's path to the Lua module path.
-- Applies to both the source and the binary module paths. It makes it easy for
-- the main file of a multi-file program to access its modules in the same directory.
-- @return the current script's path with a trailing slash
function app.require_here ()
    local p = path.dirname(check_script_name())
    if not path.isabs(p) then
        p = path.join(lfs.currentdir(),p)
    end
    if p:sub(-1,-1) ~= path.sep then
        p = p..path.sep
    end
    local so_ext = path.is_windows and 'dll' or 'so'
    local lsep = package.path:find '^;' and '' or ';'
    local csep = package.cpath:find '^;' and '' or ';'
    package.path = ('%s?.lua;%s?%sinit.lua%s%s'):format(p,p,path.sep,lsep,package.path)
    package.cpath = ('%s?.%s%s%s'):format(p,so_ext,csep,package.cpath)
    return p
end

--- return a suitable path for files private to this application.
-- These will look like '~/.SNAME/file', with '~' as with expanduser and
-- SNAME is the name of the script without .lua extension.
-- @param file a filename (w/out path)
-- @return a full pathname
function app.appfile (file)
    local sname = path.basename(check_script_name())
    local name,ext = path.splitext(sname)
    local dir = path.join(path.expanduser('~'),'.'..name)
    if not path.isdir(dir) then
        local ret = lfs.mkdir(dir)
        if not ret then return utils.raise ('cannot create '..dir) end
    end
    return path.join(dir,file)
end


--- parse command-line arguments into flags and parameters.
-- Understands GNU-style command-line flags; short (-f) and long (--flag).
-- These may be given a value with either '=' or ':' (-k:2,--alpha=3.2,-n2);
-- note that a number value can be given without a space.
-- Multiple short args can be combined like so: (-abcd).
-- @param args an array of strings (default is the global 'arg')
-- @param flags_with_values any flags that take values, e.g. <code>{out=true}</code>
-- @return a table of flags (flag=value pairs)
-- @return an array of parameters
function app.parse_args (args,flags_with_values)
	if not args then
		args = _G.arg
		if not args then utils.error "Not in a main program: 'arg' not found" end
	end
	flags_with_values = flags_with_values or {}
    local _args = {}
    local flags = {}
	local i = 1
    while i <= #args do
		local a = args[i]
        local v = a:match('^-(.+)')
		local is_long
        if v then -- we have a flag
			if v:find '^-' then
				is_long = true
				v = v:sub(2)
			end
			if flags_with_values[v] then
                if i == #_args or args[i+1]:find '^-' then
                    return utils.raise ("no value for '"..v.."'")
                end
				flags[v] = args[i+1]
				i = i + 1
			else
				-- a value can be indicated with = or :
				local var,val =  utils.splitv (v,'[=:]')
				var = var or v
				val = val or true
				if not is_long then
					if #var > 1 then
						if var:find '.%d+' then -- short flag, number value
							val = var:sub(2)
							var = var:sub(1,1)
						else -- multiple short flags
							for i = 1,#var do
								flags[var:sub(i,i)] = true
							end
                            val = nil -- prevents use of var as a flag below
						end
					else  -- single short flag (can have value, defaults to true)
						val = val or true
					end
				end
				if val then
					flags[var] = val
				end
			end
        else
            _args[#_args+1] = a
        end
		i = i + 1
    end
    return flags,_args
end

return app
