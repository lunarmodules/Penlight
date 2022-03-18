package = "penlight"
version = "1.9.1-2"

source = {
  url = "git+https://github.com/lunarmodules/Penlight.git",
  tag = "1.9.1"
}

description = {
  summary = "Lua utility libraries loosely based on the Python standard libraries",
  homepage = "https://lunarmodules.github.io/Penlight",
  license = "MIT/X11",
  maintainer = "thijs@thijsschreijer.nl",
  detailed = [[
Penlight is a set of pure Lua libraries for making it easier to work with common tasks like
iterating over directories, reading configuration files and the like. Provides functional operations
on tables and sequences.
]]
}

dependencies = {
  "luafilesystem",
}

build = {
  type = "builtin",
  modules = {
    ["pl.strict"] = "lua/pl/strict.lua",
    ["pl.dir"] = "lua/pl/dir.lua",
    ["pl.operator"] = "lua/pl/operator.lua",
    ["pl.input"] = "lua/pl/input.lua",
    ["pl.config"] = "lua/pl/config.lua",
    ["pl.compat"] = "lua/pl/config.lua",
    ["pl.seq"] = "lua/pl/seq.lua",
    ["pl.stringio"] = "lua/pl/stringio.lua",
    ["pl.text"] = "lua/pl/text.lua",
    ["pl.test"] = "lua/pl/test.lua",
    ["pl.tablex"] = "lua/pl/tablex.lua",
    ["pl.app"] = "lua/pl/app.lua",
    ["pl.stringx"] = "lua/pl/stringx.lua",
    ["pl.lexer"] = "lua/pl/lexer.lua",
    ["pl.utils"] = "lua/pl/utils.lua",
    ["pl.sip"] = "lua/pl/sip.lua",
    ["pl.permute"] = "lua/pl/permute.lua",
    ["pl.pretty"] = "lua/pl/pretty.lua",
    ["pl.class"] = "lua/pl/class.lua",
    ["pl.List"] = "lua/pl/List.lua",
    ["pl.data"] = "lua/pl/data.lua",
    ["pl.Date"] = "lua/pl/Date.lua",
    ["pl.init"] = "lua/pl/init.lua",
    ["pl.luabalanced"] = "lua/pl/luabalanced.lua",
    ["pl.comprehension"] = "lua/pl/comprehension.lua",
    ["pl.path"] = "lua/pl/path.lua",
    ["pl.array2d"] = "lua/pl/array2d.lua",
    ["pl.func"] = "lua/pl/func.lua",
    ["pl.lapp"] = "lua/pl/lapp.lua",
    ["pl.file"] = "lua/pl/file.lua",
    ['pl.template'] = "lua/pl/template.lua",
    ["pl.Map"] = "lua/pl/Map.lua",
    ["pl.MultiMap"] = "lua/pl/MultiMap.lua",
    ["pl.OrderedMap"] = "lua/pl/OrderedMap.lua",
    ["pl.Set"] = "lua/pl/Set.lua",
    ["pl.xml"] = "lua/pl/xml.lua",
    ["pl.url"] = "lua/pl/url.lua",
    ["pl.import_into"] = "lua/pl/import_into.lua",
    ["pl.types"] = "lua/pl/types.lua",
  },
  copy_directories = {"docs", "tests"}
}

