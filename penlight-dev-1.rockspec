local package_name = "penlight"
local package_version = "dev"
local rockspec_revision = "1"
local github_account_name = "lunarmodules"
local github_repo_name = package_name
local git_checkout = package_version == "dev" and "master" or package_version


rockspec_format = "3.0"
package = package_name
version = package_version .. "-" .. rockspec_revision

source = {
  url = "git+https://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = git_checkout
}

description = {
  summary = "Lua utility libraries loosely based on the Python standard libraries",
  detailed = [[
      Penlight is a set of pure Lua libraries focusing on input data handling
      (such as reading configuration files), functional programming
      (such as map, reduce, placeholder expressions,etc), and OS path management.
      Much of the functionality is inspired by the Python standard libraries.
    ]],
  license = "MIT/X11",
  homepage = "https://"..github_account_name..".github.io/"..github_repo_name,
  issues_url = "https://github.com/"..github_account_name.."/"..github_repo_name.."/issues",
  maintainer = "thijs@thijsschreijer.nl",
}

dependencies = {
  "lua >= 5.1",
  "luafilesystem"
}

test_dependencies = {
  "busted",
}

test = {
  type = "busted",
}

build = {
  type = "builtin",
  modules = {
    ["pl"] = "lua/pl/init.lua",
    ["pl.app"] = "lua/pl/app.lua",
    ["pl.array2d"] = "lua/pl/array2d.lua",
    ["pl.class"] = "lua/pl/class.lua",
    ["pl.compat"] = "lua/pl/compat.lua",
    ["pl.comprehension"] = "lua/pl/comprehension.lua",
    ["pl.config"] = "lua/pl/config.lua",
    ["pl.data"] = "lua/pl/data.lua",
    ["pl.Date"] = "lua/pl/Date.lua",
    ["pl.dir"] = "lua/pl/dir.lua",
    ["pl.file"] = "lua/pl/file.lua",
    ["pl.func"] = "lua/pl/func.lua",
    ["pl.import_into"] = "lua/pl/import_into.lua",
    ["pl.input"] = "lua/pl/input.lua",
    ["pl.lapp"] = "lua/pl/lapp.lua",
    ["pl.lexer"] = "lua/pl/lexer.lua",
    ["pl.List"] = "lua/pl/List.lua",
    ["pl.luabalanced"] = "lua/pl/luabalanced.lua",
    ["pl.Map"] = "lua/pl/Map.lua",
    ["pl.MultiMap"] = "lua/pl/MultiMap.lua",
    ["pl.operator"] = "lua/pl/operator.lua",
    ["pl.OrderedMap"] = "lua/pl/OrderedMap.lua",
    ["pl.path"] = "lua/pl/path.lua",
    ["pl.permute"] = "lua/pl/permute.lua",
    ["pl.pretty"] = "lua/pl/pretty.lua",
    ["pl.Set"] = "lua/pl/Set.lua",
    ["pl.seq"] = "lua/pl/seq.lua",
    ["pl.sip"] = "lua/pl/sip.lua",
    ["pl.strict"] = "lua/pl/strict.lua",
    ["pl.stringio"] = "lua/pl/stringio.lua",
    ["pl.stringx"] = "lua/pl/stringx.lua",
    ["pl.tablex"] = "lua/pl/tablex.lua",
    ["pl.template"] = "lua/pl/template.lua",
    ["pl.test"] = "lua/pl/test.lua",
    ["pl.text"] = "lua/pl/text.lua",
    ["pl.types"] = "lua/pl/types.lua",
    ["pl.url"] = "lua/pl/url.lua",
    ["pl.utils"] = "lua/pl/utils.lua",
    ["pl.xml"] = "lua/pl/xml.lua",
  },
  copy_directories = {"docs", "tests"}
}
