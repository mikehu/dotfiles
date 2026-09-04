---
name: follow-up
description: Capture deferred work as a tracked follow-up, or resume a previously deferred one by topic. Use when you (or the user) decide some discovered work should be offloaded to a later session ("flag this", "defer", "follow up on X"), or when the user wants to pick up a follow-up by search term.
---

Capture deferred work as a durable, searchable note — or resume one later — so follow-ups don't get lost between sessions.

## Where follow-ups live

Follow-ups live **per-repo** at `$FOLLOWUPS = <repo-root>/.agents/artifacts/follow-ups/`. One `.md` file per follow-up.

`<repo-root>` must be the **durable** root — the one shared by every worktree of the repo — and is emphatically *not* `git rev-parse --show-toplevel`. Worktrees are transient by policy (deleted after merge) and `.agents/` is typically gitignored, so it can't ride the branch out via a PR either. Anything written into a worktree is lost unconditionally when that worktree is pruned.

Do not resolve this by hand. Run the shared resolver:

```sh
FOLLOWUPS=$(~/.agents/skills/follow-up/scripts/follow-ups-dir.sh) || exit 1
```

It resolves the root via `--git-common-dir`, which is shared across every worktree of a repo, so you get the same directory whether you're in the main checkout, in `.claude/worktrees/<branch>/`, or in a worktree sibling of a `.bare` clone. It falls back to the current working tree only where no shared root exists (submodules, sibling bare clones), and exits non-zero with a message when there's no usable location at all.

That script is the **single source of truth** — the `warmup` skill calls it too. If the resolution logic ever needs to change, change it there and nowhere else; a second copy is how capture-writes-here / list-reads-there loss starts.

Two rules that matter more than they look:

- **Run the resolver in every lane.** Capture writing to the main checkout while Resume/List/Clean read the worktree is worse than the original bug — it hides the loss in both directions.
- **Never substitute `--show-toplevel`** as a convenience, even when it looks equivalent. It is equivalent right up until the session that isn't, and the failure is silent.

## Pick the intent

First check for an **explicit leading keyword** in `$ARGUMENTS` — these force a lane, no inference:

- `defer …` (or `add`, `capture`) → **Capture**, with the rest of the args as the subject.
- `resume …` (or `find`, `on`) → **Resume**, with the rest of the args as the search topic.
- `list` (or `ls`, `status`) → **List**.
- `clean` (or `prune`, `cleanup`, `tidy`) → **Clean**.

If no keyword is present, **infer** from the args and recent conversation:

- **Capture** — the user is flagging work to defer ("follow up on this", "flag this"), or you've just identified out-of-scope work worth offloading.
- **Resume** — the user gives a topic/search term to pick up prior work.
- **List** — no arguments, or the user asks what's outstanding.

When inference is genuinely ambiguous (e.g. a bare topic that could mean "start a new follow-up on X" or "find the existing one on X"), search first (Resume). If nothing matches, offer to Capture. Explicit keywords skip this — honor them exactly.

## Capture

1. **Determine the content** from the conversation and any `$ARGUMENTS`. A good follow-up captures *why it was deferred* and *what the next session needs to know* — not just a one-line TODO. If the scope is unclear, ask one clarifying question before writing.
2. **Resolve `$FOLLOWUPS`** (see *Where follow-ups live*) and `mkdir -p` it. Then check where you landed:
   - If `$REPO` differs from `git rev-parse --show-toplevel`, you're in a worktree and the write was redirected to the durable root. Note that in one line when reporting, so the redirect is visible rather than surprising.
   - If they're the *same* but you're in a linked worktree (`git rev-parse --git-dir` differs from `--git-common-dir`), the fallback fired and durability could not be established. Say so plainly — this follow-up will die with the worktree — and offer to write it somewhere durable instead.
3. **Choose a slug**: short kebab-case, descriptive (e.g. `retry-backoff-jitter.md`). If a file with that slug already exists and is `status: open`, append to it rather than creating a near-duplicate.
4. **Write the file** with this frontmatter:
   ```
   ---
   title: "Human-readable title"
   status: open              # open | done
   created: "YYYY-MM-DD"     # use the current date
   completed: ""
   tags: [search, terms, aliases]   # words the user might search by later
   branch: "<git branch at capture time>"
   worktree: ""              # capture-time --show-toplevel, only if != $REPO
   ---

   ## Context
   Why this was deferred / what we determined together. Enough that a
   fresh session with zero prior context understands the situation.

   ## Scope
   What actually needs to be done.

   ## Pointers
   - `path/to/file.ext:line` references
   - relevant links, PRs, prior decisions
   ```
5. **Report** the title and path, concisely.

Guidelines:
- One follow-up per file. If a discussion spawns three unrelated deferrals, that's three files.
- Put every plausible search term in `tags` — the Resume lane matches against these.
- Capture pointers (`file:line`) generously; they're the cheapest way to re-orient a future session.
- `worktree` is a breadcrumb, not a location: it records where the work was happening, and a later session should expect that path to be gone.

## Resume

1. Resolve `$FOLLOWUPS` (see *Where follow-ups live*). If it doesn't exist or is empty, tell the user there are no follow-ups and stop.
2. **Search** open follow-ups against the topic in `$ARGUMENTS` — match on `title`, `tags`, filename, and body. Prefer `status: open`; only surface `done` ones if nothing open matches (and say so).
3. **Resolve matches**:
   - No match → tell the user plainly there's no follow-up for that topic; offer to Capture one.
   - One match → read it fully and load its context into the session. Summarize the Context/Scope/Pointers, then confirm this is the one to pick up.
   - Multiple matches → list titles + one-line summaries, ask which.
4. **Grill before building.** Once a follow-up is selected and confirmed, do **not** jump into implementation. A follow-up written in a prior session is exactly where stale assumptions hide, so hand off to the `grill-me` skill to iron out ambiguity first. `grill-me` is user-triggered (it can't be auto-invoked), so tell the user to run `/grill-me` to stress-test this follow-up's scope before you build — and don't start coding until that grilling has reached a shared understanding.
5. When the user finishes the resumed work (or explicitly says it's handled), **mark it done**: set `status: done` and `completed: "YYYY-MM-DD"` in that file's frontmatter, in place. Don't delete it.

If a follow-up records a `worktree` or `branch` that no longer exists, don't treat that as a problem — it's the normal end state. Re-derive the current locations from the `Pointers` instead, and flag any pointer that no longer resolves.

## List

1. Resolve `$FOLLOWUPS`. If missing/empty, say there are no follow-ups and stop.
2. Read the frontmatter of each `.md`. Show **open** ones grouped first, as `title — created — tags`. Mention the count of `done` ones without listing them unless asked.
3. Keep it scannable; this is a status glance, not a report.

## Clean

Prune completed follow-ups so the folder stays manageable. Deletion is destructive, so this lane is **only** entered on an explicit `clean` request (or when the user asks to prune/tidy) — never as a side effect of the other lanes.

1. Resolve `$FOLLOWUPS`. If missing/empty, say there's nothing to clean and stop.
2. Collect every `.md` with `status: done`. If none, tell the user the folder is already clean and stop.
3. List the done ones (`title — completed date`) and ask for confirmation before deleting. If the user scoped it ("clean up the retry ones", "anything done before June"), filter to that subset and confirm that subset.
4. On confirmation, delete the confirmed files (`rm`). Report how many were removed and how many open follow-ups remain.

Only ever delete `status: done` items. Never prune an `open` follow-up — if the user wants one gone that isn't done, point out it's still open and ask them to confirm explicitly.

$ARGUMENTS
