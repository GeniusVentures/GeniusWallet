---
phase: 26
plan: 03
subsystem: swap
tags: [squid, quote, provider-boundary, base-units]
status: complete
requires: [26-01]
provides: [swap-provider-boundary, swap-quote-domain-type, live-quote, route-fixtures]
affects: [lib/swap, lib/squid_router]
tech-stack:
  added: []
  patterns: [adapter behind an abstract interface, recorded-response fixtures]
key-files:
  created: [lib/swap/swap_quote.dart, lib/swap/swap_provider.dart, lib/squid_router/squid_swap_provider.dart, test/squid_router/fixtures/route_response.json, test/squid_router/fixtures/route_response_cross_chain.json, test/squid_router/route_fixture.dart, test/squid_router/route_parse_test.dart, test/swap/squid_quote_mapping_test.dart, test/swap/live_quote_walk_test.dart, test/squid_router/squid_util_test.dart]
  modified: [lib/squid_router/squid_util.dart, lib/squid_router/squid_token_service.dart, lib/squid_router/swap_screen.dart, lib/squid_router/route_details_card.dart, test/squid_router/route_details_card_test.dart]
  deleted: [lib/squid_router/models/squid_route_response.dart, lib/squid_router/models/squid_swap_params.dart, lib/squid_router/models/squid_gas_cost.dart, lib/squid_router/models/squid_fee_cost.dart]
decisions:
  - "Squid's types stop at the adapter: SwapQuote/SwapQuoteRequest/SwapProvider are ours, and only squid_client.dart and squid_swap_provider.dart import squidrouter."
  - "The card takes symbols, not token models, so 26-04's SwapToken rename cannot reach it."
  - "Two recorded fixtures, not one: a same-chain route has no fees at all, so the fee+gas sum is only provable against a cross-chain one."
metrics: {duration: 1h10m, completed: 2026-09-16, tasks: 3, commits: 4}
actuals: {tokens: 15758, tasks: 3, commits: 4}
---

# Phase 26 Plan 03: The quote becomes real Summary

The rate on screen is a live `/v2/route` answer read through our own `SwapQuote`, and the typed
amount is converted to base units before it is sent. `actuals.tokens` is chars/4 over the realized
diff; ~4,400 of it is recorded fixture JSON rather than authored code.

## Deviations from Plan

**[Coordinator constraint, mid-execution] The provider boundary.** A new locked decision arrived
while task 3 was in progress: Squid must be replaceable, so no widget, screen or shared helper may
name a Squid type. The already-written Squid-typed signatures were refactored rather than noted.
`SquidTokenService.getRoute` is gone entirely — routing lives in `SquidSwapProvider`, and the
service keeps only 26-04's token and balance mocks. Added beyond the plan: `lib/swap/`, the adapter,
and its mapping test.

**[Rule 1 - Bug] The submit toast would have printed base units.** It read `params.fromAmount`,
which was the typed string under the old params type and is `1500000000000000000` under the new
one. It now reads the typed amount directly.

**[Rule 2] The quote debounce was 500ms against a verified 1 RPS ceiling.** Raised to 1000ms; an
overrun answers with an error the user reads as a broken swap. Easy to veto — one line.

**[Plan text vs. reality] `feeCosts` is empty on a same-chain route.** The plan asked the fixture
test to assert at least one fee cost. The live API returns none for GNUS→USDC on Base, and treating
that as an error would be the bug. The test asserts gas is non-empty and fees may legitimately be
empty; a second cross-chain fixture carries a real fee so the sum is still proven.

**[Correction for 26-05/26-06] `quoteOnly` does NOT omit `transactionRequest`.** Squid returns it as
an empty object `{}`, not absent. `transactionRequest != null` is therefore the wrong executability
check — test for `target`/calldata. 26-RESEARCH.md says "absent"; it is not.

## Verification

Real output, this machine, this branch:

- `flutter test --no-pub` → **+1258 ~4, All tests passed!**, exit 0 (baseline 1239 ~3, measured here)
- `flutter analyze --no-pub` → "No issues found!", exit **0**, root and `packages/genius_api`
- `flutter test test/swap/live_quote_walk_test.dart --dart-define-from-file=squid.local.json` →
  **+1, All tests passed!** — two live quotes, rates 0.757-ish, not 993.72, and moving with amount
- `dart format --set-exit-if-changed lib test` → exit 0; `tool/check_brace_style.sh --count` → `0`
- `grep -rn "993.72" lib/` → 0 hits. `ls lib/squid_router/models/` → the two token models only
- `grep -rn squidrouter lib/` → `squid_client.dart` and `squid_swap_provider.dart` only
- Both fixtures assert `fromAddress`/`toAddress` are the all-zero address; the capture address was
  a public one, never a project wallet
- Deletions in `6b8f6fcd` are exactly the four planned models

## Open for the human

The one thing not run here: the GUI walk. `flutter run -d windows --debug
--dart-define-from-file=squid.local.json`, pick GNUS→USDC on Base, type an amount, confirm the card
moves. The live test proves the same path headlessly, but not the pixels.

## Self-Check: PASSED

All listed files exist on disk; commits `f2cd2845`, `c29db94c`, `b2dd8d84`, `6b8f6fcd` all resolve.
