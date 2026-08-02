#!/bin/bash
# macOS-style screenshots for Hyprland, built on grim + slurp. Mirrors the macOS
# Screenshot shortcuts (Ctrl = "to clipboard instead of file"). Bound from
# keybinds.conf, e.g.:
#   bind = SHIFT $meta,   4, exec, ~/.config/hypr/scripts/screenshot.sh region file
#   bind = SHIFT $navMod, 4, exec, ~/.config/hypr/scripts/screenshot.sh region clipboard
#
# Usage: screenshot.sh <full|region|window> <file|clipboard>

mode="${1:-region}"
dest="${2:-clipboard}"

case "$mode" in
    full)
        # Whole focused monitor. Use -o (not -g) so HiDPI scaling stays correct.
        out="$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')"
        grim_args=(-o "$out")
        ;;
    region)
        geom="$(slurp)" || exit 1          # Esc / cancel -> abort
        grim_args=(-g "$geom")
        ;;
    window)
        # Feed every window's box on the active workspace into slurp so the
        # selection snaps to whole windows (macOS Cmd+Shift+4 then Space).
        ws="$(hyprctl activeworkspace -j | jq '.id')"
        geom="$(hyprctl clients -j \
            | jq -r --argjson ws "$ws" '.[]
                | select(.workspace.id == $ws and .hidden == false and .mapped == true)
                | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' \
            | slurp)" || exit 1
        grim_args=(-g "$geom")
        ;;
    *)
        echo "usage: $0 <full|region|window> <file|clipboard>" >&2
        exit 1
        ;;
esac

if [[ "$dest" == clipboard ]]; then
    grim "${grim_args[@]}" - | wl-copy
    notify-send "Screenshot" "Copied to clipboard" 2>/dev/null
else
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
    grim "${grim_args[@]}" "$file"
    notify-send "Screenshot" "Saved to $(basename "$file")" 2>/dev/null
fi
