local awful = require("awful")
local vicious = require("vicious")

-- Initialize widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"},
                    {1, "#AECF96" }}})
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

-- local jiffies = {}
-- local activecpu = function()
--    local s = ""
--    for line in io.lines("/proc/stat") do
--       local cpu, newjiffies = string.match(line, "(cpu%d*)\ +(%d+)")
--       if cpu and newjiffies then
--          if not jiffies[cpu] then
--             jiffies[cpu] = newjiffies
--          end
--          --The string.format prevents your task list from jumping around
--          --when CPU usage goes above/below 10%
--          s = s .. " " .. cpu .. ": " .. string.format("%02d", newjiffies-jiffies[cpu]) .. "% "
--          jiffies[cpu] = newjiffies
--       end
--    end
--    return s
-- end

-- cpuinfo = widget({ type = "textbox", align = "right" })
-- awful.hooks.timer.register(1, function() cpuinfo.text = activecpu() end)
