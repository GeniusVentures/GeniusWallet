---
phase: 44-dashboard-consent-and-limits
plan: 01
subsystem: gnus-bridge
tags: [consent, hive, rpc]
requires: []
provides: [GnusConnectionStore, showGnusConnectPrompt, GnusConnect seam]
affects: [lib/gnus_bridge/gnus_rpc_handler.dart, lib/main.dart]
key-files:
  created: [lib/gnus_bridge/gnus_connection_store.dart, lib/gnus_consent/gnus_prompts.dart]
  modified: [lib/gnus_bridge/gnus_rpc_handler.dart, lib/reown/approve_transaction_drawer.dart, lib/hive/init.dart, lib/main.dart]
status: complete
actuals: {tokens: 60000, tasks: 3, commits: 3}
---

# Phase 44 Plan 01: Connect prompt Summary

An origin's first `gnus_*` call opens a drawer titled with that origin; Approve stores it in Hive until revoked, and every method checks it after its params and before readiness.

## Baseline (before the first change)
- `flutter test test/gnus_bridge`: 190 passed. Full suite: 2925 passed, 9 skipped, 0 failed.
- After: `test/gnus_bridge` 199 passed, `test/gnus_consent` 3 passed.

## Commits
- 18e2d200 tracer: store, `_requireConnected` on getAccounts, connect drawer, harness `connect`
- 9a1ca13d the check on all six methods (8 tests in `gnus_connection_test.dart`)
- d0312064 `gnusConnections` box at startup, handler wiring, guards, restart test

## Decisions
- Key is sha256 of the exact origin; an unreadable value is not connected.
- Declines, timeouts and a throwing seam answer 4001. A failed write answers -32603.
- The confirm stays at its rejecting default; `connect: showGnusConnectPrompt` is wired.
- Tracer gate: its verify passed (3 widget tests) before the other tasks, run unattended as asked.

## Deviations
- The drawer's own app-bar title is the origin and may ellipsize; the full origin is on the wrapping site line under it, which the test asserts.
- Harness `connections` is a non-final `late` field so a test can swap in a failing store.

## Self-Check: PASSED (no known stubs)
