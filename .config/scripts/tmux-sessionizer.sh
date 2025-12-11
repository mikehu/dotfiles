#!/bin/sh
set -eu

work_dirs="$HOME/Code $HOME/Code/personal $HOME/Code/neurox $HOME/Code/minicart $HOME/Code/illustrious-industries $HOME/Code/shuttle"

# Parse arguments
command=""
selected=""
list_only=false

while [ $# -gt 0 ]; do
    case $1 in
    -c)
        command="$2"
        shift 2
        ;;
    --list)
        list_only=true
        shift
        ;;
    *)
        selected="$1"
        shift
        ;;
    esac
done

get_zoxide_dirs() {
    zoxide query --list | head -20 | sed 's|^|d:|'
}

get_project_dirs() {
    for work_dir in $work_dirs; do
        if [ -d "$work_dir" ]; then
            fd --type d --max-depth 1 --exclude '.bare' . "$work_dir" | sed 's|/$||' | while read -r dir; do
                # Skip the work_dir itself
                [ "$dir" = "$work_dir" ] && continue

                # Check if this directory has git worktrees
                if [ -d "$dir/.bare" ] && git -C "$dir" worktree list >/dev/null 2>&1; then
                    # List all worktree paths, excluding .bare
                    git -C "$dir" worktree list --porcelain | grep '^worktree ' | cut -d' ' -f2- | grep -v '\.bare$' | sed 's|^|t:|'
                else
                    # Regular directory
                    printf 'd:%s\n' "$dir"
                fi
            done
        fi
    done
}

# If no directory was provided as argument, use fzf to select
if [ -z "$selected" ]; then
    # Collect paths with type markers for different icons
    all_paths=$(
        {
            get_zoxide_dirs | sed 's|/*$||'
            get_project_dirs | sed 's|/*$||'
            printf 'c:%s\n' "$HOME/dotfiles"
        }
    )

    # Deduplicate based on path (keep first occurrence) - simpler approach
    normalized_paths=$(echo "$all_paths" | sort -t: -k2 -u)

    # Add appropriate icons based on type
    list=$(echo "$normalized_paths" | sed \
        -e 's|^d:| |' \
        -e 's|^t:| |' \
        -e 's|^c:| |')

    if [ "$list_only" = true ]; then
        # Strip icons/prefixes for external tools (like Neovim)
        echo "$list" | sed 's/^[^ ]* //'
        exit 0
    else
        # Use fzf with icons for interactive mode
        selected=$(echo "$list" | fzf --height 100% --no-border)
    fi
fi

if [ -z "$selected" ]; then
    exit 0
fi

selected=$(echo "$selected" | sed 's/^[^ ]* //')

# Smart session naming that handles worktrees
if git -C "$selected" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # This is a git worktree, check if it's in a worktree setup
    git_top_level=$(git -C "$selected" rev-parse --show-toplevel)
    parent_dir=$(dirname "$git_top_level")

    # If parent has .bare, this is likely a worktree setup
    if [ -d "$parent_dir/.bare" ]; then
        parent_name=$(basename "$parent_dir")
        worktree_name=$(basename "$selected")
        selected_name="${parent_name}_${worktree_name}"
    else
        selected_name=$(basename "$selected")
    fi
else
    selected_name=$(basename "$selected")
fi

# Clean up the name (replace dots and other problematic chars)
selected_name=$(echo "$selected_name" | tr '. -' '___')

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
