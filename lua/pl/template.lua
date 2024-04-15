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

local append, concat = table.insert, table.concat
local format, strsub, strfind, strgsub, strrep = string.format, string.sub, string.find, string.gsub, string.rep

local APPENDER = " __R_size = __R_size + 1; __R_table[__R_size] = "

-- When this function returns, `pieces` is guaranteed to hold a complete Lua
-- statement, meaning that new statements can be appended without creating
-- invalid Lua code.
local function parseDollarParen(pieces, chunk, exec_pat, newline)
    local s = 1
    for term, executed, e in chunk:gmatch(exec_pat) do
        executed = '(' .. strsub(executed, 2, -2) .. ')'
        append(pieces, APPENDER .. format("%q;", strsub(chunk, s, term - 1)))
        append(pieces, APPENDER .. format("__tostring(%s or '');", executed))
        s = e
    end
    local remainder, newlines_removed
    if newline then
        remainder, newlines_removed = strgsub(strsub(chunk, s), "\n", "")
    else
        remainder, newlines_removed = strsub(chunk, s), 0
    end
    if remainder ~= "" then
        append(pieces, APPENDER .. format("%q;", remainder))
    end
    if newlines_removed > 0 then
        append(pieces, strrep("\n", newlines_removed))
    end
end

local function parseHashLines(chunk, inline_escape, brackets, esc, newline)
    -- Escape special characters to avoid invalid expressions
    inline_escape = utils.escape(inline_escape)
    esc = utils.escape(esc)

    local exec_pat = "()" .. inline_escape .. "(%b" .. brackets .. ")()"

    local esc_pat = esc .. "+([^\n]*\n?)"
    local esc_pat1, esc_pat2 = "^" .. esc_pat, "\n" .. esc_pat
    local pieces, s = {"return function() local __R_size, __R_table, __tostring = 0, {}, __tostring; "}, 1
    while true do
        local _, e, lua = strfind(chunk, esc_pat1, s)
        if not e then
            local ss
            ss, e, lua = strfind(chunk, esc_pat2, s)
            parseDollarParen(pieces, strsub(chunk, s, ss), exec_pat, newline)
            if not e then break end
        end
        if strsub(lua, -1, -1) ~= "\n" then lua = lua .. "\n" end -- Ensure trailing newline
        append(pieces, lua)
        -- since `lua` ends with a newline, there is no danger of subsequent
        -- statements being gobbled up by comments or being altered
        s = e + 1
    end
    append(pieces, "return __R_table; end")

    -- let's check for a special case where there is nothing to template, but it's
    -- just a single static string
    local short = false
    if (#pieces == 3) and (strfind(pieces[2], APPENDER, 1, true) == 1) then
        pieces = { "return " .. strsub(pieces[2], #APPENDER + 1, -1) }
        short = true
    end
    -- if short == true, the generated function will not return a table of strings,
    -- but a single string
    return concat(pieces), short
end

local template = {}

--- expand the template using the specified environment.
-- This function will compile and render the template. For more performant
-- recurring usage use the two step approach by using `compile` and `ct:render`.
-- @string str the template string
-- @tparam[opt] table env the environment. This table has the following special fields:
-- @tparam[opt=nil] table env._parent continue looking up in this table (e.g. `_parent=_G`).
-- @tparam[opt="()"] string env._brackets bracket pair that wraps inline Lua expressions.
-- @tparam[opt="#"] string env._escape character marking Lua lines.
-- @tparam[opt="$"] string env._inline_escape character marking inline Lua expression.
-- @tparam[opt="TMP"] string env._chunk_name chunk name for loaded templates, used if there
-- is an error in Lua code.
-- @tparam[opt=false] boolean env._debug if truthy, the generated code will be printed upon a render error.
-- @treturn[1] string render result
-- @treturn[1] nil
-- @treturn[1] string source_code (only if '`env._debug`' was truthy).
-- @treturn[2] nil
-- @treturn[2] string error message
-- @treturn[2] string source_code (only if '`env._debug`' was truthy).
function template.substitute(str, env)
    env = env or {}
    local t, err = template.compile(str, {
        chunk_name = rawget(env, "_chunk_name"),
        escape = rawget(env, "_escape"),
        inline_escape = rawget(env, "_inline_escape"),
        inline_brackets = rawget(env, "_brackets"),
        newline = false,
        debug = rawget(env, "_debug")
    })
    if not t then return t, err end

    return t:render(env, rawget(env, "_parent"), rawget(env, "_debug"))
end

--- executes the previously compiled template and renders it.
-- @function ct:render
-- @tab[opt] env the environment.
-- @tab[opt] parent continue looking up in this table (e.g. `parent=_G`).
-- @bool[opt] db if thruthy, it will print the code upon a render error
-- (provided the template was compiled with the debug option).
-- @treturn[1] string render result
-- @treturn[1] nil
-- @treturn[1] string source_code (only if '`env._debug`' was truthy).
-- @treturn[2] nil
-- @treturn[2] string error message
-- @treturn[2] string source_code (only if '`env._debug`' was truthy).
-- @usage
-- local ct, err = template.compile(my_template)
-- local rendered , err = ct:render(my_env, parent)
local function render(self, env, parent, db)
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
    return concat(out), nil, self.code
end

--- compiles the template.
-- Returns an object that can repeatedly be rendered without parsing/compiling
-- the template again. Preserves the line layout of the template so that line
-- numbers in error messages should point to the correct lines in the source
-- string.
-- @tparam string str the template string
-- @tparam[opt] table opts the compilation options to use. This table supports the following options:
-- @tparam[opt="TMP"] string opts.chunk_name chunk name for loaded templates, used if there
-- is an error in Lua code.
-- @tparam[opt="#"] string opts.escape character marking Lua lines.
-- @tparam[opt="$"] string opts.inline_escape character marking inline Lua expression.
-- @tparam[opt="()"] string opts.inline_brackets bracket pair that wraps inline Lua expressions.
-- @tparam[opt=false] boolean opts.newline if truthy, newlines will be stripped from text in the template.
-- @tparam[opt=false] boolean opts.debug if truthy, the generated code will be printed upon a render error.
-- @treturn[1] ct compiled template object
-- @treturn[2] nil
-- @treturn[2] string error message
-- @treturn[2] string source_code
-- @usage
-- local ct, err = template.compile(my_template)
-- local rendered , err = ct:render(my_env, parent)
function template.compile(str, opts)
    opts = opts or {}
    local chunk_name = opts.chunk_name or 'TMP'
    local escape = opts.escape or '#'
    local inline_escape = opts.inline_escape or '$'
    local inline_brackets = opts.inline_brackets or '()'

    local code, short = parseHashLines(str, inline_escape, inline_brackets, escape, opts.newline)
    local env = { __tostring = tostring }
    local fn, err = utils.load(code, chunk_name, 't', env)
    if not fn then return nil, err, code end

    if short then
        -- the template returns a single constant string, let's optimize for that
        local constant_string = fn()
        return {
            fn = fn(),
            env = env,
            render = function(self) -- additional params can be ignored
                -- skip the metatable magic and error handling in the render
                -- function above for this special case
                return constant_string, nil, self.code
            end,
            code = opts.debug and code or nil,
        }
    end

    return {
        fn = fn(),
        env = env,
        render = render,
        code = opts.debug and code or nil,
    }
end

return template
