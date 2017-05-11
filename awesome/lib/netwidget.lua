local wibox = require("wibox")
local vicious = require("vicious")

-- Network usage widget
netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${enp3s0 down_kb}</span> <span color="#7F9F7F">${enp3s0 up_kb}</span>', 3)
