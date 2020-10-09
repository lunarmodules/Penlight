local permute = require("pl.permute")
local tcopy = require("pl.tablex").copy

describe("pl.permute", function()

  describe("iter", function()

    it("returns all order combinations", function()
      local result = {}
      for list in permute.iter({"one", "two", "three"}) do
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
      for list in permute.iter({}) do
        result[#result+1] = tcopy(list)
      end
      assert.equal(0, #result)
    end)

  end)



  describe("table", function()

    it("returns all order combinations", function()
      local result = permute.table({"one", "two", "three"})
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
      local result = permute.table({})
      assert.same({}, result)
    end)

  end)

end)
