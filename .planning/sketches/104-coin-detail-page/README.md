---
sketch: 104
name: coin-detail-page
question: "What structure should the coin detail page (/token-info) have so identity + price + chart + actions + stats + convert read as one page — reusing today's data and widgets?"
winner: null
tags: [coin-detail, token-info, chart, layout, actions, convert, market-data]
---

# Sketch 104: Coin detail page

## Design Question

The current `/token-info` page (`lib/tokens/token_info_screen.dart`) has all the right data but
scatters it: the coin's **identity lives in the right-hand Info panel**, ~800px from its own hero
price; the chart's `Expanded` eats the whole left column so the price + actions cluster tiny at the
top over a mostly-empty gradient; the actions float uncontained; and the **% pill color contradicts
its sign** on hover. What page structure pulls it back into one coherent whole — without touching the
data layer?

## Grounding (what's reused, verbatim)

Every variant surfaces **only the data the code already has** — no new API fields:

| Widget today | Data | Where it lands in the sketch |
|---|---|---|
| `CryptoLiveChart` | price, %, hover tooltip (time/price/%), zoom+pan | hero price + chart card |
| `_buildStaticActions` | Receive · Send · Swap · More (+ Bridge for GNUS) | `.actions` row |
| `_MarketDataInfo` | icon, name, symbol, Network, Address, Market Cap, Circ/Total Supply, Volume | identity + Info list |
| `_ConvertSection` | token price × amount → total | Convert card (live calc) |

## How to View

`open .planning/sketches/104-coin-detail-page/index.html`
(or serve the `sketches/` dir and hit `/104-coin-detail-page/index.html` — file:// is blocked for the Chrome extension.)

Charts are real SVG: hover for the crosshair/tooltip, use the zoom/pan buttons, edit the Convert
fields to see the total recompute, and toggle Dark/Light + Phone/Tablet/Full in the bottom-right toolbar.

## Variants

- **A · Faithful cleanup** — today's 2-panel split, made coherent. Identity pulled up *beside* the
  hero price; actions boxed; chart gets a header; right column keeps Info + Convert. **Smallest port.**
- **B · Exchange header** — full-width identity + price + inline key-stats strip (Coinbase/Binance
  coin-page feel), full-width chart below, actions + Info + Convert in a bottom row. Most "pro-trader."
- **C · Identity rail** — fixed left column = identity card + price + vertical actions + Convert,
  always visible; the main area gives the chart the room the current page wastes; stats become a
  horizontal strip under the chart. **Biggest chart.**
- **D · Unified stack** — one centered column of cards (identity+price → actions → chart → Info →
  Convert). Nothing is force-stretched, so the dead space disappears — and **this is also the mobile
  layout** (one layout, two form factors).

## Findings baked into every variant

- **% pill bug fixed.** In the live app the pill *color* tracks `_latestPrice vs _oldestPrice`
  (`crypto_live_chart.dart:234`) while the *number* tracks `_displayPrice` (hovered) vs open
  (`:342`) — so on hover the sign and color disagree (the screenshot shows `+0.21%` in a **red**
  pill). Here color always follows the same value as the sign.
- **Identity next to price.** The coin icon/name/symbol/network sits with the hero price in all four,
  not exiled to the Info panel.
- **No forced dead space.** The chart is given real room (C) or the column simply hugs its content
  (D) instead of an `Expanded` stretching an empty gradient.

## Open decisions (for the pick)

- **Timeframe tabs (1H/1D/1W/ALL)** are drawn but currently *visual only* — the code has no
  per-range fetch (`fetchHistoricalPrices` returns one series; zoom/pan is the real control). Building
  them means adding range fetches = a data-layer change. They follow the **sketch 006** direction
  (dashboard chart timeframe selector). Decide: ship timeframe tabs, or keep zoom/pan only for now.
- **A vs B vs C vs D** as the page structure. A is the cheapest port; C/D best kill the dead space.

## What to Look For

- Where does your eye land first — and is it the coin + its price, or an anonymous number?
- Does the chart feel *used* (C/D) or *padded* (today)?
- On desktop, is the two-panel (A/B) or the single-column (D) rhythm more "GeniusWallet"?
- Mobile: only D is automatically the phone layout — do A/B/C need a separate mobile pass?
