<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    <title>Reference</title>
    <link rel="stylesheet" href="$(ldoc.css)" type="text/css" />
</head>
<body>

<div id="container">

<div id="product">
	<div id="product_logo"></div>
	<div id="product_name"><big><b></b></big></div>
	<div id="product_description"></div>
</div> <!-- id="product" -->

<div id="main">

# local iter = ldoc.modules.iter

<!-- Menu -->

<div id="navigation">
<h1>Penlight</h1>
<ul>
  <li><strong>Index</strong></li>
</ul>

<h1>Modules</h1>
<ul>
# local this_mod = module and module.name
# local base = module and "" or "modules/"
# for mod in iter(ldoc.modules) do
#  if mod.name == this_mod then
  <li><strong>$(mod.name)</strong></li>
# else
  <li><a href="$(base..mod.name).html">$(mod.name)</a></li>
# end
#end
</ul>

</div>

<div id="content">

# if module then

<h1>Module <code>$(module.name)</code></h1>

# local function use_li(ls)
#   if #ls > 1 then return '<li>','</li>' else return '','' end
# end
# local function display_name(item)
#   if item.type == 'function' then return item.name..'&nbsp;'..item.args
#   else return item.name end
#  end

<p>$(module.summary)</p>
<p>$(module.description)</p>

## -- bang out the table of functions for this module
# for kind, items in _G.pairs(module.kinds) do
#   if items then
<h2>$(kind)</h2>
<table class="function_list">
#  for item in items() do
	<tr>
	<td class="name" nowrap><a href="#$(item.name)">$(display_name(item))</a></td>
	<td class="summary">$(item.summary)</td>
	</tr>
#  end
</table>
# end
#end

<br/>
<br/>

# --- currently works for both Functions and Tables. The params field either contains
# --- function parameters or table fields.
# for kind, items in _G.pairs(module.kinds) do if items then
    <h2><a name="$(kind)"></a>$(kind)</h2>
    <dl class="function">
#  for item in items() do
    <dt>
    <a name = "$(item.name)"></a>
    <strong>$(display_name(item))</strong>
    </dt>
    <dd>
    $(item.summary)
    $(item.description)

#  if item.params and #item.params > 0 then
    <h3>$(item.subname):</h3>
    <ul>
#   for p in iter(item.params) do
       <li><code><em>$(p)</em></code>: $(item.params[p])</li>
#   end
    </ul>
#   end

#   if item.usage then
#     local li,il = use_li(item.usage)
    <h3>Usage:</h3>
    <ul>
#     for usage in iter(item.usage) do
        $(li)<pre class="example">$(usage)</pre>$(il)
#     end
    </ul>
#   end

#   if item.ret then
#     local li,il = use_li(item.ret)
    <h3>Returns:</h3>
    <ol>
#     for r in iter(item.ret) do
        $(li)$(r)$(il)
#     end
    </ol>
#   end

#   if item.see then
#     local li,il = use_li(item.see)
    <h3>see also:</h3>
    <ul>
#     for see in iter(item.see) do
         $(li)<a href="$(see.mod).html#$(see.name)">$(see.label)</a>$(il)
#    end
    </ul>
#   end
</dd>
# end
</dl>
# end end

# else

<h2>Modules</h2>
<table class="module_list">
# for m in iter(ldoc.modules) do
	<tr>
		<td class="name"><a href="modules/$(m.name).html">$(m.name)</a></td>
		<td class="summary">$(m.summary)</td>
	</tr>
#  end
</table>

# end
</div> <!-- id="content" ->
</div> <!-- id="main" -->
<div id="about">
	<!--
    <p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
    -->
</div> <!-- id="about" -->
</div> <!-- id="container" -->
</body>
</html>

