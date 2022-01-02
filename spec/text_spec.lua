describe("pl.text", function ()

  local text = require("pl.text")

  describe("Template", function()

    local Template = text.Template


    it("substitute() replaces placeholders", function()
      local t1 = Template [[
while true do
  $contents
end
]]

      assert.equal([[
while true do
  print "hello"
end
]], t1:substitute {contents = 'print "hello"'})
    end)


    it("substitute() replaces multiple placeholders", function ()
      local template = Template("${here} is the $answer")
      local out = template:substitute({ here = 'one', answer = 'two' })
      assert.is.equal('one is the two', out)
    end)


    it("indent_substitute() indents replaced multi-lines", function()
      local t1 = Template [[
while true do
  $contents
end
]]

      assert.equal(
"while true do\n"..
"  for i = 1,10 do\n"..
"    gotcha(i)\n"..
"  end\n"..
"\n"..
"end\n"
, t1:indent_substitute {contents = [[
for i = 1,10 do
  gotcha(i)
end
]]})
    end)


    it("indent()", function()
      local t = "a whole lot\nof love"

      assert.equal([[
    a whole lot
    of love
]], text.indent(t, 4))

      assert.equal([[
**easy
**
**enough!
]], text.indent("easy\n\nenough!", 2 ,'*'))
    end)

    it("indent() appends a newline if not present", function()
      assert.equal("  hello\n  world\n", text.indent("hello\nworld", 2))
      assert.equal("  hello\n  world\n", text.indent("hello\nworld\n", 2))
    end)


    it("dedent() removes prefixed whitespace", function()
      assert.equal([[
one
two
three
]], text.dedent [[
    one
    two
    three
]])
    end)

    it("dedent() removes prefixed whitespace, retains structure", function()
      assert.equal([[
  one

 two

three
]], text.dedent [[
      one

     two

    three
]])
    end)

    it("dedent() appends a newline if not present", function()
      assert.equal("hello\nworld\n", text.dedent("  hello\n  world"))
      assert.equal("hello\nworld\n", text.dedent("  hello\n  world\n"))
    end)


    it("fill()/wrap() word-wraps a text", function()
      assert.equal([[
It is often said of Lua
that it does not include
batteries. That is because
the goal of Lua is to
produce a lean expressive
language that will be
used on all sorts of machines,
(some of which don't
even have hierarchical
filesystems). The Lua
language is the equivalent
of an operating system
kernel; the creators of
Lua do not see it as their
responsibility to create
a full software ecosystem
around the language. That
is the role of the community.
]], text.fill("It is often said of Lua that it does not include batteries. That is because the goal of Lua is to produce a lean expressive language that will be used on all sorts of machines, (some of which don't even have hierarchical filesystems). The Lua language is the equivalent of an operating system kernel; the creators of Lua do not see it as their responsibility to create a full software ecosystem around the language. That is the role of the community.", 20))
    end)

end)

  describe("format_operator()", function()

    setup(function()
      text.format_operator()
    end)


    it("handles plain substitutions", function()
      assert.equal('[home]', '[%s]' % 'home')
      assert.equal('fred = 42', '%s = %d' % {'fred',42})
    end)


    it("invokes tostring on %s formats", function()
      -- mostly works like string.format, except that %s forces use of tostring()
      -- rather than throwing an error
      local List = require 'pl.List'
      assert.equal('TBL:{1,2,3}', 'TBL:%s' % List{1,2,3})
    end)


    it("replaces '$field' references", function()
      -- table with keys and format with $
      assert.equal('<1>', '<$one>' % {one=1})
    end)


    it("accepts replacement functions", function()
      local function subst(k)
        if k == 'A' then
          return 'ay'
        elseif k == 'B' then
          return 'bee'
        else
          return '?'
        end
      end
      assert.equal('ay & bee', '$A & $B' % subst)
    end)

  end)

end)

