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

  end)



  describe("indent()", function()

    it("adds an indent", function()
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

    it("appends a newline if not present", function()
      assert.equal("  hello\n  world\n", text.indent("hello\nworld", 2))
      assert.equal("  hello\n  world\n", text.indent("hello\nworld\n", 2))
    end)

  end)



  describe("dedent()", function()

    it("removes prefixed whitespace", function()
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

    it("removes prefixed whitespace, retains structure", function()
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

    it("appends a newline if not present", function()
      assert.equal("hello\nworld\n", text.dedent("  hello\n  world"))
      assert.equal("hello\nworld\n", text.dedent("  hello\n  world\n"))
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



  describe("fill()/wrap()", function()

    it("wraps width over limit", function()
      assert.same({
        "abc",
        "def"
      }, text.wrap("abc def", 2))
    end)

    it("wraps width at limit", function()
      assert.same({
        "abc",
        "def"
      }, text.wrap("abc def", 3))
      assert.same({
        "a c",
        "d f"
      }, text.wrap("a c d f", 3))
    end)

    it("wraps single letters", function()
      assert.same({"a"}, text.wrap("a"))
    end)

    it("wraps empty strings", function()
      assert.same({""}, text.wrap(""))
      assert.same({""}, text.wrap("    "))
    end)

    it("handles leading/trailing whitespace", function()
      assert.same({"hello"}, text.wrap("     hello     ", 10))
      assert.same({"hello"}, text.wrap("     hello     ", 2))
      assert.same({"he", "ll", "o"}, text.wrap("     hello     ", 2, true))
    end)

    it("handles line-breaks", function()
      assert.same({"Hello", "Dolly"}, text.wrap("Hello\nDolly", 10))
      assert.same({"Hello Dolly"}, text.wrap("Hello\nDolly", 20))
    end)

    it("doesn't split on accented characters", function()
      assert.same({"àbcdéfghîj"}, text.wrap("àbcdéfghîj"))
    end)

    it("word-wraps a text", function()
      local binstring = require("luassert.formatters.binarystring")
      assert:add_formatter(binstring)
      assert.equal([[
It is often said of
Lua that it does not
include batteries.
That is because the
goal of Lua is to
produce a lean
expressive language
that will be used on
all sorts of
machines, (some of
which don't even
have hierarchical
filesystems). The
Lua language is the
equivalent of an
operating system
kernel; the creators
of Lua do not see it
as their
responsibility to
create a full
software ecosystem
around the language.
That is the role of
the community.
]], text.fill("It is often said of Lua that it does not include batteries. That is because the goal of Lua is to produce a lean expressive language that will be used on all sorts of machines, (some of which don't even have hierarchical filesystems). The Lua language is the equivalent of an operating system kernel; the creators of Lua do not see it as their responsibility to create a full software ecosystem around the language. That is the role of the community.", 20))
    end)


    it("generic wrap test", function()
      local t = [[
hello "world" 'this' -is- a bb      ccc dddd test... but wouldn't it pass??? final. word-that-can-be-broken
]]

      assert.same({
        "hello",
        '"world"',
        "'this'",
        "-is-",
        "a",
        "bb",
        "ccc",
        "dddd",
        "test...",
        "but",
        "wouldn't",
        "it",
        "pass???",
        "final.",
        "word-that-can-be-broken",
      }, text.wrap(t, 3))
    end)

    it("generic wrap test, with overflow breaking", function()
      local t = [[
hello "world" 'this' -is- a bb      ccc dddd test... but wouldn't it pass??? final. word-that-can-be-broken
]]

      assert.same({
        "hel",
        "lo",
        '"wo',
        'rld',
        '"',
        "'th",
        "is'",
        "-is",
        "- a",
        "bb",
        "ccc",
        "ddd",
        "d",
        "tes",
        "t..",
        ".",
        "but",
        "wou",
        "ldn",
        "'t",
        "it",
        "pas",
        "s??",
        "?",
        "fin",
        "al.",
        "wor",
        "d-t",
        "hat",
        "-ca",
        "n-b",
        "e-b",
        "rok",
        "en",
      }, text.wrap(t, 3, true))
    end)

  end)

end)

