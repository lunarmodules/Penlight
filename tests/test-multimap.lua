local asserteq = require 'pl.test' . asserteq
local MultiMap = require 'pl.MultiMap'

m = MultiMap()
m:set('john',1)
m:set('jane',3)
m:set('john',2)

local ms = MultiMap{john={1,2},jane={3}}

asserteq(m,ms)
