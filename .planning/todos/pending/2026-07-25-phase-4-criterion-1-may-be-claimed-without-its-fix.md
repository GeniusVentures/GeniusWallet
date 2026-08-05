---
created: 2026-07-25T12:35:51.827Z
title: Phase 4 criterion 1 may be claimed without its fix (7a63b4f deferred but criterion passed)
area: planning
files:
  - .planning/ROADMAP.md
  - .planning/phases/04-navigation-shell-chrome/04-VERIFICATION.md
---

## Problem

`.planning/ROADMAP.md` appears to contradict itself about Phase 4, and Phase 4 is marked
`passed`.

- **Line 224** lists as a Phase 4 **success criterion**: *"The app starts, reaches the shell, and
  navigates every existing `go_router` route with no runtime exception — specifically no `!_dirty`
  crash when the initial route resolves mid-mount (`7a63b4f`)"*
- **Line 242** records, for the same phase: *"**Carries**: `7a63b4f` (`!_dirty` guard) — DEFERRED to
  the swap-FAB phase per D-08 (its target `GlobalSwapFabHost` is not built this phase; carry-move,
  not a drop)"*

So the criterion names `7a63b4f` as the thing that must be true, while the same section records
that commit as deferred out of the phase. And `7a63b4f` is **not an ancestor of
`ui-redesign-port`** (verified 2026-07-25 via `git merge-base --is-ancestor`) — it lives only on
`ui-redesign-3.514-develop`.

Surfaced 2026-07-25 while scoping Phase 8, which has now explicitly taken ownership of the carry
(ROADMAP criterion 5, plus D-17/D-18 in `08-CONTEXT.md`). Phase 8 owning it going forward does
**not** resolve the question of whether Phase 4 should have passed that criterion.

## Solution

Read `.planning/phases/04-navigation-shell-chrome/04-VERIFICATION.md` and determine which of these
is true:

1. **The criterion was satisfied by other means** — e.g. the `!_dirty` crash could not occur on
   `ui-redesign-port` because `GlobalSwapFabHost` (the thing that tripped it) was never mounted
   here. In that case the criterion is honestly met and the ROADMAP wording is just confusing:
   fix the wording so it does not cite a commit that was deferred.
2. **The criterion was passed on the strength of the commit reference alone**, without the fix being
   present. Then Phase 4's verification has a real gap and should be recorded as such — most likely
   as an override with a note that Phase 8 now carries the fix, rather than silently re-opening a
   closed phase.

Option 1 is plausible and probably the answer — but it should be *checked and written down*, not
assumed. Note this is a **planning/verification-record** question, not a code defect: no user-facing
bug is claimed here.
