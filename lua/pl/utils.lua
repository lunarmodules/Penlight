--- Generally useful routines.
-- @class module
-- @name pl.utils
local format,gsub,byte = string.format,string.gsub,string.byte
local clock = os.clock
local stdout = io.stdout
local append = table.insert

local collisions = {}

--[[
module ('pl.utils')
]]

local utils = {}

utils._VERSION = "0.9.0"

utils.dir_separator = _G.package.config:sub(1,1)

--- end this program gracefully.
-- @param code The exit code
-- @param msg A message to be printed
-- @param ... extra arguments for fprintf
-- @see utils.fprintf
function utils.quit(code,msg,...)
    if type(code) == 'string' then
        msg = code
        code = -1
    end
    utils.fprintf(io.stderr,msg,...)
    io.stderr:write('\n')
    os.exit(code)
end

--- print an arbitrary number of arguments using a format.
--  @param fmt The format (see string.format)
function utils.printf(fmt,...)
    utils.fprintf(stdout,fmt,...)
end

--- write an arbitrary number of arguments to a file using a format.
-- @param fmt The format (see string.format)
function utils.fprintf(f,fmt,...)
    utils.assert_string(2,fmt)
    f:write(format(fmt,...))
end

local function import_symbol(T,k,v,libname)
    local key = rawget(T,k)
    -- warn about collisions!
    if key and k ~= '_M' and k ~= '_NAME' and k ~= '_PACKAGE' and k ~= '_VERSION' then
        utils.printf("warning: '%s.%s' overrides existing symbol\n",libname,k)
    end
    rawset(T,k,v)
end

local function lookup_lib(T,t)
    for k,v in pairs(T) do
        if v == t then return k end
    end
    return '?'
end

local already_imported = {}

--- take a table and 'inject' it into the local namespace.
-- @param t The Table
-- @param T An optional destination table (defaults to callers environment)
function utils.import(t,T)
    T = T or _G
    t = t or utils
    if type(t) == 'string' then
        t = require (t)
    end
    local libname = lookup_lib(T,t)
    if already_imported[t] then return end
    already_imported[t] = libname
    for k,v in pairs(t) do
        import_symbol(T,k,v,libname)
    end
end

utils.patterns = {
    FLOAT = '[%+%-%d]%d*%.?%d*[eE]?[%+%-]?%d*',
    INTEGER = '[+%-%d]%d*',
    IDEN = '[%a_][%w_]*',
    FILE = '[%a%.\\][:%][%w%._%-\\]*'
}

--- escape any 'magic' characters in a string
-- @param s The input string
function utils.escape(s)
    utils.assert_string(1,s)
    return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'))
end

--- return either of two values, depending on a condition.
-- @param cond A condition
-- @param value1 Value returned if cond is true
-- @param value2 Value returned if cond is false (can be optional)
function utils.choose(cond,value1,value2)
    if cond then return value1
    else return value2
    end
end

--- return the contents of a file as a string
-- @param filename The file path
-- @return file contents
function utils.readfile(filename,is_bin)
	local mode = is_bin and 'b' or ''
	utils.assert_string(1,filename)
    local f,err = io.open(filename,'r'..mode)
    if not f then return raise (err) end
    local res,err = f:read('*a')
	f:close()
    if not res then return raise (err) end
    return res
end

--- write a string to a file
-- @param filename The file path
-- @param str The string
function utils.writefile(filename,str)
    utils.assert_string(1,filename)
    utils.assert_string(2,str)
	local f,err = io.open(filename,'w')
    if not f then return raise(err) end
    f:write(str)
    f:close()
    return true
end

--- return the contents of a file as a list of lines
-- @param filename The file path
-- @return file contents as a table
function utils.readlines(filename)
    utils.assert_string(1,filename)
    local f,err = io.open(filename,'r')
    if not f then return raise(err) end
    local res = {}
    for line in f:lines() do
        append(res,line)
    end
    f:close()
    return res
end

---- split a string into a list of strings separated by a delimiter.
-- @param s The input string
-- @param re A regular expression; defaults to spaces
-- @return a list-like table
function utils.split(s,re)
    utils.assert_string(1,s)
    local i1 = 1
    local ls = {}
    if not re then re = '%s+' end
    if re == '' then return {s} end
    while true do
        local i2,i3 = s:find(re,i1)
        if not i2 then
            local last = s:sub(i1)
            if last ~= '' then append(ls,last) end
            if #ls == 1 and ls[1] == '' then
                return {}
            else
                return ls
            end
        end
        append(ls,s:sub(i1,i2-1))
        i1 = i3+1
    end
end


--- split a string into a number of values.
-- @param s the string
-- @param re the delimiter, default space
-- @return n values
-- @usage first,next = splitv('jane:doe',':')
-- @see split
function utils.splitv (s,re)
    return unpack(utils.split(s,re))
end

if not loadin then
    function loadin(env,str)
        local chunk,err = loadstring(str)
        if chunk then setfenv(chunk,env) end
        return chunk,err
    end
end

if not table.pack then
    function table.pack (...)
        return {n=select('#',...); ...}
    end
end
if not table.pack then table.pack = pack end
if not pack then pack = table.pack end

--- take an arbitrary set of arguments and make into a table.
-- This returns the table and the size; works fine for nil arguments
-- @param ... arguments
-- @return table
-- @return table size
-- @usage local t,n = utils.args(...)

--- 'memoize' a function (cache returned value for next call).
-- This is useful if you have a function which is relatively expensive,
-- but you don't know in advance what values will be required, so
-- building a table upfront is wasteful/impossible.
-- @param func a function of at least one argument
-- @return a function with at least one argument, which is used as the key.
function utils.memoize(func)
    return setmetatable({}, {
        __index = function(self, k, ...)
            local v = func(k,...)
            self[k] = v
            return v
        end,
        __call = function(self, k) return self[k] end
    })
end

--- is the object either a function or a callable object?.
function utils.is_callable (obj)
    return type(obj) == 'function' or getmetatable(obj) and getmetatable(obj).__call
end

--- is the object of the specified type?.
-- If the type is a string, then use type, otherwise compare with metatable
-- @param obj an object
-- @param tp a type
function utils.is_type (obj,tp)
    if type(tp) == 'string' then return type(obj) == tp end
    local mt = getmetatable(obj)
    return tp == mt
end

utils.stdmt = { List = {}, Map = {}, Set = {}, MultiMap = {} }

local _function_factories = {}

function utils.add_function_factory (mt,fun)
    _function_factories[mt] = fun
end

local ops

--- process a function argument. 
-- This is used throughout Penlight and defines what is meant by a function: 
-- Something that is callable, or an operator string as defined by <code>pl.operator</code>, 
-- such as '>' or '#'.
-- @param idx argument index
-- @param f a function, operator string, or callable object
-- @param msg optional error message
-- @return a callable
-- @see utils.is_callable
function utils.function_arg (idx,f)
    utils.assert_arg(1,idx,'number')
    if not msg then msg = " must be callable" end
    local tp = type(f)
    if tp == 'function' then return f end  -- no worries!
    -- ok, a string can correspond to an operator (like '==')
    if tp == 'string' then
        if not ops then ops = require 'pl.operator'.optable end
        local fn = ops[f]
        if fn then return fn end
    elseif tp == 'table' or tp == 'userdata' then
        local mt = getmetatable(f)
        if not mt then error('not a callable object') end
        local ff = _function_factories[mt]
        if not ff then
            if not mt.__call then error('not a callable object',2) end
            return f
        else
            return ff(f) -- we have a function factory for this type!
        end
    end
    if idx > 0 then        
        error("argument "..idx..": "..msg,2)
    else
        error(msg,2)    
    end
end

--- bind the first argument of the function to a value.
-- @param fn a function of at least two values (may be an operator string)
-- @param p a value
-- @return a function such that f(x) is fn(p,x)
-- @see pl.func.curry
function utils.bind1 (fn,p)
	fn = utils.function_arg(1,fn)
    return function(...) return fn(p,...) end
end

--- assert that the given argument is in fact of the correct type.
-- @param n argument index
-- @param val the value
-- @param tp the type
-- @param verify an optional verfication function
-- @param msg an optional custom message
-- @param lev optional stack position for trace, default 2
-- @usage assert_arg(1,t,'table')
-- @usage assert_arg(n,val,'string',path.isdir,'not a directory')
function utils.assert_arg (n,val,tp,verify,msg,lev)
    if type(val) ~= tp then
        error(("argument %d expected a '%s', got a '%s'"):format(n,tp,type(val)),2)
    end
    if verify and not verify(val) then
        error(("argument %d: '%s' %s"):format(n,val,msg),lev or 2)
    end
end

--- assert the common case that the argument is a string.
-- @param n argument index
-- @param val a value that must be a string
function utils.assert_string (n,val)
	utils.assert_arg(n,val,'string',nil,nil,nil,3)
end

local err_mode = 'default'

--- control the error strategy used by Penlight. 
-- Controls how <code>utils.raise</code> works; the default is for it
-- to return nil and the error string, but if the mode is 'error' then
-- it will throw an error. If mode is 'quit' it will immediately terminate
-- the program.
-- @param mode - either 'default', 'quit'  or 'error'
-- @see utils.raise
function utils.on_error (mode)
	err_mode = mode
end

--- used by Penlight functions to return errors.  Its global behaviour is controlled
-- by <code>utils.on_error</code>
-- @param err the error string.
-- @see utils.on_error
function utils.raise (err)
    if err_mode == 'default' then return nil,err
	elseif err_mode == 'quit' then quit(err)
	else error(err,2)
	end
end

return utils


