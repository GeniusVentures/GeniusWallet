# Phase 39 — Context (decisions)

Decided by Braian on 2026-09-30. Research: `39-RESEARCH.md`, `39-UX-RESEARCH.md`. Sketches: 080, 081, 082.

## Locked decisions

- **D-01:** Banxa key stays in the app for now. No proxy or server exists and none is built this phase. The key leaves the committed source: it is supplied at build time (`--dart-define`), never printed, never in Sentry breadcrumbs. Rotating the already-leaked key is a Banxa dashboard task for Braian, outside the code. A proxy is a later phase.
- **D-02:** GNUS only. No crypto picker. If Banxa's coin list has no GNUS, the page shows a clear "not available yet" state instead of the form (design at planner's discretion, inside sketch 080 A's card).
- **D-03:** The receiving address is the Selected wallet's, read at tap time, shown as name + short address with a "change" link to the account switcher. No address text field.
- **D-04:** Watch-only (tracking) wallets are blocked. Buy is disabled for them with a one-line reason.
- **D-05:** Buy page = sketch 080 A, compact card. Fiat defaults from locale with a change link; payment method row only when the currency offers more than card; one "You get ~X GNUS" figure with processing and network fee lines; live quote refresh; presets scale per currency.
- **D-06:** Checkout = sketch 081 B, full-screen in-app checkout with a slim header and Order > Pay > Done progress; "pay on another device" (QR + copy link) in the header menu. KYC stays inside Banxa's checkout; the separate KYC button and sandbox KYC WebView go. Order status polling is the source of truth for Done; the return URL is a shortcut.
- **D-07:** Orders = sketch 082 C. Banxa orders appear in Transactions behind a "Buy orders" filter chip; one app-level poller for every open order; Banxa's real status names mapped once (`complete` is success).
- **D-08:** Entry points. An easy way into Buy GNUS from the main surfaces, and a link from Buy GNUS to Transactions with the Buy orders filter pre-selected.
- **D-09:** Sandbox mode is switched at build time, like `GW_DEV_TOOLS`, so a sandbox build can complete a whole buy. The sandbox key is not available yet; automated tests use a fake API.

## Claude's discretion

Return URL shape, Google Pay/Custom Tabs rule, expired-order polling window, SGNUS-wallet order display, `externalCustomerId` (keep `gw-<address>`), final-state surface, filter label wording, wave order.

## Deferred

- Proxy/server for the Banxa key.
- Always-available Bridge button (phase 40).
