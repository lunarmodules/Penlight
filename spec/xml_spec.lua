local xml = require "pl.xml"

describe("xml", function()

  describe("new()", function()

    it("creates a new xml-document", function()
      local doc = xml.new("main")
      assert.equal("<main/>", doc:tostring())
    end)


    it("fails without a tag", function()
      assert.has.error(function()
        xml.new()
      end, "expected 'tag' to be a string value, got: nil")
    end)


    it("fails with bad attributes", function()
      assert.has.error(function()
        xml.new("tag", "not a table...")
      end, "expected 'attr' to be a table value, got: string")
    end)


    it("adds attributes if given", function()
      local doc = xml.new("main", { hello = "world" })
      assert.equal("<main hello='world'/>", doc:tostring())
    end)

  end)



  describe("parse()", function()

    pending("todo", function()
      -- TODO: implement
    end)

  end)



  describe("elem()", function()

    it("creates a node", function()
      local doc = xml.elem("main")
      assert.equal("<main/>", doc:tostring())
    end)


    it("creates a node, with single text element", function()
      local doc = xml.elem("main", "oh my")
      assert.equal("<main>oh my</main>", doc:tostring())
    end)


    it("creates a node, with single child tag/Node", function()
      local doc = xml.elem("main", xml.new("child"))
      assert.equal("<main><child/></main>", doc:tostring())
    end)


    it("creates a node, with multiple text elements", function()
      local doc = xml.elem("main", { "this ", "is ", "nice" })
      assert.equal("<main>this is nice</main>", doc:tostring())
    end)


    it("creates a node, with multiple child tags/Nodes", function()
      local doc = xml.elem("main", { xml.new "this", xml.new "is", xml.new "nice" })
      assert.equal("<main><this/><is/><nice/></main>", doc:tostring())
    end)


    it("creates a node, with attributes", function()
      local doc = xml.elem("main", { hello = "world" })
      assert.equal("<main hello='world'/>", doc:tostring())
    end)


    it("creates a node, with text/Node children and attributes", function()
      local doc = xml.elem("main", {
        "prefix",
        xml.elem("child", { "this ", "is ", "nice"}),
        "postfix",
        attrib = "value"
      })
      assert.equal("<main attrib='value'>prefix<child>this is nice</child>postfix</main>", doc:tostring())
    end)


    it("creates a node, with text/Node nested children and attributes", function()
      local doc = xml.elem("main", {
        "prefix",
        xml.elem("child", {
          "this",
          xml.elem "is",
          "nice",
        }),
        "postfix",
        attrib = "value"
      })
      assert.equal("<main attrib='value'>prefix<child>this<is/>nice</child>postfix</main>", doc:tostring())
    end)

  end)



  describe("tags()", function()

    it("creates constructors", function()
      local parent, child = xml.tags({ "mom" , "kid" })
      local doc = parent {child 'Bob', child 'Annie'}
      assert.equal("<mom><kid>Bob</kid><kid>Annie</kid></mom>", doc:tostring())
    end)


    it("creates constructors from CSV values", function()
      local parent, child = xml.tags("mom,kid" )
      local doc = parent {child 'Bob', child 'Annie'}
      assert.equal("<mom><kid>Bob</kid><kid>Annie</kid></mom>", doc:tostring())
    end)


    it("creates constructors from CSV values, ignores surrounding whitespace", function()
      local parent, child = xml.tags(" mom , kid " )
      local doc = parent {child 'Bob', child 'Annie'}
      assert.equal("<mom><kid>Bob</kid><kid>Annie</kid></mom>", doc:tostring())
    end)

  end)



  describe("addtag()", function()

    it("adds a Node", function()
      local doc = xml.new("main")
      doc:addtag("penlight", { hello = "world" })
      assert.equal("<main><penlight hello='world'/></main>", doc:tostring())

      -- moves position
      doc:addtag("expat")
      assert.equal("<main><penlight hello='world'><expat/></penlight></main>", doc:tostring())
    end)

  end)



  describe("text()", function()

    it("adds text", function()
      local doc = xml.new("main")
      doc:text("penlight")
      assert.equal("<main>penlight</main>", doc:tostring())

      -- moves position
      doc:text("expat")
      assert.equal("<main>penlightexpat</main>", doc:tostring())
    end)

  end)



  describe("up()", function()

    it("moves position up 1 level", function()
      local doc = xml.new("main")
      doc:addtag("one")
      doc:addtag("two-a")
      doc:up()
      doc:addtag("two-b")
      assert.equal("<main><one><two-a/><two-b/></one></main>", doc:tostring())

      -- doesn't move beyond top level
      for i = 1, 10 do
        doc:up()
      end
      doc:addtag("solong")
      assert.equal("<main><one><two-a/><two-b/></one><solong/></main>", doc:tostring())
    end)

  end)



  describe("reset()", function()

    it("resets position to top Node", function()
      local doc = xml.new("main")
      doc:addtag("one")
      doc:addtag("two")
      doc:addtag("three")
      doc:reset()
      doc:addtag("solong")
      assert.equal("<main><one><two><three/></two></one><solong/></main>", doc:tostring())
    end)

  end)



  describe("add_direct_child", function()

    it("adds a child node", function()
      local doc = xml.new("main")
      doc:add_direct_child(xml.new("child"))
      assert.equal("<main><child/></main>", doc:tostring())

      doc:add_direct_child(xml.new("child"))
      assert.equal("<main><child/><child/></main>", doc:tostring())
    end)


    it("adds a text node", function()
      local doc = xml.new("main")
      doc:add_direct_child("child")
      assert.equal("<main>child</main>", doc:tostring())

      doc:add_direct_child("child")
      assert.equal("<main>childchild</main>", doc:tostring())
    end)

  end)



  describe("add_child()", function()

    it("adds a child at the current position", function()
      local doc = xml.new("main")
      doc:addtag("one")
      doc:add_child(xml.new("item1"))
      doc:add_child(xml.new("item2"))
      doc:add_child(xml.new("item3"))
      assert.equal("<main><one><item1/><item2/><item3/></one></main>", doc:tostring())
    end)

  end)



  describe("set_attribs()", function()

    it("sets attributes on the Node", function()
      local doc = xml.new("main")
      doc:addtag("one") -- moves position


      doc:set_attribs( { one = "a" })
      assert.equal("<main one='a'><one/></main>", doc:tostring())

      -- overwrites and adds
      doc:set_attribs( { one = "1", two = "2" })
      assert.matches("one='1'", doc:tostring())
      assert.matches("two='2'", doc:tostring())

      -- 'two' doesn't get removed
      doc:set_attribs( { one = "a" })
      assert.matches("one='a'", doc:tostring())
      assert.matches("two='2'", doc:tostring())
    end)

  end)



  describe("set_attrib()", function()

    it("sets/deletes a single attribute on the Node", function()
      local doc = xml.new("main")
      doc:addtag("one") -- moves position


      doc:set_attrib("one", "a")
      assert.equal("<main one='a'><one/></main>", doc:tostring())

      -- deletes
      doc:set_attrib("one", nil)
      assert.equal("<main><one/></main>", doc:tostring())
    end)

  end)



  describe("get_attribs()", function()

    it("gets attributes on the Node", function()
      local doc = xml.new("main")
      doc:addtag("one") -- moves position

      doc:set_attribs( { one = "1", two = "2" })
      assert.same({ one = "1", two = "2" }, doc:get_attribs())
    end)

  end)



  describe("subst()", function()

    pending("todo", function()
      -- TODO: implement
    end)

  end)



  describe("child_with_name()", function()

    it("returns the first child", function()
      local doc = xml.new("main")
      doc:add_child(xml.elem "one")
      doc:text("hello")
      doc:add_child(xml.elem "two")
      doc:text("goodbye")
      doc:add_child(xml.elem "three")

      local child = doc:child_with_name("two")
      assert.not_nil(child)
      assert.equal(doc[3], child)
    end)

  end)



  describe("tostring()", function()

    pending("todo still...", function()
      -- TODO: implement
    end)

  end)



  describe("get_elements_with_name()", function()

    it("returns matching nodes", function()
      local doc = assert(xml.parse[[
        <person>
          <name>John</name>
          <children>
            <person>
              <name>Bob</name>
              <children>
                <person>
                  <name>Bob junior</name>
                </person>
              </children>
            </person>
            <person>
              <name>Annie</name>
              <children>
                <person>
                  <name>Melissa</name>
                </person>
                <person>
                  <name>Noel</name>
                </person>
              </children>
            </person>
          </children>
        </person>
      ]])

      local list = doc:get_elements_with_name("name")
      for i, entry in ipairs(list) do
        list[i] = entry:get_text()
      end
      assert.same({"John", "Bob", "Bob junior", "Annie", "Melissa", "Noel"}, list)

      -- if tag not found, returns empty table
      local list = doc:get_elements_with_name("unknown")
      assert.same({}, list)
    end)

  end)



  describe("children()", function()

    it("iterates over all children", function()
      local doc = xml.elem("main", {
        "prefix",
        xml.elem("child"),
        "postfix",
        attrib = "value"
      })

      local lst = {}
      for node in doc:children() do
        lst[#lst+1] = tostring(node)
      end
      assert.same({ "prefix", "<child/>", "postfix"}, lst)
    end)


    it("doesn't fail on empty node", function()
      local doc = xml.elem("main")
      local lst = {}
      for node in doc:children() do
        lst[#lst+1] = tostring(node)
      end
      assert.same({}, lst)
    end)

  end)



  describe("first_childtag()", function()

    it("returns first non-text tag", function()
      local doc = xml.elem("main", {
        "prefix",
        xml.elem("child"),
        "postfix",
        attrib = "value"
      })

      local node = doc:first_childtag()
      assert.same("<child/>", tostring(node))
    end)


    it("returns nil if there is none", function()
      local doc = xml.elem("main", {
        "prefix",
        "postfix",
        attrib = "value"
      })

      local node = doc:first_childtag()
      assert.is_nil(node)
    end)

  end)



  describe("matching_tags()", function()

    local _ = [[
      <root xmlns:h="http://www.w3.org/TR/html4/"
            xmlns:f="https://www.w3schools.com/furniture">

      <h:table>
        <h:tr>
          <h:td>Apples</h:td>
          <h:td>Bananas</h:td>
        </h:tr>
      </h:table>

      <f:table>
        <f:name>African Coffee Table</f:name>
        <f:width>80</f:width>
        <f:length>120</f:length>
      </f:table>

      </root>
    ]]

    pending("xmlns is weird...", function()
      -- the xmlns stuff doesn't make sense
    end)

  end)



  describe("childtags()", function()

    it("returns the first child", function()
      local doc = xml.new("main")
      doc:add_child(xml.elem "one")
      doc:text("hello")
      doc:add_child(xml.elem "two")
      doc:text("goodbye")
      doc:add_child(xml.elem "three")

      local lst = {}
      for node in doc:childtags() do
        lst[#lst+1] = tostring(node)
      end
      assert.same({"<one/>", "<two/>", "<three/>"},lst)
    end)

  end)



  describe("maptags()", function()

    it("updates nodes", function()
      local doc = xml.new("main")
      doc:add_child(xml.elem "one")
      doc:text("hello")
      doc:add_child(xml.elem "two")
      doc:text("goodbye")
      doc:add_child(xml.elem "three")

      doc:maptags(function(node)
        if node.tag then
          -- return a new object so we know it got replaced
          return xml.new(node.tag:upper())
        end
        return node
      end)
      assert.same("<main><ONE/>hello<TWO/>goodbye<THREE/></main>", doc:tostring())
    end)


    it("removes nodes", function()
      local doc = xml.new("main")
      doc:add_child(xml.elem "one")
      doc:text("hello")
      doc:add_child(xml.elem "two")
      doc:text("goodbye")
      doc:add_child(xml.elem "three")

      doc:maptags(function(node)
        if node.tag then
          return nil -- remove it
        end
        return node
      end)
      assert.same("<main>hellogoodbye</main>", doc:tostring())
    end)

  end)



  describe("xml_escape()", function()

    it("escapes reserved characters", function()
      local esc = xml.xml_escape([["'<>&]])
      assert.same("&quot;&apos;&lt;&gt;&amp;", esc)
    end)


    it("escapes non-printable characters as \\xHH", function()
      -- Test null byte
      local esc = xml.xml_escape("hello\x00world")
      assert.same("hello\\x00world", esc)

      -- Test control characters
      local esc2 = xml.xml_escape("\x01\x02\x03")
      assert.same("\\x01\\x02\\x03", esc2)

      -- Test DEL character
      local esc3 = xml.xml_escape("test\x7Fend")
      assert.same("test\\x7Fend", esc3)
    end)


    it("preserves tab, newline, carriage return", function()
      local esc = xml.xml_escape("hello\tworld\n")
      assert.same("hello\tworld\n", esc)

      local esc2 = xml.xml_escape("line1\r\nline2")
      assert.same("line1\r\nline2", esc2)
    end)


    it("escapes high ASCII characters (127-255)", function()
      -- Only DEL (127) should be escaped, high bytes (128-255) are preserved for UTF-8
      local esc = xml.xml_escape("test\x7F")
      assert.same("test\\x7F", esc)

      -- High bytes preserved
      local esc2 = xml.xml_escape("test\x80\xFF")
      assert.same("test\x80\xFF", esc2)
    end)


    it("handles mixed content with both special and non-printable chars", function()
      local esc = xml.xml_escape("hello\x00<tag>&\x01world")
      assert.same("hello\\x00&lt;tag&gt;&amp;\\x01world", esc)
    end)


    it("handles UTF-8 text correctly", function()
      -- UTF-8 multi-byte characters should be preserved (not escaped)
      local esc = xml.xml_escape("你好世界")
      assert.same("你好世界", esc)

      local esc2 = xml.xml_escape("hello 世界 <tag>")
      assert.same("hello 世界 &lt;tag&gt;", esc2)
    end)


    it("handles empty string", function()
      local esc = xml.xml_escape("")
      assert.same("", esc)
    end)


    it("handles string with only printable characters", function()
      local esc = xml.xml_escape("Hello World 123!")
      assert.same("Hello World 123!", esc)
    end)


    it("escapes binary data in text nodes", function()
      local doc = xml.new("data")
      doc:text("\x00\x01\x02\x7F")
      assert.same("<data>\\x00\\x01\\x02\\x7F</data>", doc:tostring())
    end)


    it("escapes binary data in attributes", function()
      local doc = xml.new("data", { content = "hello\x00world" })
      assert.same("<data content='hello\\x00world'/>", doc:tostring())
    end)


    it("handles real binary data from file operations", function()
      -- Simulate reading binary file data (PNG header signature)
      local png_header = string.char(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
      local esc = xml.xml_escape(png_header)
      -- 0x0D (CR) and 0x0A (LF) are preserved, others escaped
      assert.same("\x89PNG\\x0D\n\\x1A\n", esc)
    end)


    it("handles binary integers as bytes", function()
      -- Pack 32-bit integer (little-endian)
      local binary = string.char(0xEF, 0xBE, 0xAD, 0xDE)  -- 0xDEADBEEF
      local esc = xml.xml_escape(binary)
      assert.same("\\xEF\\xBE\\xAD\\xDE", esc)
    end)


    it("handles null-terminated C strings", function()
      local cstring = "Hello\x00World\x00"
      local esc = xml.xml_escape(cstring)
      assert.same("Hello\\x00World\\x00", esc)
    end)


    it("handles raw byte sequences", function()
      -- Create a string with all control characters
      local controls = ""
      for i = 0, 31 do
        if i ~= 9 and i ~= 10 and i ~= 13 then  -- except tab, LF, CR
          controls = controls .. string.char(i)
        end
      end
      local esc = xml.xml_escape(controls)
      -- Should contain \x00, \x01, ..., \x08, \x0B, \x0C, \x0E, ..., \x1F
      assert.is_true(esc:match("\\x00") ~= nil)
      assert.is_true(esc:match("\\x01") ~= nil)
      assert.is_true(esc:match("\\x1F") ~= nil)
      -- Should not contain literal control chars
      assert.is_false(esc:match("\x00") ~= nil)
    end)


    it("handles mixed binary and text content", function()
      -- Simulate a data structure with magic number + text
      local magic = string.char(0xCA, 0xFE, 0xBA, 0xBE)  -- Java class file magic
      local data = magic .. "MyClass"
      local esc = xml.xml_escape(data)
      assert.same("\\xCA\\xFE\\xBA\\xBEMyClass", esc)
    end)

  end)



  describe("xml_unescape()", function()

    it("escapes reserved characters", function()
      local unesc = xml.xml_unescape("&quot;&apos;&lt;&gt;&amp;")
      assert.same([["'<>&]], unesc)
    end)

  end)



  describe("get_text()", function()

    it("returns all text concatenated", function()
      local doc = xml.new("main")
      doc:text("one")
      doc:add_child(xml.elem "two")
      doc:text("three")

      assert.same("onethree", doc:get_text())
    end)

    it("returns empty string if no text", function()
      local doc = xml.new("main")
      doc:add_child(xml.elem "two")

      assert.same("", doc:get_text())
    end)

  end)



  describe("clone()", function()

    it("clones a document", function()
      local doc1 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      local doc2 = xml.clone(doc1)
      assert.are.same(doc1:tostring(), doc2:tostring())
      assert.not_equal(doc1, doc2)
      for i, elem1 in ipairs(doc1) do
        assert.are.same(tostring(elem1), tostring(doc2[i]))
        if type(elem1) == "table" then
          assert.not_equal(elem1, doc2[i])
        end
      end
    end)


    it("calls substitution callback and updates", function()
      local doc1 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      local repl = {
        ["*TAG"] = {
          main = "top",
          this = "that",
          is = "was",
          a = "a",
          b = "b",
          nice = "bad",
        },
        ["*TEXT"] = {
          ["this content"] = "that content",
        },
        hello = {
          world = "universe",
        },
      }
      local subst = function(object, kind, parent)
        if repl[kind] then
          if repl[kind][object] then
            return repl[kind][object]
          else
            error(("object '%s' of kind '%s' not found"):format(object,kind))
          end
        else
          error(("kind '%s' not found"):format(kind))
        end
      end

      local doc2 = xml.clone(doc1, subst)
      assert.equal("<top hello='universe'><that>that content</that><was><a/><b/></was><bad/></top>", doc2:tostring())
    end)


    it("clones text nodes", function()
      assert.equal("hello", xml.clone("hello"))
    end)


    it("errors on recursion", function()
      local doc = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        "some",
        xml.elem "is",
        "text",
        xml.elem "nice",
      })

      doc[#doc+1] = doc -- add recursion

      assert.has.error(function()
        xml.clone(doc)
      end, "recursion detected")
    end)

  end)



  describe("compare()", function()

    it("returns true on equal docs", function()
      local doc1 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      local doc2 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      local ok, err = xml.compare(doc1, doc2)
      assert.is_nil(err)
      assert.is_true(ok)
    end)


    it("compares types", function()
      local ok, err = xml.compare(nil, true)
      assert.equal("type mismatch", err)
      assert.is_false(ok)

      local ok, err = xml.compare("true", true)
      assert.equal("type mismatch", err)
      assert.is_false(ok)

      local ok, err = xml.compare(true, true)
      assert.equal("not a document", err)
      assert.is_false(ok)

      local ok, err = xml.compare("text", "text")
      assert.is_nil(err)
      assert.is_true(ok)

      local ok, err = xml.compare("text1", "text2")
      assert.equal("text text1 ~= text text2", err)
      assert.is_false(ok)
    end)


    it("compares element size (array part)", function()
      local doc1 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      local doc2 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
        "plain text",
      })

      local ok, err = xml.compare(doc1, doc2)
      assert.equal("size 3 ~= size 4 for tag main", err)
      assert.is_false(ok)
    end)


    it("compares children", function()
      local doc1 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      local doc2 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "c"
        }),
        xml.elem "nice",
      })

      local ok, err = xml.compare(doc1, doc2)
      assert.equal("tag  b ~= tag c", err)
      assert.is_false(ok)
    end)


    it("compares attributes", function()
      local doc1 = xml.new("main", {
        hello = "world",
        goodbye = "universe"
      })

      local ok, err = xml.compare(doc1, xml.new("main", {
        hello = "world",
        goodbye = "universe"
      }))
      assert.equal(nil, err)
      assert.is_true(ok)

      local ok, err = xml.compare(doc1, xml.new("main", {
        -- hello = "world",  -- one less attribute
        goodbye = "universe"
      }))
      assert.equal("mismatch attrib", err)
      assert.is_false(ok)

      local ok, err = xml.compare(doc1, xml.new("main", {
        hello = "world",
        goodbye = "universe",
        one = "more", -- one more attribute
      }))
      assert.equal("mismatch attrib", err)
      assert.is_false(ok)
    end)


    it("compares attributes order", function()
      local doc1 = xml.new("main", {
        [1] = "hello",
        [2] = "goodbye",
        hello = "world",
        goodbye = "universe"
      })

      local ok, err = xml.compare(doc1, xml.new("main", {
        -- no order, this compares ok
        hello = "world",
        goodbye = "universe"
      }))
      assert.equal(nil, err)
      assert.is_true(ok)

      local ok, err = xml.compare(doc1, xml.new("main", {
        [2] = "hello",  -- order reversed, this should fail
        [1] = "goodbye",
        hello = "world",
        goodbye = "universe"
      }))
      assert.equal("mismatch attrib order", err)
      assert.is_false(ok)
    end)


    it("handles recursion", function()
      local doc1 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      local doc2 = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        xml.elem("is", {
          xml.elem "a",
          xml.elem "b"
        }),
        xml.elem "nice",
      })

      doc1[#doc1 + 1] = doc1  -- add recursion
      doc2[#doc2 + 1] = xml.elem "main"  -- add tag by same name

      local ok, err = xml.compare(doc1, doc2)
      assert.equal("recursive document", err)
      assert.is_false(ok)
    end)

  end)



  describe("walk()", function()

    it("calls on all tags", function()
      local doc = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        "some",
        xml.elem "is",
        "text",
        xml.elem "nice",
      })

      assert.equal("<main hello='world'><this>this content</this>some<is/>text<nice/></main>", doc:tostring())

      local list = {}
      xml.walk(doc, nil, function(tag_name, node)
        list[#list+1] = assert(tag_name)
      end)
      assert.same({"main", "this", "is", "nice"}, list)

      -- now depth_first
      local list = {}
      xml.walk(doc, true, function(tag_name, node)
        list[#list+1] = assert(tag_name)
      end)
      assert.same({"this", "is", "nice", "main"}, list)
    end)


    it("errors on recursion", function()
      local doc = xml.elem("main", {
        hello = "world",
        xml.elem("this", "this content"),
        "some",
        xml.elem "is",
        "text",
        xml.elem "nice",
      })

      doc[#doc+1] = doc -- add recursion

      assert.has.error(function()
        xml.walk(doc, nil, function() end)
      end, "recursion detected")
    end)

  end)



  describe("parsehtml()", function()

    pending("to be deprecated...", function()
      -- TODO: implement
    end)

  end)



  describe("basic_parse()", function()

    pending("to be deprecated...", function()
      -- TODO: implement
    end)

  end)



  describe("match()", function()

    pending("figure out what it does...", function()
      -- TODO: implement
    end)

  end)

end)

