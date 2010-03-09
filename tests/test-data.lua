--_DEBUG=true
data = require 'pl.data'
List = require 'pl.list' . List
array = require 'pl.array2d'
seq = require 'pl.seq'
utils = require 'pl.utils'
open = require 'pl.stringio'. open
asserteq = require 'pl.test' . asserteq

-- tab-separated data, explicit column names
t1f = open [[
EventID	Magnitude	LocationX	LocationY	LocationZ	LocationError	EventDate	DataFile
981124001	2.0	18988.4	10047.1	4149.7	33.8	24/11/1998 11:18:05	981124DF.AAB
981125001	0.8	19104.0	9970.4	5088.7	3.0	25/11/1998 05:44:54	981125DF.AAB
981127003	0.5	19012.5	9946.9	3831.2	46.0	27/11/1998 17:15:17	981127DF.AAD
981127005	0.6	18676.4	10606.2	3761.9	4.4	27/11/1998 17:46:36	981127DF.AAF
981127006	0.2	19109.9	9716.5	3612.0	11.8	27/11/1998 19:29:51	981127DF.AAG
]]

t1 = data.read (t1f)
-- column_by_name returns a List
asserteq(t1:column_by_name 'Magnitude',List{2,0.8,0.5,0.6,0.2})
-- can use array.column as well
asserteq(array.column(t1,2),{2,0.8,0.5,0.6,0.2})

-- only numerical columns (deduced from first data row) are converted by default
-- can look up indices in the list fieldnames.
EDI = t1.fieldnames:index 'EventDate'
assert(type(t1[1][EDI]) == 'string')

-- select method returns a sequence, in this case single-valued.
-- (Note that seq.copy returns a List)
asserteq(seq(t1:select 'LocationX where Magnitude > 0.5'):copy(),List{18988.4,19104,18676.4})

--[[
--a common select usage pattern:
for event,mag in t1:select 'EventID,Magnitude sort by Magnitude desc' do
    print(event,mag)
end
--]]

-- space-separated, but with last field containing spaces.
t2f = open [[
USER PID %MEM %CPU COMMAND
sdonovan 2333  0.3 0.1 background --n=2
root 2332  0.4  0.2 fred --start=yes
root 2338  0.2  0.1 backyard-process
]]

t2 = data.read(t2f,{last_field_collect=true})

-- the last_field_collect option is useful with space-delimited data where the last
-- field may contain spaces. Otherwise, a record count mismatch should be an error!
asserteq(List(t2[2]):join ',','root,2332,0.4,0.2,fred --start=yes')

-- fieldnames are converted into valid identifiers by substituting _
-- (we do this to make select queries parseable by Lua)
asserteq(t2.fieldnames,List{'USER','PID','_MEM','_CPU','COMMAND'})

-- select queries are NOT SQL so remember to use == ! (and no 'between' operator, sorry)
--s,err = t2:select('_MEM where USER="root"')
--assert(err == [[[string "tmp"]:9: unexpected symbol near '=']])

s = t2:select('_MEM where USER=="root"')
assert(s() == 0.4)
assert(s() == 0.2)
assert(s() == nil)

-- CSV, Excel style
t3f = open [[
Department Name,Employee ID,Project,Hours Booked
sales,1231,overhead,4
sales,1255,overhead,3
engineering,1501,development,5
engineering,1501,maintenance,3
engineering,1433,maintenance,10
]]

t3 = data.read(t3f)

-- a common operation is to select using a given list of columns, and each row
-- on some explicit condition. The select() method can take a table with these
-- parameters
keepcols = {'Employee_ID','Hours_Booked'}

q = t3:select { fields = keepcols,
    where = function(row) return row[1]=='engineering' end
    }

asserteq(seq.copy2(q),{{1501,5},{1501,3},{1433,10}})

-- another pattern is doing a select to restrict rows & columns, process some
-- fields and write out the modified rows.

utils.import 'pl.func'

outf = pl.stringio.create()

names = {[1501]='don',[1433]='dilbert'}

t3:write_row (outf,{'Employee','Hours_Booked'})
q = t3:select_row {fields=keepcols,where=Eq(_1[1],'engineering')}
for row in q do
    row[1] = names[row[1]]
    t3:write_row(outf,row)
end

asserteq(outf:value(),
[[
Employee,Hours_Booked
don,5
don,3
dilbert,10
]])








