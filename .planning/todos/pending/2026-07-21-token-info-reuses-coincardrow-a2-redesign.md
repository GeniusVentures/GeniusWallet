---
created: 2026-07-21T00:00:00.000Z
title: Token-info top slot reuses the A2-redesigned CoinCardRow — review during the token page work
area: ui
files:
  - lib/tokens/token_info_screen.dart
  - lib/components/coins/view/coin_card_row.dart
---

## Context

During the dashboard Assets-panel redesign (quick `260720-vwj`, 2026-07-21 dark walk),
`CoinCardRow` was rebuilt to the A2 market-forward layout (subtitle = price + 24h% chip,
trailing = fiat value over token amount, zero-balance dims only the holding numbers,
`networkSymbol`/chain suffix removed). A coverage audit found `CoinCardRow` has a **second
consumer**: `token_info_screen.dart:218` (`_MarketDataInfo.topSlot`).

- It **compiles clean** (never passed `networkSymbol`, so the field removal broke nothing).
- But the A2 redesign now **also renders on the token-details screen's top slot** — a side
  effect of the shared component, not an explicit design decision for that screen.

User decision (2026-07-21): **leave as-is for now** — the shared A2 look is an acceptable,
consistent default. Revisit when the token page / token screens are worked (roadmap Phase 7).

## To review during the token page work

1. Does the A2 row read right at the top of the token-details screen, or does that screen want
   its own row variant (option (b) — split `CoinCardRow` into an Assets-panel row vs a token-info
   header row)?
2. On token-info the coin is already the subject, so price+chip in the subtitle may be redundant
   with the rest of that screen — check for duplication.
3. If splitting, keep the Assets panel on the current A2 `CoinCardRow` and give token-info its own
   lightweight header row.

## Not a bug

This is a deliberate deferral, not a regression — the screen works and looks consistent today.
