#!/bin/bash
# Translate macOS-style Super+<key> shortcuts into the right Ctrl combo for the
# focused window. GUI apps use Ctrl+<key>; terminals use Ctrl+Shift+<key> (so
# Super+C copies instead of sending SIGINT). Bound from keybinds.conf, e.g.:
#   bind = SUPER, C, exec, ~/.config/hypr/scripts/mac-clipboard.sh copy
#
# Usage: mac-clipboard.sh <copy|paste|cut|select-all>

case "$1" in
    copy)       key=C ;;
    paste)      key=V ;;
    cut)        key=X ;;
    select-all) key=A ;;
    *) echo "usage: $0 <copy|paste|cut|select-all>" >&2; exit 1 ;;
esac

# Window classes that are terminals (need the Ctrl+Shift variant).
TERMINAL_CLASSES='^(com\.mitchellh\.ghostty|kitty|kitty-float|Alacritty|foot|footclient|org\.wezfurlong\.wezterm|xterm.*|.*[Tt]erminal)$'

class=$(hyprctl activewindow -j | jq -r '.class // empty')

if [[ "$class" =~ $TERMINAL_CLASSES ]]; then
    hyprctl dispatch sendshortcut "CTRL SHIFT, $key, activewindow"
else
    hyprctl dispatch sendshortcut "CTRL, $key, activewindow"
fi
