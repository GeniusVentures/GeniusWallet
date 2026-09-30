---
sketch: 080
name: buy-gnus-page
question: "What should the Buy GNUS page look like so buying feels like one step?"
winner: "A"
tags: [banxa, buy, gnus, quote, fees, page-layout, phase-39]
---

# Sketch 080: Buy GNUS page

## Design Question

Phase 39 rebuilds the Buy page around GNUS only. The address comes from the Selected wallet, one
"You get ~X GNUS" figure sits above the fee lines, and the quote refreshes on its own, so there is
no "Get quote" step before "Buy GNUS". Which layout makes that read as a single step?

Inputs: `39-UX-RESEARCH.md` (patterns 1, 2 and 4), the Phase 39 roadmap entry, and the current
`banxa_buy_screen.dart` card (You spend / chips / Currency / Payment method / Wallet address /
You get, Rate, Banxa fee / Get quote then Buy GNUS).

## How to View

open .planning/sketches/080-buy-gnus-page/index.html

- Top bar: variant tabs and **State** (Normal, Quoting, Below minimum, Stale quote, No wallet).
- Bottom-right toolbar: **View** (Desktop 1280 inside the app shell / Mobile 390) and **Theme**.
- Live: type an amount, tap chips, "Change" opens the account switcher or a searchable list of 29
  currencies. EUR, AUD, CAD, CLP, ZAR and MXN show a payment-method row; the other currencies show
  "Paid by card". The quote refreshes every 10 s. Typing re-quotes after a short delay. Buy GNUS
  shows a fake checkout hand-off.

## Variants

- **A: Compact card**. One 440px card, amount first (MetaMask/Phantom). A fiat pill sits beside
  the amount, chips below, then "You get" with the fee rows, then To / payment, then the CTA.
  The same card sits centred on desktop.
- **B: Form + live receipt**. Inputs on the left, a receipt on the right in the style of 031
  (icon, "You get" hero, "Live quote" pill, QUOTE and DELIVERY sections, CTA at the bottom). On
  mobile the receipt shrinks to one "You get" line with Details, and the CTA is pinned.
- **C: Big number**. The typed amount is a 72px centred numeral, with "You get ~X GNUS" in a pill
  right under it. To, Pay with and Fees are quiet rows, and the fees fold under Details. On mobile
  a keypad replaces the system keyboard and the CTA is pinned.

## What to Look For

- **Does it read as one step?** Is "You get" the second thing your eye lands on, after the amount?
- **Quote liveness**. A shows a countdown ring, B a pill, C "Updated Xs ago". Which one calms you
  and which one rushes you? During a refresh the numbers dim instead of being replaced by a skeleton.
  Check that this doesn't read as broken.
- **Switch EUR then USD**. The payment row appears and disappears. Does the page jump more in A or
  in C? B keeps the "Payment method" label either way.
- **Below minimum**. The error sits under the amount, the numbers become `-`, and the CTA says
  "Enter at least $20". **Stale quote**: the CTA becomes "Refresh quote".
- **Light mode**. Links use `brandPrimaryOnSurface` (#0A6885 light / #0AAEE6 dark), and error
  text uses `statusErrorText`. Both pass AA on every surface shown. The disabled CTA uses
  text-secondary on surface-menu (about 5.5:1 in both modes).
- **Mobile C**. Is the keypad worth the height it costs, compared with the system keyboard?

## Flutter notes

**A is the path of least resistance.** It is today's `GWCard` column with the crypto select and
the `Wallet address` field deleted, then reordered:

- A: `GWCard`; `GWTextField` with `numericHeadline`; the existing `_AmountChip`s in `GWControlTrack`;
  `GWDetailGrid` for the fee rows (it already renders the `-` placeholders); `GWButton` gradient.
  For the To row, reuse `AccountAvatar` and `WalletUtils.getAddressForDisplay` (the `0x7a3F...91c2`
  format), with a text button calling `AccountDrawer.show`. The currency list is a
  `ResponsiveDrawer` with `GWSearchField` and `GWSelectRow`. The payment row reuses the same
  `GWControlTrack` as the chips.
- B: the page frame already has two columns (form plus the `Your orders` rail). The receipt is a
  `GWCard` with `GWKicker` section labels and two `GWDetailGrid`s, as in 031. **Open question:**
  the receipt takes the column `Your orders` uses today. Only the mobile Details fold is new.
- C: this one needs the most new code: a keypad widget, a fit-to-width hero (the type steps from
  066-C) and the inline "You get" pill. The rows and drawers are reused.
- New in all three: a small countdown or "updated" indicator plus a 10 s re-quote timer in
  `MakeOrderCubit`. No such widget exists in `lib/` today.

## Not matched to the real app (flag before building)

- **Network**. Banxa does not list GNUS for partner `gnus` yet (roadmap blocker), so which chain it
  delivers on is unknown. The app takes it from `selectedCrypto.defaultBlockchain`. The sketch
  shows no network label on purpose, rather than guessing one.
- **No wallet**. I found no wallet type that "can't receive". The state uses the app's real
  no-wallets case (the account chip reads "You have no wallets!"), with an Add wallet action.
- **Presets**. The app's ladder is a fixed 100/500/1,000/5,000 filtered to the limits, so for IDR,
  VND, COP, CLP and JPY every chip falls below the minimum and the track is empty. The sketch
  scales the presets per currency (about $50/100/250/500 each).
- **Fees**. The app sums processing and network into one "Banxa fee" row. The sketch splits them,
  as the research recommends. The GNUS price ($0.4125), FX rates, fee percentages, the $0.60
  network fee and the $20 / $15,000 limits are all made up but consistent.
- **Link colour** comes from a sketch-local token (`brandPrimaryOnSurface`), which the shared
  theme does not carry.
