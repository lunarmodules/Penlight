local template = require 'pl.template'


--------------------------------------------------
-- Test using no leading nor trailing linebreak
local tmpl = [[<ul>
# for i,val in ipairs(T) do
<li>$(i) = $(val:upper())</li>
# end
</ul>]]

local my_env = {
  ipairs = ipairs,
  T = {'one','two','three'},
  _debug = true,
}
local res, err = template.substitute(tmpl, my_env)

print(res, err)
assert(res == [[<ul>
<li>1 = ONE</li>
<li>2 = TWO</li>
<li>3 = THREE</li>
</ul>]])



--------------------------------------------------
-- Test using both leading and trailing linebreak
local tmpl = [[
<ul>
# for i,val in ipairs(T) do
<li>$(i) = $(val:upper())</li>
# end
</ul>
]]

local my_env = {
  ipairs = ipairs,
  T = {'one','two','three'},
  _debug = true,
}
local res, err = template.substitute(tmpl, my_env)

print(res, err)
assert(res == [[
<ul>
<li>1 = ONE</li>
<li>2 = TWO</li>
<li>3 = THREE</li>
</ul>
]])


--------------------------------------------------
-- Test reusing a compiled template
local tmpl = [[
<ul>
# for i,val in ipairs(T) do
<li>$(i) = $(val:upper())</li>
# end
</ul>
]]

local my_env = {
  ipairs = ipairs,
  T = {'one','two','three'}
}
local t, err = template.compile(tmpl, nil, nil, nil, nil, true)
local res, err, code = t:render(my_env)
print(res, err, code)
assert(res == [[
<ul>
<li>1 = ONE</li>
<li>2 = TWO</li>
<li>3 = THREE</li>
</ul>
]])


-- reuse with different env
local my_env = {
  ipairs = ipairs,
  T = {'four','five','six'}
}
local t, err = template.compile(tmpl, nil, nil, nil, nil, true)
local res, err, code = t:render(my_env)
print(res, err, code)
assert(res == [[
<ul>
<li>1 = FOUR</li>
<li>2 = FIVE</li>
<li>3 = SIX</li>
</ul>
]])
