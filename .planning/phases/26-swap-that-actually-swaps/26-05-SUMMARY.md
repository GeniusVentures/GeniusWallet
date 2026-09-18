---
phase: 26
plan: 05
subsystem: swap
tags: [squid, execution, orchestrator, provider-boundary, spec-drift]
status: complete
requires: [26-04]
provides: [swap-orchestrator, swap-outcome-type, executable-route, status-polling]
affects: [lib/squid_router, lib/swap]
tech-stack:
  added: []
  patterns: [pure orchestrator with injected callbacks, sealed outcome, recorded-response fixture]
key-files:
  created: [lib/squid_router/swap_execution.dart, lib/swap/swap_transaction.dart, test/squid_router/swap_execution_test.dart, test/squid_router/fixtures/route_response_executable.json, test/swap/squid_transaction_mapping_test.dart, test/swap/fake_swap_provider.dart]
  modified: [lib/squid_router/squid_swap_provider.dart, lib/swap/swap_provider.dart, test/squid_router/squid_client_test.dart, test/squid_router/swap_balances_wiring_test.dart, test/squid_router/swap_flip_centring_test.dart]
  deleted: []
decisions:
  - "Written before 26-08 landed: the plan's decision checkpoint assumed TransactionStatus had four values. It already had seven (needsGas/partialSuccess/refunded, HiveFields 4-6), so the mapping is faithful and neither of the two offered options applied."
  - "SquidTokenService is gone, so the plan's 'add a status call to squid_token_service.dart' became SwapProvider.status on the adapter — a third squidrouter importer would have broken the decoupling rule."
  - "buildTransaction and status both read raw dio. The generated model resolves transactionRequest through a oneOf that collapses the object into a ListJsonObject, so the signable half is unreachable through it."
  - "The unwrap converts Squid's DECIMAL strings to hex. signAndSendTransaction parses every numeric field as hex; gasLimit '969344' read as hex is 9,868,100."
metrics: {tasks: 2, commits: 2, completed: 2026-09-16}
actuals: {tokens: 26000, tasks: 2, commits: 2}
---

# Phase 26 Plan 05: The whole swap, minus the screen Summary

`executeSwap` runs route → allowance → exact-amount approval → send → status poll, behind a sealed
outcome where **only a hash-bearing shape may produce a toast, a receipt or a stored row**.
`sideEffectsFor` is exhaustive, so a new outcome cannot silently become a fourth way to lie.

Backfilled 2026-09-17: this plan was executed on 2026-09-16 but its summary was deferred when the
run halted on a blocker (below). The work itself landed in `29aada9b` and `b1024326`.

## Deviations from Plan

**[Checkpoint void] The decision checkpoint's premise was already false.** The plan opened with a
blocking decision — map Squid's seven statuses onto four `TransactionStatus` values, or extend the
Hive enum — and called extending it "a phase of its own". The enum **already had seven values**
(`needsGas`, `partialSuccess`, `refunded` at HiveFields 4-6, append-only). So neither option applied
and the mapping is simply faithful, at zero migration cost. I initially announced `map-to-pending`
and corrected it on reading the enum.

**[Rule 3 - Blocking] The generated client cannot deliver `transactionRequest`.** Its `oneOf`
resolves the object into a `ListJsonObject` — measured, not inferred. `buildTransaction` therefore
reads `/v2/route` off the generated client's own dio, as 26-04 already did for `/v2/sdk-info`.
`status` reads `/v2/status` the same way. Third and fourth endpoints where the generated model is
wrong; the submodule may not be edited.

**[Rule 1 - Bug] Squid sends `value`, `gasLimit`, `maxFeePerGas` and `maxPriorityFeePerGas` as
DECIMAL strings, and `signAndSendTransaction` parses every one as hex.** `gasLimit: "969344"` read
as hex is 9,868,100 — ten times over, on a value that costs money. The unwrap converts, and the test
round-trips the mapped strings back through `parseHexToBigInt`, the signer's own parser, rather than
comparing against hand-written hex.

**[Plan text vs. reality] An unindexed transaction is HTTP 404, not a `not_found` status.** It
reaches the poller as a throw. Treated as "not yet" — the hash is kept and polling continues; only
the attempt bound resolves, to pending. The plan assumed a status value.

**[Correction] `requestId` is NOT simply null.** The top-level body field is absent entirely, but
`transactionRequest.requestId` is populated and equal to the `x-request-id` header. The header is
read as instructed, with the field as fallback.

**[Halted, then unblocked]** The run stopped after `b1024326`: `walletStatusFor` referenced enum
values that existed only in another agent's **uncommitted** working-tree changes, and those changes
broke two unrelated tests. That agent committed as `09669d8b` — labelled `feat(26-05)` but actually
implementing **26-08**'s scope — which resolved the dependency.

## Verification

Real output, this machine, this branch:

- `flutter test test/squid_router/swap_execution_test.dart --no-pub` → **+19, All tests passed!**
- `flutter analyze --no-pub` → "No issues found!", exit **0**, both trees
- `grep -rn "BuildContext\|package:flutter" lib/squid_router/swap_execution.dart` → **nothing** (pure)
- `grep -rln "package:squidrouter" lib/` → 2 files, unchanged
- Live, real credential: `/v2/route` with `quoteOnly: false` → HTTP 200, `x-request-id` present;
  `/v2/status` for an unknown hash → **HTTP 404** `{"message":"No transaction found"}`
- The executable fixture is a real body with the capture address redacted in all 3 occurrences,
  calldata included; a test asserts it

## Note for later plans

26-07 subsequently split `SwapRouteFailed` into `SwapRouteUnavailable`/`SwapRouteUnsignable` and
`SwapApprovalFailed` into `SwapAllowanceUnreadable`/`SwapApprovalFailed`, so six failures could each
carry their own message. The invariant and `sideEffectsFor` are unchanged.

## Self-Check: PASSED

All six created files exist. Commits `29aada9b`, `b1024326` resolve.
