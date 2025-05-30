#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

# Check for required tools and environment variables
check_requirements() {
    local missing_requirements=0

    # Check if SYNC_VAULT is set
    if [ -z "$SYNC_VAULT" ]; then
        echo "Error: SYNC_VAULT environment variable is not set"
        echo "Please set it with: export SYNC_VAULT='your-1password-account'"
        missing_requirements=1
    fi

    # Check if 'op' CLI is available
    if ! command -v op >/dev/null 2>&1; then
        echo "Error: '1Password CLI (op)' is not installed"
        echo "Install it from: https://1password.com/downloads/command-line/"
        missing_requirements=1
    fi

    # Check if 'pass' is available
    if ! command -v pass >/dev/null 2>&1; then
        echo "Error: 'pass' is not installed"
        echo "Install it using your package manager (e.g., brew install pass)"
        missing_requirements=1
    fi

    # Check if pass is initialized with a GPG key
    if [ ! -d "${PASSWORD_STORE_DIR:-$HOME/.password-store}" ]; then
        echo "Error: password store is not initialized"
        echo "Initialize it with: pass init <your-gpg-key-id>"
        missing_requirements=1
    fi

    [ $missing_requirements -eq 1 ] && exit 1
}

sync_credentials=(
    "OpenAI API Key"
    "Claude API Key"
    "xAI API Key"
    "Gemini API Key"
    "DeepSeek API Key"
    "Groq API Key"
    "Perplexity API Key"
)

sync_tokens=(
    "GitHub Personal Access Token"
)

# Perform initial requirement checks
check_requirements

echo "Starting password synchronization from 1Password to system password store..."

count=0
failures=0

# Process credential targets
for target in "${sync_credentials[@]}"; do
  echo "Processing $target..."
  # Retrieve credential field from 1Password CLI
  password=$(op item get "$target" --vault "Private" --account "$SYNC_VAULT" --fields credential --reveal)

  if [ -z "$password" ]; then
      echo "Error: Failed to retrieve credential for '$target' from 1Password."
      echo "Possible issues:"
      echo "  - Item doesn't exist in the vault"
      echo "  - You're not authenticated (run 'op signin')"
      echo "  - Incorrect vault name or account"
      ((failures++))
      continue
  fi

  echo "Updating pass entry for $target..."
  if echo "$password" | pass insert -fe "API/$target" > /dev/null 2>&1; then
      echo "Successfully updated pass entry for '$target'"
      ((count++))
  else
      echo "Error: Failed to update pass entry for '$target'."
      echo "Possible issues:"
      echo "  - GPG key problems"
      echo "  - Permission issues with password store"
      ((failures++))
  fi
done

# Process token targets
for target in "${sync_tokens[@]}"; do
  echo "Processing $target..."
  # Retrieve token field from 1Password CLI
  password=$(op item get "$target" --vault "Private" --account "$SYNC_VAULT" --fields token --reveal)

  if [ -z "$password" ]; then
      echo "Error: Failed to retrieve token for '$target' from 1Password."
      echo "Possible issues:"
      echo "  - Item doesn't exist in the vault"
      echo "  - You're not authenticated (run 'op signin')"
      echo "  - Incorrect vault name or account"
      ((failures++))
      continue
  fi

  echo "Updating pass entry for $target..."
  if echo "$password" | pass insert -fe "Tokens/$target" > /dev/null 2>&1; then
      echo "Successfully updated pass entry for '$target'"
      ((count++))
  else
      echo "Error: Failed to update pass entry for '$target'."
      echo "Possible issues:"
      echo "  - GPG key problems"
      echo "  - Permission issues with password store"
      ((failures++))
  fi
done

echo "Password synchronization complete: $count successful, $failures failed."

# Exit with failure if any sync failed
[ $failures -gt 0 ] && exit 1
exit 0
