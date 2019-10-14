# Penlight Lua Libraries

[![Build Status](https://travis-ci.org/Tieske/Penlight.svg?branch=master)](https://travis-ci.org/Tieske/Penlight)
[![Coverage Status](https://coveralls.io/repos/github/Tieske/Penlight/badge.svg?branch=master)](https://coveralls.io/github/Tieske/Penlight?branch=master)
[![AppVeyor status](https://ci.appveyor.com/api/projects/status/d59xoj32dbiylaq3/branch/master?svg=true)](https://ci.appveyor.com/project/Tieske/penlight/branch/master)

## Why a new set of libraries?

Penlight brings together a set of generally useful pure Lua modules,
focusing on input data handling (such as reading configuration files),
functional programming (such as map, reduce, placeholder expressions, etc),
and OS path management.  Much of the functionality is inspired by the
Python standard libraries.

## Module Overview

### Paths, Files and Directories

  * `path`: queries like `isdir`,`isfile`,`exists`, splitting paths like `dirname` and `basename`
  * `dir`: listing files in directories (`getfiles`,`getallfiles`) and creating/removing directory paths
  * `file`: `copy`,`move`; read/write contents with `read` and `write`

### Application Support

  * `app`: `require_here` to rebase `require` to work with main script path; simple argument parsing `parse_args`
  * `lapp`: sophisticated usage-text-driven argument parsing for applications
  * `config`: flexibly read Unix config files and Windows INI files
  * `strict`: check for undefined global variables - can use `strict.module` for modules
  * `utils`,`compat`: Penlight support for unified Lua 5.1/5.2 codebases
  * `types`: predicates like `is_callable` and `is_integer`; extended `type` function.

### Extra String Operations

  * `utils`: can split a string with a delimiter using `utils.split`
  * `stringx`: extended string functions covering the Python `string` type
  * `stringio`:  open strings for reading, and creating strings using standard Lua IO methods
  * `lexer`:  lexical scanner for splitting text into tokens; special cases for Lua and C
  * `text`:  indenting and dedenting text, wrapping paragraphs; optionally make `%` work as in Python
  * `template`:  small but powerful template expansion engine
  * `sip`:  Simple Input Patterns - higher-level string patterns for parsing text

### Extra Table Operations

  * `tablex`: copying, comparing and mapping over
  * `pretty`: pretty-printing Lua tables, and various safe ways to load Lua as data
  * `List`: implementation of Python 'list' type - slices, concatenation and partitioning
  * `Map`, `Set`, `OrderedMap`: classes for specialized kinds of tables
  * `data`: reading tabular data into 2D arrays and efficient queries
  * `array2d`: operations on 2D arrays
  * `permute`: generate permutations

### Iterators, OOP and Functional

   * `seq`:  working with iterator pipelines; collecting iterators as tables
   * `class`: a simple reusable class framework
   * `func`: symbolic manipulation of expressions and lambda expressions
   * `utils`: `utils.string_lambda` converts short strings like '|x| x^2' into functions
   * `comprehension`: list comprehensions: `C'x for x=1,4'()=={1,2,3,4}`

## License

Penlight is distributed under the [MIT license](https://github.com/Tieske/Penlight/blob/master/LICENSE.md)

## Installation

Using [LuaRocks](https://luarocks.org): simply run `luarocks install penlight`.

Manually: copy `lua/pl` directory into your Lua module path. It's typically
`/usr/local/share/lua/5.x` on a Linux system and `C:\Program Files\Lua\5.x\lua`
for Lua for Windows.

## Dependencies

The file and directory functions depend on [LuaFileSystem](https://keplerproject.github.io/luafilesystem/),
which is installed automatically if you are using LuaRocks. Additionally, if you want `dir.copyfile` to work
elegantly on Windows, then you need [Alien](http://mascarenhas.github.io/alien/). Both libraries are present
in Lua for Windows.

## Building the Documentation

Requires [ldoc](https://github.com/stevedonovan/LDoc), which is available
through LuaRocks.  Then it's a simple matter of running `ldoc .` from the repo.

## Contributing

Contributions are most welcome, please check the [contribution guidelines](https://github.com/Tieske/Penlight/blob/master/CONTRIBUTING.md).

## Running tests

Execute `lua run.lua tests` to run the tests. Execute `lua run.lua examples` to run examples.

## History

For a complete history of the development of Penlight, please check the
[changelog](https://github.com/Tieske/Penlight/blob/master/CHANGELOG.md).
