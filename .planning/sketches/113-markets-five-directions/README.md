---
sketch: 113
name: markets-five-directions
question: "Five distinct redesigns of the Markets page, each making GENIUS AI structural, not a banner."
winner: null
tags: [markets, five-directions, native-token, structure, editorial, ledger, glance, plain, ai]
---

# Sketch 113: Markets — 5 directions

## Brief
Market-tracking screen only (no transactional action, none implied). Audience: GENIUS AI
holders/community, daily returners asking "how's our token today". GENIUS AI must be **structural** -
always visible without search/scroll/filter - solved differently in each direction. Directions 1-4:
zero new features, existing data only. Direction 5: unconstrained.

Available data (verified in code): coin icon (`buildTokenIcon(imageUrl)`), name, price, 24h%,
market cap, volume, rank, ATH gap, 7d sparkline; sort, search, token detail. NOT available: total
cap/volume/BTC-dominance (`/global`), Fear&Greed (external), 30d/1y ranges.

## How to View
open .planning/sketches/113-markets-five-directions/index.html

## The five (each: signature · sacrifice · how GENIUS AI is structure)
- **1 · Ledger** — precise sortable table. Signature: GENIUS AI is a **pinned lead row** above the
  ranked market. Sacrifice: no chart/atmosphere. Rejected: BTC-dominance column (needs /global).
- **2 · Editorial** — magazine front page, breath. Signature: the **featured slot is permanently
  GENIUS AI** with a 7d chart. Sacrifice: density. Rejected: multi-range selector (only 7d exists).
- **3 · Glance** — 15-second check. Signature: GENIUS AI **is the page headline** (oversized price +
  today + spark); market is a thin strip. Sacrifice: depth.
- **4 · Plain** — for non-chart-readers. Signature: status **in words** ("up a lot today") + plain
  up/down cards, no rank/ATH/mcap jargon. Sacrifice: precision.
- **5 · Unconstrained** — the market seen through your token. Signature: **AI briefing + percentile
  meter + every row measured relative to GENIUS AI**. Sacrifice: buildability. New data: AI insight,
  percentile, relative strength.

## What to Look For
- Which "GENIUS AI as structure" solution passes the test: would it still make sense as "your token
  vs the market" if it were someone else's token?
- Which single signature is most memorable, and is its sacrifice acceptable for daily holders?
- 1-2 are on the shipped design system; 3-4 are proposals; 5 is a north star.

## Notes
- All on real brand palette + app page frame (navbar · GWPageHeader · 1180 frame · GWCards).
- 1-4 buildable on existing data; 5 flags its new-data cost explicitly.
