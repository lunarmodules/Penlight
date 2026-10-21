-- This test file expects to be ran from 'run.lua' in the root Penlight directory.

local dir = require( "pl.dir" )
local file = require( "pl.file" )
local path = require( "pl.path" )
local asserteq = require( "pl.test" ).asserteq
local lfs = require("lfs")

asserteq(dir.fnmatch("foobar", "foo*bar"), true)
asserteq(dir.fnmatch("afoobar", "foo*bar"), false)
asserteq(dir.fnmatch("foobars", "foo*bar"), false)
asserteq(dir.fnmatch("foonbar", "foo*bar"), true)
asserteq(dir.fnmatch("foo'n'bar", "foo*bar"), true)
asserteq(dir.fnmatch("foonbar", "foo?bar"), true)
asserteq(dir.fnmatch("foo'n'bar", "foo?bar"), false)
asserteq(dir.fnmatch("foo", "FOO"), path.is_windows)
asserteq(dir.fnmatch("FOO", "foo"), path.is_windows)

local filtered = dir.filter({"foobar", "afoobar", "foobars", "foonbar"}, "foo*bar")
asserteq(filtered, {"foobar", "foonbar"})

local normpath = path.normpath

local doc_files = dir.getfiles(normpath "docs/", "*.css")
asserteq(doc_files, {normpath "docs/ldoc_fixed.css"})

local all_doc_files = dir.getallfiles(normpath "docs/", "*.css")
asserteq(all_doc_files, {normpath "docs/ldoc_fixed.css"})

local test_samples = dir.getallfiles(normpath "tests/lua")
table.sort(test_samples)
asserteq(test_samples, {
    normpath "tests/lua/animal.lua",
    normpath "tests/lua/bar.lua",
    normpath "tests/lua/foo/args.lua",
    normpath "tests/lua/mod52.lua",
    normpath "tests/lua/mymod.lua"
})

-- Test move files -----------------------------------------

-- Create a dummy file
local fileName = path.tmpname() .. "Xx"
file.write( fileName, string.rep( "poot ", 1000 ) )

local newFileName = path.tmpname() .. "Xx"
local err, msg = dir.movefile( fileName, newFileName )

-- Make sure the move is successful
assert( err, msg )

-- Check to make sure the original file is gone
asserteq( path.exists( fileName ), false )

-- Check to make sure the new file is there
asserteq( path.exists( newFileName ) , newFileName )

-- Test existence again, but explicitly check for correct casing
local files = dir.getfiles(path.dirname(newFileName))
local found = false
for i, filename in ipairs(files) do
  if filename == newFileName then
    found = true
    break
  end
end
assert(found, "file was not found in directory, check casing: " .. newFileName)


-- Try to move the original file again (which should fail)
local newFileName2 = path.tmpname()
local err, msg = dir.movefile( fileName, newFileName2 )
asserteq( err, false )

-- Clean up
file.delete( newFileName )


-- Test copy files -----------------------------------------

-- Create a dummy file
local fileName = path.tmpname()
file.write( fileName, string.rep( "poot ", 1000 ) )

local newFileName = path.tmpname() .. "xX"
local err, msg = dir.copyfile( fileName, newFileName )

-- Make sure the move is successful
assert( err, msg )

-- Check to make sure the new file is there
asserteq( path.exists( newFileName ) , newFileName )

-- Test existence again, but explicitly check for correct casing
local files = dir.getfiles(path.dirname(newFileName))
local found = false
for i, filename in ipairs(files) do
  if filename == newFileName then
    found = true
    break
  end
end
assert(found, "file was not found in directory, check casing: " .. newFileName)


-- Try to move a non-existant file (which should fail)
local fileName2 = 'blub'
local newFileName2 = 'snortsh'
local err, msg = dir.copyfile( fileName2, newFileName2 )
asserteq( err, false )

-- Clean up the files
file.delete( fileName )
file.delete( newFileName )



-- Test make directory -----------------------------------------

-- Create a dummy file
local dirName = path.tmpname() .. "xX"
local fullPath = dirName .. "/and/one/more"
if path.is_windows then
    fullPath = fullPath:gsub("/", "\\")
end
local err, msg = dir.makepath(fullPath)

-- Make sure the move is successful
assert( err, msg )

-- Check to make sure the new file is there
assert(path.isdir(dirName))
assert(path.isdir(fullPath))

-- Test existence again, but explicitly check for correct casing
local files = dir.getdirectories(path.dirname(path.tmpname()))
local found = false
for i, filename in ipairs(files) do
  if filename == dirName then
    found = true
    break
  end
end
assert(found, "dir was not found in directory, check casing: " .. newFileName)


-- Try to move a non-existant file (which should fail)
local fileName2 = 'blub'
local newFileName2 = 'snortsh'
local err, msg = dir.copyfile( fileName2, newFileName2 )
asserteq( err, false )

-- Clean up the files
file.delete( fileName )
file.delete( newFileName )




-- Test rmtree -----------------------------------------
do
  local dirName = path.tmpname()
  os.remove(dirName)
  assert(dir.makepath(dirName))
  assert(file.write(path.normpath(dirName .. "/file_base.txt"), "hello world"))
  assert(dir.makepath(path.normpath(dirName .. "/sub1")))
  assert(file.write(path.normpath(dirName .. "/sub1/file_sub1.txt"), "hello world"))
  assert(dir.makepath(path.normpath(dirName .. "/sub2")))
  assert(file.write(path.normpath(dirName .. "/sub2/file_sub2.txt"), "hello world"))


  local linkTarget = path.tmpname()
  os.remove(linkTarget)
  assert(dir.makepath(linkTarget))
  local linkFile = path.normpath(linkTarget .. "/file.txt")
  assert(file.write(linkFile, "hello world"))

  local linkSource = path.normpath(dirName .. "/link1")
  assert(lfs.link(linkTarget, linkSource, true))

  -- test: rmtree will not follow symlinks
  local ok, err = dir.rmtree(linkSource)
  asserteq(ok, false)
  asserteq(err, "will not follow symlink")

  -- test: rmtree removes a tree without following symlinks in that tree
  local ok, err = dir.rmtree(dirName)
  asserteq(err, nil)
  asserteq(ok, true)

  asserteq(path.exists(dirName), false)  -- tree is gone, including symlink
  assert(path.exists(linkFile), "expected linked-to file to still exist")  -- symlink target file is still there

  -- cleanup
  assert(dir.rmtree(linkTarget))
end


-- test: rmtree does not delete subdirectories inside a symlink target
do
  local dirName = path.tmpname()
  os.remove(dirName)
  assert(dir.makepath(dirName))

  local linkTarget = path.tmpname()
  os.remove(linkTarget)
  assert(dir.makepath(linkTarget))
  local targetFile = path.normpath(linkTarget .. "/top_file.txt")
  assert(file.write(targetFile, "hello world"))
  local targetSubDir = path.normpath(linkTarget .. "/subdir")
  assert(dir.makepath(targetSubDir))
  local targetSubFile = path.normpath(targetSubDir .. "/sub_file.txt")
  assert(file.write(targetSubFile, "hello world"))

  local linkSource = path.normpath(dirName .. "/link1")
  assert(lfs.link(linkTarget, linkSource, true))

  local ok, err = dir.rmtree(dirName)
  asserteq(ok, true)
  asserteq(err, nil)

  assert(path.exists(targetFile), "expected linked-to top file to still exist")
  assert(path.exists(targetSubDir), "expected linked-to subdir to still exist")
  assert(path.exists(targetSubFile), "expected linked-to subdir file to still exist")

  assert(dir.rmtree(linkTarget))
end


-- dirtree must not loop on a symlink pointing at an ancestor,
-- but must still descend into symlinks that point elsewhere
do
  local dirName = path.tmpname()
  os.remove(dirName)
  local other = path.tmpname()
  os.remove(other)
  assert(dir.makepath(path.normpath(dirName .. "/sub")))
  assert(dir.makepath(other))
  assert(file.write(path.normpath(dirName .. "/top.txt"), "hello world"))
  assert(file.write(path.normpath(other .. "/inside.txt"), "hello world"))
  assert(lfs.link(dirName, path.normpath(dirName .. "/sub/loop"), true))
  assert(lfs.link(other, path.normpath(dirName .. "/elsewhere"), true))

  local seen, count = {}, 0
  for entry in dir.dirtree(dirName) do
    count = count + 1
    assert(count <= 20, "dir.dirtree did not terminate; it followed a symlink cycle")
    seen[entry] = true
  end

  -- the cycle is cut: the ancestor link is reported but not descended into
  assert(seen[path.normpath(dirName .. "/sub/loop")], "the ancestor symlink should still be listed")
  assert(not seen[path.normpath(dirName .. "/sub/loop/sub")], "dirtree descended into the cycle")

  -- a symlink that is not an ancestor is still traversed
  assert(seen[path.normpath(dirName .. "/elsewhere/inside.txt")],
    "dirtree stopped descending into a symlink that points outside the tree")

  assert(dir.rmtree(dirName))
  assert(dir.rmtree(other))
end


-- have NO idea why forcing the return code is necessary here (Windows 7 64-bit)
os.exit(0)

