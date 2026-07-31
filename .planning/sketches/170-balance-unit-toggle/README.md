---
sketch: 170
name: balance-unit-toggle
question: "The Compute panel's balance can switch between GNUS and Minions, but nothing on screen says so. What makes it look tappable - and is a hint even the right answer, or should the control just state both units?"
winner: null
tags: [compute, balance, toggle, affordance, control-track, discoverability]
---

# Sketch 170: Balance unit toggle

## How to View

    open .planning/sketches/170-balance-unit-toggle/index.html

Every tile is live - press the unit in any scheme and both the label and the number flip, so you can
feel each one rather than read about it. Dark first, light toggle in the corner.

## The problem, measured

`compute_panel.dart:331-367`. `_UnitToggle` renders the unit as plain `labelMd` text in
`gw.textSecondary` - **the same treatment the tile's own `Balance` kicker uses**. Two runs of text,
identical weight and colour, one of them secretly a button.

What is already right, and should not be "fixed": the control has a 24x24 minimum target
(WCAG 2.5.8 AA), carries `Semantics(button: true, value: unitLabel)` so a screen reader announces
which unit is active, and uses `InkWell` rather than a bare `GestureDetector` specifically so it is
keyboard-focusable and operable with Enter/Space. **The gap is purely visual**, and only for sighted
pointer/touch users. A screen-reader user already knows it is a button; Jakub did not.

On desktop there is a faint `InkWell` hover wash, which is why this survived review - whoever
checked it had a mouse. On touch there is no hover, so there is no signal at all, ever.

## Schemes

### A - Swap glyph beside the unit

A 14px `swap_vert` after the label. One icon, ~18px of width, zero height. The universal
"these two exchange" mark, nothing to learn.

### B - Two-segment control track (recommended)

Both units always visible, active one raised, in the app's documented control-track recipe
(`CONVENTIONS.md:358`) - geometrically identical to the chart's timeframe segment and the dashboard's
transaction filter.

**The argument for it is not decoration, it is that nothing needs discovering.** A and C and D all
answer "how do I hint that this is pressable"; B dissolves the question by showing both options. It
is also the only scheme where you can learn that the other unit is called Minions without pressing
anything.

The cost is honest and it is copy, not pixels: the full word MINIONS pushes the track to ~132px and
starts squeezing long balances, so the segment reads `MIN`. Whether that abbreviation is acceptable
is a decision this sketch cannot make.

### C - Bordered chip

The unit keeps its single word and gains a hairline pill - the app's usual "this is a control, not
prose" mark. Middle weight, and it keeps the full word MINIONS.

The risk is stated rather than hidden: this same panel already uses pills for status, so a bordered
unit can read as a badge that reports something instead of a button that changes something.

### D - Under the number, as a link

The unit drops below the balance as a dotted-underline link that paints the brand gradient on hover
(`GWViewAllLink`'s language), reading `Showing GNUS - switch`. The only scheme that says the action
in words, and the only one no balance length can ever squeeze.

It costs ~18px of height in a panel whose height is already budgeted at 340px and was raised to that
this same week - so it is the one scheme with a real layout consequence.

## Recommendation

**B**, because it is the only scheme that removes the question rather than answering it, and because
this codebase is standardising on exactly this control today - `GWControlTrack` is being extracted
right now by quick task `260731-jx5` for the Banxa orders filter. Adopting it here makes the balance
unit the third or fourth member of one family instead of a fourth bespoke treatment.

**Runner-up: A.** If `MIN` is not acceptable copy, A is the right answer and B becomes unbuildable at
this width. A is also the cheapest thing on this page by a wide margin.

**Rejected: D.** Not because it is bad - it is the clearest of the four in pure language terms - but
because it spends height in the one panel where height was the argument this week, and it separates
the unit from the number it belongs to.

## What to Look For

- **Touch honesty.** Ignore hover entirely and ask which schemes still say "press me". A, B and C do.
  The current build does not.
- **`MIN` vs `MINIONS`.** This is the decision that picks between B and A. Press B's segments and see
  whether the abbreviation reads as a real unit or as a truncation bug.
- **Long balances.** Press any tile to flip to Minions - the number grows by several digits. Watch
  which schemes get squeezed. D never does.
- **Does C read as a badge?** Compare it against the status pills the same panel renders a few pixels
  below.
- **Light mode.** The control track's light step (`#CFD4DB` under `#FFFFFF`) is a much bigger jump
  than dark's - check B does not read as a grey slab.
