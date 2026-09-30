---
phase: 39-banxa-integration-hardening
plan: 05
subsystem: banxa-orders
tags: [banxa, orders, status, fixtures]
requires: [39-04]
provides:
  - "orderStatusTone, OrderStatusPill, orderTransactionStatus and orderRowContent all read BanxaOrderStatus"
  - "Fixtures on Banxa wire strings; OrdersCubit.applyFilters and OrdersState.filteredOrders removed"
key-files:
  modified: [lib/banxa/banxa_components/order_status_style.dart, lib/banxa/banxa_helpers/order_transaction_mapping.dart, lib/banxa/banxa_order/banxa_order_cubit.dart, lib/banxa/banxa_order/banxa_order_state.dart, lib/dev/dev_banxa_fixtures.dart, lib/screens/banxa_buy_screen.dart, test/banxa/fixtures.dart]
status: complete
actuals: {tokens: 9800, tasks: 2, commits: 2}
---
# Phase 39 Plan 05: Order surfaces on the status model Summary

Order rows, pills and tones now come from the parsed Banxa status, so only `complete` reads as success and a paid-but-undelivered order cannot look delivered.

## Result
- Full `flutter test`: 2277 passed, 6 skipped, 0 failed (plan 04 ended at 2274). `flutter analyze lib test` exit 0; `dart format --set-exit-if-changed`, `tool/check_brace_style.sh`, `tool/check_raw_colors.sh` exit 0. ID gate printed 0 on both commits.
- Commits: c4233417 (rows, pills, tones), 298be9df (fixtures, filtered list removal).
- No checkpoints, no tracer tasks. STATE.md and ROADMAP.md untouched.

## Decisions
- Tones: complete success, declined error, expired/cancelled/refunded/unknown neutral, every in-flight status warning.
- Row: short tail word; `+ X` when final, `+ ≈X` while open; `Not charged` for declined, expired, cancelled; `<fiat> refunded` for refunded; unknown keeps its fiat and shows `Unknown`.
- `orderTransactionStatus`: expired and cancelled fold onto the neutral `cancelled`, refunded onto `refunded`, declined onto `failed`, all else `pending`. A blank status therefore maps to `pending` and shows no label.

## Deviations from Plan
- [Rule 3] `lib/screens/banxa_buy_screen.dart` and `test/banxa/orders_poller_test.dart` were outside the file list. The screen carried a doc comment naming the removed `applyFilters`; the poller test used `applyFilters()` only to force an emit, so it now calls `track('c1')`.
- [Rule 1] The order-row finders in `order_rail_row_test.dart` and `orders_header_track_test.dart` matched the exact `+ X BTC` text; they now match `X BTC` so the approximate sign does not break them.
- In Task 1 the tests that needed a finished order pass `status: 'complete'` explicitly, because the fixture default only changes in Task 2.

## Self-Check: PASSED
Both commits are in `git log`, no trailer in either message, grep acceptance checks hold (`'completed'` remains only in the three legacy-string test files). Known stubs: none.
