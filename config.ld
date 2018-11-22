project = 'Penlight'
description = 'Penlight Lua Libraries 1.6.0'
full_description = 'The documentation is available @{01-introduction.md|here}.'
title = 'Penlight Documentation'
dir = 'docs'
style = '!fixed'
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
