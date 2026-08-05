---
phase: quick-260720-lyn
plan: 01
subsystem: theme
tags: [ui, shadows, appearance, light-mode]
status: complete
dependency-graph:
  requires: []
  provides: [GeniusWalletElevation.card, GeniusWalletElevation.dialog appearance-aware shadows]
  affects:
    - lib/components/cards/gw_card.dart
    - lib/components/overlays/gw_dialog.dart
    - lib/theme/genius_wallet_decorations.dart
tech-stack:
  added: []
  patterns: [appearance-aware getter over const list, GWAppearance.isLight switch]
key-files:
  created: []
  modified:
    - lib/theme/genius_wallet_elevation.dart
decisions:
  - "Converted static const List<BoxShadow> to static List<BoxShadow> get to allow runtime branching on GWAppearance.isLight; inner BoxShadow/Offset/Color literals stay const."
  - "Light-mode alphas: card 0x1F000000 (~12%), dialog 0x33000000 (~20%); dark-mode bytes unchanged (0x59000000 / 0x73000000)."
metrics:
  duration: "~10 min"
  completed: "2026-07-20"
---

# Phase quick-260720-lyn Plan 01: Soften elevated-surface card/dialog shadows Summary

Made `GeniusWalletElevation.card` and `.dialog` appearance-aware getters that soften the drop-shadow alpha in light mode (~12% / ~20%) while leaving dark mode byte-identical (35% / 45%), fixing walk feedback that shadows read too heavy on light surfaces.

## What Was Built

**Task 1: Make GeniusWalletElevation.card + dialog appearance-aware (softer in light)**

- Added `import 'package:genius_wallet/theme/gw_appearance.dart';` to `lib/theme/genius_wallet_elevation.dart`.
- Converted `card` from `static const List<BoxShadow>` to `static List<BoxShadow> get card`, branching on `GWAppearance.isLight`:
  - Light: `Color(0x1F000000)` (~12%)
  - Dark: `Color(0x59000000)` (~35%, byte-unchanged from original)
  - `blurRadius: 16`, `offset: Offset(0, 4)` unchanged.
- Converted `dialog` the same way:
  - Light: `Color(0x33000000)` (~20%)
  - Dark: `Color(0x73000000)` (~45%, byte-unchanged from original)
  - `blurRadius: 32`, `offset: Offset(0, 8)` unchanged.
- `glowBrand` / `glowGradient` left untouched (brand glows, not neutral drop shadows, per plan scope).
- Confirmed via `flutter analyze` that all 4 known consumers (`gw_card.dart`, `gw_dialog.dart`, `genius_wallet_decorations.dart` x2) compile cleanly with the const→getter change since none use it in a const context.

## Deviations from Plan

None - plan executed exactly as written.

## Verification

```
flutter analyze lib/theme/genius_wallet_elevation.dart lib/components/cards/gw_card.dart lib/components/overlays/gw_dialog.dart lib/theme/genius_wallet_decorations.dart
No issues found! (ran in 1.1s)
```

## Commits

- `2b05cfd`: fix(quick-260720-lyn): soften elevated card/dialog shadows in light mode

## Remaining Work

Task 2 is a `checkpoint:human-verify` (gate="blocking") — the walk step. Execution paused here per plan instructions. On the already-running `GW_DEV_TOOLS=true` build (no rebuild needed since this is a runtime getter change reflected via hot reload/existing app state), the user needs to:
1. Flip to LIGHT via the dev bubble and confirm card shadows (markets grid, dashboard sections, transaction rows) + any dialog read as a subtle elevation, not a heavy drop shadow.
2. Flip to DARK and confirm the elevation looks exactly as before (unchanged).
3. Respond "approved" or say softer/stronger.

## Self-Check: PASSED

- FOUND: lib/theme/genius_wallet_elevation.dart
- FOUND: 2b05cfd (git log)
