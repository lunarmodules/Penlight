--- Permutation operations.
--
-- Dependencies: `pl.utils`, `pl.tablex`
-- @module pl.permute
local tablex = require 'pl.tablex'
local utils = require 'pl.utils'
local copy = tablex.deepcopy
local append = table.insert
local assert_arg = utils.assert_arg


local permute = {}


--- an iterator over all permutations of the elements of a list.
-- Please note that the same list is returned each time, so do not keep references!
-- @param a list-like table
-- @return an iterator which provides the next permutation as a list
function permute.iter(a)
    assert_arg(1,a,'table')

    local t = #a
    local stack = { 1 }
    local function iter()
        local h = #stack
        local n = t - h + 1

        local i = stack[h]
        if i > t then
            return
        end

        if n == 0 then
            table.remove(stack)
            h = h - 1

            stack[h] = stack[h] + 1
            return a

        elseif i <= n then

            -- put i-th element as the last one
            a[n], a[i] = a[i], a[n]

            -- generate all permutations of the other elements
            table.insert(stack, 1)

        else

            table.remove(stack)
            h = h - 1

            n = n + 1
            i = stack[h]

            -- restore i-th element
            a[n], a[i] = a[i], a[n]

            stack[h] = stack[h] + 1
        end
        return iter() -- tail-call
    end

    return iter
end


--- construct a table containing all the permutations of a list.
-- @param a list-like table
-- @return a table of tables
-- @usage permute.table {1,2,3} --> {{2,3,1},{3,2,1},{3,1,2},{1,3,2},{2,1,3},{1,2,3}}
function permute.table (a)
    assert_arg(1,a,'table')
    local res = {}
    for t in permute.iter(a) do
        append(res,copy(t))
    end
    return res
end

return permute
