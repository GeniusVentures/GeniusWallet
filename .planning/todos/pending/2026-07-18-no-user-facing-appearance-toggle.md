---
created: 2026-07-18T13:23:10.107Z
title: No user-facing appearance (dark/light) toggle
area: ui
severity: verification-blocker  # ESCALATED 2026-07-20 (05-01 walk) — was UX-only
files:
  - lib/theme/gw_appearance.dart:40
  - lib/settings/settings_screen.dart
blocks:
  - "05-01 must_have: DashboardScrollContainer 'flips LIVE on an in-place appearance toggle rather than rendering stale'"
---

## ESCALATION (2026-07-20, 05-01 dashboard walk)

This is no longer just a UX gap — it is now a **verification blocker**. Multiple
plans (04-02, 04-04, 05-01) carry a must_have of the form "re-skins LIVE on an
IN-PLACE appearance toggle", which exists specifically to catch the const-staleness
failure mode documented in `2026-07-18-const-widgets-do-not-re-skin-on-live-
appearance-toggle.md`. That clause **cannot be verified while the only `setMode()`
call sites are dev screens** (`lib/dev/token_probe_screen.dart:103`,
`lib/dev/design_gallery_screen.dart:124`).

The reason is structural, not a matter of walk discipline: toggling requires
navigating away to a dev screen and back, and **that navigation forces a rebuild
which masks exactly the const-staleness the clause guards against**. A walk done
this way can only ever prove "correct AFTER an appearance change", never "flips
LIVE in place". Until a toggle reachable from the surface under test exists, every
such must_have must be recorded as an outstanding item rather than passed.

**Recipe to close the blocked verifications once a toggle ships:** with the surface
under test on screen and NOT navigated away from, flip appearance and confirm the
surface re-skins immediately. A surface that stays in the old mode is the
const-staleness regression.

## Problem

Surfaced during the 04-03 nav-shell walk (2026-07-18). The appearance system
(`GWAppearance` + GWColors + OS-follow default) is fully wired and the whole app
re-skins on `GWAppearance.instance.setMode(...)` — but the ONLY places that call
`setMode` are DEV tools: the design gallery sun/moon (`design_gallery_screen.dart`)
and the token probe (`token_probe_screen.dart`). There is NO user-facing appearance
toggle on any real (non-dev) screen. On a normal build (`GW_DEV_TOOLS` off) a user
cannot switch dark/light at all — they are stuck on the OS-follow default with no
override.

Alex's `lib/preferences/` (which had the toggle) is OUT of scope for the port, and
develop never had one, so this fell through the gap.

## Solution

TBD. Add a real appearance control — most naturally an "Appearance" row in the
Settings screen (light / dark / follow-OS), calling `GWAppearance.instance.setMode`
and persisting via the existing Hive `preferences` box (`appearanceModeKey`). Good
candidate to fold into the 04-05 Settings re-skin (`settings_screen.dart`), or a
small dedicated task. Must honor the three states (light, dark, system) and the
WCAG rule ([[wcag-contrast-rule]]). Note: this also removes the current walk
limitation where the shell's live-flip can only be exercised via the dev Gallery.
