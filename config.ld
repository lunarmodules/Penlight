project = 'Penlight'
description = 'Penlight Lua Libraries 1.14.0'
full_description = 'Penlight is a set of pure Lua libraries for making it easier to work with common tasks like iterating over directories, reading configuration files and the like. Provides functional operations on tables and sequences. Visit the <a href="https://github.com/lunarmodules/Penlight">GitHub project</a> to review the code or file issues. Skip to the @{01-introduction.md|introduction}.'
title = 'Penlight Documentation'
dir = 'docs'
style = '!fixed'
template = true
use_markdown_titles = true
topics = 'docs_topics'
examples = {'./examples','./tests/test-data.lua'}
package = 'pl'
format = 'discount'
sort_modules=true
file = './lua/pl'
kind_names={topic='Manual',module='Libraries'}
tparam_alias('array','array')
tparam_alias('array2d','array')
alias('ret',{'return',modifiers={type="$1"}})
