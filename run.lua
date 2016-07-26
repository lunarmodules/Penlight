-- Running tests and/or examples.
local lfs = require "lfs"

local directories = {}
local luacov = false

for _, argument in ipairs(arg) do
    if argument == "--help" then
        print("Usage: lua run.lua [--luacov] [<dir>]...")
        os.exit(0)
    elseif argument == "--luacov" then
        luacov = true
    else
        table.insert(directories, argument)
    end
end

if #directories == 0 then
    directories = {"tests", "examples"}
end

local lua = "lua"
local i = -1
while arg[i] do
    lua = arg[i]
    i = i - 1
end

if luacov then
    lua = lua .. " -lluacov"
end

local dir_sep = package.config:sub(1, 1)
local quote = dir_sep == "/" and "'" or '"'
local pl_src = "lua" .. dir_sep .. "?.lua"
lua = lua .. " -e " .. quote .. "package.path=[[" .. pl_src .. ";]]..package.path" .. quote

local function run_directory(dir)
    local files = {}
    for path in lfs.dir(dir) do
        local full_path = dir .. dir_sep .. path
        if path:find("%.lua$") and lfs.attributes(full_path, "mode") == "file" then
            table.insert(files, full_path)
        end
    end
    table.sort(files)

    for _, file in ipairs(files) do
        local cmd = lua .. " " .. file
        print("Running " .. file)
        local code1, _, code2 = os.execute(cmd)
        local code = type(code1) == "number" and code1 or code2

        if code ~= 0 then
            print(("Running %s failed with code %d"):format(file, code))
            os.exit(1)
        end
    end
end

for _, dir in ipairs(directories) do
    print("Running files in " .. dir)
    run_directory(dir)
end

print("Run completed successfully")
