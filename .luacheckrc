unused_args     = false
redefined       = false
max_line_length = false


not_globals = {
    "string.len",
    "table.getn",
}


exclude_files = {
    "tests/*.lua",
    "tests/**/*.lua",
    "here/*.lua",
    "here/**/*.lua",

    -- TODO: fix these files
    "examples/symbols.lua",
    "examples/test-symbols.lua",
}

