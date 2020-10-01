local MultiMap = require("pl.MultiMap")

describe("pl.MultiMap", function ()

  it("should hold multiple values per key", function ()
    local map = MultiMap()
    map:set('foo', 1)
    map:set('bar', 3)
    map:set('foo', 2)
    local expected = { foo = { 1, 2 }, bar = { 3 } }
    assert.is.same(expected, map)
  end)

end)
