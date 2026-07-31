---
sketch: 167
name: banxa-buy-flow
question: "What is the Buy GNUS page, how does it fill the page frame, and what of it already exists in code?"
winner: "L3 · Form on top, orders below full width (chosen 2026-07-30 by Jakub)"
supersedes_design_of: [157]
tags: [banxa, buy, fiat, orders, kyc, checkout, page-layout, readiness]
---

# Sketch 167: Buy GNUS / Banxa — the whole flow

- `index.html` — 6 flow schemes × 6 screens (36 combinations)
- `layout.html` — 5 page layouts, drawn inside the real page frame ← **L3 chosen**

## Page frame (not a choice — it is the app's rule)

```
Align(topCenter) → Padding.fromLTRB(12, space32=64, 12, space8=16) → ConstrainedBox(1536)
```

Recorded as Jakub's own call in `transactions_screen.dart:71-90`: *"all three left-align to the
window with a 12px gutter and an xxl cap, so the page title lands at the same X on every content
page."* Used by Transactions, Markets, News and the coin page.

The app has **two** page archetypes on that frame:

| | Archetype | Who uses it |
|---|---|---|
| A | **Content page** — header left, content full 1536 | Transactions, Markets, News, coin page |
| B | **Focused form** — nested `ConstrainedBox(560)` + `GWPageHeader(centered: true)` | Swap (`swap_screen.dart:634, 654`), Feedback |

Buy is a form (B) that also owns a history (A). **That collision is the layout question.**

## ✅ CHOSEN: L3 — form on top, orders below full width

Two-column form block (form left, verification + live summary right), then the order history as a
full-width table with counted status filters. Archetype A, stacked.

---

## Readiness — what exists, what does not

**Verified by reading the code, not assumed.**

### Already there

| Piece | Where |
|---|---|
| Fiat / crypto / payment-method lists | `MakeOrderCubit.loadCurrencies`, `selectFiat/selectCrypto/selectPaymentMethod` |
| Amount input wiring | `MakeOrderCubit.setAmountText` (`:131`) |
| Quote fetch | `MakeOrderCubit.getQuote()` (`:148`) |
| Order creation | `MakeOrderCubit.createOrder()` (`:202`) |
| CTA enablement rules | `canGetQuote`, `canCreateOrder` (`create_order_state.dart:153-155`) |
| Order list + **status filtering** | `OrdersCubit.applyFilters({status, startDate, endDate})` (`banxa_order_cubit.dart:87-95`) |
| 4-bucket status→colour ladder | `orderStatusTone()` / `orderStatusPaint()` (`order_status_style.dart:13-60`) |
| Order row | `OrderCard` (`banxa_components/order_card.dart`) |
| Checkout polling | `PollingCubit`, mounted at `router.dart:137-166` |
| QR | `CryptoAddressQr` (`qr/crypto_address_qr.dart`) |
| KYC submit | `BanxaApiService.submitKYC` (`banxa_api_services.dart:36`) |

### Missing — five items, one of them real

| # | Gap | Kind | Notes |
|---|-----|------|-------|
| 1 | **Verification status cannot be read** | ⚠ **backend/state — the real one** | `submitKYC` posts and returns `accountId` + `accountReference`; **nothing stores or reads back whether this user is verified.** A repo-wide search for `isVerified` / `kycStatus` / `verificationStatus` finds only the onboarding recovery-phrase flow, which is unrelated. So L3's "Verified with Banxa" pill **has no data source today.** |
| 2 | Per-status counts (`All · 4`, `Pending · 1`) | derivation | `applyFilters` filters but nothing counts. A `groupBy` over `state.orders`. Cheap, but does not exist. |
| 3 | Live quote instead of a manual "Get Quote" | cubit behaviour | `getQuote()` is button-triggered. L3's summary panel implies it updates as you type — needs a debounce on amount/selection change. |
| 4 | Orders **table** | markup | `MarketsTable` is Markets-specific (`MarketRow`, `CoinGeckoCoin`) and cannot be reused. The new table is a `Column` of rows built from existing primitives, exactly how `markets_table.dart` is built — **not** a new shared component. |
| 5 | `/buy` route target | one line | `router.dart:80` currently mounts `OrdersPage`. |

### New components: zero

Everything on L3 composes from shipped components: `GWPageHeader`, `GWCard`, `GWSelect`,
`GWTextField`, `GWButton`, `GWDetailGrid`, `GWKicker`, `GWStatusDot`, `GWEmptyState`,
`GWErrorState`, `GWViewAllLink`, `OrderCard`, `CryptoAddressQr`.

Two existing surfaces get *upgraded* rather than built:
- **Three raw Material `DropdownMenu`s → `GWSelect`** (`banxa_buy_screen.dart:174/196/218`).
- **Two raw `TextField`s → `GWTextField`** (`banxa_buy_screen.dart:240, 323`).

Banxa is the app's only surface still using bare Material inputs.

### Dead code to delete

`QuoteCard` (`banxa_components/quote_card.dart:8`) — its own header says a search for an
instantiation "turns up nothing outside this" file. If the live-quote summary (gap 3) lands, this
is what it replaces.

---

## Decide before planning

1. **Gap 1 is a fork.** Either (a) persist the KYC account reference locally after `submitKYC` and
   treat its presence as "verified" — cheap, and wrong the moment Banxa rejects or expires a
   verification; or (b) add a status read to `BanxaApiService` — correct, needs an endpoint;
   or (c) **drop the verification card from L3's right column for now** and let the buy attempt
   surface it. (c) is the only one that ships without new backend work.
2. **Live quote or keep the button.** Gap 3 changes cubit behaviour and affects rate limits.
3. **Phase 9's three unclosed criteria are untouched by this design** — see
   `.planning/phases/09-banxa/09-OUTSTANDING.md`. Notably the **KYC redirect blocker**: 09-06
   proved the redirect-matching logic byte-identical to what shipped before the phase. A layout
   decision does not close it.
