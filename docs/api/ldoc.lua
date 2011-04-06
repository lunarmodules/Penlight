require 'pl'

local append = table.insert
local template = require 'pl.template'
local lapp = require 'pl.lapp'

local args = lapp [[
ldoc, a Lua documentation generator, vs 0.1 Beta
  -d,--dir (default .) output directory
  -o  (default 'index') output name
  -v,--verbose          verbose
  -q,--quiet            suppress output
  -m,--module           module docs as text
  -s,--style (default .) directory for templates and style
  -p,--package  (default '') top-level package name (needed for module(...))
  <file> (string) source file or directory containing source
]]

local known_tags = {
    param = 'M', see = 'M', usage = 'M', ['return'] = 'M', field = 'M', author='M';
    class = 'id', name = 'id', pragma = 'id';
    copyright = 'S', description = 'S', release = 'S'
}

local kind_names = {
    ['function'] = {name='Functions',subnames='Parameters'},
    table = {name='Tables',subnames='Fields'},
    field = {name='Fields'}
}

local filename, lineno

----- some useful utility functions ------

local function module_basepath()
    local lpath = List.split(package.path,';')
    for p in lpath:iter() do
        local p = path.dirname(p)
        if path.isabs(p) then
            return p
        end
    end
end

-- split a qualified name into the module part and the name part,
-- e.g 'pl.utils.split' becomes 'pl.utils' and 'split'
local function split_dotted_name (s)
    local s1,s2 = path.splitext(s)
    if s2=='' then return nil
    else  return s1,s2:sub(2)
    end
end

-- expand lists of possibly qualified identifiers
-- given something like {'one , two.2','three.drei.drie)'}
-- it will output {"one","two.2","three.drei.drie"}
local function expand_comma_list (ls)
    local new_ls = List()
    for s in ls:iter() do
        s = s:gsub('[^%.:%w]*$','')
        if s:find ',' then
            new_ls:extend(List.split(s,'%s*,%s*'))
        else
            new_ls:append(s)
        end
    end
    return new_ls
end

local function extract_identifier (value)
    return value:match('([%.:_%w]+)')
end

-- this constructs an iterator over a list of objects which returns only
-- those objects where a field has a certain value. It's used to iterate
-- only over functions or tables, etc.
-- (something rather similar exists in LuaDoc)
local function kind_iterator (list,field,value)
    return function()
        local i = 1
        return function()
            local val = list[i]
            while val and val[field] ~= value do
                i = i + 1
                val = list[i]
            end
            i = i + 1
            if val then return val end
        end
    end
end


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

function File:new_item(tags,line)
    local item = Item(tags)
    self.items:append(item)
    item.file = self
    item.lineno = line
    return item
end


function File:finish()
    local this_mod
    local items = self.items
    for item in items:iter() do
        item:finish()
        if item.type == 'module' then
            this_mod = item
            -- if name is 'package.mod', then mod_name is 'mod'
            local package,mname = split_dotted_name(this_mod.name)
            if not package then
                mname = this_mod.name
            end
            self.modules:append(this_mod)
            this_mod.package = package
            this_mod.mod_name = mname
            this_mod.kinds = {}
        else
            if this_mod then
                -- new-style modules will have qualified names like 'mod.foo';
                -- if that's the mod_name, then we want to only use 'foo'
                local mod,fname = split_dotted_name(item.name)
                if mod == this_mod.mod_name and this_mod.tags.pragma ~= 'nostrip' then
                    item.name = fname
                end
                item.module = this_mod
                this_mod.items.by_name[item.name] = item
                this_mod.items:append(item)
                local kind = kind_names[item.type]
                item.subname = kind.subnames
                local kname = kind.name
                if not this_mod.kinds[kname] then
                    this_mod.kinds[kname] = kind_iterator (this_mod.items,'type',item.type)
                end
            else
                -- must be a free-standing function (sometimes a problem...)
            end
        end
    end
end

function Item:_init(tags)
    self.summary = tags.summary
    self.description = tags.description
    tags.summary = nil
    tags.description = nil
    self.tags = {}
    self.formal_args = tags.formal_args
    tags.formal_args = nil
    for tag,value in pairs(tags) do
        local ttype = known_tags[tag]
        if ttype == 'M' then
            if type(value) == 'string' then
                value = List{value}
            end
            self.tags[tag] = value
        elseif ttype == 'id' then
            if type(value) ~= 'string' then
                print('!',type(value),value,tag)
            else
                self.tags[tag] = extract_identifier(value)
            end
        elseif ttype == 'S' then
            self.tags[tag] = value
        else
            self:warning ('unknown tag: '..tag)
        end
    end
end


function Item:finish()
    local tags = self.tags
    self.name = tags.name
    self.type = tags.class
    tags.name = nil
    tags.class = nil
    -- see tags are multiple, but they may also be comma-separated
    if tags.see then
        tags.see = expand_comma_list(tags.see)
    end
    if self.type == 'module' then
        -- we are a module, so become one!
        self.items = List()
        self.items.by_name = {}
        setmetatable(self,Module)
    else
        -- params are either a function's arguments, or a table's fields, etc.
        local params
        if self.type == 'function' then
            params = tags.param or List()
            if tags['return'] then
                self.ret = tags['return']
            end
        else
            params = tags.field or List()
        end
        tags.param = nil
        local names,comments = List(),List()
        for p in params:iter() do
            local name,comment = p:match('%s*([%w_%.:]+)(.*)')
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
    if args.quiet then return end
    local name = self.file and self.file.filename
    if type(name) == 'table' then pretty.dump(name); name = '?' end
    name = name or '?'
    io.stderr:write(name,':',self.lineno or '?',' ',msg,'\n')
end

-- resolving @see references. A word may be either a function in this module,
-- or a module in this package. A MOD.NAME reference is within this package.
-- Otherwise, the full qualified name must be used.
-- First, check whether it is already a fully qualified module name.
-- Then split it and see if the module part is a qualified module
-- and try look up the name part in that module.
-- If this isn't successful then try prepending the current package to the reference,
-- and try to to resolve this.
function Module:resolve_references(modules)
    local found = List()

    local function process_see_reference (item,see,s)
        local mod_ref,fun_ref,name,packmod
        -- is this a fully qualified module name?
        local mod_ref = modules.by_name[s]
        if mod_ref then return mod_ref,nil end
        local packmod,name = split_dotted_name(s) -- e.g. 'pl.utils','split'
        if packmod then -- qualified name
            mod_ref = modules.by_name[packmod] -- fully qualified mod name?
            if not mod_ref then
                mod_ref = modules.by_name[self.package..'.'..packmod]
            end
            if not mod_ref then
                item:warning("module not found: "..packmod)
                return nil
            end
            fun_ref = mod_ref.items.by_name[name]
            if fun_ref then return mod_ref,fun_ref
            else
                item:warning("function not found: "..s.." in "..mod_ref.name)
            end
        else -- plain jane name; module in this package, function in this module
            mod_ref = modules.by_name[self.package..'.'..s]
            if mod_ref then return mod_ref,nil end
            fun_ref = self.items.by_name[s]
            if fun_ref then return self,fun_ref
            else
                item:warning("function not found: "..s.." in this module")
            end
        end
    end

    for item in self.items:iter() do
        local see = item.tags.see
        if see then -- this guy has @see references
            item.see = List()
            for s in see:iter() do
                local mod_ref, item_ref = process_see_reference(item,see,s)
                if mod_ref then
                    local name = item_ref and item_ref.name or ''
                    item.see:append {mod=mod_ref.name,name=name,label=s}
                    found:append{item,s}
                end
            end
        end
    end
    -- mark as found, so we don't waste time re-searching
    for f in found:iter() do
        f[1].tags.see:remove_value(f[2])
    end
end

function File:dump(verbose)
    for mod in self.modules:iter() do
        print('Module:',mod.name,mod.summary,mod.description)
        for item in mod.items:iter() do
            item:dump(verbose)
        end
    end
end

function Item:dump(verbose)
    local tags = self.tags
    local name = self.name
    if self.type == 'function' then
        name = name .. self.args
    end
    if verbose then
        print(self.type,name,self.summary)
        print(self.description)
        for p in self.params:iter() do
            print(p,self.params[p])
        end
        for tag, value in pairs(self.tags) do
            print(tag,value)
        end
    else
        print(name,self.summary)
    end
end

function Item:is_named()
    return self.tags.class ~= nil
end

local tnext = lexer.skipws

local function get_parameters (tok)
    local names = List()
    local t,name,sep
    repeat
        t,name = tnext(tok)
        if not t or t == ')' then break end
        names:append(name)
        t,sep = tnext(tok)
    until sep == ')' or not sep
    return names
end

local function get_fun_name (tok)
    local res = {}
    local _,name = tnext(tok)
    _,sep = tnext(tok)
    while sep == '.' or sep == ':' do
        append(res,name)
        append(res,sep)
        _,name = tnext(tok)
        _,sep = tnext(tok)
    end
    append(res,name)
    return table.concat(res)
end

local function strip (s)
    return s:gsub('^%s+',''):gsub('%s+$','')
end

local function extract_tags (s)
    if s:match '^%s*$' then return {} end
    local items = utils.split(s,'@')
    local summary,description = items[1]:match('([^%.]+)%.%s(.+)')
    if not summary then summary = items[1] end
    table.remove(items,1)
    local tags = {summary=summary and strip(summary),description=description and strip(description)}
    for _,item in ipairs(items) do
        local tag,value = item:match('(%a+)%s+(.+)%s*$')
        if not tag then
            print(s)
            os.exit()
        end
        value = strip(value)
        local old_value = tags[tag]
        if old_value then
            if type(old_value)=='string' then tags[tag] = List{old_value} end
            tags[tag]:append(value)
        else
            tags[tag] = value
        end
    end
    return Map(tags)
end

local quit = utils.quit


local function this_module_name (basename,fname)
    local ext
    if basename == '' then quit("module(...) needs package basename") end
    basename = path.abspath(basename)
    if basename:sub(-1,-1) ~= path.sep then
        basename = basename..path.sep
    end
    local lpath,cnt = fname:gsub('^'..utils.escape(basename),'')
    if cnt ~= 1 then quit("module(...) name deduction failed: base "..basename.." "..fname) end
    lpath = lpath:gsub(path.sep,'.')
    lpath,ext = path.splitext(lpath)
    return lpath
end

local function trim_comment (s)
    return s:gsub('^%-%-+','')
end

local function start_comment (v)
    return v:match '^%-%-%-'
end

local function empty_comment (v)
    return v:match '^%-+%s*$'
end


local function parse_file(fname)
    local f,e = io.open(fname)
    if not f then return print(e) end
    local F = File(fname)
    local module_found, module_set

    local tok = lexer.lua(f,{})

    function lineno ()
        return lexer.lineno(tok)
    end

    function filename ()
        return fname
    end

    function F:warning (msg,kind)
        kind = kind or 'warning'
        io.stderr:write(kind..' '..file..':'..lineno()..' '..msg,'\n')
    end

    function F:error (msg)
        self:warning(msg,'error')
        os.exit(1)
    end

    local t,v = tok()
    while t do
        if t == 'comment' then
            local comment = {}

            local ldoc_comment = start_comment(v)
            if empty_comment(v)  then -- ignore rest of empty start comments
                t,v = tok()
            end
            while t and t == 'comment' do
                v = trim_comment(v)
                append(comment,v)
                t,v = tok()
            end
            if not t then break end -- no more file!

            if t == 'space' then t,v = tnext(tok) end

            local fun_follows,tags
            if ldoc_comment then
                comment = table.concat(comment)
                if t == 'keyword' and v == 'local' then
                    t,v = tnext(tok)
                end
                fun_follows = t == 'keyword' and v == 'function'
                if fun_follows or comment:find '@' then
                    tags = extract_tags(comment)
                    if tags.class == 'module' then module_found = tags.name end
                end
            end
            -- some hackery necessary to find the module() call
            if not module_found then
                while t and not (t == 'iden' and v == 'module') do
                    t,v = tnext(tok)
                end
                if not t then break end
                t,v = tnext(tok)
                if t == '(' then t,v = tnext(tok) end
                if t == 'string' then
                    module_found = v
                elseif t == '...' then
                    module_found = this_module_name(args.package,fname)
                end
                -- right, we can add the module object ...
                if not tags then tags = extract_tags(comment) end
                tags.name = module_found
                tags.class = 'module'
                F:new_item(tags,lineno())
                tags = nil
            end

            -- end of a group of comments (may be just one)
            if ldoc_comment and tags then
                -- ldoc block
                if fun_follows then
                    tags.name = get_fun_name(tok)
                    tags.formal_args = get_parameters(tok)
                    tags.class = 'function'
                end
                if tags.name then
                    F:new_item(tags,lineno())
                end
            end
        end
        if t ~= 'comment' then t,v = tok() end
    end
    f:close()
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
        module_list.by_name[mod.name] = mod
    end
end

local multiple_files

if args.module then
    local fullpath,lua = path.package_path(args.file)
    if not fullpath then quit("module "..args.file.." not found on module path") end
    if not lua then quit("module "..args.file.." is a binary extension") end
    args.file = fullpath
end

if args.package == '' then
    args.package = path.splitpath(args.file)
end

if path.isdir(args.file) then
    local files = dir.getallfiles(args.file,'*.lua')
    for _,f in ipairs(files) do
        if args.v then print(path.basename(f)) end
        local F = read_file(f)
        file_list:append(F)
    end
    for F in file_list:iter() do
        extract_modules(F)
    end
    multiple_files = true
elseif path.isfile(args.file) then
    F = read_file(args.file)
    extract_modules(F)
    --F:dump(); os.exit()
else
    quit ("file or directory does not exist")
end

-- os.exit()

for mod in module_list:iter() do
    mod:resolve_references(module_list)
end
table.sort(module_list,function(m1,m2)
    return m1.name < m2.name
end)

if args.module then
    if #module_list == 0 then quit("no modules found") end
    F:dump(args.verbose)
    return
end

local css, templ = 'ldoc.css','ldoc.lp'

local module_template,err = utils.readfile (path.join(args.style,templ))
if not module_template then quit(err) end

function generate_output()

    local out,err = template.substitute(module_template,{
        _G = _G,
        ldoc = {css = css, modules = module_list}
    })
    if not path.isdir(args.dir) then
        lfs.mkdir(args.dir)
    end
    args.dir = args.dir .. path.sep

    if not path.exists(args.dir..css) then
       local cssfile = path.join(args.style,css)
        dir.copyfile(cssfile,args.dir..css)
    end

    -- make the module index
    if not out then quit(err) else
        local index = args.dir..'index.html'
        ok,err = utils.writefile(index,out)
        if err then quit(err) end
    end

    -- write out the module documentation
    if not path.isdir(args.dir..'modules') then
        lfs.mkdir(args.dir..'modules')
    end
    for m in module_list:iter() do
        out,err = template.substitute(module_template,{
            module=m, _G = _G,
            ldoc = {css = '../'..css, modules = module_list}
        })
        if not out then
            quit('template failed for '..m.name..': '..err)
        else
            ok,err = utils.writefile(args.dir..('modules/%s.html'):format(m.name),out)

        end
    end

    if not args.quiet then print('output written to '..args.dir) end
end

generate_output()

if args.verbose then
    for k in pairs(module_list.by_name) do print(k) end
end


