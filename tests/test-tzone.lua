local Date = require 'pl.Date'
local test = require 'pl.test'
local df = Date.Format()
local dl = df:parse '2008-07-05'
local du = dl:toUTC()

test.asserteq(dl,du)



