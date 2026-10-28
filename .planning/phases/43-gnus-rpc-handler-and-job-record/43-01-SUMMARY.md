---
phase: 43-gnus-rpc-handler-and-job-record
plan: 01
subsystem: gnus_bridge
tags: [gnus-rpc, handler, hive, job-record, submit]
requires: [42-shared-job-submission-off-the-ui-isolate]
provides: [GnusRpcHandler.handle with gnus_submitJob, contract constants and gnusErrorForGate, GnusJobStore put/byBurnHash, JobSubmission.submit(onBurned:)]
affects: [43-02, 43-03, 43-04, 43-05]
key-files:
  created: [lib/gnus_bridge/gnus_rpc_contract.dart, gnus_amounts.dart, gnus_job_store.dart, gnus_rpc_handler.dart, test/gnus_bridge/gnus_fakes.dart, gnus_rpc_submit_test.dart]
  modified: [lib/submit_job/job_submission.dart, test/submit_job/job_submission_test.dart]
decisions: [Job record is JSON in one Hive Box<String> keyed by lowercased burn hash, Owner onBurned writes bridgedNotProcessed then final status overwrites, GNUS decimals one constant (18) with ponytail comment]
status: complete
actuals: {tokens: 60000, tasks: 3, commits: 2}
---
# Phase 43 Plan 01: gnus_submitJob tracer and the owner's onBurned Summary
A `gnus_submitJob` call runs through a transport-independent handler, the bridge gate, the Phase 42 `JobSubmission` owner and a reject-by-default confirm, and leaves a job record written before the process call.
## Baseline
Measured 2026-10-27 at base SHA `e2b8bd31cd8197fcc8b14ca5f6a42c4155220bb4`: analyze exit 0 (no issues); brace check exit 0; full suite exit 0, +2693 ~6, 0 failed; focused set +235 passed; tree clean.
## Tasks
- Task 0: baseline re-measured, no commit.
- Task 1 (58a7085c): contract, amounts, store, handler, fakes with both transports, 20 handler tests (deep-equal on both transports for happy path, 4200, -32602, -32015, 4900, -32010, -32013).
- Task 2 (1b219993): owner `onBurned` (awaited, throw logged and ignored), 4 owner tests.
## Numbers
- Analyze exit 0, no issues (baseline rule met); format clean; brace check exit 0; new files LF (`i/lf`).
- Full suite exit 0, +2717 ~6, 0 failed (baseline 2693, +24: 20 handler, 4 owner). Focused set +144.
- Neutrality: `git diff --exit-code e2b8bd31` over the five panel test files and `submit_job_cubit.dart` exits 0.
## Deviations from Plan
- Task 2 neutrality diff used `e2b8bd31` instead of the stale `c3fb0a76`.
- Handler also uses reason `account_changed` (-32603) when the network changes during the token-info fetch; fail-closed, 43-03 can reuse it.
- Executor branch allow-list (`agent-*`) did not match `claude/gsd-dashboard-bridge-milestone-b6a5e7`; committed there on the orchestrator's instruction.
## Known limits
- A window close during the burn, before `onBurned`, is uncovered (Pitfall 6; Phase 42 `ponytail:` in `genius_api.dart`).
- Other methods return 4200 until 43-02 to 43-04; no amount-based -32011 until 43-03. No stubs; no threat flags beyond T-43-01 to T-43-07.
## Self-Check: PASSED
Files and commits 58a7085c, 1b219993 exist; full suite and analyze green.
