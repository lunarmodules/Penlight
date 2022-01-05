describe("stringx", function()

  local stringx = require "pl.stringx"


  it("isalpha()", function()
    assert.equal(false, stringx.isalpha '')
    assert.equal(false, stringx.isalpha' ')
    assert.equal(false, stringx.isalpha'0')
    assert.equal(false, stringx.isalpha'\0')
    assert.equal(true, stringx.isalpha'azAZ')
    assert.equal(false, stringx.isalpha'az9AZ')
  end)


  it("isdigit()", function()
    assert.equal(false, stringx.isdigit'')
    assert.equal(false, stringx.isdigit' ')
    assert.equal(false, stringx.isdigit'a')
    assert.equal(true, stringx.isdigit'0123456789')
  end)


  it("isalnum()", function()
    assert.equal(false, stringx.isalnum'')
    assert.equal(false, stringx.isalnum' ')
    assert.equal(true, stringx.isalnum'azAZ01234567890')
  end)


  it("isspace()", function()
    assert.equal(false, stringx.isspace'')
    assert.equal(true, stringx.isspace' ')
    assert.equal(true, stringx.isspace' \r\n\f\t')
    assert.equal(false, stringx.isspace' \r\n-\f\t')
  end)


  it("islower()", function()
    assert.equal(false, stringx.islower'')
    assert.equal(true, stringx.islower'az')
    assert.equal(false, stringx.islower'aMz')
    assert.equal(true, stringx.islower'a z')
  end)


  it("isupper()", function()
    assert.equal(false, stringx.isupper'')
    assert.equal(true, stringx.isupper'AZ')
    assert.equal(false, stringx.isupper'AmZ')
    assert.equal(true, stringx.isupper'A Z')
  end)


  it("startswith()", function()
    local startswith = stringx.startswith
    assert.equal(true, startswith('', ''))
    assert.equal(false, startswith('', 'a'))
    assert.equal(true, startswith('a', ''))
    assert.equal(true, startswith('a', 'a'))
    assert.equal(false, startswith('a', 'b'))
    assert.equal(false, startswith('a', 'ab'))
    assert.equal(true, startswith('abc', 'ab'))
    assert.equal(false, startswith('abc', 'bc'))    -- off by one
    assert.equal(false, startswith('abc', '.'))     -- Lua pattern char
    assert.equal(true, startswith('a\0bc', 'a\0b')) -- '\0'

    assert.equal(true, startswith('abcfoo',{'abc','def'}))
    assert.equal(true, startswith('deffoo',{'abc','def'}))
    assert.equal(false, startswith('cdefoo',{'abc','def'}))
  end)


  it("endswith()", function()
    local endswith = stringx.endswith
    assert.equal(true, endswith("", ""))
    assert.equal(false, endswith("", "a"))
    assert.equal(true, endswith("a", ""))
    assert.equal(true, endswith("a", "a"))
    assert.equal(false, endswith("a", "A"))         -- case sensitive
    assert.equal(false, endswith("a", "aa"))
    assert.equal(true, endswith("abc", ""))
    assert.equal(false, endswith("abc", "ab"))      -- off by one
    assert.equal(true, endswith("abc", "c"))
    assert.equal(true, endswith("abc", "bc"))
    assert.equal(true, endswith("abc", "abc"))
    assert.equal(false, endswith("abc", " abc"))
    assert.equal(false, endswith("abc", "a"))
    assert.equal(false, endswith("abc", "."))       -- Lua pattern char
    assert.equal(true, endswith("ab\0c", "b\0c"))   -- \0
    assert.equal(false, endswith("ab\0c", "b\0d"))  -- \0

    assert.equal(true, endswith('dollar.dot',{'.dot','.txt'}))
    assert.equal(true, endswith('dollar.txt',{'.dot','.txt'}))
    assert.equal(false, endswith('dollar.rtxt',{'.dot','.txt'}))
  end)


  it("join()", function()
    assert.equal('1 2 3', stringx.join(' ', {1,2,3}))
  end)


  it("splitlines", function()
    assert.same({}, stringx.splitlines(''))
    assert.same({'a'}, stringx.splitlines('a'))
    assert.same({''}, stringx.splitlines('\n'))
    assert.same({'', ''}, stringx.splitlines('\n\n'))
    assert.same({'', ''}, stringx.splitlines('\r\r'))
    assert.same({''}, stringx.splitlines('\r\n'))
    assert.same({'ab', 'cd'}, stringx.splitlines('ab\ncd\n'))
    assert.same({'ab\n', 'cd\n'}, stringx.splitlines('ab\ncd\n', true))
    assert.same({'\n', 'ab\r', '\r\n', 'cd\n'}, stringx.splitlines('\nab\r\r\ncd\n', true))
  end)


  it("split()", function()
    local split = stringx.split
    assert.same({''}, split('', ''))
    assert.same({}, split('', 'z')) --FIX:intended and specified behavior?
    assert.same({'a'}, split('a', '')) --FIX:intended and specified behavior?
    assert.same({''}, split('a', 'a'))
    -- stringx.split now follows the Python pattern, so it uses a substring, not a pattern.
    -- If you need to split on a pattern, use utils.split()
    -- asserteq(split('ab1cd23ef%d', '%d+'), {'ab', 'cd', 'ef%d'}) -- pattern chars
    -- note that leading space is ignored by the default
    assert.same({'1','2','3'}, split(' 1  2  3 '))
    assert.same({'a','bb','c','ddd'}, split('a*bb*c*ddd','*'))
    assert.same({'dog','fred','bonzo:alice'}, split('dog:fred:bonzo:alice',':',3))
    assert.same({'dog','fred','bonzo:alice:'}, split('dog:fred:bonzo:alice:',':',3))
    assert.same({'','','',''}, split('///','/'))
  end)


  it("expandtabs()", function()
    assert.equal('', stringx.expandtabs('',0))
    assert.equal('', stringx.expandtabs('',1))
    assert.equal(' ', stringx.expandtabs(' ',1))
    assert.equal((' '):rep(1+8), stringx.expandtabs(' \t '))
    assert.equal((' '):rep(3), stringx.expandtabs(' \t ',2))
    assert.equal((' '):rep(2), stringx.expandtabs(' \t ',0))
    assert.equal('        hi      there   folks!', stringx.expandtabs('\thi\tthere\tfolks!'))
  end)


  it("lfind()", function()
    assert.equal(1, stringx.lfind('', ''))
    assert.equal(1, stringx.lfind('a', ''))
    assert.equal(2, stringx.lfind('ab', 'b'))
    assert.is_nil(stringx.lfind('abc', 'cd'))
    assert.equal(2, stringx.lfind('abcbc', 'bc'))
    assert.equal(3, stringx.lfind('ab..cd', '.')) -- pattern char
    assert.equal(4, stringx.lfind('abcbcbbc', 'bc', 3))
    assert.is_nil(stringx.lfind('abcbcbbc', 'bc', 3, 4))
    assert.equal(4, stringx.lfind('abcbcbbc', 'bc', 3, 5))
    assert.equal(2, stringx.lfind('abcbcbbc', 'bc', nil, 5))
  end)


  it("rfind()", function()
    assert.equal(1, stringx.rfind('', ''))
    assert.equal(3, stringx.rfind('ab', ''))
    assert.is_nil(stringx.rfind('abc', 'cd'))
    assert.equal(4, stringx.rfind('abcbc', 'bc'))
    assert.equal(4, stringx.rfind('abcbcb', 'bc'))
    assert.equal(4, stringx.rfind('ab..cd', '.')) -- pattern char
    assert.equal(7, stringx.rfind('abcbcbbc', 'bc', 3))
    assert.is_nil(stringx.rfind('abcbcbbc', 'bc', 3, 4))
    assert.equal(4, stringx.rfind('abcbcbbc', 'bc', 3, 5))
    assert.equal(4, stringx.rfind('abcbcbbc', 'bc', nil, 5))
    assert.equal(4, stringx.rfind('banana', 'ana'))
  end)


  it("replace()", function()
    assert.equal('', stringx.replace('', '', ''))
    assert.equal(' ', stringx.replace(' ', '', ''))
    assert.equal('   ', stringx.replace(' ', '', ' '))
    assert.equal('', stringx.replace('    ', '  ', ''))
    assert.equal('aBCaBCaBC', stringx.replace('abcabcabc', 'bc', 'BC'))
    assert.equal('aBCabcabc', stringx.replace('abcabcabc', 'bc', 'BC', 1))
    assert.equal('abcabcabc', stringx.replace('abcabcabc', 'bc', 'BC', 0))
    assert.equal('abc', stringx.replace('abc', 'd', 'e'))
    assert.equal('a%db', stringx.replace('a.b', '.', '%d'))
  end)


  it("count()", function()
    assert.equal(0, stringx.count('', '')) --infinite loop]]
    assert.equal(2, stringx.count('  ', '')) --infinite loop]]
    assert.equal(2, stringx.count('a..c', '.')) -- pattern chars
    assert.equal(0, stringx.count('a1c', '%d')) -- pattern chars
    assert.equal(3, stringx.count('Anna Anna Anna', 'Anna')) -- no overlap
    assert.equal(1, stringx.count('banana', 'ana', false)) -- no overlap
    assert.equal(2, stringx.count('banana', 'ana', true)) -- overlap
  end)


  it("ljust()", function()
    assert.equal('', stringx.ljust('', 0))
    assert.equal('  ', stringx.ljust('', 2))
    assert.equal('ab ', stringx.ljust('ab', 3))
    assert.equal('ab%', stringx.ljust('ab', 3, '%'))
    assert.equal('abcd', stringx.ljust('abcd', 3)) -- agrees with Python
  end)


  it("rjust()", function()
    assert.equal('', stringx.rjust('', 0))
    assert.equal('  ', stringx.rjust('', 2))
    assert.equal(' ab', stringx.rjust('ab', 3))
    assert.equal('%ab', stringx.rjust('ab', 3, '%'))
    assert.equal('abcd', stringx.rjust('abcd', 3)) -- agrees with Python
  end)


  it("center()", function()
    assert.equal('', stringx.center('', 0))
    assert.equal(' ', stringx.center('', 1))
    assert.equal('  ', stringx.center('', 2))
    assert.equal('a', stringx.center('a', 1))
    assert.equal('a ', stringx.center('a', 2))
    assert.equal(' a ', stringx.center('a', 3))
  end)


  it("lstrip()", function()
    local trim = stringx.lstrip
    assert.equal('', trim'')
    assert.equal('', trim' ')
    assert.equal('', trim'  ')
    assert.equal('a', trim'a')
    assert.equal('a', trim' a')
    assert.equal('a ', trim'a ')
    assert.equal('a ', trim' a ')
    assert.equal('a  ', trim'  a  ')
    assert.equal('ab cd  ', trim'  ab cd  ')
    assert.equal('a\000b \r\t\n\f\v', trim' \t\r\n\f\va\000b \r\t\n\f\v')
    assert.equal('hello] -- - ', trim(' - -- [hello] -- - ','-[] '))
  end)


  it("rstrip()", function()
    local trim = stringx.rstrip
    assert.equal('', trim'')
    assert.equal('', trim' ')
    assert.equal('', trim'  ')
    assert.equal('a', trim'a')
    assert.equal(' a', trim' a')
    assert.equal('a', trim'a ')
    assert.equal(' a', trim' a ')
    assert.equal('  a', trim'  a  ')
    assert.equal('  ab cd', trim'  ab cd  ')
    assert.equal(' \t\r\n\f\va\000b', trim' \t\r\n\f\va\000b \r\t\n\f\v')
    assert.equal(' - -- [hello', trim(' - -- [hello] -- - ','-[] '))
  end)


  it("strip()", function()
    local trim = stringx.strip
    assert.equal('', trim'')
    assert.equal('', trim' ')
    assert.equal('', trim'  ')
    assert.equal('a', trim'a')
    assert.equal('a', trim' a')
    assert.equal('a', trim'a ')
    assert.equal('a', trim' a ')
    assert.equal('a', trim'  a  ')
    assert.equal('ab cd', trim'  ab cd  ')
    assert.equal('a\000b', trim' \t\r\n\f\va\000b \r\t\n\f\v')
    assert.equal('hello', trim(' - -- [hello] -- - ','-[] '))
    local long = 'a' .. string.rep(' ', 200000) .. 'a'
    assert.equal(long, trim(long))
  end)

  it("splitv()", function()
    -- is actually 'utils.splitv'
    assert.same({"hello", "dolly"}, {stringx.splitv("hello dolly")})
  end)


  it("partition()", function()
    assert.has.error(function()
      stringx.partition('a', '')
    end)
    assert.same({'', 'a', ''}, {stringx.partition('a', 'a')})
    assert.same({'a', 'b', 'c'}, {stringx.partition('abc', 'b')})
    assert.same({'abc','',''}, {stringx.partition('abc', '.+')})
    assert.same({'ab','.','c'}, {stringx.partition('ab.c', '.')})
    assert.same({'a',',','b,c'}, {stringx.partition('a,b,c', ',')})
    assert.same({'abc', '', ''}, {stringx.partition('abc', '/')})
  end)


  it("rpartition()", function()
    assert.has.error(function()
      stringx.rpartition('a', '')
    end)
    assert.same({'a/b', '/', 'c'}, {stringx.rpartition('a/b/c', '/')})
    assert.same({'a', 'b', 'c'}, {stringx.rpartition('abc', 'b')})
    assert.same({'', 'a', ''}, {stringx.rpartition('a', 'a')})
    assert.same({'', '', 'abc'}, {stringx.rpartition('abc', '/')})
  end)


  it("at()", function()
    -- at (works like s:sub(idx,idx), so negative indices allowed
    assert.equal('a', stringx.at('a', 1))
    assert.equal('b', stringx.at('ab', 2))
    assert.equal('d', stringx.at('abcd', -1))
    assert.equal('', stringx.at('abcd', 10))  -- not found
  end)



  describe("indent()", function()

    it("adds an indent", function()
      local t = "a whole lot\nof love"

      assert.equal([[
    a whole lot
    of love
]], stringx.indent(t, 4))

      assert.equal([[
**easy
**
**enough!
]], stringx.indent("easy\n\nenough!", 2 ,'*'))
    end)

    it("appends a newline if not present", function()
      assert.equal("  hello\n  world\n", stringx.indent("hello\nworld", 2))
      assert.equal("  hello\n  world\n", stringx.indent("hello\nworld\n", 2))
    end)

  end)



  describe("dedent()", function()

    it("removes prefixed whitespace", function()
      assert.equal([[
one
two
three
]], stringx.dedent [[
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
]], stringx.dedent [[
      one

     two

    three
]])
    end)

    it("appends a newline if not present", function()
      assert.equal("hello\nworld\n", stringx.dedent("  hello\n  world"))
      assert.equal("hello\nworld\n", stringx.dedent("  hello\n  world\n"))
    end)

  end)




  describe("fill()/wrap()", function()

    it("wraps width over limit", function()
      assert.same({
        "abc",
        "def"
      }, stringx.wrap("abc def", 2))
    end)

    it("wraps width at limit", function()
      assert.same({
        "abc",
        "def"
      }, stringx.wrap("abc def", 3))
      assert.same({
        "a c",
        "d f"
      }, stringx.wrap("a c d f", 3))
    end)

    it("wraps single letters", function()
      assert.same({"a"}, stringx.wrap("a"))
    end)

    it("wraps empty strings", function()
      assert.same({""}, stringx.wrap(""))
      assert.same({""}, stringx.wrap("    "))
    end)

    it("handles leading/trailing whitespace", function()
      assert.same({"hello"}, stringx.wrap("     hello     ", 10))
      assert.same({"hello"}, stringx.wrap("     hello     ", 2))
      assert.same({"he", "ll", "o"}, stringx.wrap("     hello     ", 2, true))
    end)

    it("handles line-breaks", function()
      assert.same({"Hello", "Dolly"}, stringx.wrap("Hello\nDolly", 10))
      assert.same({"Hello Dolly"}, stringx.wrap("Hello\nDolly", 20))
    end)

    it("doesn't split on accented characters", function()
      assert.same({"àbcdéfghîj"}, stringx.wrap("àbcdéfghîj"))
    end)

    it("word-wraps a text", function()
      -- local binstring = require("luassert.formatters.binarystring")
      -- assert:add_formatter(binstring)
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
]], stringx.fill("It is often said of Lua that it does not include batteries. That is because the goal of Lua is to produce a lean expressive language that will be used on all sorts of machines, (some of which don't even have hierarchical filesystems). The Lua language is the equivalent of an operating system kernel; the creators of Lua do not see it as their responsibility to create a full software ecosystem around the language. That is the role of the community.", 20))
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
      }, stringx.wrap(t, 3))
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
      }, stringx.wrap(t, 3, true))
    end)

  end)



  describe("Template", function()

    local Template = stringx.Template


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



  it("lines()", function()
    local function merge(it, ...)
      assert(select('#', ...) == 0)
      local ts = {}
      for val in it do ts[#ts+1] = val end
      return ts
    end
    assert.same({''}, merge(stringx.lines('')))
    assert.same({'ab'}, merge(stringx.lines('ab')))
    assert.same({'ab', 'cd'}, merge(stringx.lines('ab\ncd')))
  end)


  it("title()", function()
    assert.equal('', stringx.title(''))
    assert.equal('Abc Def1', stringx.title('abC deF1')) -- Python behaviour
    assert.equal('Hello World', stringx.capitalize('hello world'))
  end)


  it("capitalize()", function()
    -- old name for 'title'
    assert.equal(stringx.title, stringx.capitalize)
  end)


  it("shorten()", function()
    assert.equal('', stringx.shorten('', 0))
    assert.equal('a', stringx.shorten('a', 1))
    assert.equal('.', stringx.shorten('ab', 1)) --FIX:ok?
    assert.equal('abc', stringx.shorten('abc', 3))
    assert.equal('...', stringx.shorten('abcd', 3))
    assert.equal('abcde', stringx.shorten('abcde', 5))
    assert.equal('a...', stringx.shorten('abcde', 4))
    assert.equal('...', stringx.shorten('abcde', 3))
    assert.equal('..', stringx.shorten('abcde', 2))
    assert.equal('', stringx.shorten('abcde', 0))
    assert.equal('', stringx.shorten('', 0, true))
    assert.equal('a', stringx.shorten('a', 1, true))
    assert.equal('.', stringx.shorten('ab', 1, true))
    assert.equal('abcde', stringx.shorten('abcde', 5, true))
    assert.equal('...e', stringx.shorten('abcde', 4, true))
    assert.equal('...', stringx.shorten('abcde', 3, true))
    assert.equal('..', stringx.shorten('abcde', 2, true))
    assert.equal('', stringx.shorten('abcde', 0, true))
  end)


  it("quote_string()", function()
    local assert_str_round_trip = function(s)

      local qs = stringx.quote_string(s)
      local compiled, err = require("pl.utils").load("return "..qs)

      if not compiled then
        print(
          ("stringx.quote_string assert failed: invalid string created: Received:\n%s\n\nCompiled to\n%s\n\nError:\t%s\n"):
          format(s, qs, err)
        )
        error()
      else
        compiled = compiled()
      end

      if compiled ~= s then
        print("stringx.quote_string assert Failed: String compiled but did not round trip.")
        print("input string:\t\t",s, #s)
        print("compiled string:\t", compiled, #compiled)
        print("output string:\t\t",qs, #qs)
        error()
      -- else
      --   print("input string:\t\t",s)
      --   print("compiled string:\t", compiled)
      --   print("output string:\t\t",qs)
      end
    end

    assert_str_round_trip( "normal string with nothing weird.")
    assert_str_round_trip( "Long string quoted with escaped quote \\\" and a long string pattern match [==[ found near the end.")

    assert_str_round_trip( "Unescapped quote \" in the middle")
    assert_str_round_trip( "[[Embedded long quotes \\\". Escaped must stay! ]]")
    assert_str_round_trip( [[Long quoted string with a slash prior to quote \\\". ]])
    assert_str_round_trip( "[[Completely normal\n long quote. ]]")
    assert_str_round_trip( "String with a newline\nending with a closing bracket]")
    assert_str_round_trip( "[[String with opening brackets ending with part of a long closing bracket]=")
    assert_str_round_trip( "\n[[Completely normal\n long quote. Except that we lead with a return! Tricky! ]]")
    assert_str_round_trip( '"balance [======[ doesn\'t ]====] mater when searching for embedded long-string quotes.')
    assert_str_round_trip( "Any\0 \t control character other than a return will be handled by the %q mechanism.")
    assert_str_round_trip( "This\tincludes\ttabs.")
    assert_str_round_trip( "But not returns.\n Returns are easier to see using long quotes.")
    assert_str_round_trip( "The \z escape does not trigger a control pattern, however.")

    assert_str_round_trip( "[==[If a string is long-quoted, escaped \\\" quotes have to stay! ]==]")
    assert_str_round_trip('"A quoted string looks like what?"')
    assert_str_round_trip( "'I think that it should be quoted, anyway.'")
    assert_str_round_trip( "[[Even if they're long quoted.]]")
    assert_str_round_trip( "]=]==]")

    assert_str_round_trip( "\"\\\"\\' pathalogical:starts with a quote ]\"\\']=]]==][[]]]=========]")
    assert_str_round_trip( "\\\"\\\"\\' pathalogical: quote is after this text with a quote ]\"\\']=]]==][[]]]=========]")
    assert_str_round_trip( "\\\"\\\"\\' pathalogical: quotes are all escaped. ]\\\"\\']=]]==][[]]]=========]")
    assert_str_round_trip( "")
    assert_str_round_trip( " ")
    assert_str_round_trip( "\n") --tricky.
    assert_str_round_trip( "\r")
    assert_str_round_trip( "\r\n")
    assert_str_round_trip( "\r1\n")
    assert_str_round_trip( "[[")
    assert_str_round_trip( "''")
    assert_str_round_trip( '""')
  end)



  describe("format_operator()", function()

    setup(function()
      stringx.format_operator()
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

