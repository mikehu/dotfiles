---
name: ask
description: Answer a question by searching the ThoughtQuarry knowledge base first, then supplementing with general knowledge.
argument-hint: "[question]"
---

Answer a question by searching the ThoughtQuarry knowledge base first, then supplementing with general knowledge.

**Question**: $ARGUMENTS

## Instructions

1. **Search the vault** — Glob and grep through `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/ThoughtQuarry/` to find files relevant to the question. Check `concepts/`, `projects/`, `logs/`, and `raw/`. Also check the user's personal folders (Title Case folders like `Minicart/`, `Shuttle/`, etc.) — these contain the user's own notes. Cast a wide net with keywords from the question.

2. **Read relevant files** — Read the top matches in full. Follow any `[[wiki-links]]` to related pages and read those too.

3. **Synthesize an answer** — Answer the question drawing primarily from what's in the vault. Structure your response as:

   **From your knowledge base:**
   The answer grounded in vault contents, citing filenames as `[[page-name]]` links.

   **Beyond your notes:**
   Anything relevant from general knowledge that isn't captured in the vault yet. Keep this short — the vault is the primary source.

   **Sources:** List the vault files you drew from.

4. **Suggest captures** — If your answer included significant general knowledge that would be worth adding to the vault, suggest it: "This might be worth capturing in `concepts/topic-name.md`."

## Important
- If nothing relevant is found in the vault, say so clearly — don't pretend vault knowledge exists.
- Prefer vault content over general knowledge. The whole point is retrieval from YOUR notes.
- Keep answers concise and direct.
