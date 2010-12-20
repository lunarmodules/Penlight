![penlight](penlight.jpg)
# Penlight - A Portable Lua Library

The module documentation is available [here](api/index.html); and there is an alphabetical [function index](function_index.html).

The latest vesion is available at [Github](http://github.com/stevedonovan/Penlight).

## Introduction

### Purpose

It is often said of Lua that it does not include batteries. That is because the goal of Lua is to produce a lean expressive language that will be used on all sorts of machines, (some of which don't even have hierarchical filesystems). The Lua language is the equivalent of an operating system kernel; the creators of Lua do not see it as their responsibility to create a full software ecosystem around the language. That is the role of the community.

A principle of software design is to recognize common patterns and reuse them. If you find yourself writing things like `io.write(string.format('the answer is %d ',42))` more than a number of times then it becomes useful just to define a function `printf`. This is good, not just because repeated code is harder to maintain, but because such code is easier to read, once people understand your libraries.

Penlight captures many such code patterns, so that the intent of your code becomes clearer. For instance, a Lua idiom to copy a table is `{unpack(t)}`, but this will only work for 'small' tables (for a given value of 'small') so it is not very robust. Also, the intent is not clear. So `tablex.deepcopy` is provided, which will also copy nested tables and and associated metatables, so it can be used to clone complex objects.

The default error handling policy follows that of the Lua standard libraries: if a argument is the wrong type, then an error will be thrown, but otherwise we return `nil,message` if there is a problem. There are some exceptions; functions like `input.fields` default to shutting down the program immediately with a useful message. This is more appropriate behaviour for a _script_ than providing a stack trace. (However, this default can be changed.) The lexer functions always throw errors, to simplify coding, and so should be wrapped in `pcall`.

By default, the error stacktrace starts with your code, since you are not usually interested in the internal details of the library.

If you are used to Python conventions, please note that all indices consistently start at 1.

The Lua function `table.foreach` has been deprecated in favour of the `for in` statement, but such an operation becomes particularly useful with the higher-order function support in Penlight. Note that `tablex.foreach` reverses the order, so that the function is passed the value and then the key. Although perverse, this matches the intended use better.

The only important external dependence of Penlight is LuaFileSystem (`lfs`), and if you want `dir.copyfile` to work cleanly on Windows, you will need `alien` as well. (The fallback is to call the equivalent shell commands.)

Some of the examples in this guide were created using [ilua](http://lua-users.org/wiki/InteractiveLua), which doesn't require '=' to print out expressions, and will attempt to print out table results as nicely as possible.  This is also available under Lua for Windows, as a library, so the command `lua -lilua -s` will work (the s option switches off 'strict' variable checking, which is annoying and conflicts with the use of `_DEBUG` in some of these libraries.

### To Inject or not to Inject?

It was realized a long time ago that large programs needed a way to keep names distinct by putting them into tables (Lua), namespaces (C++) or modules (Python).  It is obviously impossible to run a company where everyone is called 'Bruce', except in Monty Python skits. These 'namespace clashes' are more of a problem in a simple language like Lua than in C++, because C++ does more complicated lookup over 'injected namespaces'.  However, in a small group of friends, 'Bruce' is usually unique, so in particular situations it's useful to drop the formality and not use last names. It depends entirely on what kind of program you are writing, whether it is a ten line script or a ten thousand line program.

So the Penlight library provides the formal way and the informal way, without imposing any preference. You can do it formally like:

    require 'pl.utils'
    pl.utils.printf("%s\n","hello, world!")

or informally like:

    require 'pl'
    utils.printf("%s\n","That feels better")

`require 'pl'` makes all the separate Penlight modules available, without needing to require them each individually.

This is also commonly done like so, especially when writing modules:

    local utils = require 'pl.utils'
    utils.printf("The answer is %d\n",42)

Penlight will not bring in functions into the global table, or clobber standard tables like 'io'.  require('pl') will bring tables like 'utils','tablex',etc into the global table _if they are used_. This 'load-on-demand' strategy ensures that the whole kitchen sink is not loaded up front.

You have an option to bring the `pl.stringx` methods into the standard string table. All strings have a metatable that allows for automatic lookup in `string`, so we can say `s:upper()`. Importing `stringx` allows for its functions to also be called as methods: `s:strip()`,etc:

    require 'pl'
    stringx.import()

or, more explicitly:

    require('pl.stringx').import()

A more delicate operation is importing tables into the local environment. This is convenient when the context makes the meaning of a name very clear:

    > require 'pl'
    > utils.import(math)
    > = sin(1.2)
    0.93203908596723

`utils.import` can also be passed a module name, which is first required and then imported. If used in a module, `import` will bring the symbols into the module context.

Keeping the global scope simple is very necessary with dynamic languages. Using global variables in a big program is always asking for trouble, especially if you don't have the spell-checking provided by a compiler. The `pl.strict` module enforces a simple rule: globals must be 'declared'.  This means that they must be assigned before use; assigning to `nil` is sufficient.

    > require 'pl.strict'
    > print(x)
    stdin:1: variable 'x' is not declared
    > x = nil
    > print(x)
    nil

The `strict` module provided by Penlight is compatible with the 'load-on-demand' scheme used by `require 'pl`.

`strict` also disallows assignment to global variables, except in the main program. Generally, modules have no business messing with global scope; if you must do it, then use a call to `rawset`. Simularly, if you have to check for the existance of a global, use `rawget`.

If you wish to enforce strictness globally, then just add `require 'pl.strict'` at the end of `pl/init.lua`.

### What are function arguments in Penlight?

Many functions in Penlight themselves take function arguments, like `map` which applies a function to a list, element by element.  You can use existing functions, like `math.max`, anonymous functions (like `function(x,y) return x > y end`), or operations by name (e.g '*' or '..').  The module `pl.operator` exports all the standard Lua operations, like the Python module of the same name. Penlight allows these to be refered to by name, so `operator.gt` can be more concisely expressed as '>'.

Note that the `map` functions pass any extra arguments to the function, so we can have `ls:filter('>',0)`, which is effectively `ls:filter(function(x) return x > 0 end)`.

Finally, `pl.func` supports _placeholder expressions_ in the Boost style, so that an anonymous function to multiply the two arguments can be expressed as `_1*_2`.

To use them directly, note that _all_ function arguments in Penlight go through `utils.function_arg`:

    > FA = utils.function_arg
    > f = FA '+'
    > f(10,20)
    30
    > f = FA '|x| x+1'
    > f(10)
    11


### Pros and Cons of Loopless Programming

The standard loops-and-ifs 'imperative' style of programming is dominant, and often seems to be the 'natural' way of telling a machine what to do. It is in fact very much how the machine does things, but we need to take a step back and find ways of expressing solutions in a higher-level way.  For instance, applying a function to all elements of a list is a common operation:

    local res = {}
    for i = 1,#ls do
        res[i] = fun(ls[i])
    end

This can be efficiently and succintly expressed as `ls:map(fun)`. Not only is there less typing but the intention of the code is clearer. If readers of your code spend too much time trying to guess your intention by analyzing your loops, then you have failed to express yourself clearly. Simularly, `ls:filter('>',0)` will give you all the values in a list greater than zero. (Of course, if you don't feel like using `List`, or have non-list-like tables, then `pl.tablex` offers the same facilities. In fact, the `List` methods are implemented using `tablex' functions.)

A common observation is that loopless programming is less efficient, particularly in the way it uses memory. `ls1:map2('*',ls2):reduce '+'` will give you the dot product of two lists, but an unnecessary temporary list is created.  But efficiency is relative to the actual situation, it may turn out to be _fast enough_, or may not appear in any crucial inner loops, etc.

Writing loops is 'error-prone and tedious', as Stroustrup says. But any half-decent editor can be taught to do much of that typing for you. The question should actually be: is it tedious to _read_ loops?  As with natural language, programmers tend to read chunks at a time. A for-loop causes no suprise, and probably little brain activity. One argument for loopless programming is the loops that you _do_ write stand out more, and signal 'something different happening here'.  It should not be an all-or-nothing thing, since most programs require a mixture of idioms that suit the problem.  Some languages (like APL) do nearly everything with map and reduce operations on arrays, and so solutions can sometimes seem forced. Wisdom is knowing when a particular idiom makes a particular problem easy to _solve_ and the solution easy to _explain_ afterwards.


### Utilities. Generally useful functions.

The function `printf` discussed earlier is included in `pl.utils` because it makes properly formatted output easier. (There is an equivalent `fprintf` which also takes a file object parameter, just like the C function.)

Utility functions like `is_callable` and `is_type` help with identifying what kind of animal you are dealing with. Obviously, a function is callable, but an object can be callable as well if it has overriden the `__call` metamethod. The Lua `type` function handles the basic types, but can't distinguish between different kinds of objects, which are all tables. So `is_type` handles both cases, like `is_type(s,"string")` and `is_type(ls,List)`.

A common pattern when working with Lua varargs is capturing all the arguments in a table:

    function t(...)
        local args = {...}
        ...
    end

But this will bite you someday when `nil` is one of the arguments, since this will put a 'hole' in your table. In particular, `#ls` will only give you the size upto the `nil` value.  Hence the need for `table.pack` - this is a new Lua 5.2 function which Penlight defines also for Lua 5.1.

    function t(...)
        local args,n = table.pack(...)
        for i = 1,n do
          ...
        end
    end

The 'memoize' pattern occurs when you have a function which is expensive to call, but will always return the same value subsequently. `utils.memoize` is given a function, and returns another function. This calls the function the first time, saves the value for that argument, and thereafter for that argument returns the saved value.  This is a more flexible alternative to building a table of values upfront, since in general you won't know what values are needed.

    sum = utils.memoize(function(n)
        local sum = 0
        for i = 1,n do sum = sum + i end
        return sum
    end)
    ...
    s = sum(1e8) --takes time!
    ...
    s = sum(1e8) --returned saved value!

<a id="app"/>
### Application Support

`app.parse_args` is a simple command-line argument parser. If called without any arguments, it tries to use the global `arg` array.  It returns the _flags_ (options begining with '-') as a table of name/value pairs, and the _arguments_ as an array.  It knows about long GNU-style flag names, e.g. `--value`, and groups of short flags are understood, so that `-ab` is short for `-a -b`. The flags result would then look like `{value=true,a=true,b=true}`.

Flags may take values. The command-line `--value=open -n10` would result in `{value='open',n='10'}`; generally you can use '=' or ':' to separate the flag from its value, except in the special case where a short flag is followed by an integer.  Or you may specify upfront that some flags have associated values, and then the values will follow the flag.

	> require 'pl'
	> flags,args = utils.parse_args({'-o','fred','-n10','fred.txt'},{o=true})
	> dump(flags)
	{o='fred',n='10'}

`parse_args` is not intelligent or psychic; it will not convert any flag values or arguments for you, or raise errors. For that, have a look at [#lapp](pl.lapp).

An application which consists of several files cannot use `require` to load files in the same directory as the main script.  `app.require_here()` ensures that the Lua module path is modified so that files found locally are found first. In the `examples` directory, `test-symbols.lua` uses this function to ensure that it can find `symbols.lua` even if it is not run from this directory.

`app.appfile` will create a filename that your application can use to store its private data, based on the script name. For example, `app.appfile "test.txt"` from a script called `testapp.lua` produces the following file on my Windows machine:

	C:\Documents and Settings\SJDonova\.testapp\test.txt

and the equivalent on my Linux machine:

	/home/sdonovan/.testapp/test.txt

Penlight makes it convenient to save application data in Lua format. You can use `pretty.dump(t,file)` to write a Lua table in a human-readable form to a file, and `pretty.read(file.read(file))` to generate the table again.

(@see app, @see pretty)


<a id="class"/>

### Classes. Simplifying Object-Oriented Programming in Lua

Lua is similar to JavaScript in that the concept of class is not directly supported by the language. In fact, Lua has a very general mechanism for extending the behaviour of tables which makes it straightforward to implement classes. A table's behaviour is controlled by its metatable. If that metatable has a `__index` function or table, this will handle looking up anything which is not found in the original table. A class is just a table with an `__index` key pointing to itself. Creating an object involves making a table and setting its metatable to the class; then when handling `obj.fun`, Lua first looks up `fun` in the table `obj`, and if not found it looks it up in the class. `obj:fun(a)` is just short for `obj.fun(obj,a)`. So with the metatable mechanism and this bit of syntactic sugar, it is straightforward to implement classic object orientation.

    -- animal.lua

    class = require 'pl.class'.class

    class.Animal()

    function Animal:_init(name)
        self.name = name
    end

    function Animal:__tostring()
      return self.name..': '..self:speak()
    end

    class.Dog(Animal)

    function Dog:speak()
      return 'bark'
    end

    class.Cat(Animal)

    function Cat:_init(name,breed)
        self:super(name)  -- must init base!
        self.breed = breed
    end

    function Cat:speak()
      return 'meow'
    end

    class.Lion(Cat)

    function Lion:speak()
      return 'roar'
    end

    fido = Dog('Fido')
    felix = Cat('Felix','Tabby')
    leo = Lion('Leo','African')

    $ lua -i animal.lua
    > = fido,felix,leo
    Fido: bark      Felix: meow     Leo: roar
    > = leo:is_a(Animal)
    true
    > = leo:is_a(Dog)
    false
    > = leo:is_a(Cat)
    true

All Animal does is define `__tostring`, which Lua will use whenever a string representation is needed of the object. In turn, this relies on `speak`, which is not defined. So it's what C++ people would call an abstract base class; the specific derived classes like Dog define `speak`. (Please note that if derived classes have their own constructors, they must explicitly call the base constructor for their base class; this is conveniently available as the `super` method.)

All such objects will have a `is_a` method, which looks up the inheritance chain to find a match.  Another form is `class_of`, which can be safely called on all objects, so instead of `leo:is_a(Animal)` one can say `Animal:class_of(leo)`.

There are two ways to define a class, either `class.Name()` or `Name = class()`; both work identically, except that the first form will always put the class in the current environment (whether global or module); the second form provides more flexibility about where to store the class. The first form does _name_ the class by setting the `_name` field, which can be useful in identifying the objects of this type later. This session illustrates the usefulness of having named classes, if no `__tostring` method is explicitly defined.

    > class.Fred()
    > a = Fred()
    > = a
    Fred: 00459330
    > Alice = class()
    > b = Alice()
    > = b
    table: 00459AE8
    > Alice._name = 'Alice'
    > = b
    Alice: 00459AE8

So `Alice = class(); Alice._name = 'Alice'` is exactly the same as `class.Alice()`.

This useful notation is borrowed from Hugo Etchegoyen's [classlib](http://lua-users.org/wiki/MultipleInheritanceClasses) which further extends this concept to allow for multiple inheritance.


## Tables and Arrays

<a id="list"/>

### Python-style Lists

One of the elegant things about Lua is that tables do the job of both lists and dicts (as called in Python) or vectors and maps, (as called in C++), and they do it efficiently.  However, if we are dealing with 'tables with numerical indices' we may as well call them lists and look for operations which particularly make sense for lists. The Penlight `List` class was originally written by Nick Trout for Lua 5.0, and translated to 5.1 and extended by myself.  It seemed that borrowing from Python was a good idea, and this eventually grew into Penlight. (@see list)

Here is an example showing `List` in action; it redefines `__tostring`, so that it can print itself out more sensibly:

    > l = List()
    > l:append(10)
    > l:append(20)
    > = l
    {10,20}
    > l:extend {30,40}
    {10,20,30,40}
    > l:insert(1,5)
    {5,10,20,30,40}
    > = l:pop()
    40
    > = l
    {5,10,20,30}
    > = l:index(30)
    4
    > = l:contains(30)
    true
    > = l:reverse()  ---> note: doesn't make a copy!
    {30,20,10,5}

Although methods like `sort` and `reverse` operate in-place and change the list, they do return the original list. This makes it possible to do _method chaining_, like `ls = ls:append(10):append(20):reverse():append(1)`. But (and this is an important but) no extra copy is made, so `ls` does not change identity. `List` objects (like tables) are _mutable_, unlike strings. If you want a copy of a list, then `List(ls)` will do the job, i.e. it acts like a copy constructor. However, if passed any other table, `List` will just set the metatable of the table and _not_ make a copy.

A particular feature of Python lists is _slicing_. This is fully supported in this version of `List`, except we use 1-based indexing. So `List.slice` works rather like `string.sub`:

    > l = List {10,20,30,40}
    > = l:slice(1,1)  ---> note: creates a new list!
    {10}
    > = l:slice(2,2)
    {20}
    > = l:slice(2,3)
    {20,30}
    > = l:slice(2,-2)
    {20,30}
    > = l:slice_assign(2,2,{21,22,23})
    {10,21,22,23,30,40}
    > = l:chop(1,1)
    {21,22,23,30,40}

Functions like `slice_assign` and `chop` modify the list; the first is equivalent to Python`l[i1:i2] = seq` and the second to `del l[i1:i2]`.

List objects are ultimately just Lua 'list-like' tables, but they have extra operations defined on them, such as equality and concatention.  For regular tables, equality is only true if the two tables are _identical objects_, whereas two lists are equal if they have the same contents, i.e. that `l1[i]==l2[i]` for all elements.

    > l1 = List {1,2,3}
    > l2 = List {1,2,3}
    > = l1 == l2
    true
    > = l1..l2
    {1,2,3,1,2,3}

The `List` constructor can be passed a function. If so, it's assumed that this is an iterator function that can be repeatedly called to generate a sequence.  One such function is `io.lines`; the following short, intense little script counts the number of lines in standard input:

    -- linecount.lua
    require 'pl'
    ls = List(io.lines())
    print(#ls)

`pl.list.iter` captures what `List` considers a sequence. In particular, it can also iterate over all 'characters' in a string:

    > for ch in pl.list.iter 'help' do io.write(ch,' ') end
    h e l p >

Since the function `iter` is used internally by the `List` constructor, strings can be made into lists of character strings very easily.

There are a number of operations that go beyond the standard Python methods. For instance, you can _partition_ a list into a table of sublists using a function. In the simplest form, you use a predicate (a function returning a boolean value) to partition the list into two lists, one of elements matching and another of elements not matching. But you can use any function; if we use `type` then the keys will be the standard Lua type names.

    > ls = List{1,2,3,4}
    > ops = require 'pl.operator'
    > ls:partition(function(x) return x > 2 end)
    {false={1,2},true={3,4}}
    > ls = List{'one',math.sin,List{1},10,20,List{1,2}}
    > ls:partition(type)
    {function={function: 00369110},string={one},number={10,20},table={{1},{1,2}}}

This is one `List` method which returns a table which is not a `List`. Bear in mind that you can always call a `List` method on a plain table argument, so `List.partition(t,type)` works as expected. But these functions will only operate on the array part of the table.

Stacks occur everywhere in computing. `List` supports stack-like operations; there is already `pop` (remove and return last value) and `append` acts like `push` (add a value to the end). `push` is provided as an alias for `append`, and the other stack operation (size) is simply the size operator `#`.  Queues can also be implemented; you use `pop` to take values out of the queue, and `put` to insert a value at the begining.


### Map and Set classes

The `Map` class exposes what Python would call a 'dict' interface, and accesses the hash part of the table. The name 'Map' is used to emphasize the interface, not the implementation; it is an object which maps keys onto values; `m['alice']` or the equivalent `m.alice` is the access operation.  This class also provides explicit `set` and `get` methods, which are trivial for regular maps but get interesting when `Map` is subclassed. The other operation is `update`, which extends a map by copying the keys and values from another table, perhaps overwriting existing keys:

    > Map = require 'pl.class' . Map
    > m = Map{one=1,two=2}
    > m:update {three=3,four=4,two=20}
    > = m == M{one=1,two=20,three=3,four=4}
    true

The method `values` returns a list of the values, and `keys` returns a list of the keys; there is no guarantee of order. `getvalues` is given a list of keys and returns a list of values associated with these keys:

    > m = Map{one=1,two=2,three=3}
    > = m:getvalues {'one','three'}
    {1,3}
    > = m:getvalues(m:keys()) == m:values()
    true

When querying the value of a `Map`, it is best to use the `get` method:

    > print(m:get 'one', m:get 'two')
    1     2

The reason is that `m[key]` can be ambiguous; due to the current implementation, `m["get"]` will always succeed, because if a value is not present in the map, it will be looked up in the `Map` metatable, which contains a method `get`. There is currently no simple solution to this annoying restriction.

A `Set` is a special kind of `Map`, where all the values are `true`. So `get` will always return either `true` or `nil`; all the values are keys, and the order is not important. So in this case `values` is defined to return a list of the keys.  Sets can display themselves, and the basic operations like `union` (`+`) and `intersection` (`*`) are defined.

    > Set = pl.class.Set
    > = Set{'one','two'} == Set{'two','one'}
    true
    > fruit = Set{'apple','banana','orange'}
    > = fruit['banana']
    true
    > = fruit['hazelnut']
    nil
    > = fruit:values()
    {apple,orange,banana}
    > colours = Set{'red','orange','green','blue'}
    > = fruit,colours
    [apple,orange,banana]   [blue,green,orange,red]
    > = fruit+colours
    [blue,green,apple,red,orange,banana]
    > = fruit*colours
    [orange]

There are also the methods `difference` and `symmetric_difference`. The first answers the question 'what fruits are not colours?' and the second 'what are fruits and colours but not both?'

    > = fruit - colours
    [apple,banana]
    > = fruit ^ colours
    [blue,green,apple,red,banana]

Adding elements to a set is either done like `fruit['peach'] = true` or by `fruit:set('peach')`. Removing is either `fruit['apple'] = nil` or `fruit:unset('apple')`.

`pl.classx` defines some useful classes which also inherit from `Map`. An `OrderedMap` behaves like a `Map` but keeps its keys in order if you use its `set` method to add keys and values.  Like all the 'container' classes in Penlight, it defines an `iter` method for iterating over its values; this will return the keys and values in the order of insertion; the `keys` and `values` methods likewise.

A `MultiMap` allows multiple values to be associated with a given key. So `set` (as before) takes a key and a value, but calling it with the same key and a different value does not overwrite but adds a new value. `get` (or using `[]`) will return a list of values.

There are occaisions when 'type-safe' containers can be very useful. These can only accept values of a particular kind. `TypedList` is a base class for lists of values of a particular type.

    class.StringList(TypedList,'string')

    sl = StringList()

    sl:append 'hello'
    sl:append (10)  --> error! 'not a string'
    sl:extend {'hello'} --> error! 'cannot extend with another List type'

The extra parameter can either be a Lua type (here 'string') or a previously defined class type (i.e. works like `pl.utils.is_type`)

In general, this parameter is meant to be passed to the _class constructor_. In classx.lua, `TypedList` defines this by defining a special class method called `_class_init`:

    function TypedList._class_init (klass,type)
        klass._type = type
        klass._name = 'TypedList<'..name_of_type(type)..'>'
    end


(@see class, @see classx)

### Tablex. Useful Operations on Tables

Some notes on terminology: Lua tables are usually _list-like_ (like an array) or _map-like_ (like an associative array or dict); they can of course have a list-like and a map-like part. Some of the table operations only make sense for list-like tables, and some only for map-like tables. (The usual Lua terminology is the array part and the hash part of the table, which reflects the actual implementation used.)

The functions provided in `table` provide all the basic manipulations on Lua tables, but as we saw with the `List` class, it is useful to build higher-level operations on top of those functions. For instance, to copy a table involves this kind of loop:

    local res = {}
    for k,v in pairs(T) do
        res[k] = v
    end
    return res

The `tablex` module (@see tablex) provides this as `copy`, which does a _shallow_ copy of a table. There is also `deepcopy` which goes further than a simple loop in two ways; first, it also gives the copy the same metatable as the original (so it can copy objects like `List` above) and any nested tables will also be copied, to arbitrary depth. There is also `icopy` which operates on list-like tables, where you can set optionally set the start index of the source and destination as well. It ensures that any left-over elements will be deleted:

    asserteq(icopy({1,2,3,4,5,6},{20,30}),{20,30})   -- start at 1
    asserteq(icopy({1,2,3,4,5,6},{20,30},2),{1,20,30}) -- start at 2
    asserteq(icopy({1,2,3,4,5,6},{20,30},2,2),{1,30}) -- start at 2, copy from 2

(This code from the `tablex` test module shows the use of `pl.test.asserteq`)

Whereas, `move` overwrites but does not delete the rest of the destination:

    asserteq(move({1,2,3,4,5,6},{20,30}),{20,30,3,4,5,6})
    asserteq(move({1,2,3,4,5,6},{20,30},2),{1,20,30,4,5,6})
    asserteq(move({1,2,3,4,5,6},{20,30},2,2),{1,30,3,4,5,6})

(The difference is somewhat like that between C's `strcpy` and `memmove`.)

To summarize, use `copy` or `deepcopy` to make a copy of an arbitrary table. To copy into a map-like table, use `update`; to copy into a list-like table use `icopy`, and `move` if you are updating a range in the destination.

To complete this set of operations, there is `insertvalues` which works like `table.insert` except that one provides a table of values to be inserted, and `removevalues` which removes a range of values.

    asserteq(insertvalues({1,2,3,4},2,{20,30}),{1,20,30,2,3,4})
    asserteq(insertvalues({1,2},{3,4}),{1,2,3,4})

Another example:

    > T = require 'pl.tablex'
    > t = {10,20,30,40}
    > T.removevalues(t,2,3)
    {10,40}
    > T.insertvalues(t,2,{20,30})
    {10,20,30,40}


In a similar spirit to `deepcopy`, `deepcompare` will take two tables and return true only if they have exactly the same values and structure.

    > t1 = {1,{2,3},4}
    > t2 = deepcopy(t1)
    > = t1 == t2
    false
    > = deepcompare(t1,t2)
    true

`find` will return the index of a given value in a list-like table. Note that like `string.find` you can specify an index to start searching, so that all instances can be found. There is an optional fourth argument, which makes the search start at the end and go backwards, so we could define `rfind` like so:

    function rfind(t,val,istart)
        return tablex.find(t,val,istart,true)
    end

`find` does a linear search, so it can slow down code that depends on it.  If efficiency is required for large tables, consider using an _index map_. `index_map` will return a table where the keys are the original values of the list, and the associated values are the indices. (It is almost exactly the representation needed for a _set_.)

    > t = {'one','two','three'}
    > = tablex.find(t,'two')
    2
    > = tablex.find(t,'four')
    nil
    > il = tablex.index_map(t)
    > il['two']
    2
    > il.two
    2

A version of `index_map` called `makeset` is also provided, where the values are just `true`. This is useful because two such sets can be compared for equality using `deepcompare`:

    > deepcompare(makeset {1,2,3},makeset {2,1,3})
    true

Consider the problem of determining the new employees that have joined in a period. Assume we have two files of employee names:

    (last-month.txt)
    smith,john
    brady,maureen
    mongale,thabo

    (this-month.txt)
    smith,john
    smit,johan
    brady,maureen
    mogale,thabo
    van der Merwe,Piet

To find out differences, just make the employee lists into sets, like so:

    require 'pl'

    function read_employees(file)
      local ls = List(io.lines(file)) -- a list of employees
      return tablex.makeset(ls)
    end

    last = read_employees 'last-month.txt'
    this = read_employees 'this-month.txt'

    -- who is in this but not in last?
    diff = tablex.difference(this,last)

    -- in a set, the keys are the values...
    for e in pairs(diff) do print(e) end

    --  *output*
    -- van der Merwe,Piet
    -- smit,johan

The `difference` operation is easy to write and read:

    for e in pairs(this) do
      if not last[e] then
        print(e)
      end
    end

Using `difference` here is not that it is a tricky thing to code, it is that you are stating your intentions clearly to other readers of your code. (And naturally to your future self, in six months time.)

`find_if` will search a table using a function. The optional third argument is a value which will be passed as a second argument to the function. `pl.operator` provides the Lua operators conveniently wrapped as functions, so the basic comparison functions are available:

    > ops = require 'pl.operator'
    > = tablex.find_if({10,20,30,40},ops.gt,20)
    3       true

Note that `find_if` will also return the _actual value_ returned by the function, which of course is usually just  `true` for a boolean function, but any value which is not `nil` and not `false` can be usefully passed back.

`deepcompare` does a thorough recursive comparison, but otherwise using the default equality operator. `compare` allows you to specify exactly what function to use when comparing two list-like tables, and `compare_no_order` is true if they contain exactly the same elements. Do note that the latter does not need an explicit comparison function - in this case the implementation is actually to compare the two sets, as above:

    > compare_no_order({1,2,3},{2,1,3})
    true
    > compare_no_order({1,2,3},{2,1,3},'==')
    true

(Note the special string '==' above; instead of saying `ops.gt` or `ops.eq` we can use the strings '>' or '==' respectively.)

There are several ways to merge tables in PL. If they are list-like, then see the operations defined by `pl.list.List`, like concatenation. If they are map-like, then `merge` provides two basic operations. If the third arg is false, then the result only contains the keys that are in common between the two tables, and if true, then the result contains all the keys of both tables. These are in fact generalized set union and intersection operations:

    > S1 = {john=27,jane=31,mary=24}
    > S2 = {jane=31,jones=50}
    > tablex.merge(S1,S2,false)
    {jane=31}
    > tablex.merge(S1,S2,true)
    {mary=24,jane=31,john=27,jones=50}

When working with tables, you will often find yourself writing loops like in the first example. Loops are second nature to programmers, but they are often not the most elegant and self-describing way of expressing an operation. Consider the `map` function, which creates a new table by applying a function to each element of the original:

    > = map(math.sin,{1,2,3,4})
    {  0.84,  0.91,  0.14, -0.76}
    > = map(function(x) return x*x end,{1,2,3,4})
    {1,4,9,16}

`map` saves you from writing a loop, and the resulting code is often clearer, as well as being shorter. This is not to say that 'loops are bad' (although you will hear that from some extremists), just that it's good to capture standard patterns. Then the loops you do write will stand out and acquire more significance.

`pairmap` is interesting, because the function works with both the key and the value.

    > t = {fred=10,bonzo=20,alice=4}
    > = pairmap(function(k,v) return v end, t)
    {4,10,20}
    > = pairmap(function(k,v) return k end, t)
    {'alice','fred','bonzo'}

(These are common enough operations that the first is defined as `values` and the second as `keys`.) If the function returns two values, then the _second_ value is considered to be the new key:

    > = pairmap(t,function(k,v) return v+10,k:upper() end)
    {BONZO=30,FRED=20,ALICE=14}

`map2` applies a function to two tables:

    > map2(ops.add,{1,2},{10,20})
    {11,22}
    > map2('*',{1,2},{10,20})
    {10,40}

The various map operations generate tables; `reduce` applies a function of two arguments over a table and returns the result as a scalar:

    > reduce ('+',{1,2,3})
    6
    > reduce ('..',{'one','two','three'})
    'onetwothree'

Finally, `zip` sews different tables together:

    > = zip({1,2,3},{10,20,30})
    {{1,10},{2,20},{3,30}}

Browsing through the documentation, you will find that `tablex` and `List` share methods.  For instance, `tablex.imap` and `List.map` are basically the same function; they both operate over the array-part of the table and generate another table. This can also be expressed as a _list comprehension_ `C 'f(x) for x' (t)` which makes the operation more explicit. So why are there different ways to do the same thing? The main reason is that not all tables are Lists: the expression `ls:map('#')` will return a _list_ of the lengths of any elements of `ls`. A list is a thin wrapper around a table, provided by the metatable `List`. Sometimes you may wish to work with ordinary Lua tables; the `List` interface is not a compulsory way to use Penlight table operations.


### Operations on two-dimensional tables

two-dimensional tables are of course easy to represent in Lua, for instance `{{1,2},{3,4}}` where we store rows as subtables and index like so `A[col][row]`. This is the common representation used by matrix libraries like [LuaMatrix](http://lua-users.org/wiki/LuaMatrix). `pl.array2d` does not provide matrix operations, since that is the job for a specialized library, but rather provides generalizations of the higher-level operations provided by `pl.tablex` for one-dimensional arrays.

`iter` is a useful generalization of `ipairs`. (The extra parameter determines whether you want the indices as well.)

    > array = require 'pl.array2d'
    > a = {{1,2},{3,4}}
    > for i,j,v in array2d.iter(a,true) do print(i,j,v) end
    1       1       1
    1       2       2
    2       1       3
    2       2       4

Bear in mind that you can always convert an arbitrary 2D array into a 'list of lists' with `List(tablex.map(List,a))`

`map` will apply a function over all elements (notice that extra arguments can be provided, so the operation is in effect `function(x) return x-1 end`)

    > array2d.map('-',a,1)
    {{0,1},{2,3}}

2D arrays are stored as an array of rows, but columns can be extracted:

    > array2d.column(a,1)
    {1,3}

There are three equivalents to `tablex.reduce`. You can either reduce along the rows (which is the most efficient) or reduce along the columns. Either one will give you a 1D array. And `reduce2` will apply two operations: the first one reduces the rows, and the second reduces the result.

    > array2d.reduce_rows('+',a)
    {3,7}
    > array2d.reduce_cols('+',a)
    {4,6}
    > -- same as tablex.reduce('*',array.reduce_rows('+',a))
    > array2d.reduce2('*','+',a)
    21    `

`tablex.map2` applies an operation to two tables, giving another table. `array2d.map2` does this for 2D arrays. Note that you have to provide the _rank_ of the arrays involved, since it's hard to always correctly deduce this from the data:

    > b = {{10,20},{30,40}}
    > array2d.map2('+',2,2,a,b)  -- two 2D arrays
    {{11,22},{33,44}}
    > array2d.map2('+',1,2,{10,100},a)  -- 1D, 2D
    {{11,102},{13,104}}
    > array2d.map2('*',2,1,a,{1,-1})  -- 2D, 1D
    {{1,-2},{3,-4}}

Of course, you are not limited to simple arithmetic. Say we have a 2D array of strings, and wish to print it out with proper right justification. The first step is to create all the string lengths by mapping `string.len` over the array, the second is to reduce this along the columns using `math.max` to get maximum column widths, and last, apply `string.rjust` with these widths.

    maxlens = reduce_cols(math.max,map('#',lines))
    lines = map2(string.rjust,2,1,lines,maxlens)

There is `product` which returns  the _Cartesian product_ of two 1D arrays. The result is a 2D array formed from applying the function to all possible pairs from the two arrays.

    > array2d.product('{}',{1,2},{'a','b'})
    {{{1,'b'},{2,'a'}},{{1,'a'},{2,'b'}}}

There is a set of operations which work in-place on 2D arrays. You can `swap_rows` and `swap_cols`; the first really is a simple one-liner, but the idea is to give the operation a name. `remove_row` and `remove_col' are generalizations of `table.remove`. Likewise, `extract_rows` and `extract_cols` are given arrays of indices and discard anything else. So, for instance, `extract_cols(A,{2,4})` will leave just columns 2 and 4 in the array.

`List.slice` is often useful on 1D arrays; `array2d.slice` does the same thing, but is generally given a start (row,column) and a end (row,column).

    > A = {{1,2,3},{4,5,6},{7,8,9}}
    > B = slice(A,1,1,2,2)
    > write(B)
     1 2
     4 5
    > B = slice(A,2,2)
    > write(B,nil,'%4.1f')
     5.0 6.0
     8.0 9.0

Here `array2d.write` is used to print out an array nicely; the second parameter is `nil`, which is the default (stdout) but can be any file object and the third parameter is an optional format (as used in `string.format`).

`parse_range` will take a spreadsheet range like 'A1:B2' or 'R1C1:R2C2' and return the range as four numbers, which can be passed to `slice`. The rule is that `slice` will return an array of the appropriate shape depending on the range; if a range represents a row or a column, the result is 1D, otherwise 2D.

This applies to `iter` as well, which can also optionally be given a range:


    > for i,j,v in iter(A,true,2,2) do print(i,j,v) end
    2       2       5
    2       3       6
    3       2       8
    3       3       9

(@see array2d)

## Strings. Higher-level operations on strings.

### Extra String Methods

These are convenient borrowings from Python, as described in 3.6.1 of the Python reference, but note that indices in Lua always begin at one. There are methods like `s:isalpha()` and `s:isdigit()`, which return true if s is only composed of letters or digits respectively. `s:startswith()` and `s:endswith()` are convenient ways to find substrings. (`endswith` works as in Python 2.5, so that `f:endswith {'.bat','.exe','.cmd'}` will be true for any filename which ends with these extensions.) There are justify methods and whitespace trimming functions like `strip`.

    > stringx.import()
    > ('bonzo.dog'):endswith {'.dog','.cat'}
    true
    > ('bonzo.txt'):endswith {'.dog','.cat'}
    false
    > ('bonzo.cat'):endswith {'.dog','.cat'}
    true
    > (' stuff'):ljust(20,'+')
    '++++++++++++++ stuff'
    > ('  stuff '):lstrip()
    'stuff '
    > ('  stuff '):rstrip()
    '  stuff'
    > ('  stuff '):strip()
    'stuff'
    > for s in ('one\ntwo\nthree\n'):lines() do print(s) end
    one
    two
    three

Most of these can be fairly easily implemented using the Lua string library, which is more general and powerful. But they are convenient operations to have easily at hand. Note that can be injected into the `string` table if you use `require 'pl'` and then `stringx.import()`, or explicitly call `pl.stringx.import()`, but a simple alias like 'stringx = require 'pl.string'` can be used. This is the recommended practice when writing modules for consumption by other people, since it is bad manners to change the global state of the rest of the system.

(@see stringx)

### String Templates

Another borrowing from Python, string templates allow you to substitute values looked up in a table:

    local Template = require ('pl.text').Template
    t = Template('${here} is the $answer')
    print(t:substitute {here = 'Lua', answer = 'best'})
    ==>
    Lua is the best

'$ variables' can optionally have curly braces; this form is useful if you are glueing text together to make variables, e.g `${prefix}_name_${postfix}`. The `substitute` method will throw an error if a $ variable is not found in the table, and the `safe_substitute` method will not.

The Lua implementation has an extra method, `indent_substitute` which is very useful for inserting blocks of text, because it adjusts indentation. Consider this example:

    -- testtemplate.lua
    local stringx = require 'pl.stringx'
    local Template = stringx.Template

    t = Template [[
        for i = 1,#$t do
            $body
        end
    ]]

    body = Template [[
    local row = $t[i]
    for j = 1,#row do
        fun(row[j])
    end
    ]]

    print(t:indent_substitute {body=body,t='tbl'})

And the output is:

        for i = 1,#tbl do
            local row = tbl[i]
            for j = 1,#row do
                fun(row[j])
            end
        end

`indent_substitute` can substitute templates, and in which case they themselves will be substituted using the given table. So in this case, `$t` was substituted twice.

`pl.text` also has a number of useful functions like `dedent`, which strips all the initial indentation from a multiline string. As in Python, this is useful for preprocessing multiline strings if you like indenting them with your code. The function `wrap` is passed a long string (a _paragraph_) and returns a list of lines that fit into a desired line width. As an extension, there is also `indent` for indenting multiline strings.

(@see text)


## Paths and Directories

### Working with Paths

Programs should not depend on quirks of your operating system. They will be harder to read, and need to be ported for other systems.  The worst of course is hardcoding paths like 'c:\\' in programs, and wondering why Vista complains so much. But even something like `dir..'\\'..file` is a problem, since Unix can't understand backslashes in this way. `dir..'/'..file` is _usually_ portable, but it's best to put this all into a simple function, `path.join`. If you consistently use `path.join`, then it's much easier to write cross-platform code, since it handles the directory separator for you.


`pl.path` provides the same functionality as Python's `os.path` module (11.1).

    > p = 'c:\\bonzo\\DOG.txt'
    > = path.normcase (p)  ---> only makes sense on Windows
    c:\bonzo\dog.txt
    > = path.splitext (p)
    c:\bonzo\DOG    .txt
    > = path.extension (p)
    .txt
    > = path.basename (p)
    DOG.txt
    > = path.exists(p)
    false
    > = path.join ('fred','alice.txt')
    fred\alice.txt
    > = path.exists 'pretty.lua'
    true
    > = path.getsize 'pretty.lua'
    2125
    > = path.isfile 'pretty.lua'
    true
    > = path.isdir 'pretty.lua'
    false


It is becoming increasingly important for all programmers, not just on Unix, to only write to where they are allowed to write. `path.expanduser` will expand '~' (tilde) into the home directory. Depending on your OS, this will be a guaranteed place where you can create files:

    > = path.expanduser '~/mydata.txt'
    'C:\Documents and Settings\SJDonova/mydata.txt'

    > = path.expanduser '~/mydata.txt'
    /home/sdonovan/mydata.txt

Under Windows, `os.tmpname` returns a path which leads to your drive root full of temporary files. (And increasingly, you do not have access to this root folder.) This is corrected by `path.tmpname`, which uses the environment variable TMP:

    > os.tmpname()  -- not a good place to put temporary files!
    '\s25g.'
    > path.tmpname()
    'C:\DOCUME~1\SJDonova\LOCALS~1\Temp\s25g.1'


A useful extra function is `pl.path.package_path`, which will tell you the path of a particular Lua module.  So on my system, `package_path('pl.path')` returns 'C:\Program Files\Lua\5.1\lualibs\pl\path.lua', and `package_path('ifs')` returns 'C:\Program Files\Lua\5.1\clibs\lfs.dll'. It is implemented in terms of `package.searchpath`, which is a new function in Lua 5.2 which has been implemented for Lua 5.1 in Penlight.

### File Operations

`pl.file` is a new module that provides more sensible names for common file operations. For instance, `file.read` and `file.write` are aliases for `utils.readfile` and `utils.writefile`.

Smaller files can be efficiently read and written in one operation. `file.read` is passed a filename and returns the contents as a string, if successful; if not, then it returns `nil` and the actual error message. There is an optional boolean parameter if you want the file to be read in binary mode (this makes no difference on Unix but remains important with Windows.)

In previous versions of Penlight, `utils.readfile` would read standard input if the file was not specified, but this can lead to nasty bugs; use `io.read '*a'` to grab all of standard input.

Simularly, `file.write` takes a filename and a string which will be written to that file.

For example, this little script converts a file into upper case:

    require 'pl'
	assert(#arg == 2, 'supply two filenames')
	text = assert(file.read(arg[1]))
    assert(file.write(arg[2],text:upper()))

Copying files is suprisingly tricky. `file.copy` and `file.move` attempt to use the best implementation possible. On Windows, they link to the API functions `CopyFile` and `MoveFile`, but only if the `alien` package is installed (this is true for Lua for Windows.) Otherwise, the system copy command is used. This can be ugly when writing Windows GUI applications, because of the dreaded flashing black-box problem with launching processes.

### Directory Operations

`pl.dir` provides some useful functions for working with directories. `fnmatch` will match a filename against a shell pattern, and `filter` will return any files in the supplied list which match the given pattern, which correspond to the functions in the Python `fnmatch` module. `getdirectories` will return all directories contained in a directory, and `getfiles` will return all files in a directory which match a shell pattern. These functions return the files as a table, unlike `lfs.dir` which returns an iterator.)

`dir.makepath` can create a full path, creating subdirectories as necessary; `rmtree` is the Nuclear Option of file deleting functions, since it will recursively clear out and delete all directories found begining at a path (there is a similar function with this name in the Python `shutils` module.)

    > = dir.makepath 't\\temp\\bonzo'
    > = path.isdir 't\\temp\\bonzo'
    true
    > = dir.rmtree 't'

`dir.rmtree` depends on `dir.walk`, which is a powerful tool for scanning a whole directory tree. Here is the implementation of `dir.rmtree`:

    --- remove a whole directory tree.
    -- @param path A directory path
    function dir.rmtree(fullpath)
        for root,dirs,files in dir.walk(fullpath) do
            for i,f in ipairs(files) do
                os.remove(path.join(root,f))
            end
            lfs.rmdir(root)
        end
    end


`dir.clonetree` clones directory trees. The first argument is a path that must exist, and the second path is the path to be cloned. (Note that this path cannot be _inside_ the first path, since this leads to madness.)  By default, it will then just recreate the directory structure. You can in addition provide a function, which will be applied for all files found.

    -- make a copy of my libs folder
    require 'pl'
    p1 = [[d:\dev\lua\libs]]
    p2 = [[D:\dev\lua\libs\..\tests]]
    dir.clonetree(p1,p2,dir.copyfile)

A more sophisticated version, which only copies files which have been modified:

    -- p1 and p2 as before, or from arg[1] and arg[2]
    dir.clonetree(p1,p2,function(f1,f2)
      local res
      local t1,t2 = path.getmtime(f1),path.getmtime(f2)
	  -- f2 might not exist, so be careful about t2
      if not t2 or t1 > t2 then
        res = dir.copyfile(f1,f2)
      end
      return res -- indicates successful operation
    end)

`dir.clonetree` uses `path.common_prefix`. With `p1` and `p2` defined above, the common path is 'd:\dev\lua'. So 'd:\dev\lua\libs\testfunc.lua` is copied to 'd:\dev\lua\test\testfunc.lua', etc.

If you need to find the common path of list of files, then `tablex.reduce` will do the job:

    > p3 = [[d:\dev]]
    > = tablex.reduce(path.common_prefix,{p1,p2,p3})
    'd:\dev'


## Data

### Reading Data Files

The first thing to consider is this: do you actually need to write a custom file reader? And if the answer is yes, the next question is: can you write the reader in as clear a way as possible? Correctness, Robustness, and Speed; pick the first two and the third can be sorted out later, _if necessary_.

A common sort of data file is the configuration file format commonly used on Unix systems. This format is often called a _property_ file in the Java world.

    # Read timeout in seconds
    read.timeout=10

    # Write timeout in seconds
    write.timeout=10

Here is a simple Lua implementation:

    -- property file parsing with Lua string patterns
    props = []
    for line in io.lines() do
        if line:find('#,1,true) ~= 1 and not line:find('^%s*$') then
            local var,value = line:match('([^=]+)=(.*)')
            props[var] = value
        end
    end

Very compact, but it suffers from a similar disease in equivalent Perl programs; it uses odd string patterns which are 'lexically noisy'. Noisy code like this slows the casual reader down. (For an even more direct way of doing this, see the next section, 'Reading Configuration Files')

Another implementation, using the Penlight libraries:

    -- property file parsing with extended string functions
    require 'pl'
    stringx.import()
    props = []
    for line in io.lines() do
        if not line:startswith('#') and not line:isspace() then
            local var,value = line:splitv('=')
            props[var] = value
        end
    end

This is more self-documenting; it is generally better to make the code express the _intention_, rather than having to scatter comments everywhere - comments are necessary, of course, but mostly to give the higher view of your intention that cannot be expressed in code. It is slightly slower, true, but in practice the speed of this script is determined by I/O, so further optimization is unnecessary.

### Reading Unstructured Text Data

<a id="input"/>

Text data is sometimes unstructured, for example a file containing words. The 'pl.input` module has a number of functions which makes processing such files easier. For example, a script to count the number of words in standard input (@see input.words):

    -- countwords.lua
    require 'pl'
    local k = 1
    for w in input.words(io.stdin) do
        k = k + 1
    end
    print('count',k)

Or this script to calculate the average of a set of numbers (@see input.numbers):

    -- average.lua
    require 'pl'
    local k = 1
    local sum = 0
    for n in input.numbers(io.stdin) do
        sum = sum + n
        k = k + 1
    end
    print('average',sum/k)

These scripts can be improved further by _eliminating loops_ In the last case, there is a perfectly good function `seq.sum` which can already take a sequence of numbers and calculate these numbers for us:

    -- average2.lua
    require 'pl'
    local total,n = seq.sum(input.numbers())
    print('average',total/n)

A further simplification here is that if `numbers` or `words` are not passed an argument, they will grab their input from standard input.  The first script can be rewritten:

    -- countwords2.lua
    require 'pl'
    print('count',seq.count(input.words()))

A useful feature of a sequence generator like `numbers` is that it can read from a string source. Here is a script to calculate the sums of the numbers on each line in a file:

    -- sums.lua
    for line in io.lines() do
        print(seq.sum(input.numbers(line))
    end

### Reading Columnar Data

It is very common to find data in columnar form, either space or comma-separated, perhaps with an initial set of column headers. Here is a typical example:

    EventID	Magnitude	LocationX	LocationY	LocationZ
    981124001	2.0	18988.4	10047.1	4149.7
    981125001	0.8	19104.0	9970.4	5088.7
    981127003	0.5	19012.5	9946.9	3831.2
    ...

`input.fields` is designed to extract several columns, given some delimiter (default to whitespace).  Here is a script to calculate the average X location of all the events:

    -- avg-x.lua
    require 'pl'
    io.read() -- skip the header line
    local sum,count = seq.sum(input.fields {3})
    print(sum/count)

`input.fields` is passed either a field count, or a list of column indices, starting at one as usual. So in this case we're only interested in column 3.  If you pass it a field count, then you get every field up to that count:

    for id,mag,locX,locY,locZ in input.fields (5) do
    ....
    end

`input.fields` by default tries to convert each field to a number. It will skip lines which clearly don't match the pattern, but will abort the script if there are any fields which cannot be converted to numbers.

The second parameter is a delimiter, by default spaces. ' ' is understood to mean 'any number of spaces', i.e. '%s+'. Any Lua string pattern can be used.

The third parameter is a _data source_, by default standard input (@see input.create_getter) It assumes that the data source has a `read` method which brings in the next line, i.e. it is a 'file-like' object. As a special case, a string will be split into its lines:

    > for x,y in input.fields(2,' ','10 20\n30 40\n') do print(x,y) end
    10      20
    30      40

Note the default behaviour for bad fields, which is to show the offending line number:

    > for x,y in input.fields(2,' ','10 20\n30 40x\n') do print(x,y) end
    10      20
    line 2: cannot convert '40x' to number

This behaviour of `input.fields` is appropriate for a script which you want to fail immediately with an appropriate _user_ error message if conversion fails. The fourth optional parameter is an options table: `{no_fail=true}` means that conversion is attempted but if it fails it just returns the string, rather as AWK would operate. You are then responsible for checking the type of the returned field. `{no_convert=true}` switches off conversion altogether and all fields are returned as strings.

<a id="data"/>

Sometimes it is useful to bring a whole dataset into memory, for operations such as extracting columns. Penlight provides a flexible reader specifically for reading this kind of data (@see data.read). Given a file looking like this:

    x,y
    10,20
    2,5
    40,50

Then `data.read` will create a table like this, with each row represented by a sublist:

    > t = data.read 'test.txt'
    > t
    {{10,20},{2,5},{40,50},
    fieldnames={'x','y'},delim=','}

You can now analyze this returned table using the supplied methods. For instance, the method `column_by_name` returns a table of all the values of that column.

    -- testdata.lua
    require 'pl'
    d = data.read('fev.txt')
    for _,name in ipairs(d.fieldnames) do
        local col = d:column_by_name(name)
        if type(col[1]) == 'number' then
            local total,n = seq.sum(col)
            utils.printf("Average for %s is %f\n",name,total/n)
        end
    end

`data.read` tries to be clever when given data; by default it expects a first line of column names, unless any of them are numbers. It tries to deduce the column delimiter by looking at the firstline. Sometimes it guesses wrong; these things can be specified explicitly. The second optional parameter is an options table: can override `delim` (a string pattern), `fieldnames` (a list or comma-separated string), specify `no_convert` (default is to convert), numfields (indices of columns known to be numbers, as a list) and `thousands_dot` (when the thousands separator in Excel CSV is '.')

A very powerful feature is a way to execute SQL-like queries on such data:

    -- queries on tabular data
    require 'pl'
    local d = data.read('xyz.txt')
    local q = d:select('x,y,z where x > 3 and z < 2 sort by y')
    for x,y,z in q do
        print(x,y,z)
    end

Please note that the format of queries is restricted to the following syntax:

    FIELDLIST [ 'where' CONDITION ] [ 'sort by' FIELD [asc|desc]]

Any valid Lua code can appear in `CONDITION`; remember it is _not_ SQL and you have to use `==` (this warning comes from experience.)

For this to work, _field names must be Lua identifiers_. So `read` will massage fieldnames so that all non-alphanumeric chars are replaced with underscores.

`read` can handle standard CSV files fine, although doesn't try to be a full-blown CSV parser. Spreadsheet programs are not always the best tool to process such data, strange as this might seem to some people. This is a toy CSV file; to appreciate the problem, imagine thousands of rows and dozens of columns like this:

    Department Name,Employee ID,Project,Hours Booked
    sales,1231,overhead,4
    sales,1255,overhead,3
    engineering,1501,development,5
    engineering,1501,maintenance,3
    engineering,1433,maintenance,10

The task is to reduce the dataset to a relevant set of rows and columns, perhaps do some processing on row data, and write the result out to a new CSV file. The `write_row` method uses the delimiter to write the row to a file; `select_row` is like `select`, except it iterates over _rows_, not fields; this is necessary if we are dealing with a lot of columns!

    names = {[1501]='don',[1433]='dilbert'}
    t:write_row (outf,{'Employee','Hours_Booked'})
    q = t:select_row {
        fields=keepcols,
        where=function(row) return row[1]=='engineering' end
    }
    for row in q do
        row[1] = names[row[1]]
        t:write_row(outf,row)
    end

`select_row` and `select` can be passed a table specifying the query; a list of field names, a function defining the condition and an optional parameter `sort_by`. It isn't really necessary here, but if we had a more complicated row condition (such as belonging to a specified set) then it is not generally possible to express such a condition as a query string, without resorting to hackery such as global variables.

Data does not have to come from files, nor does it necessarily come from the lab or the accounts department. On Linux, `ps aux` gives you a full listing of all processes running on your machine. It is straightforward to feed the output of this command into `data.read` and perform useful queries on it. Notice that non-identifier characters like '%' get converted into underscores:

        require 'pl'

        f = io.popen 'ps aux'
        s = data.read (f,{last_field_collect=true})
        f:close()
        print(s.fieldnames)
        print(s:column_by_name 'USER')
        qs = 'COMMAND,_MEM where _MEM > 0.5 and USER=="sdonovan"'
        for name,mem in s:select(qs) do
            print(mem,name)
        end


I've always been an admirer of the AWK programming language; with `filter` (@see data.filter) you can get Lua programs which are just as compact:

    -- printxy.lua
    require 'pl'
    data.filter 'x,y where x > 3'

As a tutorial resource, have a look at test-data.lua in the PL tests directory for other examples of use, plus comments.

Finally, for the curious, the global variable `_DEBUG` can be used to print out the actual iterator function which a query generates and dynamically compiles. By using code generation, we can get pretty much optimal performance out of arbitrary queries.

    > lua -lpl -e "_DEBUG=true" -e "data.filter 'x,y where x > 4 sort by x'" < test.txt
    return function (t)
            local i = 0
            local v
            local ls = {}
            for i,v in ipairs(t) do
                if v[1] > 4  then
                        ls[#ls+1] = v
                end
            end
            table.sort(ls,function(v1,v2)
                return v1[1] < v2[1]
            end)
            local n = #ls
            return function()
                i = i + 1
                v = ls[i]
                if i > n then return end
                return v[1],v[2]
            end
    end

    10,20
    40,50

<a id="config"/>

### Reading Configuration Files

The `config` module provides a simple way to convert several kinds of configuration files into a Lua table. Consider the simple example:

    # test.config
    # Read timeout in seconds
    read.timeout=10

    # Write timeout in seconds
    write.timeout=5

    #acceptable ports
    ports = 1002,1003,1004

This can be easily brought in using `config.read` and the result shown using `pl.pretty.write` (@see pretty.write)

    -- readconfig.lua
    local config = require 'pl.config'
    local pretty= require 'pl.pretty'

    local t = config.read(arg[1])
    print(pretty.write(t))

and the output of `lua readconfig.lua test.config` is:

    {
      ports = {
        1002,
        1003,
        1004
      },
      write_timeout = 5,
      read_timeout = 10
    }

That is, `config.read()` will bring in all key/value pairs, ignore # comments, and ensure that the key names are proper Lua identifiers by replacing non-identifier characters with '_'. If the values are numbers, then they will be converted. (So the value of `t.write_timeout` is the number 5). In addition, any values which are separated by commas will be converted likewise into an array.

Any line can be continued with a backslash. So this will all be considered one line:

    names=one,two,three, \
    four,five,six,seven, \
    eight,nine,ten


Windows-style INI files are also supported. The section structure of INI files translates naturally to nested tables in Lua:

    ; test.ini
    [timeouts]
    read=10 ; Read timeout in seconds
    write=5 ; Write timeout in seconds
    [portinfo]
    ports = 1002,1003,1004

 The output is:

    {
      portinfo = {
        ports = {
          1002,
          1003,
          1004
        }
      },
      timeouts = {
        write = 5,
        read = 10
      }
    }

You can now refer to the write timeout as `t.timeouts.write`.

As a final example of the flexibility of `config.read`, if passed this simple comma-delimited file

    one,two,three
    10,20,30
    40,50,60
    1,2,3

it will produce the following table:

    {
      { "one", "two", "three" },
      { 10, 20, 30 },
      { 40, 50, 60  },
      { 1, 2, 3 }
    }

`config.read` isn't designed to read all CSV files in general, but intended to support some Unix configuration files not structured as key-value pairs, such as '/etc/passwd'.

This function is intended to be a Swiss Army Knife of configuration readers, but it does have to make assumptions, and you may not like them. So there is an optional extra parameter which allows some control, which is table that may have the following fields:

    {
       variablilize = true,
       convert_numbers = true,
       trim_space = true,
       list_delim = ','
    }

`variablilize` is the option that converted `write.timeout` in the first example to the valid Lua identifier `write_timeout`.  If `convert_numbers` is true, then an attempt is made to convert any string that starts like a number. `trim_space` ensures that there is no starting or trailing whitespace with values, and `list_delim` is the character that will be used to decide whether to split a value up into a list (it may be a Lua string pattern such as '%s+'.)

For instance, the password file in Unix is colon-delimited:

    t = config.read('/etc/passwd',{list_delim=':'})

This produces the following output on my system (only last two lines shown):

    {
      ...
      {
        "user",
        "x",
        "1000",
        "1000",
        "user,,,",
        "/home/user",
        "/bin/bash"
      },
      {
        "sdonovan",
        "x",
        "1001",
        "1001",
        "steve donovan,28,,",
        "/home/sdonovan",
        "/bin/bash"
      }
    }

You can get this into a more sensible format, where the usernames are the keys, with:

    t = tablex.pairmap(function(k,v) return v,v[1] end,t)

and you get:

    { ...
      sdonovan = {
        "sdonovan",
        "x",
        "1001",
        "1001",
        "steve donovan,28,,",
        "/home/sdonovan",
        "/bin/bash"
      }
    ...
    }


<a id="lexer"/>

### Lexical Scanning

Although Lua's string pattern matching is very powerful, there are times when something more powerful is needed.  `pl.lexer.scan` provides a lexical scanner which _tokenizes_ a string, classifying tokens into numbers, strings, etc.


    > lua -lpl
    Lua 5.1.4  Copyright (C) 1994-2008 Lua.org, PUC-Rio
    > tok = lexer.scan 'alpha = sin(1.5)'
    > = tok()
    iden    alpha
    > = tok()
    =       =
    > = tok()
    iden    sin
    > = tok()
    (       (
    > = tok()
    number  1.5
    > = tok()
    )       )
    > = tok()

The scanner is a function, which is repeatedly called and returns the _type_ and _value_ of the token.  Recognized types are 'iden','string','number','space', 'comment' and 'keyword', and everything else is represented by itself. Note that by default the scanner will skip any 'space' tokens.

'comment' and 'keyword' aren't applicable to the plain scanner, which is not language-specific, but a scanner which understands Lua is available:

    > for t,v in lexer.lua 'for i=1,n do' do print(t,v) end
    keyword for
    iden    i
    =       =
    number  1
    ,       ,
    iden    n
    keyword do

A lexical scanner is useful where you have highly-structured data which is not nicely delimited by newlines. For example, here is a snippet of a in-house file format which it was my task to maintain:

    points	(818344.1,-20389.7,-0.1),(818337.9,-20389.3,-0.1),(818332.5,-20387.8,-0.1)
        ,(818327.4,-20388,-0.1),(818322,-20387.7,-0.1),(818316.3,-20388.6,-0.1)
        ,(818309.7,-20389.4,-0.1),(818303.5,-20390.6,-0.1),(818295.8,-20388.3,-0.1)
        ,(818290.5,-20386.9,-0.1),(818285.2,-20386.1,-0.1),(818279.3,-20383.6,-0.1)
        ,(818274,-20381.2,-0.1),(818274,-20380.7,-0.1);

Here is code to extract the points using `pl.lexer`:

    -- assume 's' contains the text above...
    local expecting = lexer.expecting
    local append = table.insert

    local tok = lexer.scan(s)

    local points = {}
    local t,v = tok() -- should be 'points'

    while t ~= ';' do
        c = {}
        t,v = tok() -- should be '('
        t,v = tok()
        c.x = v
        expecting(tok,',')
        t,v = tok()
        c.y = v
        expecting(tok,',')
        t,v = tok()
        c.z = v
        expecting(tok,')')
        t,v = tok()  -- either ',' or ';'
        append(points,c)
    end

The `expecting` function grabs the next token and if the type doesn't match, it throws an error. (`pl.lexer`, unlike other PL libraries, raises errors if something goes wrong, so you should wrap your code in `pcall` to catch the error gracefully.)

The ultimate highly-structured data is of course, program source. Here is a snippet from 'text-lexer.lua':


    -- uses asserteq from pl.test
    lines = [[
    for k,v in pairs(t) do
        if type(k) == 'number' then
            print(v) -- array-like case
        else
            print(k,v)
        end
    end
    ]]

    ls = List()
    for tp,val in lexer.lua(lines,{space=true,comments=true}) do
        assert(tp ~= 'space' and tp ~= 'comment')
        if tp == 'keyword' then ls:append(val) end
    end
    asserteq(ls,List{'for','in','do','if','then','else','end','end'})

`pl.lexer.lua` does not by default exclude spaces and comments, but the second argument is an _exception list_ that is used to filter token types out.

Here is a useful little utility that identifies all common global variables present in a lua module:

    -- testglobal.lua
    require 'pl'

    local txt = utils.readfile(arg[1])
    local globals = List()
    for t,v in lexer.lua(txt) do
        if t == 'iden' and _G[v] then
            globals:append(v)
        end
    end
    print(pretty.write(seq.count_map(globals)))

Rather then dumping the whole list, with its duplicates, we pass it through `seq.count_map` which turns the list into a table where the keys are the values, and the associated values are the number of times those values occur in the sequence. Typical output looks like this:

    {
      type = 2,
      pairs = 2,
      table = 2,
      print = 3,
      tostring = 2,
      require = 1,
      ipairs = 4
    }

You could further pass this through `tablex.keys` to get a unique list of symbols. This can be useful when writing 'strict' Lua modules, where all global symbols must be defined as locals at the top of the file.

For a more detailed use of `lexer.scan`, please look at 'testxml.lua' in the examples directory.


## Functional Programming

### Sequences

A Lua iterator (in its simplest form) is a function which can be repeatedly called to return a set of one or more values. The `for in` statement understands these iterators, and loops until the function returns `nil`. There are standard sequence adapters for tables in Lua ('ipairs` and 'pairs'), and `io.lines` returns an iterator over all the lines in a file. In the Penlight libraries, such iterators are also called _sequences_.  A sequence of single values (say from `io.lines`) is called _single-valued_, whereas the sequence defined by `pairs` is _double-valued_.

`pl.seq` provides a number of useful iterators, and some functions which operate on sequences.  At first sight this example looks like an attempt to write Python in Lua, (with the sequence being inclusive):

    > for i in seq.range(1,4) do print(i) end
    1
    2
    3
    4

But `range` is actually equivalent to Python's `xrange`, since it generates a sequence, not a list.  To get a list, use `seq.copy(seq.range(1,10))`, which takes any single-value sequence and makes a table from the result. `seq.list` is like `ipairs` except that it does not give you the index, just the value.

    > for x in seq.list {1,2,3} do print(x) end
    1
    2
    3

`enum` takes a sequence and turns it into a double-valued sequence consisting of a sequence number and the value, so `enum(list(ls))` is actually equivalent to `ipairs`. A more interesting example prints out a file with line numbers:


    for i,v in seq.enum(io.lines(fname)) do print(i..' '..v) end

Sequences can be _combined_, either by 'zipping' them or by concatenating them.

    > for x,y in seq.zip(l1,l2) do print(x,y) end
    10      1
    20      2
    30      3
    > for x in seq.splice(l1,l2) do print(x) end
    10
    20
    30
    1
    2
    3

`seq.printall` is useful for printing out single-valued sequences, and provides some finer control over formating, such as a delimiter, the number of fields per line, and a format string to use (@see string.format)

    > seq.printall(seq.random(10))
    0.0012512588885159 0.56358531449324 0.19330423902097 ....
    > seq.printall(seq.random(10),',',4,'%4.2f')
    0.17,0.86,0.71,0.51
    0.30,0.01,0.09,0.36
    0.15,0.17,

`map` will apply a function to a sequence.

    > seq.printall(seq.map(string.upper,{'one','two'}))
    ONE TWO
    > seq.printall(seq.map('+',{10,20,30},1))
    11 21 31

`filter` will filter a sequence using a boolean function (often called a _predicate_). For instance, this code only prints lines in a file which are composed of digits:

    for l in seq.filter(io.lines(file),pl.stringx.isdigit) do print(l) end

The following returns a table consisting of all the positive values in the original table (equivalent to `tablex.filter(ls,'>',0)`)

    ls = seq.copy(seq.filter(ls,'>',0))

We're already encounted `seq.sum` when discussing `input.numbers`. This can also be expressed with `seq.reduce`:

    > seq.reduce(function(x,y) return x + y end,seq.list{1,2,3,4})
    10

`seq.reduce` applies a binary function in a recursive fashion, so that:

    reduce(op,{1,2,3}) => op(1,reduce(op,{2,3}) => op(1,op(2,3))

it's now possible to easily generate other cumulative operations; the standard operations declared in `pl.operator` are useful here:

    > ops = require 'pl.operator'
    > -- can also say '*' instead of ops.mul
    > seq.reduce(ops.mul,input.numbers '1 2 3 4')
    24

There are functions to extract statistics from a sequence of numbers:

    > l1 = List {10,20,30}
    > l2 = List {1,2,3}
    > = seq.minmax(l1)
    10      30
    > = seq.sum(l1)
    60      3

It is common to get sequences where values are repeated, say the words in a file. `count_map` will take such a sequence and count the values, returning a table where the _keys_ are the unique values, and the value associated with each key is the number of times they occurred:

    > t = seq.count_map {'one','fred','two','one','two','two'}
    > t
    {one=2,fred=1,two=3}

This will also work on numerical sequences, but you cannot expect the result to be a proper list, i.e. having no 'holes'. Instead, you always need to use `pairs` to iterate over the result - note that there is a hole at index 5:

    > t = seq.count_map {1,2,4,2,2,3,4,2,6}
    > for k,v in pairs(t) do print(k,v) end
    1       1
    2       4
    3       1
    4       2
    6       1

`unique` uses `count_map` to return a list of the unique values, that is, just the keys of the resulting table.

`last` turns a single-valued sequence into a double-valued sequence with the current value and the last value:

    > for current,last in seq.last {10,20,30,40} do print (current,last) end
    20      10
    30      20
    40      30

This makes it easy to do things like identify repeated lines in a file, or construct differences between values. `filter` can handle double-valued sequences as well, so one could filter such a sequence to only return cases where the current value is less than the last value by using `operator.lt` or just '<'. This code then copies the resulting code into a table.

    > ls = {10,9,10,3}
    > seq.copy(seq.filter(seq.last(s),'<'))
    {9,3}


### Sequence Wrappers

The functions in `pl.seq` cover the common patterns when dealing with sequences, but chaining these functions together can lead to ugly code. Consider the last example of the previous section; `seq` is repeated three times and the resulting expression has to be read right-to-left. The first issue can be helped by local aliases, so that the expression becomes `copy(filter(last(s),'<'))` but the second issue refers to the somewhat unnatural order of functional application.  We tend to prefer reading operations from left to right, which is one reason why object-oriented notation has become popular. Sequence adapters allow this expression to be written like so:

    seq(s):last():filter('<'):copy()

With this notation, the operation becomes a chain of method calls running from left to right.

Sequence is not a basic Lua type, they are generally functions or callable objects. The expression `seq(s)` wraps a sequence in a _sequence wrapper_, which is an object which understands all the functions in `pl.seq` as methods. This object then explicitly represents sequences.

As a special case, the  constructor (which is when you call the table `seq`) will make a wrapper for a plain list-like table. Here we apply the length operator to a sequence of strings, and print them out.

    > seq{'one','tw','t'} :map '#' :printall()
    3 2 1

As a convenience, there is a function `seq.lines` which behaves just like `io.lines` except it wraps the result as an explicit sequence type. This takes the first 10 lines from standard input, makes it uppercase, turns it into a sequence with a count and the value, glues these together with the concatenation operator, and finally prints out the sequence delimited by a newline.

    seq.lines():take(10):upper():enum():map('..'):printall '\n'

Note the method `upper`, which is not a `seq` function. if an unknown method is called, sequence wrappers apply that method to all the values in the sequence (this is implicit use of `mapmethod` - @see seq.mapmethod)

It is straightforward to create custom sequences that can be used in this way. On Unix, `/dev/random` gives you an _endless_ sequence of random bytes, so we use `take` to limit the sequence, and then `map` to scale the result into the desired range. The key step is to use `seq` to wrap the iterator function:

    -- random.lua
    local seq = require 'pl.seq'

    function dev_random()
        local f = io.open('/dev/random')
        local byte = string.byte
        return seq(function()
            -- read two bytes into a string and convert into a 16-bit number
            local s = f:read(2)
            return byte(s,1) + 256*byte(s,2)
        end)
    end

    -- print 10 random numbers from 0 to 1 !
    dev_random():take(10):map('%',100):map('/',100):printall ','


Another Linux one-liner depends on the `/proc` filesystem and makes a list of all the currently running processes:

    pids = seq(lfs.dir '/proc'):filter(stringx.isdigit):map(tonumber):copy()

This version of Penlight has an experimental feature which relies on the fact that _all_ Lua types can have metatables, including functions. This makes _implicit sequence wrapping_ possible:

    > seq.import()
    > seq.random(5):printall(',',5,'%4.1f')
     0.0, 0.1, 0.4, 0.1, 0.2

This avoids the awkward `seq(seq.random(5))` construction. Or the iterator can come from somewhere else completely:

    > require 'lfs'

    > lfs.dir('.'):printall()
    . .. old out.txt readconfig.lua test.config test.ini
    test.txt

After `seq.import()`, it is no longer necessary to explicitly wrap sequence functions.

But there is a price to pay for this convenience. _Every_ function is affected, so that any function can be used, appropriate or not:

    > math.sin:printall()
    ..seq.lua:287: bad argument #1 to '(for generator)' (number expected, got nil)
    > a = tostring
    > a:find(' ')
    function: 0042C920

What function is returned? It's almost certain to be something that makes no sense in the current context. So implicit sequences may make certain kinds of programming mistakes harder to catch - they are best used for interactive exploration and small scripts.

### List Comprehensions

List comprehensions are a compact way to create tables by specifying their elements. In Python, you can say this:

    ls = [x for x in range(5)]  # == [0,1,2,3,4]

In Lua, using `pl.comprehension`:

    > C = require('pl.comprehension').new()
    > C ('x for x=1,10') ()
    {1,2,3,4,5,6,7,8,9,10}

`C` is a function which compiles a list comprehension _string_ into a _function_. In this case, the function has no arguments. The parentheses are redundant for a function taking a string argument, so this works as well:

    > C 'x^2 for x=1,4' ()
    {1,4,9,16}
    > C '{x,x^2} for x=1,4' ()
    {{1,1},{2,4},{3,9},{4,16}}

Note that the expression can be _any_ function of the variable `x`!

The basic syntax so far is `<expr> for <set>`, where `<set>` can be anything that the Lua `for` statement understands. `<set>` can also just be the variable, in which case the values will come from the _argument_ of the comprehension. Here I'm emphasizing that a comprehension is a function which can take a list argument:

    > C '2*x for x' {1,2,3}
    {2,4,6}
    > dbl = C '2*x for x'
    > dbl {10,20,30}
    {20,40,60}

Here is a somewhat more explicit way of saying the same thing; `_1` is a _placeholder_ refering to the _first_ argument passed to the comprehension.

    > C '2*x for _,x in pairs(_1)' {10,20,30}
    {20,40,60}
    > C '_1(x) for x'(tostring,{1,2,3,4})
    {'1','2','3','4'}

This extended syntax is useful when you wish to collect the result of some iterator, such as `io.lines`. This comprehension creates a function which creates a table of all the lines in a file:

    > f = io.open('array.lua')
    > lines = C 'line for line in _1:lines()' (f)
    > #lines
    118

There are a number of functions that may be applied to the result of a comprehension:

    > C 'min(x for x)' {1,44,0}
    0
    > C 'max(x for x)' {1,44,0}
    44
    > C 'sum(x for x)' {1,44,0}
    45

(These are equivalent to a reduce operation on a list.)

After the `for` part, there may be a condition, which filters the output. This comprehension collects the even numbers from a list:

    > C 'x for x if x % 2 == 0' {1,2,3,4,5}
    {2,4}

There may be a number of `for` parts:

    > C '{x,y} for x = 1,2 for y = 1,2' ()
    {{1,1},{1,2},{2,1},{2,2}}
    > C '{x,y} for x for y' ({1,2},{10,20})
    {{1,10},{1,20},{2,10},{2,20}}

These comprehensions are useful when dealing with functions of more than one variable, and are not so easily achieved with the other Penlight functional forms.

<a id="func"/>

### Creating Functions from Functions

Lua functions may be treated like any other value, although of course you cannot multiply or add them. One operation that makes sense is _function composition_, which chains function calls (so `(f * g)(x)` is `f(g(x))`.)

    > func = require 'pl.func'
    > printf = func.compose(io.write,string.format)
    > printf("hello %s\n",'world')
    hello world
    true

Many functions require you to pass a function as an argument, say to apply to all values of a sequence or as a callback. Usually this function is required to have a particular number of arguments, often one (in the case of the `map` functions) or two (for comparison functions.)  But often useful functions have the wrong number of arguments. For instance, `operator.add` simply adds its two arguments, but can't be passed to `tablex.map`, which expects to pass only one value to its function. So there is a need to construct a function of one argument from one of two arguments, _binding_ the extra argument to a given value.

_currying_ takes a function of n arguments and returns a function of n-1 arguments where the first argument is bound to some value:

    > p2 = func.curry(print,'start>')
    > p2('hello',2)
    start>  hello   2
    > ops = require 'pl.operator'
    > tablex.filter({1,-2,10,-1,2},curry(ops.gt,0))
    {-2,-1}
    > tablex.filter({1,-2,10,-1,2},curry(ops.le,0))
    {1,10,2}

The last example unfortunately reads backwards, because `curry` alway binds the first argument!

Currying is a specialized form of function binding. Here is another way to say the `print` example:

    > p2 = func.bind(print,'start>',func._1,func._2)
    > p2('hello',2)
    start>  hello   2

where `_1` and `_2` are _placeholder variables_, corresponding to the first and second argument respectively.

Having `func` all over the place is distracting, so it's useful to pull all of `pl.func` into the local context. Here is the filter example, this time the right way around:

    > utils.import 'pl.func'
    > tablex.filter({1,-2,10,-1,2},bind(ops.gt,_1,0))
    {1,10,2}


`tablex.merge` does a general merge of two tables. This example shows the usefulness of binding the last argument of a function.

    > S1 = {john=27,jane=31,mary=24}
    > S2 = {jane=31,jones=50}
    > intersection = bind(tablex.merge,_1,_2,false)
    > union = bind(tablex.merge,_1,_2,true)
    > intersection(S1,S2)
    {jane=31}
    > union(S1,S2)
    {mary=24,jane=31,john=27,jones=50}

When using `bind` to curry `print`, we got a function of precisely two arguments, whereas we really want our function to use varargs like `print`. This is the role of `_0`:

    > _DEBUG = true
    > p = bind(print,'start>',_0)
    return function (fn,_v1)
        return function(...) return fn(_v1,...) end
    end

    > p(1,2,3,4,5)
    start>  1       2       3       4       5

I've turned on the global `_DEBUG` flag, so that the function generated is printed out. It is actually a function which _generates_ the required function; the first call _binds the value_ of `_v1` to 'start>'.

### Placeholder Expressions

A common pattern in Penlight is a function which applies another function to all elements in a table or a sequence, such as `tablex.map` or `seq.filter`. Lua does anonymous functions well, although they can be a bit tedious to type:

    > tablex.map(function(x) return x*x end,{1,2,3,4})
    {1,4,9,16}

`pl.func` allows you to define _placeholder expressions_, which can cut down on the typing required, and also make your intent clearer. First, we bring contents of `pl.func` into our context, and then supply an expression using placeholder variables, such as `_1`,`_2`,etc. (C++ programmers will recognize this from the Boost libraries.)

    > utils.import 'pl.func'
    > tablex.map(_1*_1,{1,2,3,4})
    {1,4,9,16}

Functions of up to 5 arguments can be generated.

    > tablex.map2(_1+_2,{1,2,3},{10,20,30})
    {11,22,33}

These expressions can use arbitrary functions, altho they must first be registered with the functional library. `pl.func.register` brings in a single function, and `pl.func.import` brings in a whole table of functions, such as `math`.

    > sin = register(math.sin)
    > tablex.map(sin(_1),{1,2,3,4})
    {0.8414709848079,0.90929742682568,0.14112000805987,-0.75680249530793}
    > import 'math'
    > tablex.map(cos(2*_1),{1,2,3,4})
    {-0.41614683654714,-0.65364362086361,0.96017028665037,-0.14550003380861}

A common operation is calling a method of a set of objects:

    > tablex.map(_1:sub(1,1),{'one','four','x'})
    {'o','f','x'}
    > tablex.map(_1:at(1),{'one','four','x'})
    {'o','f','x'}

There are some restrictions on what operators can be used in PEs. For instance, because the `__len` metamethod cannot be overriden by plain Lua tables, we need to define a special function to express `#_1':

    > tablex.map(Len(_1),{'one','four','x'})
    {3,4,1}

Likewise for comparison operators, which cannot be overloaded for _different_ types, and thus also have to be expressed as a special function:

    > tablex.filter(Gt(_1,0),{1,-1,2,4,-3})
    {1,2,4}

It is useful to express the fact that a function returns multiple values. For instance, `tablex.pairmap`  expects a function that will be called with the key and the value, and returns the new value and the key, in that order.

    > pairmap(Args(_2,_1:upper()),{fred=1,alice=2})
    {ALICE=2,FRED=1}

PEs cannot contain `nil` values, since PE function arguments are represented as an array. Instead, a special value called `Nil` is provided.  So say `_1:f(Nil,1)` instead of `_1:f(nil,1)`.

A placeholder expression cannot be automatically used as a Lua function. The technical reason is that the call operator must be overloaded to construct function calls like `_1(1)`.  If you want to force a PE to return a function, use `pl.func.I`.

    > tablex.map(_1(10),{I(2*_1),I(_1*_1),I(_1+2)})
    {20,100,12}

Here we make a table of functions taking a single argument, and then call them all with a value of 10.

The essential idea with PEs is to 'quote' an expression so that it is not immediately evaluated, but instead turned into a function that can be applied later to some arguments. The basic mechanism is to wrap values and placeholders so that the usual Lua operators have the effect of building up an _expression tree_. (It turns out that you can do _symbolic algebra_ using PEs, see symbols.lua in the examples directory, and its test runner testsym.lua, which demonstrates symbolic differentiation.)

The rule is that if any operator has a PE operand, the result will be quoted. Sometimes we need to quote things explicitly. For instance, say we want to pass a function to a filter that must return true if the element value is in a set. `set[_1]` is the obvious expression, but it does not give the desired result, since it evaluates directly, giving `nil`. Indexing works differently than a binary operation like addition (set+_1 _is_ properly quoted) so there is a need for an explicit quoting or wrapping operation. This is the job of the `_` function; the PE in this case should be `_(set)[_1]`.  This works for functions as well, as a convenient alternative to registering functions: `_(math.sin)(_1)`. This is equivalent to using the `lines' method:

    for line in I(_(f):read()) do print(line) end

Now this will work for _any_ 'file-like' object which which has a `read` method returning the next line. If you had a LuaSocket client which was being 'pushed' by lines sent from a server, then `_(s):receive '*l'` would create an iterator for accepting input. These forms can be convenient for adapting your data flow so that it can be passed to the sequence functions in `pl.seq'.

Placeholder expressions can be mixed with sequence wrapper expressions. `lexer.lua` will give us a double-valued sequence of tokens, where the first value is a type, and the second is a value. We filter out only the values where the type is 'iden', extract the actual value using `map`, get the unique values and finally copy to a list.

    > str = 'for i=1,10 do for j = 1,10 do print(i,j) end end'
    > S(lexer.lua(str)):filter('==','iden'):map(_2):unique():copy()
    {i,print,j}

This is a particularly intense line (and I don't always suggest making everything a one-liner!); the key is the behaviour of `map`, which will take both values of the sequence, so `_2` returns the value part. (Since `filter` here is given an extra argument, it only operates on the type values.)

There are some performance considerations to using placeholder expressions. Instantiating a PE requires constructing and compiling a function, which is not such a fast operation. So to get best performance, factor out PEs from loops like this;

    local fn = I(_1:f() + _2:g())
    for i = 1,n do
        res[i] = tablex.map2(fn,first[i],second[i])
    end


## Additional Libraries

Libraries in this section are no longer considered to be part of the Penlight core, but still provide specialized functionality when needed.

<a id="sip"/>

### Simple Input Patterns

Lua string pattern matching is very powerful, and usually you will not need a traditional regular expression library.  Even so, sometimes Lua code ends up looking like Perl, which happens because string patterns are not always the easiest things to read, especially for the casual reader.  Here is a program which needs to understand three distinct date formats:

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

These aren't particularly difficult patterns, but already typical issues are appearing, such as having to escape '-'. Also, `string.match` returns its captures, so that we're forced to use a slightly awkward nested if-statement.

Verification issues will further cloud the picture, since regular expression people try to enforce constraints (like year cannot be more than four digits) using regular expressions, on the usual grounds that one shouldn't stop using a hammer when one is enjoying oneself.

`pl.sip` provides a simple, intuitive way to detect patterns in strings and extract relevant parts.

    > sip = require 'pl.sip'
    > write = require('pl.pretty').write
    > function pprint(t) print(write(t)) end
    > res = {}
    > c = sip.compile 'ref=$S{file}:$d{line}'
    > = c('ref=hello.c:10',res)
    true
    > pprint(res)
    {
      line = 10,
      file = "hello.c"
    }
    > c('ref=long name, no line',res)
    false

`sip.compile` creates a pattern matcher function, which is given a string and a table. If it matches the string, then `true` is returned and the table is populated according to the _named fields_ in the pattern.

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

SIP patterns start with '$', then a one-letter type, and then an optional variable in curly braces.

    Type    Meaning
    v         variable, or identifier.
    i          possibly signed integer
    f          floating-point number
    r          'rest of line'
    q         quoted string (either ' or ")
    p         a path name
    (         anything inside (...)
    [         anything inside [...]
    {         anything inside {...}
    <         anything inside <...>
    [---------------------------------]
    S         non-space
    d         digits
    ...

If a type is not one of v,i,f,r or q, then it's assumed to be one of the standard Lua character classes.  Any spaces you leave in your pattern will match any number of spaces.  And any 'magic' string characters will be escaped.

SIP captures (like `$v{mon}`) do not have to be named. You can use just `$v`, but you have to be consistent; if a pattern contains unnamed captures, then all captures must be unnamed. In this case, the result table is a simple list of values.

`sip.match` is a useful shortcut if you like your matches to be 'in place'. (It caches the result, so it is not much slower than explicitly using `sip.compile`.)

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

Finally, putting a ' $' at the end of a pattern means 'capture the rest of the line, starting at the first non-space'.

    > sip.match('( $q , $q ) $','("jan", "smit") and a string',res)
    true
    > res
    {'jan','smit','and a string'}
    > res = {}
    > sip.match('( $q{first} , $q{last} ) $','("jan", "smit") and a string',res)
    true
    > res
    {first='jan',rest='and a string',last='smit'}

(@see sip)

<a id="lapp"/>

### Command-line Programs with Lapp

`pl.lapp` is a small and focused Lua module which aims to make standard command-line parsing easier and intuitive. It implements the standard GNU style, i.e. short flags with one letter start with '-', and there may be an additional long flag which starts with '--'. Generally options which take an argument expect to find it as the next parameter (e.g. 'gcc test.c -o test') but single short options taking a numerical parameter can dispense with the space (e.g. 'head -n4 test.c')

As far as possible, Lapp will convert parameters into their equivalent Lua types, i.e. convert numbers and convert filenames into file objects. If any conversion fails, or a required parameter is missing, an error will be issued and the usage text will be written out. So there are two necessary tasks, supplying the flag and option names and associating them with a type.

For any non-trivial script, even for personal consumption, it's necessary to supply usage text. The novelty of Lapp is that it starts from that point and defines a loose format for usage strings which can specify the names and types of the parameters.

An example will make this clearer:

    -- scale.lua
      lapp = require 'pl.lapp'
      local args = lapp [[
      Does some calculations
        -o,--offset (default 0.0)  Offset to add to scaled number
        -s,--scale  (number)  Scaling factor
         <number> (number )  Number to be scaled
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

There are two kinds of lines in Lapp usage strings which are meaningful; option and parameter lines. An option line gives the short option, optionally followed by the corresponding long option. A type specifier in parentheses may follow. Simularly, a parameter line starts with '<' PARAMETER '>', followed by a type specifier. Type specifiers are either of the form '(default ' VALUE ')' or '(' TYPE ')'; the default specifier means that the parameter or option has a default value and is not required. TYPE is one of 'string','number','file-in' or 'file-out'; VALUE is a number, one of ('stdin','stdout','stderr') or a token. The rest of the line is not parsed and can be used for explanatory text.

This script shows the relation between the specified parameter names and the fields in the output table.

      -- simple.lua
      local args = require ('lapp') [[
      Various flags and option types
        -p          A simple optional flag, defaults to false
        -q,--quiet  A simple flag with long name
        -o  (string)  A required option with argument
        <input> (default stdin)  Optional input file parameter
      ]]

      for k,v in pairs(args) do
          print(k,v)
      end

I've just dumped out all values of the args table; note that args.quiet has become true, because it's specified; args.p defaults to false. If there is a long name for an option, that will be used in preference as a field name. A type or default specifier is not necessary for simple flags, since the default type is boolean.

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

The parameter input has been set to an open read-only file object - we know it must be a read-only file since that is the type of the default value. The field input_name is automatically generated, since it's often useful to have access to the original filename.

Notice that any extra parameters supplied will be put in the result table with integer indices, i.e. args[i] where i goes from 1 to #args.

Files don't really have to be closed explicitly for short scripts with a quick well-defined mission, since the result of garbage-collecting file objects is to close them.

#### Enforcing a Range for a Parameter

The type specifier can also be of the form '(' MIN '..' MAX ')'.

    require 'pl.lapp'
    local args = pl.lapp [[
        Setting ranges
        <x> (1..10)  A number from 1 to 10
        <y> (-5..1e6) Bigger range
    ]]

    print(args.x,args.y)

Here the meaning is that the value is greater or equal to MIN and less or equal to MAX; there is no provision for forcing a parameter to be a whole number.

You may also define custom types that can be used in the type specifier:

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

`lapp.add_type` takes three parameters, a type name, a converter and a constraint function. The constraint function is expected to throw an assertion if some condition is not true; we use lapp.assert because it fails in the standard way for a command-line script. The converter argument can either be a type name known to Lapp, or a function which takes a string and generates a value.

#### 'varargs' Parameter Arrays

    require 'lapp'
    local args = lapp [[
    Summing numbers
        <numbers...> (number) A list of numbers to be summed
    ]]

    local sum = 0
    for i,x in ipairs(args.numbers) do
        sum = sum + x
    end
    print ('sum is '..sum)

The parameter number has a trailing '...', which indicates that this parameter is a 'varargs' parameter. It must be the last parameter, and args.number will be an array.

Consider this implementation of the head utility from Mac OS X:

        -- implements a BSD-style head
        -- (see http://www.manpagez.com/man/1/head/osx-10.3.php)

        require ('lapp')

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

Note how we have access to all the filenames, because the auto-generated field `files_name` is also an array!

(This is probably not a very considerate script, since Lapp will open all the files provided, and only close them at the end of the script. See the xhead.lua example for another implementation.)

Flags and options may also be declared as vararg arrays, and can occur anywhere. Bear in mind that short options can be combined (like 'tar -xzf'), so it's perfectly legal to have '-vvv'. But normally the value of args.v is just a simple `true` value.

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

If a script implements `lapp.callback`, then Lapp will call it after each argument is parsed. The callback is passed the parameter name, the raw unparsed value, and the result table. It is called immediately after assignment of the value, so the corresponding field is available.

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

Callbacks are needed when you want to take action immediately on parsing an argument.


## Technical Choices

### Modularity and Granularity

In an ideal world, a program should only load the libraries it needs. Penlight is intended to work in situations where an extra 100Kb of bytecode could be a problem. It is straightforward but tedious to load exactly what you need:

    local data = require 'pl.data'
    local List = require 'pl.list' . List
    local array2d = require 'pl.array2d'
    local seq = require 'pl.seq'
    local utils = require 'pl.utils'

This is the style that I follow in Penlight itself, so that modules don't mess with the global environment; also, `stringx.import()` is not used because it will update the global `string` table.

But `require 'pl'` is more convenient in scripts; the question is how to ensure that one doesn't load the whole kitchen sink as the price of convenience. The strategy is to only load modules when they are referenced. In 'init.lua' (which is loaded by `require 'pl'`) a metatable is attached to the global table with an `__index` metamethod. Any unknown name is looked up in the list of modules, and if found, we require it and make that module globally available. So when `tablex.deepcompare` is encountered, looking up `tablex` causes 'pl.tablex' to be required.  This strategy is also used for the standard classes defined in `class` and `classx`.

Modifying the behaviour of the global table has consequences. For instance, there is the famous module `strict` which comes with Lua itself (perhaps the only standard Lua module written in Lua itself) which also does this modification so that global variiables must be defined before use.  So the implementation in 'init.lua' allows for a 'not found' hook, which 'pl.strict.lua' uses.

But the strategy is worth the effort: the old 'kitchen sink' 'init.lua' would pull in about 260K of bytecode, whereas now typical programs use about 100K less, and short scripts even better - for instance, if they were only needing functionality in `utils`.

There are some functions which mark their output table with a special metatable, when it seems particularly appropriate. For instance, `tablex.makeset` creates a `Set`, and `seq.copy` creates a `List`. But this does not automatically result in the loading of `pl.class` and `pl.list`; only if you try to access any of these methods.  In 'utils.lua', there is an exported table called `stdmt`:

    stdmt = { List = {}, Map = {}, Set = {}, MultiMap = {} }

If you go through 'init.lua', then these plain little 'identity' tables get an `__index` metamethod which forces the loading of the full functionality. Here is the code from 'list.lua' which starts the ball rolling for lists:

    List = utils.stdmt.List
    List.__index = List
    List._name = "List"
    List._class = List

The 'load-on-demand' strategy helps to modularize the library. If there are a lot of modules, then the user has to keep track of where things are defined, that `Map` is in `pl.class` but `MultiMap` is in `pl.classx`. Especially for more casual use, `require 'pl'` is a good compromise between convenience and modularity.

### Defining what is Callable

'utils.lua' exports `function_arg` which is used extensively throughout Penlight. It defines what is meant by 'callable'.  Obviously true functions are immediately passed back. But what about strings? The first option is that it represents an operator in 'operator.lua', so that '<' is just an alias for `operator.lt`.

We then check whether there is a _function factory_ defined for the metatable of the value. In Penlight, the list comprehensions module registers itself as the function factory for strings, so that `map('x^2 for x',a)` can work (it operates on the rows of a 2D array).  It is true that strings can be made callable, but in practice this turns out to be a cute but dubious idea, since _all_ strings share the same metatable. A common programming error is to pass the wrong kind of object to a function, and it's better to get a nice clean 'attempting to call a string' message rather than some obscure trace from the bowels of your library.

The other module that registers a function factory is `pl.func`. Placeholder expressions cannot be directly calleable, and so need to be instantiated and cached in as efficient way as possible.

(An inconsistency is that `utils.is_callable` does not do this thorough check.)


