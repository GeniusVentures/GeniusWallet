---
sketch: 191
name: transaction-filter-treatments
question: "The 190-C page is right, but the filter control is wrong. What replaces it?"
winner: null   # recommending F1
tags: [mobile, ios, transactions, filters, chips, track, labels, counts, overflow, orthogonal-axes, model-defect, corrects-188, corrects-190, follows-007, follows-011, follows-014, follows-022, follows-190]
---

# Sketch 191 - seven filter treatments inside 190-C

http://localhost:8899/191-transaction-filter-treatments/

Jakub, 2026-08-09, after picking 190-C: **C one panel for transactions, definitely. But I really dislike
the filters as shown - do five to seven designs, using the 190-C design, with different filters,
because they are terrible.**

Every tab is **the same 190-C page**: one panel, control at the top, kicker with the count, rows. Only
the control changes.

## A correction to my own sketches, first

Sketches 188 and 190 drew a small **count on each filter chip**. There is no count on the chip in the
code. `_FilterChip` (`transactions_slim_view.dart:1030-1110`) draws `badgeGlyph` and nothing else; the
`counts` map reaches only `_menuItem`, inside the overflow popup. **What ships is thinner than what I
showed.** The `Today` tab here draws it correctly.

## Six defects, from the code

| # | What | Where |
| --- | --- | --- |
| 1 | **No labels, ever.** A 15px glyph in a 44px circle. The doc calls it locked: *"never by revealing a label, because a chip that grows on tap shoves its neighbours sideways"* | `:1024-1028`, `:1102` |
| 2 | **The name lives in a `Tooltip`**, which a finger cannot open | `:1052` |
| 3 | **Five of nine filters sit behind `⋯`**: Escrow, Swap, Purchase, Pending, Failed | `Filters.overflowTypes` / `overflowStatuses` |
| 4 | **Active is the full `brandCta` gradient** - the weight reserved for a primary CTA, spent on a filter | `:1093` |
| 5 | **`All` is not a chip.** You clear by tapping the lit chip again | `:899-901` |
| 6 | **No counts on the bar at all** | `:1006`, menu only |

And the thing that decides how much of this is worth fixing: **`_FilterRail`** - the same nine filters
as rows with icon, label and live count - is what a wide window already gets. Its own doc says the
popup exists *"ONLY because a 376px dashboard panel cannot show nine filters"*. But this is the
**page**, not the panel, and the phone page inherited the panel's control anyway. **The phone is the
only surface in the app that hides these labels.**

## The seventh defect, which is not visual

`Filters` is one enum holding two orthogonal axes - seven **types** (Sent, Received, Mint, Jobs,
Escrow, Swap, Purchase) and two **statuses** (Pending, Failed) - and the selection is a single value.
Choosing `Pending` un-chooses `Sent`, so *"my failed sends"* is not a question this control can ask.
**F7 is the only scheme that fixes it; every other scheme inherits it.** Measured in the sketch: `Failed`
alone returns 2 rows, `Sent + Failed` returns 1.

## Variants

| | Scheme | Control vertical | Reachable with no second tap |
| --- | --- | --- | --- |
| | Today | 50px | 4 of 9 |
| ★ | **F1 · Labelled scrolling track** | **38px** | **10 of 10** |
| | F2 · Wrapped, nothing hidden | 108px | 10 of 10 |
| | F3 · Full-width select | 44px | 0, all behind one tap |
| | F4 · Underline tabs | 43px | 10 of 10 |
| | F5 · Search leads, filter follows | 44px | 0, all behind one tap |
| | F6 · The kicker is the control | **0px** | 0, all behind one tap |
| | F7 · Two tiers, type and status | 96px | 10, and combinable |

- **F1 · Labelled scrolling track** ★ - All plus nine chips, each icon + label + count, one scrolling
  row, no overflow menu. Active is `surfaceMenu` + a `brandPrimary` hairline, so the gradient stays
  with the CTA. Fixes all six. Its one real cost is the scroll edge, mitigated by deliberately
  clipping the last visible chip under a short fade.
- **F2 · Wrapped** - all ten at once on three lines. Removes the edge by removing the scroll; costs
  **108px**, 11% of the first screen, permanently. Ages worst: an eighth type makes it four rows.
- **F3 · Full-width select** - one 44px control where `/assets` puts its search field, opening a sheet
  of `_menuItem` rows. Structurally the closest to Assets, cheapest in pixels, the only one that scales
  for free. Gives up glanceability: a closed select advertises nothing.
- **F4 · Underline tabs** - reuses sketch 022-B2's approved active mark (2px gradient rule, label never
  recoloured). Lightest ink of any scheme. Objection is 008's: underlined tabs read as **sections of a
  page**, and this would be the third place the nav's gradient underline appears.
- **F5 · Search leads** - `GWSearchField` full width with a 44px filter trigger beside it. Named
  honestly in the sketch as **scope, not a filter treatment**: it answers the question with a different
  control. It is here because type is a coarse axis and text is the precise one, and because the search
  field is the piece of Assets' panel 2 every other scheme quietly drops.
- **F6 · Kicker control** - no control row at all; the kicker's trailing slot carries `ALL ▾`, exactly
  where `assets_screen.dart:444` puts its `VALUE ↓` sort toggle. Costs **nothing**. Not recommended
  because it puts the app's smallest type (11px uppercase) in charge of its most structural control -
  and the toggle it copies has two states where this has ten.
- **F7 · Two tiers** - types scroll on one line, statuses sit on their own and **combine** rather than
  replace. The only scheme that fixes the model. Its diff is not confined to the widget: selection
  becomes a pair, `matches()` becomes a conjunction, `filterCounts()` must count against the other
  axis's live selection (tap Failed and watch Sent drop 3 → 1), and `filteredEmptyTitle` has to name
  both.

## Recommendation

**★ F1.** It is the only scheme that fixes all six defects without changing what kind of control this
is: same `GWControlTrack` family, same chips, same tap semantics, everything reachable in one gesture.
The diff is a label, a count, an `All` chip and the deletion of the popup.

**Runner-up F3**, and the one to take if vertical space is the priority or if the scroll edge fails on
glass.

**Rejected F2** - correct but expensive, and it is the scheme that degrades worst as filters are added.

**F7 is not a variant, it is a phase.** If F1 ships, F1's chips become F7's type tier unchanged, so the
two are in sequence rather than in competition.

## What to look for

- **Today** first, and notice there is no way to learn what the third circle means without a mouse.
- On **F1**, `RULER` on, look at the right edge: the last chip is clipped on purpose. If that does not
  read as "there is more", F1 is wrong and F2 or F3 is right.
- **Escrow has 0** in this data. Every scheme renders it dim and inert rather than hiding it - a control
  whose contents change shape as the wallet's history changes is worse than a quiet chip.
- On **F7**, press `Sent + Failed` under the phone. Then compare with **F1**, where picking Failed
  after Sent silently drops Sent.
- The **cost** meter under each phone is `getBoundingClientRect().height` of the control block, read
  from the rendered DOM.

## Provenance

Filter set, labels, primary/overflow split and `emptySelectionAllowed` behaviour from
`transactions_slim_view.dart:60-150` and `:810-930`; chip geometry from `GWControlTrack`
(`gw_control_track.dart`: `surfaceSunken`, hairline, `radiusPill`, `EdgeInsets.all(3)`, 2px between
children) and `touchChipSize` 44 (`:836`); the sheet's rows are `_menuItem`'s anatomy (glyph, label,
count, gradient label when active, 40px high) from `:963-1015`; active-mark alternatives from sketch
022-B2; count string shape from `assets_screen.dart:440-442`; kicker trailing precedent from
`assets_screen.dart:444`. Row anatomy unchanged from 190. Colours from `gw_colors.dart` dark(); spacing
from `genius_wallet_consts.dart`; row rhythm from `gw_row_rhythm.dart`. Inter inlined from the shipping
TTFs. `node --check` clean; div balance 0; zero em dashes; rendered in jsdom with **zero script errors**
across all eight tabs, every filter target clicked twice and every sheet opened and dismissed (102
clicks), and the F1-vs-F7 orthogonality difference asserted (2 rows vs 1).
