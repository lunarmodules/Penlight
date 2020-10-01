local Date = require("pl.Date")

describe("pl.Date", function ()

  describe("function", function ()

    describe("Format()", function ()

      it("should output parsable inputs", function ()
        local function assert_date_format(expected, format)
          local df = Date.Format(format)
          local d = df:parse(expected)
          assert.is.equal(expected, df:tostring(d))
        end
        assert_date_format('02/04/10', 'dd/mm/yy')
        assert_date_format('04/02/2010', 'mm/dd/yyyy')
        assert_date_format('2011-02-20', 'yyyy-mm-dd')
        assert_date_format('20070320', 'yyyymmdd')
        assert_date_format('23:10', 'HH:MM')
      end)

      it("should parse 'slack' fields", function ()
        local df = Date.Format("m/d/yy")
        -- TODO: Re-enable when issue #359 fixed
        -- assert.is.equal('01/05/99', df:tostring(df:parse('1/5/99')))
        assert.is.equal('01/05/01', df:tostring(df:parse('1/5/01')))
        assert.is.equal('01/05/32', df:tostring(df:parse('1/5/32')))
      end)

    end)

  end)

  describe("meta method", function ()

    describe("__tostring()", function ()

      it("should be suitable for serialization", function ()
        local df = Date.Format()
        local du = df:parse("2008-07-05")
        assert.is.equal(du, du:toUTC())
      end)

    end)

  end)

end)
