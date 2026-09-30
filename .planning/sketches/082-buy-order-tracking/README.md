---
sketch: 082
name: buy-order-tracking
question: "How does a Banxa order show up and progress after checkout?"
winner: "C"
tags: [banxa, buy, orders, transactions, status, drawer, toast, tracker, phase-39]
---

# Sketch 082: Buy order tracking

## Design Question
After checkout, where does a Banxa order live and how does the user see it move from "Waiting
for payment" to "GNUS is in your wallet", or to a failure? Today only the QR page polls, it waits
for statuses Banxa never sends (`completed`, `failed`), and the success/cancel drawers are
reachable only from the dev bubble.

## How to View
open .planning/sketches/082-buy-order-tracking/index.html

Pick an **Order path** (happy, needs more ID, declined, expired, cancelled, refunded) and press
**Next status** or **Auto-play**. **Jump to** or a click on a legend row sets any status directly.
**Page** switches between Transactions, Buy GNUS and Markets (elsewhere in the app). Theme and
viewport (desktop 1280 in the app shell, mobile 390) are in the floating toolbar, bottom right.

## Variants
- **A · Row + drawer** - the order is a normal row in Transactions (the shipped `TransactionRow` +
  `orderRowContent`). Tap opens the shared transaction drawer with order rows. On a final status a
  card toast appears; tapping it opens the result drawer. If the drawer is already open on that
  order it turns into the result view in place and no toast fires.
- **B · Pinned tracker** - while the order is open, a tracker card sits above the list and on the
  Buy page: 5 stages, a progress bar, "Step 3 of 5", and the one action the status needs. At a
  final status it shows the outcome for ~2s, collapses, and the order drops into the list as a row.
  The toast only fires when the user is on a page without the tracker.
- **C · Buy orders filter** - A's row and drawer, plus a **Buy orders** chip in the 014-F1 filter
  row with a count of open orders, listing every Banxa order open or finished.

## What to Look For
- Step the happy path on Transactions in A: is one amber word in the list enough to tell you the
  purchase is moving? Then do the same in B.
- Switch Page to **Markets** and finish an order: does the toast reach you, and does "View order"
  land on the right drawer?
- **Declined vs expired vs cancelled**: declined is red, expired and cancelled are slate (nothing
  broke, nothing charged). Does that split read right?
- `paymentReceived` must not look finished: it stays amber, the amount keeps its `≈`, and the
  timeline has three stages left.
- Mobile: status tails use the short copy (`Unpaid`, `Confirming`, `Needs ID`...) because the
  shipped tail is capped at 76px.
- Light mode on every tone, including the neutral pill inside the drawer.

## Status mapping

| Banxa status | User copy | Phone tail | Tone | Row value line | Action |
|---|---|---|---|---|---|
| `pendingPayment` | Waiting for payment | Unpaid | pending (amber) | 100.00 EUR | Complete payment |
| `waitingPayment` | Confirming payment | Confirming | pending | 100.00 EUR | |
| `extraVerification` | Banxa needs more ID | Needs ID | pending | 100.00 EUR | Continue verification + support link |
| `paymentReceived` | Payment received (not final) | Paid | pending | 100.00 EUR | |
| `inProgress` | Buying your GNUS | Buying | pending | 100.00 EUR | |
| `coinTransferred` / `cryptoTransferred` | Sending to your wallet | Sending | pending | 100.00 EUR | |
| `complete` | Done (final) | none, happy path is silent | success | 100.00 EUR | View in wallet |
| `declined` | Payment declined (final) | Declined | error (red) | Not charged (red) | Try again + support link |
| `expired` | Order expired (final) | Expired | slate | Not charged | Try again + support link |
| `cancelled` | Cancelled (final) | Cancelled | slate | Not charged | Try again |
| `refunded` | Refunded (final) | Refunded | slate | 100.00 EUR refunded | support link |

Tones are `txStatusColors` exactly: the `*Text` foreground on a 14-16% wash. The sketch measures
them live (and `console.assert`s AA). Pill on wash / tail on panel: dark ok 8.2/10.4, warn 8.8/12.1,
err 5.1/5.9, neutral 5.4/6.0; light ok 6.4/7.7, warn 6.6/7.1, err 6.7/8.3, neutral 5.6/6.3. Tightest
is the dark error pill on the drawer surface (`#171A21`): 4.56:1, still AA.

## Flutter notes
- **A is the least resistance.** `orderRowContent`, `orderAsTransaction`, `orderTransactionRows` and
  the `_OrderRows` rail on the Buy page already render an order as a `TransactionRow` and open
  `showTransactionDetails` with order rows and a Complete Payment footer. A means merging orders
  into the Transactions list and adding a timeline block and support link to that drawer.
  `BuySuccessDrawer` / `BuyCancelledDrawer` exist but need an order passed in and a caller.
- **B** needs one new tracker widget. The rest is A's plumbing. **C** is A plus promoting the
  existing `Filters.purchase` ("Purchased", in the More menu) to the title row. Don't add a new enum value.
- **Polling must cover every open order, not only the QR page.** Today `PollingOrderCubit` runs
  only there, every 5s, and stops on `completed`/`failed`/`cancelled`, which Banxa never sends.
  One app-level poller over all non-final orders, stopping on the real final set (`complete`,
  `declined`, `expired`, `cancelled`, `refunded`), is what makes any variant's toast possible.
- Status mapping lives in one place: `orderStatusTone` + `getOrderStatusLabel` need the full
  Banxa set above. Today `complete` falls to neutral, and `cancelled`/`expired` paint red, which
  contradicts `txStatusColors` (cancelled is slate) and the cancelled drawer.

## Could not match to the real app
- **No status history in the API.** `Order` carries only `createdAt`/`updatedAt`. The timeline's
  per-stage times would have to be recorded by the poller and will miss stages that pass between
  polls. The stage list itself can always be drawn from the current status.
- **Toasts have no tap or action slot** (sketch 079: zero callers pass one). "View order" on the
  toast needs one.
- **New badge colour:** slate card badge for expired/cancelled/refunded. Today's mapping gives
  those the green purchase badge or the red failed badge.
- **`≈` on in-flight amounts** is new. The shipped row prints `+ 1,235.62 GNUS` before Banxa has
  bought anything.
- GNUS is not on Banxa's buy list for partner `gnus` yet (Phase 39 blocker). The amounts, the
  Base chain and the explorer hash are illustrative.
