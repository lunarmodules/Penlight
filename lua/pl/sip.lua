---------------------------------
--- Simple Input Patterns (SIP). SIP patterns start with '$', then a
-- one-letter type, and then an optional variable in curly braces. <br>
-- Example:
-- <pre class=example>sip.match('($q{first},$q{second})','("john","smith")',res)</pre>
-- <pre class=example>result is true and 'res' is: {second='smith',first='john'} </pre>
-- See <a href="../../index.html#sip">the Guide</a>

local utils = require 'pl.utils'
local patterns = utils.patterns
local append,concat = table.insert,table.concat
local concat = table.concat
local ipairs,loadstring,type,unpack = ipairs,loadstring,type,unpack
local io,_G = io,_G
local print,rawget = print,rawget
local assert_arg = utils.assert_arg

module ('pl.sip',utils._module)

local brackets = {['<'] = '>', ['('] = ')', ['{'] = '}', ['['] = ']' }
local stdclasses = {a=1,c=0,d=1,l=1,p=0,u=1,w=1,x=1,s=0}

local _patterns = {}


local function group(s)
    return '('..s..')'
end

-- escape all magic characters except $, which has special meaning
-- Also, un-escape any characters after $, so $( passes through as is.
local function escape (spec)
    --_G.print('spec',spec)
    local res = spec:gsub('[%-%.%+%[%]%(%)%^%%%?%*]','%%%1'):gsub('%$%%(%S)','$%1')
	--_G.print('res',res)
	return res
end

local function compress_space (s)
    return s:gsub('%s+','%%s*')
end

-- [handling of spaces in patterns]
-- spaces may be 'compressed' (i.e will match zero or more spaces)
-- before or after a alphanum pattern,
-- if the character before the space is not alphanum
-- otherwise, always just before or after a pattern
local function compress_spaces (s)
    s = s:gsub('%W%s+%$[vifadxlu]',compress_space)
    s = s:gsub('%$[vifadxlu]%s+[^%$%w]',compress_space)
    s = s:gsub('%$[^vifadxlu]%s+',compress_space)
    s = s:gsub('%s+%$[^vifadxlu]',compress_space)
    return s
end

--- convert a SIP pattern into the equivalent Lua regular expression.
-- @param spec a SIP pattern
-- @param fieldnames an optional table which is to be filled with fieldnames
-- @param fieldtypes an optional table which maps the names to their types
function create_pattern (spec,options)
    assert_arg(1,spec,'string')
    local fieldnames,fieldtypes = {},{}
    if type(spec) == 'string' then
        spec = escape(spec)
    else
        local res = {}
        for i,s in ipairs(spec) do
            res[i] = escape(s)
        end
        spec = concat(res,'.-')
    end

    local kount = 1

    local function addfield (name,type)
        if not name then name = kount end
        if fieldnames then append(fieldnames,name) end
        if fieldtypes then fieldtypes[name] = type end
        kount = kount + 1
    end

    local named_vars, pattern
    named_vars = spec:find('{%a+}')
    pattern = '%$%S'

    if options and options.at_start then
        spec = '^'..spec
    end
    if spec:sub(-1,-1) == '$' then
        spec = spec:sub(1,-2)..'$r'
        if named_vars then spec = spec..'{rest}' end
    end

    local names

    if named_vars then
        names = {}
        spec = spec:gsub('{(%a+)}',function(name)
            append(names,name)
            return ''
        end)
    end
    spec = compress_spaces(spec)

    local k = 1
    local err
    local r = (spec:gsub(pattern,function(s)
        local type,name
        type = s:sub(2,2)
        if names then name = names[k]; k=k+1 end
        -- this kludge is necessary because %q generates two matches, and
        -- we want to ignore the first. Not a problem for named captures.
        if not names and type == 'q' then
            addfield(nil,type)
        else
            addfield(name,type)
        end
        local res
        if type == 'v' then
            res = group(patterns.IDEN)
        elseif type == 'i' then
            res = group(patterns.INTEGER)
        elseif type == 'f' then
            res = group(patterns.FLOAT)
        elseif type == 'r' then
            res = '(%S.*)'
        elseif type == 'q' then
            -- some Lua pattern matching voodoo; we want to match '...' as
            -- well as "...", and can use the fact that %n will match a
            -- previous capture. Adding an extra field comes from needing
            -- to accomodate the extra spurious match (which is either ' or ")
            addfield(name,type)
            res = '(["\'])(.-)%'..(kount-2)
        elseif type == 'p' then
            res = '([%a]?[:]?[\\/%.%w_]+)'
        else
            local endbracket = brackets[type]
            if endbracket then
                res = '(%b'..type..endbracket..')'
            elseif stdclasses[type] or stdclasses[type:lower()] then
                res = '(%'..type..'+)'
            else
                err = "unknown format type or character class"
            end
        end
        return res
    end))
    --print(r,err)
    if err then
        return nil,err
    else
        return r,fieldnames,fieldtypes
    end
end


local function tnumber (s)
    return s == 'd' or s == 'i' or s == 'f'
end

function create_spec_fun(spec,options)
    local fieldtypes,fieldnames
    local ls = {}
    spec,fieldnames,fieldtypes = create_pattern(spec,options)
    if not spec then return spec,fieldnames end
    local named_vars = type(fieldnames[1]) == 'string'
    for i = 1,#fieldnames do
        append(ls,'mm'..i)
    end
    local fun = ('return (function(s,res)\n\t\local %s = s:match(%q)\n'):format(concat(ls,','),spec)
    fun = fun..'\tif not mm1 then return false end\n'
    local k = 1
    for i,f in ipairs(fieldnames) do
        if f ~= '_' then
            local var = 'mm'..i
            if tnumber(fieldtypes[f]) then
                var = 'tonumber('..var..')'
            elseif brackets[fieldtypes[f]] then
                var = var..':sub(2,-2)'
            end
            if named_vars then
                fun = ('%s\tres.%s = %s\n'):format(fun,f,var)
            else
                fun = ('%s\tres[%d] = %s\n'):format(fun,k,var)
            end
            k = k + 1
        end
    end
    return fun..'\treturn true\nend)\n', named_vars
end

--- convert a SIP pattern into a matching function.
-- The returned function takes two arguments, the line and an empty table.
-- If the line matched the pattern, then this function return true
-- and the table is filled with field-value pairs.
-- @param spec a SIP pattern
-- @param options optional table; {anywhere=true} will stop pattern anchoring at start
-- @return a function if successful, or nil,<error>
function compile(spec,options)
    assert_arg(1,spec,'string')
    local fun,names = create_spec_fun(spec,options)
    if not fun then return nil,names end
    if rawget(_G,'_DEBUG') then print(fun) end
    chunk,err = loadstring(fun,'tmp')
    if err then return nil,err end
    return chunk(),names
end

local cache = {}

--- match a SIP pattern against a string.
-- @param spec a SIP pattern
-- @param line a string
-- @param res a table to receive values
-- @param options (optional) option table
-- @return true or false
function match (spec,line,res,options)
    assert_arg(1,spec,'string')
    assert_arg(2,line,'string')
    assert_arg(3,res,'table')
    if not cache[spec] then
        cache[spec] = compile(spec,options)
    end
    return cache[spec](line,res)
end

--- match a SIP pattern against the start of a string.
-- @param spec a SIP pattern
-- @param line a string
-- @param res a table to receive values
-- @return true or false
function match_at_start (spec,line,res)
    return match(spec,line,res,{at_start=true})
end

--- given a pattern and a file object, return an iterator over the results
-- @param spec a SIP pattern
-- @param f a file - use standard input if not specified.
function fields (spec,f)
    assert_arg(1,spec,'string')
    f = f or io.stdin
    local fun,err = compile(spec)
    if not fun then return nil,err end
    local res = {}
    return function()
        while true do
            local line = f:read()
            if not line then return end
            if fun(line,res) then
                local values = res
                res = {}
                return unpack(values)
            end
        end
    end
end

--- register a match which will be used in the read function.
-- @param spec a SIP pattern
-- @param fun a function to be called with the results of the match
-- @see read
function pattern (spec,fun)
    assert_arg(1,spec,'string')
    local pat,named = compile(spec)
    append(_patterns,{pat=pat,named=named,callback=fun or false})
end

--- enter a loop which applies all registered matches to the input file.
-- @param f a file object; if nil, then io.stdin is assumed.
function read (f)
    local owned,err
    f = f or io.stdin
    if type(f) == 'string' then
        f,err = io.open(f)
        if not f then utils.quit(1,err) end
        owned = true
    end
    local res = {}
    for line in f:lines() do
        for _,item in ipairs(_patterns) do
            if item.pat(line,res) then
                if item.callback then
                    if item.named then
                        item.callback(res)
                    else
                        item.callback(unpack(res))
                    end
                end
                res = {}
                break
            end
        end
    end
    if owned then f:close() end
end
