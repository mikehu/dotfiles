---
name: enlist
description: Enlist a squad member to help with cross-repo work.
---

Enlist a squad member to help with cross-repo work. Use when your task requires changes in a sibling repository.

## Find your squad

Your squad info was provided at session start. If you need it again: ``/Users/mike/.local/bin/cmdr squad``

## Always deliver as a PR

Enlisted work must always land as a PR in the enlisted repo, never as a direct commit to main. You may not have opened your own PR yet when enlisting — what matters is the destination state, not the current state. Always-PR keeps cross-repo coordination safe regardless of when each side merges.

Pass ``--pr`` on every dispatch — the cmdr backend renders the right delivery instructions when this flag is set. Do **not** embed your own ``## Delivery`` section in ``--details``; doing so duplicates the backend-rendered block and can produce conflicting instructions.

Include a ``Companion PR: <branch-or-url>`` line at the end of ``--details`` so the delegatee can cross-reference your PR. For ``<branch-or-url>``: use your PR URL if you've opened one; otherwise use your branch name (``git rev-parse --abbrev-ref HEAD``). You can update the cross-reference in the delegatee's PR later if your PR opens after theirs.

## Dispatch

```bash
/Users/mike/.local/bin/cmdr enlist --squad {squad-name} --from {your-alias} --to {target-alias} --pr \
  --summary "Brief description of what you need" \
  --details "Full specification — be precise about interfaces, types, behavior. End with: 'Companion PR: <branch-or-url>'"
```

The --details should have enough context for someone unfamiliar with your repo to implement the change — include expected interfaces, types, endpoints, and behavior.

## After dispatching

Continue with parts of your task that don't depend on the enlisted work. Auto-notification on completion is best-effort and not reliable — check status explicitly:

```bash
/Users/mike/.local/bin/cmdr debrief --squad {squad-name}    # all enlistments by this squad member
/Users/mike/.local/bin/cmdr task {taskId}                   # status + debrief for one task
```
