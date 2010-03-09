package = "penlight"
version = "0.8-1"

source = {
  dir = "penlight-0.8",
  url = "http://yoururl/pl-0.8.zip",
}

description = {
  summary = "short sentence about this package",
  homepage = "package homepage",
  license = "MIT/X11",
  maintainer = "your email",
  detailed = [[
paragraph about this package
]]
}

dependencies = {
  "luafilesystem",
}

build = {
  modules = {
    ["pl.strict"] = "lua/pl/strict.lua",
    ["pl.dir"] = "lua/pl/dir.lua",
    ["pl.classx"] = "lua/pl/classx.lua",
    ["pl.operator"] = "lua/pl/operator.lua",
    ["pl.input"] = "lua/pl/input.lua",
    ["pl.compat52"] = "lua/pl/compat52.lua",
    ["pl.config"] = "lua/pl/config.lua",
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
    ["pl.list"] = "lua/pl/list.lua",
    ["pl.data"] = "lua/pl/data.lua",
    ["pl"] = "lua/pl/init.lua",
    ["pl.luabalanced"] = "lua/pl/luabalanced.lua",
    ["pl.comprehension"] = "lua/pl/comprehension.lua",
    ["pl.path"] = "lua/pl/path.lua",
    ["pl.array2d"] = "lua/pl/array2d.lua",
    ["pl.func"] = "lua/pl/func.lua",
    ["pl.lapp"] = "lua/pl/lapp.lua",
    ["pl.file"] = "lua/pl/file.lua",
  },
  type = "module",
  copy_directories = {
    "docs",
    "tests",
    "examples",
  }
}

