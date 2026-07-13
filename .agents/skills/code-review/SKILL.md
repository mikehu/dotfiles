---
name: code-review
description: Run a second-opinion code review with pi headless mode on recent git changes, save the review as markdown, then verify and adjudicate the findings before acting on them.
---

Use this skill when you want an opinionated second-opinion review of code changes.

This skill is designed for a simple Claude ↔ Pi handoff:
- Claude coordinates the workflow
- `pi -p` performs the independent review
- markdown artifacts carry the handoff state

## Default Workflow

1. Run `./scripts/run-pi-review.sh` from anywhere inside the target git repo.
2. Read the generated markdown review report.
3. Verify each finding against the actual code before acting.
4. Summarize findings as:
   - accepted
   - rejected
   - unsure
5. Only then make fixes if the user asked for them.

Do **not** blindly apply Pi's findings. Treat the report as a second opinion, not ground truth.

## Scope Selection

If the user does not specify a scope, the script defaults to `auto`, which chooses:
1. `staged` if there are staged changes
2. `working` if there are unstaged changes
3. `branch` if the current branch is ahead of its upstream/default base
4. `head` otherwise

Supported scopes:
- `auto`
- `staged`
- `working`
- `branch`
- `head`

## Common Commands

```bash
# Auto-detect the best review scope
./scripts/run-pi-review.sh

# Review staged changes
./scripts/run-pi-review.sh staged

# Review unstaged working tree changes
./scripts/run-pi-review.sh working

# Review branch diff against upstream/default base
./scripts/run-pi-review.sh branch

# Review the last commit
./scripts/run-pi-review.sh head

# Add a focus note for Pi
./scripts/run-pi-review.sh auto --note "pay extra attention to layer boundaries and file sprawl"
```

## Artifacts

The script writes artifacts under the current repo at:

```text
.agents/artifacts/code-review/
```

Important files:
- `review-latest.md` — latest Pi review report
- `review-input-latest.md` — latest prompt payload sent to Pi

The script also prints the artifact paths and the full report to stdout so you can read it immediately.

## Policy Source

The script prefers the review policy from:

```text
~/.cmdr/agents/review.md
```

It strips the frontmatter and passes the body to Pi as the system prompt.

If that file does not exist, it falls back to the bundled `policy.md` in this skill.

## How to Use the Results

After the script runs:
1. Read `review-latest.md`
2. Inspect the referenced files / code regions
3. Decide which findings are valid
4. Explain disagreements plainly when rejecting findings
5. If asked to make changes, use the accepted findings as your fix plan

Prefer a short adjudication summary before editing code.

$ARGUMENTS
