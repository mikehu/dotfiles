#!/bin/bash

CLAUDE_DATA="$HOME/Library/Application Support/Claude"

echo "Checking current Claude data size..."

du -sh "$CLAUDE_DATA" 2>/dev/null

echo ""

echo "Breakdown:"

du -sh "$CLAUDE_DATA/vm_bundles" "$CLAUDE_DATA/local-agent-mode-sessions" "$CLAUDE_DATA/Cache" 2>/dev/null

echo ""

if pgrep -f "Claude.app/Contents/MacOS/Claude" >/dev/null 2>&1; then

    echo "Claude is running. Quitting..."

    osascript -e 'quit app "Claude"'

    sleep 3

fi

echo "Clearing vm_bundles (Cowork sandboxes)..."

rm -rf "$CLAUDE_DATA/vm_bundles"

echo "Clearing local-agent-mode-sessions..."

rm -rf "$CLAUDE_DATA/local-agent-mode-sessions"

echo "Clearing Cache..."

rm -rf "$CLAUDE_DATA/Cache"

echo ""

echo "Done. New size:"

du -sh "$CLAUDE_DATA" 2>/dev/null

echo ""

read -p "Reopen Claude? (y/n) " -n 1 -r

echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    open -a "Claude"
fi
