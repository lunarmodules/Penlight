-- This test file expects to be ran from 'run.lua' in the root Penlight directory.

local dir = require( "pl.dir" )
local asserteq = require( "pl.test" ).asserteq
local pretty = require( "pl.pretty" )

local expected = {"docs/function_index.txt"}

local files = dir.getallfiles( "docs/", "*.txt" )

asserteq( files, expected )

