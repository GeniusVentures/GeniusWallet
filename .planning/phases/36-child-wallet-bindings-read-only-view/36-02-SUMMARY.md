---
phase: 36-child-wallet-bindings-read-only-view
plan: 02
subsystem: api
requires:
  - phase: 36-01
    provides: "GetRegistrationsForMain/GetChildBalanceAll bindings, ChildRegistration/ChildRegistrations, collectChildRegistrations"
provides:
  - "All 12 child-wallet symbols bound in genius_api_ffi.dart; GENIUS_NODE_ERROR_REGISTRATION(7) mapped everywhere the enum is exhaustively switched"
  - "writeRegistrationMetadata/writeTokenValue/uint64Arg boundary-check every string and amount before any native call"
  - "Ten GeniusApi wrappers (registerChild, getChildBalance, fund/recoverFromChild in both amount shapes, detachChild, replaceMain, revokeChild, getPubSubHandle) bound and wrapped, no UI caller yet"
affects: [37-child-write-operations]
key-files:
  modified: [packages/genius_api/lib/ffi/genius_api_ffi.dart, packages/genius_api/lib/src/genius_api.dart, lib/submit_job/cubit/submit_job_cubit.dart, test/ffi/child_wallet_ffi_test.dart]
key-decisions:
  - "ChildRegistrationMetadata.peersCut stores the raw uint64 bits unchecked; only the three metadata strings are length-validated"
requirements-completed: [CHILD-01]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 36 Plan 02: Child wallet bindings & read-only view Summary

**All 12 child-wallet SDK symbols bound and wrapped in plain Dart values, with metadata/amount length checked at the boundary before any native call — no UI caller yet.**

## Accomplishments
- Ten remaining bindings (GetPubSub, RegisterChild, GetChildBalance, Fund/RecoverFromChild(GNUS), DetachChild, ReplaceMain, RevokeChild) spliced into `NativeLibrary`, plus `GENIUS_NODE_ERROR_REGISTRATION(7)`
- `writeRegistrationMetadata`/`writeTokenValue` reject over-long UTF-8 before writing anything; `uint64Arg` rejects outside `0..2^64-1`; the shared char-array reader is byte-masked UTF-8 so a non-ASCII field never throws
- Ten `GeniusApi` wrappers return plain Dart values and `NOT_INITIALIZED`/zero/null when the SDK isn't up; a `lib/` grep proves none has a UI caller

## Verification
No deviations from the plan. Full suite: 2008 passed / 5 skipped / 0 failed (baseline 2000 + 8 new). `flutter analyze lib test`: 0 issues. Package-scoped analyze on the two genius_api files: exactly 109 pre-existing warnings, none new. Format, brace-style, ID-identifier gate and key-logging checks all clean.
