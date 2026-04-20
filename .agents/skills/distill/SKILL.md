---
name: distill
description: Process unprocessed raw notes in ThoughtQuarry into refined, interlinked concept pages.
---

Process unprocessed raw notes in ThoughtQuarry into refined, interlinked concept pages.

## Instructions

1. **Find unprocessed notes** — Glob for all `.md` files in `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/ThoughtQuarry/raw/`. Read each file and check for `processed: false` in the frontmatter. If none found, say so and stop.

2. **For each unprocessed note:**
   a. Read the full content
   b. Identify distinct concepts, patterns, or learnings worth their own page
   c. For each concept:
      - Check if a page already exists in `concepts/` (search by name and content to avoid duplicates)
      - If it exists, append new information — never overwrite human edits
      - If it's new, create a page in `concepts/` with this frontmatter:
        ```
        ---
        title: "Concept Name"
        tags: []
        related: []
        source: "raw/original-filename.md"
        created: "YYYY-MM-DD"
        last_reviewed: "YYYY-MM-DD"
        status: draft
        ---
        ```
      - Use `[[wiki-links]]` to connect related concepts to each other
      - If the raw note contains project-specific learnings (architecture, onboarding info, etc.), also create/update pages in `projects/{project-name}/` (lowercase, kebab-case)
   d. Update the raw note: set `processed: true` and add links to the concept pages that were created

3. **Report what you did:**
   - How many raw notes were processed
   - What concept pages were created or updated
   - Any notable connections between concepts that emerged

## Guidelines
- One concept per file. If a raw note contains five ideas, that's five concept pages.
- Name files descriptively in kebab-case (e.g., `coordinator-pattern.md`, `icloud-file-access.md`)
- Prefer linking to existing concepts over creating near-duplicates
- Tag everything with `status: draft` — the user reviews and promotes to `reviewed`
- Keep concept pages concise. Capture the what, why, and how — not filler.

## Vault ownership convention
- **Lowercase folders** (`concepts/`, `projects/`, `raw/`, `logs/`) — LLM-managed. You write here.
- **Title Case folders** (`Minicart/`, `Shuttle/`, etc.) — user's personal notes. Never modify these.
- This distinction helps the user know what they can safely prune vs. what's hand-written.
