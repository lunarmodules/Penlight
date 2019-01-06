local Set = require 'pl.Set'
local asserteq = require 'pl.test' . asserteq

local s1 = Set{1,2}
local s2 = Set{1,2}
-- equality
asserteq(s1,s2)
-- union
asserteq(Set{1,2} + Set{2,3},  Set{1,2,3})
asserteq(Set{1,2} + 3,   Set{1,2,3})
-- intersection
asserteq(Set{1,2} * Set{2,3},   Set{2})
-- difference
local fruit = Set{'apple','banana','orange','apricots'}
local tropical = Set{'banana','orange'}

asserteq(fruit - tropical,  Set{'apple','apricots'})
asserteq(tropical - 'orange', Set{'banana'})

-- symmetric_difference
asserteq(Set{1,2} ^ Set{2,3}, Set{1,3})
-- tostring - illustrative, because these assertions may or may not work,
-- due to no ordering in set elements
--asserteq(tostring(S{1,2}),'[1,2]')
--asserteq(tostring(S{1,S{2,3}}),'[1,[2,3]]')

local s3 = Set()
asserteq(Set.isempty(s3),true)

local s4 = Set{1,2,3}

-- subsets/supersets
asserteq(s4 > s1,true)

Set.set(s3,'one',true)
s3.two = true
asserteq(s3,Set{'one','two'})
