# Phase 16 — Markets page (sketch 103 · H1)

**Status:** implementation already built in worktree, **not committed**. This phase is a
*plan-and-integrate* phase, not a from-scratch build — most of the work exists; it needs review,
integration into the main tree, and the human walk.

## Goal
Replace the flat Markets card grid with **sketch 103 · H1 "Refined split"**: a native-token
(GENIUS AI) hero card over a sortable "All Markets" table.

## Design contract
- Sketch: `.planning/sketches/103-markets-page/` — winner **H1** (see README `winner: "H1"`).
- Hero: identity + 48px price + %-pill + abs 24h change + 2×2 stats (Rank · Market Cap · Volume 24h ·
  ATH) left; 7d brand-gradient area chart + visual timeframe selector right; responsive Row→Column.
- Table: Rank · Coin · Price · 24h% · Market Cap · Volume · 7d spark, sortable headers, row →
  `/token-info`; horizontal scroll below ~762px.

## Where the implementation lives
- Worktree `../GW-markets`, branch **`redesign/markets-tab-260723`** (off `efae33a`), **not committed**.
- Files: `lib/dashboard/chart/markets_hero_card.dart` (new), `markets_table.dart` (new),
  `markets_sort.dart` (new, pure/testable), `markets_screen.dart` (rewritten),
  `test/markets_sort_test.dart` (new).
- No new data / API / model changes — all fields already on `CoinGeckoMarketData`.

## Verified
- `flutter analyze` (5 files) clean · `flutter test test/markets_sort_test.dart` 5/5.
- NOT run: `flutter run` (executor-only; Hive lock), full suite.

## Remaining work (what this phase must close)
1. Integrate `redesign/markets-tab-260723` into the main tree (or cherry-pick the 5 files).
2. **macOS signing:** the worktree's `project.pbxproj` is Manual/team `P7T32QQX5V` (fails); the main
   tree signs with Automatic/team `9UJNVD92ZW`. Building in the main tree avoids this.
3. Human walk — dark + light; check hero split at wide/narrow, table sort + horizontal scroll.
4. Add sketch-103 winner row to `.planning/sketches/MANIFEST.md`.

## Known simplifications (ponytail)
- Timeframe selector is visual-only (only 7d `sparkline` exists) — ties to the existing
  `2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart` todo.
- Coins with no market data are hidden (mirrors `DashboardMarkets`), not shown as a debug box.

Full handoff: `.planning/HANDOFF-markets-hero.md`.
