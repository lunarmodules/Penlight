# Changelog

Versioning is strictly according to [Semantic Versioning](https://semver.org/),
see the [README.md](README.md#versioning) for details on version scoping and
deprecation policy.

see [CONTRIBUTING.md](CONTRIBUTING.md#release-instructions-for-a-new-version) for release instructions

## 1.14.0 (2024-Apr-15)
 - fix(path): make `path.expanduser` more sturdy
   [#469](https://github.com/lunarmodules/Penlight/pull/469)
 - feat(func): extend `compose` to support N functions
   [#448](https://github.com/lunarmodules/Penlight/pull/448)
 - fix(utils) `nil` values in `utils.choose(cond, val1, val2)`
   [#447](https://github.com/lunarmodules/Penlight/pull/447)
 - fix(template) using `%` as an escape character caused the expression to not be recognized
   [#452](https://github.com/lunarmodules/Penlight/pull/452)
 - enhance(template): Preserve line numbers
   [#468](https://github.com/lunarmodules/Penlight/pull/468)
 - fix(pretty) integers for Lua 5.4
   [#456](https://github.com/lunarmodules/Penlight/pull/456)

## 1.13.1 (2022-Jul-22)
 - fix: `warn` unquoted argument
   [#439](https://github.com/lunarmodules/Penlight/pull/439)

## 1.13.0 (2022-Jul-22)
 - fix: `xml.parse` returned nonsense when given a file name
   [#431](https://github.com/lunarmodules/Penlight/pull/431)
 - feat: `app.require_here` now follows symlink'd main modules to their directory
   [#423](https://github.com/lunarmodules/Penlight/pull/423)
 - fix: `pretty.write` invalid order function for sorting
   [#430](https://github.com/lunarmodules/Penlight/pull/430)
 - fix: `compat.warn` raised write guard warning in OpenResty
   [#414](https://github.com/lunarmodules/Penlight/pull/414)
 - feat: `utils.enum` now accepts hash tables, to enable better error handling
   [#413](https://github.com/lunarmodules/Penlight/pull/413)
 - feat: `utils.kpairs` new iterator over all non-integer keys
   [#413](https://github.com/lunarmodules/Penlight/pull/413)
 - fix: `warn` use rawget to not trigger strict-checkers
   [#437](https://github.com/lunarmodules/Penlight/pull/437)
 - fix: `lapp` provides the file name when using the default argument
   [#427](https://github.com/lunarmodules/Penlight/pull/427)
 - fix: `lapp` positional arguments now allow digits after the first character
   [#428](https://github.com/lunarmodules/Penlight/pull/428)
 - fix: `path.isdir` windows root directories (including drive letter) were not considered valid
   [#436](https://github.com/lunarmodules/Penlight/pull/436)


## 1.12.0 (2022-Jan-10)
 - deprecate: module `pl.text` the contents have moved to `pl.stringx` (removal later)
   [#407](https://github.com/lunarmodules/Penlight/pull/407)
 - deprecate: module `pl.xml`, please switch to a more specialized library (removal later)
   [#409](https://github.com/lunarmodules/Penlight/pull/409)
 - feat: `utils.npairs` added. An iterator with a range that honours the `n` field
   [#387](https://github.com/lunarmodules/Penlight/pull/387)
 - fix: `xml.maptags` would hang if it encountered text-nodes
   [#396](https://github.com/lunarmodules/Penlight/pull/396)
 - fix: `text.dedent` didn't handle declining indents nor empty lines
   [#402](https://github.com/lunarmodules/Penlight/pull/402)
 - fix: `dir.getfiles`, `dir.getdirectories`, and `dir.getallfiles` now have the
   directory optional, as was already documented
   [#405](https://github.com/lunarmodules/Penlight/pull/405)
 - feat: `array2d.default_range` now also takes a spreadsheet range, which means
   also other functions now take a range. [#404](https://github.com/lunarmodules/Penlight/pull/404)
 - fix: `lapp` enums allow [patterns magic characters](https://www.lua.org/pil/20.2.html)
   [#393](https://github.com/lunarmodules/Penlight/pull/393)
 - fix: `text.wrap` and `text.fill` numerous fixes for handling whitespace,
   accented characters, honouring width, etc.
   [#400](https://github.com/lunarmodules/Penlight/pull/400)
 - feat: `text.wrap` and `text.fill` have a new parameter to forcefully break words
   longer than the width given.
   [#400](https://github.com/lunarmodules/Penlight/pull/400)
 - fix: `stringx.expandtabs` could error out on Lua 5.3+
   [#406](https://github.com/lunarmodules/Penlight/pull/406)
 - fix: `pl` the module would not properly forward the `newindex` metamethod
   on the global table.
   [#395](https://github.com/lunarmodules/Penlight/pull/395)
 - feat: `utils.enum` added to create enums and prevent magic strings
   [#408](https://github.com/lunarmodules/Penlight/pull/408)
 - change: `xml.new` added some sanity checks on input
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - added: `xml.xml_escape` and `xml.xml_unescape` functions (previously private)
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - feat: `xml.tostring` now also takes numeric indents (previously only strings)
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - fix: `xml.walk` now detects recursion (errors out)
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - fix: `xml.clone` now detects recursion (errors out)
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - fix: `xml.compare` now detects recursion (errors out)
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - fix: `xml.compare` text compares now work
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - fix: `xml.compare` attribute order compares now only compare if both inputs provide an order
   [#397](https://github.com/lunarmodules/Penlight/pull/397)
 - fix: `xml.compare` child comparisons failing now report proper error
   [#397](https://github.com/lunarmodules/Penlight/pull/397)


## 1.11.0 (2021-Aug-18)

 - fix: `stringx.strip` behaved badly with string lengths > 200
   [#382](https://github.com/lunarmodules/Penlight/pull/382)
 - fix: `path.currentdir` now takes no arguments and calls `lfs.currentdir` without argument
   [#383](https://github.com/lunarmodules/Penlight/pull/383)
 - feat: `utils.raise_deprecation` now has an option to NOT include a
   stack-trace [#385](https://github.com/lunarmodules/Penlight/pull/385)


## 1.10.0 (2021-Apr-27)

 - deprecate: `permute.iter`, renamed to `permute.order_iter` (removal later)
   [#360](https://github.com/lunarmodules/Penlight/pull/360)
 - deprecate: `permute.table`, renamed to `permute.order_table` (removal later)
   [#360](https://github.com/lunarmodules/Penlight/pull/360)
 - deprecate: `Date` module (removal later)
   [#367](https://github.com/lunarmodules/Penlight/pull/367)
 - feat: `permute.list_iter` to iterate over different sets of values
   [#360](https://github.com/lunarmodules/Penlight/pull/360)
 - feat: `permute.list_table` generate table with different sets of values
   [#360](https://github.com/lunarmodules/Penlight/pull/360)
 - feat: Lua 5.4 'warn' compatibility function
   [#366](https://github.com/lunarmodules/Penlight/pull/366)
 - feat: deprecation functionality `utils.raise_deprecation`
   [#361](https://github.com/lunarmodules/Penlight/pull/361)
 - feat: `utils.splitv` now takes same args as `split`
   [#373](https://github.com/lunarmodules/Penlight/pull/373)
 - fix: `dir.rmtree` failed to remove symlinks to directories
   [#365](https://github.com/lunarmodules/Penlight/pull/365)
 - fix: `pretty.write` could error out on failing metamethods (Lua 5.3+)
   [#368](https://github.com/lunarmodules/Penlight/pull/368)
 - fix: `app.parse` now correctly parses values containing '=' or ':'
   [#373](https://github.com/lunarmodules/Penlight/pull/373)
 - fix: `dir.makepath` failed to create top-level directories
   [#372](https://github.com/lunarmodules/Penlight/pull/372)
 - overhaul: `array2d` module was updated, got additional tests and several
   documentation updates
   [#377](https://github.com/lunarmodules/Penlight/pull/377)
 - feat: `array2d` now accepts negative indices
 - feat: `array2d.row` added to align with `column`
 - fix: bad error message in `array2d.map`
 - fix: `array2d.flatten` now ensures to deliver a 'square' result if `nil` is
   encountered
 - feat: `array2d.transpose` added
 - feat: `array2d.swap_rows` and `array2d.swap_cols` now return the array
 - fix: `array2d.range` correctly recognizes `R` column in spreadsheet format, was
   mistaken for `R1C1` format.
 - fix: `array2d.range` correctly recognizes 2 char column in spreadsheet format
 - feat: `array2d.default_range` added (previously private)
 - feat: `array2d.set` if used with a function now passes `i,j` to the function
   in line with the `new` implementation.
 - fix: `array2d.iter` didn't properly iterate the indices
   [#376](https://github.com/lunarmodules/Penlight/issues/376)
 - feat: `array2d.columns` now returns a second value; the column index
 - feat: `array2d.rows` added to be in line with `columns`


## 1.9.2 (2020-Sep-27)

 - fix: dir.walk [#350](https://github.com/lunarmodules/Penlight/pull/350)


## 1.9.1 (2020-Sep-24)

 - released to superseed the 1.9.0 version which was retagged in git after some
   distro's already had picked it up. This version is identical to 1.8.1.

## 1.8.1 (2020-Sep-24) (replacing a briefly released but broken 1.9.0 version)

## Fixes

  - In `pl.class`, `_init` can now be inherited from grandparent (or older ancestor) classes. [#289](https://github.com/lunarmodules/Penlight/pull/289)
  - Fixes `dir`, `lexer`, and `permute` to no longer use coroutines. [#344](https://github.com/lunarmodules/Penlight/pull/344)

## 1.8.0 (2020-Aug-05)

### New features

  - `pretty.debug` quickly dumps a set of values to stdout for debug purposes

### Changes

  - `pretty.write`: now also sorts non-string keys [#319](https://github.com/lunarmodules/Penlight/pull/319)
  - `stringx.count` has an extra option to allow overlapping matches
    [#326](https://github.com/lunarmodules/Penlight/pull/326)
  - added an extra changelog entry for `types.is_empty` on the 1.6.0 changelog, due
    to additional fixed behaviour not called out appropriately [#313](https://github.com/lunarmodules/Penlight/pull/313)
  - `path.packagepath` now returns a proper error message with names tried if
    it fails

### Fixes

  - Fix: `stringx.rfind` now properly works with overlapping matches
    [#314](https://github.com/lunarmodules/Penlight/pull/314)
  - Fix: `package.searchpath` (in module `pl.compat`)
    [#328](https://github.com/lunarmodules/Penlight/pull/328)
  - Fix: `path.isabs` now reports drive + relative-path as `false`, eg. "c:some/path" (Windows only)
  - Fix: OpenResty coroutines, used by `dir.dirtree`, `pl.lexer`, `pl.permute`. If
    available the original coroutine functions are now used [#329](https://github.com/lunarmodules/Penlight/pull/329)
  - Fix: in `pl.strict` also predefine global `_PROMPT2`
  - Fix: in `pl.strict` apply `tostring` to the given name, in case it is not a string.
  - Fix: the lexer would not recognize numbers without leading zero; "-.123".
    See [#315](https://github.com/lunarmodules/Penlight/issues/315)

## 1.7.0 (2019-Oct-14)

### New features

  - `utils.quote_arg` will now optionally take an array of arguments and escape
    them all into a single string.
  - `app.parse_args` now accepts a 3rd parameter with a list of valid flags and aliases
  - `app.script_name` returns the name of the current script (previously a private function)

### Changes

  - Documentation updates
  - `utils.quit`: exit message is no longer required, and closes the Lua state (on 5.2+).
  - `utils.assert_arg` and `utils.assert_string`: now return the validated value
  - `pl.compat`: now exports the `jit` and `jit52` flags
  - `pretty.write`: now sorts the output for easier diffs [#293](https://github.com/lunarmodules/Penlight/pull/293)

### Fixes

  - `utils.raise` changed the global `on_error`-level when passing in bad arguments
  - `utils.writefile` now checks and returns errors when writing
  - `compat.execute` now handles the Windows exitcode -1 properly
  - `types.is_empty` would return true on spaces always, independent of the parameter
  - `types.to_bool` will now compare case-insensitive for the extra passed strings
  - `app.require_here` will now properly handle an absolute base path
  - `stringx.split` will no longer append an empty match if the number of requested
    elements has already been reached [#295](https://github.com/lunarmodules/Penlight/pull/295)
  - `path.common_prefix` and `path.relpath` return the result in the original casing
    (only impacted Windows) [#297](https://github.com/lunarmodules/Penlight/pull/297)
  - `dir.copyfile`, `dir.movefile`, and `dir.makepath` create the new file/path with
    the requested casing, and no longer force lowercase (only impacted Windows)
    [#297](https://github.com/lunarmodules/Penlight/pull/297)
  - added a missing assertion on `path.getmtime` [#291](https://github.com/lunarmodules/Penlight/pull/291)
  - `stringx.rpartition` returned bad results on a not-found [#299](https://github.com/lunarmodules/Penlight/pull/299)

## 1.6.0 (2018-Nov-23)

### New features

  - `pl.compat` now provides `unpack` as `table.unpack` on Lua 5.1

### Changes

  - `utils.unpack` is now documented and respects `.n` field of its argument.
  - `tablex.deepcopy` and `tablex.deepcompare` are now cycle aware (#262)
  - Installing through LuaRocks will now include the full rendered documentation

### Fixes

  - Fixed `seq.last` returning `nil` instead of an empty list when given an empty iterator (#253).
  - `pl.template` now applies `tostring` when substituting values in templates, avoiding errors when they are not strings or numbers (#256).
  - Fixed `pl.import_into` not importing some Penlight modules (#268).
  - Fixed version number stuck at 1.5.2 (#260).
  - Fixed `types.is_empty` returning `true` on tables containing `false` key (#267).
  - Fixed `types.is_empty` returning `false` if not a nil/table/string
  - Fixed `test.assertraise` throwing an error when passed an array with a function to call plus its arguments (#272).
  - Fixed `test.assertraise` not throwing an error when given function does not error but instead returns a string matching given error pattern.
  - Fixed placeholder expressions being evaluated with wrong precedence of binary and unary negation.
  - Fixed placeholder expressions being evaluated assuming wrong binary operator associativity (e.g. `_1-(_2+_3)` was evaluated as `(_1-_2)+_3`.
  - Fixed placeholder expressions being evaluated as if unary operators take precedence over power operator (e.g. `(-_1)^_2`) was evaluated as `-(_1^2)`).
  - Fixed vulnerable backtracking pattern in `pl.stringx.strip` (#275)

## 1.5.4 (2017-07-17)

### Fixes

  - Fixed `compat.execute` behaving differently on Lua 5.1 and 5.1+.
  - Fixed `lapp.process_options_string` setting global `success` variable.

## 1.5.3 (2017-07-16)

### Changes

  - Added `template.compile` function that allows caching compiled template and rendering it multiple times.
  - Added special `_debug` field to environment table argument in `template.substitute` for printing generated template code upon render error.

### Fixes

  - Fixed error (`attempt to concatenate a nil value (local 'vtype')`) in `lapp.process_options_string`.

## 1.5.2 (2017-04-08)

### Fixes

  - Removed leftover debug pring in `lapp.process_options_string`.

## 1.5.1 (2017-04-02)

### Fixes

  - Fixed `dir.getfiles` matching given pattern against full paths from base directory instead of file names.

## 1.5.0 (2017-04-01)

### Changes

  - `stringx.splitlines` considers `\r\n` a single line ending.
  - `stringx.splitlines` returns an empty list for an empty string.

### Fixes

  - `tablex.count_map` no longer raises an error.
  - `strict.module` correctly handles existing `__index` metamethod returning `false`.
  - `app.parse_args` accepts colon as a separator between option name and value, as advertised.
  - `pretty.load` handles case where a C hook is present.
  ' `os.execute` had issue with LuaJIT in 5.2 compat mode.

### Features

  - `template` supports customizing inline escape character and chunk name.
  - `seq` constructor supports iterators with a state object as the second argument.
  - `stringx.splitlines` has `keep_ends` argument.
  - `tablex.reduce` can take an optional initial value.

## 1.4.1 (2016-08-16)

### Changes

  - All functions that return instances of `pl.List`, `pl.Map` and `pl.Set` now require corresponding modules,
   so that their methods always work right away.

### Fixes

  - Fixed `dir.getallfiles` returning an empty array when called without `pattern` argument.

### Features

## 1.4.0 (2016-08-14)

### Changes

### Fixes

  - `pl.path` covers edge cases better (e.g `path.normpath` was broken)
  - `p.dir` shell patterns fixed
  - `os.tmpname` broken on modern Windows/MSVC14
  - (likewise for `utils.executeex` which depends on it)
  - `pretty.write` more robust and does not lose floating-point precision;
    saves and restores debug hooks when loading.
  - `pl.lexer` fixes: `cpp` lexer now filters space by default
  - `tablex.sortv` no longer assumes that the values are all unique
  - `stringx.center` is now consistent with Python; `stringx.rfind` and
  `string.quote_string` fixed.
  - `data.write` had a problem with default delimiter, properly returns error now.
  - `pl.Set` `+` and `-` now have correct semantics

### Features

  - `pl.tablex` has `union` and `merge` convenience functions
  - `pl.lapp` understands '--' meaning end of parsed arguments
  - `utils.quote_arg` quotes command arguments for `os.execute`,
  correctly handling all special characters.
  - `utils.writefile` has optional `is_bin` argument
  - 'pl.lexer' supports line numbers with string argument
  - `stringx.endswith` may be passed an array of possible suffixes.
  - `data.read` - in CSV mode, assume empty fields are numerical zero


## 1.3.2 (2015-05-10)

### Changes

  - now works and passes tests with Lua 5.3
  - utils.import will NOT override global symbols (import 'math' caused global type() to be clobbered)
  - Updated pl.dir.file_op to return true on success and false on failure...
  - workaround for issues with pl.lapp with amalg.lua - will look at global LAPP_SCRIPT if arg[0] is nil

### Fixes

  - func was broken: do NOT use ipairs to iterate if __index is overridden!
  - issue #133 pretty.read (naively) confused by unbalanced brackets
  - xml attribute underscore fix for simple parser
  - Fix path.normpath
  - lexer: fix parsing block comments/string. fix hang on empty string.
  -  Fixed utils.execute returning different values for Lua 5.1 and Lua 5.2
  - Issue #97; fixed attempt to put a month into a day
  -  problem with tablex.count_map with custom comparison
  - tablex.pairmap overwrites result if key already exists; instead, upon detection that key already exists
	for a returned value, we modify the key's value to be a table and insert values into that table

### Features

  -  Add Python style url module for quote and unquote.
  -  stringx.quote_string, which scans for embedded long-string quote matches and escapes them by creating a long-string quote.
  -  issue #117: tablex.range now works with decreasing numbers, consistent with numerical for loop
  -  utils.import will NOT override global symbols (import 'math' caused global type() to be clobbered)
  - issue #125: DOCTYPE ignored in xml documents as well
  - Allow XML tostring() function to customize the default prefacing with `<?xml...>`
  - More Robust Quoted Strings
  - lapp: improved detection of unsupported short flags

## 1.3.1 (2013-09-24)

## 1.3.0 (2013-09-14)

### Changes

  - class: RIP base method - not possible to implement correctly
  - lapp: short flags can now always be followed directly by their value, for instance,
`-I/usr/include/lua/5.1`
  - Date: new explicit `Date.Interval` class; `toUTC/toLocal` return new object; `Date.__tostring`
always returns ISO 8601 times for exact serialization.  `+/-` explicit operators. Date objects
are explicitly flagged as being UTC or not.

### Fixes

  - class: super method fixed.
  - Date: DST is now accounted for properly.
  - Date: weekday calculation borked.

### Features

  - All tests pass with no-5.1-compatible Lua 5.2; now always uses `utils.load` and
`utils.unpack` is always available.
  - types: new module containing `utils.is_xxx` methods plus new `to_bool`.
  - class: can be passed methods in a table (see `test=klass.lua`). This is
particularly convenient for using from Moonscript.
  - general documentation improvements, e.g `class`

## 1.2.1 (2013-06-21)

### Changes

  - utils.set(get)fenv always defined (_not_ set as globals for 5.2 anymore!).
    These are defined in new module pl.compat, but still available through utils.
  - class.Frodo now puts 'Frodo' in _current environment_

### Fixes

  - lapp.add_type was broken (Pete Kazmier)
  - class broke with classes that redefined __newindex
  - Set.isdisjoint was broken because of misspelling; default ctor Set() now works as expected
  - tablex.transform was broken; result now has same keys as original (CoolistheName007)
  - xml match not handling empty matches (royalbee)
  - pl.strict: assigning nil to global declares it, as God intended. (Pierre Chapuis)
  - tests all work with pl.strict
  - 5.2 compatible load now respects mode
  - tablex.difference thought that a value of `false` meant 'not present' (Andrew Starke)

### Features

  - tablex.sort(t) iterates over sorted keys, tablex.sortv(t) iterates over sorted values (Pete Kazmier)
  - tablex.readonly(t) creates a read-only proxy for a table (John Schember)
  - utils.is_empty(o) true if o==nil, o is an empty table, or o is an empty string (John Schember)
  - utils.executeex(cmd,bin) returns true if successful, return code, plus stdout and stderr output as strings. (tieske)
  - class method base for calling inherited methods (theypsilon)
  - class supports pre-constructor _create for making a custom self (used in pl.List)
  - xml HTML mode improvements - can parse non-trivial well-formed HTML documents.
    xml.parsehtml is a parse function, no longer a flag
  - if a LOM document has ordered attributes, use these when stringifying
  - xml.tostring has yet another extra parm to force prefacing with `<?xml...>`
  - lapp boolean flags may have `true` default
  - lapp slack mode where 'short' flags can be multi-char
  - test.asserteq etc take extra arg, which is extra level where error must be reported at
  - path.currentdir,chdir,rmdir,mkdir and dir as alias to lfs are exported; no dependencies on luafilesystem outside pl.path, making it easier to plug in different implementations.

## 1.2.0 (2013-05-28)

## 1.1.1 (2013-05-14)

## 1.1.0 (2013-03-18)

## 1.0.3 (2012-12-07)

## 1.0.2 (2012-05-12)

## 1.0.1 (2012-05-26)

## 1.0.0 (2012-04-26)

## 0.9.8 (2011-11-27)

## 0.9.7 (2011-11-27)

### Lua 5.2 compatibility

(These are all now defined in pl.utils)

- setfenv, getfenv defined for Lua 5.2 (by Sergey Rozhenko)

### Changes

- array2d.flatten is new
- OrderedMap:insert is new

### Fixes

- seq.reduce re-implemented to give correct order (Carl Ådahl)
- seq.unique was broken: new test
- tablex.icopy broken for last argument; new test
- utils.function_arg last parm 'msg' was missing
- array2d.product was broken; more sensible implementation
- array2d.range, .slice, .write were broken
- text optional operator % overload broken for 'fmt % fun'; new tests
- a few occurrences of non-existent function utils.error removed


## 0.9.6 (2011-09-11)

### Lua 5.2 compatibility

- Bad string escape in tests fixed

### Changes

- LuaJIT FFI used on Windows for Copy/MoveFile functionality

### Fixes

- Issue 13 seq.sort now calls seq.copy
- issue 14 bad pattern to escape trailing separators in path.abspath
- lexer: string tokens broken with some combinations
- lexer: long comments broken for Lua and C
- stringx.split behaves according to Python spec; extra parm meaning 'max splits'
- stringx.title behaves according to Python spec
- stringx.endswith broken for 2nd arg being table of postfixes
- OrderedMap.set broken when value was nil and key did not exist in map; ctor throws
  error if unhappy

## 0.9.5 (2011-07-05)

### Lua 5.2 compatibility

 - defines Lua 5.2 beta compatible load()
 - defines table.pack()

### New functions

 - stringx.title(): translates "a dog's day" to "A Dog's Day"
 - path.normpath(): translates 'A//B','A/./B' and 'A/C/../B' to 'A/B'
 - utils.execute(): returns ok,return-code: compatible with 5.1 and 5.2

### Fixes

 - pretty.write() _always_ returns a string, but will return also an error string
if the argument is not a table. Non-integer indices between 1 and #t are no longer falsely considered part of the array
 - stringx.expandtabs() now works like the Python string method; it will expand each field up to the next tab stop
 - path.normcase() was broken, because of a misguided attempt to normalize the path.
 - UNC specific fix to path.abspath()
 - UNC paths recognized as absolute; dir.makedir() works here
 - utils.quit() varargs broken, e.g. utils.quit("answer was %d",42)
 - some stray globals caused trouble with 'strict'

## 0.9.4 (2011-04-08)

## 0.9.3 (2011-03-05)

## 0.9.2 (2011-02-16)

## 0.9.1 (2011-02-12)

## 0.9.0 (2010-12-20)

## 0.8.5 (2010-12-16)

### What's new with 0.8b ?

#### Features:

pl.app provides useful stuff like simple command-line argument parsing and require_here(), which
makes subsequent require() calls look in the local directory by preference.

p.file provides useful functions like copy(),move(), read() and write().  (These are aliases to
dir.copyfile(),movefile(),utils.readfile(),writefile())

Custom error trace will only show the functions in user code.

More robust argument checking.

In function arguments, now supports 'string lambdas', e.g. `'|x| 2*x'`

utils.readfile,writefile now insist on being given filenames. This will cause less confusion.

tablex.search() is new: will look recursively in an arbitrary table; can specify tables not to follow.
tablex.move() will work with source and destination tables the same, with overlapping ranges.

#### Bug Fixes:

dir.copyfile() now works fine without Alien on Windows

dir.makepath() and rmtree() had problems.

tablex.compare_no_order() is now O(NlogN), as expected.
tablex.move() had a problem with source size

### What's New with 0.7.0b?

#### Features:

utils.is_type(v,tp) can say is_type(s,'string') and is_type(l,List).
utils.is_callable(v) either a function, or has a `__call` metamethod.

Sequence wrappers: can write things like this:

seq(s):last():filter('<'):copy()

seq:mapmethod(s,name) - map using a named method over a sequence.

seq:enum(s)  If s is a simple sequence, then
     for i,v in seq.enum(s) do print(i,v) end

seq:take(s,n)  Grab the next n values from a (possibly infinite)
sequence.

In a related change suggested by Flemming Madsden, the in-place List
methods like reverse() and sort() return the list, allowing for
method chaining.

list.join()  explicitly converts using tostring first.

tablex.count_map() like seq.count_map(), but takes an equality function.

tablex.difference()  set difference
tablex.set()  explicit set generator given a list of values

Template.indent_substitute() is a new Template method which adjusts
for indentation and can also substitute templates themselves.

pretty.read(). This reads a Lua table (as dumped by pretty.write)
and attempts to be paranoid about its contents.

sip.match_at_start(). Convenience function for anchored SIP matches.

#### Bug Fixes:

tablex.deepcompare() was confused by false boolean values, which
it thought were synonymous with being nil.

pretty.write() did not handle cycles, and could not display tables
with 'holes' properly (Flemming Madsden)

The SIP pattern '$(' was not escaped properly.
sip.match() did not pass on options table.

seq.map() was broken for double-valued sequences.
seq.copy_tuples() did not use default_iter(), so did not e.g. like
table arguments.

dir.copyfile() returns the wrong result for \*nix operations.
dir.makepath() was broken for non-Windows paths.

### What's New with 0.6.3?

The map and reduce functions now take the function first, as Nature intended.

The Python-like overloading of '\*' for strings has been dropped, since it
is silly. Also, strings are no longer callable; use 's:at(1)' instead of
's(1)' - this tended to cause Obscure Error messages.

Wherever a function argument is expected, you can use the operator strings
like '+','==',etc as well as pl.operator.add, pl.operator.eq, etc.
(see end of pl/operator.lua for the full list.)

tablex now has compare() and compare_no_order(). An explicit set()
function has been added which constructs a table with the specified
keys, all set to a value of true.

List has reduce() and partition() (This is a cool function which
separates out elements of a list depending on a classifier function.)

There is a new array module which generalizes tablex operations like
map and reduce for two-dimensional arrays.

The famous iterator over permutations from PiL 9.3 has been included.

David Manura's list comprehension library has been included.

Also, utils now contains his memoize function, plus a useful function
args which captures the case where varargs contains nils.

There was a bug with dir.copyfile() where the flag was the wrong way round.

config.lines() had a problem with continued lines.

Some operators were missing in pl.operator; have renamed them to be
consistent with the Lua metamethod names.


