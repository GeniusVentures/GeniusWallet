---
sketch: 160
name: drawers-to-154a
question: "154-A is the accepted receipt design. What do the two drawers that already shipped look like when they are re-cut to it, using only its components?"
winner: "Swap Settings 1 · Section wrapper + Token Selector 1 · One card (both chosen by Jakub 2026-07-27); the row's SELECTION mark is deferred to sketch 161"
tags: [drawers, consistency, components, swap-settings, token-selector, sections, follows-154, follows-063, follows-032]
lane: B
---

> **DECIDED 2026-07-27 (Jakub).** Swap Settings = **1 · Section wrapper**. Token Selector = **1 · One card**.
> Both against the recommendation on the picker (2 · Two sections was recommended), so the scrolling-card
> tension named below stands unresolved and should be watched on the live screen.
> **One thing was carved out of this pick and moved to sketch 161: how the selected row is marked.** Jakub
> asked whether a gradient underline beats the tint fill, and for one shared selection component app-wide.

# Sketch 160: The shipped drawers, re-cut to 154-A

Jakub, 2026-07-27: **A · 031-B1 as decided is the accepted design.** Then: *"jakbyś zaadjustował obecne
drawery, żeby wyglądały tak samo i miały te same komponenty - dwa, trzy designy dla każdego"*.

So the direction reverses. Round 2 of 154 asked whether A should bend to the two drawers that shipped on
27 July; the answer was no. This sketch bends them to A.

## How to View

```
open .planning/sketches/160-drawers-to-154a/index.html
```

Toolbar: **Drawer** (Swap Settings / Token Selector), variants **0-3**, and a **state** switch that changes
meaning per drawer - Normal/High value for slippage, Has results/No match for the picker. 0 is always the
literal render of what ships.

## What 154-A actually contributes as components

Three, and they are the whole contract. Nothing else is invented.

| Component | Spec |
|---|---|
| **`GWDrawerSection`** | uppercase kicker, **10px / w700 / .8px tracking**, `textPrimary54`; then a **1px `borderSubtle`** container at `radiusMd` filled `surfaceSheen`. `space12` between sections. |
| **`GWDrawerRow`** | **11px / `space8`** padding; label `14px` `textPrimary70` left, value `14px` `textPrimary` right and tabular. Rows inside a section are divided by a **hairline**, never by a gap. |
| **The hero** | centred above the first section: one big tabular number, a quiet sub-line, a **status pill**. |

Unchanged in every variant: the 030-B1 shell, body padding `24 / 20 / 20`, the primary action in the footer,
`GWFocusRing` on inputs, the app-wide hover recipe, and both drawers' mechanics - presets, `slippageState()`
validation, search, selection, Apply.

## Swap Settings

- **0 · Today (063-A)** - sentence-case label, description, three chips, field, message.
- **1 · Section wrapper ★** - the existing form wrapped in one `GWDrawerSection`. The label becomes the
  kicker; everything below is untouched. **The diff is roughly one widget and one `TextStyle`.**
- **2 · Settings as rows** - the drawer becomes a card of `GWDrawerRow`s, exactly like the receipt's
  TRANSACTION block, with the presets demoted to a second section.
- **3 · Hero + section** - the current value as 154-A's hero: big tabular number, explanation as sub-line, and
  a **status pill driven by `slippageState()`'s own three levels**.

### Recommendation - Swap Settings

**★ 1 · Section wrapper.** It is the whole ask at the smallest possible cost: the drawer gains the receipt's
section grammar and loses nothing. **The card is deliberately absent inside it** - 154-A's card exists to bind
*rows*, and chips plus a field are not rows; wrapping them would put a box inside a box inside a panel.

**Runner-up: 3 · Hero + section**, and it is worth looking at on the **High value** state before dismissing.
At 12% it shows a large number with an amber *"High - front-running risk"* pill, which is a considerably
stronger warning than today's grey line under a field - and it gives the validation state somewhere to live.
Its cost is that a hero for one percentage is a lot of panel, and it does not scale to the 7-setting SDK
account manager.

**2 · Settings as rows is the most literal answer and the wrong one.** It prints the value **twice** (the
Tolerance row and the custom row), and it puts the presets - the primary path 063-A deliberately chose -
*below* a summary of what they set. On **High value** the warning ends up two sections away from the number it
is about. Its one genuine merit is that it is the shape that scales to seven settings, so it is worth
revisiting when the SDK account manager gets re-skinned.

## Token Selector

- **0 · Today (032-A1)** - search, transparent rows 2px apart, gradient tint selection.
- **1 · One card** - the whole list inside a single section: kicker `TOKENS`, one card, hairline dividers.
- **2 · Two sections ★** - `Your tokens` / `All tokens`, split on `SquidTokenInfo.balance` being nullable.
- **3 · Kickers, no card** - the kickers and hairlines, but no outer border.

### The tension this sketch found

**154-A's card is designed for three to six fixed rows. This list is capped at 30 (`_maxRows`) and it
scrolls.** A border drawn around a scrolling list either scrolls away with the content or clips it - there is
no third option. **The card that makes a receipt feel finished makes a picker feel truncated.** That is the
real decision here, and it is why variant 1 is drawn but not recommended.

### Recommendation - Token Selector

**★ 2 · Two sections.** It is the only variant where the kicker earns its keep: in variant 1 the label reads
*Tokens* above a list of tokens, which says nothing. The split is not invented - `SquidTokenInfo.balance` is
nullable and the shipped row already treats a balance the wallet does not hold as **absent, not "0"**, so
`Your tokens` / `All tokens` is a fact the data carries. It also mostly dissolves the tension above: the
section a user actually wants is three rows long, so its card ends on screen.

**Runner-up: 3 · Kickers, no card**, and it is the honest answer if the card turns out to read badly while
scrolling. It takes half of 154-A - the kickers and the hairlines - and leaves the border, which is exactly
what an open-ended list wants. **It is also the variant that opts out of the thing this whole exercise is
about**, so taking it means accepting that "same components" means the row and the kicker, not the card.

**1 · One card is drawn to make the tension visible**, not to be picked. Scroll it before agreeing.

## What to Look For

1. **Swap Settings, switch to High value.** Variant 1 puts the warning under the field, variant 3 puts it in a
   pill under a 30px number. That comparison is the whole argument for 3.
2. **Token Selector, variant 1, then scroll.** The lower border of the card is the question.
3. **Token Selector, No match.** Variant 0 centres an icon and a line in an empty panel; the section variants
   have to decide whether an empty card is better or worse than no card.
4. **Swap Settings, variant 2, count where the number appears.** Twice.

## If both recommendations are taken

Two shared widgets come out of it, and they are what makes this an alignment rather than three re-skins:

- **`GWDrawerSection(label, child)`** - used by the receipt (2x), Swap Settings (1x), Token Selector (2x).
- **`GWDrawerRow(label, value, {mono, onTap})`** - used by the receipt (6+) and available to the ~17 unwalked
  drawers as they come up.

Both should land during the drawer walk already queued in `HANDOFF.json`, not before it - the same nineteen
panels are in scope, and sketch 156's colour question lands on them too.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 160 | drawers-to-154a | 154-A is the accepted receipt. What do the two drawers that already shipped (063-A Swap Settings, 032-A1 Token Selector) look like re-cut to it, using only its components? | _pending pick_ (rec Swap Settings **1 · Section wrapper** - the existing form wrapped in one `GWDrawerSection`, diff is one widget and one TextStyle; the card stays absent because 154-A's card binds ROWS and chips are not rows. Runner-up **3 · Hero + section**, strongest on the High-value state where `slippageState()`'s level becomes a real pill; rejected **2 · Settings as rows** - prints the value twice and demotes the presets below a summary of what they set. Rec Token Selector **2 · Two sections** - `Your tokens` / `All tokens` split on the nullable `balance` the shipped row already honours; runner-up **3 · Kickers, no card**; **1 · One card** drawn to expose the tension). **Finding: 154-A's card is built for 3-6 fixed rows, the token list is capped at 30 and scrolls** - a border around a scrolling list either scrolls away or clips, so the card that finishes a receipt truncates a picker. Yields two shared widgets: `GWDrawerSection` and `GWDrawerRow`. | drawers, consistency, components, swap-settings, token-selector, sections, follows-154, follows-063, follows-032 |
```
