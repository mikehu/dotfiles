#!/bin/bash
# Translate macOS-style Super+<key> shortcuts into the right Ctrl combo for the
# focused window. GUI apps use Ctrl+<key>; terminals use Ctrl+Shift+<key> (so
# Super+C copies instead of sending SIGINT). Bound from hyprland.lua, e.g.:
#   hl.bind("SUPER + C", hl.dsp.exec_cmd("~/.config/hypr/scripts/mac-keys.sh copy"))
#
# Usage: mac-keys.sh <copy|paste|cut|select-all|new-tab|close-tab|line-start|line-end>

case "$1" in
    copy)       key=C ;;
    paste)      key=V ;;
    cut)        key=X ;;
    select-all) key=A ;;
    new-tab)    key=T ;;
    close-tab)  key=W ;;
    # macOS Cmd+Left/Right are line Home/End. These are bare keys rather than
    # Ctrl combos, and behave identically in terminals and GUI apps, so they
    # skip the terminal/GUI split below.
    line-start) key=Home; bare=1 ;;
    line-end)   key=End;  bare=1 ;;
    *) echo "usage: $0 <copy|paste|cut|select-all|new-tab|close-tab|line-start|line-end>" >&2; exit 1 ;;
esac

# Window classes that are terminals (need the Ctrl+Shift variant).
TERMINAL_CLASSES='^(com\.mitchellh\.ghostty|kitty|kitty-float|Alacritty|foot|footclient|org\.wezfurlong\.wezterm|xterm.*|.*[Tt]erminal)$'

class=$(hyprctl activewindow -j | jq -r '.class // empty')

# Since 0.55 hyprctl dispatch takes Lua, not the old "MOD, key, window" string.
# 'mods' is required by send_shortcut, but an empty string is valid.
if [[ -n "$bare" ]]; then
    mods=''
elif [[ "$class" =~ $TERMINAL_CLASSES ]]; then
    mods='CTRL SHIFT'
else
    mods='CTRL'
fi

hyprctl dispatch "hl.dsp.send_shortcut({ mods = '$mods', key = '$key', window = 'activewindow' })"
