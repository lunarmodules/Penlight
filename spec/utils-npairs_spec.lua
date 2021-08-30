local utils = require("pl.utils")

describe("pl.utils", function ()

  describe("npairs", function ()
    local npairs = utils.npairs

    it("start index defaults to 1", function()
      local t1 = { 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1, nil, 2) do t2[i] = v end
      assert.are.same({ 1, 2 }, t2)
    end)


    it("end index defaults to `t.n`", function()
      local t1 = { n = 2, 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1) do t2[i] = v end
      assert.are.same({1, 2}, t2)
    end)


    it("step size defaults to 1", function()
      local t1 = { 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1) do t2[i] = v end
      assert.are.same({1, 2, 3}, t2)
    end)


    it("step size cannot be 0", function()
      local t1 = { 1, 2, 3 }
      assert.has.error(function()
        npairs(t1, nil, nil, 0)
      end, "iterator step-size cannot be 0")
    end)


    it("end index defaults to `#t` if there is no `t.n`", function()
      local t1 = { 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1) do t2[i] = v end
      assert.are.same({1, 2, 3}, t2)
    end)


    it("returns nothing if start index is beyond end index", function()
      local t1 = { 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1, 5, 3) do t2[i] = v end
      assert.are.same({}, t2)
    end)


    it("returns nothing if start index is beyond end index, with negative step size", function()
      local t1 = { 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1, 3, 1, -1) do t2[#t2+1] = v end
      assert.are.same({ 3, 2, 1}, t2)
    end)


    it("returns 1 key/value if end == start index", function()
      local t1 = { 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1, 2, 2) do t2[i] = v end
      assert.are.same({ [2] = 2 }, t2)
    end)


    it("returns negative to positive ranges", function()
      local t1 = { [-5] = -5, [-4] = -4, [-3] = -3, [-2] = -2, [-1] = -1, [0] = 0, 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1, -4, 1) do t2[i] = v end
      assert.are.same({ [-4] = -4, [-3] = -3, [-2] = -2, [-1] = -1, [0] = 0, 1 }, t2)
    end)


    it("returns nil values with the range", function()
      local t1 = { n = 3 }
      local t2 = {}
      for i, v in npairs(t1) do t2[i] = tostring(v) end
      assert.are.same({ "nil", "nil", "nil" }, t2)
    end)


    it("honours positive step size", function()
      local t1 = { [-5] = -5, [-4] = -4, [-3] = -3, [-2] = -2, [-1] = -1, [0] = 0, 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1, -4, 1, 2) do t2[#t2+1] = v end
      assert.are.same({ -4, -2, 0}, t2)
    end)


    it("honours negative step size", function()
      local t1 = { [-5] = -5, [-4] = -4, [-3] = -3, [-2] = -2, [-1] = -1, [0] = 0, 1, 2, 3 }
      local t2 = {}
      for i, v in npairs(t1, 0, -5, -2) do t2[#t2+1] = v end
      assert.are.same({ 0, -2, -4 }, t2)
    end)

  end)

end)
