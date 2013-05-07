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
 