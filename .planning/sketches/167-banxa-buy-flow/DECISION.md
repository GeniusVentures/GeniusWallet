# DECISION — Buy GNUS / Banxa · APPROVED

**Status:** ✅ **APPROVED by Jakub, 2026-07-30.** Ready to plan and execute.
**Design source:** `.planning/sketches/167-banxa-buy-flow/final.html`
**Not yet executed.** No Dart has been written. Nothing in `lib/` has changed.

> Written into the sketch directory, not `STATE.md` / `ROADMAP.md`, because a second session
> (Braian) is mid-PR on this repo. Fold into `ROADMAP.md` when that PR lands.

Supporting files, in the order they were produced:
`index.html` (6 flow schemes × 6 screens) → `layout.html` (5 page layouts, L3 chosen) →
`layout-v2.html` (L3 revised against the code) → `layout-v3.html` (orders moved beside the form,
4 options) → **`final.html` (the approved combination)**.

---

## What was approved

**Page:** `/buy` becomes the buy form. Two columns on the app's shared page frame.

```
Align(topCenter) → Padding.fromLTRB(12, space32=64, 12, space8=16) → ConstrainedBox(1536)
```

The same frame as Transactions / Markets / News / coin page — recorded as Jakub's own call in
`transactions_screen.dart:71-90`.

| Region | Content |
|--------|---------|
| **Header** | `Buy GNUS` / `Powered by Banxa`, with **`Verify with Banxa`** on the right |
| **Left column** | Amount field, quick-amount chips ($100/$500/$1,000/$5,000), `Currency`, `Payment method`, the quote grid (You get / Rate / Banxa fee), one CTA |
| **Right column** | `Your orders` — `View all`, counted filters (`All · 4`, `Pending · 1`, `Done · 2`), four rows with status pill, date, `paid → received`, chevron |

## The three decisions that make it buildable

### 1 · One CTA, two roles

`getQuote()` and `createOrder()` are separate calls behind separate guards
(`create_order_cubit.dart:148, 202`; `create_order_state.dart:153-155`). The design shows **one**
button, so the button changes role rather than multiplying:

| State | Label | Guard |
|-------|-------|-------|
| no quote yet | **Get quote** | `canGetQuote` |
| quote present | **Buy GNUS** | `canCreateOrder` |

The quote grid is rendered in **both** states — em-dash placeholders before, values after. Two
consequences, both deliberate: the card never changes height (so the orders rail beside it never
shifts), and the app never prints a fabricated `$0.00` rate it does not have.

### 2 · No verification STATUS anywhere

`BanxaApiService.submitKYC` (`banxa_api_services.dart:36`) posts KYC data and returns
`accountId` + `accountReference`. **Nothing stores or reads back whether this user is verified** —
a repo-wide search for `isVerified` / `kycStatus` / `verificationStatus` finds only the onboarding
recovery-phrase flow, which is unrelated.

So the header carries an **action** (`Verify with Banxa`), never a status pill. An action asserts
nothing about state and therefore cannot be wrong.

**Parked, not deleted:** if a status endpoint is ever added, `layout.html`'s verification card is
the design to restore.

### 3 · The header's orders link was dropped

The synthesis screenshot carried `Your orders · 3` in the header. With the rail in the right
column that link pointed at something already on screen. Its slot now carries `Verify with Banxa`,
which had nowhere else to live once the verification card was cut.

---

## Cost: zero new components

| Composed from | Already ships |
|---|---|
| `GWPageHeader`, `GWCard`, `GWKicker`, `GWButton`, `GWDetailGrid`, `GWSelect`, `GWTextField`, `GWStatusDot`, `GWEmptyState`, `GWErrorState`, `OrderCard` | ✓ |

**Two upgrades, not builds.** Banxa is the app's only surface still using bare Material inputs:
- three raw `DropdownMenu` → `GWSelect` (`banxa_buy_screen.dart:174, 196, 218`)
- two raw `TextField` → `GWTextField` (`banxa_buy_screen.dart:240, 323`)

**Delete:** `QuoteCard` (`banxa_components/quote_card.dart:8`) — its own header says a search for
an instantiation "turns up nothing outside this" file.

## Logic: already there

`MakeOrderCubit.loadCurrencies / selectFiat / selectCrypto / selectPaymentMethod / setAmountText /
getQuote / createOrder`, `canGetQuote`, `canCreateOrder`,
`OrdersCubit.applyFilters({status, startDate, endDate})`, `orderStatusTone()` /
`orderStatusPaint()`, `OrderCard`, `PollingCubit`, `CryptoAddressQr`.

## Missing: two, both small

| # | Gap | Kind |
|---|-----|------|
| 1 | Per-status counts (`All · 4`, `Pending · 1`, `Done · 2`) | a `groupBy` over `state.orders` — the data exists, only the derivation is new |
| 2 | `/buy` route target | one line: `router.dart:80` currently mounts `OrdersPage` |

**No backend work.** This design ships against the API surface that exists today.

---

## Out of scope — and it must stay recorded

Approving this **does not close Phase 9.** `.planning/phases/09-banxa/09-OUTSTANDING.md` holds
three unmet ROADMAP criteria, untouched by any layout decision:

1. **KYC redirect blocker.** Completing KYC does not pop the webview and return success; 09-06
   proved by diff that the redirect-matching logic is byte-identical to what shipped before the
   phase. **This is a behaviour fix in `kyc_registration.dart` / `banxa_payment.dart`.**
2. **Checkout QR has never been scanned** with a real camera, in either appearance.
3. **The order-details status banner has never been seen** painted from a real redirect round
   trip; the tone mapping is proven only against synthetic strings.

Also still true: no end-to-end buy has ever been walked (09-CONTEXT D-03).

## Screens beyond this page

`index.html`'s synthesis scheme covers the rest of the flow and is approved as direction, not yet
as detail: KYC as a conditional step rather than a separate destination, checkout with the QR
desktop handoff, per-status actions on order details, and the fixed orders history. Those need
their own pass before planning.
