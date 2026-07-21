---
sketch: 001
name: holdings-panel
question: "How should the dashboard assets panel read before the wallet has any balance?"
winner: "A2 · Market-forward + Stacked header + Center gap"
tags: [dashboard, empty-state, assets, coins]
---

# Sketch 001: Assets Panel

## Design Question

The shipped panel (`coin_card_row.dart`, from plan 05-03) repeats *"No balance yet"* on every row and
leaves the entire right column empty (`:65,:77` skip the trailing column when `balance == 0`). Four
identical italic subtitles read as a broken fetch, not an empty wallet. How should this surface read?

## How to View

```
open .planning/sketches/001-holdings-panel/index.html
```

Toolbar: **Layout** (A1/A2/A3) · **Header** (Stacked/Minimal/Left/Inline) · **Gap** (Center/Divider/Balanced)
· **State** (Empty/Funded) · **Theme** (Light/Dark).

## Decisions (winner)

- **Section name → `Assets`.** Broadest crypto-wallet standard (Coinbase); covers native coins + tokens + NFTs.
- **Layout → A2 · Market-forward.** Subtitle = price + 24h % chip (*what the coin is doing*); right column =
  fiat value over token amount. Chosen because it matches the Coinbase/Trust convention *and* structurally
  fixes the empty state — price + % never depend on balance, so a zero row still looks fully alive.
- **No sparkline** in rows (explicitly cut — too busy at row scale).
- **Header → Stacked.** `Assets` left; right = total (20px, amount-first) over a quiet `+$63.66 · +2.53%`
  subline (13px, success/error tinted). Amount-first is the convention the eye reads by size; the change
  ($ + %) rides underneath without crowding. No count/"funded" text beside the title.
- **Gap → Center.** Header right block is reserved at two-line height (`min-height:45px`, justify-center)
  so **empty ($0.00, one line) and funded (amount + change) keep identical header height** — the gaps
  between panel-top → `Assets` → first row do not shift between states. `Assets` vertically centers against it.
- **Zero-balance rows** dim only the *holding* numbers (amount + fiat value, 38% opacity); market numbers
  (price, %) stay full strength. A single footer strip carries Receive / Buy GNUS while empty.
- Rejected: A1 (holdings-forward), A3 (clean), header Minimal/Left/Inline, gap Divider/Balanced. All preserved
  in the toggles for reference.

## Findings To Carry Into The Port

1. **Light-mode contrast failures in the shipped tokens** (must fix during the port — AA both themes):
   | Token | On light surface | Ratio | Port to |
   |---|---|---|---|
   | `textSecondary` `#8A8F9D` | `#FFFFFF` | **3.0:1 ✗** | `#5A606E` (6.3:1) |
   | `statusSuccess` `#0AD89C` | `#FFFFFF` | **1.9:1 ✗** | `#07875F` (4.5:1) |
   | `statusError` `#FF4D4D` | `#FFFFFF` | **3.3:1 ✗** | `#D92D2D` (4.8:1) |
   All three pass in dark. `textSecondary` is declared **mode-invariant** in
   `genius_wallet_colors.dart:114-144` — it must become appearance-aware.
2. **Gains are painted cyan, not green.** `coin_card_row.dart:41` uses `cs.primary` for a positive
   gain/loss. Almost certainly unintended; the token is `statusSuccess`.
3. **Three up/down palettes are live** — `CoinCardRow` (cyan/`cs.error`), `CryptoSparkLineChart`
   (`mutedGreen`/`Colors.red`), and `statusSuccess`/`statusError`. The port standardizes on the status tokens.
4. **`networkSymbol` is fetched and never rendered.** A2's subtitle/`· network` spends it — no new plumbing.
5. `GWTokenRow` (`lib/components/cards/gw_token_row.dart`) is a tokenized row widget nothing on the
   dashboard uses. The port should land the redesign there (or in `CoinCardRow`) rather than the bare `ListTile`.
6. The panel currently has **no header**; the port adds the `Assets` + total/24h-change header. Consider the
   pending todo `2026-07-20-unify-dashboard-section-card-titles.md` — this header should follow that decision.
