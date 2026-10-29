-- Run from the repository root, directly or through run.lua.
local path = require 'pl.path'
local file = require 'pl.file'
local asserteq = require 'pl.test'.asserteq
local original_dir = path.dir
local loaded_dir = package.loaded['pl.dir']
local denied = {}
local listings = {}
local iterator_error = {}

-- Install before pl.dir captures path.dir in its local ldir alias.
path.dir = function(d)
    if denied[d] then
        error('cannot open ' .. d .. ': Permission denied', 0)
    end
    if iterator_error[d] then
        return function() error(iterator_error[d], 0) end
    end
    if listings[d] then
        local i = 0
        return function()
            i = i + 1
            return listings[d][i]
        end
    end
    return original_dir(d)
end
package.loaded['pl.dir'] = nil
local dir = require 'pl.dir'
path.dir = original_dir
package.loaded['pl.dir'] = loaded_dir

local temporary = path.tmpname()
file.delete(temporary)
local root = temporary .. '-dirtree'
local blocked = path.join(root, 'blocked')
local branch = path.join(root, 'branch')
local deep = path.join(branch, 'blocked')
local sibling = path.join(root, 'sibling')
local topfile = path.join(root, 'top.txt')
local nestedfile = path.join(branch, 'nested.txt')
local siblingfile = path.join(sibling, 'last.txt')
local otherfile = path.join(sibling, 'other.lua')
assert(dir.makepath(blocked))
assert(dir.makepath(deep))
assert(dir.makepath(sibling))
assert(file.write(topfile, 'top'))
assert(file.write(nestedfile, 'nested'))
assert(file.write(siblingfile, 'sibling'))
assert(file.write(otherfile, 'other'))

-- Fixed order verifies that traversal resumes after failures at two depths.
listings[root] = {'.', '..', 'blocked', 'branch', 'sibling', 'top.txt'}
listings[branch] = {'.', '..', 'blocked', 'nested.txt'}
listings[sibling] = {'.', '..', 'last.txt', 'other.lua'}
denied[blocked], denied[deep] = true, true

local function entries(d)
    local result = {}
    for entry, mode in dir.dirtree(d) do
        result[#result + 1] = {entry, mode}
    end
    return result
end

local ok, err = pcall(function()
    asserteq(entries(root), {
        {blocked, true}, {branch, true}, {deep, true}, {nestedfile, false},
        {sibling, true}, {siblingfile, false}, {otherfile, false}, {topfile, false},
    })
    asserteq(dir.getallfiles(root), {nestedfile, siblingfile, otherfile, topfile})
    asserteq(dir.getallfiles(root, '*.txt'), {nestedfile, siblingfile, topfile})
    asserteq(dir.getallfiles(root, '*.lua'), {otherfile})
    assert(getmetatable(dir.getallfiles(root)) == require 'pl.List')

    denied[root] = true
    asserteq(entries(root), {})
    asserteq(entries(root .. path.sep), {})
    asserteq(dir.getallfiles(root), {})
    assert(getmetatable(dir.getallfiles(root)) == require 'pl.List')
    denied[root] = nil

    -- Only opening a directory is protected; iterator/programmer errors escape.
    local sentinel = {}
    iterator_error[branch] = sentinel
    local success, message = pcall(entries, root)
    asserteq(success, false)
    assert(message == sentinel)
    success, message = pcall(dir.getallfiles, root)
    asserteq(success, false)
    assert(message == sentinel)
    iterator_error[branch] = nil

    denied[blocked] = nil
    listings[blocked] = {}
    asserteq(entries(blocked), {})
    asserteq(dir.getallfiles(blocked), {})

    asserteq(pcall(dir.dirtree, ''), false)
    asserteq(pcall(dir.dirtree), false)
    asserteq(pcall(dir.dirtree, {}), false)
    asserteq(pcall(dir.getallfiles, topfile), false)
    asserteq(pcall(dir.getallfiles, root .. '-missing'), false)
    asserteq(pcall(dir.getallfiles, root, {}), false)
end)

-- Cleanup uses the real pl.dir and never changes permissions.
assert(require('pl.dir').rmtree(root))
assert(ok, err)
