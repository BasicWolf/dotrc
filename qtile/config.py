from typing import List  # noqa: F401

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Match, Screen
from libqtile.dgroups import simple_key_binder
from libqtile.lazy import lazy

from qtlrc.keybindings import KEYS

keys = KEYS

groups = [
    Group('Web'),
    Group('Dev'),
    Group('Term'),
    Group('Comm'),
    Group('Else')
]

layouts = [
    layout.Columns(border_focus_stack='#d75f5f'),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    layout.Zoomy(),
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

_top_bar = bar.Bar(
    [
        widget.GroupBox(),
        widget.Prompt(),
        widget.TaskList(),
        widget.Chord(
            chords_colors={
                'launch': ("#ff0000", "#ffffff"),
            },
            name_transform=lambda name: name.upper(),
        ),
        widget.Volume(),
        widget.CPUGraph(width=60, samples=60),
        widget.BatteryIcon(),
        widget.Systray(),
        widget.Clock(format='%a %d/%m | %H:%M'),
        widget.QuickExit(default_text='[ Exit ]', countdown_format='Exit: {}'),
        widget.CurrentLayoutIcon(),
        widget.Notify()
    ],
    size=24,
)

screens = [Screen(top=_top_bar)]

# Drag floating layouts.
mouse = [
    Drag(['mod4'], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag(['mod4'], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click(['mod4'], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = simple_key_binder('mod4', '123qw')
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
