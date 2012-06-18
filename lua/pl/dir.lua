--- Useful functions for getting directory contents and matching them against wildcards.
--
-- Dependencies: `pl.utils`, `pl.path`, `pl.tablex`
--
-- Soft Dependencies: `alien`, `ffi` (either are used on Windows for copying/moving files)
-- @module pl.dir

local utils = require 'pl.utils'
local path = require 'pl.path'
local is_windows = path.is_windows
local tablex = require 'pl.tablex'
local ldir = path.dir
local chdir = path.chdir
local mkdir = path.mkdir
local rmdir = path.rmdir
local sub = string.sub
local os,pcall,ipairs,pairs,require,setmetatable,_G = os,pcall,ipairs,pairs,require,setmetatable,_G
local remove = os.remove
local append = table.insert
local wrap = coroutine.wrap
local yield = coroutine.yield
local assert_arg,assert_string,raise = utils.assert_arg,utils.assert_string,utils.raise
local List = utils.stdmt.List

local dir = {}

local function assert_dir (n,val)
    assert_arg(n,val,'string',path.isdir,'not a directory',4)
end

local function assert_file (n,val)
    assert_arg(n,val,'string',path.isfile,'not a file',4)
end

local function filemask(mask)
    mask = utils.escape(mask)
    return mask:gsub('%%%*','.+'):gsub('%%%?','.')..'$'
end

--- does the filename match the shell pattern?.
-- (cf. fnmatch.fnmatch in Python, 11.8)
-- @param file A file name
-- @param pattern A shell pattern
-- @return true or false
-- @raise file and pattern must be strings
function dir.fnmatch(file,pattern)
    assert_string(1,file)
    assert_string(2,pattern)
    return path.normcase(file):find(filemask(pattern)) ~= nil
end

--- return a list of all files which match the pattern.
-- (cf. fnmatch.filter in Python, 11.8)
-- @param files A table containing file names
-- @param pattern A shell pattern.
-- @return list of files
-- @raise file and pattern must be strings
function dir.filter(files,pattern)
    assert_arg(1,files,'table')
    assert_string(2,pattern)
    local res = {}
    local mask = filemask(pattern)
    for i,f in ipairs(files) do
        if f:find(mask) then append(res,f) end
    end
    return setmetatable(res,List)
end

local function _listfiles(dir,filemode,match)
    local res = {}
    local check = utils.choose(filemode,path.isfile,path.isdir)
    if not dir then dir = '.' end
    for f in ldir(dir) do
        if f ~= '.' and f ~= '..' then
            local p = path.join(dir,f)
            if check(p) and (not match or match(p)) then
                append(res,p)
            end
        end
    end
    return setmetatable(res,List)
end

--- return a list of all files in a directory which match the a shell pattern.
-- @param dir A directory. If not given, all files in current directory are returned.
-- @param mask  A shell pattern. If not given, all files are returned.
-- @return lsit of files
-- @raise dir and mask must be strings
function dir.getfiles(dir,mask)
    assert_dir(1,dir)
    if mask then assert_string(2,mask) end
    local match
    if mask then
        mask = filemask(mask)
        match = function(f)
            return f:find(mask)
        end
    end
    return _listfiles(dir,true,match)
end

--- return a list of all subdirectories of the directory.
-- @param dir A directory
-- @return a list of directories
-- @raise dir must be a string
function dir.getdirectories(dir)
    assert_dir(1,dir)
    return _listfiles(dir,false)
end

local function quote_argument (f)
    f = path.normcase(f)
    if f:find '%s' then
        return '"'..f..'"'
    else
        return f
    end
end


local alien,ffi,ffi_checked,CopyFile,MoveFile,GetLastError,win32_errors,cmd_tmpfile

local function execute_command(cmd,parms)
   if not cmd_tmpfile then cmd_tmpfile = path.tmpname () end
   local err = path.is_windows and ' > ' or ' 2> '
    cmd = cmd..' '..parms..err..cmd_tmpfile
    local ret = utils.execute(cmd)
    if not ret then
        return false,(utils.readfile(cmd_tmpfile):gsub('\n(.*)',''))
    else
        return true
    end
end

local function find_ffi_copyfile ()
    if not ffi_checked then
        ffi_checked = true
        local res
        res,alien = pcall(require,'alien')
        if not res then
            alien = nil
            res, ffi = pcall(require,'ffi')
        end
        if not res then
            ffi = nil
            return
        end
    else
        return
    end
    if alien then
        -- register the Win32 CopyFile and MoveFile functions
        local kernel = alien.load('kernel32.dll')
        CopyFile = kernel.CopyFileA
        CopyFile:types{'string','string','int',ret='int',abi='stdcall'}
        MoveFile = kernel.MoveFileA
        MoveFile:types{'string','string',ret='int',abi='stdcall'}
        GetLastError = kernel.GetLastError
        GetLastError:types{ret ='int', abi='stdcall'}
    elseif ffi then
        ffi.cdef [[
            int CopyFileA(const char *src, const char *dest, int iovr);
            int MoveFileA(const char *src, const char *dest);
            int GetLastError();
        ]]
        CopyFile = ffi.C.CopyFileA
        MoveFile = ffi.C.MoveFileA
        GetLastError = ffi.C.GetLastError
    end
    win32_errors = {
        ERROR_FILE_NOT_FOUND    =         2,
        ERROR_PATH_NOT_FOUND    =         3,
        ERROR_ACCESS_DENIED    =          5,
        ERROR_WRITE_PROTECT    =          19,
        ERROR_BAD_UNIT         =          20,
        ERROR_NOT_READY        =          21,
        ERROR_WRITE_FAULT      =          29,
        ERROR_READ_FAULT       =          30,
        ERROR_SHARING_VIOLATION =         32,
        ERROR_LOCK_VIOLATION    =         33,
        ERROR_HANDLE_DISK_FULL  =         39,
        ERROR_BAD_NETPATH       =         53,
        ERROR_NETWORK_BUSY      =         54,
        ERROR_DEV_NOT_EXIST     =         55,
        ERROR_FILE_EXISTS       =         80,
        ERROR_OPEN_FAILED       =         110,
        ERROR_INVALID_NAME      =         123,
        ERROR_BAD_PATHNAME      =         161,
        ERROR_ALREADY_EXISTS    =         183,
    }
end

local function two_arguments (f1,f2)
    return quote_argument(f1)..' '..quote_argument(f2)
end

local function file_op (is_copy,src,dest,flag)
    if flag == 1 and path.exists(dest) then
        return false,"cannot overwrite destination"
    end
    if is_windows then
        -- if we haven't tried to load Alien/LuaJIT FFI before, then do so
        find_ffi_copyfile()
        -- fallback if there's no Alien, just use DOS commands *shudder*
        -- 'rename' involves a copy and then deleting the source.
        if not CopyFile then
            src = path.normcase(src)
            dest = path.normcase(dest)
            local cmd = is_copy and 'copy' or 'rename'
            local res, err = execute_command('copy',two_arguments(src,dest))
            if not res then return nil,err end
            if not is_copy then
                return execute_command('del',quote_argument(src))
            end
        else
            if path.isdir(dest) then
                dest = path.join(dest,path.basename(src))
            end
			local ret
            if is_copy then ret = CopyFile(src,dest,flag)
            else ret = MoveFile(src,dest) end
            if ret == 0 then
                local err = GetLastError()
                for name,value in pairs(win32_errors) do
                    if value == err then return false,name end
                end
                return false,"Error #"..err
            else return true
            end
        end
    else -- for Unix, just use cp for now
        return execute_command(is_copy and 'cp' or 'mv',
            two_arguments(src,dest))
    end
end

--- copy a file.
-- @param src source file
-- @param dest destination file or directory
-- @param flag true if you want to force the copy (default)
-- @return true if operation succeeded
-- @raise src and dest must be strings
function dir.copyfile (src,dest,flag)
    assert_string(1,src)
    assert_string(2,dest)
    flag = flag==nil or flag
    return file_op(true,src,dest,flag and 0 or 1)
end

--- move a file.
-- @param src source file
-- @param dest destination file or directory
-- @return true if operation succeeded
-- @raise src and dest must be strings
function dir.movefile (src,dest)
    assert_string(1,src)
    assert_string(2,dest)
    return file_op(false,src,dest,0)
end

local function _dirfiles(dir,attrib)
    local dirs = {}
    local files = {}
    for f in ldir(dir) do
        if f ~= '.' and f ~= '..' then
            local p = path.join(dir,f)
            local mode = attrib(p,'mode')
            if mode=='directory' then
                append(dirs,f)
            else
                append(files,f)
            end
        end
    end
    return setmetatable(dirs,List),setmetatable(files,List)
end


local function _walker(root,bottom_up,attrib)
    local dirs,files = _dirfiles(root,attrib)
    if not bottom_up then yield(root,dirs,files) end
    for i,d in ipairs(dirs) do
        _walker(root..path.sep..d,bottom_up,attrib)
    end
    if bottom_up then yield(root,dirs,files) end
end

--- return an iterator which walks through a directory tree starting at root.
-- The iterator returns (root,dirs,files)
-- Note that dirs and files are lists of names (i.e. you must say path.join(root,d)
-- to get the actual full path)
-- If bottom_up is false (or not present), then the entries at the current level are returned
-- before we go deeper. This means that you can modify the returned list of directories before
-- continuing.
-- This is a clone of os.walk from the Python libraries.
-- @param root A starting directory
-- @param bottom_up False if we start listing entries immediately.
-- @param follow_links follow symbolic links
-- @return an iterator returning root,dirs,files
-- @raise root must be a string
function dir.walk(root,bottom_up,follow_links)
    assert_dir(1,root)
    local attrib
    if path.is_windows or not follow_links then
        attrib = path.attrib
    else
        attrib = path.link_attrib
    end
    return wrap(function () _walker(root,bottom_up,attrib) end)
end

--- remove a whole directory tree.
-- @param fullpath A directory path
-- @return true or nil
-- @return error if failed
-- @raise fullpath must be a string
function dir.rmtree(fullpath)
    assert_dir(1,fullpath)
    if path.islink(fullpath) then return false,'will not follow symlink' end
    for root,dirs,files in dir.walk(fullpath,true) do
        for i,f in ipairs(files) do
            remove(path.join(root,f))
        end
        rmdir(root)
    end
    return true
end

local dirpat
if path.is_windows then
    dirpat = '(.+)\\[^\\]+$'
else
    dirpat = '(.+)/[^/]+$'
end

local _makepath
function _makepath(p)
    -- windows root drive case
    if p:find '^%a:[\\]*$' then
        return true
    end
   if not path.isdir(p) then
    local subp = p:match(dirpat)
    if not _makepath(subp) then return raise ('cannot create '..subp) end
    return mkdir(p)
   else
    return true
   end
end

--- create a directory path.
-- This will create subdirectories as necessary!
-- @param p A directory path
-- @return a valid created path
-- @raise p must be a string
function dir.makepath (p)
    assert_string(1,p)
    return _makepath(path.normcase(path.abspath(p)))
end


--- clone a directory tree. Will always try to create a new directory structure
-- if necessary.
-- @param path1 the base path of the source tree
-- @param path2 the new base path for the destination
-- @param file_fun an optional function to apply on all files
-- @param verbose an optional boolean to control the verbosity of the output.
--  It can also be a logging function that behaves like print()
-- @return true, or nil
-- @return error message, or list of failed directory creations
-- @return list of failed file operations
-- @raise path1 and path2 must be strings
-- @usage clonetree('.','../backup',copyfile)
function dir.clonetree (path1,path2,file_fun,verbose)
    assert_string(1,path1)
    assert_string(2,path2)
    if verbose == true then verbose = print end
    local abspath,normcase,isdir,join = path.abspath,path.normcase,path.isdir,path.join
    local faildirs,failfiles = {},{}
    if not isdir(path1) then return raise 'source is not a valid directory' end
    path1 = abspath(normcase(path1))
    path2 = abspath(normcase(path2))
    if verbose then verbose('normalized:',path1,path2) end
    -- particularly NB that the new path isn't fully contained in the old path
    if path1 == path2 then return raise "paths are the same" end
    local i1,i2 = path2:find(path1,1,true)
    if i2 == #path1 and path2:sub(i2+1,i2+1) == path.sep then
        return raise 'destination is a subdirectory of the source'
    end
    local cp = path.common_prefix (path1,path2)
    local idx = #cp
    if idx == 0 then -- no common path, but watch out for Windows paths!
        if path1:sub(2,2) == ':' then idx = 3 end
    end
    for root,dirs,files in dir.walk(path1) do
        local opath = path2..root:sub(idx)
        if verbose then verbose('paths:',opath,root) end
        if not isdir(opath) then
            local ret = dir.makepath(opath)
            if not ret then append(faildirs,opath) end
            if verbose then verbose('creating:',opath,ret) end
        end
        if file_fun then
            for i,f in ipairs(files) do
                local p1 = join(root,f)
                local p2 = join(opath,f)
                local ret = file_fun(p1,p2)
                if not ret then append(failfiles,p2) end
                if verbose then
                    verbose('files:',p1,p2,ret)
                end
            end
        end
    end
    return true,faildirs,failfiles
end

--- return an iterator over all entries in a directory tree
-- @param d a directory
-- @return an iterator giving pathname and mode (true for dir, false otherwise)
-- @raise d must be a non-empty string
function dir.dirtree( d )
    assert( d and d ~= "", "directory parameter is missing or empty" )
    local exists, isdir = path.exists, path.isdir
    local sep = path.sep

    local last = sub ( d, -1 )
    if last == sep or last == '/' then
        d = sub( d, 1, -2 )
    end

    local function yieldtree( dir )
        for entry in ldir( dir ) do
            if entry ~= "." and entry ~= ".." then
                entry = dir .. sep .. entry
                if exists(entry) then  -- Just in case a symlink is broken.
                    local is_dir = isdir(entry)
                    yield( entry, is_dir )
                    if is_dir then
                        yieldtree( entry )
                    end
                end
            end
        end
    end

    return wrap( function() yieldtree( d ) end )
end


---	Recursively returns all the file starting at <i>path</i>. It can optionally take a shell pattern and
--	only returns files that match <i>pattern</i>. If a pattern is given it will do a case insensitive search.
--	@param start_path {string} A directory. If not given, all files in current directory are returned.
--	@param pattern {string} A shell pattern. If not given, all files are returned.
--	@return Table containing all the files found recursively starting at <i>path</i> and filtered by <i>pattern</i>.
--  @raise start_path must be a string
function dir.getallfiles( start_path, pattern )
    assert_dir(1,start_path)
    pattern = pattern or ""

    local files = {}
    local normcase = path.normcase
    for filename, mode in dir.dirtree( start_path ) do
        if not mode then
            local mask = filemask( pattern )
            if normcase(filename):find( mask ) then
                files[#files + 1] = filename
            end
        end
    end

    return files
end

return dir
