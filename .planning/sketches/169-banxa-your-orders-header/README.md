---
sketch: 169
name: banxa-your-orders-header
question: "How should the Buy GNUS 'Your orders' panel header read - the All / Pending / Done filter and the View all affordance - using components the repo already has?"
winner: null
tags: [banxa, buy, orders, filters, chips, control-track, view-all]
---

# Sketch 169: Buy GNUS "Your orders" header

## How to View

    open .planning/sketches/169-banxa-your-orders-header/index.html

Rendered 1:1 at the real 758px card width. Chips are clickable. Dark first, light toggle in the
corner. Every scheme carries a measured annotation column on its right.

## The finding that shaped all four schemes

**The app already built this control twice, and Buy GNUS built a third one by hand.**

`.planning/codebase/CONVENTIONS.md:358` documents a **Control track** recipe with fixed values -
`surfaceSunken` fill, `borderSubtle` hairline, `radiusPill`, `EdgeInsets.all(3)` track padding,
`SizedBox(width: 2)` between chips. It states outright that partial adoption "reads as a different
design language on the same screen", and names the two conforming implementations:

- `GWTimeframeSegment` - `lib/components/gw_timeframe_segment.dart:36`
- `_TransactionFilterBar` - `lib/dashboard/home/widgets/transactions_slim_view.dart:583`

The second one is not merely similar to what Your orders needs - it is **structurally the same
control**: a filter bar, taking a `Map<Filter, int>` of live counts, with an overflow
`PopupMenuButton` carrying the statuses that have no room for a chip, and a "tap the active chip to
clear back to All" behaviour.

`banxa_buy_screen.dart:720-762` ignores all of that. `_CountChip` is a private, hand-rolled pill:
raised `surfaceMenu` instead of a sunken track, no track container at all, and `brandCta` **gradient
fill** for the selected state.

Two consequences worth naming separately:

1. **The gradient fill.** On this screen the `Get quote` CTA is also a `brandCta` gradient fill
   (`banxa_buy_screen.dart:345-351`). A selected filter chip and the screen's one commitment action
   currently carry identical visual weight. Neither conforming track uses a gradient for selection -
   both use `surfaceMenu`.

2. **Three statuses, five outcomes.** `getOrderStatuses()` yields `pendingPayment, completed,
   declined, inProgress, expired`. `declined` and `expired` map to the `error` tone, and **there is
   no chip for the error tone.** The count already exists in `state.statusCounts`; nothing renders
   it. A declined order is invisible under every filter except All. `_TransactionFilterBar` already
   solved this exact problem with its overflow trigger and a `Status` menu header (`:665-670`).

The `View all` affordance has the same shape of problem. The app has an editorial link built for
precisely this slot - `GWViewAllLink`, `lib/components/cards/gw_view_all_link.dart:19` - and the
Markets panel uses it (`dashboard_markets.dart:67`). Buy GNUS uses a boxed `GWButton(tertiary, sm)`
instead (`banxa_buy_screen.dart:657-661`). Two languages for one job, on two panels a user sees in
the same session.

## Schemes

### A - Adopt the shipped filter bar (recommended)

The control track, icon chips at 32px, hairline divider, overflow trigger for the statuses with no
chip. `View all` becomes `GWViewAllLink`. Both controls fit on the kicker row, so the separate chip
row disappears entirely: the header block drops from 106px to 60px and gives 46px back to the
orders slot.

This is also sketch 007's own recommendation - variant **C, compact icon-only, active chip expands
to show its label** - which was chosen for the Transactions panel and then shipped as
`_FilterChip` (`transactions_slim_view.dart:774`). Adopting it here does not open a new question;
it closes an old one consistently.

### B - Same track, words instead of icons

Identical track recipe, but each chip keeps `label + count` and a fourth chip named `Issues` covers
the error tone. Nothing hidden behind a menu, nothing to learn. Costs ~332px of width, so it keeps
its own row and saves only 12px.

Pick this over A if you would rather every status be readable at a glance than reclaim the row.

### C - Stop filtering a four-row preview

The panel renders `visible.take(4)` (`banxa_buy_screen.dart:648`) - at most four rows - and the
filter selection is discarded the moment `View all` navigates away. So the chips become a read-only
breakdown built from `GWStatusDot`, and real filtering lives on `/buy/orders` where the full list is.

**Zero new components, and it deletes 43 lines.** It is the only scheme that costs nothing to build.
It also names the error tone in words ("need attention") rather than hiding it behind an icon.

The trade is real and it is the reason this is not the recommendation: it removes a working
interaction. Worth taking only if the walk shows the in-panel filter is not something you actually
use.

### D - One trigger, menu behind it

Sketch 007 variant E transplanted: a single compact trigger states the current filter, every status
lives in the menu with live counts. Most space-frugal, and the only scheme that absorbs a sixth
status without a redesign. The counts stop being glanceable, which is most of what the chips are for.

## Recommendation

**A**, because it is the only scheme that fixes all four defects at once - the off-convention track,
the gradient-fill collision with `Get quote`, the missing error tone, and the mismatched `View all` -
while reclaiming the most vertical space, and because it does it by adopting a control this codebase
already shipped and already documented rather than by inventing a fifth chip language.

**Runner-up: C.** If the in-panel filter turns out to be dead weight on the walk, C is strictly
better than A - it costs nothing, deletes code, and needs no component promotion at all.

**Rejected: B.** Not wrong, just the weakest trade: it accepts the full width cost of labels and
still keeps its own row, so it buys 12px where A buys 46px, and it leaves the four-status row to
grow again the first time Banxa adds a status.

## What A and B require that does not exist yet

`_TransactionFilterBar` is **private** to `transactions_slim_view.dart` and is typed to the
transactions `Filters` enum. Schemes A, B and D need it lifted into `lib/components/` and made
generic over its filter type.

Stated plainly: this is the one thing in this sketch that is not already a component. It is a
promotion of shipped, conforming code rather than a new design - and the Rule of Three cited in
`gw_timeframe_segment.dart:9-13` is what asks for it: a second consumer is exactly the trigger for
extraction. Scheme C is the only scheme that needs no promotion.

## What to Look For

- **The reclaimed row.** A and D delete the chip row outright. Look at the empty state with 46px
  more room and decide whether the card reads better or just emptier.
- **Icon versus word.** A hides Pending and Done behind coloured dots with tooltips; B spells them
  out. The dots match what the Transactions panel already does on the dashboard.
- **The gradient question.** Compare the Current block against A: the selected chip stops competing
  with `Get quote` for the eye. Decide whether that loss of prominence is a loss at all.
- **Light mode.** The sunken track's light step (`#CFD4DB` under `#FFFFFF`) is a much larger contrast
  jump than dark's. Toggle and check the track does not read as a heavy grey slab.
