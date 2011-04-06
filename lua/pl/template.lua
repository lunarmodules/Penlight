--- A template preprocessor.
-- Originally by Ricki Lake, see
-- There are two rules: <ul>
-- <li>lines starting with # are Lua</li>
-- <li> otherwise, `$(expr)` is the result of evaluating `expr`</li>
-- </ul>
-- (Other escape characters can be used.)
-- @class module
-- @name pl.template

--[[
    module('pl.template')
]]

local append,format = table.insert,string.format

if not loadin then -- Lua 5.2 compatibility
    function loadin(env,str,name)
        local chunk,err = loadstring(str,name)
        if chunk then setfenv(chunk,env) end
        return chunk,err
    end
end

local function parseHashLines(chunk,brackets,esc)
    local exec_pat = "()$(%b"..brackets..")()"
    
    local function parseDollarParen(pieces, chunk, s, e)
        local s = 1
        for term, executed, e in chunk:gmatch (exec_pat) do
            executed = '('..executed:sub(2,-2)..')'
            append(pieces,
              format("%q..(%s or '')..",chunk:sub(s, term - 1), executed))
            s = e
        end
        append(pieces, format("%q", chunk:sub(s)))
    end
    
    local esc_pat = esc.."+([^\n]*\n?)"
    local esc_pat1, esc_pat2 = "^"..esc_pat, "\n"..esc_pat
    local  pieces, s = {"return function(_put) ", n = 1}, 1
    while true do
        local ss, e, lua = chunk:find (esc_pat1, s)
        if not e then
            ss, e, lua = chunk:find(esc_pat2, s)
            append(pieces, "_put(")
            parseDollarParen(pieces, chunk:sub(s, ss))
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
-- @param str the template string
-- @param env the environment (by default empty). <br>
-- There are three special fields in the environment table <ul>
-- <li><code>_parent</code> continue looking up in this table</li>
-- <li><code>_brackets</code>; default is '()', can be any suitable bracket pair</li>
-- <li><code>_escape</code>; default is '#' </li>
-- </ul>
function template.substitute(str,env)
    env = env or {}
    if env._parent then
        setmetatable(env,{__index = env._parent})
    end
    local code = parseHashLines(str,env._brackets or '()',env._escape or '#')    
    local fn,err = loadin(env,code,'TMP')
    if not fn then return nil,err end
    fn = fn()
    local out = {}
    local res,err = pcall(fn,function(s)
        out[#out+1] = s
    end)
    if not res then
        if env._debug then print(code) end
        return nil,err
    end
    return table.concat(out)
end

return template




