local types = require("pl.types")
local class = require("pl.class")
local List = require("pl.List")
local Map = require("pl.Map")
local OrderedMap = require("pl.OrderedMap")
local Set = require("pl.Set")

describe("pl.types", function ()

  describe("is_type()", function ()

    it("checks Lua primitive type names", function ()
      assert.is_true(types.is_type("hello", "string"))
      assert.is_false(types.is_type("hello", "number"))
      assert.is_true(types.is_type(42, "number"))
      assert.is_false(types.is_type("42", "number"))
      assert.is_true(types.is_type({}, "table"))
      assert.is_true(types.is_type(true, "boolean"))
      assert.is_true(types.is_type(false, "boolean"))
      assert.is_false(types.is_type(1, "boolean"))
      assert.is_true(types.is_type(nil, "nil"))
      assert.is_false(types.is_type(false, "nil"))
      assert.is_true(types.is_type(function () end, "function"))

      local m = OrderedMap()
      assert.is_true(types.is_type(m, "table"))
      assert.is_false(types.is_type(m, "OrderedMap"))
    end)

    it("checks exact metatable equality", function ()
      local mt = {}
      local other_mt = {}
      local obj = setmetatable({}, mt)

      assert.is_true(types.is_type(obj, mt))
      assert.is_false(types.is_type(obj, other_mt))
      assert.is_false(types.is_type({}, mt))
      assert.is_false(types.is_type("hello", mt))
    end)

    it("matches direct Penlight classes", function ()
      local m = OrderedMap()
      local l = List()

      assert.is_true(types.is_type(m, OrderedMap))
      assert.is_true(types.is_type(l, List))
      assert.is_false(types.is_type(m, List))
    end)

    it("does not detect inheritance unlike Class:class_of and obj:is_a", function ()
      local m = OrderedMap()
      assert.is_false(types.is_type(m, Map))
      assert.is_true(OrderedMap:class_of(m))
      assert.is_true(Map:class_of(m))
      assert.is_true(m:is_a(OrderedMap))
      assert.is_true(m:is_a(Map))

      local A = class()
      local B = class(A)
      local C = class(B)
      local c = C()
      assert.is_true(types.is_type(c, C))
      assert.is_false(types.is_type(c, B))
      assert.is_false(types.is_type(c, A))
      assert.is_true(C:class_of(c))
      assert.is_true(B:class_of(c))
      assert.is_true(A:class_of(c))
      assert.is_true(c:is_a(C))
      assert.is_true(c:is_a(B))
      assert.is_true(c:is_a(A))

      -- Set derives from Map and sets __index = nil (methodless class)
      local s = Set({ 1, 2 })
      assert.is_true(types.is_type(s, Set))
      assert.is_false(types.is_type(s, Map))
      assert.is_true(Set:class_of(s))
      assert.is_true(Map:class_of(s))
    end)

  end)

  describe("type()", function ()

    it("returns type names for primitives, files, and metatables", function ()
      assert.are.equal("string", types.type("hello"))
      assert.are.equal("number", types.type(42))
      assert.are.equal("table", types.type({}))
      assert.are.equal("file", types.type(io.stdout))
      assert.are.equal("OrderedMap", types.type(OrderedMap()))
      assert.are.equal("unknown table", types.type(setmetatable({}, {})))
    end)

  end)

  describe("is_integer()", function ()

    it("identifies integers and non-integers", function ()
      assert.is_true(types.is_integer(10))
      assert.is_true(types.is_integer(-5))
      assert.is_false(types.is_integer(10.5))
    end)

  end)

  describe("is_empty()", function ()

    it("checks emptiness for nil, tables, and strings", function ()
      assert.is_true(types.is_empty(nil))
      assert.is_true(types.is_empty({}))
      assert.is_false(types.is_empty({ 1 }))
      assert.is_true(types.is_empty(""))
      assert.is_false(types.is_empty("   "))
      assert.is_true(types.is_empty("   ", true))
    end)

  end)

  describe("to_bool()", function ()

    it("converts values to booleans", function ()
      assert.is_true(types.to_bool(true))
      assert.is_true(types.to_bool("yes"))
      assert.is_true(types.to_bool(1))
      assert.is_false(types.to_bool(false))
      assert.is_false(types.to_bool("no"))
      assert.is_false(types.to_bool(0))
      assert.is_true(types.to_bool("ja", { "ja" }))
      assert.is_false(types.to_bool({ 1 }))
      assert.is_true(types.to_bool({ 1 }, nil, true))
    end)

  end)

end)
