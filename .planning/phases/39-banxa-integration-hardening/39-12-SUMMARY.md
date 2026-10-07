---
phase: 39-banxa-integration-hardening
plan: 12
subsystem: banxa-cleanup
tags: [banxa, deletion, kyc, routes]
requires: [39-11]
provides:
  - "Replaced Banxa screens, routes and helpers removed; one Buy route left"
key-files:
  created: []
  modified: [lib/navigation/router.dart, lib/components/overlay/global_swap_fab_host.dart, lib/banxa/banxa_api_services.dart, lib/banxa/banxa_model.dart, lib/banxa/banxa_components/order_status_style.dart, lib/banxa/banxa_order/banxa_order_state.dart, lib/dev/dev_banxa_fixtures.dart, test/banxa/banxa_reskin_literals_test.dart, test/banxa/order_status_style_test.dart, tool/verify_additive_boundary.sh]
status: complete
actuals: {tokens: 12000, tasks: 2, commits: 2}
---
# Phase 39 Plan 12: Closed-list deletion Summary

The KYC screen, the create-order route, the helpers class and the status-count and banner symbols are gone; KYC now lives only inside Banxa's checkout.

## Closed list
- Deleted now (task 1): lib/banxa/user_kyc/kyc_registration.dart, lib/banxa/banxa_helpers/banxa_helpers.dart (with BannerInfo), routes `/kyc` and `/createOrder`, `/kyc` in the FAB hidden list.
- Deleted now (task 2): `banxaKycUrl`, `BanxaKycResponse`, `bannerTone`, `OrderStatusBanner`, `OrdersState.statusCounts`, `totalOrderCount`, test/banxa/order_status_counts_test.dart, the banner-tone test group.
- Already removed: lib/banxa/handle_banxa_drawer.dart and test/banxa/checkout_options_sheet_test.dart (39-09); `applyFilters`/`filteredOrders` (39-05). No reader outside the list was found.
- Reskin gate: in-scope list 4 -> 3 files (the plan said 5 -> 3; the options-sheet file was already gone). `/buy` is the one Buy route left.

## Result
- Full `flutter test`: 2334 passed, 6 skipped, 0 failed (plan 11 ended at 2345; -11 is the deleted counts tests, banner-tone tests and the KYC file's 3 reskin cases). `flutter analyze lib test` exit 0. Format, brace, raw-colour and key-logging (`--scan-tree`) scripts exit 0. ID gate printed 0 on both commits. No trailers; email braianwegmann@hotmail.com.
- Commits: two refactor commits (KYC/helpers/routes, then the orphaned symbols). STATE.md and ROADMAP.md untouched; no flutter_tester left.

## Decisions
- Stale comments naming deleted files were reworded in order_status_style.dart, dev_banxa_fixtures.dart and the reskin test; the FAB host comment no longer mentions KYC.
- tool/verify_additive_boundary.sh: removed the three deleted banxa files (banxa_orders_history, banxa_payment, kyc_registration) from its Loading importer baseline.

## Deviations from Plan
None.

## Deferred
- tool/verify_additive_boundary.sh still fails on drift this plan did not cause: the Loading importer baseline no longer matches (e.g. checkout/*, assets_screen, token_info_screen importers), 4 duplicate private class names not in tool/shadow-baseline.txt (`_DetailRow`, `_PlainDetailRow`, `_Section`, `_SplashState`), and a `WIRE-02` mention in global_swap_fab_host.dart. Not fixed.

## Self-Check: PASSED
Deleted paths are absent, both commits are in `git log`, and no message carries a trailer.
