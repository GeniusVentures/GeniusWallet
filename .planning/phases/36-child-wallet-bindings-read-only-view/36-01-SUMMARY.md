---
phase: 36-child-wallet-bindings-read-only-view
plan: 01
subsystem: ui
requires: []
provides:
  - "GetRegistrationsForMain/GetChildBalanceAll bindings + GeniusApi wrappers (collectChildRegistrations copy-then-free-once contract)"
  - "ChildWalletsCubit/ChildWalletsScreen at /child-wallets: header, four states, 10s poll, lag note"
  - "SDK-row 'Child wallets' menu item, enabled only on the selected account"
actuals: {tokens: 14300, tasks: 3, commits: 3}
key-files:
  created: [lib/child_wallets/child_wallets_cubit.dart, lib/child_wallets/child_wallets_screen.dart, test/child_wallets/child_wallets_screen_test.dart, test/ffi/child_wallet_ffi_test.dart]
  modified: [packages/genius_api/lib/ffi/genius_api_ffi.dart, packages/genius_api/lib/src/genius_api.dart, lib/navigation/router.dart, lib/account/sdk_account_manager.dart, test/account/sdk_row_actions_test.dart, test/account/sdk_account_rows_test.dart]
key-decisions:
  - "ChildRegistrationsStatus extension (isOk/isNotInitialized) added to genius_api.dart so the cubit branches on SDK status without importing the raw FFI binding file"
requirements-completed: [CHILD-01, CHILD-02]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 36 Plan 01: Child wallet bindings & read-only view Summary

**Read-only `/child-wallets` screen reachable from the SDK row menu, backed by two new hand-spliced GeniusSDK bindings with a copy-then-free-once memory contract pinned under test.**

## Accomplishments
- `GeniusRegistrationMetadata`/`GeniusRegistrationDiscoveryEntry` structs (sizeOf 392/664, pinned) and their two bindings, plus `collectChildRegistrations` and `GeniusApi.getChildRegistrations`/`getChildBalanceAll` wrappers
- `ChildWalletsCubit`/`ChildWalletsScreen`: header always shown, four states (loaded/empty/node-not-running/error), 10s poll cancelled on close, balances via `minionsToGnus` (BigInt-exact) + `formatTxAmount`
- New `/child-wallets` route and a "Child wallets" SDK-row menu item, gated to the account the node runs as

## Task Commits
1. Tracer: one main's children and balances - `a443e62f` (feat)
2. Struct layout and free-contract tests - `1283487a` (test)
3. Every state, the 10s poll, and the menu gate - `3d30934c` (feat)

## Verification
No deviations from the plan. Full suite: 2000 passed / 5 skipped / 0 failed (baseline 1968 + 32 new). `flutter analyze lib test`: 0 issues. `flutter analyze` on the two genius_api files: exactly 109 pre-existing warnings, none new. Format/brace/raw-colour/key-logging scripts clean. ID-identifier gate: 0 matches on every commit. Live node walk deferred to end-of-milestone per this plan's own `<verification>` note.

## Self-Check: PASSED
All created files present on disk; all three commit hashes found in git log.
