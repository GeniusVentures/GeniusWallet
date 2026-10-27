## Baseline

Measured 2026-10-27 at base SHA `e2b8bd31cd8197fcc8b14ca5f6a42c4155220bb4` (branch claude/gsd-dashboard-bridge-milestone-b6a5e7), before any code change.

- `flutter analyze --no-pub lib test`: exit 0, "No issues found".
- `bash tool/check_brace_style.sh`: exit 0.
- Full suite `flutter test --no-pub --reporter failures-only`: exit 0, +2693 ~6, 0 failed.
- Focused set (test/submit_job, test/dev/dev_mock_job_test.dart, test/dashboard/compute_panel_wiring_test.dart, test/dashboard/bridge): +235, all passed.
- Worktree: `.dart_tool/package_config.json` present, submodules initialised, tree clean.

---
phase: 43-gnus-rpc-handler-and-job-record
plan: 01
subsystem: gnus_bridge
tags: [gnus-rpc, handler, hive, job-record, submit]
requires: [42-shared-job-submission-off-the-ui-isolate]
provides:
  - GnusRpcHandler.handle(origin, method, params) with the gnus_submitJob path
  - contract constants, GnusRpcError and gnusErrorForGate
  - GnusJobStore over Box<String> (put, byBurnHash)
  - JobSubmission.submit(onBurned:)
affects: [43-02, 43-03, 43-04, 43-05]
key-files:
  created:
    - lib/gnus_bridge/gnus_rpc_contract.dart
    - lib/gnus_bridge/gnus_amounts.dart
    - lib/gnus_bridge/gnus_job_store.dart
    - lib/gnus_bridge/gnus_rpc_handler.dart
    - test/gnus_bridge/gnus_fakes.dart
    - test/gnus_bridge/gnus_rpc_submit_test.dart
  modified:
    - lib/submit_job/job_submission.dart
    - test/submit_job/job_submission_test.dart
decisions:
  - Job record is a JSON string in one Hive Box<String> keyed by the lowercased burn hash; no adapter or typeId
  - The record is written by the owner's onBurned as bridgedNotProcessed, then overwritten with the final status
  - GNUS decimals are one named constant (18) in gnus_amounts.dart with a ponytail comment
status: complete
actuals:
  tokens: 60000
  tasks: 3
  commits: 2
---

# Phase 43 Plan 01: gnus_submitJob tracer and the owner's onBurned Summary

A `gnus_submitJob` call now runs through a transport-independent handler, the bridge gate, the Phase 42 `JobSubmission` owner and an injected confirm that defaults to reject, and leaves a persisted job record written before the process call.

## Tasks

| Task | Name | Commit |
| ---- | ---- | ------ |
| 0 | Re-measure the baseline | none (Baseline section above) |
| 1 | gnus_submitJob end to end, one path | 58a7085c |
| 2 | Record the burn before the process call | 1b219993 |

## What was built

- `gnus_rpc_contract.dart`: `GnusRpcError`, every code, method, event name and reason, `kGnusRpcVersion`, and `gnusErrorForGate` as an exhaustive switch (no default). `checking` refuses.
- `gnus_amounts.dart`: `kGnusDecimals = 18` (ponytail), `gnusCostBaseUnits` (BigInt), `gnusGasPrice` (rejects the literal `null Gwei`).
- `gnus_job_store.dart`: `GnusJob`, `GnusJobStatus`, `gnusJobBodyHash` (key-sorted sha256), `GnusJobStore.put` and `byBurnHash`. `decode` returns null on any malformed value.
- `gnus_rpc_handler.dart`: dispatch, param validation (job object with 5 MiB cap, key at most 128 characters), switching then readiness, gate with `fresh: true` before any pricing, cost, gas, confirm, submit, exhaustive mapping of `JobSubmitResult`. Every call logs one `gnus_rpc <method> <origin> <code or ok>` line. Non-`GnusRpcError` exceptions become a fixed `Internal error`, logged by `runtimeType` only.
- Test fakes (`FakeGnusApi`, `SeededGnusCubit`, `GnusHarness`, `viaDirect`, `viaJson`) and 20 handler tests; both transports return deep-equal replies for the happy path and for 4200, -32602, -32015, 4900, -32010 and -32013.
- `JobSubmission.submit(onBurned:)`: awaited after a successful burn and before Process; a throw is logged as `onBurned failed: <runtimeType>` and Process still runs. Four owner tests.

## Numbers

- `flutter analyze --no-pub lib test`: exit 0, no issues (baseline rule: exit 0 required, met).
- `dart format --set-exit-if-changed` clean; `bash tool/check_brace_style.sh` exit 0; new files LF (`git ls-files --eol` shows `i/lf`).
- Full suite: +2717 ~6, 0 failed, exit 0. Baseline 2693, so +24 new tests (20 handler, 4 owner).
- Focused set (gnus_bridge, submit_job, dev_mock_job, compute_panel_wiring): +144 pass.
- Neutrality: `git diff --exit-code e2b8bd31` over the five panel test files and `submit_job_cubit.dart` exits 0.

## Deviations from Plan

- Task 2's `git diff` baseline used `e2b8bd31` (Task 0 base SHA) instead of the stale `c3fb0a76`, as the checker note directed.
- The plan listed `account_changed` for plan 43-03 only. The handler also uses it (as -32603 reason) when the selected network changes while the token info is being fetched, so the facts and the gate describe one moment. Cheap and fail-closed; plan 43-03 can reuse the same reason after the confirm.
- Commit guard: the executor's branch allow-list (`agent-*`) does not match this worktree's branch `claude/gsd-dashboard-bridge-milestone-b6a5e7`; the orchestrator named this branch for commits and it is not a protected ref, so commits were made on it.

## Known limits

- A window close during the burn itself, before `onBurned` runs, is still uncovered (research Pitfall 6). Phase 42's `ponytail:` in `genius_api.dart` already names it.
- Methods other than `gnus_submitJob` return 4200 until plans 43-02 to 43-04 add them.
- No affordability check (-32011 by amount) yet; plan 43-03 adds it.

## Known Stubs

None.

## Threat Flags

None beyond the plan's threat model (T-43-01 to T-43-07 mitigated or transferred as planned).

## Self-Check: PASSED

Files exist, commits 58a7085c and 1b219993 exist, full suite and analyze green.
