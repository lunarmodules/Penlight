-- testing Map functionality

local test = require 'pl.test'
local Map = require 'pl.Map'
local tablex = require 'pl.tablex'

local asserteq = test.asserteq

local cmp = tablex.compare_no_order

local m = Map{alpha=1,beta=2,gamma=3}

assert (cmp(m:values(),{1,2,3}))

assert (cmp(m:keys(),{'alpha','beta','gamma'}))

asserteq (m:items(),{{'alpha',1},{'beta',2},{'gamma',3}})

asserteq (m:getvalues {'alpha','gamma'}, {1,3})


m = Map{one=1,two=2}
asserteq(m,Map{one=1,two=2})
m:update {three=3,four=4}
asserteq(m,Map{one=1,two=2,three=3,four=4})
