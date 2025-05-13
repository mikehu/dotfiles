#!/bin/sh
set -eu

# Examples of call:
# git init-worktree                    => creates worktree 'main' at path 'main'
# git init-worktree feature            => creates worktree 'feature' at path 'feature'
# git init-worktree feature path       => creates worktree 'feature' at path 'path'
# git init-worktree feature path HEAD  => creates worktree 'feature' at path 'path' from HEAD
# git init-worktree -b feature main    => creates new branch 'feature' from 'main' at path 'feature'

default_branch="main"
create_new=false

# Parse flags (POSIX-compliant flag parsing)
while [ $# -gt 0 ] && [ "$(echo "$1" | cut -c1)" = "-" ]; do
    case "$1" in
        -b) create_new=true; shift ;;
        --) shift; break ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Get parameters with POSIX parameter handling
branch=${1:-$default_branch}
path=${2:-$branch}
base_commit=${3:-HEAD}

# Check if we're inside a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not inside a Git worktree."
    exit 1
fi

# Check if the worktree already exists (using more portable grep)
if git worktree list | grep " ${path%/} " > /dev/null 2>&1; then
    echo "Error: Worktree at path '$path' already exists."
    exit 1
fi

# Add the new worktree
if [ "$create_new" = true ]; then
    git worktree add -b "$branch" "$path" "$base_commit"
else
    git worktree add "$path" "$branch"
fi

# Check status more explicitly for POSIX compliance
status=$?
if [ $status -eq 0 ]; then
    echo "Worktree for branch '$branch' has been successfully created at path '$path'."
else
    exit $status
fi
