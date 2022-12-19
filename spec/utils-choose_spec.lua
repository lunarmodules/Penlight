local utils = require("pl.utils")

describe("pl.utils", function()

  describe("choose", function ()

    it("handles normal values", function()
      assert.equal(utils.choose(true, 1, 2), 1)
      assert.equal(utils.choose(false, 1, 2), 2)
    end)

    it("handles nils", function()
      assert.equal(utils.choose(true, nil, 2), nil)
      assert.equal(utils.choose(false, nil, 2), 2)
      assert.equal(utils.choose(true, 1, nil), 1)
      assert.equal(utils.choose(false, 1, nil), nil)
    end)

  end)

end)
