## 1.5.0 [in progress]

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

## 1.4.1

### Changes

  - All functions that return instances of `pl.List`, `pl.Map` and `pl.Set` now require corresponding modules,
   so that their methods always work right away.

### Fixes

  - Fixed `dir.getallfiles` returning an empty array when called without `pattern` argument.

### Features

## 1.4.0

### Changes

### Fixes

  - `pl.path` covers edge cases better (e.g 'path.normpath` was broken)
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


## 1.3.2

### Changes

  - now works and passes tests with Lua 5.3
  - utils.import will NOT override global symbols (import 'math' caused global type() to be clobbered)
  - Updated pl.dir.file_op to return true on success and false on failure...
  - workaround for issues with pl.lapp with amalg.lua - will look at global LAPP_SCRIPT if arg[0] is nil

### Fixes

  - func was broken: do NOT use ipairs to iterate if __index is overriden!
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
  - Allow XML tostring() function to customize the default prefacing with <?xml...>
  - More Robust Quoted Strings
  - lapp: improved detection of unsupported short flags

## 1.3.0

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

## 1.2.1

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
  - xml.tostring has yet another extra parm to force prefacing with <?xml...>
  - lapp boolean flags may have `true` default
  - lapp slack mode where 'short' flags can be multi-char
  - test.asserteq etc take extra arg, which is extra level where error must be reported at
  - path.currentdir,chdir,rmdir,mkdir and dir as alias to lfs are exported; no dependencies on luafilesystem outside pl.path, making it easier to plug in different implementations.



## 0.9.7

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
- a few occurances of non-existent function utils.error removed


## 0.9.6

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

## 0.9.5

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

###What's new with 0.8b ?

####Features:

pl.app provides useful stuff like simple command-line argument parsing and require_here(), which
makes subsequent require() calls look in the local directory by preference.

p.file provides useful functions like copy(),move(), read() and write().  (These are aliases to
dir.copyfile(),movefile(),utils.readfile(),writefile())

Custom error trace will only show the functions in user code.

More robust argument checking.

In function arguments, now supports 'string lambdas', e.g. '|x| 2*x'

utils.readfile,writefile now insist on being given filenames. This will cause less confusion.

tablex.search() is new: will look recursively in an arbitrary table; can specify tables not to follow.
tablex.move() will work with source and destination tables the same, with overlapping ranges.

####Bug Fixes:

dir.copyfile() now works fine without Alien on Windows

dir.makepath() and rmtree() had problems.

tablex.compare_no_order() is now O(NlogN), as expected.
tablex.move() had a problem with source size

###What's New with 0.7.0b?

####Features:

utils.is_type(v,tp) can say is_type(s,'string') and is_type(l,List).
utils.is_callable(v) either a function, or has a __call metamethod.

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

####Bug Fixes:

tablex.deepcompare() was confused by false boolean values, which
it thought were synonymous with being nil.

pretty.write() did not handle cycles, and could not display tables
with 'holes' properly (Flemming Madsden)

The SIP pattern '$(' was not escaped properly.
sip.match() did not pass on options table.

seq.map() was broken for double-valued sequences.
seq.copy_tuples() did not use default_iter(), so did not e.g. like
table arguments.

dir.copyfile() returns the wrong result for *nix operations.
dir.makepath() was broken for non-Windows paths.

###What's New with 0.6.3?

The map and reduce functions now take the function first, as Nature intended.

The Python-like overloading of '*' for strings has been dropped, since it
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


