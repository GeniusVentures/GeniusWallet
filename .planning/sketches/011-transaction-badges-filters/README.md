---
sketch: 011
name: transaction-badges-filters
question: "What colour should each type/status badge be, and how should filters cover all 7 TransactionTypes?"
winner: "Scheme 1 · Restrained (badges) + F1 two-tier (filters)"
tags: [transactions, badges, color, filters, tokens]
---

# Sketch 011: Transaction Badges + Filters

## Design Question
Two questions in one surface: what colour is each badge, and how do filters reach every
`TransactionType`? Introduced the proposal format Jakub then asked to keep for all future designs
(provenance tags, whole schemes, inline contrast math, code-grounded findings).

## Outcome
- **Badges: Scheme 1 · Restrained** — colour only where money moved; everything else neutral.
- **Filters: F1 two-tier** recommended and later confirmed.

## The coverage bug this sketch found
`Filters` (`transactions_slim_view.dart:16`) is `{all, sent, received, escrow, mint}` while
`TransactionType` has seven values. **`swap`, `purchase` and `process` are unreachable by any
filter** — a swap can only ever be found under "All". Not a styling preference; a coverage bug.

## Key technical finding
Badges are **filled circles with a knocked-out glyph**, so the contrast that matters is
glyph-against-fill, not fill-against-background. Saturated colours are therefore safe in both themes
where the same colours would fail as text. Also: `statusWarning` (#FFC42E) exists only as a static in
`genius_wallet_colors.dart:178` — it is **not** in the `GWColors` extension, so it is not
appearance-aware and would fail AA as text on white (1.7:1).
