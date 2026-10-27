---
phase: 42-shared-job-submission-off-the-ui-isolate
plan: 02
subsystem: submit-job
tags: [isolate, ffi, genius-api, tests]
requires: ["42-01"]
provides:
  - "GeniusApi.requestGeniusSDKCostAsync / requestGeniusSDKProcessAsync running the FFI call in Isolate.run workers"
  - "Sync requestGeniusSDKCost / requestGeniusSDKProcess deleted"
affects: [43, 48]
tech-stack:
  added: []
  patterns: ["top-level worker entry captures only the job JSON and re-opens the SDK library inside the worker"]
key-files:
  created:
    - test/submit_job/job_off_ui_isolate_test.dart
  modified:
    - packages/genius_api/lib/src/genius_api.dart
    - lib/submit_job/job_submission.dart
    - test/submit_job/submit_job_errors_test.dart
    - test/submit_job/submit_job_outcome_test.dart
    - test/submit_job/job_flow_test.dart
    - test/submit_job/job_submission_test.dart
key-decisions:
  - "Isolate.run, not the spawn plus ReceivePort precedent: a worker throw reaches the awaiting caller instead of hanging the panel"
  - "No Dart-side queue: the SDK serialises job entry points with one global mutex (A1 checked at planning)"
status: complete
actuals:
  tokens: 11000
  tasks: 3
  commits: 3
---

# Phase 42 Plan 02: Job SDK calls off the UI isolate Summary

The SDK cost and process FFI calls now run inside `Isolate.run` workers that re-open the native library themselves; `JobSubmission` awaits only the async versions and the synchronous ones are gone from `GeniusApi`.

## Tasks

| Task | Commit | Notes |
| ---- | ------ | ----- |
| 1 Tracer: price a job off the UI isolate | 58fdc098 | Both async methods and both top-level worker entries, ponytail comment, `cost` on the async call, cost fakes swapped |
| 2 Process a job off the UI isolate | 227e5832 | `submit` on the async process call, four process fakes swapped, outcome-test header comment updated |
| 3 Delete sync calls, add proof tests | 126948de | Sync methods deleted, `job_off_ui_isolate_test.dart` (7 tests) |

## Numbers

- `flutter analyze --no-pub lib test`: exit 0, "No issues found".
- `packages/genius_api` `flutter analyze --no-pub`: exit 0, "No issues found".
- `dart format --set-exit-if-changed`, `tool/check_brace_style.sh`: exit 0. All touched files are LF.
- Full suite: +2692 passed, 6 skipped, 0 failed (42-01 baseline 2685 / 6 / 0; the +7 are the new tests).
- Focused set (`test/submit_job`, dev mock job, compute panel wiring): all passed after each task.

## Existing tests unchanged

The "existing tests unchanged" claim was proven at the 42-01 boundary (no diff against 46d188c4 for the four submit_job test files). This plan edits only fake method signatures in those files, because the synchronous methods they overrode are deleted: the cost and process overrides became async, the process override in `submit_job_outcome_test.dart` keeps a block body, and its header comment names the async method. No assertion, field name or constructor argument changed.

## New test file

`test/submit_job/job_off_ui_isolate_test.dart`:
- Async-only fake that `implements GeniusApi` with a throwing `noSuchMethod`; the owner served cost, gas estimate, burn, process in that order; a real seeded cubit lands `SubmitOutcome.done`.
- `lib/` sweep for `requestGeniusSDK(Cost|Process)(` outside comments. The pattern is checked against positive samples first. `bridge_screen.dart` is not flagged: it calls `bridgeOut` and `getBrigeOutGasCost`, which the pattern does not name.
- genius_api guard: no cost or process FFI call through `_ffiBridgePrebuilt.sgnsLib`, no sync method name, at least two `Isolate.run(`.
- Two "keeps pumping" widget tests (cost pending, process pending): ten fixed 100 ms pumps, a persistent-frame-callback counter advances every pump, `hasScheduledFrame` stays true, a `GWSpinner` stays on screen, and completing the call lands the same state as before.

## Deviations from Plan

**1. [Rule 3 - Blocking] Pending-call signal by polling, not a Completer.** The plan said to wait on a second Completer completed by the fake. A Completer created in the widget-test zone completes its listeners through the fake-async microtask queue, so awaiting it inside `tester.runAsync` never returned (the test hung to its timeout). The test polls `api.served` with a 5 ms real delay inside `runAsync` instead. The process test checks `served` after one `tester.pump()`. Behaviour asserted is unchanged.

**2. Process worker closes over the raw int.** `_geniusSdkProcessOffIsolate` returns `Future<int>`, as `<interfaces>` lists, and `requestGeniusSDKProcessAsync` maps it with `_mapNodeReturnValue` on the main isolate.

No bugs or missing functionality found. No caller of the sync methods existed outside the job flow, so both were deleted.

## Deferred to phase 48

Research Open Question 1 / Pitfall 1: the SDK holds its global mutex for the whole cost call (a live coin-price request) and the whole process call (which re-prices first). The main isolate still makes synchronous SDK calls: `AppBloc`'s 1 s processing-status tick (`lib/bloc/app_bloc.dart:253-259`, `api.getProcessingStatus()`) and the balance reads. A poll that fires while a worker holds the mutex blocks the UI thread until the job call returns. This plan removes the freeze caused by the call itself running on the UI isolate; it does not remove a shorter hitch from a poll landing inside a call. `flutter test` cannot show either. The claim for criterion 3 is therefore limited to "the cost and process calls no longer run on the UI isolate"; the real feel, with the real SDK, is checked only by the phase 48 device walk. Pausing the poll while a job call is in flight would be a separate decision for Braian.

Also accepted (T-42-10): a build pinned to an SDK tag older than 2026-07-13 would link a pre-mutex SDK; `selectGeniusAccountAsync` already carries the same exposure.

## Known Stubs

None.

## Threat Flags

None. The worker closures capture only the job JSON string; no new endpoint, log line or secret handling.

## Self-Check: PASSED

- test/submit_job/job_off_ui_isolate_test.dart: present.
- Commits 58fdc098, 227e5832, 126948de: present.
