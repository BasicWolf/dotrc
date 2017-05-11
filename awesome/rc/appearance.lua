local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")


-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")

config.layouts = {
   -- awful.layout.suit.floating,
   awful.layout.suit.tile,
   -- awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   -- awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   -- awful.layout.suit.fair.horizontal,
   -- awful.layout.suit.spiral,
   -- awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   -- awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier,
   -- awful.layout.suit.corner.nw,
   -- ??? awful.layout.suit.floating
}

awful.layout.layouts = config.layouts;

-- Naughty
for _,preset in pairs({"normal", "low", "critical"}) do
  naughty.config.presets[preset].font    = "Droid Sans 10"
  naughty.config.presets[preset].timeout = 5
  naughty.config.presets[preset].margin  = 10
end
