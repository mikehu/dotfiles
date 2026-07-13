#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  run-pi-review.sh [scope] [--note "text"] [--base <ref>] [--report <path>]

Scopes:
  auto     Auto-detect: staged -> working -> branch -> head
  staged   Review staged changes
  working  Review unstaged working tree changes
  branch   Review current branch diff against upstream/default base
  head     Review the last commit

Examples:
  run-pi-review.sh
  run-pi-review.sh staged
  run-pi-review.sh branch --base origin/main
  run-pi-review.sh auto --note "focus on layer boundaries"
EOF
}

err() {
  echo "code-review: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || err "required command not found: $1"
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"

scope="auto"
if [[ $# -gt 0 && "$1" != --* ]]; then
  scope="$1"
  shift
fi

base_ref=""
report_path=""
note_parts=()

if [[ "$scope" == "branch" && $# -gt 0 && "$1" != --* ]]; then
  base_ref="$1"
  shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --note)
      [[ $# -ge 2 ]] || err "--note requires a value"
      note_parts+=("$2")
      shift 2
      ;;
    --base)
      [[ $# -ge 2 ]] || err "--base requires a value"
      base_ref="$2"
      shift 2
      ;;
    --report)
      [[ $# -ge 2 ]] || err "--report requires a value"
      report_path="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      note_parts+=("$1")
      shift
      ;;
  esac
done

note="${note_parts[*]:-}"

require_cmd git
require_cmd pi

if ! git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  err "not inside a git repository"
fi

cd "$git_root"
repo_name="$(basename "$git_root")"
current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
head_sha="$(git rev-parse --short HEAD 2>/dev/null || true)"
head_full_sha="$(git rev-parse HEAD 2>/dev/null || true)"

auto_base_ref() {
  local candidate
  candidate="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"
  if [[ -n "$candidate" ]]; then
    echo "$candidate"
    return 0
  fi

  for candidate in origin/main main origin/master master; do
    if git rev-parse --verify "$candidate" >/dev/null 2>&1; then
      echo "$candidate"
      return 0
    fi
  done

  return 1
}

has_staged_changes() {
  ! git diff --cached --quiet --exit-code
}

has_working_changes() {
  ! git diff --quiet --exit-code
}

branch_has_changes() {
  local base="$1"
  local merge_base
  merge_base="$(git merge-base HEAD "$base" 2>/dev/null || true)"
  [[ -n "$merge_base" && "$merge_base" != "$head_full_sha" ]]
}

resolve_scope() {
  local requested="$1"
  case "$requested" in
    auto)
      if has_staged_changes; then
        echo staged
      elif has_working_changes; then
        echo working
      else
        local auto_base
        auto_base="$(auto_base_ref || true)"
        if [[ -n "$auto_base" ]] && branch_has_changes "$auto_base"; then
          echo branch
        else
          echo head
        fi
      fi
      ;;
    staged|working|branch|head)
      echo "$requested"
      ;;
    *)
      err "unknown scope: $requested"
      ;;
  esac
}

resolved_scope="$(resolve_scope "$scope")"

artifact_dir="$git_root/.agents/artifacts/code-review"
mkdir -p "$artifact_dir"
timestamp="$(date +%Y%m%d-%H%M%S)"
prompt_file="$artifact_dir/review-input-$timestamp.md"
latest_prompt="$artifact_dir/review-input-latest.md"

if [[ -n "$report_path" ]]; then
  mkdir -p "$(dirname "$report_path")"
  report_file="$report_path"
else
  report_file="$artifact_dir/review-$timestamp.md"
fi
latest_report="$artifact_dir/review-latest.md"

policy_source="$HOME/.cmdr/agents/review.md"
fallback_policy="$skill_dir/policy.md"
policy_tmp="$(mktemp)"
trap 'rm -f "$policy_tmp"' EXIT

extract_policy() {
  local source_file="$1"
  if [[ ! -f "$source_file" ]]; then
    return 1
  fi

  if [[ "$(head -n 1 "$source_file" 2>/dev/null || true)" == "---" ]]; then
    awk '
      BEGIN { in_header = 1; seen_start = 0 }
      NR == 1 && $0 == "---" { seen_start = 1; next }
      in_header && $0 == "---" { in_header = 0; next }
      !in_header { print }
    ' "$source_file"
  else
    cat "$source_file"
  fi
}

if ! extract_policy "$policy_source" > "$policy_tmp" || [[ ! -s "$policy_tmp" ]]; then
  cp "$fallback_policy" "$policy_tmp"
  policy_source="$fallback_policy"
fi

system_prompt="$(cat "$policy_tmp")"

base_label=""
merge_base=""
merge_base_short=""
diff_text=""
files_text=""
commit_lines=""

case "$resolved_scope" in
  staged)
    diff_text="$(git diff --cached --no-ext-diff --unified=3)"
    files_text="$(git diff --cached --name-only --diff-filter=ACMRTUXB)"
    ;;
  working)
    diff_text="$(git diff --no-ext-diff --unified=3)"
    files_text="$(git diff --name-only --diff-filter=ACMRTUXB)"
    ;;
  branch)
    if [[ -z "$base_ref" ]]; then
      base_ref="$(auto_base_ref || true)"
    fi
    [[ -n "$base_ref" ]] || err "could not determine a base ref for branch review; pass --base <ref>"
    merge_base="$(git merge-base HEAD "$base_ref" 2>/dev/null || true)"
    [[ -n "$merge_base" ]] || err "could not compute merge-base with $base_ref"
    merge_base_short="$(git rev-parse --short "$merge_base")"
    base_label="$base_ref"
    diff_text="$(git diff "$merge_base"...HEAD --no-ext-diff --unified=3)"
    files_text="$(git diff "$merge_base"...HEAD --name-only --diff-filter=ACMRTUXB)"
    commit_lines="$(git log --format='- `%h` %s — %an' "$merge_base"..HEAD)"
    ;;
  head)
    [[ -n "$head_full_sha" ]] || err "unable to resolve HEAD"
    diff_text="$(git show --no-ext-diff --unified=3 --format= "$head_full_sha")"
    files_text="$(git show --name-only --format= "$head_full_sha")"
    ;;
esac

if [[ -z "$diff_text" ]]; then
  err "no diff content found for scope: $resolved_scope"
fi

if [[ -z "$files_text" ]]; then
  files_block='- (no changed files detected)'
else
  files_block="$(printf '%s\n' "$files_text" | sed 's/^/- `/; s/$/`/')"
fi

head_author="$(git show -s --format='%an' HEAD 2>/dev/null || true)"
head_date="$(git show -s --format='%aI' HEAD 2>/dev/null || true)"
head_subject="$(git show -s --format='%s' HEAD 2>/dev/null || true)"

{
  cat <<EOF
You are reviewing recent changes for **codebase health**. The system prompt defines the review philosophy and strictness. Your job here is to review the supplied change set using the materials below and return structured findings.

Do not review primarily for functional correctness, security, or feature completeness unless a problem materially affects codebase health, maintainability, or architectural integrity.

## Review Request
- Repository: $repo_name
- Scope: $resolved_scope
- Git root: `$git_root`
- Branch: `$current_branch`
EOF

  if [[ -n "$head_sha" ]]; then
    cat <<EOF
- HEAD: `$head_sha`
EOF
  fi

  if [[ -n "$base_label" ]]; then
    cat <<EOF
- Base ref: `$base_label`
- Merge base: `$merge_base_short`
EOF
  fi

  if [[ "$resolved_scope" == "head" ]]; then
    cat <<EOF
- Commit author: $head_author
- Commit date: $head_date
- Commit message: $head_subject
EOF
  fi

  cat <<EOF

## Changed Files
$files_block
EOF

  if [[ "$resolved_scope" == "branch" && -n "$commit_lines" ]]; then
    cat <<EOF

## Commits in Scope
$commit_lines
EOF
  fi

  if [[ -n "$note" ]]; then
    cat <<EOF

## Reviewer's Note
> $note
EOF
  fi

  cat <<'EOF'

## Review Scope

Review the diff in context. Read the surrounding code in touched files and, when necessary, adjacent modules to understand whether the change belongs in that layer, file, and pattern family.

If `docs/PATTERNS*.md` files exist and are relevant to the touched code, read them and use them as project context.

Focus findings on these areas:

1. **Boundary / Architecture** — whether responsibilities remain in the correct layer and dependency flow stays coherent
2. **Cohesion / API Shape** — whether functions, objects, and module APIs stay understandable and cohesive
3. **Organizational Fit** — whether code belongs in the current file/module and whether new files or abstractions are justified
4. **Consistency / Local Pattern Fit** — whether the change aligns with established patterns in nearby code and project docs
5. **Side Effects / Imperative Shell** — whether side effects stay visible at the edges and pure transformation logic remains separable
6. **DRY / Abstraction Fit** — whether duplication indicates a real missing abstraction rather than harmless repetition

Only report meaningful findings. Do not narrate what the code does or summarize the change. Avoid surfacing unrelated pre-existing issues unless the diff worsens them or should clearly have aligned with nearby code.
EOF

  if [[ -n "$note" ]]; then
    cat <<'EOF'

## Notes to Address
- Address the reviewer's note directly
- If the concern is valid, incorporate it into the finding and plan
- If the concern is not valid given the project's conventions, say so plainly
EOF
  fi

  cat <<'EOF'

## Diff
```diff
EOF
  printf '%s
' "$diff_text"
  cat <<'EOF'
```

## Output Format

For each finding, use:

```markdown
### [N. Category] Finding Title
**Lines:** X–Y (diff), `file/path`
**Severity:** must-fix | should-fix | optional
**Confidence:** high | medium | low
**Issue:** One-sentence description of what's wrong
**Why it matters:** How this degrades the codebase over time
**Plan:**
1. [Step]: what to do and where (file:method/function), not how to write the code
2. [Step]: ...
```

Use N from the six scope areas above.

The plan should be a sequence of steps that a refactoring agent can follow. Each step should point at a **location and intention**. Do not include code snippets or exact implementations.

Skip scope areas with no findings. If the change is clean, say so in one sentence — do not pad with praise or generic observations.
EOF
} > "$prompt_file"

cp "$prompt_file" "$latest_prompt"

pi_args=(-p "Review the attached change set using the required format. Read surrounding code when needed.")
pi_args+=(--append-system-prompt "$system_prompt")

if [[ -n "${PI_REVIEW_MODEL:-}" ]]; then
  pi_args+=(--model "$PI_REVIEW_MODEL")
fi
if [[ -n "${PI_REVIEW_PROVIDER:-}" ]]; then
  pi_args+=(--provider "$PI_REVIEW_PROVIDER")
fi
if [[ -n "${PI_REVIEW_THINKING:-}" ]]; then
  pi_args+=(--thinking "$PI_REVIEW_THINKING")
fi

if ! review_output="$(cat "$prompt_file" | pi "${pi_args[@]}" 2>&1)"; then
  printf '%s
' "$review_output" >&2
  err "pi review failed"
fi

printf '%s
' "$review_output" > "$report_file"
cp "$report_file" "$latest_report"

cat <<EOF
PI_CODE_REVIEW_SCOPE=$resolved_scope
PI_CODE_REVIEW_REPO=$repo_name
PI_CODE_REVIEW_GIT_ROOT=$git_root
PI_CODE_REVIEW_POLICY=$policy_source
PI_CODE_REVIEW_PROMPT=$prompt_file
PI_CODE_REVIEW_REPORT=$report_file
EOF

if [[ -n "$base_label" ]]; then
  echo "PI_CODE_REVIEW_BASE=$base_label"
fi

cat <<'EOF'
PI_CODE_REVIEW_REPORT_BEGIN
EOF
cat "$report_file"
cat <<'EOF'
PI_CODE_REVIEW_REPORT_END
EOF
