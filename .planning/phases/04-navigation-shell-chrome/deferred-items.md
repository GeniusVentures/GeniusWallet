# Phase 4 — Deferred Items

Out-of-scope discoveries logged during execution, per the executor's scope-boundary rule
(not fixed — pre-existing, unrelated to the task that surfaced them).

## 04-01

- `lib/dev/design_gallery_screen.dart:187,223` — `unnecessary_const` info-level lints
  (`flutter analyze`), pre-existing on lines this plan's Task 2 did not touch. Not fixed:
  out of this theme-only plan's scope (`design_gallery_screen.dart`'s only sanctioned edit
  this plan is the single `backgroundColor` revert at what is now line ~103).
