local utils = require("pl.utils")

describe("pl.utils", function()

  local TEST_NAME = "name" .. tostring(math.random(1000))

  after_each(function()
    utils.setenv_default(TEST_NAME, nil)
  end)


  describe("setenv_default", function ()

    it("errors if name isn't a string", function()
      assert.has.errors(function()
        utils.setenv_default(nil, "value")
      end)
      assert.has.errors(function()
        utils.setenv_default(123, "value")
      end)
    end)


    it("doesn't error if name is a string", function()
      assert.has.no.errors(function()
        utils.setenv_default(TEST_NAME, "value")
      end)
    end)


    it("errors if value isn't a string", function()
      assert.has.errors(function()
        utils.setenv_default(TEST_NAME, 123)
      end)
      assert.has.errors(function()
        utils.setenv_default(123, "value")
      end)
    end)


    it("doesn't error if value is nil or a string", function()
      assert.has.no.errors(function()
        utils.setenv_default(TEST_NAME, "value")
      end)
      assert.has.no.errors(function()
        utils.setenv_default(TEST_NAME, nil)
      end)
    end)

  end)



  describe("getenv", function ()

    it("errors if name isn't a string", function()
      assert.has.errors(function()
        utils.getenv(nil)
      end)
      assert.has.errors(function()
        utils.getenv(123)
      end)
    end)


    it("doesn't error if name is a string", function()
      assert.has.no.errors(function()
        utils.getenv(TEST_NAME)
      end)
    end)


    it("returns values set by setenv_default", function()
      utils.setenv_default(TEST_NAME, "value")
      assert.equal(utils.getenv(TEST_NAME), "value")

      utils.setenv_default(TEST_NAME, nil)
      assert.is_nil(utils.getenv(TEST_NAME))
    end)


    it("returns defaults only as fallback", function()
      -- PATH is set on all systems, so we use that to test
      finally(function()
        utils.setenv_default("PATH", nil)
      end)

      utils.setenv_default("PATH", "value")
      assert.not_nil(utils.getenv("PATH"))
      assert.not_equal(utils.getenv("PATH"), "value")
    end)


    if utils.is_windows then
      it("is case-insensitive on Windows", function()
        finally(function()
          utils.setenv_default(TEST_NAME:upper(), nil)
        end)

        assert.is_nil(utils.getenv(TEST_NAME:lower()))  -- verify it's unset first
        utils.setenv_default(TEST_NAME:upper(), "value")
        assert.equal(utils.getenv(TEST_NAME:lower()), "value")
      end)
    end

  end)

end)
