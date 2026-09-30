---
phase: 39-banxa-integration-hardening
plan: 07
subsystem: banxa-checkout
tags: [banxa, checkout, webview, security]
requires: [39-06]
provides:
  - "checkout_rules.dart: isTrustedCheckoutUrl, isBanxaReturn, allowsCheckoutNavigation, checkoutHostKind, checkoutPermissionAllowed"
  - "CheckoutScreen, CheckoutProgress, CheckoutResult, CheckoutExternal and CheckoutWebView; /checkout builds CheckoutScreen"
key-files:
  created: [lib/banxa/checkout/checkout_rules.dart, lib/banxa/checkout/checkout_screen.dart, lib/banxa/checkout/checkout_webview.dart, test/banxa/checkout_rules_test.dart, test/banxa/checkout_screen_test.dart]
  modified: [lib/navigation/router.dart, test/banxa/banxa_reskin_literals_test.dart]
status: complete
actuals: {tokens: 12400, tasks: 2, commits: 2}
---
# Phase 39 Plan 07: Full-screen checkout Summary
A full-screen in-app checkout that ends on the polled order status; the return link only speeds up one status read.

## Result
- Full `flutter test`: 2347 passed, 6 skipped, 0 failed (plan 06 ended at 2304). `flutter analyze lib test` exit 0. Format, brace, raw-colour and lib/banxa key-logging scripts exit 0. ID gate printed 0 on both commits. No trailers.
- Commits: a0eab26e (rules and tests), 4a7e3100 (screen, webview host, route, deletions). No checkpoints or tracer tasks. STATE.md and ROADMAP.md untouched.
- Mutation check: dropping `isPaid` from the Done condition fails the polled-status test.
- Not run: the webview host itself (no test implementation on this host). Its logic sits in the tested rules; the live walk is still owed on Android, iOS and macOS.

## Decisions
- Windows returns the external host for now; the `windows` enum value is reserved for its own host.
- Camera and microphone are granted only while the last main-frame page is a Banxa host, since the permission request carries no origin.
- "Unpaid" means neither paid nor final, so extraVerification and unknown also offer Complete payment.

## Deviations from Plan
- [Rule 2] `CheckoutScreen.initState` calls `OrdersCubit.track(orderId)`. Without it an order the caller never added would never be polled, so Done could not fire.
- Deleted `banxa_payment.dart` and `webview_fallback_test.dart` as planned; the latter also pinned the KYC screen's Linux fallback layout.

## Deferred Issues
- `tool/verify_additive_boundary.sh` already fails on this branch (Loading importer baseline drift, a WIRE- comment in `global_swap_fab_host.dart`). Not caused by this plan; its list still names the deleted `banxa_payment.dart`.

## Known Stubs
None. `/checkout` has no caller until the Buy card plan hands off to it.
## Self-Check: PASSED
All five new files exist, both commits are in `git log`, the two deleted files are gone, and no message carries a trailer.
