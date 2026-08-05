---
sketch: 067
name: section-grammar-real-components
question: "160-1 was picked but specifies three components of its own that do not exist: a kicker at 10/w700/0.8/textPrimary54 (a sixth value, contradicting 065-C), a card at radiusMd + surfaceSheen (not GWCard) and a row at 14/14 (not the shipped _buildRow). What does the same shape look like built ONLY from what is already in the code - and what groups the content, given a card on a drawer panel measures 1.11:1?"
winner: "A · Kicker only - grouping by whitespace, no container. Chosen by Jakub 2026-07-27, together with the 156-A canvas."
tags: [drawers, sections, components, contrast, wcag, swap-settings, follows-160, follows-065, follows-156]
lane: execution
---

# Sketch 067: Section grammar on real components

Built when Jakub asked whether **160-1 uses our components or pushes one-offs through**. The answer
is that it pushes three.

## What 160 calls "154-A's components", and what they actually are

| 160 specifies | What the code has | The divergence |
|---|---|---|
| kicker **10 / w700 / 0.8 / `textPrimary54`** | `GWKicker` 13/w600/0.5, or 11/w600/0.6 dense, `textSecondary` | **a sixth value** - different size, weight, tracking and colour; every token exists, so it compiles without a warning and quietly recreates the drift 065 had just eliminated |
| card at `radiusMd` + `surfaceSheen` | `GWCard` at `radiusLg` + `surfaceElevated` | two radii and two fills for one role |
| row at 14/14, tabular | `_buildRow`: label `bodySm` 14, value **`bodyMd` 16** | the value shrinks 2px and gains tabular figures |

In fairness: **160 was written in the morning and 065 that same evening.** This is not bad faith,
it is a sketch authored before the rule existed. But executed literally it undoes a day's work.

What 160 takes correctly and verbatim: the 030-B1 shell, `GWFocusRing`, the app-wide hover recipe,
and the whole of the mechanics - presets, `slippageState()`, search, `Apply`.

## The number that redesigned this sketch

Before drawing anything, the card was measured against the drawer panel:

| Boundary | Panel today `#171A21` | Panel after 156-A `#0C0E14` | 1.4.11 wants 3:1 |
|---|---|---|---|
| `GWCard` fill `surfaceElevated` | 1.11:1 | **1.00:1** - the same colour | no |
| sunken card `surfaceSunken` | 1.15:1 | 1.04:1 | no |
| hairline `borderSubtle` 12% | 1.42:1 | 1.36:1 | no |
| `borderStrong` 24% | 2.19:1 | 2.11:1 | no |
| white 30% edge (156-A's proposal) | 2.72:1 | 2.63:1 | no |
| **white 36% edge** | **3.32:1** | **3.30:1** | **yes** |

**No fill available in this palette makes a card read on a drawer panel.** After 156-A the card
becomes precisely the panel's own colour and vanishes. Only the border does any work, and it has to
go to white 36% to pass - which is a visible grey line, not a hairline.

So 160's card fails on **arithmetic, not taste**. It is the same conclusion the two shipped drawers
reached (`_TokenRow` carries a comment about decoration nobody can see), with the number underneath
it.

## How to view

```
open .planning/sketches/067-section-grammar-real-components/index.html
```

Toggles: **Wysoka wartość** (the 12% warning state), **Płótno po 156-A** (swaps the panel colour),
**Kicker dense** (11 instead of 13), **Kontrast** (prints the measured value above the section). The
table beside the panel names the source file of every element on screen.

## Variants

| | Variant | New widgets | Reading |
|---|---|---|---|
| **A** ★ | **Kicker only** | **0** | A label and a gap. What the two shipped drawers already do. A gap has no contrast threshold to meet. |
| **B** | **Kicker with a rule** | 0 | A hairline to the right edge. Groups visibly while nothing has to pass 1.4.11 - a rule under a label is part of its typography, not a component boundary. |
| **C** | **Card at 3:1** | 0 | `GWCard` with its border raised to white 36%. The only 1.4.11-compliant variant and the only one that survives 156-A. |

## Decision - A, 2026-07-27 (Jakub)

*"wydaje mi się że A sam kicker oraz płótno po 156A"* - A **together with** 156-A.

The two picks interlock, and not by accident: once the panel becomes `#0C0E14`, a `GWCard` inside it
measures 1.00:1 and is invisible. **The no-card variant is the only one that makes sense after
156-A.**

Two follow-ups were settled in the same exchange:
- **kicker inside a drawer: the default 13 step**, not `dense` - the same role as `INFO`/`CONVERT`
  inside the token card, and consistent with the receipt, where this label returns above two
  sections.
- **body padding moves to the shell** - because without a card the gap is the only thing doing the
  grouping, so it cannot depend on whether someone wrote it in that particular drawer. Done in
  quick 260728-0vd.

Rejected with reasons: **B and C only start earning their keep at two sections.** Swap Settings has
one - a rule above the only group promises a second group that does not exist, and a card draws a
box around the drawer's entire contents, i.e. a box inside a box. **B returns as a real candidate
for receipt 154-A**, where there are two sections. **C** is rejected as the default: 36% makes the
section the loudest element in the panel, louder than `Apply`.

## Build status

**BUILT 2026-07-28**, quick **260728-q7c**, together with 156-A as the decision required.

The section itself is `GWKicker('Slippage tolerance')` at the default 13 step and one changed
number: the gap under it went **4 to 12**. That gap is not cosmetic here - with no container it is
the only thing grouping the section, so the 4px that was fine under a sentence-case label is not
fine under a kicker.

One correction to this sketch's own table, found while building: the **white 30%** row (156's
proposal) reads 2.63:1 and the **white 36%** row reads 3.30:1 - both correct, and 36% is what
shipped as `GeniusWalletColors.borderControl`. 156's text claimed 30% was 3.0:1; this sketch's
table was the one that was right.

## MANIFEST row

```
| 067 | section-grammar-real-components | 160-1 was picked but specifies three components of its own that do not exist: a kicker at 10/w700/0.8/textPrimary54 (a sixth value, contradicting 065-C), a card at radiusMd+surfaceSheen (not GWCard) and a row at 14/14 (not _buildRow). What does the same shape look like built ONLY from what the code already has - and what groups the content, given a card on a drawer panel measures 1.11:1? | **A · Kicker only** (Jakub 2026-07-27), together with the **156-A** canvas; kicker at the default 13 step; body padding moved to the shell. Rejected B (kicker with a rule) and C (card at a white-36% border) - both only earn their keep at two sections, so **B returns as a real candidate for receipt 154-A**. **Key finding: a card on a drawer panel fails on arithmetic, not taste** - GWCard measures 1.11:1 today and **1.00:1 after 156-A** (the same colour), the 12% hairline is 1.42:1, and the first edge to pass 1.4.11 is white **36%** (3.32:1), a visibly grey line. Variants A and B introduce NOT ONE new widget. | drawers, sections, components, contrast, wcag, swap-settings, follows-160, follows-065, follows-156 |
```
