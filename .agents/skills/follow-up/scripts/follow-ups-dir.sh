#!/bin/sh
# Print the durable follow-ups directory for the current repo.
#
# Canonical implementation shared by the `follow-up` and `warmup` skills — if you
# change how the root is resolved, change it here and nowhere else. A second copy
# is how capture-writes-here / list-reads-there data loss starts.
#
# The root must be shared by every worktree of the repo. `--show-toplevel` is NOT
# that: worktrees are deleted after merge and .agents/ is usually gitignored, so
# anything stored in one is lost unconditionally when it is pruned.
set -eu

common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
  echo "not inside a git repository" >&2; exit 1
}
root=$(dirname "$common")

# Trust dirname only if that directory still resolves to this same repo. Rejects
# submodules (common dir lives under .git/modules/...) and sibling bare clones,
# where dirname would otherwise escape into an unrelated parent directory.
if [ "$(git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" != "$common" ]; then
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "no working tree (bare repository)" >&2; exit 1
  }
fi

echo "$root/.agents/artifacts/follow-ups"
