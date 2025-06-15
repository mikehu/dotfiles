#!/bin/sh
set -eu

work_dirs="$HOME/Code $HOME/Code/personal $HOME/Code/neurox $HOME/Code/illustrious-industries $HOME/Code/shuttle"

# Parse arguments
command=""
selected=""

while [ $# -gt 0 ]; do
    case $1 in
    -c)
        command="$2"
        shift 2
        ;;
    *)
        selected="$1"
        shift
        ;;
    esac
done

# If no directory was provided as argument, use fzf to select
if [ -z "$selected" ]; then
    selected=$(
        {
            fd --type d --max-depth 1 . $work_dirs
            printf '%s\n' "$HOME/dotfiles"
        } | fzf
    )
fi

if [ -z "$selected" ]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=""

if pgrep tmux >/dev/null 2>&1; then
    tmux_running="yes"
fi

if [ -z "${TMUX:-}" ] && [ -z "$tmux_running" ]; then
    if [ -n "$command" ]; then
        tmux new-session -s "$selected_name" -c "$selected" "$command"
    else
        tmux new-session -s "$selected_name" -c "$selected"
    fi
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    if [ -n "$command" ]; then
        tmux new-session -ds "$selected_name" -c "$selected" "$command"
    else
        tmux new-session -ds "$selected_name" -c "$selected"
    fi
else
    if [ -n "$command" ]; then
        tmux send-keys -t "$selected_name" "$command" Enter
    fi
fi

if [ -n "${TMUX:-}" ]; then
    # We're inside tmux, switch client
    tmux switch-client -t "$selected_name"
else
    # We're outside tmux but tmux is running, attach to session
    tmux attach-session -t "$selected_name"
fi
