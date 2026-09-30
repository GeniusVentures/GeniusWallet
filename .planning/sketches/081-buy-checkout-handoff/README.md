---
sketch: 081
name: buy-checkout-handoff
question: "What happens between tapping Buy GNUS and being back in the wallet with a tracked order?"
winner: "B"
tags: [banxa, buy, checkout, webview, custom-tabs, callback, order-status, disclaimer, errors, phase-39]
---

# Sketch 081: Buy checkout handoff

## Design Question

Today, tapping Buy GNUS shows the leave-the-app disclaimer on every buy, then
`showCheckoutOptionsSheet` (`lib/banxa/handle_banxa_drawer.dart`) makes the user pick
Open in Browser, Show QR (use another device) or Copy checkout link. After that the app
loses the user. `BanxaPaymentWebView` at `/checkout` exists but nothing opens it, and only
the QR page polls status. The research (`phases/39-.../39-UX-RESEARCH.md`) says to choose
checkout by platform, keep QR and link as a small "pay on another device" option, show the
disclaimer once, and land on a tracked order. This sketch asks what that sequence looks like.

## How to View

open .planning/sketches/081-buy-checkout-handoff/index.html

- Variant tabs at the top. Under them, the **Sequence** strip jumps to any step
  (Buy tapped, Creating your order, Checkout, Return, Order: Processing payment) and the
  **Errors** strip jumps to the three error states. Restart runs from the start.
- The line under the strips says what the platform is doing at that step.
- Toolbar, bottom right: Viewport (Desktop 1280 in the app shell, Mobile 390), Theme,
  Scenario (payment goes through / checkout fails to open / payment declined), and
  "First buy on this device", which turns the disclaimer on. Accepting it clears the box,
  which is the point: the next run goes straight to checkout.
- Banxa's checkout is a grey dashed frame labelled BANXA CHECKOUT · PLACEHOLDER with a fake
  ID check and a fake Pay step. It is not a copy of Banxa's UI.

## Variants

- **A: Sheet on mobile, waiting card on desktop.** Mobile: checkout opens in a tall bottom
  sheet with a slim header (Banxa, lock + checkout.banxa.com, close X). Closing early asks
  "Leave checkout? Your order stays open for 30 minutes". Desktop: the system browser opens
  (drawn as a separate window) and the Buy page shows "Finish paying in your browser" with
  the order summary, "I've paid, check status", "Reopen checkout", and a small "Pay on
  another device" link that opens QR + Copy link in the drawer shell. Lands on the receipt
  drawer over Buy GNUS.
- **B: Full-screen checkout.** Both platforms show checkout inside the app, full screen on
  mobile and as a panel under the navbar on desktop. Slim header with close X, "Secured by
  Banxa", Order › Pay › Done progress, and a ⋮ menu with Pay on another device and Open in
  browser. The flow ends on its own Done page, which is the order.
- **C: Stay on the page.** The Buy form turns into an order tracker (Order created, Pay with
  Banxa, Processing payment, GNUS in your wallet) and checkout runs outside: a browser window
  on desktop, a Custom Tab / SFSafariViewController on mobile. Nothing has to navigate back.
  Kept because it is the only variant where the mobile path is the one Banxa recommends
  when Google Pay matters, and because it shows what the app loses when it does not own the
  close button (no "Leave checkout?" prompt, no way to see the tab close).

## What to Look For

- **The wait before checkout.** A puts it in the sheet (mobile) or the button (desktop),
  B in the progress, C in the tracker. Which one feels like the tap was answered?
- **Return reliability on desktop.** A and C depend on the callback link or the user coming
  back. Try "Switch to GeniusWallet" before paying, then "I've paid, check status" (A): it
  says Banxa has nothing yet, rather than pretending.
- **Where you land.** A: receipt drawer over the page. B: a Done page inside the flow.
  C: the page itself. Which reads as "your order is being tracked"?
- **Closing early.** A and B can ask first. C mobile cannot, because a Custom Tab's X is the
  system's. Is the prompt worth the platform cost?
- **Pay on another device** as a link (A), a menu item (B) or a button (C). It should be
  findable without competing with the main path.
- **Errors.** Checkout failed to open keeps the same order and offers retry, browser, or
  another device. Declined shows "Not charged", the Banxa order ID with copy, a support link
  and Retry Order. Closed without paying shows Pending Payment and Complete Payment.
- Light and dark. Links and the secondary button use `brandPrimaryOnSurface`
  (`#0A6885` light, `#0AAEE6` dark); status pills use the theme's status tokens.

## Flutter notes

**Path of least resistance: A.** Nearly everything already exists.

- Mobile sheet: `BanxaPaymentWebView` (`lib/banxa/banxa_payment.dart`) already has a
  `webview_flutter` `NavigationDelegate` whose `onNavigationRequest` pops when the URL
  contains `redirectUrl`. `BanxaApiService.redirectUrl` is `geniuswallet://banxa/callback`.
  Moving it from a pushed route into `showModalBottomSheet(isScrollControlled: true)` plus a
  `PopScope` for the leave prompt is the main change.
  Watch out: Banxa is sent `geniuswallet://banxa/callback?extOrderId=...`
  (`banxa_api_services.dart`), but `create_order_cubit.dart:225` stores
  `yourapp://banxa-callback` in state, and that stored value is what the buy screen hands the
  delegate to match. As wired today the in-app WebView would never see its callback.
- Desktop: `url_launcher` with `LaunchMode.externalApplication` is what the options sheet
  does now. The waiting card is `BanxaPaymentWebView`'s Linux branch ("Payment opened in
  your browser", "Re-open in Browser", "Done") grown into a card with polling. The deep link
  back needs the `geniuswallet://` scheme registered per OS. `app_links` is already a
  dependency and macOS `Info.plist` declares the scheme; no Windows or Linux registration was
  found in this checkout. Without it, "I've paid, check status" and polling are the return.
- Polling: `PollingCubit` exists but only the QR page uses it, and it waits for `completed`
  and `failed`, which Banxa never sends. It needs Banxa's real statuses (`complete` is the
  only final success; `paymentReceived` is not done).
- **B** is `webview_flutter` everywhere. On Windows that means `webview_windows` (already a
  dependency) behind the same widget; macOS uses WKWebView. Linux has no implementation, so
  Linux falls back to A's desktop path anyway.
- **C** on mobile is `flutter_custom_tabs` (or `url_launcher` with
  `LaunchMode.inAppBrowserView`, which uses Custom Tabs on Android and SFSafariViewController
  on iOS). The app resumes on its own page, so the tracker needs no route change, but the
  close cannot be intercepted.

**Platform caveats from the research:**

- Google Pay does not work in a plain Android WebView. If Banxa offers Google Pay, Android
  needs Custom Tabs (C's mobile path), which also means A's and B's Android sheet loses the
  leave prompt.
- Apple Pay and iDEAL fail inside an iframe. A `WKWebView` on iOS 15+ is fine; B's
  "Open in browser" menu item is the escape hatch if a method still refuses to load.
- The WebView needs camera, microphone, DOM storage and autoplay for Banxa's liveness check
  (the ID check step). Android needs `onPermissionRequest` handled; iOS needs the camera and
  microphone usage strings.

## Not matched to the real app

- **"Processing payment"** is not a label the app has. `BanxaHelpers.getOrderStatusLabel`
  maps only `pendingPayment`, `completed`, `declined`, `inProgress` and `expired`; Banxa's
  `waitingPayment`, `paymentReceived`, `cryptoTransferred` and `complete` fall through to the
  raw string. The sketch uses "Processing payment" for the post-payment states and keeps the
  real "Pending Payment", "Declined", "Complete Payment" and "Retry Order".
- **Disclaimer copy** is rewritten. The real text starts "You are now leaving GeniusWallet",
  which is false for an in-app sheet. The sketch keeps the Banxa terms line and the "I have
  read and agree" checkbox from `disclaimer_dialogue.dart`, adds Cancel, and changes the
  first sentence by variant.
- **The "Verify with Banxa" button** on the Buy page header is left out (research: KYC
  stays inside checkout).
- **Buy page and navbar** are abbreviated from 167 L3 and the real nav destinations. The
  fiat and crypto pickers are drawn as static inputs; GNUS is not yet listed by Banxa for
  partner `gnus` (ROADMAP Phase 39 blocker), so the amounts are illustrative.
- **Receipt drawer title** "GNUS purchase" is a placeholder; the real drawer comes from
  `showTransactionDetails` with the order's row content.
- **30-minute expiry** is taken from the brief, not measured against Banxa.
