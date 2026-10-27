---
phase: 43-gnus-rpc-handler-and-job-record
plan: 04
subsystem: gnus_bridge
tags: [gnus-rpc, getAccounts, getEarnings, events, role]
requires: [43-03]
provides:
  - gnus_getAccounts and gnus_getEarnings
  - gnusNodeRole (pure) and GnusEvent
  - GnusRpcHandler.events (broadcast) and dispose()
  - gnus_accountsChanged, gnus_networkChanged and gnus_jobUpdated
affects: [43-05]
key-files:
  created:
    - test/gnus_bridge/gnus_rpc_reads_test.dart
    - test/gnus_bridge/gnus_rpc_events_test.dart
  modified:
    - lib/gnus_bridge/gnus_rpc_handler.dart
    - test/gnus_bridge/gnus_fakes.dart
decisions:
  - One private payload method serves gnus_getAccounts and the accountsChanged event, so the two cannot drift
  - A cheap state key (accounts, links, SDK readiness, wallet address and type, chain id) gates every app or wallet emission; the 1 s processing tick never reaches the registrations reader
  - A node that stops being ready clears the last payload, so its return is announced even if the payload is identical
  - jobUpdated fires only when a stored record's status changes; the first write of a record is not a change
status: complete
actuals:
  tokens: 60000
  tasks: 2
  commits: 2
---

# Phase 43 Plan 04: Identity and earnings reads, and the event stream Summary

The page can read who the node and the payer are and what the node holds, and the handler now tells it once, with the full payload, when the wallet, node account, link, role, switch state or chain changes.

## Tasks

| Task | Name | Commit |
| ---- | ---- | ------ |
| 1 | gnus_getAccounts, gnus_getEarnings and the readiness rule on every method | b0ae1777 |
| 2 | The event stream: accountsChanged, networkChanged, jobUpdated | 06259bb9 |

## What was built

- `gnus_getAccounts`: node `{sdkAddress, linkedEvm, role, main}`, payer `{evmAddress, canSign}`, `switching`, network, version `"1"`, unit `{GNUS, 18}`. SDK addresses are lowercased; EVM fields are kept only if they match the 40-hex form, so an `sgnus` wallet row gives a null `evmAddress`. `canSign` = a wallet is selected, `walletCanSign`, and the (non-fresh) gate is not `child`. During a switch it answers `switching: true`; every other method answers -32015.
- `gnusNodeRole`: pure, lowercased, child before main, null registrations mean none.
- `gnus_getEarnings`: balance in base units through `sgnusBalanceBaseUnits`, `isProcessing` from AppState, `jobsProcessed`, `earned.total` and `earned.history` null. `includeChildren` accepted (bool only) and ignored. An unparseable SDK balance is -32603 `balance_unavailable`.
- Events: subscriptions on the app bloc, the wallet details cubit and the child-registration stream; baseline taken at construction without emitting; recomputes run one at a time; `dispose()` is idempotent.

## Numbers

- `flutter analyze --no-pub lib test`: exit 0, no issues.
- `dart format --set-exit-if-changed` clean, `bash tool/check_brace_style.sh` exit 0, new files LF.
- Full suite: +2805 ~6, 0 failed, exit 0. Start 2772, so +33 in this plan (20 reads, 13 events).

## Deviations from Plan

- The constructor parameters `appStates` and `registrationChanges` were added in Task 2 rather than Task 1, because Task 1 had no use for them and an unused required parameter would have been dead code for one commit. The harness gained `pushApp` and `registrationChanges` at the same time.
- The harness now tracks every handler it builds and disposes them in `dispose()`.

## Known limits

- `isProcessing` is false both when the node is idle and while the processing feed has never ticked or is down; recorded as a `ponytail:` on `_getEarnings`.
- `gnus_networkChanged` never reports an SDK-side change inside a session (the SDK net applies only after a restart); not faked.
- `canSign` follows the gate's `child` state, which comes from the registrations stream; there is no separate event when only the gate changes.
- The `disconnect` event belongs to the transports (phases 45-47).

## Known Stubs

None.

## Threat Flags

None beyond the plan's register (T-43-19 to T-43-22 mitigated as planned; payloads carry addresses, role, network and flags only).

## Self-Check: PASSED

Commits b0ae1777 and 06259bb9 exist; full suite and analyze green.
