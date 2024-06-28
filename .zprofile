# .zprofile

# Check if the OS is Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Running linux"
    if [[ "$(tty)" == "/dev/tty1" && -e ~/.config/hypr/scripts ]]; then
        if sh ~/.config/hypr/scripts/hyprland-startup.sh; then
            echo "goodbye, now logging out"
            exit 0
        else
            echo "$? hyprland-startup.sh failed"
            if tty | grep tty1 > /dev/null; then
                echo "refusing autologin to Hyprland on non-tty1"
                exit 0
            else
                echo "not on tty1, skipping hyprland-startup.sh"
            fi
        fi
    fi
# Check if the OS is macOS
elif [[ "$OSTYPE" == "darwin"* ]]; then
	echo "Running macOS"
	sw_vers
	# Set PATH, MANPATH, etc., for Homebrew.
	if [ -f /opt/homebrew/bin/brew ]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	fi
# Unknown OS
else
	echo "Unknown OS: $OSTYPE"
fi
