-------------------------------------------
--- Lexical scanner for creating a sequence of tokens from text. <br>
-- See the Guide for further <a href="../../index.html#lexer">discussion</a>

local tonumber,type,ipairs,_G = tonumber,type,ipairs,_G
local yield,wrap = coroutine.yield,coroutine.wrap
local strfind = string.find
local strsub = string.sub
local append = table.insert
local utils = require 'pl.utils'
local assert_arg = utils.assert_arg

module ('pl.lexer',utils._module)

local lexer = _G.pl.lexer

local NUMBER1 = '^[%+%-]?%d+%.?%d*[eE][%+%-]?%d+'
local NUMBER2 = '^[%+%-]?%d+%.?%d*'
local NUMBER3 = '^0x[%da-fA-F]+'
local IDEN = '^[%a_][%w_]*'
local WSPACE = '^%s+'
local STRING1 = "^'.-[^\\]'"
local STRING2 = '^".-[^\\]"'
local STRING3 = '^[\'"][\'"]'

local plain_matches,lua_matches,cpp_matches,lua_keyword,cpp_keyword

local function tdump(tok)
	return yield(tok,tok)
end

local function ndump(tok,options)
    if options and options.number then
        tok = tonumber(tok)
    end
	return yield("number",tok)
end

local function sdump(tok,options)
    if options and options.string then
        tok = tok:sub(2,-2)
    end
	return yield("string",tok)
end

local function chdump(tok,options)
    if options and options.string then
        tok = tok:sub(2,-2)
    end
	return yield("char",tok)
end

local function cdump(tok)
	return yield("comment",tok)
end

local function wsdump (tok)
    return yield("space",tok)
end

local function plain_vdump(tok)
    return yield("iden",tok)
end

local function lua_vdump(tok)
    if lua_keyword[tok] then
        return yield("keyword",tok)
    else
        return yield("iden",tok)
    end
end

local function cpp_vdump(tok)
    if cpp_keyword[tok] then
        return yield("keyword",tok)
    else
        return yield("iden",tok)
    end
end

--- create a plain token iterator from a string.
-- @param s the string
-- @param matches an optional match table (set of pattern-action pairs)
-- @param filter a table of token types to exclude, by default {space=true}
-- @param options a table of options; by default, {number=true,string=true},
-- which means convert numbers and strip string quotes.
function scan (s,matches,filter,options)
    assert_arg(1,s,'string')
	filter = filter or {space=true}
	options = options or {number=true,string=true}
    if filter then
        if filter.space then filter[wsdump] = true end
		if filter.comments then filter[cdump] = true end
    end
    if not matches then
        if not plain_matches then
            plain_matches = {
                {WSPACE,wsdump},
                {NUMBER3,ndump},
                {IDEN,plain_vdump},
                {NUMBER1,ndump},
                {NUMBER2,ndump},
                {STRING3,sdump},
                {STRING1,sdump},
                {STRING2,sdump},
                {'^.',tdump}
            }
        end
        matches = plain_matches
    end
	function lex ()
		local i1,i2,idx,res1,res2,tok,pat,fun
		local sz = #s
        --print('sz',sz)
		while true do
			for _,m in ipairs(matches) do
                pat = m[1]
                fun = m[2]
				i1,i2 = strfind(s,pat,idx)
				if i1 then
					tok = strsub(s,i1,i2)
					idx = i2 + 1
                    if not (filter and filter[fun]) then
                        --print(s,pat,idx,tok)
                        lexer.finished = idx > sz
                        res1,res2 = fun(tok,options)
                        --print(res1,res2)
                    end
                    if res1 then
                        -- insert a token list
                        if type(res1)=='table' then
                            yield('','')
                            for _,t in ipairs(res1) do
                                --print('insert',t[1],t[2])
                                yield(t[1],t[2])
                            end
                        else -- or search up to some special pattern
                            i1,i2 = strfind(s,res1,idx)
                            if i1 then
                                tok = strsub(s,i1,i2)
                                idx = i2 + 1
                                yield('',tok)
                            else
                                yield('','')
                                idx = sz + 1
                            end
							if idx > sz then return end
                        end
                    end
					if idx > sz then return  -- print 'ret';
					else break end
				end
			end
		end
	end
	return wrap(lex)
end

local function isstring (s)
    return type(s) == 'string'
end

--- insert tokens into a stream.
-- @param tok a token stream
-- @param a1 a string is the type, a table is a token list and
-- a function is assumed to be a token-like iterator (returns type & value)
-- @param a2 a string is the value
function insert (tok,a1,a2)
    if not a1 then return end
    local ts
    if isstring(a1) and isstring(a2) then
        ts = {{a1,a2}}
    elseif type(a1) == 'function' then
        ts = {}
        for t,v in a1() do
            append(ts,{t,v})
        end
    else
        ts = a1
    end
    tok(ts)
end

--- get everything in a stream upto a newline.
-- @param tok a token stream
-- @return a string
function getline (tok)
    local t,v = tok('.-\n')
    return v
end

--- get the rest of the stream.
-- @param tok a token stream
-- @return a string
function getrest (tok)
    local t,v = tok('.+')
    return v
end

--- get the Lua keywords as a set-like table.
-- So <code>res["and"]</code> etc would be <code>true</code>.
-- @return a table
function get_keywords ()
    if not lua_keyword then
        lua_keyword = {
            ["and"] = true, ["break"] = true,  ["do"] = true,
            ["else"] = true, ["elseif"] = true, ["end"] = true,
            ["false"] = true, ["for"] = true, ["function"] = true,
            ["if"] = true, ["in"] = true,  ["local"] = true, ["nil"] = true,
            ["not"] = true, ["or"] = true, ["repeat"] = true,
            ["return"] = true, ["then"] = true, ["true"] = true,
            ["until"] = true,  ["while"] = true
        }
    end
    return lua_keyword
end


--- create a Lua token iterator from a string. Will return the token type and value.
-- @param s the string
-- @param filter a table of token types to exclude, by default {space=true,comments=true}
-- @param options a table of options; by default, {number=true,string=true},
-- which means convert numbers and strip string quotes.
function lua(s,filter,options)
    assert_arg(1,s,'string')
	filter = filter or {space=true,comments=true}
    get_keywords()
    if not lua_matches then
        lua_matches = {
            {WSPACE,wsdump},
            {NUMBER3,ndump},
            {IDEN,lua_vdump},
            {NUMBER1,ndump},
            {NUMBER2,ndump},
            {STRING3,sdump},
            {STRING1,sdump},
            {STRING2,sdump},
            {'^%-%-.-\n',cdump},
            {'^%[%[.+%]%]',sdump},
            {'^%-%-%[%[.+%]%]',cdump},
            {'^==',tdump},
            {'^~=',tdump},
            {'^<=',tdump},
            {'^>=',tdump},
            {'^%.%.%.',tdump},
            {'^.',tdump}
        }
    end
    return scan(s,lua_matches,filter,options)
end

--- create a C/C++ token iterator from a string. Will return the token type type and value.
-- @param s the string
-- @param filter a table of token types to exclude, by default {space=true,comments=true}
-- @param options a table of options; by default, {number=true,string=true},
-- which means convert numbers and strip string quotes.
function cpp(s,filter,options)
    assert_arg(1,s,'string')
	filter = filter or {comments=true}
    if not cpp_keyword then
        cpp_keyword = {
            ["class"] = true, ["break"] = true,  ["do"] = true, ["sizeof"] = true,
            ["else"] = true, ["continue"] = true, ["struct"] = true,
            ["false"] = true, ["for"] = true, ["public"] = true, ["void"] = true,
            ["private"] = true, ["protected"] = true, ["goto"] = true,
            ["if"] = true, ["static"] = true,  ["const"] = true, ["typedef"] = true,
            ["enum"] = true, ["char"] = true, ["int"] = true, ["bool"] = true,
            ["long"] = true, ["float"] = true, ["true"] = true, ["delete"] = true,
            ["double"] = true,  ["while"] = true, ["new"] = true, ["delete"] = true,
            ["namespace"] = true, ["try"] = true, ["catch"] = true,
            ["switch"] = true, ["case"] = true, ["extern"] = true,
        }
    end
    if not cpp_matches then
        cpp_matches = {
            {WSPACE,wsdump},
            {NUMBER3,ndump},
            {IDEN,cpp_vdump},
            {NUMBER1,ndump},
            {NUMBER2,ndump},
            {STRING3,sdump},
            {STRING1,chdump},
            {STRING2,sdump},
            {'^//.-\n',cdump},
            {'^/%*.-%*/]',cdump},
            {'^==',tdump},
            {'^!=',tdump},
            {'^<=',tdump},
            {'^>=',tdump},
            {'^->',tdump},
            {'^&&',tdump},
            {'^||',tdump},
            {'^%+%+',tdump},
            {'^%-%-',tdump},
            {'^%+=',tdump},
            {'^%-=',tdump},
            {'^%*=',tdump},
            {'^/=',tdump},
            {'^|=',tdump},
            {'^%^=',tdump},
            {'^::',tdump},
            {'^.',tdump}
        }
    end
    return scan(s,cpp_matches,filter,options)
end

--- get a list of parameters separated by a delimiter from a stream.
-- @param tok the token stream
-- @param endtoken end of list (default ')'). Can be '\n'
-- @param delim separator (default ',')
-- @return a list of token lists.
function get_separated_list(tok,endtoken,delim)
    endtoken = endtoken or ')'
    delim = delim or ','
    local parm_values = {}
    local level = 1 -- used to count ( and )
    local tl = {}
    local function tappend (tl,tok,val)
        val = val or tok
        append(tl,{tok,val})
    end
    local is_end
    if endtoken == '\n' then
        is_end = function(tok,val)
            return tok == 'space' and val:find '\n'
        end
    else
        is_end = function (tok)
            return tok == endtoken
        end
    end
    while true do
        token,value=tok()
        if not token then return end -- end of stream is an error!
        if token == '(' then
            level = level + 1
            tappend(tl,'(')
        elseif token == ')' then
            level = level - 1
            if level == 0 then -- finished with parm list
                append(parm_values,tl)
                break
            else
                tappend(tl,')')
            end
        elseif token == delim and level == 1 then
            append(parm_values,tl) -- a new parm
            tl = {}
        elseif is_end(token,value) and level == 1 then
            append(parm_values,tl)
            break
        else
            tappend(tl,token,value)
        end
    end
    return parm_values
end

--- get the next non-space token from the stream.
-- @param tok the token stream.
function skipws (tok)
	local t,v = tok()
	while t == 'space' do
		t,v = tok()
	end
	return t,v
end

--- get the next token, which must be of the expected type.
-- Throws an error if this type does not match!
-- @param tok the token stream
-- @param expected_type the token type
-- @param no_skip_ws whether we should skip whitespace
function expecting (tok,expected_type,no_skip_ws)
    assert_arg(2,expected_type,'string')
    local t,v
	if no_skip_ws then
		t,v = tok()
	else
		t,v = skipws(tok)
	end
	if t ~= expected_type then utils.error ("expecting "..expected_type) end
	return v
end

