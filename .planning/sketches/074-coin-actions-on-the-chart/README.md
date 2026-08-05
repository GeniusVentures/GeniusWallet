---
sketch: 074
name: coin-actions-on-the-chart
question: "Jakub wants the icon actions on the chart, as suggested by 073's C and D. Drawn precisely: what does each version actually collide with?"
winner: "C2 · Above the card - chosen by Jakub 2026-07-28 (\"sprobujmy zatem z C2\"). Supersedes 072-A and 073-A, both of which stay winner:null and unimplemented."
tags: [coin-detail, token-info, actions, icon-buttons, chart, follows-073, follows-072, follows-071]
lane: execution
---

# Sketch 074: The actions on the chart, four precise versions

Jakub, 2026-07-28: *"Co sądzisz o tym, żeby dać to na wykresie? Tak jak to zasugerowałeś w C albo w
D. Pokaż mi, jakby to wyglądało [...] dokładniej."*

## How to view

```
open .planning/sketches/074-coin-actions-on-the-chart/index.html
```

Four versions × two states (with / without market data), dark and light, chart card at a real 560px.
**Every panel draws the chart's existing zoom/pan row, marked in red.**

## The finding that decides this

**The chart card already owns an icon row.** `crypto_live_chart.dart:506` renders a centred `Row` of
four `IconButton`s - zoom in, zoom out, back, forward - inside the same card.

So putting wallet actions in that card means **two icon rows in one box with categorically different
consequences**: one changes what you are looking at, the other moves money. Undo exists for the first
and not for the second. That is not a spacing problem, and alignment cannot fix it.

Related, and inherited: those four icons are **hardcoded `Colors.white`** (filed todo
`2026-07-21-chart-zoom-pan-icons-still-raw-colors-white`), so they are white-on-light in light mode
today. Anything placed beside them inherits that neighbour.

**And the no-data page still has no chart card** (071-B). C1, D1 and D2 all put the actions inside a
card that does not exist on that route, so they vanish or must be re-homed - the page ends up with two
action positions for a reason the user cannot see. **C2 is the only one of the four that does not
move.**

## The four

| | Version | Where exactly | Collides with the zoom row | Survives no-data | Height |
|---|---|---|---|---|---|
| **C1** | Top of the card | inside the card, above the plot; kicker left, icons right | same card, opposite ends | no | ~44px |
| **C2** ★ | **Above the card** | **outside** the card, on the section line | **no - different container** | **yes** | ~44px |
| **D1** | Floating on the chart | overlaid top-right on the plot, translucent | same card | no | **zero** |
| **D2** | Shared bottom row | same row as zoom: zoom centred, wallet right | **directly** | no | zero |

## Recommendation

**★ C2 · Above the card.** The version of the idea that survives its own context. The icons sit on a
section line **outside** the chart card, opposite a `GWKicker`, so they read as "at the chart" without
being *in* the box that already contains four icons with a different job. It is also the only one of
the four that **does not move on the no-data page** - the line stays, the card beneath it becomes the
empty state.

**Runner-up: D1 · Floating on the chart.** Visually the best of the four - the translucent treatment
reads as premium and it costs zero height. Worth keeping in reserve for a version where the chart is a
full-bleed hero. Not the pick because it shares a card with the zoom row and has nothing to float over
on the no-data route. Its glass fill would also be a **new surface treatment**, which nothing else in
the app uses.

**Rejected: D2 · Shared bottom row.** It looks like the tidy answer - one row, no new height - and it
is the worst of the four: *Receive* ends up 6px from *zoom out*, at the same size, with the same
affordance. The two things a user must never confuse become neighbours.

## Honest note against my own recommendation

**073-A (under the price) still wins on one measure C2 cannot match: it costs zero new vertical
height, where C2 costs ~44px.** This sketch does not overturn 073 - it shows the best version of the
chart idea so the two can be compared on equal terms. If the page's vertical budget matters more than
the association with the chart, 073-A remains the better answer.

## Decision - 2026-07-28 (Jakub), and what the component audit found

**C2 chosen.** Asked for a component count before committing, which surfaced three things the sketch
drew differently from the code and one deletion the sketch had not counted.

**Zero new components, zero new parameters.** `GWKicker`, `GWButton.icon`, `tooltip:`,
`semanticLabel:`, `GWButtonVariant.icon`, `GWButtonSize.sm` (44) and `CryptoAddressQR` all exist.
`tooltip` and `semanticLabel` are not just declared - they wrap in a real `Tooltip` and
`Semantics(button: true)` at `gw_button.dart:319-323`.

**Three places the sketch and the component disagree, to resolve during implementation:**

1. **Icon buttons are CIRCLES, not rounded squares.** `gw_button.dart:270` -
   `BorderRadius.circular(_isIconOnly ? _height / 2 : radiusLg)`. The sketch drew `radiusMd`. Either
   accept circles or change the component, which touches its 2 existing call sites.
2. **The tinted "primary" Receive does not exist.** The sketch drew an 18% brand tint;
   `GWButtonVariant.gradient` is a full bright fill, not a tint. So either Receive is loud on a full
   gradient, or all three icons are equal - **there is no third option without a new variant.**
   Recommended: equal, because this is an action row, not a CTA, and in this app the gradient means
   commitment.
3. **`GWButton.icon` defaults to `ghost`**, not `icon` - the variant has to be passed explicitly or
   the buttons render with no fill and no border.

**C2 deletes more than it adds.** `TokenActionBar` has exactly ONE consumer (this page), so it goes
dead along with its private `_ActButton` / `_ActVariant`. The "More Options" drawer disappears if
Bridge becomes a direct icon. `SlidingDrawerButton` survives - it has 3 other consumers.

**Default taken, overridable:** **Bridge becomes an icon**, with the zero-balance guard moved onto the
button's own `onPressed: null`. That keeps the rule and removes the drawer. The cost, stated: the
drawer's description line (*"Move your GNUS across chains with the bridge"*) has nowhere to go.

## Implemented - 2026-07-28, quick task `260728-v6c`

Shipped uncommitted, per CLAUDE.md. `analyze lib` 59 = baseline, `flutter test` 371/1 (up one, the
failure inherited). See
[`.planning/quick/260728-v6c-coin-actions-074c2/SUMMARY.md`](../../quick/260728-v6c-coin-actions-074c2/SUMMARY.md).

All three audit resolutions carried: circles, no tinted primary, explicit
`variant: GWButtonVariant.icon`. **Bridge is absent rather than disabled when the coin is not GNUS** -
the sketch's default was disabled, and the honest reading is that a non-GNUS coin has no bridge
action at all, where zero balance is a state the user can change. Glyphs came out as Material icons
rather than the sketch-152 SVGs, because `GWButton` tints through an `IconTheme` that `SketchIcon`
cannot read - an SVG would be the one glyph in the row that does not dim.

**Three defects the implementation surfaced**, none of them visible in any sketch panel:
`_pushBridgeScreen` opened with a `Navigator.pop()` that would have popped the PAGE once the drawer
was gone; the no-data empty state used to sit ABOVE the actions, so the row stood at two different
heights depending on coverage - the very thing C2 was chosen to prevent, and it was not fixed by
choosing C2, it was fixed by moving the empty state into the chart card's slot; and
`_kChromeAboveChart` was 38px stale.

**Nobody has walked it.**

## Still open

- **072-A and 073-A stay `winner: null` and unimplemented** - superseded by C2, not cancelled.
- The three hardcoded `isGnusWalletConnected: false` call sites (072 finding 2) are still a bug in the
  callers, and still unanswered as a question: should Bridge be live from Markets at all? **This one
  changes what shipped**: if yes, the main route's row is three icons instead of two.

## MANIFEST row

```
| 074 | coin-actions-on-the-chart | Jakub wants the icon actions on the chart, as suggested by 073's C and D. Drawn precisely: what does each version actually collide with? | **Recommended C2 · Above the card** - icons on a section line OUTSIDE the chart card, opposite a `GWKicker`, so they read as "at the chart" without being in the box that already holds four icons with a different job; **the only one of the four that does not move on the no-data page**. Runner-up D1 · floating translucent top-right on the plot (best-looking, zero height, but shares the card with the zoom row, has nothing to float over on the no-data route, and its glass fill would be a new surface treatment). Rejected D2 · shared bottom row (looks tidy, is worst: *Receive* ends up 6px from *zoom out* at the same size with the same affordance). **THE FINDING THAT DECIDES IT: the chart card already owns an icon row** - `crypto_live_chart.dart:506` renders a centred Row of 4 IconButtons (zoom in/out, back, forward) in the same card, so any in-card placement means two icon rows in one box with categorically different consequences - one changes the view, the other moves money, and undo exists for only one of them. Those 4 icons are also hardcoded `Colors.white` (filed todo), so anything beside them inherits a white-on-light neighbour. **And the no-data page has no chart card** (071-B), so C1/D1/D2 all vanish or must be re-homed there. **Honest note recorded against the recommendation: 073-A (under the price) still wins on cost - zero new height vs C2's ~44px** - so this sketch does not overturn 073, it makes the chart idea comparable. | coin-detail, token-info, actions, icon-buttons, chart, follows-073, follows-072, follows-071 |
```
