unused_args     = false
redefined       = false
max_line_length = false

globals = {
    "ngx",
}

not_globals = {
    "string.len",
    "table.getn",
}


exclude_files = {
    "tests/*.lua",
    "tests/**/*.lua",
    -- Travis Lua environment
    "here/*.lua",
    "here/**/*.lua",
    -- GH Actions Lua Environment
    ".lua",
    ".luarocks",
    ".install",

    -- TODO: fix these files
    "examples/symbols.lua",
    "examples/test-symbols.lua",
}

