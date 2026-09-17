---
phase: 26
plan: 07
subsystem: swap
tags: [squid, error-states, copy, disclosure]
status: complete
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

## Walked 2026-09-17 — PASSED

**Base mainnet 8453**, with the 0.000016 ETH left over from 26-06's swap — genuinely underfunded,
not simulated. Swapping that dust to USDC:

- **The message named the send**, verbatim: "The swap did not go through." / "The swap could not
  be sent. Check that you have enough to cover gas, then try again." That copy belongs to
  `SwapSendFailed` and to no other outcome, so the shape is identified by the words alone. The
  heading is the `submitFailure != null` branch, which only `_reportFailure` sets — so this came
  from the submit, not from a failed quote.
- **No row was written.** The run's log contains no receipt and no `transactionHash` at all: the
  send never broadcast, so nothing could be stored under a real hash. `storeRow` is false for
  this shape by construction.
- **The form stayed usable** — amount and tokens seated, CTA back on its enabled retry rung.

Native was deliberate. A native swap skips allowance and approval entirely
(`swap_execution.dart`), so `SwapSendFailed` is the only failure reachable on that path; an
ERC-20 would have tripped `SwapApprovalFailed` first and walked the wrong sentence.

## What this walk settled, and what it did not

**MAX does not reserve gas.** This dust balance was MAX'd and the send failed for gas — so the
app offers the entire balance and lets the send fail. That is the honest behaviour for a failure
message, but it means a user CAN empty their native balance and be unable to move what they
received.

It does **not** explain 26-06: that swap spent 0.004983074278833122 ETH and left ~0.0000169,
which is where this dust came from. If MAX takes everything, something else trimmed that amount
— Squid, or a balance that was never the round 0.005 it appeared to be. **Still unresolved, and
still not worth guessing at**; it is the difference between "the user chose to spend it all" and
"the app quietly held some back".

## Self-Check: PASSED

Both created files exist. Commits `a013a81d`, `75ac8c39` resolve.
