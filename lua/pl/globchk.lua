#!/usr/bin/env lua
-- Reads luac listings and reports global variable usage
-- Lines where a global is written to are marked with 's'
-- Globals not preloaded in Lua is marked with  '!!!'

local
   _G,arg,io,ipairs,string,table,tonumber =
   _G,arg,io,ipairs,string,table,tonumber


local function process_file(filename, do_print_global_list)
   local global_list = {} -- global usages {{name=, line=, op=''},...}
   local name_list = {}   -- list of global names
   
   -- run luac, read listing,  store GETGLOBAL/SETGLOBAL lines in global_list
   do  
      local fd = io.popen( 'luac -p -l '.. filename ) 
      print('file',filename)	
      while 1 do
         local s=fd:read()
         if s==nil then break end
         local ok,_,l,op,g=string.find(s,'%[%-?(%d*)%]%s*([GS])ETGLOBAL.-;%s+(.*)$')
         if ok then
            if op=='S' then op='s' else op='' end -- s means set global
            table.insert(global_list, {name=g, line=tonumber(l), op=op})
         end
      end
   end


   table.sort (global_list,
      function(a,b)
         if a.name < b.name then return true end
         if a.name > b.name then return false end 
         if a.line < b.line then return true end
         return false
      end )
      
   do  -- print globals, grouped per name
      local prev_name 
      for _, v in ipairs(global_list) do
         local name =   v.name 
         local unknown = '   '
         if not _G[name] then unknown = '!!!' end
         if name ~= prev_name then
            if prev_name then io.write('\n') end
            table.insert(name_list,name)
            prev_name=name
            io.write(string.format (  ' %s %-12s :', unknown, name))
         end
         io.write(' ',v.line..v.op)
         
      end
      io.write('\n')
   end
   
   if do_print_global_list then
      io.write('   ')
      for i, name in ipairs(name_list) do
         io.write(name)
         if i ~= #name_list then io.write(',')  end
      end
   end
   io.write('\n')
end

if not arg[1] then
   io.write(
     table.concat({ 
       'usage: globchk.lua [-l]  <inputfiles>',
       '  -l           : also print a list of the globals on one line, for you to copy the file for declaration ',
       '  <inputfiles> : list of Lua files ',''
   },'\n' ))
   return
end

local do_print_global_list
if arg[1] == '-l' then 
   do_print_global_list = true
   table.remove(arg,1)
end

for _,filename in ipairs(arg) do 
   io.write('\n'..filename..'\n')
   process_file( filename , do_print_global_list)
end

