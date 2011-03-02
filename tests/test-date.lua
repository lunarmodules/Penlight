local asserteq = require 'pl.test'.asserteq
local dump = require 'pl.pretty'.dump
local T = require 'pl.test'.tuple

local Date = require 'pl.Date'

--[[
d = Date()
print(d)
print(d:year())
d:day(20)
print(d)
d:add {day = 2}
print(d:day())
d = Date() -- 'now'
print(d:last_day():day())
print(d:month(7):last_day())
--]]

function check_df(fmt,str,no_check)
    df = Date.Format(fmt)
    d = df:parse(str)
    --print(str,d)
    if not no_check then
        asserteq(df:tostring(d),str)
    end
end

check_df('dd/mm/yy','02/04/10')
check_df('mm/dd/yyyy','04/02/2010')
check_df('yyyy-mm-dd','2011-02-20')
check_df('yyyymmdd','20070320')

-- use single fields for 'slack' parsing
check_df('m/d/yyyy','1/5/2001',true)

check_df('HH:MM','23:10')

iso = Date.Format 'yyyy-mm-dd' -- ISO date
d = iso:parse '2010-04-10'
asserteq(T(d:day(),d:month(),d:year()),T(10,4,2010))
amer = Date.Format 'mm/dd/yyyy' -- American style
s = amer:tostring(d)
dc = amer:parse(s)
asserteq(d,dc)

d = Date() -- today
d:add { day = 1 }  -- tomorrow
assert(d > Date())
