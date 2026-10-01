---
phase: 34-account-linking
plan: 04
subsystem: api
provides:
  - GeniusApi.addWalletFromSecret / SDKAddOutcome - the SDK form's import path
  - _registerWallet(save:false) returning Future<bool>
  - AddSDKAccountWithMnemonic/WithPrivateKey.done Completer
actuals: {tokens: 6400, tasks: 2, commits: 2}
key-files:
  modified: [packages/genius_api/lib/src/genius_api.dart, lib/bloc/app_event.dart, lib/bloc/app_bloc.dart, lib/account/sdk_account_manager.dart, test/account/sdk_add_account_test.dart]
key-decisions:
  - "requirements mark-complete skipped for LINK-01: phase 34 marks it at phase close, not per-plan"
requirements-completed: []
duration: ~30min
completed: 2026-09-28
status: complete
---

# Phase 34 Plan 4: SDK form becomes a wallet import Summary

**Pasting a secret into the SDK Accounts form now saves the ETH wallet and links its SDK account through the same `_registerWallet` path as normal import, and reports exactly what happened instead of guessing from a list-length change.**

## Accomplishments
- `SDKAddOutcome` (added/alreadyThere/pending/failed); `addWalletFromSecret` builds the wallet the way normal import does, detects an existing key wallet by lowercased address, and never rolls back a save that already happened
- `_registerWallet` takes `{bool save = true}` and now returns `Future<bool>` (whether the SDK ends up holding the account), with everything after the key save wrapped so a throw never hides the save (D-06)
- `_defaultWalletName` extracted from `saveWallet`'s inline fallback name, reused by the new form path (D-03)
- Both add events carry an optional `Completer<SDKAddOutcome>`; one shared `AppBloc` handler calls `addWalletFromSecret` (the old direct `addAccountWith*` calls are gone) and never selects an SDK account or the active wallet (D-04)
- Dialog awaits the completer (60s timeout -> failed) and toasts per outcome: "Account added", "That wallet is already in the app.", the pending note, or "That account could not be added."

## Task Commits
1. genius_api save+report - `8f802b3a`  2. Bloc + dialog wiring - `ef0b7eb7`

No deviations - plan executed exactly as written.

Full `flutter test`: 1924 passed/5 skipped/0 failed (1921 baseline + 3 new). `flutter analyze lib test`: 0 issues. `dart format`, `check_brace_style.sh`, `check_no_new_key_logging.sh --scan-tree` all clean.

Self-Check: PASSED - all 5 files and 2 commits verified present.

*Phase: 34-account-linking — completed 2026-09-28*
