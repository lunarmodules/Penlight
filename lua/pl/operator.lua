-------------------------------------------------------------------
--- Lua operators available as functions.
-- (similar to the Python module of the same name)<br>
-- There is a module field <code>optable</code> which maps the operator strings
-- onto these functions, e.g. <pre class=example>operator.optable['()']==operator.call</pre>


local strfind = string.find
local utils = require 'pl.utils'

module ('pl.operator',utils._module)

--- apply function to some arguments ()
-- @param fn a function or callable object
function call(fn,...)
    return fn(...)
end

--- get the indexed value from a table []
-- @param t a table or any indexable object
-- @param k the key
function index(t,k)
    return t[k]
end

--- returns true if arguments are equal ==
-- @param a value
-- @param b value
function eq(a,b)
    return a==b
end

--- returns true if arguments are not equal ~=
 -- @param a value
-- @param b value
function neq(a,b)
    return a~=b
end

--- returns true if a is less than b <
-- @param a value
-- @param b value
function lt(a,b)
    return a < b
end

--- returns true if a is less or equal to b <=
-- @param a value
-- @param b value
function le(a,b)
    return a <= b
end

--- returns true if a is greater than b >
-- @param a value
-- @param b value
function gt(a,b)
    return a > b
end

--- returns true if a is greater or equal to b >=
-- @param a value
-- @param b value
function ge(a,b)
    return a >= b
end

--- returns length of string or table #
-- @param a a string or a table
function len(a)
    return #a
end

--- add two values +
-- @param a value
-- @param b value
function add(a,b)
    return a+b
end

--- subtract b from a -
-- @param a value
-- @param b value
function sub(a,b)
    return a-b
end

--- multiply two values *
-- @param a value
-- @param b value
function mul(a,b)
    return a*b
end

--- divide first value by second /
-- @param a value
-- @param b value
function div(a,b)
    return a/b
end

--- raise first to the power of second ^
-- @param a value
-- @param b value
function pow(a,b)
    return a^b
end

--- modulo; remainder of a divided by b %
-- @param a value
-- @param b value
function mod(a,b)
    return a%b
end

--- concatenate two values (either strings or __concat defined) ..
-- @param a value
-- @param a value
function concat(a,b)
    return a..b
end

--- return the negative of a value -
-- @param a value
-- @param a value
function unm(a)
    return -a
end

--- false if value evaluates as true (i.e. not nil or false) not
-- @param a value
function lnot(a)
    return not a
end

--- true if both values evaluate as true (i.e. not nil or false) and
-- @param a value
-- @param a value
function land(a,b)
    return a and b
end

--- true if either value evaluate as true (i.e. not nil or false) or
-- @param a value
-- @param a value
function lor(a,b)
    return a or b
end

--- make a table from the arguments. {}
-- @param ... non-nil arguments
-- @return a table
function table (...)
    return {...}
end

function match (a,b)
    return strfind(a,b)~=nil
end

--- the null operation.
-- @param ... arguments
-- @return the arguments
function nop (...)
    return ...
end

optable = {
    ['+']=add,
    ['-']=sub,
    ['*']=mul,
    ['/']=div,
    ['%']=mod,
    ['^']=pow,
    ['..']=concat,
    ['()']=call,
    ['[]']=index,
    ['<']=lt,
    ['<=']=le,
    ['>']=gt,
    ['>=']=ge,
    ['==']=eq,
    ['~=']=neq,
    ['#']=len,
    ['and']=land,
    ['or']=lor,
    ['{}']=table,
    ['~']=match,
    ['']=nop,
}
