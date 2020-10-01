local Date = require("pl.Date")

describe("pl.Date:__tostring()", function ()

  it("should be suitable for serialization", function ()
    local df = Date.Format()
    local du = df:parse("2008-07-05")
    assert.is.equal(du, du:toUTC())
  end)

end)
