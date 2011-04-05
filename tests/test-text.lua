local T = require 'pl.text'
local Template = T.Template
local asserteq = require 'pl.test'.asserteq

local t1 = Template [[
while true do
    $contents
end
]]

assert(t1:substitute {contents = 'print "hello"'},[[
while true do
    print "hello"
end
]])

assert(t1:indent_substitute {contents = [[
for i = 1,10 do
    gotcha(i)
end
]]},[[
while true do
    for i = 1,10 do
        gotcha(i)
    end
end
]])

asserteq(T.dedent [[
    one
    two
    three
]],[[
one
two
three
]])
asserteq(T.fill ([[
It is often said of Lua that it does not include batteries. That is because the goal of Lua is to produce a lean expressive language that will be used on all sorts of machines, (some of which don't even have hierarchical filesystems). The Lua language is the equivalent of an operating system kernel; the creators of Lua do not see it as their responsibility to create a full software ecosystem around the language. That is the role of the community.
]],20),[[
It is often said of Lua
that it does not include
batteries. That is because
the goal of Lua is to
produce a lean expressive
language that will be
used on all sorts of machines,
(some of which don't
even have hierarchical
filesystems). The Lua
language is the equivalent
of an operating system
kernel; the creators of
Lua do not see it as their
responsibility to create
a full software ecosystem
around the language. That
is the role of the community.
]])

local template = require 'pl.template'

local t = [[
# for i = 1,3 do
    print($(i+1))
# end
]]

asserteq(template.substitute(t),[[
    print(2)
    print(3)
    print(4)
]])

t = [[
> for i = 1,3 do
    print(${i+1})
> end
]]

asserteq(template.substitute(t,{_brackets='{}',_escape='>'}),[[
    print(2)
    print(3)
    print(4)
]])

t = [[
# for k,v in pairs(T) do
    "$(k)", -- $(v)
# end
]]

local T = {Dog = 'Bonzo', Cat = 'Felix', Lion = 'Leo'}

asserteq(template.substitute(t,{T=T,_parent=_G}),[[
    "Dog", -- Bonzo
    "Cat", -- Felix
    "Lion", -- Leo
]])

