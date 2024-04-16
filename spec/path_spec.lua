
-- conditional it/pending blocks per platform
local function nix_it(desc, ...)
  if package.config:sub(1,1) == "\\" then
    pending("Skip test on Windows: " .. desc, ...)
  else
    it(desc, ...)
  end
end
local function win_it(desc, ...)
  if package.config:sub(1,1) == "\\" then
    it(desc, ...)
  else
    pending("Skip test on Unix: " .. desc, ...)
  end
end



describe("pl.path", function()

  local pl_path
  local pl_utils
  local mock_envs
  local old_get_env

  before_each(function()
    pl_utils = require "pl.utils"
    mock_envs = {}
    old_get_env = pl_utils.getenv
    pl_utils.getenv = function(name)      -- luacheck: ignore
      return mock_envs[name]
    end
    package.loaded["pl.path"] = nil
    pl_path = require "pl.path"
  end)

  after_each(function()
    package.loaded["pl.path"] = nil
    pl_utils.getenv = old_get_env         -- luacheck: ignore
  end)



  describe("expanduser()", function()

    it("should expand ~ to the user's home directory", function()
      mock_envs = {
        HOME = "/home/user",
      }
      assert.equal("/home/user/file", pl_path.expanduser("~/file"))
    end)


    nix_it("returns an error if expansion fails: HOME not set", function()
      mock_envs = {}
      assert.same(
        { nil, "failed to expand '~' (HOME not set)" },
        { pl_path.expanduser("~/file")}
      )
    end)


    win_it("returns an error if expansion fails: all Windows vars", function()
      mock_envs = {}
      assert.same(
        { nil, "failed to expand '~' (HOME, USERPROFILE, and HOMEDRIVE and/or HOMEPATH not set)" },
        { pl_path.expanduser("~/file")}
      )
    end)


    win_it("HOME is first in line", function()
      mock_envs = {
        HOME = "\\home\\user1",
        USERPROFILE = "\\home\\user2",
        HOMEDRIVE = "C:",
        HOMEPATH = "\\home\\user3",
      }
      assert.equal("\\home\\user1\\file", pl_path.expanduser("~\\file"))
    end)


    win_it("USERPROFILE is second in line", function()
      mock_envs = {
        --HOME = "\\home\\user1",
        USERPROFILE = "\\home\\user2",
        HOMEDRIVE = "C:",
        HOMEPATH = "\\home\\user3",
      }
      assert.equal("\\home\\user2\\file", pl_path.expanduser("~\\file"))
    end)


    win_it("HOMEDRIVE/PATH is third in line", function()
      mock_envs = {
        -- HOME = "\\home\\user1",
        -- USERPROFILE = "\\home\\user2",
        HOMEDRIVE = "C:",
        HOMEPATH = "\\home\\user3",
      }
      assert.equal("C:\\home\\user3\\file", pl_path.expanduser("~\\file"))
    end)

  end)

end)

