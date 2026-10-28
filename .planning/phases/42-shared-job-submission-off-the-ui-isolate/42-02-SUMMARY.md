---
phase: 42-shared-job-submission-off-the-ui-isolate
plan: 02
subsystem: submit-job
tags: [isolate, ffi, genius-api, tests]
requires: ["42-01"]
provides: ["requestGeniusSDKCostAsync / requestGeniusSDKProcessAsync via Isolate.run workers", "sync cost/process deleted"]
affects: [43, 48]
tech-stack: {added: [], patterns: ["top-level worker entry captures only the job JSON and re-opens the SDK library"]}
key-files:
  created: [test/submit_job/job_off_ui_isolate_test.dart]
  modified: [packages/genius_api/lib/src/genius_api.dart, lib/submit_job/job_submission.dart, test/submit_job/submit_job_errors_test.dart, test/submit_job/submit_job_outcome_test.dart, test/submit_job/job_flow_test.dart, test/submit_job/job_submission_test.dart]
key-decisions: ["Isolate.run, not spawn plus ReceivePort: a worker throw reaches the caller instead of hanging the panel", "No Dart-side queue: SDK serialises job entry points with one global mutex (A1 checked at planning)"]
status: complete
actuals: {tokens: 11000, tasks: 3, commits: 3}
---

# Phase 42 Plan 02: Job SDK calls off the UI isolate Summary

SDK cost and process FFI calls now run in `Isolate.run` workers that re-open the native library; `JobSubmission` awaits only the async versions; the sync ones are gone from `GeniusApi`.

## Tasks
- Task 1, tracer: price off the UI isolate. Commit 58fdc098.
- Task 2, process off the UI isolate; four process fakes swapped. Commit 227e5832.
- Task 3, sync methods deleted; `job_off_ui_isolate_test.dart` added (7 tests: async-only fake, lib/ sweep, genius_api guard, two "keeps pumping" widget tests). Commit 126948de.

## Numbers
- `flutter analyze --no-pub lib test` and `packages/genius_api` analyze: exit 0, "No issues found".
- `dart format --set-exit-if-changed`, `tool/check_brace_style.sh`: exit 0. Touched files LF.
- Full suite: +2692 passed, 6 skipped, 0 failed (42-01 baseline 2685 / 6 / 0; +7 are the new tests). Focused set (`test/submit_job`, dev mock job, compute panel wiring) passed after each task.
- Existing tests unchanged: only fake method signatures changed (no diff against 46d188c4 at the 42-01 boundary); no assertion, field or constructor argument changed.

## Deviations from Plan
1. [Rule 3 - Blocking] Pending-call signal by polling `api.served` (5 ms real delay inside `runAsync`), not a Completer: a Completer made in the widget-test zone hung inside `tester.runAsync`. Asserted behaviour unchanged.
2. `_geniusSdkProcessOffIsolate` returns `Future<int>`; mapping runs on the main isolate. No sync caller existed outside the job flow, so both were deleted.

## Deferred to phase 48
The SDK holds its global mutex for the whole cost and process call. Main-isolate sync SDK calls (`AppBloc` 1 s status tick, `lib/bloc/app_bloc.dart:253-259`; balance reads) can still hitch the UI when they land inside a job call; `flutter test` cannot show it. Claim limited to "cost and process calls no longer run on the UI isolate"; real feel is a phase 48 device walk. Pausing the poll is Braian's call. Accepted (T-42-10): a build pinned to an SDK tag older than 2026-07-13 links a pre-mutex SDK.

Known stubs and threat flags: none. Self-check passed: test file and commits 58fdc098, 227e5832, 126948de present.
