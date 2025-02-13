#!/bin/sh
kitty +runpy 'from kitty.fast_data_types import cocoa_set_app_icon; import sys; cocoa_set_app_icon(*sys.argv[1:]); print("OK")' ~/.config/kitty/kitty.app.png
rm /var/folders/*/*/*/com.apple.dock.iconcache; killall Dock
