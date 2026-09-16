---
phase: 26
plan: 07
subsystem: swap
tags: [squid, error-states, copy, disclosure]
status: complete-pending-walk
requires: [26-06]
provides: [distinct-failure-messages, typed-route-failure]
affects: [lib/squid_router, lib/swap]
tech-stack:
  added: []
  patterns: [message selected by sealed outcome shape, no default arm]
key-files:
  created: [lib/squid_router/swap_messages.dart, test/squid_router/swap_messages_test.dart]
  modified: [lib/squid_router/swap_execution.dart, lib/squid_router/squid_swap_provider.dart, lib/squid_router/swap_screen.dart, lib/swap/swap_transaction.dart, test/squid_router/swap_execution_test.dart, test/squid_router/swap_submit_test.dart, test/swap/squid_transaction_mapping_test.dart]
  deleted: []
decisions:
  - "The outcome gained two shapes. Six distinguishable failures cannot come from four shapes, and the plan asked for six — SwapRouteFailed split into Unavailable/Unsignable, SwapApprovalFailed into AllowanceUnreadable/ApprovalFailed."
  - "The adapter throws a typed SwapRouteException carrying an enum, not a StateError. Telling the two route failures apart by matching an error string would break the moment a message is reworded."
  - "A settled-but-not-successful swap still stores its row and opens its receipt — the funds moved. Only the toast copy and its type change."
metrics: {tasks: 3, commits: 2, completed: 2026-09-16}
actuals: {tokens: 21000, tasks: 3, commits: 2}
---

# Phase 26 Plan 07: Every failure says which way Summary

`swapFailureMessage` maps each outcome shape to its own sentence, surfaced through the toast and
inline notice the screen already had. No new widget, colour or drawer.

## Deviations from Plan

**[Design] The outcome type grew from four shapes to six.** The plan lists six branches — no route,
unsignable route, unreadable allowance, failed approval, failed send, settled-not-success — while
26-05 left four shapes. Rather than a reason enum inside a shape (which defeats the compile-time
exhaustiveness the threat model relies on), `SwapRouteFailed` became `SwapRouteUnavailable` /
`SwapRouteUnsignable` and `SwapApprovalFailed` became `SwapAllowanceUnreadable` /
`SwapApprovalFailed`. `executeSwap` already knew which step failed for the approval split; the route
split needed the adapter to say, hence the typed exception.

**[Rule 2] `SwapRouteException` replaces `StateError` on the execute path.** It carries an enum plus
an optional `detail` for logs, and its `toString` deliberately omits the detail — a screen that
printed it would leak a node URL. Asserted.

**[Beyond the plan's file list]** `swap_submit_test.dart` and `squid_transaction_mapping_test.dart`
were updated for the new shapes; the mapping test now asserts *which* failure, which is stronger
than the `throwsStateError` it replaced.

**Fixture defect found and fixed:** a loop of `_mountReady` inside one `testWidgets` silently does
nothing on the second pass — Flutter reuses the `State`, so the tokens are already seated and the
taps hit nothing. Split to one mount per case.

## Verification

Real output, this machine, this branch:

- `flutter test test/squid_router/ test/swap/ --no-pub` → **All tests passed** (messages +8,
  submit +13)
- `flutter analyze --no-pub` → "No issues found!", exit **0**, root AND `packages/genius_api`
- `dart format --set-exit-if-changed lib test packages/genius_api/lib` → exit 0; brace style → `0`
- Task 3 gates: `grep -rn "993.72" lib/` → nothing; `grep -rniE "^\s*return mock" lib/squid_router/`
  → nothing; `git diff --name-only origin/develop -- squidrouter/ | wc -l` → **0**
- `grep` for `baseUrl` / `testnet.api` / `mockTokens` / `mockSquid` in `lib/squid_router/` → nothing
- No source file added in this phase cites a plan, phase, sketch or spec number, or names a test file
- `flutter test --no-pub` → 1325 pass / 5 skip / **3 fail** — all three are the other agent's
  in-flight `26-08` work, unchanged and untouched by this plan

## Open for the human

The plan's `<human-check>`: underfund gas on a throwaway **Base mainnet (8453)** wallet and submit —
the message should name the send failure, the list should gain no row, and the form should stay
usable. Needs dust and a key, so it is yours. The unavailable-build case is already covered
headlessly by `squid_client_test.dart`.

## Self-Check: PASSED

Both created files exist. Commits `a013a81d`, `75ac8c39` resolve.
