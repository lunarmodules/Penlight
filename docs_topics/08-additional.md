## Additional Libraries

Libraries in this section are no longer considered to be part of the Penlight
core, but still provide specialized functionality when needed.

<a id="sip"/>

### Simple Input Patterns

Lua string pattern matching is very powerful, and usually you will not need a
traditional regular expression library.  Even so, sometimes Lua code ends up
looking like Perl, which happens because string patterns are not always the
easiest things to read, especially for the casual reader.  Here is a program
which needs to understand three distinct date formats:

    -- parsing dates using Lua string patterns
    months={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,
    Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}

    function check_and_process(d,m,y)
        d = tonumber(d)
        m = tonumber(m)
        y = tonumber(y)
        ....
    end

    for line in f:lines() do
        -- ordinary (English) date format
        local d,m,y = line:match('(%d+)/(%d+)/(%d+)')
        if d then
            check_and_process(d,m,y)
        else -- ISO date??
            y,m,d = line:match('(%d+)%-(%d+)%-(%d+)')
            if y then
                check_and_process(d,m,y)
            else -- <day> <month-name> <year>?
                d,mm,y = line:match('%(d+)%s+(%a+)%s+(%d+)')
                m = months[mm]
                check_and_process(d,m,y)
            end
        end
    end

These aren't particularly difficult patterns, but already typical issues are
appearing, such as having to escape '-'. Also, `string.match` returns its
captures, so that we're forced to use a slightly awkward nested if-statement.

Verification issues will further cloud the picture, since regular expression
people try to enforce constraints (like year cannot be more than four digits)
using regular expressions, on the usual grounds that you shouldn't stop using a
hammer when you are enjoying yourself.

`pl.sip` provides a simple, intuitive way to detect patterns in strings and
extract relevant parts.

    > sip = require 'pl.sip'
    > dump = require('pl.pretty').dump
    > res = {}
    > c = sip.compile 'ref=$S{file}:$d{line}'
    > = c('ref=hello.c:10',res)
    true
    > dump(res)
    {
      line = 10,
      file = "hello.c"
    }
    > = c('ref=long name, no line',res)
    false

`sip.compile` creates a pattern matcher function, which takes a string and a
table as arguments. If the string matches the pattern, then `true` is returned
and the table is populated according to the captures within the pattern.

Here is another version of the date parser:

    -- using SIP patterns
    function check(t)
        check_and_process(t.day,t.month,t.year)
    end

    shortdate = sip.compile('$d{day}/$d{month}/$d{year}')
    longdate = sip.compile('$d{day} $v{mon} $d{year}')
    isodate = sip.compile('$d{year}-$d{month}-$d{day}')

    for line in f:lines() do
        local res = {}
        if shortdate(str,res) then
            check(res)
        elseif isodate(str,res) then
            check(res)
        elseif longdate(str,res) then
            res.month = months[res.mon]
            check(res)
        end
    end

SIP captures start with '$', then a one-character type, and then an
optional variable name in curly braces.

    Type      Meaning
    v         identifier
    i         possibly signed integer
    f         floating-point number
    r         rest of line
    q         quoted string (quoted using either ' or ")
    p         a path name
    (         anything inside balanced parentheses
    [         anything inside balanced brackets
    {         anything inside balanced curly brackets
    <         anything inside balanced angle brackets

If a type is not one of the above, then it's assumed to be one of the standard
Lua character classes, and will match one or more repetitions of that class.
Any spaces you leave in your pattern will match any number of spaces, including
zero, unless the spaces are between two identifier characters or patterns
matching them; in that case, at least one space will be matched.

SIP captures (like `$v{mon}`) do not have to be named. You can use just `$v`, but
you have to be consistent; if a pattern contains unnamed captures, then all
captures must be unnamed. In this case, the result table is a simple list of
values.

`sip.match` is a useful shortcut if you want to compile and match in one call,
without saving the compiled pattern. It caches the result, so it is not much
slower than explicitly using `sip.compile`.

    > sip.match('($q{first},$q{second})','("john","smith")',res)
    true
    > res
    {second='smith',first='john'}
    > res = {}
    > sip.match('($q,$q)','("jan","smit")',res)  -- unnamed captures
    true
    > res
    {'jan','smit'}
    > sip.match('($q,$q)','("jan", "smit")',res)
    false   ---> oops! Can't handle extra space!
    > sip.match('( $q , $q )','("jan", "smit")',res)
    true

As a general rule, allow for whitespace in your patterns.

Finally, putting a '$' at the end of a pattern means 'capture the rest of the
line, starting at the first non-space'. It is a shortcut for '$r{rest}',
or just '$r' if no named captures are used.

    > sip.match('( $q , $q ) $','("jan", "smit") and a string',res)
    true
    > res
    {'jan','smit','and a string'}
    > res = {}
    > sip.match('( $q{first} , $q{last} ) $','("jan", "smit") and a string',res)
    true
    > res
    {first='jan',rest='and a string',last='smit'}


<a id="lapp"/>

### Command-line Programs with Lapp

`pl.lapp` is a small and focused Lua module which aims to make standard
command-line parsing easier and intuitive. It implements the standard GNU style,
i.e. short flags with one letter start with '-', and there may be an additional
long flag which starts with '--'. Generally options which take an argument expect
to find it as the next parameter (e.g. 'gcc test.c -o test') but single short
options taking a value can dispense with the space (e.g. 'head -n4
test.c' or `gcc -I/usr/include/lua/5.1 ...`)

As far as possible, Lapp will convert parameters into their equivalent Lua types,
i.e. convert numbers and convert filenames into file objects. If any conversion
fails, or a required parameter is missing, an error will be issued and the usage
text will be written out. So there are two necessary tasks, supplying the flag
and option names and associating them with a type.

For any non-trivial script, even for personal consumption, it's necessary to
supply usage text. The novelty of Lapp is that it starts from that point and
defines a loose format for usage strings which can specify the names and types of
the parameters.

An example will make this clearer:

    -- scale.lua
      lapp = require 'pl.lapp'
      local args = lapp [[
      Does some calculations
        -o,--offset (default 0.0)  Offset to add to scaled number
        -s,--scale  (number)  Scaling factor
        <number> (number)  Number to be scaled
      ]]

      print(args.offset + args.scale * args.number)

Here is a command-line session using this script:

      $ lua scale.lua
      scale.lua:missing required parameter: scale

      Does some calculations
       -o,--offset (default 0.0)  Offset to add to scaled number
       -s,--scale  (number)  Scaling factor
        <number> (number )  Number to be scaled

      $ lua scale.lua -s 2.2 10
      22

      $ lua scale.lua -s 2.2 x10
      scale.lua:unable to convert to number: x10

      ....(usage as before)

There are two kinds of lines in Lapp usage strings which are meaningful; option
and parameter lines. An option line gives the short option, optionally followed
by the corresponding long option. A type specifier in parentheses may follow.
Similarly, a parameter line starts with '<NAME>', followed by a type
specifier.

Type specifiers usually start with a type name: one of 'boolean', 'string','number','file-in' or
'file-out'.  You may leave this out, but then _must_ say 'default' followed by a value.
If a flag or parameter has a default, it is not _required_ and is set to the default. The actual
type is deduced from this value (number, string, file or boolean) if not provided directly.
'Deduce' is a fancy word for 'guess' and it can be wrong, e.g '(default 1)'
will always be a number. You can say '(string default 1)' to override the guess.
There are file values for the predefined console streams: stdin, stdout, stderr.

The boolean type is the default for flags. Not providing the type specifier is equivalent to
'(boolean default false)`.  If the flag is meant to be 'turned off' then either the full
'(boolean default true)` or the shortcut '(default true)' will work.

An alternative to `default` is `optional`:

    local lapp = require 'pl.lapp'
    local args = lapp [[
       --cmd (optional string) Command to run.
    ]]

    if args.cmd then
      os.execute(args.cmd)
    end

Here we're implying that `cmd` need not be specified (just as with `default`) but if not
present, then `args.cmd` is `nil`, which will always test false.

The rest of the line is ignored and can be used for explanatory text.

This script shows the relation between the specified parameter names and the
fields in the output table.

      -- simple.lua
      local args = require ('pl.lapp') [[
      Various flags and option types
        -p          A simple optional flag, defaults to false
        -q,--quiet  A simple flag with long name
        -o  (string)  A required option with argument
        -s  (default 'save') Optional string with default 'save' (single quotes ignored)
        -n  (default 1) Optional numerical flag with default 1
        -b  (string default 1)  Optional string flag with default '1' (type explicit)
        <input> (default stdin)  Optional input file parameter, reads from stdin
      ]]

      for k,v in pairs(args) do
          print(k,v)
      end

I've just dumped out all values of the args table; note that args.quiet has
become true, because it's specified; args.p defaults to false. If there is a long
name for an option, that will be used in preference as a field name. A type or
default specifier is not necessary for simple flags, since the default type is
boolean.

      $ simple -o test -q simple.lua
      p       false
      input   file (781C1BD8)
      quiet   true
      o       test
      input_name      simple.lua
      D:\dev\lua\lapp>simple -o test simple.lua one two three
      1       one
      2       two
      3       three
      p       false
      quiet   false
      input   file (781C1BD8)
      o       test
      input_name      simple.lua

The parameter input has been set to an open read-only file object - we know it
must be a read-only file since that is the type of the default value. The field
input_name is automatically generated, since it's often useful to have access to
the original filename.

Notice that any extra parameters supplied will be put in the result table with
integer indices, i.e. args[i] where i goes from 1 to #args.

Files don't really have to be closed explicitly for short scripts with a quick
well-defined mission, since the result of garbage-collecting file objects is to
close them.

#### Enforcing a Range and Enumerations

The type specifier can also be of the form '(' MIN '..' MAX ')' or a set of strings
separated by '|'.

    local lapp = require 'pl.lapp'
    local args = lapp [[
        Setting ranges
        <x> (1..10)  A number from 1 to 10
        <y> (-5..1e6) Bigger range
        <z> (slow|medium|fast)
    ]]

    print(args.x,args.y)

Here the meaning of ranges is that the value is greater or equal to MIN and less or equal
to MAX.
An 'enum' is a _string_ that can only have values from a specified set.

#### Custom Types

There is no builti-in way to force a parameter to be a whole number, but
you may define a custom type that does this:

    lapp = require ('pl.lapp')

    lapp.add_type('integer','number',
        function(x)
            lapp.assert(math.ceil(x) == x, 'not an integer!')
        end
    )

    local args =  lapp [[
        <ival> (integer) Process PID
    ]]

    print(args.ival)

`lapp.add_type` takes three parameters, a type name, a converter and a constraint
function. The constraint function is expected to throw an assertion if some
condition is not true; we use `lapp.assert` because it fails in the standard way
for a command-line script. The converter argument can either be a type name known
to Lapp, or a function which takes a string and generates a value.

Here's a useful custom type that allows dates to be input as @{pl.Date} values:

    local df = Date.Format()

    lapp.add_type('date',
        function(s)
            local d,e = df:parse(s)
            lapp.assert(d,e)
            return d
        end
    )

#### 'varargs' Parameter Arrays

    lapp = require 'pl.lapp'
    local args = lapp [[
    Summing numbers
        <numbers...> (number) A list of numbers to be summed
    ]]

    local sum = 0
    for i,x in ipairs(args.numbers) do
        sum = sum + x
    end
    print ('sum is '..sum)

The parameter number has a trailing '...', which indicates that this parameter is
a 'varargs' parameter. It must be the last parameter, and args.number will be an
array.

Consider this implementation of the head utility from Mac OS X:

        -- implements a BSD-style head
        -- (see http://www.manpagez.com/man/1/head/osx-10.3.php)

        lapp = require ('pl.lapp')

        local args = lapp [[
        Print the first few lines of specified files
           -n         (default 10)    Number of lines to print
           <files...> (default stdin) Files to print
        ]]

        -- by default, lapp converts file arguments to an actual Lua file object.
        -- But the actual filename is always available as <file>_name.
        -- In this case, 'files' is a varargs array, so that 'files_name' is
        -- also an array.
        local nline = args.n
        local nfile = #args.files
        for i = 1,nfile do
            local file = args.files[i]
            if nfile > 1 then
                print('==> '..args.files_name[i]..' <==')
            end
            local n = 0
            for line in file:lines() do
                print(line)
                n = n + 1
                if n == nline then break end
            end
        end

Note how we have access to all the filenames, because the auto-generated field
`files_name` is also an array!

(This is probably not a very considerate script, since Lapp will open all the
files provided, and only close them at the end of the script. See the `xhead.lua`
example for another implementation.)

Flags and options may also be declared as vararg arrays, and can occur anywhere.
If there is both a short and long form, then the trailing "..." must happen after the long form,
for example "-x,--network... (string)...",

Bear in mind that short options can be combined (like 'tar -xzf'), so it's
perfectly legal to have '-vvv'. But normally the value of args.v is just a simple
`true` value.

    local args = require ('pl.lapp') [[
       -v...  Verbosity level; can be -v, -vv or -vvv
    ]]
    vlevel = not args.v[1] and 0 or #args.v
    print(vlevel)

The vlevel assigment is a bit of Lua voodoo, so consider the cases:

    * No -v flag, v is just { false }
    * One -v flags, v is { true }
    * Two -v flags, v is { true, true }
    * Three -v flags, v is { true, true, true }

#### Defining a Parameter Callback

If a script implements `lapp.callback`, then Lapp will call it after each
argument is parsed. The callback is passed the parameter name, the raw unparsed
value, and the result table. It is called immediately after assignment of the
value, so the corresponding field is available.

    lapp = require ('pl.lapp')

    function lapp.callback(parm,arg,args)
        print('+',parm,arg)
    end

    local args = lapp [[
    Testing parameter handling
        -p               Plain flag (defaults to false)
        -q,--quiet       Plain flag with GNU-style optional long name
        -o  (string)     Required string option
        -n  (number)     Required number option
        -s (default 1.0) Option that takes a number, but will default
        <start> (number) Required number argument
        <input> (default stdin)  A parameter which is an input file
        <output> (default stdout) One that is an output file
    ]]
    print 'args'
    for k,v in pairs(args) do
        print(k,v)
    end

This produces the following output:

    $ args -o name -n 2 10 args.lua
    +       o       name
    +       n       2
    +       start   10
    +       input   args.lua
    args
    p       false
    s       1
    input_name      args.lua
    quiet   false
    output  file (781C1B98)
    start   10
    input   file (781C1BD8)
    o       name
    n       2

Callbacks are needed when you want to take action immediately on parsing an
argument.

#### Slack Mode

If you'd like to use a multi-letter 'short' parameter you need to set
the `lapp.slack` variable to `true`.

In the following example we also see how default `false` and default `true` flags can be used
and how to overwrite the default `-h` help flag (`--help` still works fine) - this applies
to non-slack mode as well.

    -- Parsing the command line ----------------------------------------------------
    -- test.lua
    local lapp = require 'pl.lapp'
    local pretty = require 'pl.pretty'
    lapp.slack = true
    local args = lapp [[
    Does some calculations
       -v, --video              (string)             Specify input video
       -w, --width              (default 256)        Width of the video
       -h, --height             (default 144)        Height of the video
       -t, --time               (default 10)         Seconds of video to process
       -sk,--seek               (default 0)          Seek number of seconds
       -f1,--flag1                                   A false flag
       -f2,--flag2                                   A false flag
       -f3,--flag3              (default true)       A true flag
       -f4,--flag4              (default true)       A true flag
    ]]

    pretty.dump(args)

And here we can see the output of `test.lua`:

    $> lua test.lua -v abc --time 40 -h 20 -sk 15 --flag1 -f3
    ---->
    {
      width = 256,
      flag1 = true,
      flag3 = false,
      seek = 15,
      flag2 = false,
      video = abc,
      time = 40,
      height = 20,
      flag4 = true
    }

### Simple Test Framework

`pl.test` was originally developed for the sole purpose of testing Penlight itself,
but you may find it useful for your own applications. ([There are many other options](http://lua-users.org/wiki/UnitTesting).)

Most of the goodness is in `test.asserteq`.  It uses `tablex.deepcompare` on its two arguments,
and by default quits the test application with a non-zero exit code, and an informative
message printed to stderr:

    local test = require 'pl.test'

    test.asserteq({10,20,30},{10,20,30.1})

    --~ test-test.lua:3: assertion failed
    --~ got:	{
    --~  [1] = 10,
    --~  [2] = 20,
    --~  [3] = 30
    --~ }
    --~ needed:	{
    --~  [1] = 10,
    --~  [2] = 20,
    --~  [3] = 30.1
    --~ }
    --~ these values were not equal

This covers most cases but it's also useful to compare strings using `string.match`

    -- must start with bonzo the dog
    test.assertmatch ('bonzo the dog is here','^bonzo the dog')
    -- must end with an integer
    test.assertmatch ('hello 42','%d+$')

Since Lua errors are usually strings, this matching strategy is used to test 'exceptions':

    test.assertraise(function()
        local t = nil
        print(t.bonzo)
    end,'nil value')

(Some care is needed to match the essential part of the thrown error if you care
for portability, since in Lua 5.2
the exact error is "attempt to index local 't' (a nil value)" and in Lua 5.3 the error
is "attempt to index a nil value (local 't')")

There is an extra optional argument to these test functions, which is helpful when writing
test helper functions. There you want to highlight the failed line, not the actual call
to `asserteq` or `assertmatch` - line 33 here is the call to `is_iden`

    function is_iden(str)
        test.assertmatch(str,'^[%a_][%w_]*$',1)
    end

    is_iden 'alpha_dog'
    is_iden '$dollars'

    --~ test-test.lua:33: assertion failed
    --~ got:	"$dollars"
    --~ needed:	"^[%a_][%w_]*$"
    --~ these strings did not match

Useful Lua functions often return multiple values, and `test.tuple` is a convenient way to
capture these values, whether they contain nils or not.

    T = test.tuple

    --- common error pattern
    function failing()
        return nil,'failed'
    end

    test.asserteq(T(failing()),T(nil,'failed'))

