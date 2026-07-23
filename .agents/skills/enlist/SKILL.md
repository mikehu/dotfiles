---
name: enlist
description: Enlist a squad member to help with cross-repo work. Only for NEW delegations — if the target repo already has an active or completed enlistment for this effort, use `cmdr amend` on the existing task instead of enlisting again.
---

Enlist a squad member to help with cross-repo work. Use when your task requires changes in a sibling repository.

## Find your squad

Your squad info was provided at session start. If you need it again: ``/Users/mike/.local/bin/cmdr squad``

## MANDATORY: check for an existing enlistment first

Before every dispatch, check whether the target repo is already enlisted:

```bash
/Users/mike/.local/bin/cmdr debrief --squad {squad-name}
```

- If an open or recently completed task already covers the target repo for this effort, do **not** enlist. Send your additional/corrected instructions to that session instead:

```bash
/Users/mike/.local/bin/cmdr amend {taskId} --details "Amended orders — precise, self-contained instructions building on the original ask"
```

  The enlisted session keeps its full context, worktree, and branch; it applies the amendment on top of its existing work and rewrites its debrief. If `amend` fails because the worktree is gone, only then enlist fresh.

- Only enlist when no enlistment exists for that repo. (The backend also enforces this: enlisting a repo with an open enlistment auto-forwards your orders as an amendment and reports the existing taskId.)

## Always deliver as a PR

Enlisted work must always land as a PR in the enlisted repo, never as a direct commit to main. You may not have opened your own PR yet when enlisting — what matters is the destination state, not the current state. Always-PR keeps cross-repo coordination safe regardless of when each side merges.

Pass ``--pr`` on every dispatch — the cmdr backend renders the right delivery instructions when this flag is set. Do **not** embed your own ``## Delivery`` section in ``--details``; doing so duplicates the backend-rendered block and can produce conflicting instructions.

Include a ``Companion PR: <branch-or-url>`` line at the end of ``--details`` so the delegatee can cross-reference your PR. For ``<branch-or-url>``: use your PR URL if you've opened one; otherwise use your branch name (``git rev-parse --abbrev-ref HEAD``). You can update the cross-reference in the delegatee's PR later if your PR opens after theirs.

## Dispatch

```bash
/Users/mike/.local/bin/cmdr enlist --squad {squad-name} --from {your-alias} --to {target-alias} --pr \
  --effort {effort-slug} --slug {enlistment-slug} \
  --summary "Brief description of what you need" \
  --details "Full specification — be precise about interfaces, types, behavior. End with: 'Companion PR: <branch-or-url>'"
```

The --details should have enough context for someone unfamiliar with your repo to implement the change — include expected interfaces, types, endpoints, and behavior.

### Effort and slug

Orders and debriefs are recorded as markdown (with frontmatter metadata) under ``.agents/enlistments/{effort}/`` in your working tree — this folder is the consolidated record of the coordinated cross-repo work.

- ``--effort``: short kebab-slug naming the overall cross-repo effort (e.g. ``support-x-feature``). **Reuse the same effort slug for every enlistment belonging to the same coordinated change** so they group in one folder.
- ``--slug``: short kebab-slug for this specific enlistment (e.g. ``support-x-feature-on-api``). Pick something more apt than the summary when the summary is long; omitted, cmdr slugifies the summary.

## After dispatching

Continue with parts of your task that don't depend on the enlisted work. Auto-notification on completion is best-effort and not reliable — check status explicitly:

```bash
/Users/mike/.local/bin/cmdr debrief --squad {squad-name}    # all enlistments by this squad member
/Users/mike/.local/bin/cmdr task {taskId}                   # status + debrief for one task
```

Debriefs also land in ``.agents/enlistments/{effort}/debrief-{taskId}_{slug}.md`` next to the orders; read them there when consolidating the effort. Prior debriefs from before an amendment are archived alongside as ``debrief-…N.md``.
