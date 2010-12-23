--- Simple command-line parsing using human-readable specification.
-- Supports GNU-style parameters.
-- <pre class=example>
--      lapp = require 'pl.lapp'
--      local args = lapp [[
--      Does some calculations
--        -o,--offset (default 0.0)  Offset to add to scaled number
--        -s,--scale  (number)  Scaling factor
--         &lt;number&gt; (number )  Number to be scaled
--      ]]
--
--      print(args.offset + args.scale * args.number)
-- </pre>
-- Lines begining with '-' are flags; there may be a short and a long name; 
-- lines begining wih '&lt;var&gt;' are arguments.  Anything in parens after
-- the flag/argument is either a default, a type name or a range constraint.
-- <p>See <a href="../../index.html#lapp">the Guide</a>
-- @class module
-- @name pl.lapp

local match = require 'pl.sip'.match_at_start
local stringx = require 'pl.stringx'
local lines,lstrip,strip,at = stringx.lines,stringx.lstrip,stringx.strip,stringx.at
local isdigit = stringx.isdigit
local append = table.insert
local tinsert = table.insert

--[[
module('pl.lapp')
]]

local lapp = {}

local open_files,parms,aliases,parmlist,usage,windows,script

local filetypes = {
    stdin = {io.stdin,'file-in'}, stdout = {io.stdout,'file-out'},
    stderr = {io.stderr,'file-out'}
}

--- quit this script immediately.
-- @param msg optional message
-- @param no_usage suppress 'usage' display
function lapp.quit(msg,no_usage)
    if msg then
        io.stderr:write(msg..'\n\n')
    end
    if not no_usage then
        io.stderr:write(usage)
    end
    os.exit(1);
end

--- print an error to stderr and quit.
-- @param msg a message
-- @param no_usage suppress 'usage' display
function lapp.error(msg,no_usage)
    lapp.quit(script..':'..msg,no_usage)
end

--- open a file.
-- This will quit on error, and keep a list of file objects for later cleanup.
-- @param file filename
-- @param opt same as second parameter of <code>io.open</code>
function lapp.open (file,opt)
    local val,err = io.open(file,opt)
    if not val then lapp.error(err,true) end
    append(open_files,val)
    return val
end

--- quit if the condition is false.
-- @param condn a condition
-- @param msg an optional message
function lapp.assert(condn,msg)
    if not condn then
        lapp.error(msg)
    end
end

local function range_check(x,min,max,parm)
    lapp.assert(min <= x and max >= x,parm..' out of range')
end

local function xtonumber(s)
    local val = tonumber(s)
    if not val then lapp.error("unable to convert to number: "..s) end
    return val
end

local function is_filetype(type)
    return type == 'file-in' or type == 'file-out'
end

local types

local function convert_parameter(ps,val)
    if ps.converter then
        val = ps.converter(val)
    end
    if ps.type == 'number' then
        val = xtonumber(val)
    elseif is_filetype(ps.type) then
        val = lapp.open(val,(ps.type == 'file-in' and 'r') or 'w' )
    elseif ps.type == 'boolean' then
        val = true
    end
    if ps.constraint then
        ps.constraint(val)
    end
    return val
end

--- add a new type to Lapp. These appear in parens after the value like
-- a range constraint, e.g. '<ival> (integer) Process PID'
-- @param name name of type
-- @param converter either a function to convert values, or a Lua type name.
-- @param constraint optional function to verify values, should use lapp.error
-- if failed.
function lapp.add_type (name,converter,constraint)
    types[name] = {converter=converter,constraint=constraint}
end

local function force_short(short)
    lapp.assert(#short==1,short..": short parameters should be one character")
end

local function process_default (sval)
	local val = tonumber(sval)
	if val then -- we have a number!
		return val,'number'
	elseif filetypes[sval] then
		local ft = filetypes[sval]
		return ft[1],ft[2]
	else
		return sval,'string'
	end
end

--- process a Lapp options string.
-- Usually called as lapp().
-- @param str the options text
-- @return a table with parameter-value pairs
function lapp.process_options_string(str)
    local results = {}
    local opts = {at_start=true}
    local varargs
	open_files = {}
	parms = {}
	aliases = {}
	parmlist = {}
	types = {}

    local function check_varargs(s)
        local res,cnt = s:gsub('%.%.%.%s*','')
        varargs = cnt > 0
        return res
    end

    local function set_result(ps,parm,val)
        if not ps.varargs then
            results[parm] = val
        else
            if not results[parm] then
                results[parm] = { val }
            else
                append(results[parm],val)
            end
        end
    end

    usage = str
    local res = {}

    for line in lines(str) do
        local optspec,optparm,i1,i2,defval,vtype,constraint
        line = lstrip(line)
        local function check(str)
            return match(str,line,res)
        end

		-- flags: either -<short>, -<short>,--<long> or --<long>
		if check '-$v{short}, --$v{long} $' or check '-$v{short} $' or check '--$v{long} $' then
			if res.long then
				optparm = res.long
                if res.short then aliases[res.short] = optparm  end
			else
				optparm = res.short
			end
            if res.short then force_short(res.short) end
            res.rest = check_varargs(res.rest)
        elseif check '$<{name} $'  then -- is it <parameter_name>?
            -- so <input file...> becomes input_file ...
            optparm = check_varargs(res.name):gsub('%A','_')
			append(parmlist,optparm)
        end
        if res.rest then -- this is not a pure doc line
            line = res.rest
			res = {}
            -- do we have (default <val>) or (<type>)?
			if match('$({def} $',line,res) or match('$({def}',line,res) then
				typespec = strip(res.def)
				if match('default $',typespec,res) then
					defval,vtype = process_default(res[1])
				elseif match('$f{min}..$f{max}',typespec,res) then
					local min,max = res.min,res.max
					vtype = 'number'
					constraint = function(x)
						range_check(x,min,max,optparm)
					end
				else -- () just contains type of required parameter
					vtype = typespec
				end
			else -- must be a plain flag, no extra parameter required
				defval = false
				vtype = 'boolean'
			end
            local ps = {
                type = vtype,
                defval = defval,
                required = defval == nil,
                comment = res.rest or optparm,
                constraint = constraint,
                varargs = varargs
            }
            varargs = nil
            if types[vtype] then
                local converter = types[vtype].converter
                if type(converter) == 'string' then
                    ps.type = converter
                else
                    ps.converter = converter
                end
                ps.constraint = types[vtype].constraint
            end
            parms[optparm] = ps
        end
    end
    -- cool, we have our parms, let's parse the command line args
    local iparm = 1
    local iextra = 1
    local i = 1
    local parm,ps,val

    while i <= #arg do
        local theArg = arg[i]
        -- look for a flag, -<short flags> or --<long flag>
		if match('--$v{long}',theArg,res) or match('-$v{short}',theArg,res) then
			if res.long then -- long option
				parm = res.long
			elseif #res.short == 1 then
				parm = res.short
			else
				local parmstr = res.short
                parm = at(parmstr,1)
				if isdigit(at(parmstr,2)) then
					-- a short option followed by a digit is an exception (for AW;))
					-- push ahead into the arg array
					tinsert(arg,i+1,parmstr:sub(2))
				else
					-- push multiple flags into the arg array!
					for k = 2,#parmstr do
						tinsert(arg,i+k-1,'-'..at(parmstr,k))
					end
				end
			end
			if parm == 'h' or parm == 'help' then
				lapp.quit()
			end
			if aliases[parm] then parm = aliases[parm] end
		else -- a parameter
			parm = parmlist[iparm]
			if not parm then
			   -- extra unnamed parameters are indexed starting at 1
			   parm = iextra
			   iextra = iextra + 1
			   ps = { type = 'string' }
			else
				ps = parms[parm]
			end
			if not ps.varargs then
				iparm = iparm + 1
			end
			val = theArg
		end
		ps = parms[parm]
		if not ps then lapp.error("unrecognized parameter: "..parm) end
		if ps.type ~= 'boolean' then -- we need a value! This should follow
            if not val then
                i = i + 1
                val = arg[i]
            end
			lapp.assert(val,parm.." was expecting a value")
		end
        ps.used = true
        val = convert_parameter(ps,val)
        set_result(ps,parm,val)
        if is_filetype(ps.type) then
            set_result(ps,parm..'_name',theArg)
        end
        if lapp.callback then
            lapp.callback(parm,theArg,res)
        end
        i = i + 1
        val = nil
    end
    -- check unused parms, set defaults and check if any required parameters were missed
    for parm,ps in pairs(parms) do
        if not ps.used then
            if ps.required then lapp.error("missing required parameter: "..parm) end
            set_result(ps,parm,ps.defval)
        end
    end
    return results
end

if arg then
    script = arg[0]:gsub('.+[\\/]',''):gsub('%.%a+$','')
else
    script = "inter"
end


setmetatable(lapp, {
    __call = function(tbl,str) return lapp.process_options_string(str) end,
})


return lapp


