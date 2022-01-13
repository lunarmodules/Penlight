local utils = require("pl.utils")

describe("pl.utils", function ()

  describe("kpairs", function ()
    local kpairs

    before_each(function()
      kpairs = utils.kpairs
    end)


    it("iterates over non-integers", function()
      local func = function() end
      local bool = true
      local string = "a string"
      local float = 123.45
      local r = {}
      for k, v in kpairs {
        [func] = 1,
        [bool] = 2,
        [string] = 3,
        [float] = 4,
        5, 6, 7,
      } do
        r[k] = v
      end

      assert.same({
        [func] = 1,
        [bool] = 2,
        [string] = 3,
        [float] = 4 }, r)
    end)

  end)

end)
