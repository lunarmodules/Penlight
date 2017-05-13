--- A template preprocessor.
-- Originally by [Ricki Lake](http://lua-users.org/wiki/SlightlyLessSimpleLuaPreprocessor)
--
-- There are two rules:
--
--  * lines starting with # are Lua
--  * otherwise, `$(expr)` is the result of evaluating `expr`
--
-- Example:
--
--    #  for i = 1,3 do
--       $(i) Hello, Word!
--    #  end
--    ===>
--    1 Hello, Word!
--    2 Hello, Word!
--    3 Hello, Word!
--
-- Other escape characters can be used, when the defaults conflict
-- with the output language.
--
--    > for _,n in pairs{'one','two','three'} do
--    static int l_${n} (luaState *state);
--    > end
--
-- See  @{03-strings.md.Another_Style_of_Template|the Guide}.
--
-- Dependencies: `pl.utils`
-- @module pl.template

local utils = require 'pl.utils'

local append,format,strsub,strfind,strgsub = table.insert,string.format,string.sub,string.find,string.gsub

local APPENDER = "\n__R_size = __R_size + 1; __R_table[__R_size] = "

local function parseDollarParen(pieces, chunk, exec_pat, newline)
    local s = 1
    for term, executed, e in chunk:gmatch(exec_pat) do
        executed = '('..strsub(executed,2,-2)..')'
        append(pieces, APPENDER..format("%q", strsub(chunk,s, term - 1)))
        append(pieces, APPENDER..format("(%s or '')", executed))
        s = e
    end
    local r
    if newline then
        r = format("%q", strgsub(strsub(chunk,s),"\n",""))
    else
        r = format("%q", strsub(chunk,s))
    end
    if r ~= '""' then
        append(pieces, APPENDER..r)
    end
end

local function parseHashLines(chunk,inline_escape,brackets,esc,newline)
    local exec_pat = "()"..inline_escape.."(%b"..brackets..")()"

    local esc_pat = esc.."+([^\n]*\n?)"
    local esc_pat1, esc_pat2 = "^"..esc_pat, "\n"..esc_pat
    local  pieces, s = {"return function()\nlocal __R_size, __R_table = 0, {}", n = 1}, 1
    while true do
        local ss, e, lua = strfind(chunk,esc_pat1, s)
        if not e then
            ss, e, lua = strfind(chunk,esc_pat2, s)
            parseDollarParen(pieces, strsub(chunk,s, ss), exec_pat, newline)
            if not e then break end
        end
        append(pieces, "\n"..lua)
        s = e + 1
    end
    append(pieces, "\nreturn __R_table\nend")
    return table.concat(pieces)
end

local template = {}

--- expand the template using the specified environment.
-- There are six special fields in the environment table `env`
--
--   * `_parent`: continue looking up in this table (e.g. `_parent=_G`).
--   * `_brackets`: bracket pair that wraps inline Lua expressions,  default is '()'.
--   * `_escape`: character marking Lua lines, default is '#'
--   * `_inline_escape`: character marking inline Lua expression, default is '$'.
--   * `_chunk_name`: chunk name for loaded templates, used if there
--     is an error in Lua code. Default is 'TMP'.
--   * `_debug`: if thruthy, the generated code will be printed upon a render error
--
-- @string str the template string
-- @tab[opt] env the environment
-- @return `rendered template + nil + code`, or `nil + error + code`. The last return value
-- `code` is only returned if the debug option is used.
function template.substitute(str,env)
    env = env or {}
    local t, err = template.compile(str, {
        chunk_name = rawget(env,"_chunk_name"),
        escape = rawget(env,"_escape"),
        inline_escape = rawget(env,"_inline_escape"),
        inline_brackets = rawget(env,"_brackets"),
        newline = nil,
        debug = rawget(env,"_debug")
    })
    if not t then return t, err end
    
    return t:render(env, rawget(env,"_parent"), rawget(env,"_debug"))
end

--- executes the previously compiled template and renders it.
-- @tab[opt] env the environment.
-- @tab[opt] parent continue looking up in this table (e.g. `_parent=_G`).
-- @bool[opt] db if thruthy, it will print the code upon a render error. Note:
-- the template must have been compiled with the debug option as well! (only
-- here for backward compatibility, as the function will return the generated
-- code anyway if available)
-- @return `rendered template + nil + code`, or `nil + error + code`. The last return value
-- `code` is only returned if the template was compiled with the debug option.
local render = function(self, env, parent, db)
    env = env or {}
    if parent then  -- parent is a bit silly, but for backward compatibility retained
        setmetatable(env, {__index = parent})
    end
    setmetatable(self.env, {__index = env})

    local res, out = xpcall(self.fn, debug.traceback)
    if not res then
        if self.code and db then print(self.code) end
        return nil, out, self.code
    end
    return table.concat(out), nil, self.code
end

--- compiles the template.
-- Returns an object that can repeatedly be run without parsing the template
-- again.
-- The options passed in the `opts` table support the following options:
--
--   * `chunk_name`: chunk name for loaded templates, used if there
--     is an error in Lua code. Default is 'TMP'.
--   * `escape`: character marking Lua lines, default is '#'
--   * `inline_escape`: character marking inline Lua expression, default is '$'.
--   * `inline_brackets`: bracket pair that wraps inline Lua expressions, default is '()'.
--   * `newline`: string to replace newline characters, default is `nil` (not replacing newlines).
--   * `debug`: if thruthy, the generated code will be printed upon a render error, default is `nil`.
--
-- @string str the template string
-- @table[opt] opts the compliation options to use
-- @return template object, or nil + error + code
-- @usage
-- local t, err = template.compile(my_template)
-- local rendered , err = t:render(my_env, parent)
function template.compile(str, opts)
    opts = opts or {}
    local chunk_name = opts.chunk_name or 'TMP'
    local escape = opts.escape or '#'
    local inline_escape = opts.inline_escape or '$'
    local inline_brackets = opts.inline_brackets or '()'
    
    local code = parseHashLines(str,inline_escape,inline_brackets,escape,opts.newline)
    local env = {}
    local fn, err = utils.load(code, chunk_name,'t',env)
    if not fn then return nil, err, code end
    return {
        fn = fn(),
        env = env,
        render = render,
        code = opts.debug and code or nil,
    }
end

return template
