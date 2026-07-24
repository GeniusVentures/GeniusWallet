---
sketch: 106
name: markets-visualization
question: "Can the Markets page be visually striking while still reading off the same market data?"
winner: null
tags: [markets, dataviz, treemap, heatmap, native-token, aesthetics]
---

# Sketch 106: Markets visualization

## Design Question
Sketch 103 (H1) shipped a solid but conventional Markets page: native-token hero over a sortable
table. This asks the opposite question - **what does an aesthetics-first Markets page look like** when
the goal is visual impact, not analytical precision? All three variants read off the exact same live
fields (`market cap`, `24h%`, `price`, `rank`, `ATH gap`, `7d sparkline`) so any of them is buildable
against `CoinGeckoMarketData` with no new data.

## How to View
open .planning/sketches/106-markets-visualization/index.html

## Variants
- **A · Treemap** - tiles packed by market cap (BTC largest), fill colour diverging by 24h move. The
  native GENIUS AI tile carries a rotating brand-gradient ring + glow. Instant whole-market read.
- **B · Constellation** - bubbles on a starfield, radius ∝ √market-cap, ambient drift; GENIUS AI is
  the pulsing star at centre. Most "wow", least dense.
- **C · Heatmap grid** - uniform cells tinted by 24h move, each with a live 7d spark and its ATH gap.
  Densest and most scannable; closest to a real "all markets".

## What to Look For
- Which one makes you *feel* the market at a glance (green/red mass, where the energy is)?
- Does the native-token glow read as special without looking gimmicky?
- Which balances beauty vs. actually-usable (can you find a coin, read a price)?
- Colour encoding: is the diverging green↔red tint legible on the dark canvas?

## Notes
- Shared top strip: total market cap + 24h pill + a **breadth bar** (% advancing vs declining) - cheap
  to compute, high visual payoff.
- Aesthetics-first per Jakub: numbers are plausible placeholders, not audited. Size=market cap,
  colour=24h% throughout.
- Real brand palette (`#06070B` canvas, `#14C8FF→#2BF5B4` gradient, `status-success/error`).
