local awful = require("awful")
local naughty = require("naughty")

-- Simple function to load additional LUA files.
function loadrc(name, mod)
   local success
   local result

   -- Which file? In rc/ or in lib/?
   local path = awful.util.getdir("config") .. "/" ..
      (mod and "lib" or "rc") .. "/" .. name .. ".lua"

   -- If the module is already loaded, don't load it again
   if mod and package.loaded[mod] then return package.loaded[mod] end

   -- Execute the RC/module file
   success, result = pcall(function() return dofile(path) end)
   if not success then
      naughty.notify({ preset = naughty.config.presets.critical,
                       title = "Error while loading an RC file",
                       text = "When loading `" .. name .. "`, got the following error:\n" .. result
      })

      return print("E: error loading RC file '" .. name .. "': " .. result)
   end

   -- Is it a module?
   if mod then
      return package.loaded[mod]
   end

   return result
end
