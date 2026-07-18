---
created: 2026-07-18T13:23:10.107Z
title: No user-facing appearance (dark/light) toggle
area: ui
files:
  - lib/theme/gw_appearance.dart:40
  - lib/settings/settings_screen.dart
---

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
