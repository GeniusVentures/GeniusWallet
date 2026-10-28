---
phase: 43-gnus-rpc-handler-and-job-record
plan: 04
subsystem: gnus_bridge
tags: [gnus-rpc, getAccounts, getEarnings, events, role]
requires: [43-03]
provides: [gnus_getAccounts, gnus_getEarnings, gnusNodeRole, GnusEvent, events and dispose(), accountsChanged/networkChanged/jobUpdated]
affects: [43-05]
key-files: {created: [test/gnus_bridge/gnus_rpc_reads_test.dart, test/gnus_bridge/gnus_rpc_events_test.dart], modified: [lib/gnus_bridge/gnus_rpc_handler.dart, test/gnus_bridge/gnus_fakes.dart]}
decisions: [One payload method serves getAccounts and accountsChanged; cheap state key gates the 1 s processing tick; jobUpdated only on a status change]
status: complete
actuals: {tokens: 60000, tasks: 2, commits: 2}
---

# Phase 43 Plan 04: Identity and earnings reads, and the event stream Summary

The page can read the node, payer and node holdings, and is told once, with the full payload, when the wallet, node account, link, role, switch state or chain changes.

## Tasks
- Task 1, gnus_getAccounts, gnus_getEarnings, readiness rule: b0ae1777. Task 2, event stream: 06259bb9

## What was built

- `gnus_getAccounts`: SDK addresses lowercased; EVM fields only if 40-hex (an `sgnus` wallet gives null `evmAddress`). `canSign` = wallet selected, `walletCanSign`, gate not `child`. During a switch: `switching: true`, all other methods -32015.
- `gnusNodeRole` (pure), `gnus_getEarnings` (base-unit balance, `jobsProcessed` and `earned.*` null, bad balance -32603), and the events with a construction baseline, serial recomputes and idempotent `dispose()`.

## Verification

- `flutter analyze --no-pub lib test`: exit 0, no issues. `dart format --set-exit-if-changed` clean; `bash tool/check_brace_style.sh` exit 0; new files LF.
- Full suite: +2805 ~6, 0 failed, exit 0. Start 2772, so +33 here (20 reads, 13 events).

## Deviations from Plan
- `appStates` and `registrationChanges` were added in Task 2, not Task 1, to avoid an unused required parameter for one commit. The harness gained `pushApp` and `registrationChanges` and disposes its handlers.

## Known limits
- `isProcessing` is false both when idle and when the feed never ticked or is down (`ponytail:` on `_getEarnings`).
- `gnus_networkChanged` never reports an SDK-side change in a session (applies after restart); not faked. `canSign` follows the gate's `child` state; no event when only the gate changes. `disconnect` belongs to the transports (phases 45-47).

No stubs; no threat flags beyond T-43-19 to T-43-22 (mitigated). Self-Check PASSED: commits b0ae1777 and 06259bb9 exist; suite and analyze green.
