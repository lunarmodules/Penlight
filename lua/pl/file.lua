-------------------------------------------------------------------
-- File Operations: copy,move,reading,writing

local os = os
local utils = require 'pl.utils'
local dir = require 'pl.dir'
local path = require 'pl.path'
module ('pl.file',utils._module)

--- return the contents of a file as a string
-- @class function
-- @name read
-- @param filename The file path
-- @return file contents
read = utils.readfile

--- write a string to a file
-- @class function
-- @name write
-- @param filename The file path
-- @param str The string
write = utils.writefile

--- copy a file.
-- @class function
-- @name copy
-- @param src source file
-- @param dest destination file
-- @param flag true if you want to force the copy (default)
-- @return true if operation succeeded
copy = dir.copyfile

--- move a file.
-- @class function
-- @name move
-- @param src source file
-- @param dest destination file
-- @return true if operation succeeded
move = dir.movefile

--- Return the time of last access as the number of seconds since the epoch.
-- @class function
-- @name access_time
-- @param path A file path
access_time = path.getatime

---Return when the file was created.
-- @class function
-- @name creation_time
-- @param path A file path
creation_time = path.getctime

--- Return the time of last modification
-- @class function
-- @name modified_time
-- @param path A file path
modified_time = path.getmtime

--- Delete a file
-- @class function
-- @name delete
-- @param path A file path
delete = os.remove

