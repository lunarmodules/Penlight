unused_args     = false
redefined       = false
max_line_length = false

globals = {
    "ngx",
    "coroutine._wrap",
    "coroutine._yield",
    "coroutine._create",
    "coroutine._resume",
}

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

