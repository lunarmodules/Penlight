--- Date and Date.Format classes. <br>
-- @class module
-- @name pl.date

--[[
module("pl.date")
]]

local class = require 'pl.class'.class
local os_time, os_date = os.time, os.date

local Date = class()
Date.Format = class()

--- Date constructor.
-- @param t this can be either <ul>
-- <li>nil - use current date and time</li>
-- <li>number - seconds since epoch (as returned by os.time())</li>
-- <li>Date - copy constructor</li>
-- <li>table - table containing year, month, etc as for os.time()</li>
-- </ul>
-- @class function
-- @name Date
function Date:_init(t)
    local time
    if t == nil then
        time = os_time()
    elseif type(t) == 'number' then
        time = t
    elseif type(t) == 'table' then
        if getmetatable(t) == Date then -- copy ctor
            time = t.time
        else
            time = os_time(t)
        end
    end
    self:set(time)
end

--- set the current time of this Date object.
-- @param t seconds since epoch
function Date:set(t)
    self.time = t
    self.tab = os_date('*t',self.time)
end

--- set the year.
-- @param y Four-digit year
-- @class function
-- @name Date.year

--- set the month.
-- @param m month
-- @class function
-- @name Date.year

--- set the hour.
-- @param h hour
-- @class function
-- @name Date.year

--- set the minutes.
-- @param min minutes
-- @class function
-- @name Date.year

--- set the seconds.
-- @param sec seconds
-- @class function
-- @name Date.year

--- set the day of year.
-- @class function
-- @param yday day of year
-- @name Date.year

--- get the year.
-- @param y Four-digit year
-- @class function
-- @name Date.year

--- get the month.
-- @class function
-- @name Date.year

--- get the hour.
-- @class function
-- @name Date.year

--- get the minutes.
-- @class function
-- @name Date.year

--- get the seconds.
-- @class function
-- @name Date.year

--- get the day of year.
-- @param yday day of year
-- @name Date.year



for _,c in ipairs{'year','month','day','hour','min','sec','yday'} do
    Date[c] = function(self,val)
        if val then
            self.tab[c] = val
            self:set(os_time(self.tab))
            return self
        else
            return self.tab[c]
        end
    end
end

--- name of day of week.
-- @param full abbreviated if true, full otherwise.
function Date:weekday_name(full)
    return os_date(full and '%A' or '%a',self.time)
end

--- name of month.
-- @param full abbreviated if true, full otherwise.
function Date:month_name(full)
    return os_date(full and '%B' or '%b',self.time)
end

--- is this day on a weekend?.
function Date:is_weekend()
    return self.tab.wday == 0 or self.tab.wday == 6
end

--- add to a date object.
-- @param t a table containing one of the following keys and a value:<br>
-- year,month,day,hour,min,sec
function Date:add(t)
    local key,val = next(t)
    self.tab[key] = self.tab[key] + val
    self:set(os_time(self.tab))
    return self
end

--- last day of the month.
function Date:last_day()
    local d = 28
    local m = self.tab.month
    while self.tab.month == m do
        d = d + 1
        self:add{day=1}
    end
    self:add{day=-1}
    return self
end

--- difference between two Date objects.
-- @param d1
-- @param d2
function Date.diff(d1,d2)
    local dt = d1.time - d2.time
    return Date(dt)
end

--- long numerical ISO data format version of this date.
function Date:__tostring()
    return os_date('%Y-%m-%d %H:%M',self.time)
end

------------ Date.Format class: parsing and renderinig dates ------------

-- short field names, explicit os.date names, and a mask for allowed field repeats
local formats = {
    d = {'day',{true,true}},
    y = {'year',{false,true,false,true}},
    m = {'month',{true,true}},
    H = {'hour',{true,true}},
    M = {'min',{true,true}},
    S = {'sec',{true,true}},
}

--

--- Date.Format constructor.
-- @param fmt. A string where the following fields are significant: <ul>
-- <li>d day (either d or dd)</li>
-- <li>y year (either yy or yyy)</li>
-- <li>m month (either m or mm)</li>
-- <li>H hour (either H or HH)</li>
-- <li>M minute (either M or MM)</li>
-- <li>S second (either S or SS)</li>
-- <ul>
-- @usage df = Date.Format("yyyy-mm-dd HH:MM:SS")
-- @class function
-- @name Date.Format
function Date.Format:_init(fmt)
    local append = table.insert
    local D,PLUS,OPENP,CLOSEP = '\001','\002','\003','\004'
    local vars,used = {},{}
    local patt,outf = {},{}
    local i = 1
    while i < #fmt do
        local ch = fmt:sub(i,i)
        local df = formats[ch]
        if df then
            if used[ch] then error("field appeared twice: "..ch,2) end
            used[ch] = true
            -- this field may be repeated
            local _,inext = fmt:find(ch..'+',i+1)
            local cnt = not _ and 1 or inext-i+1
            if not df[2][cnt] then error("wrong number of fields: "..ch,2) end
            -- single chars mean 'accept more than one digit'
            local p = cnt==1 and (D..PLUS) or (D):rep(cnt)
            append(patt,OPENP..p..CLOSEP)
            append(vars,ch)
            if ch == 'y' then
                append(outf,cnt==2 and '%y' or '%Y')
            else
                append(outf,'%'..ch)
            end
            i = i + cnt
        else
            append(patt,ch)
            append(outf,ch)
            i = i + 1
        end
    end
    -- escape any magic characters
    fmt = table.concat(patt):gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
    -- replace markers with their magic equivalents
    fmt = fmt:gsub(D,'%%d'):gsub(PLUS,'+'):gsub(OPENP,'('):gsub(CLOSEP,')')
    self.fmt = fmt
    self.outf = table.concat(outf)
    self.vars = vars
--    print(self.fmt)
--    print(self.outf)

end

--- parse a string into a Date object.
-- @param str a date string
-- @return date object
function Date.Format:parse(str)
    local res = {str:match(self.fmt)}
    if #res==0 then return nil, 'cannot parse '..str end
    local tab = {}
    for i,v in ipairs(self.vars) do
        local name = formats[v][1] -- e.g. 'y' becomes 'year'
        tab[name] = tonumber(res[i])
    end
    -- os.date() requires these fields; if not present, we assume
    -- that the time set is for the current day.
    if not (tab.year and tab.month and tab.year) then
        local today = Date()
        tab.year = tab.year or today:year()
        tab.month = tab.month or today:month()
        tab.day = tab.day or today:month()
    end
    local Y = tab.year
    if Y < 100 then -- classic Y2K pivot
        tab.year = Y + (Y < 35 and 2000 or 1999)
    elseif not Y then
        tab.year = 1970
    end
    --dump(tab)
    return Date(tab)
end

--- convert a Date object into a string.
-- @param d a date object
-- @return string
function Date.Format:tostring(d)
    return os.date(self.outf,d.time)
end

return Date

