local awful = require("awful")
local menubar = require("menubar")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- {{{ Load either debian or locally generated menu
function load_debian_menu()
   require("debian.menu")
end

if pcall(load_debian_menu) then
   xdgmenu = debian.menu.Debian_menu.Debian
else
   loadrc("xdgmenu")
end
--- }}}

shutdown_commands_menu = {
   {
      "Logout",
      function()
         awful.util.spawn("xscreensaver-command -lock", false)
         awful.util.spawn("dm-tool switch-to-greeter", false)
      end
   },
   {
      "Suspend",
      function()
         awful.util.spawn("xscreensaver-command -lock", false)
         awful.util.spawn("systemctl suspend", false)
      end
   },
   -- { "Restart", function() awful.util.spawn("systemctl reboot", false) end },
   -- { "Power off", function() awful.util.spawn("systemctl poweroff", false) end }
}


-- {{{ Helper functions
function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}


-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", config.terminal .. " -e man awesome" },
   { "edit config", config.editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({
      items = {
         { "awesome", myawesomemenu, beautiful.awesome_icon },
         { "applications", xdgmenu },
         { "open terminal", config.terminal },
         { "shutdown", shutdown_commands_menu }
      }
})

mylauncher = awful.widget.launcher({
      image = beautiful.awesome_icon,
      menu = mymainmenu
})

-- Menubar configuration
-- Set the terminal for applications that require it
menubar.utils.terminal = config.terminal

