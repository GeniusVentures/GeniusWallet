---
sketch: 107
name: markets-alt-directions
question: "A completely different visual language for Markets - which of four feels right?"
winner: null
tags: [markets, dataviz, radar, momentum, spotlight, aurora, aesthetics]
---

# Sketch 107: Markets - alt directions

## Design Question
Round 106 (treemap / constellation / heatmap) read as so-so. This is a clean-slate round: four
directions with nothing in common with 106 or each other. Same live fields
(`market cap`, `24h%`, `price`, `rank`, `ATH`, `7d spark`); GENIUS AI is the star of each.

## How to View
open .planning/sketches/107-markets-alt-directions/index.html

## Variants
- **A · Radar / sonar** - on-brand for GENIUS *AI*. Native token pings at the core; blips are coins
  (distance from centre = rank, size = market cap, colour = 24h), a gradient sweep rotates.
- **B · Momentum lanes** - a market equaliser: gainers push right (green), losers push left (red),
  bar length = |24h%|, sorted by move, with a live shimmer. Feels like a race.
- **C · Spotlight deck** - premium/editorial. One coin in the spotlight with a full 7d area chart +
  stats; the rest are a filmstrip - **click a card to bring it into the spotlight** (interactive).
- **D · Aurora field** - mood-first. The background aurora reflects market breadth (risk-on/off);
  frosted-glass modules float a briefing, top movers, and an elegant list with sparklines.

## What to Look For
- Which one is a genuine "wow, ship it" vs. a gimmick that gets old?
- A/D are the most atmospheric; B is the most kinetic; C is the most practical (still find + read a coin).
- Does the native-token emphasis feel earned in each?
- Which could carry the *whole* Markets tab, not just a hero band?

## Notes
- Aesthetics-first per Jakub; numbers are plausible placeholders. Size=market cap, colour=24h% throughout.
- All buildable against `CoinGeckoMarketData` with no new data. C's interactive spotlight-swap and B's
  shimmer are the only motion beyond ambient.
- Real brand palette (`#05060A` canvas, `#14C8FF→#2BF5B4` gradient).
