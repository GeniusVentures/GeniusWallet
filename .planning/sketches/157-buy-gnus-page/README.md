---
sketch: 157
name: buy-gnus-page
question: "What is the Buy GNUS flow actually made of, what is broken in it, and what should the page be? The CTA labelled Buy GNUS opens the order history."
winner: null
tags: [banxa, buy, fiat, orders, kyc, page-layout, routing, empty-state, data-honesty, auto-generated]
lane: B
---

# Sketch 157: Buy GNUS - the flow, the defects, and five redesigns

Jakub, 2026-07-27: *"buy genius - caly redesign tej strony - analiza co tam jest i tak dalej? jaki logic and
so on"*.

Half analysis, half proposal, in that order - because **the biggest problem on this screen is not visual**
and no re-skin fixes it.

## The headline finding

**The button labelled "Buy GNUS" does not open a buy screen.**

`coins_screen.dart:349` pushes `/buy`. `router.dart:80` maps `/buy` to `OrdersPage` - the order *history*.
The screen that actually buys something is `BanxaBuyScreen` at `/createOrder`, and the only way in is a small
text action in the AppBar labelled **"+ New Order"**.

So a user with no orders taps a gradient CTA promising a purchase and lands on

```
Total Orders: 0
No orders found.
```

which is exactly the screenshot. **This is a one-line routing fix, and it is worth more than everything else
in this sketch put together.**

## How to View

```
open .planning/sketches/157-buy-gnus-page/index.html
```

Deep links `#a` .. `#e`. Toolbar: six page variants and a **Has orders / Empty** data toggle. Judge on
**Empty** - that is where today's page fails hardest and where the variants differ most. Section 1-3 of the
page are the analysis (flow map, route table, logic table, 14 numbered defects); section 4 is the variants;
section 5 is the `/banxa` constraint and the way through it.

## The flow, as it really runs

```
Buy GNUS  ->  /buy (OrdersPage)  ->  "+ New Order"  ->  /createOrder (BanxaBuyScreen)
   ->  Get Quote  ->  Create Order  ->  /checkout (webview) or /checkoutQR (finish on phone)
   ->  geniuswallet://banxa/callback  ->  /banxa/callback -> OrderDetailsPage (PollingCubit)
```

Seven routes, all of them **outside `ShellRoute`**, so none of them has the navbar.

| Layer | Files | Status |
|---|---|---|
| Models | `banxa_model.dart` (`Order`, `Quote`, `FiatCurrency`, `Blockchain`) | generated, keep |
| Service | `banxa_api_services.dart` | generated, keep |
| Cubits | `OrdersCubit`, `MakeOrderCubit`, `PollingCubit` | generated, keep |
| Widgets | `banxa_orders_history.dart`, `order_card.dart`, `order_details_card.dart` | generated, **and the only thing a redesign needs** |
| Widgets, outside the fence | `screens/banxa_buy_screen.dart` | editable today |

## Fourteen defects found in the code

1. **The CTA lies** - "Buy GNUS" opens order history (`coins_screen.dart:349` -> `router.dart:80`).
2. **The customer id is a placeholder** - `fetchOrders('your-cust-id')`, hardcoded at **two** call sites
   (`:33` init, `:122` refresh). The list cannot show a real user's orders in any build.
3. **Three status vocabularies.** Filter offers `pendingPayment / completed / declined / inProgress /
   expired`; `_getStatusColor` handles `completed / pendingpayment / pending / declined / cancelled`; the
   banner handles `cancel / failure / success`. **`inProgress` and `expired` get no colour; `cancelled` gets
   a colour but cannot be filtered.**
4. **No design tokens at all** - `Colors.green/orange/red/grey`, `Colors.grey[700]`, a 1.5px
   `lightGreenSecondary` card border. Nothing on this page flips with the appearance.
5. **The empty state reads as a failed load** - two bare strings, top-centre, over an empty page. Against the
   MANIFEST's own rule for this round.
6. **"Total Orders" counts the filtered list** - filter to Declined and the total changes.
7. **No navbar** - all seven routes sit outside `ShellRoute`. Same defect sketch 061 found on the coin page.
8. **A card grid for what is a ledger** - `mainAxisExtent: 300`, min column 294, so five columns at 1536.
   Sketches 021/022 already settled that this app renders a ledger as a list plus a filter rail.
9. **Real data thrown away** - `Order` carries `processingFee`, `networkFee`, `transactionHash`,
   `walletAddress`, `country`, `metadata`; the card shows none of them. A completed purchase cannot be opened
   in an explorer although its hash is in hand.
10. **No pagination** although `OrdersResponse` parses `total` and `pageTotal`.
11. **The date picker is a raw Material `showDateRangePicker`** - every other picker in this app is a
    `ResponsiveDrawer`.
12. **The buy form never validates against `Blockchain.minimum`**, which it already parses.
13. **The swap FAB floats over the whole purchase flow** - `_hiddenPaths` covers `/checkout`, `/checkoutQR`,
    `/kyc`, `/banxa/callback` but **not** `/buy`, `/createOrder`, `/orderDetails`.
14. **KYC is an unlabelled icon** - a person-badge `IconButton` to `/kyc`, with no indication of whether
    verification is needed, pending or done. A fiat purchase can fail on exactly that.

## Variants

- **0 · Today** - literal render, including the empty state.
- **A · Buy first ★** - `/buy` becomes the buy form; order history moves to a counted secondary link. Rail
  carries verification state and recent orders.
- **B · Form + rail** - the shape 062-A chose for Swap, applied here so Buy and Swap read as siblings. Best
  use of a 1536 frame, worst empty state.
- **C · Drawer** - Buy GNUS opens the 063-A form drawer instead of a page. Cheapest chrome; nowhere to put
  history, and a lot of consequence for 420px.
- **D · Stepper** - sketch 018-A's vertical steps (already this project's choice for the job flow). Makes
  "Get Quote" disappear as a concept and carries KYC as a conditional step.
- **E · Orders, fixed** - the ledger shape, a filter rail with real counts, per-status row actions, and an
  empty state that reads as ready.

## Recommendation

**★ A · Buy first, plus E · Orders fixed.** They are not rivals; A decides what `/buy` *is*, E decides what
the history *looks like* wherever it lives. Ship in that order, because A is a routing change and E is a
rebuild.

The order of value, honestly:

1. **Repoint `/buy` to the buy screen** (or add a `/buy/new`). One line. Fixes the defect a user hits first.
2. **Put the Banxa routes inside `ShellRoute`** so the navbar exists (defect 7). Second-cheapest, second-most
   noticeable.
3. **Fix the customer id** (defect 2). Until this is real, no design of the order list can be judged on real
   data - which is also why every variant here is drawn in both states.
4. **Then E**, the list rebuild, and **then A's rail** (verification + recents).

**Runner-up: D · Stepper.** It is the better long-term shape for a flow that genuinely has KYC branches,
expiring quotes and a third-party handoff, and this project already picked that pattern once (018-A). It is
held back only because nobody yet knows how often KYC actually branches - which is a product fact, not a
design one. If Braian says most users hit verification, D beats A.

**Rejected: C · Drawer.** A 420px panel is the right home for a setting, not for a purchase with limits, an
expiring quote and a hand-off to a third party. It also has nowhere to put the order history, so it does not
answer the whole question.

**B is A's destination, not its replacement.** Once the rail has real content it *is* B. Starting at B means
designing two panels that are both empty on a new account.

## The `/banxa` constraint, and the way through it

`CLAUDE.md`: *"Files under /banxa and /squidrouter are auto-generated. Do not change them."* Six of the seven
screens live there. Taken literally, none of these variants can be built.

They can all be built anyway, because the generated code is **layered**: models, service and cubits are
data; only three files are presentation. A redesign can add new widgets under `lib/screens/` - where
`banxa_buy_screen.dart` already lives, outside the fence - subscribe them to the same cubits, and repoint
`router.dart`. **The generated files stay byte-identical and simply stop being mounted. Zero edits inside the
fence.**

Worth confirming with Braian whether `/banxa` is genuinely regenerated by a tool or whether that note is
stale. If the fence can be lifted for the three widget files, the same designs land with a much smaller diff.

## What to Look For

1. **Toggle Empty on variant 0.** That is what "Buy GNUS" delivers today.
2. **Then toggle Empty on E.** Same data, same route, different answer to "you have nothing here yet".
3. **A's rail.** Verification state with a limit under it is one line of UI and it is the thing that decides
   whether a purchase succeeds.
4. **D's collapsed steps.** The quote stays on screen as a summary instead of being navigated away from -
   that is the whole reason 018 chose this pattern.
5. **B on Empty.** Two columns of nothing. That is why the recommendation is A first.

## Related

- Defect 13 is also raised in sketch **158** (the FAB), where the placement question lives.
- Defect 7 is the same finding as sketch **061** on the coin page - `/token-info` is outside `ShellRoute`
  too. If both are fixed, fix them together; it is one `ShellRoute` edit.
- The ledger row and filter rail in **E** are **021 / 022 / 029** applied verbatim. No new components.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 157 | buy-gnus-page | What is the Buy GNUS flow made of, what is broken in it, and what should the page be? | _pending pick_ (rec **A · Buy first** + **E · Orders fixed** as a pair - A decides what `/buy` IS, E decides what the history looks like; runner-up **D · Stepper** = 018-A applied, better if KYC really branches; rejected **C · Drawer** - a purchase with limits, an expiring quote and a third-party handoff does not fit 420px; **B · Form + rail** = A's destination once the rail has content). **Headline finding: the CTA labelled "Buy GNUS" opens the order HISTORY** (`coins_screen.dart:349` -> `router.dart:80` -> `OrdersPage`); the buy form is `/createOrder`, reachable only via "+ New Order". 14 numbered defects incl. `fetchOrders('your-cust-id')` hardcoded at two sites, three conflicting status vocabularies, zero design tokens, an empty state that reads as a failed load, all seven routes outside `ShellRoute`, and `processingFee`/`networkFee`/`transactionHash` parsed but never shown. Constraint: six of seven screens are under the `/banxa` do-not-change fence - the way through is new widgets in `lib/screens/` over the SAME cubits plus a router repoint, zero edits inside the fence. | banxa, buy, fiat, orders, kyc, page-layout, routing, empty-state, data-honesty, auto-generated |
```
