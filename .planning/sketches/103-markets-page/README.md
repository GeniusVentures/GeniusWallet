---
sketch: 103
name: markets-page
question: "What structure should the full Markets page have, and how much of CoinGeckoMarketData should it surface — while reusing the components we already ship?"
winner: "H1"
tags: [markets, page-layout, grid, table, sparkline, coingecko, data-density]
---

> **Chosen 2026-07-23: H1 · Refined split** (hero + sortable table). Implemented in worktree
> `../GW-markets` on branch `redesign/markets-tab-260723` — see
> `.planning/handoffs/HANDOFF-markets-hero.md`. Not committed (design session; executor owns git).

# Sketch 103: Markets Page

## Design Question
The current Markets page (`lib/dashboard/chart/markets_screen.dart`) is a flat 4/3/2/1 responsive
grid of identical `CryptoSparkLineChart` cards, ordered by the hardcoded `topCoinsByCapitalization`
array. Each card shows only **name · price · spark · %** — 4 of the ~26 fields on
`CoinGeckoMarketData` — and leaves a large dead gap in the centre of every wide card.

What should the page **structure** be, and how much extra data should it surface, without
abandoning the components already shipped? All variants add **rank + market cap** (Jakub's call).

## How to View
open .planning/sketches/103-markets-page/index.html

Use the top tabs to switch variants; the Dark/Light toggle re-renders sparkline colours.

## Variants
- **A · Faithful grid+** — today's card grid, but the sparkline is **flexible-width** (eats the dead
  centre), a muted `#rank · $mktcap` line sits under each name, and search is a real header field
  instead of a hidden drawer icon. Path of least resistance — no page-structure change.
- **B · Ranked table** — CoinGecko/CMC-style sortable table: Rank · Coin · Price · 24h% · Market Cap ·
  Volume · 7d spark. Densest use of the model; click headers to sort. Reuses sketch 023's table
  pattern. GENIUS AI stays tinted so it's findable when sorted down.
- **C · Featured + grid** — a GENIUS-AI hero card (big price, 7d area chart à la sketch 006,
  rank/mktcap/volume/high-low stats) over the compact grid for everything else. Surfaces the native
  token the hardcoded-first order already privileges.
- **D · Segmented markets** — A's cards plus a toolbar: **All / Gainers / Losers / Favorites**
  segmented control (008/022 component) + inline search + sort select. Segments and sort are live.

## What to Look For
- **Does the dead-centre gap read as fixed?** (A/C/D flexible spark vs B's dedicated column.)
- **Is rank + market cap enough, or does the table's fuller column set earn its density?** (A/C/D vs B)
- **Does featuring GENIUS AI feel right, or preferential?** (C)
- **Is browsing chrome — filters/sort — worth the toolbar height?** (D)
- All four in **dark + light**; sparkline colour must track the theme.

## Grounding notes
- Cards keep the shipped anatomy from `CryptoSparkLineChart` (icon · name · price · spark · %-chip);
  the % chip uses `--status-success/error-fill` tints verbatim.
- Table/hero reuse patterns already approved in sketches 023 (table) and 006 (chart hero).
- Data mirrors the screenshot's real prices/percentages; market caps/volumes are plausible fillers
  for layout only — the real page reads them off `CoinGeckoMarketData` (`marketCap`,
  `marketCapRank`, `totalVolume`, `high24h`, `low24h`).
