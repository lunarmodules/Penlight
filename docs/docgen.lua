-- massaging @see references in the markdown source.
-- (for a more elegant way of doing this, see seesubst.lua in the examples
-- directory.)
local lua = arg[-1]
local markdown_dir = arg[1] or '.'
if lua:find ' ' then lua = '"'..lua..'"' end

function markdown (file,tmp)
    local tmp_created
    if tmp then
        local f = io.open (tmp,'w')
        for line in io.lines (file) do
            line = line:gsub('@see [%a%.]+',function(s)
                s = s:gsub('@see ','')
                local m,fun = s:match('(.-)%.(.+)')
                if not m then m = s end
                local res = '[see '..s..'](api/modules/pl.'..m..'.html'
                if fun then return res..'#'..s..')'
                else return res..')'
                end
            end)
            f:write(line,'\n')
        end
        f:close()
        tmp_created = true
    else
        tmp = file
    end
    local cmd = lua..' '..markdown_dir..'/markdown.lua -s doc.css -l '..tmp
    print(cmd)
    os.execute (cmd)
    if tmp_created then os.remove (tmp) end
end

markdown ('penlight.md','index.txt')
markdown ('function_index.txt')








