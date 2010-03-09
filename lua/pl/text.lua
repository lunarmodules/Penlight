--- Text processing utilities. <br>
-- This provides a Template class (modeled after the same from the Python <br>
-- libraries, see string.Template). It also provides dedent, wrap and
-- fill as found in the textwrap module, as well as indent.
-- @class module
-- @name pl.text

local print = print
local gsub = string.gsub
local stringx = require 'pl.stringx'
local concat = table.concat
local imap = require 'pl.tablex'.imap
local utils = require 'pl.utils'
local bind1 = utils.bind1
local split = stringx.split
local setmetatable,getmetatable,tostring,string = setmetatable,getmetatable,tostring,string
local List = require 'pl.list'.List
local lstrip,strip = stringx.lstrip,stringx.strip
local assert_arg = utils.assert_arg

module ('pl.text',utils._module)

local function _indent (s,sp)
    local sl = split(s,'\n')
    return concat(imap(bind1('..',sp),sl),'\n')..'\n'
end

--- indent a multiline string.
-- @param s the string
-- @param n the size of the indent
-- @param ch the character to use when indenting (default ' ')
-- @return indented string
function indent (s,n,ch)
    assert_arg(1,s,'string')
    assert_arg(2,s,'number')
    return _indent(s,string.rep(ch or ' ',n))
end

--- dedent a multiline string by removing any initial indent.
-- useful when working with [[..]] strings.
-- @param s the string
-- @return a string with initial indent zero.
function dedent (s)
    assert_arg(1,s,'string')
    local sl = split(s,'\n')
    local i1,i2 = sl[1]:find('^%s*')
    sl = sl:map(string.sub,i2+1)
    return sl:concat('\n')..'\n'
end

--- format a paragraph into lines so that they fit into a line width.
-- It will not break long words, so lines can be over the length
-- to that extent.
-- @param s the string
-- @param width the margin width, default 70
-- @return a list of lines
function wrap (s,width)
    assert_arg(1,s,'string')
    width = width or 70
    s = s:gsub('\n',' ')
    local i,nxt = 1
    local lines = List()
    while i < #s do
        nxt = i+width
        if s:find("[%w']",nxt) then -- inside a word
            nxt = s:find('%W',nxt+1) -- so find word boundary
        end
        line = s:sub(i,nxt)
        i = i + #line
        lines:append(strip(line))
    end
    return lines
end

--- format a paragraph so that it fits into a line width.
-- @param s the string
-- @param width the margin width, default 70
-- @return a string
-- @see wrap
function fill (s,width)
    return wrap(s,width):concat '\n' .. '\n'
end

Template = {}
Template.__index = Template
setmetatable(Template, {
    __call = function(obj,tmpl)
        return Template.new(tmpl)
    end})

function Template.new(tmpl)
    assert_arg(1,tmpl,'string')
    local res = {}
    res.tmpl = tmpl
    setmetatable(res,Template)
    return res
end

local function _substitute(s,tbl,safe)
    local function subst(f)
        local s = tbl[f]
        if not s then
            if safe then
                return f
            else
                error("not present in table "..f)
            end
        else
            return s
        end
    end
    local res = gsub(s,'%${([%w_]+)}',subst)
    return (gsub(res,'%$([%w_]+)',subst))
end

--- substitute values into a template, throwing an error.
-- This will throw an error if no name is found.
-- @param tbl a table of name-value pairs.
function Template:substitute(tbl)
    assert_arg(1,tbl,'table')
    return _substitute(self.tmpl,tbl,false)
end

--- substitute values into a template.
-- This version just passes unknown names through.
-- @param tbl a table of name-value pairs.
function Template:safe_substitute(tbl)
    assert_arg(1,tbl,'table')
    return _substitute(self.tmpl,tbl,true)
end

--- substitute values into a template, preserving indentation. <br>
-- If the value is a multiline string _or_ a template, it will insert
-- the lines at the correct indentation. <br>
-- Furthermore, if a template, then that template will be subsituted
-- using the same table.
-- @param tbl a table of name-value pairs.
function Template:indent_substitute(tbl)
    assert_arg(1,tbl,'table')
    if not self.strings then
        self.strings = split(self.tmpl,'\n')
    end
    -- the idea is to substitute line by line, grabbing any spaces as
    -- well as the $var. If the value to be substituted contains newlines,
    -- then we split that into lines and adjust the indent before inserting.
    local function subst(line)
        return line:gsub('(%s*)%$([%w_]+)',function(sp,f)
			local subtmpl
            local s = tbl[f]
            if not s then error("not present in table "..f) end
			if getmetatable(s) == Template then
				subtmpl = s
				s = s.tmpl
			else
				s = tostring(s)
			end
            if s:find '\n' then
                s = _indent(s,sp)
            end
			if subtmpl then return _substitute(s,tbl)
			else return s
			end
        end)
    end
    local lines = imap(subst,self.strings)
    return concat(lines,'\n')..'\n'
end

