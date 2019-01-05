local text = require 'pl.text'
local Template = text.Template
local asserteq = require 'pl.test' . asserteq


local t = Template('${here} is the $answer')
asserteq(t:substitute {here = 'one', answer = 'two'} , 'one is the two')

