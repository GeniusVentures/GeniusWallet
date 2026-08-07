---
slug: splash-bottom-safe-area
status: complete
date: 2026-08-06
files_changed:
  - lib/screens/splash.dart
committed: false
---

# SUMMARY — splash-bottom-safe-area

## What was done

The splash screen's bottom `Column` was wrapped in `SafeArea(top: false)` with a floor of
`minimum: EdgeInsets.only(bottom: GeniusWalletConsts.space6)`.

The diff is one wrapped widget - `dart format` reindented the subtree, so the change looks bigger
in git than it is.

## Cause, for the record

`lib/screens/splash.dart` contained **no** `SafeArea` and never read `MediaQuery`. The last child
of the bottom `Column` is a 2-pixel progress bar, and `Align(bottomCenter)` glued it to the physical
edge of the screen - under the home indicator and into the rounded corner.

## Why `minimum`, not `SafeArea` alone

`SafeArea` on its own gives 0 on a device without a gesture handle, so the bar would sit on the edge
again. `minimum` is a floor (result = the larger of the two values), so the iPhone gets its ~34 px
and a device without a handle gets 12 px off the 4-pt grid. Without it we would have fixed one phone
model and left the rest.

## Verification

- `dart format lib/screens/splash.dart` — 1 file changed.
- `flutter analyze` — **No issues found! (ran in 27.0s)**, run after the change.
- Visual check on Sidney: full relaunch (the splash does not come back on hot reload) — **in progress**.

## Deviation from the project notes

Project memory recorded the `flutter analyze` baseline as "409 issues, 0 errors" (2026-07-20).
The actual state on 2026-08-06 is **0 issues**. The note needs fixing so the next session does not
treat a clean result as an anomaly.

## Not committed

`AGENTS.md` says "Do not create commits", and Jakub's rule gates commits the same way it gates PRs.
The change sits in the working tree.
