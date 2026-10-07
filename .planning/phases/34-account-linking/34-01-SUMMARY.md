---
phase: 34-account-linking
plan: 01
subsystem: api
provides:
  - SDKAccountLink storage + diff-and-persist capture
  - AppBloc.linkedWallet/sdkAccountName row naming
  - AppState.sdkAccountLinks, defaultSDKAccount (renamed)
actuals: {tokens: 7859, tasks: 3, commits: 3}
key-files:
  modified: [packages/local_secure_storage/lib/src/local_secure_storage_base.dart, packages/genius_api/lib/src/genius_api.dart, lib/bloc/app_bloc.dart, lib/bloc/app_state.dart, lib/account/sdk_account_manager.dart]
key-decisions:
  - "requirements mark-complete skipped for LINK-01/LINK-02: multi-plan, D-01/D-12/D-13/D-17/D-19 not built"
requirements-completed: []
duration: ~18min
completed: 2026-09-29
status: complete
---

# Phase 34 Plan 1: SDK account link capture and naming Summary

**A key wallet's SDK address is recorded (`__sdk_links__`) and named from it everywhere SDK rows render; "Super Genius Wallet N" is gone.**

## Accomplishments
- Storage: lowercased address->name map, never throws on corrupt data
- `_initSDK`/`_registerWallet` capture the link on start and later imports
- `AppBloc.linkedWallet`/`sdkAccountName` replace the numbered placeholder
- D-20: start-account ids renamed to "default"; `sdkAccountLinks` in all 11 emits

## Task Commits
1. Link capture - `d45bba7c`  2. D-20 rename - `ad45f9f3`  3. AppState + emits - `d7e088d1`

No deviations - plan executed exactly as written. Self-Check: PASSED - all 9 files and 3 commits verified present.

*Phase: 34-account-linking — completed 2026-09-29*
