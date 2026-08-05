---
sketch: 073
name: coin-icon-actions
question: "Jakub likes the small icon actions from 072's rejected C. Where do they go - given GWPageHeader's trailing slot already holds the price, the live count changes by route, and 'small' has a floor this codebase already set at 44?"
winner: null
tags: [coin-detail, token-info, actions, icon-buttons, touch-target, accessibility, follows-072, follows-071]
lane: execution
---

# Sketch 073: Small icon actions on the coin page

Jakub, 2026-07-28, after 072: *"te małe ikonki mi się podobają i myślę, że to będzie nasza droga do
pójścia [...] wyślij mi trzy, pięć dokładnych designów, używając naszych base components i takich
małych ikon akcyjnych. A potem dopiero zdecydujemy, czy implementujemy A, czy nie."*

So 072's **rejected** C direction, taken seriously and given five placements. Nothing is implemented
yet - 072-A is on hold until this is decided.

## How to view

```
open .planning/sketches/073-coin-icon-actions/index.html
```

Five placements × **1/2/3 live actions** × labels on-hover or always, dark and light.

## The action set is 072's, unchanged

**Receive** (real), **Swap** (built, one line to wire, no preselection), **Bridge** (real, GNUS only).
**No Send** - it does not exist in the code. The count genuinely changes by route: from Markets it is
**one**.

## "Small" has a floor, and this codebase already set it

**The glyph gets small. The target does not.** `GWButton`'s `sm` size returns **44**, and the line
carries its own reason:

```dart
case GWButtonSize.sm:
  return 44; // was 36 — touch floor (iOS 44)
```

Someone already lowered it to 36 and reversed the decision. Going below 44 here would re-make a
mistake this repository has recorded. So every variant is a **44×44 hit area with a 20px glyph**.
WCAG 2.5.8 (AA) asks 24×24 minimum and 2.5.5 (AAA) asks 44×44 - the app is already at the stricter
one.

**An icon-only button must say its own name.** With the label gone, the glyph is the only thing
carrying "this is Receive", so each needs `GWButton(tooltip:, semanticLabel:)` - both already exist on
the component. The **Labels** switch draws the trade: *on hover* is the compact version the request
implies; *always* keeps a 10px caption, costs 12px, and is the only version that works on a **touch
screen**, where there is no hover to reveal anything.

## Contrast, both modes

| Pairing | Dark | Light | Needs | |
|---|---|---|---|---|
| glyph `textPrimary70` on the page | 10.9 | 9.4 | 3.0 | pass |
| glyph `textSecondary` on the page | 5.97 | 6.30 | 3.0 | pass |
| button edge `borderSubtle` | 1.32 | 1.27 | 3.0 | see below |
| caption `textSecondary` (labels: always) | 5.97 | 6.30 | 4.5 | pass |

**The 1.32:1 edge is acceptable here, and the reason matters.** A control's boundary must clear 3:1
*when the boundary is what identifies the control*. On these buttons it is not - the **glyph** is, at
10.9:1. Same argument `GWSelectRow` made on 2026-07-28: tint 1.39, brand edge 1.60, and the check
glyph at 6.81 carrying 1.4.11 alone.

**Variant E is the exception to watch:** inside the grouped pill the buttons have no edge at all and
sit on `surfaceSunken`, so the pill's outline is the only boundary - hence it is drawn around the
group, not around each item.

## The five placements

| | Placement | Where | Costs | Breaks when |
|---|---|---|---|---|
| **A** ★ | **Under the price** | `GWPageHeader.trailing`, a column: price, pill, icons | **0px** - fills space the header already reserved | the header gets tall on a narrow window |
| **B** | **By the identity** | left column, under the name + subtitle | ~12px | actions read as part of the title block |
| **C** | **Chart toolbar** | slim row above the chart: `GWKicker` left, icons right | ~44px | actions look like chart controls |
| **D** | **In the chart card** | top-right corner inside the card | 0px | the no-data page has no chart card |
| **E** | **Grouped pill** | one `surfaceSunken` pill under the header | ~50px | one action alone in a pill looks like a bug |

## What to look for

**Set "Live actions" to 1 and walk all five.** That is the Markets route - the main way in - and it is
the state nobody has drawn. A single 44px glyph floating where a four-button bar used to be is the
risk this whole direction runs. **D and E take it worst; A and B absorb it** because they sit inside a
block that has other content.

Then switch **Labels: always** and check the height cost, because that is the version that works on a
phone.

## Recommendation

**★ A · Under the price.** It costs **zero new vertical height** - the header's trailing column is
already as tall as the title block beside it, and the price + pill do not fill it - so the entire 74px
action bar leaves the page. Actions sit with the coin's numbers, which is what they act on, and at one
action it still reads as deliberate because the price is above it.

**Runner-up: B · By the identity.** The safest of the five and the best at one action, because a lone
glyph under a name is an ordinary shape. Costs ~12px and slightly miscategorises the actions as part
of the identity. Take it if A reads cramped on the walk - the two are one `Row` apart.

**Rejected: D · In the chart card.** The prettiest picture here, and it breaks on a state that is
already shipped: the **no-data page has no chart card** (071-B), so the actions would move depending
on whether CoinGecko covers the token - one page, two layouts, for a reason the user cannot see.

## Still open, and not decided here

- **072's variant A is on hold**, not cancelled. If 073 lands, 072-A's row disappears entirely and
  only its *action set* survives (Receive / Swap / Bridge, no Send).
- **The three hardcoded `isGnusWalletConnected: false` call sites** (072 finding 2) remain a bug in
  the callers whichever placement wins. Nobody has said yet whether More *should* be live from
  Markets - and if it should, every count in this sketch changes.
- **Swap preselection** is still not in the code, so no variant promises it.

## MANIFEST row

```
| 073 | coin-icon-actions | Jakub likes the small icon actions from 072's rejected C. Where do they go - given `GWPageHeader.trailing` already holds the price, the live count changes by route, and "small" has a floor this codebase already set? | **Recommended A · Under the price** - inside `GWPageHeader.trailing` beneath the price + pill, costing **ZERO new vertical height** (that column is already as tall as the title block and the price does not fill it), so the whole 74px action bar leaves the page. Runner-up B · By the identity (under the name; safest at ONE action, costs ~12px, slightly miscategorises actions as identity). Rejected D · In the chart card (prettiest, but **the no-data page has no chart card** per 071-B, so actions would move depending on whether CoinGecko covers the token). Also drawn: C · chart toolbar (~44px, puts wallet actions where zoom controls live), E · grouped control-track pill (~50px, right for 3 items, looks like a bug at 1). **The finding that constrains all five: "small" applies to the GLYPH, not the target.** `GWButton`'s `sm` returns 44 with the comment *"was 36 — touch floor (iOS 44)"* - someone already tried 36 and reversed it - so every variant is a 44x44 target with a 20px glyph; WCAG 2.5.8 AA asks 24x24 and 2.5.5 AAA asks 44x44, so the app is already at the stricter bar. **Icon-only buttons need `tooltip:` + `semanticLabel:`** (both already on GWButton) or they announce nothing; the Labels switch shows that the always-visible caption costs 12px and is **the only version that works on touch**, where no hover exists. Contrast: the glyph carries 1.4.11 at 10.9:1 so the 1.32:1 button edge is acceptable - the same argument `GWSelectRow` recorded for its check glyph. Action set is 072's: Receive + Swap + Bridge, **no Send**, and from Markets the live count is ONE - set the switch to 1 and check every placement, because that state has never been drawn. | coin-detail, token-info, actions, icon-buttons, touch-target, accessibility, follows-072, follows-071 |
```
