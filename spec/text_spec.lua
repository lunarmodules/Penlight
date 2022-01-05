describe("pl.text", function()

  it("forwarded to stringx", function()
    assert.equal(
      require "pl.stringx",
      require "pl.text"
    )
  end)

end)
