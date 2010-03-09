------------------------------------------
--- reading and writing strings using Lua IO
local tmpname = require('pl.path').tmpname
local getmetatable,fopen,remove = getmetatable,io.open,os.remove
local utils = require 'pl.utils'
local assert_arg = utils.assert_arg

module ('pl.stringio',utils._module)

local files = {}

local function value(fi)
    fi:close()
    local file = files[fi]
    files[fi] = nil
    fi = fopen(file,'r')
    local s = fi:read('*a')
    fi:close()
    remove(file)
    return s
end

--- create a file object which can be used to construct a string.
-- The resulting file object will have an extra value() method for
-- retrieving the string value.
--  @usage f = create(); f:write('hello, dolly\n'); print(f:value())
function create()
    local file = tmpname()
    local f = fopen(file,'w')
    files[f] = file
    getmetatable(f).value = value
    return f
end

--- create a file object for reading from a given string.
-- @param s The input string.
function open(s)
    assert_arg(1,s,'string')
    local file = tmpname()
    local f = fopen(file,'w')
    f:write(s)
    f:close()
    files[f] = file
    return fopen(file,'r')
end

function cleanup ()
    for _,file in pairs(files) do
        remove(file)
    end
end

