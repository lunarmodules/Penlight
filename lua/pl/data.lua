--- Reading and querying simple tabular data. 
-- <pre class=example>
-- data.read 'test.txt'
-- ==> {{10,20},{2,5},{40,50},fieldnames={'x','y'},delim=','}
-- </pre>
-- Provides a way of creating basic SQL-like queries.
-- <pre class=example>
--    require 'pl'
--    local d = data.read('xyz.txt')
--    local q = d:select('x,y,z where x > 3 and z < 2 sort by y')
--    for x,y,z in q do
--        print(x,y,z)
--    end
-- </pre>
-- <p>See <a href="../../index.html#data">the Guide</a>
-- @class module
-- @name pl.data

local stringx = require 'pl.stringx'
local utils = require 'pl.utils'
local seq = require 'pl.seq'
local tablex = require 'pl.tablex'
local List = require 'pl.list'.List
local rstrip,count = stringx.rstrip,stringx.count
local _DEBUG = rawget(_G,'_DEBUG')

local raise,patterns,choose,function_arg,split = utils.raise,utils.patterns,utils.choose,utils.function_arg,utils.split
local append,concat = table.insert,table.concat
local map,find = tablex.map,tablex.find
local gsub = string.gsub
local io = io
local _G,print,loadstring,type,tonumber,ipairs,setmetatable,pcall,error,setfenv = _G,print,loadstring,type,tonumber,ipairs,setmetatable,pcall,error,setfenv

--[[
module ('pl.data',utils._module)
]]

local data = {}

local parse_select

local DataMT = {
    column_by_name = function(self,name)
        return seq.copy(data.query(self,name))
    end,

    copy_query = function(self,condn)
        condn = parse_select(condn,self)
        local res = seq.copy_tuples(data.query(self,condn))
        res.delim = self.delim
        return new(res,List.split(condn.fields,','))
    end,

    column_names = function(self)
        return self.fieldnames
    end,
}
DataMT.__index = DataMT

-- [guessing delimiter] We check for comma, tab and spaces in that order.
-- [issue] any other delimiters to be checked?
local function guess_delim (line)
    if count(line,',') > 0 then
        return ','
    elseif count(line,'\t') > 0 then
        return '\t'
    elseif count(line,' ') > 0 then
        return '%s+'
    else
        return ' '
    end
end

-- [file parameter] If it's a string, we try open as a filename. If nil, then
-- either stdin or stdout depending on the mode. Otherwise, check if this is
-- a file-like object (implements read or write depending)
local function open_file (f,mode)
    local opened
    local reading = mode == 'r'
    if type(f) == 'string' then
        f,err = io.open(f,mode)
        if not f then return raise(err) end
        opened = true
    end
    if f and ((reading and not f.read) or (not reading and not f.write)) then
        return raise "not a file-like object"
    end
    return (f or (reading and io.stdin or io.stdout)),nil,opened
end

local function all_n ()

end

--- read a delimited file in a Lua table.
-- By default, attempts to treat first line as separated list of fieldnames.
-- @param file a filename or a file-like object (default stdin)
-- @param cnfg options table: can override delim (a string pattern), fieldnames (a list),
-- specify no_convert (default is to convert), numfields (indices of columns known
-- to be numbers) and thousands_dot (thousands separator in Excel CSV is '.')
function data.read(file,cnfg)
    local list = seq.list
    local convert,err,opened
    local D = {}
    if not cnfg then cnfg = {} end
    local f,err,opened = open_file(file,'r')
    if not f then return raise (err) end
    local thousands_dot = cnfg.thousands_dot

    local function try_tonumber(x)
        if thousands_dot then x = x:gsub('%.(...)','%1') end
        return tonumber(x)
    end

    local line = f:read()
    if not line then return raise "empty file" end
    -- first question: what is the delimiter?
    D.delim = cnfg.delim and cnfg.delim or guess_delim(line)
    local delim = D.delim
    local collect_end = cnfg.last_field_collect
    -- first line will usually be field names. Unless fieldnames are specified,
    -- we check if it contains purely numerical values for the case of reading
    -- plain D files.
    if not cnfg.fieldnames then
        local fields = List.split(line,delim)
        local nums = map(tonumber,fields)
        if #nums == #fields then
            convert = tonumber
            append(D,nums)
        else
            cnfg.fieldnames = fields
        end
        line = f:read()
    elseif type(cnfg.fieldnames) == 'string' then
        cnfg.fieldnames = List.split(cnfg.fieldnames,delim)
    end
    -- at this point, the column headers have been read in. If the first
    -- row consisted of numbers, it has already been added to the Dset.
    local numfields = cnfg.numfields
    if cnfg.fieldnames then
        D.fieldnames = cnfg.fieldnames
        -- [conversion] unless @no_convert, we need the numerical field indices
        -- of the first D row. Can also be specified by @numfields.
        if not cnfg.no_convert then
            if not numfields then
                numfields = List()
                local fields = split(line,D.delim)
                for i = 1,#fields do
                    if tonumber(fields[i]) then
                        numfields:append(i)
                    end
                end
            end
            if #numfields > 0 then -- there are numerical fields
                -- note that using dot as the thousands separator (@thousands_dot)
                -- requires a special conversion function!
                convert = thousands_dot and try_tonumber or tonumber
            end
        end
    end
    local N = #D.fieldnames
    -- keep going until finished
    while line do
        if not line:find ('^%s*$') then
            local fields =  split(line,delim)
            if convert then
                for i in list(numfields) do
                    local val = convert(fields[i])
                    if val == nil then
                        return raise ("not a number: "..fields[i])
                    else
                        fields[i] = val
                    end
                end
            end
            -- [collecting end field] If @last_field_collect then we will collect
            -- all extra space-delimited fields into a single last field.
            if collect_end and #fields > N then
                local ends = List(fields):slice(N):join ' '
                tablex.icopy(fields,{ends},N)  --*note* copy
            end
            append(D,fields)
        end
        line = f:read()
    end
    if opened then f:close() end
    if delim == '%s+' then D.delim = ' ' end
    return data.new(D)
end

local function write_row (data,f,row)
    f:write(List.join(row,data.delim),'\n')
end

DataMT.write_row = write_row

local function write (data,file)
    local f,err,opened = open_file(file,'w')
    if not f then return raise (err) end
    f:write(data.fieldnames:join(data.delim),'\n')
    for i = 1,#data do
        write_row(data,f,data[i])
    end
    if opened then f:close() end
end

DataMT.write = write

local function massage_fieldnames (fields)
    -- [fieldnames must be valid Lua identifiers] fix 0.8 was %A
    for i = 1,#fields do
        fields[i] = fields[i]:gsub('%W','_')
    end
end


--- create a new dataset from a table of rows. <br>
-- Can specify the fieldnames, else the table must have a field called
-- 'fieldnames', which is either a string of comma-separated names,
-- or a table of names.
-- @param d the table.
-- @param fieldnames optional fieldnames
-- @return the table.
function data.new (d,fieldnames)
    d.fieldnames = d.fieldnames or fieldnames
    if not d.delim and type(d.fieldnames) == 'string' then
        d.delim = guess_delim(d.fieldnames)
        d.fieldnames = split(d.fieldnames,d.delim)
    end
    d.fieldnames = List(d.fieldnames)
    massage_fieldnames(d.fieldnames)
    setmetatable(d,DataMT)
    -- a query with just the fieldname will return a sequence
    -- of values, which seq.copy turns into a table.
    return d
end

local sorted_query = [[
return function (t)
    local i = 0
    local v
    local ls = {}
    for i,v in ipairs(t) do
        if CONDITION then
            ls[#ls+1] = v
        end
    end
    table.sort(ls,function(v1,v2)
        return SORT_EXPR
    end)
    local n = #ls
    return function()
        i = i + 1
        v = ls[i]
        if i > n then return end
        return FIELDLIST
    end
end
]]

-- question: is this optimized case actually worth the extra code?
local simple_query = [[
return function (t)
    local n = #t
    local i = 0
    local v
    return function()
        repeat
            i = i + 1
            v = t[i]
        until i > n or CONDITION
        if i > n then return end
        return FIELDLIST
    end
end
]]

local function is_string (s)
    return type(s) == 'string'
end

local field_error

local function fieldnames_as_string (data)
    return concat(data.fieldnames,',')
end

local function massage_fields(data,f)
    local idx = find(data.fieldnames,f)
    if idx then
        return 'v['..idx..']'
    else
        field_error = f..' not found in '..fieldnames_as_string(data)
        return f
    end
end

local function process_select (data,parms)
    --- preparing fields ----
    local res,ret
    field_error = nil
    if parms.fields:find '^%s*%*%s*' then
        parms.fields = fieldnames_as_string(data)
    end
    local fields = rstrip(parms.fields):gsub('[^,%w]','_') -- non-identifier chars
    local massage_fields = utils.bind1(massage_fields,data)
    ret = gsub(fields,patterns.IDEN,massage_fields)
    if field_error then return raise(field_error) end
    parms.proc_fields = ret
    parms.where = parms.where or  'true'
    if is_string(parms.where) then
        parms.where = gsub(parms.where,patterns.IDEN,massage_fields)
        field_error = nil
    end
    return true
end


parse_select = function(s,data)
    local endp
    local parms = {}
    local w1,w2 = s:find('where ')
    local s1,s2 = s:find('sort by ')
    if w1 then -- where clause!
        endp = (s1 or 0)-1
        parms.where = s:sub(w2+1,endp)
    end
    if s1 then -- sort by clause (must be last!)
        parms.sort_by = s:sub(s2+1)
    end
    endp = (w1 or s1 or 0)-1
    parms.fields = s:sub(1,endp)
    local status,err = process_select(data,parms)
    if not status then return raise(err)
    else return parms end
end

--- create a query iterator from a select string.
-- Select string has this format: <br>
-- FIELDLIST [ where LUA-CONDN [ sort by FIELD] ]<br>
-- FIELDLISt is a comma-separated list of valid fields, or '*'. <br> <br>
-- The condition can also be a table, with fields 'fields' (comma-sep string or
-- table), 'sort_by' (string) and 'where' (Lua expression string or function)
-- @param data table produced by read
-- @param condn select string or table
-- @param context a list of tables to be searched when resolving functions
-- @param return_row if true, wrap the results in a row table
-- @return an iterator over the specified fields
function data.query(data,condn,context,return_row)
    local err   
    if is_string(condn) then
        condn,err = parse_select(condn,data)
        if not condn then return raise(err) end
    elseif type(condn) == 'table' then
        if type(condn.fields) == 'table' then
            condn.fields = concat(condn.fields,',')
        end
        if not condn.proc_fields then
            local status,err = process_select(data,condn)
            if not status then return raise(err) end
        end
    else
        return raise "condition must be a string or a table"
    end
    local query
    if condn.sort_by then -- use sorted_query
        query = sorted_query
    else
        query = simple_query
    end
    local fields = condn.proc_fields or condn.fields
    if return_row then
        fields = '{'..fields..'}'
    end
    query,k = query:gsub('FIELDLIST',fields)
    if is_string(condn.where) then
        query = query:gsub('CONDITION',condn.where)
        condn.where = nil
    else
       query = query:gsub('CONDITION','_condn(v)')
       condn.where = function_arg(0,condn.where,'condition.where must be callable')
    end
    if condn.sort_by then
        local expr,sort_var,sort_dir
        local sort_by = condn.sort_by
        local i1,i2 = sort_by:find('%s+')
        if i1 then
            sort_var,sort_dir = sort_by:sub(1,i1-1),sort_by:sub(i2+1)
        else
            sort_var = sort_by
            sort_dir = 'asc'
        end
        sort_var = massage_fields(data,sort_var)
        if field_error then return raise(field_error) end
        if sort_dir == 'asc' then
            sort_dir = '<'
        else
            sort_dir = '>'
        end
        expr = ('%s %s %s'):format(sort_var:gsub('v','v1'),sort_dir,sort_var:gsub('v','v2'))
        query = query:gsub('SORT_EXPR',expr)
    end
    if condn.where then
        query = 'return function(_condn) '..query..' end'
    end
    if _DEBUG then print(query) end

    local fn,err = loadstring(query,'tmp')
    if not fn then return raise(err) end
    fn = fn() -- get the function
    if condn.where then
        fn = fn(condn.where)
    end
    local qfun = fn(data)
    if context then
        -- [specifying context for condition] @context is a list of tables which are
        -- 'injected'into the condition's custom context
        append(context,_G)
        local lookup = {}
        setfenv(qfun,lookup)
        setmetatable(lookup,{
            __index = function(tbl,key)
               -- _G.print(tbl,key)
                for k,t in ipairs(context) do
                    if t[key] then return t[key] end
                end
            end
        })
    end
    return qfun
end


DataMT.select = data.query
DataMT.select_row = function(d,condn,context)
    return data.query(d,condn,context,true)
end

--- Filter input using a query.
-- @param Q a query string
-- @param file a file-like object
-- @param dont_fail true if you want to return an error, not just fail
function data.filter (Q,file,dont_fail)
    local err
    local d = read(file)
    local iter,err = d:select(Q)
    local delim = d.delim
    if not iter then
        err = 'error: '..err
        if dont_fail then
            return nil,err
        else
            utils.quit(1,err)
        end
    end
    while true do
        local res = {iter()}
        if #res == 0 then break end
        print(concat(res,delim))
    end
end

return data

