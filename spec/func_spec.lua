local func = require("pl.func")

describe("pl.func", function ()

  describe("compose", function ()

    it("compose(f)(x) == f(x)", function ()
      local f = function(x) return x + 1 end
      assert.equals(func.compose(f)(1), f(1))
    end)

    it("compose(f, g)(x) == f(g(x))", function ()
      local f = function(x) return x + 1 end
      local g = function(x) return x + 2 end
      assert.equals(func.compose(f, g)(1), f(g(1)))
    end)

    it("compose(f, g, h)(x) == f(g(h(x)))", function ()
      local f = function(x) return x + 1 end
      local g = function(x) return x + 2 end
      local h = function(x) return x + 3 end
      assert.equals(func.compose(f, g, h)(1), f(g(h(1))))
    end)

    it("compose(f)(x, y) == f(x, y)", function ()
      local f = function(x, y) return x + 1, y + 1 end
      local ax, ay = func.compose(f)(1, 2)
      local bx, by = f(1, 2)
      assert.equals(ax, bx)
      assert.equals(ay, by)
    end)

    it("compose(f, g)(x, y) == f(g(x, y))", function ()
      local f = function(x, y) return x + 1, y + 1 end
      local g = function(x, y) return x + 2, y + 2 end
      local ax, ay = func.compose(f, g)(1, 2)
      local bx, by = f(g(1, 2))
      assert.equals(ax, bx)
      assert.equals(ay, by)
    end)

    it("compose(f, g, h)(x, y) == f(g(h(x, y)))", function ()
      local f = function(x, y) return x + 1, y + 1 end
      local g = function(x, y) return x + 2, y + 2 end
      local h = function(x, y) return x + 3, y + 3 end
      local ax, ay = func.compose(f, g, h)(1, 2)
      local bx, by = f(g(h(1, 2)))
      assert.equals(ax, bx)
      assert.equals(ay, by)
    end)

  end)

end)
