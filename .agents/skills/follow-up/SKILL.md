---
name: follow-up
description: Capture deferred work as a tracked follow-up, or resume a previously deferred one by topic. Use when you (or the user) decide some discovered work should be offloaded to a later session ("flag this", "defer", "follow up on X"), or when the user wants to pick up a follow-up by search term.
---

Capture deferred work as a durable, searchable note — or resume one later — so follow-ups don't get lost between sessions.

Follow-ups live **per-repo** at `<repo-root>/.agents/artifacts/follow-ups/`, where `<repo-root>` is `git rev-parse --show-toplevel` of the current working directory. One `.md` file per follow-up.

## Pick the intent

First check for an **explicit leading keyword** in `$ARGUMENTS` — these force a lane, no inference:

- `defer …` (or `add`, `capture`) → **Capture**, with the rest of the args as the subject.
- `resume …` (or `find`, `on`) → **Resume**, with the rest of the args as the search topic.
- `list` (or `ls`, `status`) → **List**.

If no keyword is present, **infer** from the args and recent conversation:

- **Capture** — the user is flagging work to defer ("follow up on this", "flag this"), or you've just identified out-of-scope work worth offloading.
- **Resume** — the user gives a topic/search term to pick up prior work.
- **List** — no arguments, or the user asks what's outstanding.

When inference is genuinely ambiguous (e.g. a bare topic that could mean "start a new follow-up on X" or "find the existing one on X"), search first (Resume). If nothing matches, offer to Capture. Explicit keywords skip this — honor them exactly.

## Capture

1. **Determine the content** from the conversation and any `$ARGUMENTS`. A good follow-up captures *why it was deferred* and *what the next session needs to know* — not just a one-line TODO. If the scope is unclear, ask one clarifying question before writing.
2. **Compute the path**: `REPO=$(git rev-parse --show-toplevel)`; dir is `$REPO/.agents/artifacts/follow-ups/`. `mkdir -p` it.
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

## Resume

1. Compute the dir (as above). If it doesn't exist or is empty, tell the user there are no follow-ups and stop.
2. **Search** open follow-ups against the topic in `$ARGUMENTS` — match on `title`, `tags`, filename, and body. Prefer `status: open`; only surface `done` ones if nothing open matches (and say so).
3. **Resolve matches**:
   - No match → tell the user plainly there's no follow-up for that topic; offer to Capture one.
   - One match → read it fully and load its context into the session. Summarize the Context/Scope/Pointers, then confirm this is the one to pick up.
   - Multiple matches → list titles + one-line summaries, ask which.
4. **Grill before building.** Once a follow-up is selected and confirmed, do **not** jump into implementation. First iron out ambiguity by following the grill-me protocol at `.agents/skills/grill-me/SKILL.md` — read that file and apply it to *this* follow-up's scope: walk the design tree one decision at a time, recommend an answer for each, look up facts in the codebase rather than asking, and don't start coding until the user confirms shared understanding. (Invoke it as your own step — `grill-me` is user-triggered and can't be auto-called via the Skill tool, so adopt its protocol directly here.) A follow-up written in a prior session is exactly where stale assumptions hide, so this step is load-bearing.
5. When the user finishes the resumed work (or explicitly says it's handled), **mark it done**: set `status: done` and `completed: "YYYY-MM-DD"` in that file's frontmatter, in place. Don't delete it.

## List

1. Compute the dir. If missing/empty, say there are no follow-ups and stop.
2. Read the frontmatter of each `.md`. Show **open** ones grouped first, as `title — created — tags`. Mention the count of `done` ones without listing them unless asked.
3. Keep it scannable; this is a status glance, not a report.

$ARGUMENTS
