require 'pl'
require 'pl.strict'
mod =function()
	smodule('test') --,package.strict)
	A = 1
	B = 2
	function fun()
		return A+B
	end
end
mod()

print(test.fun())
