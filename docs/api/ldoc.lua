require 'pl'

local append = table.insert
local template = require 'pl.template'

local known_tags = {
    param = 'M', see = 'M', usage = 'M', ['return'] = 'M';
    class = true, name = true
}

-- we process each file, resulting in a File object, which has a list of Item objects.
-- Items can be modules, functions or tables.
-- When the File object is finalized, we specialize some items as modules and put
-- the functions inside it as item.functions.

class.File()
class.Item()
class.Module(Item)

function File:_init(filename)
    self.filename = filename
    self.items = List()
    self.modules = List()
end

function File:new_item(summary,description,line)
    local item = Item(summary,description)
    self.items:append(item)
    item.file = self
    item.lineno = line
    return item
end


local function split_dotted_name (s)
    local s1,s2 = path.splitext(s)
    if s2=='' then return nil
    else  return s1,s2:sub(2)
    end
end

function File:finish()
    -- this finishes the items and puts them into their appropriate lists
    local this_mod
    local items = List(self.items) -- make a copy; we'll remove from the original
    for item in items:iter() do
        item:finish()
        if item.type == 'module' then
            self.modules:append(item)
            self.items:remove_value(item)
            this_mod = item
            -- if name is 'package.mod', then mod_name is 'mod'
            local package,mname = split_dotted_name(this_mod.name)
            if not package then
                mname = this_mod.name
            end
            this_mod.package = package
            this_mod.mod_name = mname
        elseif item.type == 'function' then
            if this_mod then
                this_mod.functions:append(item)
                self.items:remove_value(item)
                -- new-style modules will have qualified names like 'mod.foo';
                -- if that's the mod_name, then we want to only use 'foo'
                local mod,fname = split_dotted_name(item.name)
                  if mod == this_mod.mod_name then
                    item.name = fname
                end
                item.module = this_mod
                this_mod.functions.by_name[item.name] = item
            else
                -- must be a free-standing function (sometimes a problem...)
            end
        end
    end
end

function Item:_init(summary,description)
    self.summary = summary
    self.description = description
    self.tags = {}
end

function Item:finish()
    self.name = self.tags.name
    self.type = self.tags.class
    self.tags.name = nil
    self.tags.class = nil
    if self.type == 'module' then
        self.functions = List()
        self.functions.by_name = {}
        setmetatable(self,Module)
    elseif self.type == 'function' then
        local params = self.tags.param or List()
        self.tags['param'] = nil
        local names,comments = List(),List()
        for p in params:iter() do
            local name,comment = p:match('%s*([%w_]+)(.*)')
            names:append(name)
            comments:append(comment)
        end
        -- not all arguments may be commented --
        if self.formal_args then
            for a in self.formal_args:iter() do
                if not names:index(a) then
                    names:append(a)
                    comments:append ''
                end
            end
        end
        self.params = names
        for i,name in ipairs(self.params) do
            self.params[name] = comments[i]
        end
        self.args = '('..self.params:join(', ')..')'
    end
end

function Item:warning(msg)
    io.stderr:write(self.file.filename,':',self.lineno,' ',msg,'\n')
end

-- resolving @see references. We start by looking in the current module.
-- If it's an unqualified name, then it must match there (sorry, no globals!)
-- If it's 'mod.name' then it can match within the current package;
-- If fully qualified 'package.mod.name' then it can match anywhere.
function Module:resolve_references(modules)
    local found = List()
    for fun in self.functions:iter() do
        local see = fun.tags.see
        if see then -- this guy has @see references
            fun.see = List()
            for s in see:iter() do
                local modname,name = split_dotted_name(s) -- e.g. 'mod','fun'
                local mod,ref
                if modname then -- qualified name
                    if modname == self.package then -- probably a module reference
                        ref = modules.by_name[s]
                        name = ''
                    else
                        local pack,mname = split_dotted_name(modname)
                        --print(modname,mname,pack)
                        if pack then modname = mname end
                        mod = modules.by_name[modname]
                        if not mod then
                            fun:warning("module not found: "..modname)
                            print(s)
                        else
                            ref = mod.functions.by_name[name]
                            if not ref then
                               fun:warning("function not found: "..name.." in "..modname)
                            end
                        end
                    end
                else -- plain jane name; must be in this module
                    mod = self
                    name = s
                    ref = self.functions.by_name[s]
                    if not ref then fun:warning("function not found: "..s.." in this module") end
                end
                if ref then
--~                     if self.mod_name == 'utils' then
--~                         print('gotcha',mod.name,name,s)
--~                     end
                    fun.see:append {mod=mod.name,name=name,label=s}
                    found:append{fun,s}
               end
            end
        end
    end
    -- mark as found, so we don't waste time re-searching
    for f in found:iter() do
        f[1].tags.see:remove_value(f[2])
    end
end

function File:dump()
    for mod in self.modules:iter() do
        print('++++Module:',mod.name,mod.summary)
        for item in mod.functions:iter() do
            print '---'
            item:dump()
        end
    end
    if #self.items > 0 then
        print 'NOT CATEGORIZED'
        for item in self.items:iter() do item:dump() end
    end
end

function Item:dump()
    local tags = self.tags
    local name = self.name
    if self.type == 'function' then
        name = name .. self.args
    end
    print(self.type,name,self.summary)
    print(self.description)
    for p in self.params:iter() do
        print(p,self.params[p])
    end
    for tag, value in pairs(self.tags) do
        print(tag,value)
    end
end

function Item:set_tag (tag,value)
    local tags = self.tags
    local ttype = known_tags[tag]
    if ttype == 'M' then
        if not tags[tag] then tags[tag] = List() end
        tags[tag]:append(value)
    elseif ttype then
        tags[tag] = value
    else
        error("unknown tag")
    end
end

function Item:update_tag (tag,value)
    local tags = self.tags
    local last_value = tags[tag]
    value = '\n'..value
    if last_value then
        if known_tags[tag] == 'M' then
            local last = #last_value
            last_value[last] = last_value[last] .. value
        else
            tags[value] = last_value .. value
        end
    end
end

function Item:set_args(argstr)
    self.formal_args = List.split(argstr:sub(2,-2),',')
end

function Item:is_named()
    return self.tags.class ~= nil
end


function parse_file(file)
    local f,e = io.open(file)
    if not f then return print(e) end
    local F = File(file)
    local lno = 1

    function F:warning (msg,kind)
        kind = kind or 'warning'
        io.stderr:write(kind..' '..file..':'..lno..' '..msg,'\n')
    end

    function F:error (msg)
        self:warning(msg,'error')
        os.exit(1)
    end

    -- get the next trimmed line, incrementing line count
    local function read_line ()
        local line = f:read()
        if not line then return nil end
        lno = lno + 1
        return line
    end

    -- get the next comment line, optionally skipping until we match.
    -- returns the comment header (e.g. '--') and the comment text
    local function read_comment_line (skip)
        local line
        repeat
            line = read_line()
            if not line then return nil end
            local com,rest = line:match('(%-+)(.+)')
            if com then return com,rest end
        until not skip
        return nil,line
    end

    local function read_upto_tag_or_end ()
        local res = {}
        while true do
            com,line = read_comment_line()
            if not com then
                return table.concat(res,'\n'),nil,line
            end
            if line:match '%s*@' then
                local tag,value = line:match '@(%a+)%s*(.+)'
                return table.concat(res,'\n'),tag,value
            end
            append(res,line)
        end
    end

    local com,l = read_comment_line()
    while l do
        if com == '---' then -- item
            local summary = l:match('.-%.%s') or l
            local rest,tag,value = read_upto_tag_or_end()
            local item = F:new_item(summary,rest,lno)
            local last_tag
            while tag do
                item:set_tag(tag,value)
                last_tag = tag
                rest,tag,value = read_upto_tag_or_end()
                if rest ~= '' then
                    item:update_tag(last_tag,rest)
                end
            end
            if not item:is_named() then
                l = value
                local name,type,args
                if l:match('%s*function') then
                    name,args = l:match('function%s*(%S+)%s*(%b())')
                    type = 'function'
                    item:set_args(args)
                elseif l:match('%*module') then
                    name = l:match('module%s*%([\'"](.-)[\'"]')
                    type = 'module'
                end
                item:set_tag('name',name)
                item:set_tag('class',type)
            end
        end
        -- hunt for next comment line
        com,l = read_comment_line(true)
    end
    return F
end

function read_file(name)
    local F = parse_file(name)
    F:finish()
    return F
end

local F
local file_list,module_list = List(),List()
module_list.by_name = {}

local function extract_modules (F)
    for mod in F.modules:iter() do
        module_list:append(mod)
        module_list.by_name[mod.mod_name] = mod
--        print(mod.mod_name)
    end
end

if path.isdir(arg[1]) then
    local files = dir.getallfiles(arg[1],'*.lua')
    for _,f in ipairs(files) do
        --print(path.basename(f))
        local F = read_file(f)
        file_list:append(F)
    end
    for F in file_list:iter() do
        extract_modules(F)
    end
else
    F = read_file(arg[1])
    extract_modules(F)
    --F:dump()
end

for mod in module_list:iter() do
    mod:resolve_references(module_list)
end
table.sort(module_list,function(m1,m2)
    return m1.name < m2.name
end)

local function quit (msg)
    io.stderr:write(msg,'\n')
    os.exit(1)
end


local module_template = utils.readfile 'ldoc.lp'

function generate_output()
    local out,err = template.substitute(module_template,{
        ldoc = {css = 'ldoc.css', modules = module_list}
    })
    if not out then quit(err) else
        utils.writefile('index.html',out)
    end
    for m in module_list:iter() do
        out,err = template.substitute(module_template,{
            module=m,
            ldoc = {css = 'ldoc.css', modules = module_list}
        })
        if not out then
            print('template failed for '..m.name)
            print(err)
        else
            utils.writefile(('modules/%s.html'):format(m.name),out)
        end
    end
end

generate_output()


