local app = require("pl.app")

describe("pl.app.lua", function ()

  local invocation = app.lua()

  it("should pick up the arguments used to run this test", function ()
    assert.is.truthy(invocation:match("lua.+package.+busted"))
  end)

  it("should be reusable to invoke Lua", function ()
    assert.is.truthy(os.execute(app.lua()..' -e "n=1;os.exit(n-1)"'))
  end)

end)

describe("pl.app.platform", function ()

  -- TODO: Find a reliable alternate way to determine platform to check that
  -- this is returning the right answer, not just any old answer.
  it("should at least return a valid platform", function ()
    local platforms = { Linux = true, OSX = true, Windows = true }
    local detected = app.platform()
    assert.is.truthy(platforms[detected])
  end)

end)
