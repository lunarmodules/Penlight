-- This test file expects to be ran from 'run.lua' in the root Penlight directory.

local dir = require( "pl.dir" )
local file = require( "pl.file" )
local path = require( "pl.path" )
local asserteq = require( "pl.test" ).asserteq
local pretty = require( "pl.pretty" )

local expected = {"docs/function_index.txt"}

local files = dir.getallfiles( "docs/", "*.txt" )

asserteq( files, expected )

-- Test move files -----------------------------------------
--
-- Create a dummy file
local fileName = "poot.txt"
file.write( fileName, string.rep( "poot ", 1000 ) )

local newFileName = "move_test.txt"
local err, msg = dir.movefile( fileName, newFileName )

-- Make sure the move is successful
asserteq( err, true )

-- Check to make sure the original file is gone
asserteq( path.exists( fileName ), false )

-- Check to make sure the new file is there
asserteq( path.exists( newFileName ), true )

-- Clean up
file.delete( newFileName )

