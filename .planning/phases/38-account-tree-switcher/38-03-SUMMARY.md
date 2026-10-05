---
phase: 38-account-tree-switcher
plan: 03
subsystem: ui
tags: [flutter_bloc, account-tree, gw_colors, gw_menu_item]
requires: [{phase: 38-02, provides: "merged rows, GWMenuItem, Selected/On node tags"}]
provides: ["visibleAccountRows (collapse filter)", "Fund/Recover/Revoke on nested own rows", "gated CHILD WALLETS preset listener", "brandPrimaryBadgeText token"]
affects: []
key-files:
  created: [test/account/account_row_badge_contrast_test.dart]
  modified: [lib/account/account_tree.dart, lib/account/account_drawer.dart, lib/components/overlays/gw_menu_item.dart, lib/theme/gw_colors.dart, lib/theme/genius_wallet_colors.dart, test/account/account_tree_test.dart, test/account/account_drawer_tree_test.dart, test/components/gw_menu_item_test.dart, test/theme/gw_colors_parity_test.dart]
key-decisions:
  - "A nested own row's Fund/Recover/Revoke use registrations pre-read data (row.child/row.parentMain), not a separate lookup -- placeAccount already threads the registration entry through recursion"
  - "The width fix is depth-gated (row.depth >= 1 only): a top-level row never runs tight on phone width, so wrapping its trailing unconditionally caused a real regression (a selected row's height shift broke a stale-overlay hit-test in an unrelated, already-passing test) with no benefit"
  - "New brandPrimaryBadgeText token (~1% lightness nudge of brandPrimaryOnSurface, both modes) for Selected/SDK badge text, which fell just under 4.5:1 composited on its own wash over the selection tint; GWMenuItem's disabled foreground raised from textSecondary@50% to @70% (was 2.10-2.32:1 on surfaceMenu, under the 3:1 floor)"
requirements-completed: [SWT-07]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 38 Plan 03: Child actions, collapse, live refresh, phone width, contrast Summary

**Nested own rows get Fund/Recover/Revoke, mains collapse behind a chevron, the tree stays live while open, and two real AA gaps got fixed along the way.**

## Accomplishments
- `visibleAccountRows`: filters a collapsed main's whole subtree in one pass over the depth-first row list
- Nested own rows (depth >= 1) carry their registration entry and parent main, adding Fund/Recover/Revoke after a divider; a top-level row never has them
- A main's chevron toggles `_collapsedMains` (never persisted); a fresh drawer always reopens expanded
- Gated `DevMockChildWallets.instance.preset` listener in the drawer State (compiled out under `flutter test`'s `kShowDevTools=false`, same as `ChildWalletsCubit`'s own)
- A nested row's trailing wraps tags + balance in a 62px cap so a four-deep chain fits 360px with no overflow; depth-0 rows are untouched

## Deviations from Plan
- Plan 02's must-have named `brandPrimaryOnSurface` for Selected/SDK; that token falls short of 4.5:1 on its own wash over the selection tint (4.42:1 dark / 4.498:1 light), so both badges now read `brandPrimaryBadgeText`, a new, documented, near-identical token.

## Verification
Full suite 2227/5/0 (2202 baseline + 25 new). Analyze/format/brace/raw-colour/key-logging clean. ID gate 0 (BASE = parent of `docs(38-01)`). Windows debug build compiled clean. SWT-07 marked complete.
