---
phase: 34-account-linking
plan: 03
subsystem: api
provides:
  - GeniusApi.backfillLinks (pure, @visibleForTesting) - the no-guess backfill decision
  - GeniusApi.linkExistingSDKAccounts / _addToSDK - the pass, wired to start-up and import
  - LocalWalletStorage.getStoredKeys
actuals: {tokens: 4018, tasks: 2, commits: 3}
key-files:
  created: [test/account/sdk_link_backfill_test.dart]
  modified: [packages/genius_api/lib/src/genius_api.dart, packages/local_secure_storage/lib/src/local_secure_storage_base.dart, lib/bloc/app_bloc.dart]
key-decisions:
  - "requirements mark-complete skipped for LINK-01/LINK-03: LINK-02 layout work (Phase 35) and LINK-03's flagged assumption are still open"
requirements-completed: []
duration: ~25min
completed: 2026-09-29
status: complete
---

# Phase 34 Plan 3: One-time backfill for pre-existing SDK accounts Summary

**Old SDK accounts are linked once after start-up by re-adding each unlinked wallet's key and diffing the account list; anything that can't be proven this way stays honestly "Unlinked".**

## Accomplishments
- `backfillLinks`: a single new address from a re-add links; a no-op re-add is an elimination candidate, linked only when it is the sole candidate against a sole leftover address; a jump of more than one stops the pass with no elimination
- `_addToSDK` extracted from `_registerWallet`'s inline branch, shared by both the normal import path and the backfill pass
- `linkExistingSDKAccounts` runs after `AppBloc.InitializeSDK`'s own emit and again inside `_registerWallet` (so an import made while the node was down gets linked once it starts), then `AppBloc` waits for wallet loading before refreshing names (30s timeout, swallowed) so the two never race

## Task Commits
1. Backfill decision (TDD) - RED `adef2346`, GREEN `17c69592`
2. Wiring to start-up and import - `9b94bbf1`

No deviations - plan executed exactly as written.

Full `flutter test`: 1921 passed/5 skipped/0 failed. `flutter analyze lib test`: 0 issues. `dart format` and `tool/check_brace_style.sh` clean.

Self-Check: PASSED - all 4 files and 3 commits verified present.

*Phase: 34-account-linking — completed 2026-09-29*
