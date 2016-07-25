-- testing app.parse_args
local asserteq = require 'pl.test'.asserteq
local app = require 'pl.app'
local path = require 'pl.path'
local parse_args = app.parse_args

-- shows the use of plain flags, long and short:
local flags,args = parse_args({'-abc','--flag','-v','one'})

asserteq(flags,{a=true,b=true,c=true,flag=true,v=true})
asserteq(args,{'one'})

-- flags may be given values if the value follows or is separated by equals
flags,args = parse_args({'-n10','--out=20'})

asserteq(flags,{n='10',out='20'})
asserteq(args,{})

-- a flag can be explicitly specified as taking a value:
flags,args = parse_args({'-k','-b=23','-o','hello','--out'},{o=true})

asserteq(flags,{out=true,o="hello",k=true,b="23"})
asserteq(args,{})

local ok,err = parse_args({'-n'},{n=true})
asserteq(ok,nil)
asserteq(err, "no value for 'n'")

ok,err = parse_args({'-n','-n'},{n=true})
asserteq(ok,nil)
asserteq(err, "no value for 'n'")

-- modify this script's module path so it looks in the 'lua' subdirectory
-- for its modules
app.require_here 'lua'

asserteq(require 'foo.args'.answer(),42)
asserteq(require 'bar'.name(),'bar')


asserteq(
    app.appfile 'config',
    path.expanduser('~/.test-args/config'):gsub('/',path.sep)
)




