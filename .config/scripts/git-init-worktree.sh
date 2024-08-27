#!/usr/bin/env bash
set -e

# Examples of call:
# init-worktree
#
# => runs `git worktree add main`
#
# init-worktree branch-name
# => runs `git worktree add branch-name`

default_branch="main"
branch=${1:-$default_branch}

# Check if we're inside a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Error: Not inside a Git worktree."
  exit 1
fi

# Check if the worktree already exists
if git worktree list | grep -q " $branch "; then
  echo "Error: Worktree for branch '$branch' already exists."
  exit 1
fi

# Add the new worktree
git worktree add "$branch"

# Confirm the worktree was added
if [ $? -eq 0 ]; then
  echo "Worktree for branch '$branch' has been successfully created."
fi
