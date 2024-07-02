#!/bin/bash

WALLPAPER_DIR=~/Pictures

set_wallpaper() {
    local filepath=$1
    swww img "$filepath" --transition-type wipe --transition-step 30 --transition-fps 120
}

adopt_colors() {
    local filepath=$1
    sleep 1 && wallust -q -s "$filepath" && makoctl reload
}

# Check if a filepath is provided
if [ -n "$1" ]; then
    set_wallpaper "$1"
    adopt_colors "$1"
else
    # Choose a random .jpg file from the ~/Pictures directory using rg and fzf
    random_file=$(rg --files --glob "*.jpg" "$WALLPAPER_DIR" | shuf -n 1)

    if [ -n "$random_file" ]; then
        set_wallpaper "$random_file"
        adopt_colors "$random_file"
    else
        echo "No .jpg files found in $WALLPAPER_DIR directory."
        exit 1
    fi
fi

