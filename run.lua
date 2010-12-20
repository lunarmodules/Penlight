-- running the tests and examples
require 'pl'
local lfs = require 'lfs'

-- get the Lua executable used to invoke this script
cmd = arg[-1]
if cmd:find '%s' then
	cmd = '"'..cmd..'"'
end

function do_lua_files ()
	for _,f in ipairs(dir.getfiles('.','*.lua')) do
		print(cmd..' '..f)
		local res = os.execute(cmd..' '..f)
		if res ~= 0 then
		 print ('process failed with non-zero result: '..f)
		 os.exit(1)
		end
	end
end

if #arg == 0 then arg[1] = 'tests'; arg[2] = 'examples' end

for _,dir in ipairs(arg) do
    lfs.chdir(dir)
	do_lua_files()
end

