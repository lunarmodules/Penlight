local os = require("os")

local Date2 = {}
local Date2_mt = { __index=Date2 }

--- Calculate the offset from UTC.
local function calc_gmtoff(ts)
    local utc = os.date("!*t", ts)
    local lcl = os.date("*t", ts)
    lcl.isdst = false
    return os.difftime(os.time(lcl), os.time(utc))
end

--- equality between Date objects.
function Date2_mt:__eq(d)
    if getmetatable(d) ~= Date2_mt then
    	return false
    end
    return self._ts == d._ts
end

--- equality between Date objects.
function Date2_mt:__lt(d)
    if getmetatable(d) ~= Date2_mt then
    	return false
    end
    return self._ts < d._ts
end

--- long numerical ISO data format version of this date.
function Date2_mt:__tostring()
    return os.date("%Y-%m-%d %H:%M:%S", self._ts)
end

--- Date constructor.
--
-- @param dt The date[time] to initialize with.
--   * `nil` or empty - Use current time.
--   * `number` - Seconds since Epoch.
--   * `Date2` - Copy.
--   * `table` - table containing year, month, etc as for `os.time`. You may leave out time component.
-- @return A date object.
function Date2:new(dt)
    local dt_type
    local o = setmetatable({}, Date2_mt)

    dt_type = type(dt)
    if dt == nil then
        o._ts = os.time()
    elseif dt_type == "number" then
    	o._ts = dt
    elseif dt_type == "table" then
        if getmetatable(dt) == Date2_mt then
        	o._ts = dt._ts
        else
            o._ts = os.time(dt)
        end
    end

    return o
end
setmetatable(Date2, { __call=Date2.new })

--- Convert to a table with the broken out time.
-- @return `os.date` like broken out time. Includes the additional gmtoff field which contains the offset
-- from UTC.
function Date2:to_tm()
    local tm
    tm        = os.date("*t", self._ts)
    tm.gmtoff = calc_gmtoff(self._ts)
    return tm
end

--- Name of day of week.
-- @param full abbreviated if true, full otherwise.
-- @return string name
function Date2:weekday_name(full)
    return os.date(full and "%A" or "%a", self._ts)
end

--- Name of month.
-- @param full abbreviated if true, full otherwise.
-- @return string name
function Date2:month_name(full)
    return os.date(full and "%B" or "%b", self._ts)
end

--- Is this day on a weekend?.
function Date2:is_weekend()
    local tm = self:to_tm()
    return tm.wday == 1 or tm.wday == 7
end

--- Is DST in effect.
function Date2:is_dst()
    return self:to_tm().isdst
end

--- Modifies the date/time.
-- @param t What to add to the time. Can be negative.
--   * `number` - Seconds to adjust by.
--   * `table` - Table containing year, month, etc to to adjust each broken out field by.
function Date2:add(t)
    local cur_tm
    local t_type = type(t)

    if t_type == "number" then
    	self._ts = self._ts + t
    elseif t_type == "table" then
        cur_tm = self:to_tm()
        for _,k in ipairs({ "year", "month", "day", "hour", "min", "sec" }) do
            cur_tm[k] = cur_tm[k] + (t[k] or 0)
        end
        self._ts = os.time(cur_tm)
    end
end

--- Returns the UTC time stamp for the object.
function Date2:to_utc()
    return self._ts
end

--- Get the difference in seconds between two date objects.
-- @param d The date to take the difference from.
function Date2:diff(d)
   	return  os.difftime(self._ts, d._ts)
end

return Date2
