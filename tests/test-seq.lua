input = require 'pl.input'
seq = require 'pl.seq'
asserteq = require('pl.test').asserteq

asserteq (seq.sum(input.numbers '10 20 30 40 50'),150)
x,y = unpack(seq.copy(input.numbers('10 20')))
assert (x == 10 and y == 20)

asserteq(seq.copy2(ipairs{10,20,30}),{{1,10},{2,20},{3,30}})
