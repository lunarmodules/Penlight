package = "penlight"
version = "scm-1"

source = {
  url = "git://github.com/stevedonovan/Penlight.git",
}

description = {
  summary = "Lua utility libraries loosely based on the Python standard libraries",
  homepage = "http://stevedonovan.github.com/Penlight",
  license = "MIT/X11",
  maintainer = "steve.j.donovan@gmail.com",
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
  copy_directories = { "lua/pl" },
  type = "none",
}
