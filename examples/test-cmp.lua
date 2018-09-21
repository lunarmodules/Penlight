local A = require 'pl.tablex'
print(A.compare_no_order({1,2,3},{2,1,3}))
print(A.compare_no_order({1,2,3},{2,1,3},'=='))
