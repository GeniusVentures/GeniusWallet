---
phase: 39-banxa-integration-hardening
plan: 02
subsystem: banxa-navigation
tags: [banxa, router, deletion]
provides:
  - /banxa/callback redirects to /transactions?filter=purchase and ignores its query
  - CheckoutQrPage completion goes to Buy orders
key-files:
  modified: [lib/navigation/router.dart, lib/banxa/checkout_qr.dart, test/banxa/buy_page_layout_test.dart, test/dashboard/buy_orders_filter_test.dart, test/banxa/banxa_reskin_literals_test.dart]
  deleted: [lib/banxa/banxa_orders_history.dart, lib/screens/order_details_page.dart, lib/banxa/banxa_components/order_card.dart, lib/banxa/banxa_components/order_details_card.dart, test/banxa/orders_history_states_test.dart, test/banxa/order_card_test.dart, test/banxa/order_details_card_test.dart]
status: complete
actuals: {tokens: 9000, tasks: 2, commits: 2}
---
# Phase 39 Plan 02: Retire the old orders pages Summary

Every way back from Banxa now opens Buy orders in Transactions, and the old orders history and order details pages are gone.

## Result
- Full `flutter test`: 2232 passed, 6 skipped, 0 failed. Plan 01 ended at 2266; the drop is the three deleted test files (about 35 tests) plus one new redirect test.
- `flutter analyze lib test` exit 0, `dart format --set-exit-if-changed` exit 0, `tool/check_brace_style.sh` exit 0, `tool/check_raw_colors.sh` exit 0. ID gate printed 0 on both commits.
- All seven deleted paths are absent. Commits: 3cf44048 (routes and QR target), 4f5f872a (deletions).
- No checkpoints or tracer gates in this plan.

## Decisions
- The QR page uses `context.go`, not `push`, so finishing replaces the stack instead of stacking Transactions on the QR page.
- `_rawButtonExemptionCount` is removed from the literal gate rather than left as an empty map; the check now expects zero raw Material buttons.
- The redirect test lives in `buy_orders_filter_test.dart`'s router with the same redirect route, so it exercises the real Transactions screen.

## Deviations from Plan
- [Rule 3] `router.dart` lost three imports (`order_service.dart`, the history page, the details page) that the removed routes were the only users of.
- Stale comments were rewritten where they sat inside edited code (router `/buy` comment, `checkout_qr.dart` AppBar comment, the literal gate header) so they no longer name deleted files or phase ids. The ID gate flagged the re-wrapped header line in the literal gate, so that reference was dropped rather than reflowed.
- Not touched, per "nothing else changes here": comments in `banxa_buy_screen.dart` and `order_status_style.dart` that still name the deleted files, `OrderLinker.get` (now unused, `put` still called from `banxa_api_services.dart`), and the status banner helpers. The final deletion plan owns those.

## Self-Check: PASSED
Both commits are in `git log`, deleted paths do not exist, `.planning/STATE.md` and `ROADMAP.md` untouched. Known stubs: none.
