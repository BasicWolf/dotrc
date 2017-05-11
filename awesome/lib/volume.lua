-- Creates a volume display widget
-- Copied/adapted from https://awesome.naquadah.org/wiki/Davids_volume_widget
---------------------------------
local naughty = require('naughty')
local awful = require("awful")
local wibox = require("wibox")
local io = require("io")
local os = require("os")

local tonumber = tonumber
local string   = string
local config   = config
local timer = timer

module("zawesome/volume")


-- Color constants
local normal_color = '#33cc33'
local over_100_color = '#3333cc'
local mute_color = '#cc3333'
local background_color = '#222222'
local background_over_100_color = normal_color

local sink_id = '-1'

function set_default_sink()
   local cmd = "pacmd list-sinks | grep -1 '* index:' | grep 'name:' | sed 's/<\\(.*\\)>/\\1/g' | awk '{print $2}'"
   local fd = io.popen(cmd)
   sink_id = fd:read("*line")
   fd:close()
end




-- Functions to fetch volume information (pulseaudio)
function get_volume() -- returns the volume as a float (1.0 = 100%)
   if sink_id == nil then
      return 0
   end

   local cmd = string.format("pactl list | grep -A 9001 '%s' | grep Volume | head -n 1 | awk -F / '{print $2}' | sed 's/[^0-9]*//g'",
                             sink_id)
   local fd = io.popen(cmd)
   local volume_str = fd:read("*all")
   fd:close()
   -- naughty.notify({ text = volume_str, timeout = 30 })
   if volume_str == nil or volume_str == '' then
      volume_str = '0'
   end

   return tonumber(volume_str) / 100
end

function get_mute() -- returns a true value if muted or a false value if not
   if sink_id == nil then
      return true
   end

   local cmd = string.format("pactl list | grep -A 9001 '%s' | grep Mute | head -n 1", sink_id)
   fd = io.popen(cmd)
   local mute_str = fd:read("*all")
   fd:close()
   return string.find(mute_str, "yes")
end

-- Updates the volume widget's display
function update_volume(widget)
   local volume = get_volume()
   local mute = get_mute()

   -- color
   color = normal_color
   bg_color = background_color
   if volume > 1 then
      color = over_100_color
      bg_color = background_over_100_color
      volume = volume % 1
   end
   color = (mute and mute_color) or color

   widget:set_color(color)
   widget:set_background_color(bg_color)

   widget:set_value(volume)
end

-- Volume control functions for external use
function inc_volume(widget)
   local cmd = string.format("pactl set-sink-volume %s +5%%", sink_id)
   awful.util.spawn(cmd, false)
   update_volume(widget)
end

function dec_volume(widget)
   local cmd = string.format("pactl set-sink-volume %s -3%%", sink_id)
   awful.util.spawn(cmd, false)
   update_volume(widget)
end

function mute_volume(widget)
   local cmd = string.format("pactl set-sink-mute %s", sink_id)
   awful.util.spawn(cmd, false)
   update_volume(widget)
end

function create_volume_widget()
   -- Define volume widget

   volume_widget = awful.widget.progressbar()
   -- volume_widget:set_width(8)
   -- volume_widget:set_vertical(true)
   volume_widget:set_border_color('#666666')

   wrapper_widget = wibox.widget {
      volume_widget,
      forced_height = 100,
      forced_width  = 5,
      direction     = 'east',
      layout        = wibox.container.rotate,
   }

   -- Update the widget on a timer
   mytimer = timer({ timeout = 5 })
   mytimer:connect_signal("timeout", function () set_default_sink(); update_volume(volume_widget) end)
   mytimer:start()

   return volume_widget, wrapper_widget
end
