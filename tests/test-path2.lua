local path = require 'pl.path'
local test = require 'pl.test'
local asserteq = test.asserteq

function slash (p)
    return (p:gsub('\\','/'))
end


--  path.relpath


local testpath = '/a/B/c'

function try (p,r)
    asserteq(slash(path.relpath(p,testpath)),r)
end

try('/a/B/c/one.lua','one.lua')
try('/a/B/c/bonZO/two.lua','bonZO/two.lua')
try('/a/B/three.lua','../three.lua')
try('/a/four.lua','../../four.lua')
try('one.lua','one.lua')
try('../two.lua','../two.lua')


--  path.common_prefix


asserteq(slash(path.common_prefix("../anything","../anything/goes")),"../anything")
asserteq(slash(path.common_prefix("../anything/goes","../anything")),"../anything")
asserteq(slash(path.common_prefix("../anything/goes","../anything/goes")),"../anything")
asserteq(slash(path.common_prefix("../anything/","../anything/")),"../anything")
asserteq(slash(path.common_prefix("../anything","../anything")),"..")
asserteq(slash(path.common_prefix("/hello/world","/hello/world/filename.doc")),"/hello/world")
asserteq(slash(path.common_prefix("/hello/filename.doc","/hello/filename.doc")),"/hello")
if path.is_windows then
    asserteq(path.common_prefix("c:\\hey\\there","c:\\hey"),"c:\\hey")
end
