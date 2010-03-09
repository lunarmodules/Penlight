--~ local stringio = require 'pl.stringio'
--~ require 'pl.config'
require 'pl'
asserteq = require 'pl.test'.asserteq

function testconfig(test,tbl)
    local f = stringio.open(test)
    local c = config.read(f)
    f:close()
    if not tbl then
        print(pretty.write(c))
    else
        asserteq(c,tbl)
    end
end

testconfig ([[
 ; comment 2 (an ini file)
[section!]
bonzo.dog=20,30
config_parm=here we go again
depth = 2
[another]
felix="cat"
]],{
  section_ = {
    bonzo_dog = { -- comma-sep values get split by default
      20,
      30
    },
    depth = 2,
    config_parm = "here we go again"
  },
  another = {
    felix = "\"cat\""
  }
})

testconfig ([[
# this is a more Unix-y config file
fred = 1
alice = 2
home.dog = /bonzo/dog/etc
]],{
  home_dog = "/bonzo/dog/etc",  -- note the default is {variablilize = true}
  fred = 1,
  alice = 2
})

-- altho this works, rather use pl.data.read for this kind of purpose.
testconfig ([[
# this is just a set of comma-separated values
1000,444,222
44,555,224
]],{
  {
    1000,
    444,
    222
  },
  {
    44,
    555,
    224
  }
})


