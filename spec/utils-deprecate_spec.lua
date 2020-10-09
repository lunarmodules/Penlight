local utils = require("pl.utils")

describe("pl.utils", function ()

  local old_fn, last_msg, last_trace

  before_each(function()
    old_fn = utils.deprecation_warning
    last_msg = nil
    last_trace = nil
    utils.deprecation_warning = function(msg, trace)
      last_msg = msg
      last_trace = trace
    end
  end)


  after_each(function()
    utils.deprecation_warning = old_fn
  end)



  describe("raise_deprecation", function ()

    it("requires the opts table", function()
      assert.has.error(function() utils.raise_deprecation(nil) end,
                       "argument 1 expected a 'table', got a 'nil'")
    end)


    it("requires the opts.message field", function()
      assert.has.error(function() utils.raise_deprecation({}) end,
                       "field 'message' of the options table must be a string")
    end)


    it("should output the message", function ()
      utils.raise_deprecation {
        message = "hello world"
      }
      assert.equal("hello world", last_msg)
    end)


    it("should output the deprecated version", function ()
      utils.raise_deprecation {
        message = "hello world",
        version_deprecated = "2.0.0",
      }
      assert.equal("hello world (deprecated after 2.0.0)", last_msg)
    end)


    it("should output the removal version", function ()
      utils.raise_deprecation {
        message = "hello world",
        version_removed = "3.0.0",
      }
      assert.equal("hello world (scheduled for removal in 3.0.0)", last_msg)
    end)


    it("should output the deprecated and removal versions", function ()
      utils.raise_deprecation {
        message = "hello world",
        version_deprecated = "2.0.0",
        version_removed = "3.0.0",
      }
      assert.equal("hello world (deprecated after 2.0.0, scheduled for removal in 3.0.0)", last_msg)
    end)


    it("should output the application/module name", function ()
      utils.raise_deprecation {
        source = "MyApp 1.2.3",
        message = "hello world",
        version_deprecated = "2.0.0",
        version_removed = "3.0.0",
      }
      assert.equal("[MyApp 1.2.3] hello world (deprecated after 2.0.0, scheduled for removal in 3.0.0)", last_msg)
    end)


    it("should add a stracktrace", function ()
      local function my_function_name()
        utils.raise_deprecation {
          source = "MyApp 1.2.3",
          message = "hello world",
          version_deprecated = "2.0.0",
          version_removed = "3.0.0",
        }
      end
      my_function_name()

      assert.Not.match("raise_deprecation", last_trace)
      assert.match("my_function_name", last_trace)
    end)

  end)

end)
