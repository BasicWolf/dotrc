local wibox = require("wibox")
local io = require("io")

local tonumber = tonumber
local timer = timer

local module = {};

-- Color constants
local bar_color = "#fcc202"
local background_color = "#222222"


function get_battery_level()
   local fd = io.popen("/sys/class/power_supply/BAT0/capacity")
   local level_str = fd:read("*all")
   fd:close()

   if level_str == nil or level_str == "" then
      level_str = "0"
   end

   return tonumber(level_str) / 100
end

function update_widget(widget)
   local level = get_battery_level()

   widget:set_color(bar_color)
   widget:set_background_color(background_color)
   widget:set_value(level)
end

function module.create_battery_widget()
   local widget = wibox.widget.progressbar()
   widget:set_border_color("#666666")

   local bat_timer = timer({ timeout = 30 })
   bat_timer:connect_signal("timeout", function () update_widget(widget) end)
   bat_timer:start()

   local wrapper_widget = wibox.widget {
      widget,
      forced_height = 100,
      forced_width  = 5,
      direction     = "east",
      layout        = wibox.container.rotate,
   }

   update_widget(widget)

   return widget, wrapper_widget
end


return module;
