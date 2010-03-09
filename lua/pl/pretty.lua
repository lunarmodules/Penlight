----------------------------------------------------------
--- Pretty-printing Lua tables

local append = table.insert
local concat = table.concat
local type,tostring,pairs,ipairs,loadstring,setfenv,require,print,select = type,tostring,pairs,ipairs,loadstring,setfenv,require,print,select
local utils = require 'pl.utils'
local lexer = require 'pl.lexer'
local assert_arg = utils.assert_arg

module('pl.pretty',utils._module)

--- read a string representation of a Lua table.
-- Uses loadstring, but tries to be cautious about loading arbitrary code!
-- It is expecting a string of the form '{...}', with perhaps some whitespace
-- before or after the curly braces. An empty environment is used, and
-- any occurance of the keyword 'function' will be considered a problem.
function read(s)
    assert_arg(1,s,'string')
    if not s:find '^%s*%b{}%s*$' then return nil,"not a Lua table" end
    if s:find '[^\'"%w_]function[^\'"%w_]' then
        local tok = lexer.lua(s)
        for t,v in tok do
            if t == 'keyword' then
                return nil,"cannot have Lua keywords in table definition"
            end
        end
    end
    local chunk,err = loadstring('return '..s,'tbl')
    if not chunk then return nil,err end
    setfenv(chunk,{})
    return chunk()
end

local function quote_if_necessary (v)
    if not v then return ''
    else
        if v:find ' ' then v = '"'..v..'"' end
    end
    return v
end

local keywords


--- create a string representation of a Lua table.
-- @param a table
-- @param space the indent to use (defaults to two spaces)
-- @param not_clever (defaults to false) use for plain output, e.g {['key']=1}
-- @return a string
function write (tbl,space,not_clever)
    assert_arg(1,tbl,'table')
    if not keywords then
        keywords = lexer.get_keywords()
    end
    space = space or '  '
    local lines = {}
    local line = ''
    local tables = {}

    local function is_identifier (s)
        return (s:find('^[%a_][%w_]*$')) and not keywords[s]
    end

    local function put(s)
        if #s > 0 then
            line = line..s
        end
    end

    local function putln (s)
        if #line > 0 then
            line = line..s
            append(lines,line)
            line = ''
        else
            append(lines,s)
        end
    end

    local function eat_last_comma ()
        local n,lastch = #lines
        local lastch = lines[n]:sub(-1,-1)
        if lastch == ',' then
            lines[n] = lines[n]:sub(1,-2)
        end
    end

	local function quote (s)
	    return ('%q'):format(tostring(s))
	end

    local function index (numkey,key)
        if not numkey then key = quote(key) end
        return '['..key..']'
    end

    local writeit
    writeit = function (t,oldindent,indent)
        local tp = type(t)
        if tp ~= 'string' and  tp ~= 'table' then
            putln(quote_if_necessary(tostring(t))..',')
        elseif tp == 'string' then
            if t:find('\n') then
                putln('[[\n'..t..']],')
            else
                putln(quote(t)..', ')
            end
        elseif tp == 'table' then
            if tables[t] then
                putln('<cycle>,')
                return
            end
            tables[t] = true
            local newindent = indent..space
            putln('{')
            local max = 0
            if not not_clever then
                for i,val in ipairs(t) do
                    put(indent)
                    writeit(val,indent,newindent)
                    max = i
                end
            end
            for key,val in pairs(t) do
                local numkey = type(key) == 'number'
                if not_clever then
                    key = tostring(key)
                    put(indent..index(numkey,key)..' = ')
                    writeit(val,indent,newindent)
                else
                    if not numkey or key < 1 or key > max then -- non-array indices
                        if numkey or not is_identifier(key) then
                            key = index(numkey,key)
                        end
                        put(indent..key..' = ')
                        writeit(val,indent,newindent)
                    end
                end
            end
            eat_last_comma()
            putln(oldindent..'},')
        else
            putln(tostring(t)..',')
        end
    end
    writeit(tbl,'',space)
    eat_last_comma()
    return concat(lines,#space > 0 and '\n' or '')
end

--- dump a Lua table out to a file or stdout
-- @param t a table
-- @param file (optional) file name
function dump (t,...)
    if select('#',...) == 0 then
        print(write(t))
        return true
    else
        return utils.raise(utils.writefile((select(1,...)),t))
    end
end
