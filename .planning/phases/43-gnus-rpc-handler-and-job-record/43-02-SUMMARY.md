---
phase: 43-gnus-rpc-handler-and-job-record
plan: 02
subsystem: gnus_bridge
tags: [gnus-rpc, hive, job-record, idempotency, listJobs, getJob]
requires: [43-01]
provides: [store lookups and paging, gnusJobs box in initHive, gnus_listJobs, gnus_getJob, idempotency replay, in-flight lock]
affects: [43-03, 43-04, 43-05]
key-files: {created: [gnus_job_store_test, gnus_job_store_restart_test, gnus_rpc_jobs_test], modified: [gnus_job_store, gnus_rpc_handler, hive/constants/cache, hive/init, gnus_fakes, gnus_rpc_submit_test]}
decisions: [One origin|idempotencyKey slot is both the global one-burn lock and the retry-of-in-flight check, gnus_getJob returns null when nothing matches (contract silent), Cursor is base64Url of submittedAt micros and burn hash]
status: complete
actuals: {tokens: 45000, tasks: 2, commits: 2}
---

# Phase 43 Plan 02: Job record lookups, idempotency and the in-flight lock

The job record is paged and searchable in a box `initHive` opens. `gnus_listJobs` and `gnus_getJob` answer from it, a repeated idempotency key replays the first reply, and two submits never run at once.

## Tasks
- Task 1, store, box in `initHive`, restart proof: 86196101
- Task 2, listJobs, getJob, idempotency replay, in-flight lock: d863ac11

## What was built
- Store: `GnusJobStore.app()`, `byJobId`, `byIdempotencyKey`, `page`; undecodable values skipped; scan marked `ponytail:`.
- `gnus_listJobs`: limit 1-100 (default 20), cursor at most 512 chars, node-account scoped, bad cursor -32602.
- `gnus_getJob`: exactly one of `jobId`, `burnTxHash`, `idempotencyKey` (1-256 chars); key scoped to origin; found gives Job plus `result: null`.
- Submit: 24 h idempotency lookup (same body replays, other body -32602 `idempotency_key_reused`), in-flight -32005, lock released in `finally`.

## Verification
- `flutter analyze --no-pub lib test` exit 0; format clean; `bash tool/check_brace_style.sh` exit 0; new files LF.
- Full suite +2749 ~6, 0 failed, exit 0 (43-01 end 2717, so +32; original baseline 2693).
- Restart proofs (store and handler level) ran as plain `test()` on a real temp dir.
- Self-Check PASSED: commits 86196101 and d863ac11 exist.

## Deviations and limits
- Rule 1: a cursor time part overflowing `DateTime` would throw `ArgumentError` (-32603); decoder now rejects it as -32602, covered by a store test.
- `gnus_fakes.dart` gained `costThrows` for the "owner threw" lock case.
- Idempotency lookup is not scoped to node account; store growth unbounded here (phase 44 rate limits bound it). No stubs; no new threat flags.
