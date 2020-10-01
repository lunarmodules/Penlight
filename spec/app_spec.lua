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
