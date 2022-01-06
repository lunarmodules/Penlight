describe("pl.utils", function ()

  describe("enum()", function ()
    local enum, t

    before_each(function()
      enum = require("pl.utils").enum
      t = enum("ONE", "two", "THREE")
    end)


    it("holds enumerated values", function()
      assert.equal("ONE", t.ONE)
      assert.equal("two", t.two)
      assert.equal("THREE", t.THREE)
    end)



    describe("accessing", function()

      it("errors on unknown values", function()
        assert.has.error(function()
          print(t.four)
        end, "'four' is not a valid value (expected one of: 'ONE', 'two', 'THREE')")
      end)


      it("errors on setting new keys", function()
        assert.has.error(function()
          t.four = "four"
        end, "the Enum object is read-only")
      end)


      it("entries must be strings", function()
        assert.has.error(function()
          t = enum("hello", true, "world")
        end, "argument 2 expected a 'string', got a 'boolean'")
      end)


      it("requires at least 1 entry", function()
        assert.has.error(function()
          t = enum()
        end, "argument 1 expected a 'string', got a 'nil'")
      end)


      it("keys can have 'format' placeholders", function()
        t = enum("hello", "contains: %s")
        assert.has.error(function()
          print(t["%s"])  -- should still format error properly
        end, "'%s' is not a valid value (expected one of: 'hello', 'contains: %s')")
      end)

    end)



    describe("calling", function()

      it("returns error on unknown values", function()
        local ok, err = t("four")
        assert.equal(err, "'four' is not a valid value (expected one of: 'ONE', 'two', 'THREE')")
        assert.equal(nil, ok)
      end)


      it("returns value on success", function()
        local ok, err = t("THREE")
        assert.equal(nil, err)
        assert.equal("THREE", ok)
      end)

    end)

  end)

end)
