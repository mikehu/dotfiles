#!/bin/sh
set -eu

# Examples of call:
# git-clone-bare-for-worktrees git@github.com:name/repo.git
# => Clones to a /repo directory
#
# git-clone-bare-for-worktrees git@github.com:name/repo.git my-repo
# => Clones to a /my-repo directory

url=$1
basename=$(basename "$url")
name=${2:-$(echo "$basename" | sed 's/\.git$//')}

echo "Setting up worktree-ready repository in directory: $name"
mkdir "$name"
cd "$name"

# Moves all the administrative git files (a.k.a $GIT_DIR) under .bare directory.
#
# Plan is to create worktrees as siblings of this directory.
# Example targeted structure:
# .bare
# main
# new-awesome-feature
# hotfix-bug-12
# ...
echo "Cloning repository into $name/.bare (bare repository for worktree management)..."
git clone --bare "$url" .bare
echo "gitdir: ./.bare" > .git

# Explicitly sets the remote origin fetch so we can fetch remote branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

# Gets all branches from origin
git fetch origin

echo "Repository successfully set up in $name. You can now create worktrees with 'git worktree add'."
