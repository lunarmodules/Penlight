local path = require 'pl.path'
asserteq = require 'pl.test'.asserteq

function quote(s)
	return '"'..s..'"'
end

function print2(s1,s2)
	print(quote(s1),quote(s2))
end

function testpath(pth)
    print2 (path.splitpath(pth))
    print2 (path.splitext(pth))
end

testpath [[c:\bonzo\dog_stuff\cat.txt]]
testpath [[/bonzo/dog/cat/fred.stuff]]
testpath [[../../alice/jones]]
testpath [[alice]]
testpath [[/path-to\dog\]]

asserteq( path.isdir( "../docs" ), true )
asserteq( path.isdir( "../docs/penlight.jpg" ), false )

asserteq( path.isfile( "../docs" ), false )
asserteq( path.isfile( "../docs/penlight.jpg" ), true )
