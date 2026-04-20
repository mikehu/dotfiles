---
name: enlist
description: Enlist a squad member to help with cross-repo work.
argument-hint: ""
---

Enlist a squad member to help with cross-repo work.

You are part of a squad — a group of repos managed by cmdr that can collaborate on cross-repo work.

## When to use

When your current task requires changes in another repository that is part of your squad. For example:
- You need a new API endpoint in a sibling service
- You need a shared type exported from a common library
- You need a config change in an infrastructure repo

## How to enlist

Run the cmdr CLI to dispatch work to a squad member:

```bash
/Users/mike/.local/bin/cmdr enlist --squad {squad-name} --from {your-alias} --to {target-alias} \
  --summary "Brief description of what you need" \
  --details "Full specification — be precise about interfaces, types, behavior"
```

Cmdr will validate the squad, create a branch, and launch a Claude session in the target repo.

After dispatching, continue working on parts of your task that don't depend on the enlisted work. You will be automatically notified when the enlistment is complete.
