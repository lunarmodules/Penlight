-- testing app.parse_args
asserteq = require 'pl.test'.asserteq
parse_args = require 'pl.app'.parse_args

-- shows the use of plain flags, long and short:
flags,args = parse_args({'-abc','--flag','-v','one'})

asserteq(flags,{a=true,b=true,c=true,flag=true,v=true})
asserteq(args,{'one'})

-- flags may be given values using these three syntaxes:
flags,args = parse_args({'-n10','--out=20','-v:2'})

asserteq(flags,{n='10',out='20',v='2'})

-- a flag can be specified as taking a value:
flags,args = parse_args({'-k','-b=23','-o','hello','--out'},{o=true})

asserteq(flags,{out=true,o="hello",k=true,b="23"})


