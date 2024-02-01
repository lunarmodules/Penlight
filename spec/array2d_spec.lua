local array2d = require("pl.array2d")

describe("pl.array2d", function()

  describe("new()", function()
    it("creates an empty 2d array", function()
      assert.same({{},{},{}}, array2d.new(3,3,nil))
    end)

    it("creates a value-filled 2d array", function()
      assert.same({{99,99,99},
                   {99,99,99},
                   {99,99,99}}, array2d.new(3,3,99))
    end)

    it("creates a function-filled 2d array", function()
      assert.same({{2,3,4},
                   {3,4,5},
                   {4,5,6}}, array2d.new(3,3,function(i,j) return i+j end))
    end)
  end)

  describe("size()", function()
    it("returns array size", function()
      local a = array2d.new(3,5,99)
      assert.same({3,5}, {array2d.size(a)})
    end)

    it("returns 0 columns for nil arrays", function()
      local a = array2d.new(3,5,nil)
      assert.same({3,0}, {array2d.size(a)})
    end)
  end)

  describe("column()", function()
    it("returns a column copy", function()
      local a = {{1,2},
                 {3,4},
                 {5,6}}
      assert.same({1,3,5}, array2d.column(a,1))
      assert.same({2,4,6}, array2d.column(a,2))
    end)
  end)

  describe("row()", function()
    it("returns a row copy", function()
      local a = {{1,2},
                 {3,4},
                 {5,6}}
      assert.same({1,2}, array2d.row(a,1))
      -- next test: need to remove the metatable to prevent comparison by
      -- metamethods in Lua 5.3 and 5.4
      assert.not_equal(a[1], setmetatable(array2d.row(a,1),nil))
      assert.same({3,4}, array2d.row(a,2))
      assert.same({5,6}, array2d.row(a,3))
    end)
  end)

  describe("map()", function()
    it("maps a function on an array", function()
        local a1 = array2d.new(2,3,function(i,j) return i+j end)
        local a2 = array2d.map(function(a,b) return a .. b end, a1, "x")
        assert.same({{"2x","3x","4x"},
                     {"3x","4x","5x"}}, a2)
      end)
  end)

  describe("reduce_rows()", function()
    it("reduces rows", function()
      local a = {{   1,   2,   3,   4},
                 {  10,  20,  30,  40},
                 { 100, 200, 300, 400},
                 {1000,2000,3000,4000}}
      assert.same({10,100,1000,10000},array2d.reduce_rows('+',a))
    end)
  end)

  describe("reduce_cols()", function()
    it("reduces columns", function()
      local a = {{   1,   2,   3,   4},
                 {  10,  20,  30,  40},
                 { 100, 200, 300, 400},
                 {1000,2000,3000,4000}}
      assert.same({1111,2222,3333,4444},array2d.reduce_cols('+',a))
    end)
  end)

  describe("reduce2()", function()
    it("recuces array to scalar", function()
      local a = {{1,10},
                 {2,10},
                 {3,10}}
      assert.same(60, array2d.reduce2('+','*',a))
    end)
  end)

  describe("map2()", function()
    it("maps over 2 arrays", function()
      local b = {{10,20},
                 {30,40}}
      local a = {{1,2},
                 {3,4}}
      -- 2 2d arrays
      assert.same({{11,22},{33,44}}, array2d.map2('+',2,2,a,b))
      -- 1d, 2d
      assert.same({{11,102},{13,104}}, array2d.map2('+',1,2,{10,100},a))
      -- 2d, 1d
      assert.same({{1,-2},{3,-4}},array2d.map2('*',2,1,a,{1,-1}))
    end)
  end)

  describe("product()", function()
    it("creates a product array", function()
      local a = array2d.product('..',{1,2,3},{'a','b','c'})
      assert.same({{'1a','2a','3a'},{'1b','2b','3b'},{'1c','2c','3c'}}, a)

      local a = array2d.product('{}',{1,2},{'a','b','c'})
      assert.same({{{1,'a'},{2,'a'}},{{1,'b'},{2,'b'}},{{1,'c'},{2,'c'}}}, a)
    end)
  end)

  describe("flatten()", function()
    it("flattens a 2darray", function()
      local a = {{1,2},
                 {3,4},
                 {5,6}}
      assert.same( {1,2,3,4,5,6}, array2d.flatten(a))
    end)

    it("keeps a nil-array 'square'", function()
      local a = {{  1,2},
                 {nil,4},
                 {nil,6}}
      assert.same( {1,2,nil,4,nil,6}, array2d.flatten(a))
    end)
  end)

  describe("reshape()", function()
    it("reshapes array in new nr of rows", function()
      local a = {{ 1, 2, 3},
                 { 4, 5, 6},
                 { 7, 8, 9},
                 {10,11,12}}
      local b = array2d.reshape(a, 2, false)
      assert.same({{ 1, 2, 3, 4, 5, 6},
                   { 7, 8, 9,10,11,12}}, b)
      local c = array2d.reshape(b, 4, false)
      assert.same(a, c)
    end)
    it("reshapes array in new nr of rows, column order", function()
      local a = {{ 1, 2, 3},
                 { 4, 5, 6},
                 { 7, 8, 9}}
      local b = array2d.reshape(a, 3, true)
      assert.same({{ 1, 4, 7},
                   { 2, 5, 8},
                   { 3, 6, 9}}, b)
    end)
  end)

  describe("transpose()", function()
    it("transposes a 2d array", function()
      local a = {{ 1, 2, 3},
                 { 4, 5, 6},
                 { 7, 8, 9}}
      local b = array2d.transpose(a)
      assert.same({{ 1, 4, 7},
                   { 2, 5, 8},
                   { 3, 6, 9}}, b)

      local a = {{ 1, 2, 3, 4, 5},
                 { 6, 7, 8, 9, 10}}
      local b = array2d.transpose(a)
      assert.same({{ 1, 6},
                   { 2, 7},
                   { 3, 8},
                   { 4, 9},
                   { 5,10}}, b)
    end)
  end)

  describe("swap_rows()", function()
    it("swaps 2 rows, in-place", function()
      local a = {{1,2},
                 {3,4},
                 {5,6}}
      local b = array2d.swap_rows(a, 1, 3)
      assert.same({{5,6},
                   {3,4},
                   {1,2}}, b)
      assert.equal(a, b)
    end)
  end)

  describe("swap_cols()", function()
    it("swaps 2 columns, in-place", function()
      local a = {{1,2,3},
                 {4,5,6},
                 {7,8,9}}
      local b = array2d.swap_cols(a, 1, 3)
      assert.same({{3,2,1},
                   {6,5,4},
                   {9,8,7}}, b)
      assert.equal(a, b)
    end)
  end)

  describe("extract_rows()", function()
    it("extracts rows", function()
      local a = {{ 1, 2, 3},
                 { 4, 5, 6},
                 { 7, 8, 9},
                 {10,11,12}}
      local b = array2d.extract_rows(a, {1, 3})
      assert.same({{1,2,3},
                   {7,8,9}}, b)
    end)
  end)

  describe("extract_cols()", function()
    it("extracts columns", function()
      local a = {{ 1, 2, 3},
                 { 4, 5, 6},
                 { 7, 8, 9},
                 {10,11,12}}
      local b = array2d.extract_cols(a, {1, 2})
      assert.same({{ 1, 2},
                   { 4, 5},
                   { 7, 8},
                   {10,11}}, b)
    end)
  end)

  describe("remove_row()", function()
    it("removes a row", function()
      local a = {{ 1, 2, 3},
                 { 4, 5, 6},
                 { 7, 8, 9},
                 {10,11,12}}
      array2d.remove_row(a, 2)
      assert.same({{ 1, 2, 3},
                   { 7, 8, 9},
                   {10,11,12}}, a)
    end)
  end)

  describe("remove_col()", function()
    it("removes a colum", function()
      local a = {{ 1, 2, 3},
                 { 4, 5, 6},
                 { 7, 8, 9},
                 {10,11,12}}
      array2d.remove_col(a, 2)
      assert.same({{ 1, 3},
                   { 4, 6},
                   { 7, 9},
                   {10,12}}, a)
    end)
  end)

  describe("parse_range()", function()
    it("parses A1:B2 format", function()
      assert.same({4,11,7,12},{array2d.parse_range("K4:L7")})
      assert.same({4,28,7,54},{array2d.parse_range("AB4:BB7")})
      -- test Col R since it might be mixed up with RxCx format
      assert.same({4,18,7,18},{array2d.parse_range("R4:R7")})
    end)

    it("parses A1 format", function()
      assert.same({4,11},{array2d.parse_range("K4")})
      -- test Col R since it might be mixed up with RxCx format
      assert.same({4,18},{array2d.parse_range("R4")})
    end)

    it("parses R1C1:R2C2 format", function()
      assert.same({4,11,7,12},{array2d.parse_range("R4C11:R7C12")})
    end)

    it("parses R1C1 format", function()
      assert.same({4,11},{array2d.parse_range("R4C11")})
    end)
  end)

  describe("range()", function()
    it("returns a range", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local b = array2d.range(a, "B3:C4")
      assert.same({{ 8, 9},
                   {11,12}}, b)
    end)
  end)

  describe("default_range()", function()
    it("returns the default range", function()
      local a = array2d.new(4,6,1)
      assert.same({1,1,4,6}, {array2d.default_range(a, nil, nil, nil, nil)})
    end)

    it("accepts negative indices", function()
      local a = array2d.new(4,6,1)
      assert.same({2,2,3,5}, {array2d.default_range(a, -3, -5, -2, -2)})
    end)

    it("corrects out of bounds indices", function()
      local a = array2d.new(4,6,1)
      assert.same({1,1,4,6}, {array2d.default_range(a, -100, -100, 100, 100)})
    end)
  end)

  describe("slice()", function()
    it("returns a slice", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local b = array2d.slice(a,3,2,4,3)
      assert.same({{ 8, 9},
                   {11,12}}, b)
    end)

    it("returns a single row if rows are equal", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local b = array2d.slice(a,4,1,4,3)
      assert.same({10,11,12}, b)
    end)

    it("returns a single column if columns are equal", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local b = array2d.slice(a,1,3,4,3)
      assert.same({3,6,9,12}, b)
    end)

    it("returns a single value if rows and columns are equal", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local b = array2d.slice(a,2,2,2,2)
      assert.same(5, b)
    end)
  end)

  describe("set()", function()
    it("sets a range to a value", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      array2d.set(a,0,2,2,3,3)
      assert.same({{1 ,2 ,3},
                   {4 ,0 ,0},
                   {7 ,0 ,0},
                   {10,11,12}}, a)
    end)

    it("sets a range to a function value", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local x = 10
      local args = {}
      local f = function(r,c)
        args[#args+1] = {r,c}
        x = x + 1
        return x
      end
      array2d.set(a,f,3,1,4,3)
      assert.same({{1 ,2 ,3},
                   {4 ,5 ,6},
                   {11,12,13},
                   {14,15,16}}, a)
      -- validate args used to call the function
      assert.same({{3,1},{3,2},{3,3},{4,1},{4,2},{4,3}}, args)
    end)
  end)

  describe("write()", function()
    it("writes array to a file", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local f = setmetatable({}, {
        __index = {
          write = function(self,str)
            self[#self+1] = str
          end
        }
      })
      array2d.write(a,f,"(%s)")
      f = table.concat(f)
      assert.equal([[(1)(2)(3)
(4)(5)(6)
(7)(8)(9)
(10)(11)(12)
]],f)
    end)

    it("writes partial array to a file", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local f = setmetatable({}, {
        __index = {
          write = function(self,str)
            self[#self+1] = str
          end
        }
      })
      array2d.write(a,f,"(%s)", 1,1,2,2)
      f = table.concat(f)
      assert.equal([[(1)(2)
(4)(5)
]],f)
    end)
  end)

  describe("forall()", function()
    it("runs all value and row functions", function()
      local r = {}
      local t = 0
      local fval = function(row, j) t = t + row[j] end
      local frow = function(i) r[#r+1] = t; t = 0 end
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      array2d.forall(a, fval, frow)
      assert.same({6, 15, 24, 33}, r)
      r = {}
      array2d.forall(a, fval, frow, 2,2,4,3)
      assert.same({11, 17, 23}, r)
    end)

  end)

  describe("move()", function()
    it("moves block to destination array", function()
      local a = array2d.new(4,4,0)
      local b = array2d.new(3,3,1)
      array2d.move(a,2,2,b)
      assert.same({{0,0,0,0},
                   {0,1,1,1},
                   {0,1,1,1},
                   {0,1,1,1}}, a)
    end)
  end)

  describe("iter()", function()
    it("iterates all values", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local r = {}
      for v, i, j in array2d.iter(a) do
        r[#r+1] = v
        assert.is_nil(i)
        assert.is_nil(j)
      end
      assert.same({1,2,3,4,5,6,7,8,9,10,11,12}, r)
    end)

    it("iterates all values and indices", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local r = {}
      local ri = {}
      local rj = {}
      for i, j, v in array2d.iter(a,true) do
        r[#r+1] = v
        ri[#ri+1] = i
        rj[#rj+1] = j
      end
      assert.same({1,2,3,4,5,6,7,8,9,10,11,12}, r)
      assert.same({1,1,1,2,2,2,3,3,3,4,4,4}, ri)
      assert.same({1,2,3,1,2,3,1,2,3,1,2,3}, rj)
    end)

    it("iterates all values of a 2d array part", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local r = {}
      for v, i, j in array2d.iter(a,false,2,2,4,3) do
        r[#r+1] = v
        assert.is_nil(i)
        assert.is_nil(j)
      end
      assert.same({5,6,8,9,11,12}, r)
    end)

    it("iterates all values and indices of a 2d array part", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local r = {}
      local ri = {}
      local rj = {}
      for i, j, v in array2d.iter(a,true,2,2,4,3) do
        r[#r+1] = v
        ri[#ri+1] = i
        rj[#rj+1] = j
      end
      assert.same({5,6,8,9,11,12}, r)
      assert.same({2,2,3,3,4,4}, ri)
      assert.same({2,3,2,3,2,3}, rj)
    end)
  end)

  describe("columns()", function()
    it("iterates all columns", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local r = {}
      for col, idx in array2d.columns(a) do
        r[#r+1] = col
        col.idx = idx
      end
      assert.same({{1,4,7,10, idx=1},{2,5,8,11, idx=2},{3,6,9,12, idx=3}}, r)
    end)
  end)

  describe("rows()", function()
    it("iterates all columns", function()
      local a = {{1 ,2 ,3},
                 {4 ,5 ,6},
                 {7 ,8 ,9},
                 {10,11,12}}
      local r = {}
      for row, idx in array2d.rows(a) do
        r[#r+1] = row
        row.idx = idx
      end
      assert.same({{1,2,3, idx=1},{4,5,6, idx=2},
                   {7,8,9, idx=3},{10,11,12, idx=4}}, r)
    end)
  end)

end)
