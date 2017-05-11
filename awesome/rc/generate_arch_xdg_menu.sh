#!/bin/bash
xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu | sed 's/16x16/32x32/g' > xdgmenu.lua
