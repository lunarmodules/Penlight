local stringio = require 'pl.stringio'

fs = stringio.create()
for i = 1,100 do
	fs:write('hello','\n','dolly','\n')
end
print(#fs:value())

