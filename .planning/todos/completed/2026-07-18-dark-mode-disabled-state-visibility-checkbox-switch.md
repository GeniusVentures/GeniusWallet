---
created: 2026-07-18T12:35:27.843Z
title: Dark-mode disabled-state visibility — checkbox and switch
area: ui
files:
  - lib/components/inputs/gw_checkbox.dart:39
  - lib/components/inputs/gw_switch.dart
---

## Partially closed 2026-09-22 (quick 260922-deo)

Both defects below are fixed and hold in **both** appearances, not dark only:
`GWCheckbox`'s disabled side/fill and `GWSwitch`'s disabled thumb/track/outline
now read `borderControl`/`textSecondary` instead of `borderSubtle`
(1.27–1.43:1, effectively invisible). `borderControl`'s light-mode alpha also
moved 46%→48% so it clears 3:1 on every light surface, not just white.
Measured: disabled edge vs surface 3.09–3.29:1 light / 3.23–3.33:1 dark,
disabled switch thumb vs track 5.61:1 light / 5.39:1 dark, disabled thumb vs
the enabled-off thumb 2.95:1 light / 3.23:1 dark — distinct, not merely
visible. Guarded by `test/theme/disabled_control_contrast_test.dart`. The
UI-SPEC ask below is the only part still open.

## Problem

The WCAG contrast rule the fix above relied on (see the `wcag-contrast-rule`
auto-memory) is not yet baked into the UI-SPEC design contract, so a future
component can still ship a disabled state without that floor being asked for
up front.

## Solution

Bake the WCAG contrast rule into the UI-SPEC design contract: disabled-vs-
surface and disabled-vs-enabled-state pairings must clear 3:1, verified in
both appearances, before a component ships.

Related session finding (minor, deferred per user): `GWIcon.svg` renders
always-white — tint it at the usage sites where it appears, not centrally.

## Closed 2026-09-24

Code fixed in 27184403 (PR #239) and guarded in both modes by `test/theme/disabled_control_contrast_test.dart`. The one open item, writing the rule into the UI-SPEC contract, is refiled as `2026-09-24-disabled-contrast-floor-belongs-in-the-ui-spec-contract.md`.
