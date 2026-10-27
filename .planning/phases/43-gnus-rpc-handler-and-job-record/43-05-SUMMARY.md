---
phase: 43-gnus-rpc-handler-and-job-record
plan: 05
subsystem: gnus_bridge
tags: [gnus-rpc, wiring, guards, contract, phase-gate]
requires: [43-04]
provides:
  - RepositoryProvider<GnusRpcHandler> in main.dart with the rejecting default confirm
  - source guards for wiring, layering and logging
  - an every-method, two-transport contract matrix
  - handler choices written into the contract
affects: [44, 45, 46, 47]
key-files:
  created:
    - test/gnus_bridge/gnus_rpc_guards_test.dart
    - test/gnus_bridge/gnus_rpc_contract_test.dart
  modified:
    - lib/main.dart
    - .planning/research/v4.0-gnus-rpc-contract.md
decisions:
  - The provider's private GnusCubit is closed in the provider's dispose, found through an Expando keyed by the handler (the handler's own dispose only cancels subscriptions)
  - The provider sits in the existing MultiBlocProvider list; the analyzer accepts it, so no inner MultiRepositoryProvider was needed
status: complete
actuals:
  tokens: 55000
  tasks: 2
  commits: 2
---

# Phase 43 Plan 05: Wiring, guards and the contract matrix Summary

The app now provides one `GnusRpcHandler` built from the real app-level cubits and the `gnusJobs` box with no confirm argument, so nothing can spend until phase 44 supplies a prompt; source guards and a 53-case two-transport matrix lock that in.

## Tasks

| Task | Name | Commit |
| ---- | ---- | ------ |
| 1 | App wiring with the rejecting confirm, plus logging and boundary guards | a2708a9c |
| 2 | Every method through both transports, contract text, phase gate | f701c01f |

## What was built

- `lib/main.dart`: `RepositoryProvider<GnusRpcHandler>` after `BridgeGateCubit`, lazy. Reads the app bloc, wallet details, gate (`resolveNow`), `ChildOperationsCubit.ownRegistrations` and its stream, `GnusJobStore.app()`. A private `GnusCubit(CoinService(), walletDetails)` is closed together with the handler on dispose.
- Guards: the `GnusRpcHandler(` argument list in main.dart names no `confirm` and names `GnusJobStore.app()` (the paren matcher is checked on a positive sample first); `initHive` opens `gnusJobsBoxName` as `Box<String>`; nothing under `lib/gnus_bridge` calls `bridgeOut`, `getBrigeOutGasCost` or the async cost and process calls, names `Hive` outside the store, or imports Flutter UI; a capturing `debugPrint` shows every `gnus_rpc ` line matches the fixed shape and no sentinel job, key, cursor, method name or burn hash appears.
- Contract matrix: 4200, -32602 (all six methods with bad params plus 14 specific shapes), 4900 (all six), -32015 (five methods; `gnus_getAccounts` returns `switching: true`), -32010 (estimate and submit), and a valid call of each method. Each case runs on a direct and a JSON-serialised harness and the replies must be deep-equal. A final test asserts no reply contains `"cost":"0"`.
- Contract text (all marked D, dated 2026-10-27), edited in `.planning/research/v4.0-gnus-rpc-contract.md`:
  - `gnus_estimate`: `balance` null when unreadable; a submit fails closed with `-32603 balance_unavailable`.
  - `gnus_submitJob`: the record is written at burn time as `bridgedNotProcessed`, moved to `submitted` on Process success.
  - `gnus_listJobs`: only the current node account's jobs.
  - `gnus_getJob`: `null` when no record matches; idempotency lookup is same-origin only.
  - Errors: a new `data.reason` table (-32012, -32011, -32603, -32015 `account_changed`) before section 6.
  The edited file was copied byte-for-byte to the side-session mirror `gnus-rpc-contract.md` (verified with `cmp`).

## Phase gate

- `dart format --set-exit-if-changed` over lib/gnus_bridge, lib/submit_job, lib/hive, lib/main.dart, test/gnus_bridge, test/submit_job: exit 0.
- `bash tool/check_brace_style.sh`: exit 0.
- `flutter analyze --no-pub lib test`: exit 0, no issues.
- Full suite: +2866 ~6, 0 failed, exit 0. 43-01 baseline 2693, so +173 for the phase.
- Per-plan additions: 43-01 +24, 43-02 +32, 43-03 +23, 43-04 +33, 43-05 +61 (8 guards, 53 matrix).
- `git ls-files --eol`: every tracked file in lib/gnus_bridge and test/gnus_bridge is `i/lf`; the two new untracked-at-check files were `w/lf`.

## Deviations from Plan

None. Plan executed as written; the Expando is the mechanism chosen for the checker's "close the private cubit in the provider's dispose" note.

## Known limits carried forward

- Live cost is -32010 until SDK-CA is fixed on the SDK side.
- `isProcessing` is false while the processing feed is down or has never ticked (`ponytail:` on `_getEarnings`).
- A window close during the burn itself, before `onBurned` runs, is not covered (Phase 42's `ponytail:`).
- The idempotency and listing scans are linear (`ponytail:` in the store).
- The 18-decimal constant is assumed, not read from the token (`ponytail:` in `gnus_amounts.dart`).
- The default confirm rejects; nothing can spend until phase 44.

## Known Stubs

None. The provider is intentionally unread until phases 45-47.

## Threat Flags

None beyond the plan's register (T-43-23 to T-43-25 mitigated by guards; T-43-26 accepted).

## Self-Check: PASSED

Commits a2708a9c and f701c01f exist; full suite, analyze, format and brace check green.
