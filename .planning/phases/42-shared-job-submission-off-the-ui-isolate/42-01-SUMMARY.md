---
phase: 42-shared-job-submission-off-the-ui-isolate
plan: 01
subsystem: submit-job
tags: [refactor, cubit, dev-fixture, sealed-results]
requires: []
provides:
  - "JobSubmission owner (cost, estimateGas, submit) with sealed results and the one dev gate"
affects: [42-02, 43]
tech-stack:
  added: []
  patterns: ["plain owner class + sealed typed results; cubit keeps state, emits and copy"]
key-files:
  created:
    - lib/submit_job/job_submission.dart
    - test/submit_job/job_submission_test.dart
  modified:
    - lib/submit_job/cubit/submit_job_cubit.dart
    - lib/dev/dev_mock_job.dart
key-decisions:
  - "Cost of 0 is JobCostFailed in the owner; the cubit's int jobCost is 0 either way, so no visible change"
  - "Optional injected JobSubmission on the cubit, defaulting to JobSubmission(geniusApi: geniusApi); constructor call sites untouched"
status: complete
actuals:
  tokens: 14000
  tasks: 3
  commits: 2
---

# Phase 42 Plan 01: Shared job submission owner Summary

One `JobSubmission` owner now makes the burn, gas estimate, SDK cost and SDK process calls and holds the dev fixture behind a single gate; `SubmitJobCubit` keeps every emit, string and the double-submit guard.

## Baseline

Measured on this branch before any code change. Base SHA: 46d188c4efb1f6f20e0debff0f1d67db20d2e939.

- Submodules initialised over the existing HTTPS rewrite; `flutter pub get` at root and in packages/genius_api; `git status --porcelain` empty afterwards (no tracked file changed).
- Flutter 3.41.9 / Dart 3.11.5.
- `flutter analyze --no-pub lib test`: exit 0, "No issues found".
- `packages/genius_api` `flutter analyze --no-pub`: exit 0, "No issues found".
- `bash tool/check_brace_style.sh`: exit 0.
- `flutter test --no-pub --reporter failures-only` (full suite): exit 0, +2663 passed, 6 skipped, 0 failed.
- Focused set (`test/submit_job test/dev/dev_mock_job_test.dart test/dashboard/compute_panel_wiring_test.dart`): +90 passed, 0 failed.

## After

- `flutter analyze --no-pub lib test`: exit 0, "No issues found" (the exit-0 rule applied; baseline was 0).
- `flutter test --no-pub --reporter failures-only`: exit 0, +2685 passed, 6 skipped, 0 failed (+22 are the new owner tests).
- Focused set: +112 passed, 0 failed.
- `dart format --set-exit-if-changed`, `tool/check_brace_style.sh`: exit 0. New files are LF.
- The four existing submit_job test files and `test/dev/dev_mock_job_test.dart` have no diff against 46d188c4.

## Tasks

| Task | Commit | Notes |
| ---- | ------ | ----- |
| 0 Baseline | none (no tracked file changed) | Baseline section above |
| 1 Tracer: submit through the owner | 7b273824 | JobFacts, JobSubmitResult family, devToolsEnabled/devScenario, submit, devSubmitResult |
| 2 Cost and gas through the owner, boundary guard | 61615ca6 | JobCostResult, GasEstimateResult, cost, estimateGas, dev_mock_job.dart comments |

## Interface notes

Names match the plan's `<interfaces>` block with no changes. The bridge destination chain id is one private constant in the owner.

## Deviations from Plan

- Test case "success with null data" for the burn and the gas estimate is not written: `ApiResponse` has no public way to build a success with null data, so that branch is unreachable from a test. The `!isSuccess || data == null` check is kept as it was.
- Task 1 tracer gate: no separate checkpoint; the focused tests were re-run end to end after the tracer commit and passed.
- Branch-name pre-commit guard: the worktree branch `claude/gsd-dashboard-bridge-milestone-b6a5e7` is not in the `agent-*` namespace; commits were made on it as instructed by the orchestrator. It is not a protected branch.

No bugs, missing functionality or blockers found.

## Notes for plan 02

- `lib/dashboard/bridge/bridge_screen.dart` (lines 371 and 551) calls `bridgeOut` and `getBrigeOutGasCost` directly. That is the user-facing token bridge, not the job flow, so it is out of this plan; a `lib/` sweep for D-06 must exclude or decide on it.
- Dev pricing now awaits the owner before its single emit (one extra microtask); the gate is closed under `flutter test`, so this is not covered by tests.

## Known Stubs

None.

## Threat Flags

None. No new endpoint, log line or secret handling.

## Self-Check: PASSED

- lib/submit_job/job_submission.dart, test/submit_job/job_submission_test.dart: present.
- Commits 7b273824 and 61615ca6: present.
