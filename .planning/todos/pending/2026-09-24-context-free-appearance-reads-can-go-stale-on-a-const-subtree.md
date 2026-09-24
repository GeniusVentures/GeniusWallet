---
created: 2026-09-24T15:00:00.000Z
title: Context-free appearance reads can still go stale on a const subtree
area: theme
severity: minor
---

## Problem

`GWDecorations` (`genius_wallet_decorations.dart:24,71,129,226`, including `GWCanvasBackground`), `GeniusWalletTypography`'s default colour (`:39`), `GeniusWalletElevation` (`:10,20`), `GeniusWalletGradient` (`:63,82`) and `swap_screen.dart:873` read `GWAppearance.isLight` statically, which registers no inherited dependency. Today they re-skin only because their callers also read `Theme.of`. A `const` widget using only these statics keeps its old colours after a live appearance toggle. No visibly stale instance is known today; this is a latent risk.

## Fix direction

Give each a context or `GWColors` parameter, or assert every consumer depends on Theme. Check: toggle Appearance in /settings with a const widget that uses `GeniusWalletTypography.titleMd` and no colour.
