-- indexing a library

require 'pl'
local match = sip.match_at_start

local module_name
local funs = List()

function add_function (name,sentence)
    funs:append {name,sentence,module_name}
end

function process_module (f)
    local state = 'finding_module'
    local res = {}
    module_name = nil
    for line in io.lines(f) do
        if match('--- $',line,res) then
            sentence = res[1]
            local idot = sentence:find '%.'
            if idot then
                sentence = sentence:sub(1,idot-1)
            end
        elseif match('-- @class $v',line,res) then
            if res[1] == 'module' then
                state = 'finding_module_name'
            elseif res[1] == 'function' then
                state = 'finding_function_name'
            end
        elseif match('-- @name $S',line,res) then
            if state == 'finding_module_name' then
                module_name = res[1]
            else
                add_function(res[1],sentence)
            end
            sentence = nil
        elseif match('local function $v',line,res) then
        elseif match('function $S (',line,res) then
            if sentence and module_name then
                add_function(res[1],sentence)
                sentence = nil
            end
        elseif match('module ($q',line,res) then
            if not module_name then
                module_name = res[2]  -- res[1] will be the quote used!
            end
        end
    end
end

local file = arg[1] or utils.quit 'please supply filename or path'
if path.isfile(file) then
    process_module(arg[1])
elseif path.isdir(file) then
    local files = dir.getfiles(file,'*.lua')
    for _,f in ipairs(files) do
        if f ~= '.' and f ~= '..' then
--~             print(f)
            process_module(f)
        end
    end
end

funs:sort(function(t1,t2)
    return t1[1] < t2[1]
end)

local outf = io.open('function_index.txt','w')
outf:write('#Penlight Function Index\n\n')
for i = 1,#funs do
    local t = funs[i]
    local name,mod,descript = t[1],t[3],t[2]
--~     if not mod then mod = '?' end
--~     if not t[3] then t[3] = '??' end
    name = '['..name..']('..'api/modules/'..mod..'.html#'..name..')'
    outf:write('-\t',name..'('..t[3]..')\t'..t[2],'\n')
    --print(t[1]..' ('..t[3]..')',t[2])
    --print(t[1],t[3],t[2])
end
outf:close()



