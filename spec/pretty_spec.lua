local pretty = require("pl.pretty")

describe("pl.pretty.number", function ()

  it("should format memory", function ()
    local function assert_memory (expected, input)
      assert.is.equal(expected, pretty.number(input, "M"))
    end
    assert_memory("123B", 123)
    assert_memory("1.2KiB", 1234)
    assert_memory("10.0KiB", 10*1024)
    assert_memory("1.0MiB", 1024*1024)
    assert_memory("1.0GiB", 1024*1024*1024)
  end)

  it("should format postfixes", function ()
    local function assert_postfix(expected, input)
      assert.is.equal(expected, pretty.number(input, "N", 2))
    end
    assert_postfix("123", 123)
    assert_postfix("1.23K", 1234)
    assert_postfix("10.24K", 10*1024)
    assert_postfix("1.05M", 1024*1024)
    assert_postfix("1.07B", 1024*1024*1024)
  end)

  it("should format postfixes", function ()
    local function assert_separator(expected, input)
      assert.is.equal(expected, pretty.number(input, "T"))
    end
    assert_separator('123', 123)
    assert_separator('1,234', 1234)
    assert_separator('12,345', 12345)
    assert_separator('123,456', 123456)
    assert_separator('1,234,567', 1234567)
    assert_separator('12,345,678', 12345678)
  end)


end)
