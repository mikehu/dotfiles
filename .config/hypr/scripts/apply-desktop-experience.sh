#!/bin/bash

WALLPAPER_DIR=$HOME/Pictures
CACHE_DIR=$HOME/.cache

set_wallpaper() {
    local filepath=$1
    # transition the wallpaper
    swww img "$filepath" --transition-type wipe --transition-step 30 --transition-fps 120
}

adopt_colors() {
    local filepath=$1
    local filename=$(basename "$filepath")
    sleep 0.5 && wallust run -q -s "$filepath" && makoctl reload
    notify-send "Applied desktop experience:" "$filename"
}

cache_wallpaper() {
    local filepath=$1
    # we need to cached wallpaper assets for hyprlock
    magick "$filepath" -blur 0x40 "$CACHE_DIR/blurred_wallpaper.png"
    magick "$filepath" -resize 600x600^ -gravity Center -extent 1:1 "$CACHE_DIR/cropped_center_wallpaper.png"
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
        cache_wallpaper "$random_file"
    else
        echo "No .jpg files found in $WALLPAPER_DIR directory."
        exit 1
    fi
fi

