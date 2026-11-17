local app = require("pl.app")

describe("pl.app.lua", function ()

  describe("with a synthetic command line", function ()
    local saved_arg

    before_each(function ()
      saved_arg = _G.arg
    end)

    after_each(function ()
      _G.arg = saved_arg
    end)

    it("returns only the interpreter and its options", function ()
      local exe = "path with spaces/lua"
      _G.arg = {
        [-4] = exe, [-3] = "-lpl.path", [-2] = "-e", [-1] = "n = 1",
        [0] = "script.lua", [1] = "script argument",
      }

      local command, executable = app.lua()
      local quote_arg = require("pl.utils").quote_arg
      assert.are.equal(quote_arg(exe) .. " -lpl.path -e " .. quote_arg("n = 1"), command)
      assert.are.equal(exe, executable)
    end)

    it("returns the interpreter when there are no options", function ()
      _G.arg = { [-1] = "lua", [0] = "script.lua" }
      local command, executable = app.lua()
      assert.are.equal("lua", command)
      assert.are.equal("lua", executable)
    end)

    it("reports when there is no main program", function ()
      _G.arg = nil
      local command, err = app.lua()
      assert.is_nil(command)
      assert.are.equal("not in a main program", err)
    end)
  end)

  it("should be reusable to invoke Lua", function ()
    local ok, _, code = os.execute(app.lua()..' -e "os.exit(0)"')
    -- Lua 5.1 returns the status directly; later versions return a status triple.
    assert.is_true(ok == 0 or (ok == true and code == 0))
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
