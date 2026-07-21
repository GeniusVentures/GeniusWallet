---
created: 2026-07-21T00:00:00.000Z
title: Wire real 1H/1D/1W/1M/1Y ranges into CryptoLiveChart (timeframe segment is visual-only)
area: ui
files:
  - lib/chart/crypto_live_chart.dart
  - lib/dashboard/home/view/dashboard_screen.dart
---

## Problem

Quick task 260721-dws re-skinned the dashboard Bitcoin Chart card to sketch 006 A→: a
`1H·1D·1W·1M·1Y` timeframe segment now sits top-right of the header, opposite the coin
identity. Per the user decision recorded 2026-07-21
(`user-decision:timeframe-segment-visual-only-keep-zoom-pan`), this segment ships
**VISUAL-ONLY** this task — tapping a tab moves the selected chip
(`_TimeframeSegmentState._selected` in `dashboard_screen.dart`) but does **not** change the
plotted series. `CryptoLiveChart` still pulls one fixed historical series (`_fetchHistoricalData`)
and offers zoom/pan (`_zoomIn/_zoomOut/_panLeft/_panRight`) exactly as before.

This is a deliberate, in-scope simplification for a re-skin task (**re-skin, never restructure**
per the port's scope rule) — wiring real ranges is a **data change**, not a visual change, and
was out of scope for 260721-dws.

## Solution

TBD — when this is picked up:

1. `CryptoLiveChart` needs a way to fetch/derive a price series scoped to a requested range
   (1 hour / 1 day / 1 week / 1 month / 1 year), likely via CoinGecko's
   `market_chart` range endpoints (`coin_gecko_api.dart`) rather than the current fixed
   `fetchHistoricalPrices` call.
2. `_TimeframeSegment`'s selected index needs to be lifted out of its private State and
   plumbed down to `CryptoLiveChart` (e.g. a `range` parameter + callback), replacing the
   private `_selected` int with a real controlled value.
3. **Decide whether zoom/pan is still needed once ranges are wired.** Zoom/pan was
   deliberately KEPT in 260721-dws (deleting working behaviour violates the port rule) even
   though the A→ visual language conceptually replaces it with timeframe tabs. Once a range
   selector actually re-fetches data, zoom/pan over an already-scoped range may be redundant,
   or may still be useful for drilling into the fetched window — a product call, not a given.
4. Keep the % pill / hero price / mint chart / hover tooltip styling from 260721-dws
   untouched; this follow-up is data-wiring only.
