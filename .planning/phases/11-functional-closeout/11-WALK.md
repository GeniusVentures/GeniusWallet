---
phase: 11
name: Functional closeout
status: ready
created: 2026-09-16
---

# Does the wallet actually work?

The last several phases changed how the app looks. This one asks whether it does anything.

Walk it in the order below — that is the order a new user meets the app. Mark each row
**works / broken / partly**, and write one line when it is not "works". Nothing else.

Build under test: Windows desktop, `flutter run -d windows --debug`.

---

## Section 0 — Do NOT test these

Already proven broken by reading the code. Testing them just re-confirms it. They need a
decision, not a walk.

| # | Feature | What the code does | Decision needed |
|---|---|---|---|
| 0.1 | **Swap** | ~~Fabricated a `completed` transaction with a green receipt.~~ **Resolved by Phase 26 (2026-09-17):** live Squid v2 quotes and execution; a real swap ran on Base mainnet and an underfunded one failed honestly. Walk it as a normal row now (4.8), not a Section 0 item. | Decided: wired. |
| 0.2 | **Send** | `wallet_information.dart:181` — `onPressed: null`, "No send flow yet". | Build it, or accept a wallet that cannot send. |
| 0.3 | **dApp connect** | `reown_walletkit` is missing from `windows/flutter/generated_plugins.cmake`. Init throws; the button still renders enabled and tells the user to restart, which never helps. | Register the plugin, or hide the button on Windows. |
| 0.4 | **Banxa KYC + checkout** | Both webviews special-case only `Platform.isLinux`, then build a `webview_flutter` controller that has no Windows implementation. | Route Windows to the system browser (the "Open in Browser" path already exists). |
| 0.5 | **Address book** | Does not exist. | Confirm it is not expected. |

---

## Section 1 — First run

Delete the wallet first (see the fresh-install recipe — `GW_DATA_DIR` does not work).

| # | Feature | Do this | Works means |
|---|---|---|---|
| 1.1 | Splash / boot | Launch cold | Reaches landing without a hang or exception |
| 1.2 | Landing | — | Both "Create" and "Import" are live |
| 1.3 | Create wallet | Accept legal → set PIN → confirm | Advances to the recovery phrase |
| 1.4 | Recovery phrase | Reveal, copy | 12 real words, copy puts them on the clipboard |
| 1.5 | Verify phrase | Tap the words in order | Wrong order is rejected; right order proceeds |
| 1.6 | Wallet lands | — | Dashboard opens with the new wallet selected |
| 1.7 | Import — mnemonic | Restart fresh, import a known phrase | Same address as the source wallet |
| 1.8 | Import — private key | As above, key tab | Imports, or fails with a readable reason |
| 1.9 | Import — keystore JSON | JSON + password | Imports, or fails with a readable reason |
| 1.10 | Import — watch-only | Paste an address | Imports read-only |
| 1.11 | Wallet type choice | Open the type picker | Only Ethereum is offered — confirm that is intended |
| 1.12 | PIN gate | Restart the app | PIN is demanded, wrong PIN refused |

## Section 2 — Dashboard

| # | Feature | Do this | Works means |
|---|---|---|---|
| 2.1 | Balance | — | Shows a real balance, not 0 or blank |
| 2.2 | Fiat subline | — | **Known stub:** hardcoded `''`. Confirm it stays empty |
| 2.3 | Assets panel | — | Lists held tokens with real amounts |
| 2.4 | Assets page | "View all" | Opens `/assets`, search and value sort work |
| 2.5 | Hero chart | — | **Known stub:** hardcoded to `bitcoin` regardless of wallet |
| 2.6 | Timeframe tabs | 1H/1D/1W/1M/1Y | Do they redraw, or are they decoration? |
| 2.7 | Markets panel | — | Real prices; "View all" opens `/markets` |
| 2.8 | News panel | — | Real headlines |
| 2.9 | Transactions panel | — | Real history for this wallet |
| 2.10 | Pull to refresh | Pull down | Refetches; no duplicate rows |
| 2.11 | Error + Retry | Kill the network, reload | Shows an error with a working Retry — not silence |
| 2.12 | One scroll | Resize to phone width | One scroll, no nested scroll trap, no overflow stripes |

> A `RenderFlex overflowed by 35 pixels on the bottom` fires in `ChartDashboardView` at the
> current window size. Capture the width it happens at.

## Section 3 — Accounts, networks, compute

| # | Feature | Do this | Works means |
|---|---|---|---|
| 3.1 | Wallet switcher | Switch wallets | Balance, assets and transactions all follow |
| 3.2 | Rename / delete wallet | — | Persists across restart |
| 3.3 | Copy address | — | Clipboard matches the shown address |
| 3.4 | Add wallet | — | Returns to landing, second wallet coexists |
| 3.5 | Network switcher | Change network | Toast fires and balances re-read |
| 3.6 | SDK accounts | Add, set active, set payout | Each persists |
| 3.7 | Recovery phrase / QR | From SDK account manager | Matches the wallet's real phrase |
| 3.8 | Node status | `/network` | Reports real connectivity, not a fixed string |
| 3.9 | Compute panel | — | Reflects real SDK state |
| 3.10 | GNUS ↔ MIN toggle | Flip it | Converts correctly |
| 3.11 | Stalled node | Leave a node hung | **Known gap:** shows "starting" forever, no timeout |

## Section 4 — Money movement

The rows that matter most. Use small amounts on a real network.

| # | Feature | Do this | Works means |
|---|---|---|---|
| 4.1 | Receive QR | Open from three places | All three show the same, correct address |
| 4.2 | Bridge out | Bridge a small GNUS amount | Gas quote is real; funds arrive; receipt matches the chain |
| 4.3 | Bridge destination | Open the picker | **Known stub:** `destinationChainId` hardcoded — confirm the blast radius |
| 4.4 | Submit job — quote | Open `/submit_job` | Cost quote comes from the SDK |
| 4.5 | Submit job — top-up | Trigger the gas/bridge top-up | Runs, or fails loudly |
| 4.6 | Submit job — run | Submit | Progresses through the real steps and completes |
| 4.7 | Job failure | Force one | Surfaces an error and the "Get help" path works |
| 4.8 | Swap | ETH → USDC on Base 8453, small amount | Live quote; hash resolves on basescan; stored row matches the chain; an underfunded send says so and stores nothing (both walked 2026-09-17 — see `26-06`/`26-07-SUMMARY.md`) |

## Section 5 — Buy (Banxa)

Sections 0.4 blocks the webviews; test what is reachable.

| # | Feature | Do this | Works means |
|---|---|---|---|
| 5.1 | Buy form | Open `/buy` | Fiat/crypto/payment lists populate from the API |
| 5.2 | Live quote | Enter an amount | "You get / Rate / Fee" are real and update |
| 5.3 | Create order | Submit | A real order id comes back |
| 5.4 | Browser handoff | "Open in Browser" | Opens the correct checkout |
| 5.5 | Checkout QR | Desktop path | Scannable, correct link |
| 5.6 | Order history | `/buy/orders` | Real orders; status filters and date range work |
| 5.7 | Order details | Open one | Matches Banxa; Retry works |
| 5.8 | Deep-link return | Return via `genius://` | App resumes on the right order |

> `banxa_api_services.dart` points KYC at **sandbox** and orders at **production**. Check
> whether an order can ever reach a verified state.

## Section 6 — Everything else

| # | Feature | Do this | Works means |
|---|---|---|---|
| 6.1 | Transactions page | — | Real history, correct direction and amounts |
| 6.2 | Filters | Each chip | Counts match the rows shown |
| 6.3 | Token detail | Open a token | Price, chart and stats are real |
| 6.4 | Contract copy | — | Copies the real contract |
| 6.5 | Convert calculator | Type an amount | USD total is right |
| 6.6 | Markets sort | Tap each header | Sorts correctly both ways |
| 6.7 | News | Search, refresh, open | Filters, refetches, opens the article |
| 6.8 | In-app browser | Navigate, tabs, back/forward | All work; tabs close cleanly |
| 6.9 | Feedback | Send with logs attached | Arrives — **known gap:** log attachment is commented out in `main.dart` |
| 6.10 | Settings | Change a log level, save overrides | Written to disk and survive restart |
| 6.11 | Mobile nav | Resize to phone | 4 tabs + Swap dock; More sheet reaches all 8 destinations |

---

## What comes out of this

One line per broken row, collected into `11-FINDINGS.md`. Each finding becomes a fix plan or a
written acceptance. The phase closes when every row is **works** or consciously accepted.

**Do not** fix things during the walk. Walk first, then plan the fixes — a fix mid-walk
invalidates the rows already passed.
