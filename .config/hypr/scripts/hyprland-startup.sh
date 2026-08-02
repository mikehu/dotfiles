#!/bin/bash

cd ~

# Environment now lives in hyprland.lua (hl.env). Only vars that must be set
# before the compositor starts belong here.
export _JAVA_AWT_WM_NONREPARENTING=1

exec start-hyprland > .hyprland.log.txt 2> .hyprland.err.txt

