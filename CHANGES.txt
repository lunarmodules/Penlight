## Changes from the last version

## Lua 5.2 compatibility

 - defines Lua 5.2 beta compatible load()
 - defines table.pack()

## New functions

 - stringx.title(): translates "a dog's day" to "A Dog's Day"
 - path.normpath(): translates 'A//B','A/./B' and 'A/C/../B' to 'A/B'
 - utils.execute(): returns ok,return-code: compatible with 5.1 and 5.2

## Fixes

 - pretty.write() _always_ returns a string, but will return also an error string
if the argument is not a table. Non-integer indices between 1 and #t are no longer falsely considered part of the array
 - stringx.expandtabs() now works like the Python string method; it will expand each field up to the next tab stop
 - path.normcase() was broken, because of a misguided attempt to normalize the path.
 - UNC specific fix to path.abspath()
 - UNC paths recognized as absolute; dir.makedir() works here
 - utils.quit() varargs broken, e.g. utils.quit("answer was %d",42)
 - some stray globals caused trouble with 'strict'
 