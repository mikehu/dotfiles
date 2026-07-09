## Reporting Information

When reporting information to me, be extremely concise and sacrifice grammar for the sake of concision.

## Coding Principles

1. **Surface confusion early** — If something is ambiguous or has multiple valid interpretations, stop
and ask before implementing. State assumptions explicitly. Push back if a simpler approach exists.

2. **Minimum viable change (breadth, not depth)** — Minimal governs *scope*: no features beyond what
was asked, no abstractions for single-use code, no speculative flexibility, no defensive scaffolding
(defensive cloning, helper wrappers, `_`-prefixed pseudo-private methods) unless requested. It does
NOT mean band-aid fixes. Solve the actual problem — if 200 lines could be 50, rewrite it.

3. **Root cause over symptom** — When the request is a symptom of a deeper defect, fix the cause, not
the surface (boy scout: leave touched code better than you found it). This license covers code in the
*path of the fix* — it is not a free hand to refactor the whole file. Triage: local root-cause fixes,
just do them; large or cross-cutting ones (new abstractions, changes affecting callers) — surface and
confirm first, per #1.

4. **Surgical on taste, not on correctness** — Don't churn adjacent code for style, formatting, or
preference; match existing style there. Distinguish "this offends my taste" (leave it) from "this is
wrong / is the root cause" (fix it). Every changed line traces to either the request or the root cause
behind it.

5. **Verifiable goals** — Before multi-step work, define success criteria and a brief plan. "Fix the
bug" becomes "reproduce it, write a test, make it pass." Loop independently against concrete checks
rather than vague intent.

6. **Natural domain scope** — When modeling an input type or domain, don't artificially narrow it.
Prefer the broader natural type (E164 over US_E164, Path over RelativePath) when the cost is the
same. This is about scope, not abstraction layers — it does not override #2.

## Working from review feedback

When addressing a list of findings from a review step (code review, pi review, audit, lint report,
etc.), don't plow through start-to-finish. Triage first: fix the trivial/local items, but pause and
ask before tackling architecturally significant ones (scope changes, new abstractions,
tool/responsibility shifts, anything that could affect callers). The point of a review is the
conversation, not just the patch.

## Git Workflow

- **Always rebase before merging** — never create merge commits. When integrating branch work (including
  worktree branches), rebase onto the target branch first, then fast-forward merge. This keeps history
  linear and readable.
- When cleaning up after a worktree, remove the worktree directory and delete the branch.

## Logging

When drafting log messages, ensure the message string itself is useful and identifiable without relying
on metadata. You should be able to scan through log messages and understand what's happening at a
glance.

- **Message**: Self-descriptive, scannable, identifies what happened
- **Metadata**: Verbose context for when you need to dig deeper

**Example**:
```js
// ✅ Good - message tells you what happened
req.log.info(
{ conversation_id: conversationId, success },
`${conversationId}: updated mutations [${mutationSummary}]`
)

// ❌ Bad - generic message, relies on metadata to understand
req.log.info(
{ conversation_id: conversationId, mutations, success },
'Mutation status update'
)
```

