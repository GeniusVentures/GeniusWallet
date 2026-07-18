---
created: 2026-07-18T14:27:29.466Z
title: Drawer / dialog padding & spacing polish (UI/UX)
area: ui
files:
  - lib/account/account_dropdown_selector.dart
  - lib/components/overlays/gw_dialog.dart
  - lib/components/bottom_drawer/bottom_drawer.dart
---

## Problem

Noted by the user during the 04-04 drawer walk (2026-07-18): the re-skinned wallet
drawer + rename/delete dialogs render correctly and flip appearance correctly, but
a few **paddings / spacings** need tightening for better UI/UX. Cosmetic polish
only — not a bug, not blocking 04-04 (which is scoped to a value-preserving
re-skin + behavior fix).

## Solution

TBD — a small design-polish pass over the drawer rows, the drawer panel/sheet
insets, and the GWDialog content/action spacing to match the intended redesign
rhythm. Best done as a quick follow-up (or folded into a later UI-polish sweep).
Keep it token-driven (GeniusWalletConsts spacing scale) and re-check WCAG spacing/
touch-target sizing ([[wcag-contrast-rule]]). Get specific target values from the
user / the redesign reference when picked up.
