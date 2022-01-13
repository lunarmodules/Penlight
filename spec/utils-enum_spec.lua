describe("pl.utils", function ()

  describe("enum()", function ()
    local enum, t

    before_each(function()
      enum = require("pl.utils").enum
    end)


    describe("creating", function()

      it("accepts a vararg", function()
        t = enum("ONE", "two", "THREE")
        assert.same({
          ONE = "ONE",
          two = "two",
          THREE = "THREE",
        }, t)
      end)


      it("vararg entries must be strings", function()
        assert.has.error(function()
          t = enum("hello", true, "world")
        end, "argument 2 expected a 'string', got a 'boolean'")
        -- no holes
        assert.has.error(function()
          t = enum("hello", nil, "world")
        end, "argument 2 expected a 'string', got a 'nil'")
      end)


      it("vararg requires at least 1 entry", function()
        assert.has.error(function()
          t = enum()
        end, "expected at least 1 entry")
      end)


      it("accepts an array", function()
        t = enum { "ONE", "two", "THREE" }
        assert.same({
          ONE = "ONE",
          two = "two",
          THREE = "THREE",
        }, t)
      end)


      it("array entries must be strings", function()
        assert.has.error(function()
          t = enum { "ONE", 999, "THREE" }
        end, "expected 'string' but got 'number' at index 2")
      end)


      it("array requires at least 1 entry", function()
        assert.has.error(function()
          t = enum {}
        end, "expected at least 1 entry")
      end)


      it("accepts a hash-table", function()
        t = enum {
          FILE_NOT_FOUND = "The file was not found in the filesystem",
          FILE_READ_ONLY = "The file is read-only",
        }
        assert.same({
          FILE_NOT_FOUND = "The file was not found in the filesystem",
          FILE_READ_ONLY = "The file is read-only",
        }, t)
      end)


      it("hash-table keys must be strings", function()
        assert.has.error(function()
          t = enum { [{}] = "ONE" }
        end, "expected key to be 'string' but got 'table'")
      end)


      it("hash-table requires at least 1 entry", function()
        assert.has.error(function()
          t = enum {}
        end, "expected at least 1 entry")
      end)


      it("accepts a combined array/hash-table", function()
        t = enum {
          "BAD_FD",
          FILE_NOT_FOUND = "The file was not found in the filesystem",
          FILE_READ_ONLY = "The file is read-only",
        }
        assert.same({
          BAD_FD = "BAD_FD",
          FILE_NOT_FOUND = "The file was not found in the filesystem",
          FILE_READ_ONLY = "The file is read-only",
        }, t)
      end)


      it("keys must be unique with combined array/has-table", function()
        assert.has.error(function()
          t = enum {
            "FILE_NOT_FOUND",
            FILE_NOT_FOUND = "The file was not found in the filesystem",
          }
          end, "duplicate entry in array and hash part: 'FILE_NOT_FOUND'")
      end)

    end)



    describe("accessing", function()

      before_each(function()
        t = enum("ONE", "two", "THREE")
      end)


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


      it("keys can have 'format' placeholders", function()
        t = enum("hello", "contains: %s")
        assert.has.error(function()
          print(t["%s"])  -- should still format error properly
        end, "'%s' is not a valid value (expected one of: 'hello', 'contains: %s')")
      end)

    end)



    describe("calling", function()

      before_each(function()
        t = enum("ONE", "two", "THREE")
      end)


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
