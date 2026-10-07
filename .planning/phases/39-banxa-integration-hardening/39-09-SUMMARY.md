---
phase: 39-banxa-integration-hardening
plan: 09
subsystem: banxa-checkout
tags: [banxa, checkout, webview2, windows, qr]
requires: [39-08]
provides:
  - "CheckoutWebViewWindows: in-app WebView2 checkout, registered with the window-close shutdown hook"
  - "CheckoutQrBody drawer, header menu, leave prompt; the QR page's own poller is gone"
key-files:
  created: [lib/banxa/checkout/checkout_webview_windows.dart]
  modified: [lib/banxa/checkout/checkout_screen.dart, lib/banxa/checkout/checkout_rules.dart, lib/banxa/checkout_qr.dart, lib/components/overlays/gw_menu_item.dart, lib/navigation/router.dart, lib/banxa/banxa_api_services.dart, lib/banxa/banxa_model.dart]
  deleted: [lib/banxa/banxa_order/polling_order_cubit.dart, lib/banxa/banxa_order/polling_order_state.dart, lib/banxa/handle_banxa_drawer.dart, test/banxa/checkout_options_sheet_test.dart]
status: complete
actuals: {tokens: 21000, tasks: 2, commits: 2}
---
# Phase 39 Plan 09: Windows checkout, menu, leave prompt Summary

Checkout now runs in WebView2 on Windows, can be finished on another device or in the browser from the header menu, and asks before being abandoned mid-payment.

## Result
- Full `flutter test`: 2328 passed, 6 skipped, 0 failed (plan 08 ended at 2322). `flutter analyze lib test` exit 0. Format, brace, raw-colour and lib/banxa key-logging scripts exit 0. ID gate printed 0 on both commits. No trailers, email braianwegmann@hotmail.com.
- Commits: f1b79bed (Windows host and permission rule), 762058d0 (menu, prompt, QR drawer, deletions). No checkpoints or tracer tasks. STATE.md and ROADMAP.md untouched; no flutter_tester left running.
- Mutation check: letting the back gesture through while paying (`canPop: true`) fails the back-gesture test.
- Not run: the WebView2 host itself (no test implementation on this host), so the live Windows walk is owed: load, camera prompt, close-window shutdown. The URL-stream return and load-error mapping are untested glue.

## Decisions
- `windowsCheckoutPermission` also takes the asking page's URL and denies anything that is not a Banxa page, since WebView2 supplies it. Tighter than camera/microphone alone.
- A cancelled navigation (`WebErrorStatusOperationCanceled`) is not reported as a load error; redirects cancel the page they replace.
- The header menu and the leave prompt apply only while a trusted checkout is unfinished; an untrusted link never gets a menu or a QR.
- Leave is a normal pop, so the app-level poller keeps tracking the order after the screen closes.

## Deviations from Plan
- [Rule 3] `handle_banxa_drawer.dart` (the old checkout options sheet) had no caller after plan 08 and pushed the deleted `/checkoutQR` route, so it and its test went too; the reskin literal gate now pins four files. An open todo about that sheet's visual contract is now moot.
- [Rule 2] `GWMenuItem` gained an optional `subtitle` (with a test) so the menu shows its second line without a bespoke item.
- Removed the `getOrderStatus` line from the 500-error case in `banxa_api_service_test.dart`; the router's second `BanxaApiService()` went with the QR route.

## Self-Check: PASSED
checkout_webview_windows.dart exists, the four deleted files are gone, both commits are in `git log`, and no message carries a trailer. Known stubs: none.
