---
phase: 42-shared-job-submission-off-the-ui-isolate
plan: 01
subsystem: submit-job
tags: [refactor, cubit, dev-fixture, sealed-results]
requires: []
provides: ["JobSubmission owner (cost, estimateGas, submit), sealed results, one dev gate"]
affects: [42-02, 43]
tech-stack: {added: [], patterns: ["plain owner class + sealed results; cubit keeps state, emits, copy"]}
key-files:
  created: [lib/submit_job/job_submission.dart, test/submit_job/job_submission_test.dart]
  modified: [lib/submit_job/cubit/submit_job_cubit.dart, lib/dev/dev_mock_job.dart]
key-decisions:
  - "Cost 0 is JobCostFailed in the owner; cubit jobCost is 0 either way"
  - "Optional injected JobSubmission on the cubit; call sites untouched"
status: complete
actuals: {tokens: 14000, tasks: 3, commits: 2}
---
# Phase 42 Plan 01: Shared job submission owner Summary
`JobSubmission` now makes the burn, gas estimate, SDK cost and SDK process calls and holds the dev fixture behind one gate; `SubmitJobCubit` keeps every emit, string and the double-submit guard.
## Baseline
Base SHA 46d188c4efb1f6f20e0debff0f1d67db20d2e939; Flutter 3.41.9 / Dart 3.11.5; submodules initialised, pub get at root and packages/genius_api, tree clean.
- Analyze `lib test` and `packages/genius_api`: exit 0, no issues. `tool/check_brace_style.sh`: exit 0.
- Full suite: exit 0, +2663, 6 skipped, 0 failed. Focused set (`test/submit_job`, `test/dev/dev_mock_job_test.dart`, `test/dashboard/compute_panel_wiring_test.dart`): +90, 0 failed.
## After
- Analyze `lib test`: exit 0, no issues (exit-0 rule applied). `dart format --set-exit-if-changed` and brace check: exit 0. New files LF.
- Full suite: exit 0, +2685, 6 skipped, 0 failed (+22 new owner tests). Focused set: +112, 0 failed.
- The four existing submit_job test files and `dev_mock_job_test.dart` have no diff against 46d188c4.
## Tasks
- Task 0 Baseline: no commit (no tracked file changed).
- Task 1 Tracer, submit through owner: 7b273824 (JobFacts, JobSubmitResult family, gate, submit, devSubmitResult).
- Task 2 Cost, gas, boundary guard: 61615ca6 (JobCostResult, GasEstimateResult, cost, estimateGas, dev_mock_job.dart comments).
## Deviations from Plan
- "Success with null data" cases for burn and gas not written: `ApiResponse` cannot build that state, so the branch is untestable; the check is kept.
- Branch `claude/gsd-dashboard-bridge-milestone-b6a5e7` is outside the `agent-*` pre-commit namespace; committed on it as instructed (not protected).
## Notes for plan 02
- `lib/dashboard/bridge/bridge_screen.dart` (lines 371, 551) calls `bridgeOut` and `getBrigeOutGasCost` directly: the user-facing token bridge, not the job flow. The D-06 `lib/` sweep must exclude or decide on it.
- Dev pricing awaits the owner before its single emit (one extra microtask); untested since the gate is closed under `flutter test`.
No known stubs, threat flags, bugs or blockers. Self-Check PASSED: both new files and commits 7b273824, 61615ca6 present.
