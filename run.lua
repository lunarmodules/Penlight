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

local function run_current_directory()
    local files = {}
    for path in lfs.dir(".") do
        if path:find("%.lua$") and lfs.attributes(path, "mode") == "file" then
            table.insert(files, path)
        end
    end
    table.sort(files)

    for _, file in ipairs(files) do
        local cmd = lua .. " " .. file
        print(cmd)
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
    assert(lfs.chdir(dir))
    run_current_directory()
    lfs.chdir("..")
end

print("Run completed successfully")
