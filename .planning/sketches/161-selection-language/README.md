---
sketch: 161
name: selection-language
question: "Token Selector 1 is picked. What marks the selected row - and can ONE component carry 'this one is selected' everywhere in the app?"
winner: null
tags: [selection, active-state, gradient, underline, components, consistency, token-selector, follows-160, follows-064, follows-022, follows-032]
lane: B
---

# Sketch 161: One mark for "this one is selected"

Jakub, 2026-07-27, after picking **Swap Settings 1** and **Token Selector 1**: *"chciałbym, żebyś też
sprawdził to selection, bo nie wiem, czy nie lepiej będzie na przykład z podkreśleniem. Chciałbym, żeby
faktycznie był jeden dany komponent używany przez to. (...) zamiast blue fill to weź po prostu underline
gradientowo."*

Five treatments, each applied **to the picker and to the four other places in the app that already mark
something as chosen**, so the "one component" question can be judged rather than assumed.

## How to View

```
open .planning/sketches/161-selection-language/index.html
```

Deep links `#s0` .. `#s4`. **"Mark the clash"** draws the geometry problem in variant S1. The bottom strip
shows nav tabs, the feedback chooser, the slippage presets and the transactions filter rail under the same
treatment - switch and watch all five surfaces at once.

## What already exists

**The underline is not a proposal, it is a shipped component with an exact spec**, written twice, identically:

- `responsive_overlay.dart:386` - nav tabs (002-B)
- `submit_logs_screen.dart:713` - feedback type chooser (064-B, Jakub's own pick, 27 July)

> 3px, `GeniusWalletGradient.brandCta`, `BorderRadius.vertical(top: Radius.circular(3))`,
> `BoxShadow(brandPrimaryStrong @ 50%, blurRadius 10)`, `AnimatedContainer` 200ms. Inactive is
> `Colors.transparent`, never absent - a `BoxDecoration` with a border insets its child, so the bar is always
> present and only its paint changes.

**And there is a precedent on a list.** Sketch **022-B2** chose the underline for the transactions filter rail -
*"the navbar's active-tab mark copied outright: w700 label never recoloured, 2px gradient rule beneath, glyph
untouched"*. So the instinct is not new here; it has already won once on a column of rows.

**And there is an explicit decision against it for this exact case.** `HANDOFF.json` records: roll 064-B out to
*"transactions filter chips, markets timeframe tabs, web tab strip - **NOT to list pickers**, 032-A1 decided
those separately and differently"*. This sketch reopens that. Legitimate, but it is a reversal, not a gap.

## The geometry, measured

**The filter rail has no dividers and no card. The token list in 160-T1 has both.**

A 3px underline sits at the selected row's bottom edge. The next row's 1px `borderSubtle` divider is at the
same y. Result: **two stacked rules, 4px of line, and the selected row reads as the end of a group rather than
as the chosen one.** On the last row the bar lands on the card's own bottom border - a third collision.

In a tab strip nothing sits below the tab, so the bar is a mark. In a divided list something always does, so
the bar is a boundary. That is not taste; it is what the two lines do when they meet. Press **Mark the clash**.

## The five

- **S0 · Tint fill** - what ships (032-A1): low-alpha `brandCta` across the row + `ShaderMask` check.
- **S1 · Underline** - the shipped 3px bar, under the row. What was asked for.
- **S2 · Leading bar ★** - the same bar, same glow, same 200ms, rotated to the row's leading edge.
- **S3 · Gradient ring** - a 1.5px gradient outline; `GWFocusRing`'s existing technique.
- **S4 · Check only** - w700 label plus the gradient check, nothing else.

## Recommendation

**★ S2 · Leading bar.** It is the underline - same component, same 3px, same gradient, same glow, same
duration - turned onto the axis a list has room for. One widget with a single `axis` parameter then serves
tabs, the chooser, the filter rail **and** list rows, which is the "jeden komponent" that was asked for, and
it is the only variant where the mark never collides with a divider, a card border, or the row above it.

**The cost, stated plainly:** sketch 022 explicitly *rejected* a leading bar for the filter rail and chose the
underline instead. Taking S2 means the app has **one bar with two orientations**, chosen by whether the items
run in a row or a column. That is a defensible rule and it is still one component - but it is not literally
one mark, and it re-opens 022's decision for the rail (which should then take S2 too, for consistency).

**S1 · Underline is what was asked for and I would not ship it in this list.** Not because of the idea - the
idea is right, and 022 already proved it works on a column - but because 160-T1 puts the rows in a **card with
hairline dividers**, and that is the one context where a bottom rule cannot mean "selected". If the underline
matters more than the card, the honest combination is **S1 + 160-T3** (kickers, hairlines, no card, no
dividers) - which is exactly the filter rail's geometry, where the underline already works. **That pairing is
worth considering as a package**, and it is the one route by which the literal ask becomes correct.

**Also worth knowing before deciding:** look at the **slippage presets** panel under S1 and S2. Replacing the
filled `brandCta` chip with a bar makes *"0.5% is applied"* noticeably weaker than it is today. If one mark is
to rule everything, the preset chips lose their fill - and the fill is currently the clearest "this value is
live" statement in the app. **The chips may be the one place that should keep its own mark**, on the grounds
that a chip *is* the value rather than a pointer to it.

**Rejected: S3 · Gradient ring** - free to build, but that ring already means *"this field has keyboard
focus"* in four shipped call sites. Selection and focus would become the same picture.

**S4 · Check only** is a companion, not a rival - S0, S3 and S4 all carry the check, so the check is a
constant rather than a variant. It is too quiet alone: a 20px mark at the far right of a 420px panel, while
the eye scans names on the left.

## What to Look For

1. **S1, then press "Mark the clash".** Then look at the last row in the card. Two collisions, one screenshot.
2. **S1 vs S2 on the bottom strip.** Same component, and only one of the two survives on all four surfaces.
3. **The preset chips under S1.** Is "applied" still louder than "not applied"?
4. **S2 against the filter rail panel.** If S2 wins, 022-B2 should be revisited so the rail matches.
5. **S0 last.** It is the baseline and it is not bad - the argument against it is that it is a fourth
   vocabulary, not that it reads poorly.

## If S2 is taken

One widget, and it replaces three hand-rolled implementations:

```dart
GWSelectionBar({ Axis axis = Axis.horizontal })   // horizontal = under, vertical = leading
```

- `responsive_overlay.dart:386` (nav tabs) - horizontal
- `submit_logs_screen.dart:713` (feedback chooser) - horizontal
- the transactions filter rail (022-B2, unbuilt) - vertical, if 022 is revisited
- `token_selector_drawer.dart` - vertical

Both shipped sites carry the same 25-line `AnimatedContainer` copied verbatim, so extracting it is a
deduplication regardless of which orientation the picker takes.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 161 | selection-language | Token Selector 1 is picked - what marks the selected row, and can ONE component carry "this one is selected" everywhere? | _pending pick_ (rec **S2 · Leading bar** - the shipped 3px `brandCta` bar with its glow and 200ms, rotated to the row's leading edge; one widget with an `axis` parameter then serves nav tabs, the feedback chooser, the filter rail and list rows, and it is the only variant that never collides with a divider or a card border. **S1 · Underline** is what was asked for and fails in THIS list on geometry: the 3px bar lands exactly on the next row's `borderSubtle` divider and on the card's bottom border, so the selected row reads as the end of a group - the honest route to the literal ask is **S1 + 160-T3** (no card, no dividers), which is the filter rail's geometry where the underline already works. Rejected **S3 · Gradient ring** - that ring already means keyboard focus in 4 shipped sites; **S4 · Check only** is a constant, not a variant. Open: under one mark the slippage preset chips lose their filled gradient, which is today the clearest "this value is live" statement in the app). Findings: the underline is a shipped 25-line `AnimatedContainer` duplicated verbatim in `responsive_overlay.dart:386` and `submit_logs_screen.dart:713`; **022-B2 already chose it for a vertical list** (the filter rail); and `HANDOFF.json` records an explicit decision NOT to roll it out to list pickers - this sketch reopens that. | selection, active-state, gradient, underline, components, consistency, token-selector, follows-160, follows-064, follows-022, follows-032 |
```
