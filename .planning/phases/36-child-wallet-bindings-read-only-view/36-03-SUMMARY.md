---
phase: 36-child-wallet-bindings-read-only-view
plan: 03
subsystem: ui
requires:
  - phase: 36-01
    provides: "ChildWalletsCubit/ChildWalletsScreen, GeniusApi.getChildRegistrations/getChildBalanceAll"
provides:
  - "DevMockChildWallets: five sticky presets (none/oneChild/threeChildren/queryError/nodeNotRunning), arm/clear, registrationsFor/balanceFor fixture tables"
  - "ChildWalletsCubit reads the preset behind kDebugMode && kShowDevTools, bypassing the no-selected-account check when armed"
  - "CHILD WALLETS section in the dev bubble, between BANXA and NAVIGATE"
key-files:
  created: [lib/dev/dev_mock_child_wallets.dart, test/dev/dev_mock_child_wallets_test.dart]
  modified: [lib/child_wallets/child_wallets_cubit.dart, lib/dev/dev_tools_bubble.dart, test/child_wallets/child_wallets_screen_test.dart]
key-decisions:
  - "threeChildren's synthetic pair (12.345678/0 GNUS) is always unlinked; only the leading slot ever resolves to a real linked sibling, via the first app.sdkAccounts entry other than main with a link"
requirements-completed: [VER-01]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 36 Plan 03: Child wallet bindings & read-only view Summary

**Every child-wallet screen state (empty, one child, three mixed, query error, node not running) is now reachable from the dev bubble with no live node, gated behind kDebugMode && kShowDevTools.**

## Accomplishments
- `DevMockChildWallets`: sticky `ValueNotifier<DevChildWalletsPreset?>`, `arm`/`clear`, and `registrationsFor`/`balanceFor` fixture tables; four synthetic `0xDEV...` addresses distinguished by their last 4 characters
- `ChildWalletsCubit.refresh` reads the preset only behind the double gate, adds/removes a listener in the constructor/`close()`, and an armed preset skips the no-selected-account check
- CHILD WALLETS bubble section (None / One child / Three children / Query error / Node not running / Clear), inserted after BANXA and before NAVIGATE

## Verification
No deviations from the plan. Full suite: 2032 passed / 5 skipped / 0 failed (2008 baseline + 24 new). `flutter analyze lib test`: 0 issues. Package-scoped analyze on the two genius_api files: exactly 109 pre-existing warnings, none new. Format/brace/raw-colour/key-logging scripts clean. ID-identifier gate: 0 matches on both commits. Windows debug build compiled (not run).

**Pending, manual, end-of-milestone only (not attempted here):** VER-02's live node walk, and walking each CHILD WALLETS preset from the bubble against an open Child wallets screen.
