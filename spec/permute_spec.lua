local permute = require("pl.permute")
local tcopy = require("pl.tablex").copy
local utils = require("pl.utils")

describe("pl.permute", function()

  describe("order_iter", function()

    it("returns all order combinations", function()
      local result = {}
      for list in permute.order_iter({"one", "two", "three"}) do
        result[#result+1] = tcopy(list)
      end
      assert.same({
        [1] = {
           [1] = 'two',
           [2] = 'three',
           [3] = 'one' },
         [2] = {
           [1] = 'three',
           [2] = 'two',
           [3] = 'one' },
         [3] = {
           [1] = 'three',
           [2] = 'one',
           [3] = 'two' },
         [4] = {
           [1] = 'one',
           [2] = 'three',
           [3] = 'two' },
         [5] = {
           [1] = 'two',
           [2] = 'one',
           [3] = 'three' },
         [6] = {
           [1] = 'one',
           [2] = 'two',
           [3] = 'three' } }, result)
    end)


    it("returns nil on empty list", function()
      local result = {}
      for list in permute.order_iter({}) do
        result[#result+1] = tcopy(list)
      end
      assert.equal(0, #result)
    end)

  end)



  describe("order_table", function()

    it("returns all order combinations", function()
      local result = permute.order_table({"one", "two", "three"})
      assert.same({
        [1] = {
           [1] = 'two',
           [2] = 'three',
           [3] = 'one' },
         [2] = {
           [1] = 'three',
           [2] = 'two',
           [3] = 'one' },
         [3] = {
           [1] = 'three',
           [2] = 'one',
           [3] = 'two' },
         [4] = {
           [1] = 'one',
           [2] = 'three',
           [3] = 'two' },
         [5] = {
           [1] = 'two',
           [2] = 'one',
           [3] = 'three' },
         [6] = {
           [1] = 'one',
           [2] = 'two',
           [3] = 'three' } }, result)
    end)


    it("returns empty table on empty input list", function()
      local result = permute.order_table({})
      assert.same({}, result)
    end)

  end)



  describe("list_iter", function()

    it("returns all combinations from sub-lists", function()
      local result = {}
      local strs = {"one", "two", "three"}
      local ints = { 1,2,3 }
      local bools = { true, false }
      for count, str, int, bool in permute.list_iter(strs, ints, bools) do
        result[#result+1] = {count, str, int, bool}
      end
      assert.same({
        [1] = {1, 'one', 1, true },
        [2] = {2, 'two', 1, true },
        [3] = {3, 'three', 1, true },
        [4] = {4, 'one', 2, true },
        [5] = {5, 'two', 2, true },
        [6] = {6, 'three', 2, true },
        [7] = {7, 'one', 3, true },
        [8] = {8, 'two', 3, true },
        [9] = {9, 'three', 3, true },
        [10] = {10, 'one', 1, false },
        [11] = {11, 'two', 1, false },
        [12] = {12, 'three', 1, false },
        [13] = {13, 'one', 2, false },
        [14] = {14, 'two', 2, false },
        [15] = {15, 'three', 2, false },
        [16] = {16, 'one', 3, false },
        [17] = {17, 'two', 3, false },
        [18] = {18, 'three', 3, false },
      }, result)
    end)


    it("is nil-safe, given 'n' is set", function()
      local result = {}
      local bools = utils.pack(nil, true, false)
      local strs = utils.pack("one", "two", nil)
      for count, bool, str in permute.list_iter(bools, strs) do
        result[#result+1] = {count, bool, str}
      end
      assert.same({
        [1] = {1, nil, 'one' },
        [2] = {2, true, 'one' },
        [3] = {3, false, 'one' },
        [4] = {4, nil, 'two' },
        [5] = {5, true, 'two' },
        [6] = {6, false, 'two' },
        [7] = {7, nil, nil },
        [8] = {8, true, nil },
        [9] = {9, false, nil },
      }, result)
    end)


    it("returns nil on empty list", function()
      local count = 0
      for list in permute.list_iter({}) do
        count = count + 1
      end
      assert.equal(0, count)
    end)

  end)



  describe("list_table", function()

    it("returns all combinations from sub-lists", function()
      local strs = {"one", "two", "three"}
      local ints = { 1,2,3 }
      local bools = { true, false }
      assert.same({
        [1] = {'one', 1, true, n = 3 },
        [2] = {'two', 1, true, n = 3 },
        [3] = {'three', 1, true, n = 3 },
        [4] = {'one', 2, true, n = 3 },
        [5] = {'two', 2, true, n = 3 },
        [6] = {'three', 2, true, n = 3 },
        [7] = {'one', 3, true, n = 3 },
        [8] = {'two', 3, true, n = 3 },
        [9] = {'three', 3, true, n = 3 },
        [10] = {'one', 1, false, n = 3 },
        [11] = {'two', 1, false, n = 3 },
        [12] = {'three', 1, false, n = 3 },
        [13] = {'one', 2, false, n = 3 },
        [14] = {'two', 2, false, n = 3 },
        [15] = {'three', 2, false, n = 3 },
        [16] = {'one', 3, false, n = 3 },
        [17] = {'two', 3, false, n = 3 },
        [18] = {'three', 3, false, n = 3 },
      }, permute.list_table(strs, ints, bools))
    end)


    it("is nil-safe, given 'n' is set", function()
      local bools = utils.pack(nil, true, false)
      local strs = utils.pack("one", "two", nil)
      assert.same({
        [1] = {nil, 'one', n = 2 },
        [2] = {true, 'one', n = 2 },
        [3] = {false, 'one', n = 2 },
        [4] = {nil, 'two', n = 2 },
        [5] = {true, 'two', n = 2 },
        [6] = {false, 'two', n = 2 },
        [7] = {nil, nil, n = 2 },
        [8] = {true, nil, n = 2 },
        [9] = {false, nil, n = 2 },
      }, permute.list_table(bools, strs))
    end)


    it("returns nil on empty list", function()
      assert.same({}, permute.list_table({}))
    end)

  end)

end)
