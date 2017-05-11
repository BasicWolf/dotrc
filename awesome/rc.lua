--- Bootstrap ---
require("loader")
loadrc("errors")


--- Core Definitions ---
config = {}
config.terminal = "xfce4-terminal"
config.file_manager = "thunar"
config.editor = os.getenv("EDITOR") or "emacs -q"
config.editor_cmd = config.terminal .. " -e " .. config.editor

modkey = "Mod4"

loadrc("appearance")
loadrc("menu")
loadrc("wibar")
loadrc("bindings")
loadrc("rules")
loadrc("signals")

loadrc("autostart")
