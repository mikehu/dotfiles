# .zprofile

# Check if the OS is Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # tty1 is the Hyprland session start. Keep it silent so the boot splash
    # hands over without a flash of console text; the echo below is guarded
    # for interactive shells only, matching the macOS branch.
    if [[ "$(tty)" == "/dev/tty1" && -e ~/.config/hypr/scripts ]]; then
        sh ~/.config/hypr/scripts/hyprland-startup.sh && exit 0
    fi
    [[ $- == *i* ]] && echo "Running linux"
# Check if the OS is macOS
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ $- == *i* ]]; then
        echo "Running macOS"
        sw_vers
    fi
    # Set PATH, MANPATH, etc., for Homebrew.
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    # Unknown OS
else
    echo "Unknown OS: $OSTYPE"
fi
