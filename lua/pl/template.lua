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

local append,format,strsub,strfind = table.insert,string.format,string.sub,string.find

-- If expression nesting is too deep, loading will result in
-- "chunk has too many syntax levels " error.
-- By default the limit is 200, but it can be also consumed by nested blocks
-- added in raw Lua code, so it's better to stop earlier.
local max_concatenations = 100

local function parseDollarParen(pieces, chunk, exec_pat)
    local concatenations = 0
    local s = 1
    for term, executed, e in chunk:gmatch(exec_pat) do
        executed = '('..strsub(executed,2,-2)..')'
        concatenations = concatenations + 2
        if concatenations > max_concatenations then
            append(pieces, format("%q)_put((%s or '')..",
                strsub(chunk,s, term - 1), executed))
            concatenations = 1
        else
            append(pieces, format("%q..(%s or '')..",
                strsub(chunk,s, term - 1), executed))
        end
        s = e
    end
    append(pieces, format("%q", strsub(chunk,s)))
end

local function parseHashLines(chunk,inline_escape,brackets,esc)
    local exec_pat = "()"..inline_escape.."(%b"..brackets..")()"

    local esc_pat = esc.."+([^\n]*\n?)"
    local esc_pat1, esc_pat2 = "^"..esc_pat, "\n"..esc_pat
    local  pieces, s = {"return function(_put) ", n = 1}, 1
    while true do
        local ss, e, lua = strfind(chunk,esc_pat1, s)
        if not e then
            ss, e, lua = strfind(chunk,esc_pat2, s)
            append(pieces, "_put(")
            parseDollarParen(pieces, strsub(chunk,s, ss), exec_pat)
            append(pieces, ")")
            if not e then break end
        end
        append(pieces, lua)
        s = e + 1
    end
    append(pieces, " end")
    return table.concat(pieces)
end

local template = {}

--- expand the template using the specified environment.
-- There are three special fields in the environment table `env`
--
--   * `_parent`: continue looking up in this table (e.g. `_parent=_G`).
--   * `_brackets`: bracket pair that wraps inline Lua expressions,  default is '()'.
--   * `_escape`: character marking Lua lines, default is '#'
--   * `_inline_escape`: character marking inline Lua expression, default is '$'.
--   * `_chunk_name`: chunk name for loaded templates, used if there
--     is an error in Lua code. Default is 'TMP'.
--
-- @string str the template string
-- @tab[opt] env the environment
function template.substitute(str,env)
    env = env or {}
    if rawget(env,"_parent") then
        setmetatable(env,{__index = env._parent})
    end
    local chunk_name = rawget(env,"_chunk_name") or 'TMP'
    local brackets = rawget(env,"_brackets") or '()'
    local escape = rawget(env,"_escape") or '#'
    local inline_escape = rawget(env,"_inline_escape") or '$'
    local code = parseHashLines(str,inline_escape,brackets,escape)
    local fn,err = utils.load(code,chunk_name,'t',env)
    if not fn then return nil,err end
    fn = fn()
    local out = {}
    local res,err = xpcall(function() fn(function(s)
        out[#out+1] = s
    end) end,debug.traceback)
    if not res then
        if env._debug then print(code) end
        return nil,err
    end
    return table.concat(out)
end

return template
