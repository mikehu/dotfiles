#!/bin/bash

gsettings set org.gnome.desktop.interface gtk-theme "rose-pine-gtk"
gsettings set org.gnome.desktop.wm.preferences theme "rose-pine-gtk"

# Deliberately NOT prefer-dark. rose-pine-gtk ships its variants swapped: the
# light slot (dist/gtk.css) holds the dark palette and dist/gtk-dark.css is the
# inverted one, so prefer-dark gives GTK3 apps flipped colors. Upstream says the
# same ("set your style to Light"). Ghostty is unaffected -- window-theme=auto
# derives dark chrome from its own background color.
gsettings set org.gnome.desktop.interface color-scheme "default"

# -dark, not plain WhiteSur: the light variant hardcodes color:#363636 into its
# symbolic SVGs, which is near-invisible on rose-pine's dark sidebars. The dark
# variant uses #dedede.
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
