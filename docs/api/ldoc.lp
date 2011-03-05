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

<p>$(module.summary)</p>
<p>$(module.description)</p>

## -- bang out the table of functions for this module

#   if #module.functions > 0 then
<h2>Functions</h2>
<table class="function_list">
#  for func in iter(module.functions) do
	<tr>
	<td class="name" nowrap><a href="#$(func.name)">$(func.name)&nbsp;$(func.args)</a></td>
	<td class="summary">$(func.summary)</td>
	</tr>
#  end
</table>
# end

<br/>
<br/>

# if #module.functions > 0 then
    <h2><a name="functions"></a>Functions</h2>
    <dl class="function">
#  for func in iter(module.functions) do
    <dt>
    <a name = "$(func.name)"></a>
    <strong>$(func.name)&nbsp;$(func.args)</strong>
    </dt>
    <dd>
    $(func.summary)
    $(func.description)
#  if #func.params > 0 then
    <h3>Parameters:</h3>
    <ul>
#   for p in iter(func.params) do
       <li><code><em>$(p)</em></code>: $(func.params[p])</li>
#   end
    </ul>

#   if func.usage then
#     local li,il = use_li(func.usage)
    <h3>Usage:</h3>
    <ul>
#     for usage in iter(func.usage) do
        $(li)<pre class="example">$(usage)</pre>$(il)
#     end
    </ul>
#   end

#   if func.ret then
#     local li,il = use_li(func.ret)
    <h3>Returns:</h3>
    <ol>
#     for r in iter(func.ret3) do
        $(li)$(r)$(il)
#     end
    </ol>
#   end

#   if func.see then
#     local li,il = use_li(func.see)
    <h3>see also:</h3>
    <ul>
#     for see in iter(func.see) do
         $(li)<a href="$(see.mod).html#$(see.name)">$(see.label)</a>$(il)
#    end
    </ul>
#   end
# end
</dd>
# end
# end

</dl>

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
</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<!--
    <p><a href="http://validator.w3.org/check?uri=referer"><img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
    -->
</div> <!-- id="about" -->

</div> <!-- id="container" -->

</body>
</html>

