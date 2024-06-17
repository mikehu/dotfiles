# Set PATH, MANPATH, etc., for Homebrew.
if command -v brew 1>/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
