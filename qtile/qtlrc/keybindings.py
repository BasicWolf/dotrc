from libqtile.config import Key, EzKey
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal


terminal = guess_terminal()
file_manager = 'thunar'

KEYS = [
    # Launchers
    EzKey('M-<Return>', lazy.spawn(terminal), desc="Launch terminal"),
    EzKey('M-<BackSpace>', lazy.spawn(file_manager)),

    # Switch between windows
    Key(["mod4"], "h", lazy.layout.left(), desc="Move focus to left"),
    Key(["mod4"], "l", lazy.layout.right(), desc="Move focus to right"),
    Key(["mod4"], "j", lazy.layout.down(), desc="Move focus down"),
    Key(["mod4"], "k", lazy.layout.up(), desc="Move focus up"),
    EzKey('M-<Tab>', lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        ["mod4", "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        ["mod4", "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key(["mod4", "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key(["mod4", "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key(["mod4", "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        ["mod4", "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key(["mod4", "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key(["mod4", "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key(["mod4"], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        ["mod4", "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),

    # Toggle between different layouts as defined below
    EzKey('M-<space>', lazy.next_layout(), desc="Toggle between layouts"),
    EzKey('M-C-c', lazy.window.kill(), desc="Kill focused window"),
    EzKey('M-C-r', lazy.restart(), desc="Restart Qtile"),
    Key(["mod4"], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
]
