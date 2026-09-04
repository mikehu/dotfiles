---
name: warmup
description: Prepare for this session by understanding this project's conventions — reads CLAUDE.md, .claude/rules/, recent git history, and any open follow-ups left by prior sessions.
disable-model-invocation: true
---

Prepare for this session by understanding this project's conventions.

Do these in parallel:
1. **Read root CLAUDE.md** if present — this contains project context and architecture overview
2. **Read `.claude/rules/`** — glob for `*.md` in `.claude/rules/` and read them. These are the enforced conventions, auto-loaded by path but reading them now gives you the full picture upfront.
3. **Recent context** — `git log --oneline -10`
4. **Open follow-ups** — deferred work from prior sessions. This is the half of the handoff that otherwise depends on someone *remembering* to go look:
   ```sh
   dir=$(~/.agents/skills/follow-up/scripts/follow-ups-dir.sh 2>/dev/null) \
     && grep -l '^status: open' "$dir"/*.md 2>/dev/null
   ```
   Read the frontmatter (`title`, `created`, `tags`) of each open one — titles and dates only, don't load full bodies. If the command fails or matches nothing, skip it **silently**: say nothing rather than reporting an empty result.

Summarize briefly:
- What this project does
- Key conventions from the rules files
- Recent work from git log
- **Open follow-ups**, if any — `title — created` per line, newest first, and note that `/follow-up resume <topic>` loads one with its full context. Flag any created more than a month ago as possibly stale.

Surfacing a follow-up is not permission to start it. Report it as context and stop there; picking one up is the user's call, and the `follow-up` skill's Resume lane deliberately routes through grilling first.
