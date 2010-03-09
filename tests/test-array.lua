local array = require 'pl.array2d'
local asserteq = require('pl.test').asserteq

local A = {
	{1,2,3,4},
	{10,20,30,40},
	{100,200,300,400},
	{1000,2000,3000,4000},
}

asserteq(array.column(A,2),{2,20,200,2000})
asserteq(array.reduce_rows('+',A),{10,100,1000,10000})
asserteq(array.reduce_cols('+',A),{1111,2222,3333,4444})

