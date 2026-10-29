---
phase: 43-gnus-rpc-handler-and-job-record
plan: 05
subsystem: gnus_bridge
tags: [gnus-rpc, wiring, guards, contract, phase-gate]
requires: [43-04]
provides: [RepositoryProvider<GnusRpcHandler> with rejecting confirm, source guards, two-transport matrix]
affects: [44, 45, 46, 47]
key-files: {created: [test/gnus_bridge/gnus_rpc_guards_test.dart, test/gnus_bridge/gnus_rpc_contract_test.dart], modified: [lib/main.dart, .planning/research/v4.0-gnus-rpc-contract.md]}
decisions: [Private GnusCubit closed in provider dispose via an Expando, Provider sits in the existing MultiBlocProvider list]
status: complete
actuals: {tokens: 55000, tasks: 2, commits: 2}
---

# Phase 43 Plan 05: Wiring, guards and the contract matrix Summary

One lazy `GnusRpcHandler` provider with no confirm argument, so nothing can spend until phase 44; guards and a 53-case two-transport matrix lock that in. Commits: a2708a9c (wiring and guards), f701c01f (matrix, contract text, phase gate).

## What was built

- `lib/main.dart`: provider after `BridgeGateCubit`; private `GnusCubit` closed with the handler.
- Guards: handler args name no `confirm`, name `GnusJobStore.app()`; `gnusJobsBoxName` opened as `Box<String>`; no burn, gas, cost or process calls, no `Hive` outside the store, no Flutter UI imports in `lib/gnus_bridge`; every `gnus_rpc ` log line fixed-shape, no sentinel or burn hash.
- Matrix: 4200, -32602, 4900, -32015, -32010 and valid calls, deep-equal on direct and JSON harnesses; no reply has `"cost":"0"`.
- Contract edits (D, 2026-10-27): estimate `balance` null, getJob null and same-origin lookup, listJobs current account, job record states, `data.reason` table. Mirror copy verified with `cmp`.

## Phase gate

- `dart format --set-exit-if-changed` over the phase dirs: exit 0. `bash tool/check_brace_style.sh`: exit 0. `flutter analyze --no-pub lib test`: exit 0.
- Full suite +2866 ~6, 0 failed, exit 0; 43-01 baseline 2693, so +173 for the phase.
- Per plan: 43-01 +24, 43-02 +32, 43-03 +23, 43-04 +33, 43-05 +61 (8 guards, 53 matrix).
- `git ls-files --eol`: tracked files `i/lf`; two new files `w/lf`.

## Known limits (no deviations from plan)

- Live cost is -32010 until SDK-CA; `isProcessing` false while the feed is down (`ponytail:`).
- Window close during the burn itself uncovered (Phase 42 `ponytail:`); linear scans and the 18-decimal constant (`ponytail:`).

## Threat Flags / Self-Check

None beyond the plan's register (T-43-23 to T-43-25 mitigated, T-43-26 accepted). Self-Check PASSED: both commits exist, gate green.
