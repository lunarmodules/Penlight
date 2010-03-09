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

module ('pl.path',utils._module)

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

is_windows = utils.dir_separator == '\\'

local other_sep
-- !constant sep is the directory separator for this platform.
if is_windows then
    sep = '\\'; other_sep = '/'
    dirsep = ';'
else
    sep = '/'
    dirsep = ':'
end

--- given a path, return the directory part and a file part.
-- if there's no directory part, the first value will be empty
-- @param path A file path
function splitpath(path)
    assert_string(1,path)
    local i = #path
    local ch = at(path,i)
    while i > 0 and ch ~= sep and ch ~= other_sep do
        i = i - 1
        ch = at(path,i)
    end
    if i == 0 then
        return '',path
    else
        return sub(path,1,i-1), sub(path,i+1)
    end
end

--- return an absolute path.
-- @param path A file path
function abspath(path)
    assert_string(1,path)
    if not currentdir then return path end
    if not isabs(path) then
        return join(currentdir(),path)
    else
        return path
    end
end

--- given a path, return the root part and the extension part.
-- if there's no extension part, the second value will be empty
-- @param path A file path
function splitext(path)
    assert_string(1,path)
    local i = #path
    local ch = at(path,i)
    while i > 0 and ch ~= '.' do
        if ch == sep or ch == other_sep then
            return path,''
        end
        i = i - 1
        ch = at(path,i)
    end
    if i == 0 then
        return path,''
    else
        return sub(path,1,i-1),sub(path,i)
    end
end

--- return the directory part of a path
-- @param path A file path
function dirname(path)
    assert_string(1,path)
    local p1,p2 = splitpath(path)
    return p1
end

--- return the file part of a path
-- @param path A file path
function basename(path)
    assert_string(1,path)
    local p1,p2 = splitpath(path)
    return p2
end

--- get the extension part of a path.
-- @param path A file path
function extension(path)
    assert_string(1,path)
    p1,p2 = splitext(path)
    return p2
end

--- is this an absolute path?.
-- @param path A file path
function isabs(path)
    assert_string(1,path)
    if is_windows then
        return at(path,1) == '/' or at(path,1)=='\\' or at(path,2)==':'
    else
        return at(path,1) == '/'
    end
end

--- return the path resulting from combining the two paths.
-- if the second is already an absolute path, then it returns it.
-- @param p1 A file path
-- @param p2 A file path
function join(p1,p2)
    assert_string(1,p1)
    assert_string(2,p2)
    if isabs(p2) then return p2 end
    local endc = at(p1,#p1)
    if endc ~= sep and endc ~= other_sep then
        p1 = p1..sep
    end
    return p1..p2
end

--- Normalize the case of a pathname. On Unix, this returns the path unchanged;
--  for Windows, it converts the path to lowercase, and it also converts forward slashes
-- to backward slashes. Will also replace '\dir\..\' by '\' (PL extension!)
-- @param path A file path
function normcase(path)
    assert_string(1,path)
    if is_windows then
        return (path:lower():gsub('/','\\'):gsub('\\[^\\]+\\%.%.',''))
    else
        return path
    end
end

--- is this a directory?
-- @param path A file path
function isdir(path)
    return attrib(path,'mode') == 'directory'
end

--- is this a file?.
-- @param path A file path
function isfile(path)
    return attrib(path,'mode') == 'file'
end

--- return size of a file.
-- @param path A file path
function getsize(path)
    return attrib(path,'size')
end

--- does a path exist?.
-- @param path A file path
function exists(path)
    if attributes then
        return attributes(path) ~= nil
    else
        local f = io.open(path,'r')
        if f then
            f:close()
            return true
        else
            return false
        end
    end
end

--- Replace a starting '~' with the user's home directory.
-- In windows, if HOME isn't set, then USERPROFILE is used in preference to
-- HOMEDRIVE HOMEPATH. This is guaranteed to be writeable on all versions of Windows.
-- @param path A file path
function expanduser(path)
    assert_string(1,path)
    if at(path,1) == '~' then
        local home = getenv('HOME')
        if not home then -- has to be Windows
            home = getenv 'USERPROFILE' or (getenv 'HOMEDRIVE' .. getenv 'HOMEPATH')
        end
        return home..sub(path,2)
    else
        return path
    end
end

--- Return the time of last access as the number of seconds since the epoch.
-- @param path A file path
function getatime(path)
    return attrib(path,'access')
end

--- Return the time of last modification
-- @param path A file path
function getmtime(path)
    return attrib(path,'modification')
end

---Return the system's ctime.
-- @param path A file path
function getctime(path)
    return attrib(path,'change')
end

---Return a suitable full path to a new temporary file name.
-- unlike os.tmpnam(), it always gives you a writeable path (uses %TMP% on Windows)
function tmpname ()
    local res = tmpnam()
    if is_windows then res = getenv('TMP')..res end
    return res
end

--- return the largest common prefix path of two paths.
-- @param path1 a file path
-- @param path2 a file path
function common_prefix (path1,path2)
    assert_string(1,path1)
    assert_string(2,path2)
    -- get them in order!
    if #path1 > #path2 then path2,path1 = path1,path2 end
    for i = 1,#path1 do
        local c1 = at(path1,i)
        if c1 ~= at(path2,i) then
            local cp = path1:sub(1,i-1)
            if at(path1,i-1) ~= sep then
                cp = dirname(cp)
            end
            return cp
        end
    end
    if at(path2,#path1+1) ~= sep then path1 = dirname(path1) end
    return path1
    --return ''
end



--- return the full path where a particular Lua module would be found.
-- Both package.path and package.cpath is searched, so the result may
-- either be a Lua file or a shared libarary.
-- @param mod name of the module
-- @return on success: path of module, lua or binary
-- @return on error: nil,error string
function package_path(mod)
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
