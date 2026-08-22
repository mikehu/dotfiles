#!/bin/bash
# macOS-style screenshots for Hyprland, built on grim + slurp. Mirrors the macOS
# Screenshot shortcuts (Ctrl = "to clipboard instead of file"). Bound from
# hyprland.lua, e.g.:
#   hl.bind("SUPER + SHIFT + 4",        hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region file"))
#   hl.bind("SUPER + CTRL + SHIFT + 4", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region clipboard"))
#
# Usage: screenshot.sh <full|region|window> <file|clipboard|annotate>
#
# annotate opens the capture in satty for markup; saving there writes to
# ~/Pictures/Screenshots and copies to the clipboard.

mode="${1:-region}"
dest="${2:-clipboard}"

# Selection UI, macOS-style: thin white border, darkened surround, live pixel
# readout in the same font as waybar and walker. slurp has no config file, so
# this lives here and is shared by both call sites below. The selection itself
# stays undimmed because slurp's default selection fill (-s) is transparent --
# -b only tints what falls outside it. The readout font is monospace so the
# digits don't reflow while dragging. Dotted borders aren't possible; slurp
# strokes solid, so -w is the only way to make the edge lighter.
slurp_args=(-w 1 -c '#FFFFFFFF' -b '#00000080' -d -F 'DroidSansM Nerd Font')

case "$mode" in
    full)
        # Whole focused monitor. Use -o (not -g) so HiDPI scaling stays correct.
        out="$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')"
        grim_args=(-o "$out")
        ;;
    region)
        geom="$(slurp "${slurp_args[@]}")" || exit 1   # Esc / cancel -> abort
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
            | slurp "${slurp_args[@]}")" || exit 1
        grim_args=(-g "$geom")
        ;;
    *)
        echo "usage: $0 <full|region|window> <file|clipboard|annotate>" >&2
        exit 1
        ;;
esac

if [[ "$dest" == annotate ]]; then
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    # Output path, copy command and early-exit come from ~/.config/satty/config.toml.
    grim "${grim_args[@]}" - | satty --filename -
elif [[ "$dest" == clipboard ]]; then
    grim "${grim_args[@]}" - | wl-copy
    notify-send "Screenshot" "Copied to clipboard" 2>/dev/null
else
    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
    grim "${grim_args[@]}" "$file"
    notify-send "Screenshot" "Saved to $(basename "$file")" 2>/dev/null
fi
