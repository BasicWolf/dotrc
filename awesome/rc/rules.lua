local awful = require("awful")
local beautiful = require("beautiful")

require("awful.autofocus")

local sub_screen = screen.count()


-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = { border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                    focus = awful.client.focus.filter,
                    raise = true,
                    keys = clientkeys,
                    buttons = clientbuttons,
                    screen = awful.screen.preferred,
                    placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
   },

   -- Floating clients.
   { rule_any = {
        instance = {
           "DTA",  -- Firefox addon DownThemAll.
           "copyq",  -- Includes session name in class.
        },
        class = {
           "Arandr",
           "Gpick",
           "Kruler",
           "MessageWin",  -- kalarm.
           "Sxiv",
           "Wpa_gui",
           "pinentry",
           "veromix",
           "xtightvncviewer"},

        name = {
           "Event Tester",  -- xev.
        },
        role = {
           "AlarmWindow",  -- Thunderbird's calendar.
           "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
   }, properties = { floating = true }},

   -- titlebars to normal clients and dialogs
   {
      rule_any = {
         type = {
            -- "normal",
            "dialog"
         }
      },
      properties = { titlebars_enabled = false }
   },


   {
      rule = { class = "pinentry" },
      properties = { floating = true }
   },
   {
      rule = { class = "gimp" },
      properties = { floating = true }
   },


   --- Windows and tags ---

   -- Put windows to dev tag
   {
      rule_any = {
         class = {
            "vivaldi", "Vivaldi", "Vivaldi-snapshot",
            "Chromium"
         }
      },
      properties = { tag = "web"}
   },

   -- Put windows to dev tag
   {
      rule_any = { class = {"Emacs"}},
      properties = { tag = "dev"}
   },

   -- Put windows to msg [main screen] tag
   {
      rule_any = {
         class = {
            "Pidgin", "pidgin",
         }
      },
      properties = { screen = sub_screen, tag = "msg"}
   },

   -- Put windows to msg [sub screen] tag
   {
      rule_any = {
         class = {
            "Icedove", "icedove",
            "Mail", "mail",
            "Skype", "skype",
            "Telegram", "telegram",
            "Thunderbird", "thunderbird"
         }
      },
      properties = { screen = sub_screen, tag = "msg"}
   },

   -- Put windows to various tag
   {
      rule_any = { class = {
                      "Transmission", "transmission",
                      "Clementine", "clementine"
                 }},
      properties = { screen = sub_screen, tag = "various"}
   }

   -- Set Firefox to always map on the tag named "2" on screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { screen = 1, tag = "2" } },
}
