---
sketch: 066
name: big-number-rendering
question: "How do the picker row and the 38px hero amount survive magnitudes from 1e-15 to 1e12?"
winner: null
tags: [numbers, typography, swap, picker, phase-08]
---

# Sketch 066: Big Numbers — Picker Row + 38px Amount

## Design Question

Two slots have to survive the same ladder:

- the picker's **trailing balance**, right-aligned in a 420px row it shares with a name and symbol
- the swap card's **38px hero amount**, which MAX fills verbatim

Today both are a single unwrapped mono string. `1000000000000` is thirteen digits;
`0.000000000000001` is seventeen characters in a font sized for `1.5`.

## Provenance

Braian at the 08-07 walk, 2026-07-27, after the magnitude stress fixtures landed and showed the
problem on screen: *"we need to make it look good when we have a really big numbers."*

## How to View

open .planning/sketches/066-big-number-rendering/index.html

Both slots are shown side by side for every variant, over the real ladder from the fixtures.
The third amount card is **MAX on the dust row** — the exact `0.000000000000001` that
`formattedBalance` writes into the field.

## Variants

- **baseline · shipped** — one unwrapped string in both slots. The problem, rendered.
- **A · Compact suffix** — `1T`, `1.23B`, `500`; dust keeps its honest `<0.000001`, and the amount
  card demotes the exact figure to a small line beneath.
- **B · Grouped + exact second line** — compact in the row with the grouped exact value beneath;
  grouped digits in the hero with the raw value below. Nothing is ever hidden.
- **C · Fit-to-width** — always exact, one line, type stepping 38 → 28 → 20 → 15px as the string
  lengthens. Closest to what ships today.

## What to Look For

- **Is abbreviation acceptable for money you are about to spend?** `1T` cannot distinguish 1.0
  from 1.49 trillion. That is the central trade in A, and arguably disqualifying.
- Does B's second line earn its vertical cost when ~90% of balances are ordinary?
- In C, does the hero changing size as you type feel unstable?
- Whether the row and the hero actually want the *same* answer — the row is a scanning surface,
  the hero is an editing surface, and they may deserve different rules.

## Hard constraint on C

The project bans deriving a dimension **continuously** from constraints — commit `37639d5`, which
froze the macOS app; a distinct value per frame thrashes skia's fixed-size caches and layout never
settles. `GWEmptyState` follows the same rule with a two-tier compact/full switch and a fixed
480px anchor. So C must be a **small fixed set of steps keyed to string length**, never a
continuous fit. Any implementation that measures and scales per frame is the banned pattern
wearing a different hat.
