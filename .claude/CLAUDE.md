## Reporting Information

- When reporting information to me, be extremely concise and sacrifice grammar for the sake of
  concision.

- When writing something intended for human consumption, (comment, commit message, reply to prompt)
  use as few words as possible. Pick every word meticulously to reduce the volume to a strict
  minimum. Be down to the point. Less is more.

- Avoid superlatives and praise. Stop telling me I am absolutely right. Give me the cold hard truth.

## Coding Principles

1. **Surface confusion early** — If something is ambiguous or has multiple valid interpretations,
   stop and ask before implementing. State assumptions explicitly. Push back if a simpler approach
   exists.

2. **Minimum viable change (breadth, not depth)** — Minimal governs *scope*: no features beyond what
   was asked, no abstractions for single-use code, no speculative flexibility, no defensive
   scaffolding (defensive cloning, helper wrappers, `_`-prefixed pseudo-private methods) unless
   requested. It does NOT mean band-aid fixes. Solve the actual problem — if 200 lines could be 50,
   rewrite it.

3. **Root cause over symptom** — When the request is a symptom of a deeper defect, fix the cause,
   not the surface (boy scout: leave touched code better than you found it). This license covers
   code in the *path of the fix* — it is not a free hand to refactor the whole file. Triage: local
   root-cause fixes, just do them; large or cross-cutting ones (new abstractions, changes affecting
   callers) — surface and confirm first, per #1.

4. **Surgical on taste, not on correctness** — Don't churn adjacent code for style, formatting, or
   preference; match existing style there. Distinguish "this offends my taste" (leave it) from "this
   is wrong / is the root cause" (fix it). Every changed line traces to either the request or the
   root cause behind it.

5. **Verifiable goals** — Before multi-step work, define success criteria and a brief plan. "Fix the
   bug" becomes "reproduce it, write a test, make it pass." Loop independently against concrete
   checks rather than vague intent.

6. **Natural domain scope** — When modeling an input type or domain, don't artificially narrow it.
   Prefer the broader natural type (E164 over US_E164, Path over RelativePath) when the cost is the
   same. This is about scope, not abstraction layers — it does not override #2.

## Coding Style

- Avoid magic numbers and strings by extracting recurring or meaningful values into descriptive
  constants (const) or enums. Keep self-explanatory, one-off values inline to avoid clutter. If a
  value comes from a spec (e.g. HTTP 200 OK), use a constant regardless.

- Reduce code indentation. Avoid Arrow Anti-Pattern. Leverage early return and continue.

- Keep function names short. Less than 30 characters.

- Use enums instead of booleans for function parameters.

- Let the reader of the code breathe. Add empty lines between logical blocks of code.

- Add a small, to the point, comment to explain *what* the block does and *why*. Use examples when
  possible. Propose ASCII drawings to explain complete systems.

- Program to levels of abstraction. Lower-level mechanics (e.g., raw hardware I/O, sector parsing,
  direct socket streams) must be encapsulated in a dedicated driver/abstraction layer. Expose clean,
  high-level APIs to the rest of the application so calling code works with domain concepts, not raw
  implementation details.

- Don't touch blocks of code unrelated to the feature you implement. e.g. Don't add comments to a
  block of code if you did not create it or modify it. As much as possible try to minimize the
  number of changed lines when implementing a feature.

- Strictly adhere to the layered boundary hierarchy: each layer may only communicate with its
  immediate neighbor directly below it. Never "punch holes" through layers (e.g., controllers or UI
  components must never directly call database queries, raw hardware drivers, or low-level network
  clients; always route through the intermediate service/abstraction layer).

## Working from review feedback

When addressing a list of findings from a review step (code review, pi review, audit, lint report,
etc.), don't plow through start-to-finish. Triage first: fix the trivial/local items, but pause and
ask before tackling architecturally significant ones (scope changes, new abstractions,
tool/responsibility shifts, anything that could affect callers). The point of a review is the
conversation, not just the patch.

For **each** proposed fix, before touching anything, give me a one-line **cost synopsis** — the
machinery the fix drags in: roughly how many lines, any new file, abstraction, indirection, or
dependency, which callers move, what tests it needs. One sentence. This is a price tag, not a design
doc.

Then hold the price against the size of the defect. A one-line issue answered with a twenty-line
diff needs a stated reason, and "while I was in there" is not one. Where the cheap fix and the
thorough fix differ materially, name both with their prices and let me choose — don't silently ship
the expensive one.

This is a proportionality check, not a mandate to always take the smallest diff. If the small fix is
a band-aid over the real root cause (#3), say that plainly and quote the honest price instead — an
under-priced fix I have to redo later is worse than an expensive one I agreed to. What I'm guarding
against is unrequested machinery: the abstraction, wrapper, or config surface that arrives attached
to a fix I thought was one line.

## Git Workflow

- **Always rebase before merging** — never create merge commits. When integrating branch work
  (including worktree branches), rebase onto the target branch first, then fast-forward merge. This
  keeps history linear and readable.
- When cleaning up after a worktree, remove the worktree directory and delete the branch.
- **Conventional Commit format** — both commit messages and PR titles use `type(scope): subject`
  (imperative, lowercase subject, no trailing period). Type is required — one of `feat`, `fix`,
  `chore`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`; scope is optional. A PR title
  describes the whole PR, not just the last commit.

## Logging

When drafting log messages, ensure the message string itself is useful and identifiable without
relying on metadata. You should be able to scan through log messages and understand what's happening
at a glance.

- **Message**: Self-descriptive, scannable, identifies what happened
- **Metadata**: Verbose context for when you need to dig deeper

Format: entity ID, what happened, then a bracketed summary —
`${conversationId}: updated mutations [${mutationSummary}]` — not `"Mutation status update"`.
