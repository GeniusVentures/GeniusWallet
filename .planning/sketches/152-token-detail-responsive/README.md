---
sketch: 152
name: token-detail-responsive
question: "How does the token-detail page adapt across breakpoints — A (faithful two-panel) on tablet/full, D (unified stack) on mobile — using only data the app actually has?"
winner: "A@≥768 + D@<768 (chosen 2026-07-24)"
tags: [coin-detail, token-info, responsive, layout, convert, data-honesty, resolves-104]
---

# Sketch 152: Token detail — responsive

Resolves the open pick on **sketch 104** with Braian's walk feedback baked in.

## Decision (locked 2026-07-24)

- **Tablet & Full (≥768px)** → **A · Faithful cleanup** — two-panel: identity beside the hero price,
  boxed actions, chart in the left card; Info + Convert in the right column.
- **Mobile (<768px)** → **D · Unified stack** — one centered column, with **Convert directly below
  the graph** (order: identity+price → actions → chart → **Convert** → Info).

The 768px switch matches the code's own `medium` breakpoint (`GeniusBreakpoints.medium = 768`, the
same threshold `ResponsiveDrawer`/`useDesktopLayout` use).

## How to View

`open .planning/sketches/152-token-detail-responsive/index.html`

Use the bottom-right toolbar: **Dark/Light**, and **Phone / Tablet / Full**. The layout is driven by a
CSS **container query** on the app window, so Phone actually reflows to the D stack and Tablet/Full show
the A two-panel — no manual variant switch. Chart is live (hover for crosshair/tooltip; zoom/pan buttons).

## What changed vs 104 / the shipped screen

| Walk finding | Change in this sketch |
|---|---|
| Convert price was editable | **Token Price is read-only** (display row + `read-only` chip); only **Token Amount** is editable; Total = price × amount |
| Timeframe tabs imply data we can't fetch | **Removed** 1H/1D/1W/ALL — the chart keeps only the real **zoom/pan** control |
| % pill sign/color disagreed on hover | Pill color follows the **same value as the sign** (the `crypto_live_chart.dart:234` vs `:342` bug) |
| Chart cramped over empty gradient | Chart gets real room in the left card (A) / full-width card (D); no forced `Expanded` dead space |
| Responsive across screens | One design, two form factors — A at ≥768, D at <768 |

## Data provenance — every element maps to real code, nothing invented

| Shown | Real source |
|---|---|
| Icon · name · symbol · Network | `_MarketDataInfo` header + `CoinCardRow` (icon, name, symbol, Network) |
| Hero price + % change | `CryptoLiveChart` (`_displayPrice`, `%` vs oldest) |
| Chart series + zoom/pan | `CryptoLiveChart` `fetchHistoricalPrices` (single series) + existing zoom/pan |
| Actions: Receive (on), Send/Swap (disabled), More | `_buildStaticActions` — Receive wired; Send/Swap inert; More enabled for GNUS |
| Info: Network, Address (copy), Market Cap, Circulating Supply, Total Supply, Volume | `_MarketDataInfo` list rows (all real fields) |
| Convert: price × amount → total | `_ConvertSection` (`_calculateTotalValue = amount * price`) |

**Deliberately NOT shown** (would be invented — the code has no such field/fetch): timeframe-range prices,
rank, ATH, 24h high/low, fully-diluted valuation, holders. Sample values (price, supply, address) are
placeholders for real fields, not new fields.

## Not in this sketch (tracked separately)

- **Receive drawer** QR-too-big + oversized close (X) + tall header → those are **implementation drift**
  from the already-won **sketch 034-A2** (receive QR) and **030-B1** (drawer shell). Fix = bring the shipped
  `ResponsiveDrawer` / `CryptoAddressQR` to those winners, not a new design.
- **More → Bridge Tokens drawer** reads empty (one lone button) → separate content/design pass.

## What to Look For

- Toggle **Phone**: does the stack read well with Convert right under the chart?
- Toggle **Tablet/Full**: does the two-panel keep the chart used (not padded) and the right column tidy?
- Dark **and** light: surfaces, disabled Send/Swap legibility, pill contrast.
