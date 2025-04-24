#!/usr/bin/env bash

sync_targets=(
  "OpenAI API Key"
  "Claude API Key"
  "DeepSeek API Key"
  "Gemini API Key"
  "Groq API Key"
)

echo "Starting password synchronization from 1Password to system password store..."

count=0
failures=0

for target in "${sync_targets[@]}"; do
    echo "Processing $target..."

    # Retrieve password from 1Password CLI
    password=$(op item get "$target" --vault "Private" --account "MXFJNCXIPZC2ZNSNS35K6CT334" --fields credential --reveal 2>/dev/null)

    if [ -z "$password" ]; then
        echo "Error: Failed to retrieve password for '$target' from 1Password."
        ((failures++))
        continue
    fi

    # Insert/update the password in pass
    # pass automatically encrypts the password using GPG
    echo "Updating pass entry for $target..."
    if echo "$password" | pass insert -fe "API/$target" > /dev/null 2>&1; then
        echo "Successfully updated pass entry for '$target'"
        ((count++))
    else
        echo "Error: Failed to update pass entry for '$target'."
        ((failures++))
    fi
done

echo "Password synchronization complete: $count successful, $failures failed."
