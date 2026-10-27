---
phase: 43-gnus-rpc-handler-and-job-record
plan: 02
subsystem: gnus_bridge
tags: [gnus-rpc, hive, job-record, idempotency, listJobs, getJob]
requires: [43-01]
provides:
  - GnusJobStore lookups (byJobId, byIdempotencyKey) and cursor paging
  - gnusJobs Box<String> opened in initHive
  - gnus_listJobs and gnus_getJob
  - idempotency replay and the single in-flight submit lock
affects: [43-03, 43-04, 43-05]
key-files:
  created:
    - test/gnus_bridge/gnus_job_store_test.dart
    - test/gnus_bridge/gnus_job_store_restart_test.dart
    - test/gnus_bridge/gnus_rpc_jobs_test.dart
  modified:
    - lib/gnus_bridge/gnus_job_store.dart
    - lib/gnus_bridge/gnus_rpc_handler.dart
    - lib/hive/constants/cache.dart
    - lib/hive/init.dart
    - test/gnus_bridge/gnus_fakes.dart
    - test/gnus_bridge/gnus_rpc_submit_test.dart
decisions:
  - One string slot (origin|idempotencyKey) is both the global one-burn lock and the retry-of-in-flight check
  - gnus_getJob returns null (EIP-1193 style) when nothing matches; the contract text is silent
  - Cursor is base64Url of "<submittedAt micros>|<lowercased burn hash>", bounded to DateTime's range
status: complete
actuals:
  tokens: 45000
  tasks: 2
  commits: 2
---

# Phase 43 Plan 02: Job record lookups, idempotency and the in-flight lock Summary

The wallet's job record is now paged, searchable and stored in a box `initHive` opens; `gnus_listJobs` and `gnus_getJob` answer from it, a repeated idempotency key replays the first reply without a second burn, and two submits can never run at once.

## Tasks

| Task | Name | Commit |
| ---- | ---- | ------ |
| 1 | Finish the store, open its box at startup, prove a restart | 86196101 |
| 2 | listJobs, getJob, idempotency replay, in-flight lock | d863ac11 |

## What was built

- Store: `GnusJobStore.app()`, `byJobId`, `byIdempotencyKey(origin, key, notBefore:)`, `page(...)` newest first by time then burn hash, strictly-after cursor, `nextCursor` only when more remain. A value that fails decode is skipped and counted in one log line (count only). The linear scan carries a `ponytail:` comment.
- `gnusJobsBoxName` in `cache.dart`; `Hive.openBox<String>(gnusJobsBoxName)` joins the `Future.wait` in `initHive`. No adapter, no typeId.
- `gnus_listJobs`: `limit` int or integral double 1-100 (default 20), `cursor` non-empty at most 512 characters, node account scoped, bad cursor is -32602.
- `gnus_getJob`: exactly one non-null of `jobId`, `burnTxHash`, `idempotencyKey` (each non-empty, at most 256 characters, no hex check so dev fixture hashes work); idempotency key scoped to the caller's origin; another node account's record is not found; found gives the `Job` plus `result: null`.
- Submit order: validate, switching and readiness, retry-of-in-flight check, idempotency lookup within 24 h (same body hash replays the record, other hash is -32602 `idempotency_key_reused`), any-in-flight check, lock set synchronously, existing gate, price, gas, confirm, burn and record, lock released in `finally`.

## Numbers

- `flutter analyze --no-pub lib test`: exit 0, no issues.
- `dart format --set-exit-if-changed` clean, `bash tool/check_brace_style.sh` exit 0, new files LF.
- Full suite: +2749 ~6, 0 failed, exit 0. Baseline 2693 (43-01 end: 2717), so +32 in this plan.
- Restart proofs ran as plain `test()` on a real temp directory: store level and handler level.

## Deviations from Plan

- Rule 1 (bug found before it shipped): a cursor whose time part overflows `DateTime`'s range would have thrown `ArgumentError` and surfaced as -32603. The decoder now rejects it as `FormatException` (-32602); the store test covers it.
- `gnus_fakes.dart` gained `costThrows` on the fake API for the "owner threw" lock case. The clock was already advanceable and the harness already accepted an existing box, so no further harness change was needed.

## Known limits

- The idempotency lookup is not scoped to the node account, so a replay after an account switch returns the first call's record as it was; this matches "first call's result".
- Store growth is unbounded here; phase 44 rate limits bound it.

## Known Stubs

None.

## Threat Flags

None beyond the plan's register (T-43-08 to T-43-13 mitigated or accepted as planned).

## Self-Check: PASSED

Commits 86196101 and d863ac11 exist; full suite and analyze green.
