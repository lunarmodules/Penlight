--- path manipulation and file queries. <br>
-- This is modelled after Python's os.path library (11.1)
-- @class module
-- @name pl.path

-- imports and locals
local _G = _G
local sub = string.sub
local getenv = os.getenv
local tmpnam = os.tmpname
local attributes
local currentdir
local package = package
local io = io
local append = table.insert
local ipairs = ipairs
local utils = require 'pl.utils'
local assert_arg,assert_string,raise = utils.assert_arg,utils.assert_string,utils.raise
local attributes,currentdir

--[[
module ('pl.path',utils._module)
]]

local path = {}

local res,lfs = _G.pcall(_G.require,'lfs')
if res then
    attributes = lfs.attributes
    currentdir = lfs.currentdir
end

local function at(s,i)
    return sub(s,i,i)
end

local function attrib(path,field)
    assert_string(1,path)
    assert_string(2,field)
    if not attributes then return nil end
    local attr,err = attributes(path)
    if not attr then return raise(err)
    else
        return attr[field]
    end
end

path.is_windows = utils.dir_separator == '\\'

local other_sep
-- !constant sep is the directory separator for this platform.
if path.is_windows then
    path.sep = '\\'; other_sep = '/'
    path.dirsep = ';'
else
    path.sep = '/'
    path.dirsep = ':'
end
local sep,dirsep = path.sep,path.dirsep

--- given a path, return the directory part and a file part.
-- if there's no directory part, the first value will be empty
-- @param P A file path
function path.splitpath(P)
    assert_string(1,P)
    local i = #P
    local ch = at(P,i)
    while i > 0 and ch ~= sep and ch ~= other_sep do
        i = i - 1
        ch = at(P,i)
    end
    if i == 0 then
        return '',P
    else
        return sub(P,1,i-1), sub(P,i+1)
    end
end

--- return an absolute path.
-- @param PP A A file path
function path.abspath(P)
    assert_string(1,P)
    if not currentdir then return P end
    if not path.isabs(P) then
        return join(currentdir(),P)
    else
        return P
    end
end

--- given a path, return the root part and the extension part.
-- if there's no extension part, the second value will be empty
-- @param P A file path
function path.splitext(P)
    assert_string(1,P)
    local i = #P
    local ch = at(P,i)
    while i > 0 and ch ~= '.' do
        if ch == sep or ch == other_sep then
            return P,''
        end
        i = i - 1
        ch = at(P,i)
    end
    if i == 0 then
        return P,''
    else
        return sub(P,1,i-1),sub(P,i)
    end
end

--- return the directory part of a path
-- @param P A file path
function path.dirname(P)
    assert_string(1,P)
    local p1,p2 = path.splitpath(P)
    return p1
end

--- return the file part of a path
-- @param P A file path
function path.basename(P)
    assert_string(1,P)
    local p1,p2 = path.splitpath(P)
    return p2
end

--- get the extension part of a path.
-- @param P A file path
function path.extension(P)
    assert_string(1,P)
    p1,p2 = path.splitext(P)
    return p2
end

--- is this an absolute path?.
-- @param P A file path
function path.isabs(P)
    assert_string(1,P)
    if path.is_windows then
        return at(P,1) == '/' or at(P,1)=='\\' or at(P,2)==':'
    else
        return at(P,1) == '/'
    end
end

--- return the P resulting from combining the two paths.
-- if the second is already an absolute path, then it returns it.
-- @param p1 A file path
-- @param p2 A file path
function path.join(p1,p2)
    assert_string(1,p1)
    assert_string(2,p2)
    if path.isabs(p2) then return p2 end
    local endc = at(p1,#p1)
    if endc ~= path.sep and endc ~= other_sep then
        p1 = p1..path.sep
    end
    return p1..p2
end

--- Normalize the case of a pathname. On Unix, this returns the path unchanged;
--  for Windows, it converts the path to lowercase, and it also converts forward slashes
-- to backward slashes. Will also replace '\dir\..\' by '\' (PL extension!)
-- @param P A file path
function path.normcase(P)
    assert_string(1,P)
    if path.is_windows then
        return (P:lower():gsub('/','\\'):gsub('\\[^\\]+\\%.%.',''))
    else
        return P
    end
end

--- is this a directory?
-- @param P A file path
function path.isdir(P)
    if P:match("\\$") then
        P = P:sub(1,-2)
    end
    return attrib(P,'mode') == 'directory'
end

--- is this a file?.
-- @param P A file path
function path.isfile(P)
	if P:match("\\$") then
        P = P:sub(1,-2)
    end
    return attrib(P,'mode') == 'file'
end

--- return size of a file.
-- @param P A file path
function path.getsize(P)
    return attrib(P,'size')
end

--- does a path exist?.
-- @param P A file path
-- @return the file path if it exists, nil otherwise
function path.exists(P)
    if attributes then
        return attributes(P) ~= nil and P
    else
        local f = io.open(P,'r')
        if f then
            f:close()
            return P
        else
            return false
        end
    end
end

--- Replace a starting '~' with the user's home directory.
-- In windows, if HOME isn't set, then USERPROFILE is used in preference to
-- HOMEDRIVE HOMEPATH. This is guaranteed to be writeable on all versions of Windows.
-- @param P A file path
function path.expanduser(P)
    assert_string(1,P)
    if at(P,1) == '~' then
        local home = getenv('HOME')
        if not home then -- has to be Windows
            home = getenv 'USERPROFILE' or (getenv 'HOMEDRIVE' .. getenv 'HOMEPATH')
        end
        return home..sub(P,2)
    else
        return P
    end
end

--- Return the time of last access as the number of seconds since the epoch.
-- @param P A file path
function path.getatime(P)
    return attrib(P,'access')
end

--- Return the time of last modification
-- @param P A file path
function path.getmtime(P)
    return attrib(P,'modification')
end

---Return the system's ctime.
-- @param P A file path
function path.getctime(P)
    return path.attrib(P,'change')
end

---Return a suitable full path to a new temporary file name.
-- unlike os.tmpnam(), it always gives you a writeable path (uses %TMP% on Windows)
function path.tmpname ()
    local res = tmpnam()
    if is_windows then res = getenv('TMP')..res end
    return res
end

--- return the largest common prefix path of two paths.
-- @param path1 a file path
-- @param path2 a file path
function path.common_prefix (path1,path2)
    assert_string(1,path1)
    assert_string(2,path2)
    -- get them in order!
    if #path1 > #path2 then path2,path1 = path1,path2 end
    for i = 1,#path1 do
        local c1 = at(path1,i)
        if c1 ~= at(path2,i) then
            local cp = path1:sub(1,i-1)
            if at(path1,i-1) ~= sep then
                cp = path.dirname(cp)
            end
            return cp
        end
    end
    if at(path2,#path1+1) ~= sep then path1 = path.dirname(path1) end
    return path1
    --return ''
end

if not package.searchpath then
    function package.searchpath (mod,path)
        mod = mod:gsub('%.',sep)
        for m in path:gmatch('[^;]+') do
            local nm = m:gsub('?',mod)
            local f = io.open(nm,'r')
            if f then f:close(); return nm end
        end
    end
end

--- return the full path where a particular Lua module would be found.
-- Both package.path and package.cpath is searched, so the result may
-- either be a Lua file or a shared libarary.
-- @param mod name of the module
-- @return on success: path of module, lua or binary
-- @return on error: nil,error string
function path.package_path(mod)
    assert_string(1,mod)
    local res
    mod = mod:gsub('%.',sep)
    res = package.searchpath(mod,package.path)
    if res then return res,true end
    res = package.searchpath(mod,package.cpath)
    if res then return res,false end
    return raise 'cannot find module on path'
end

---- finis -----
return path
