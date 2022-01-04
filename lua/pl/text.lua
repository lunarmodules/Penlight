--- Text processing utilities.
--
-- This provides a Template class (modeled after the same from the Python
-- libraries, see string.Template). It also provides similar functions to those
-- found in the textwrap module.
--
-- See  @{03-strings.md.String_Templates|the Guide}.
--
-- Dependencies: `pl.utils`, `pl.types`
-- @module pl.text

local gsub = string.gsub
local concat, t_remove = table.concat, table.remove
local utils = require 'pl.utils'
local bind1,usplit,assert_arg = utils.bind1,utils.split,utils.assert_arg
local is_callable = require 'pl.types'.is_callable
local unpack = utils.unpack
local pack = utils.pack

local text = {}


local function makelist(l)
    return setmetatable(l, require('pl.List'))
end

local function lstrip(str)  return (str:gsub('^%s+',''))  end
local function strip(str)  return (lstrip(str):gsub('%s+$','')) end
local function split(s,delim)  return makelist(usplit(s,delim)) end

local function imap(f,t,...)
    local res = {}
    for i = 1,#t do res[i] = f(t[i],...) end
    return res
end

local function _indent (s,sp)
    local sl = split(s,'\n')
    return concat(imap(bind1('..',sp),sl),'\n')..'\n'
end

--- indent a multiline string.
-- @tparam string s the (multiline) string
-- @tparam integer n the size of the indent
-- @tparam[opt=' '] string ch the character to use when indenting
-- @return indented string
function text.indent (s,n,ch)
    assert_arg(1,s,'string')
    assert_arg(2,n,'number')
    return _indent(s,string.rep(ch or ' ',n))
end

--- dedent a multiline string by removing any initial indent.
-- useful when working with [[..]] strings.
-- Empty lines are ignored.
-- @tparam string s the (multiline) string
-- @return a string with initial indent zero.
-- @usage
-- local s = dedent [[
--          One
--
--        Two
--
--      Three
-- ]]
-- assert(s == [[
--     One
--
--   Two
--
-- Three
-- ]])
function text.dedent (s)
    assert_arg(1,s,'string')
    local lst = split(s,'\n')
    if #lst>0 then
      local ind_size = math.huge
      for i, line in ipairs(lst) do
        local i1, i2 = lst[i]:find('^%s*[^%s]')
        if i1 and i2 < ind_size then
          ind_size = i2
        end
      end
      for i, line in ipairs(lst) do
        lst[i] = lst[i]:sub(ind_size, -1)
      end
    end
    return concat(lst,'\n')..'\n'
end


do
  local buildline = function(words, size, breaklong)
    -- if overflow is set, a word longer than size, will overflow the size
    -- otherwise it will be chopped in line-length pieces
    local line = {}
    if #words[1] > size then
      -- word longer than line
      if not breaklong then
        line[1] = words[1]
        t_remove(words, 1)
      else
        line[1] = words[1]:sub(1, size)
        words[1] = words[1]:sub(size + 1, -1)
      end
    else
      local len = 0
      while words[1] and (len + #words[1] <= size) or
            (len == 0 and #words[1] == size) do
        if words[1] ~= "" then
          line[#line+1] = words[1]
          len = len + #words[1] + 1
        end
        t_remove(words, 1)
      end
    end
    return strip(concat(line, " ")), words
  end

  --- format a paragraph into lines so that they fit into a line width.
  -- It will not break long words by default, so lines can be over the length
  -- to that extent.
  -- @tparam string s the string to format
  -- @tparam[opt=70] integer width the margin width
  -- @tparam[opt=false] boolean breaklong if truthy, words longer than the width given will be forced split.
  -- @return a list of lines (List object), use `fill` to return a string instead of a `List`.
  -- @see pl.List
  -- @see fill
  text.wrap = function(s, width, breaklong)
    s = s:gsub('\n',' ') -- remove line breaks
    s = strip(s)         -- remove leading/trailing whitespace
    if s == "" then
      return { "" }
    end
    width = width or 70
    local out = {}
    local words = split(s, "%s")
    while words[1] do
      out[#out+1], words = buildline(words, width, breaklong)
    end
    return makelist(out)
  end
end

--- format a paragraph so that it fits into a line width.
-- @tparam string s the string to format
-- @tparam[opt=70] integer width the margin width
-- @tparam[opt=false] boolean breaklong if truthy, words longer than the width given will be forced split.
-- @return a string, use `wrap` to return a list of lines instead of a string.
-- @see wrap
function text.fill (s,width,breaklong)
    return concat(text.wrap(s,width,breaklong),'\n') .. '\n'
end


local function _substitute(s,tbl,safe)
  local subst
  if is_callable(tbl) then
      subst = tbl
  else
      function subst(f)
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
  end
  local res = gsub(s,'%${([%w_]+)}',subst)
  return (gsub(res,'%$([%w_]+)',subst))
end

--- Python-style formatting operator.
-- Calling `text.format_operator()` overloads the % operator for strings to give
-- Python/Ruby style formated output.
-- This is extended to also do template-like substitution for map-like data.
--
-- Note this goes further than the original, and will allow these cases:
--
-- 1. a single value
-- 2. a list of values
-- 3. a map of var=value pairs
-- 4. a function, as in gsub
--
-- For the second two cases, it uses $-variable substituion.
--
-- When called, this function will monkey-patch the global `string` metatable by
-- adding a `__mod` method.
--
-- See <a href="http://lua-users.org/wiki/StringInterpolation">the lua-users wiki</a>
--
-- @usage
-- require 'pl.text'.format_operator()
-- local out1 = '%s = %5.3f' % {'PI',math.pi}                   --> 'PI = 3.142'
-- local out2 = '$name = $value' % {name='dog',value='Pluto'}   --> 'dog = Pluto'
function text.format_operator()

  local format = string.format

  -- a more forgiving version of string.format, which applies
  -- tostring() to any value with a %s format.
  local function formatx (fmt,...)
      local args = pack(...)
      local i = 1
      for p in fmt:gmatch('%%.') do
          if p == '%s' and type(args[i]) ~= 'string' then
              args[i] = tostring(args[i])
          end
          i = i + 1
      end
      return format(fmt,unpack(args))
  end

  local function basic_subst(s,t)
      return (s:gsub('%$([%w_]+)',t))
  end

  getmetatable("").__mod = function(a, b)
      if b == nil then
          return a
      elseif type(b) == "table" and getmetatable(b) == nil then
          if #b == 0 then -- assume a map-like table
              return _substitute(a,b,true)
          else
              return formatx(a,unpack(b))
          end
      elseif type(b) == 'function' then
          return basic_subst(a,b)
      else
          return formatx(a,b)
      end
  end
end


--- @section Template


local Template = {}
text.Template = Template
Template.__index = Template
setmetatable(Template, {
    __call = function(obj,tmpl)
        return Template.new(tmpl)
    end})

--- Creates a new Template class.
-- This is a shortcut to `Template.new(tmpl)`.
-- @tparam string tmpl the template string
-- @function Template
-- @treturn Template
function Template.new(tmpl)
    assert_arg(1,tmpl,'string')
    local res = {}
    res.tmpl = tmpl
    setmetatable(res,Template)
    return res
end

--- substitute values into a template, throwing an error.
-- This will throw an error if no name is found.
-- @tparam table tbl a table of name-value pairs.
-- @return string with place holders substituted
function Template:substitute(tbl)
    assert_arg(1,tbl,'table')
    return _substitute(self.tmpl,tbl,false)
end

--- substitute values into a template.
-- This version just passes unknown names through.
-- @tparam table tbl a table of name-value pairs.
-- @return string with place holders substituted
function Template:safe_substitute(tbl)
    assert_arg(1,tbl,'table')
    return _substitute(self.tmpl,tbl,true)
end

--- substitute values into a template, preserving indentation. <br>
-- If the value is a multiline string _or_ a template, it will insert
-- the lines at the correct indentation. <br>
-- Furthermore, if a template, then that template will be substituted
-- using the same table.
-- @tparam table tbl a table of name-value pairs.
-- @return string with place holders substituted
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


return text
