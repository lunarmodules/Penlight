local Set = require("pl.Set")

describe("pl.Set", function ()

  local s = Set()
  local s1_2 = Set({ 1, 2 })
  local s1_2_3 = Set({ 1, 2, 3 })
  local s1_3 = Set({ 1, 3 })
  local s2 = Set({ 2 })
  local s2_1 = Set({ 2, 1 })
  local s2_3 = Set({ 2, 3 })
  local s3 = Set({ 3 })
  local sm = Set({ "foo", "bar" })

  it("should produce a set object", function ()
    assert.is.same({ true, true }, s1_2)
  end)

  it("should produce identical sets for any ordered input", function ()
    assert.is.same(s1_2, s2_1)
  end)

  describe("should have an operator for", function ()

    it("union", function ()
      assert.is.same(s1_2_3, s1_2 + s3)
      assert.is.same(s1_2_3, s1_2 + 3)
    end)

    it("intersection", function ()
      assert.is.same(s2, s1_2 * s2_3)
    end)

    it("difference", function ()
      assert.is.same(s2_1, s1_2_3 - s3)
      assert.is.same(s2_3, s1_2_3 - 1)
    end)

    it("symmetric difference", function ()
      assert.is.same(s1_3, s1_2 ^ s2_3)
    end)

    it("tostring", function ()
      -- Cannot test multi-entry sets because of non-deterministic key order
      assert.is.same('[2]', tostring(s2))
    end)

  end)

  describe("should provide functions", function ()

    it("isempty", function ()
      assert.is.truthy(Set.isempty(s))
      assert.is.falsy(Set.isempty(s3))
    end)

    it("set", function ()
      local m = Set()
      Set.set(m, 'foo', true)
      m.bar = true
      assert.is.same(m, sm)
      assert.is_not.same(m, s1_2)
    end)

  end)

  describe("should have a comparison operator for", function ()

    it("supersets/subsets than", function ()
      assert.is.truthy(s1_2 > s2)
      assert.is.falsy(s1_3 > s2)
      assert.is.falsy(s1_2 > s2_3)
      assert.is.truthy(s1_2 < s1_2_3)
      assert.is.falsy(s1_2_3 < s1_2)
    end)

    it("equality", function ()
      assert.is.truthy(s1_2 == s2_1)
      assert.is.falsy(s1_2 == s2_3)
    end)

  end)

end)
