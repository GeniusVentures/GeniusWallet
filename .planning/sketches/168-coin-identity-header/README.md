---
sketch: 168
name: coin-identity-header
question: "Where does the price belong on a coin page, and does the page still need its own action row?"
winner: null
tags: [coin-page, header, price, cta, density, follows-165]
depends_on: [165]
---

# Sketch 168: The coin page identity header

## The prompt

Jakub annotated a live screenshot on 2026-07-31, right after plan 07-09 shipped sketch 165:
a red strike through the `Swap` / `Receive` row, and a long arrow dragging the price from the far
right of the header to sit **just after the coin name**.

## What ships today, and why it looks like that

The price is `GWPageHeader`'s `trailing` slot, so the identity block and the price sit at opposite
ends of the same row. On a 1536px page that is roughly **1200px of empty row** between a coin's
name and its price - which is exactly what the arrow measures. The actions then take a third row
underneath.

Three stacked rows, about **124px**, before the first stat is shown.

This is not a regression from 165. 165 deliberately moved the actions OFF the title line onto
their own row (change 3), because two 32px icon glyphs wedged behind a hairline were worse. That
fixed the actions and left the price where it always was.

## The four schemes

| # | Scheme | Rows | Actions | The idea |
|---|--------|------|---------|----------|
| **A** | Price on the title line | 1 (~52px) | none | The literal reading: name, ticker, price, change as one sentence |
| **B** | Price + 44px icon actions | 1 (~52px) | icon-only | The row's freed right end takes the actions back |
| **C** | Price under the name | 2 (~96px) | none | Identity as one top-to-bottom block; price keeps full 28px weight |
| **D** ★ | Price after the name, one fill survives | 1 (~52px) | Swap only | Receive and Bridge leave; the page keeps its one plausible action |

Every block renders at **1:1**. No thumbnails - a header judged at 60% is not judged.

## Recommendation

**★ D.** It does everything the annotation asks - price with the name, Receive/Bridge row gone,
three rows down to one - while leaving the page able to do the thing a user on a coin page most
plausibly came to do. It also settles by deletion the question 07-09 explicitly left open for this
walk: with Receive and Bridge gone there is no outline pair left to adjudicate against the one
fill, and the CTA weight rule's *"the filled gradient Swap is the coin page's single filled
control"* becomes literally true rather than aspirational.

**Runner-up: A.** The cleanest header of the five and the most faithful reading of the annotation.
Pick it if the coin page should be a **quote sheet with a calculator** - that is a defensible
product position, but it is a product decision and should be said out loud, not absorbed as a
layout tweak. Swap and Receive both remain reachable elsewhere (own tab, account drawer), so
nothing becomes unreachable; it just stops being reachable *from here*.

**Rejected: B.** Sketch 165's change 3 exists specifically because icon-only actions on the title
line were the problem - *"Labels, not bare glyphs."* Making them 44px instead of 32px answers the
accessibility half of that objection (44x44 is exactly WCAG 2.5.5 Enhanced) and none of the
comprehension half. Re-proposing it would be walking back a decision already made with reasons.

**C is not wrong, it is a different question.** It is the only scheme where the price keeps its
full 28px weight without sharing a baseline with the 24px title - in A, B and D the two large
types sit side by side and compete. Worth keeping if A or D read as cramped on a long coin name.

## What this sketch does NOT decide

- **Where Swap and Receive go if they leave.** A and C delete them from this surface without
  proposing a new home. If either wins, that is the next question, not a detail.
- **Anything below the stat rail.** Chart, Convert and Info are untouched and reproduced only so
  the header can be judged in place.
- **Light mode.** Dark only, per the standing "dark first" call.

## How to view

```
open .planning/sketches/168-coin-identity-header/index.html
```

Tabs across the top: today's shipped header first, then each scheme, then all five stacked at 1:1
in **Side by side** so the height each costs is directly comparable.

## Provenance

Every measurement in the mockup is lifted from the shipped Dart at HEAD (plan 07-09, uncommitted),
listed in the file's own header comment: title 24/32 w600 ls -.4, subtitle 14/20, price 28/34
tabular, action height 44 (`GWButtonSize.sm`, the walk's 2026-07-31 call), header inset 12,
card radius 12. Colours come from `../themes/default.css`, which mirrors `gw_colors.dart`.
