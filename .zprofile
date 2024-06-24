# .zprofile

# Check if the OS is Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	echo "Running linux"
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
