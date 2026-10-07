---
phase: 39-banxa-integration-hardening
plan: 01
subsystem: banxa-transactions
tags: [banxa, orders, transactions]
provides:
  - OrdersCubit(api:) that follows the Selected wallet, with a load generation guard
  - showOrderDetails(context, order) and filterFromQuery
  - Buy orders as the fifth title-row chip; /transactions?filter=purchase
key-files:
  created: [lib/banxa/banxa_components/order_details_drawer.dart, test/banxa/fake_banxa_api.dart, test/banxa/orders_wallet_scope_test.dart, test/dashboard/buy_orders_filter_test.dart]
  modified: [lib/banxa/banxa_order/banxa_order_cubit.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/transactions/transactions_screen.dart, lib/dashboard/transactions/sgnus_transactions_screen.dart, lib/dashboard/transactions/view/transactions_stream.dart, lib/navigation/router.dart]
status: complete
actuals: {tokens: 7100, tasks: 3, commits: 3}
---
# Phase 39 Plan 01: Buy orders in Transactions Summary

The Selected wallet's Banxa orders now list in Transactions under a "Buy orders" chip, and `/transactions?filter=purchase` opens with it selected.

## Baseline (Wave 0, before any change)
`git submodule update --init` and `flutter pub get` succeeded. `flutter test`: 2251 passed, 6 skipped, 0 failed. `flutter analyze` was not run on the untouched tree (edits began before it); after the work it exits 0 with no issues.

## Result
- Full `flutter test`: 2266 passed, 6 skipped, 0 failed (+15 tests). `flutter analyze lib test` exit 0, `dart format --set-exit-if-changed`, `tool/check_brace_style.sh`, `tool/check_raw_colors.sh` all exit 0. ID gate printed 0 on all three commits.
- Tracer gate: dashboard, banxa and dev tests re-run after Task 1 (726 passed); no checkpoint stop.
- Commits: 9aae6ce9 (tracer), 1634c358 (wallet scope tests), cc9efcf3 (chip, empty state, SGNUS).

## Decisions
- `OrdersCubit` keys its reload on the Banxa customer id, so a case-only address change does not refetch. A missing wallet emits an empty success without calling the API.
- Orders are appended after SGNUS scoping, and mapped once per build into an identity map so a row finds its order.
- Filter bar is now 289px wide (5x44 chips); a 328px content box (360px phone) fits, pinned by a new test width.

## Deviations from Plan
- [Rule 1 - test] The "filtered copy never says buy" test now skips Buy orders, which has its own empty state that does offer Buy GNUS.
- The rail's fallback-font ceiling drops from two digits to one (`Buy orders` is 132.5px, 15.5px left); the `_railWidth` comment and rail test pin say so. Real Inter is not measured. Rail width was left at 220.
- `test/banxa/fixtures.dart` gained `testWallet`, `UnusedGeniusApi` and `PickableWalletCubit` (shared by two test files).

## Self-Check: PASSED
Created files exist, commits are in `git log`. Known stubs: none.
