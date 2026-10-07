# Phase 39 — Banxa buy flow: how other wallets do it

Researched 2026-09-30. Sources are cited inline; claims marked "excerpt" came from search snippets because the vendor page would not load.

## Our flow today

- `/buy` is opened from Home, Markets and the coins list with only an `origin`, so the **wallet address field starts empty** and the user pastes their own.
- One card: fiat, payment method, amount chips, crypto, address. "Get quote" fills You receive / Rate / one summed "Banxa fee", then the button becomes "Buy GNUS".
- A leave-the-app disclaimer, then `POST /v2/buy`, then a sheet asking: Open in Browser, Show QR, or Copy link.
- An in-app checkout WebView exists at `/checkout` but nothing opens it.
- KYC is a separate button that opens `gnus.banxa-sandbox.com` while orders go to production. Banxa already runs KYC inside checkout.
- Only the QR page polls status, and it waits for `completed` / `failed`, which Banxa never sends (`complete`, `declined`, `expired`, `refunded`, `cryptoTransferred`, `extraVerification`).
- `BuySuccessDrawer` / `BuyCancelledDrawer` are reachable only from the dev bubble.
- `externalCustomerId` is derived from the wallet text; Banxa says to use a stable internal user id.

## Other wallets

| App | Providers | Provider choice | Quote / fees | Checkout | Tracking |
|---|---|---|---|---|---|
| MetaMask | 16 incl. Banxa, MoonPay, Transak [1][2] | Auto default; "Best rate", "Most reliable", "Previously used" tags; last provider reused to skip KYC [3][4] | Quote refreshes every 10 s; processing and network fee split [1] | Mobile: in-app WebView, "Back to app" closes it [5]. Extension: browser tab, callback reopens Activity [6] | Pending entry in Activity, polls to final state, "View on provider" [6][7] |
| Ledger Wallet | 10+ incl. Banxa [13][14] | All quotes side by side [13] | Amount after fees plus full breakdown [13] | Provider app embedded, given address, asset, amount, theme, session id [15] | By session id [15] |
| Phantom | 8 via Meld [16] | Sorted by price, last provider default, arrival time [16] | Review step with method, provider, fees [17] | Not confirmed | History [17] |
| Exodus | Banxa (mobile), MoonPay, Ramp and others [10][11] | Best rate auto, switchable [11] | Not confirmed | Not confirmed | Buy & Sell > History > order details [11][12] |
| Trust Wallet | Banxa, MoonPay, Ramp, Transak and others (excerpt) [8] | Best rate after amount (excerpt) [9] | Provider fees only (excerpt) | Not confirmed | Not confirmed |
| Coin98 | Banxa, MoonPay [18][19] | Best rate flagged [18] | Not confirmed | Provider handles email, KYC, payment [18] | Not confirmed |

## Banxa's guidance

- Redirect supports every payment method; WebView keeps users in-app but needs setup [25][26].
- WebView: Chrome Custom Tabs on Android if Google Pay is offered; camera, mic, DOM storage, autoplay for liveness; WKWebView on iOS 15+; Apple Pay and iDEAL fail in an iframe [26][27].
- Fetch quotes right before showing them, never cache; prefill everything; stable `externalCustomerId` [28].
- Only `complete` is final; `paymentReceived` is not [29]. Webhooks are HMAC-signed, retried, may duplicate [30].
- API calls are meant to be server-side; no key in the client [24].

## Patterns worth copying

1. Prefill the address from the wallet being viewed (MetaMask, Ledger, Coin98).
2. One all-in "You get X GNUS" first, fee lines underneath, quote refreshing on a timer instead of Get quote then Buy (Ledger, MetaMask).
3. Choose checkout by platform: in-app WebView on mobile, browser plus callback on desktop; QR and copy link as a secondary "pay on another device" (MetaMask, Ledger).
4. Drop the separate KYC button; KYC stays inside checkout (every wallet reviewed, Banxa).
5. Show the order in the main activity list with live status for every open order; map Banxa's real statuses; show the success and cancel drawers (MetaMask, Exodus, Phantom).
6. A reliable return trip: callback reopens the order, or a "Done, check status" button (MetaMask desktop).
7. On failed, expired or refunded orders, show the Banxa order id with copy and a support link (Exodus, MetaMask, Ledger).
8. If more providers come later: MetaMask's tags and last-used default, Phantom's price sort. No aggregator now.

## Avoid

- A three-way browser / QR / link choice before paying.
- The API key in the client.
- Treating `paymentReceived` as done, or matching status names Banxa doesn't send.
- A plain Android WebView with Google Pay, or an iframe with Apple Pay / iDEAL.
- A disclaimer on every buy; once is enough.
- A quote that goes stale between Get quote and Buy.

## Sources

[1] https://support.metamask.io/manage-crypto/move-crypto/buy/how-to-buy-crypto-in-metamask/ · [2] https://support.metamask.io/manage-crypto/move-crypto/buy/providers-and-payment-methods/ · [3] https://github.com/MetaMask/metamask-extension/pull/46414 · [4] https://github.com/MetaMask/core/pull/10536 · [5] https://github.com/MetaMask/metamask-mobile/pull/31534 · [6] https://github.com/MetaMask/metamask-extension/pull/46394 · [7] https://support.metamask.io/manage-crypto/move-crypto/buy/faqs/ · [8] https://support.trustwallet.com/support/solutions/articles/67000742988 · [9] https://trustwallet.com/buy-crypto · [10] https://www.exodus.com/support/en/articles/9550710-how-do-i-buy-crypto-with-banxa-in-exodus · [11] https://www.exodus.com/support/en/articles/8598616-how-can-i-buy-bitcoin-and-crypto · [12] https://www.exodus.com/support/en/articles/8598908 · [13] https://www.ledger.com/academy/topics/ledger-wallet/buy-crypto-guide · [14] https://banxa.com/partner/ledger/ · [15] https://developers.ledger.com/docs/ledger-live/exchange/buy/providers-liveapp · [16] https://phantom.com/learn/blog/buying-crypto-in-phantom-just-got-faster-and-easier · [17] https://help.phantom.com/hc/en-us/articles/4406543783571 · [18] https://docs.coin98.com/products/coin98-super-wallet/mobile/getting-started/how-to-buy-cryptocurrency-by-fiat-1 · [19] https://banxa.com/press/banxa-launches-on-viction-ecosystem-with-coin98-super-wallet-first-to-go-live/ · [24] https://docs.banxa.com/products/hosted-checkout/docs/api-integration/api-integration-overview · [25] https://docs.banxa.com/products/hosted-checkout/docs/getting-started/choose-visualisation · [26] https://docs.banxa.com/docs/checkout-approaches · [27] https://docs.banxa.com/products/hosted-checkout/docs/checkout-experience/iframe/webview-mobile · [28] https://docs.banxa.com/products/hosted-checkout/docs/getting-started/integration-best-practices · [29] https://docs.banxa.com/products/hosted-checkout/docs/transaction-lifecycle/order-statuses · [30] https://docs.banxa.com/docs/webhooks
