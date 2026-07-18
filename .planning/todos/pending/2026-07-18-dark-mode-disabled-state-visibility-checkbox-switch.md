---
created: 2026-07-18T12:35:27.843Z
title: Dark-mode disabled-state visibility — checkbox and switch
area: ui
files:
  - lib/components/inputs/gw_checkbox.dart:39
  - lib/components/inputs/gw_switch.dart
---

## Problem

Confirmed live in the 04-02 D-02 gallery re-walk (2026-07-18), BOTH in dark mode:

- **Disabled `GWCheckbox` is invisible** — the disabled fill uses `borderSubtle`
  (white @ ~12% alpha), which vanishes against the dark surface. (Root-caused
  during the 04-02 plan-check: `gw_checkbox.dart:39-50`.)
- **Disabled `GWSwitch` is styled identically to switch-OFF** — no visual
  distinction between "disabled" and "off", so the disabled affordance is lost.

Both are pre-existing Phase-3 component gaps and are WCAG-contrast / disabled-
affordance failures. The 04-02 ThemeExtension migration was value-preserving, so
it deliberately did NOT change these (correctly routed here to gap closure rather
than silently "fixed" by a color-value change).

These are 2 of the 3 dark-only findings the re-walk recorded (the third is
[[appscreenview-blank-in-dark]] — see that todo).

## Solution

TBD — gap closure. Give disabled checkbox/switch a distinct, visible treatment in
dark mode (e.g. a disabled fill/border with enough contrast against the dark
surface, and a switch disabled-state visibly different from off). Must satisfy the
project WCAG contrast rule (see the `wcag-contrast-rule` auto-memory): text/UI
components ≥ 3:1, disabled states visibly distinct from enabled/off, verified in
BOTH modes. Also bake the WCAG contrast rule into the UI-SPEC design contract so
future components apply it up front.

Related session finding (minor, deferred per user): `GWIcon.svg` renders
always-white — tint it at the usage sites where it appears, not centrally.
