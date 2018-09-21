-- shows how a script can get a private file path
-- the output on my Windows machine is:
-- C:\Documents and Settings\steve\.testapp\test.txt
local app = require 'pl.app'
print(app.appfile 'test.txt')
