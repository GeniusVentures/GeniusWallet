> ✅ RESOLVED 2026-07-23 — this handoff is HISTORICAL. The work it describes as uncommitted/next shipped in aa78eec; the ../GW-markets worktree was removed. Do NOT resume from it. Kept for history.

# Handoff — Markets page redesign (sketch 103 · H1)

**Session:** markets design/build (2026-07-23) · **Role:** design session (NOT executor)
**Sketch:** `.planning/sketches/103-markets-page/` — winner **H1 · Refined split**

## What was built
The Markets page (`/markets`) reworked from a flat card grid into **H1**: a hero card for the native
token (GENIUS AI) over a sortable "All Markets" table.

- **Hero** (`markets_hero_card.dart`): identity + 48px price + %-pill + abs 24h change + 2×2 stat
  block (Rank · Market Cap · Volume 24h · ATH) on the left; a 7d brand-gradient area chart with a
  visual timeframe selector on the right. Responsive: splits Row→Column below the `medium` breakpoint.
- **Table** (`markets_table.dart`): Rank · Coin · Price · 24h% · Market Cap · Volume · 7d spark, with
  **sortable headers** (tap to sort, tap again to flip). Rows tap through to `/token-info`. Scrolls
  horizontally below ~762px; no per-column mobile collapse yet.
- **Sort logic** (`markets_sort.dart`): pure, Flutter-free `compareMarketRows` + `MarketRowData` so it
  is unit-testable without pumping widgets.
- **Screen** (`markets_screen.dart`): pulls the native coin out into the hero, feeds the rest to the
  table. Same two chained fetches (coins → market data) and the same error/retry paths as before.

**No new data, no new API calls, no model changes** — every field comes from the already-fetched
`CoinGeckoMarketData` (`currentPrice`, `priceChangePercentage24h`, `priceChange24h`, `marketCapRank`,
`marketCap`, `totalVolume`, `ath`, `sparkline`).

## Where it lives
- **Worktree:** `../GW-markets`
- **Branch:** `redesign/markets-tab-260723` (off `efae33a`)
- **NOT committed** (CLAUDE.md: design sessions don't touch git; commits gated on Jakub's go).

Files:
- `lib/dashboard/chart/markets_sort.dart` (new)
- `lib/dashboard/chart/markets_hero_card.dart` (new)
- `lib/dashboard/chart/markets_table.dart` (new)
- `lib/dashboard/chart/markets_screen.dart` (rewritten)
- `test/markets_sort_test.dart` (new)

## Verification done (in the isolated worktree)
- `flutter analyze` on the 5 files → **No issues found**.
- `flutter test test/markets_sort_test.dart` → **5/5 passed**.
- **NOT run:** `flutter run` (executor-only; second instance dies on the Hive lock) and the full
  `flutter test` suite (executor-only baseline). Please eyeball in the running app.

## Known simplifications (ponytail)
- **Timeframe selector is visual-only** — the card only has 7d `sparkline`, so the chips move but
  don't re-window. Ties into the existing follow-up
  `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`.
- **Coins with no market data are hidden** (mirrors `DashboardMarkets`' `visibleCoins` filter) rather
  than the old per-cell red debug box.
- **Hero chart uses the 7d `sparkline`**, not `CryptoLiveChart` — deliberate, so the price stays on
  the left (H1 split) and no second fetch fires. If you want live/hover on the hero later, swap in
  `CryptoLiveChart` on the right and drop the left-column price duplication.

## Executor to-do
1. Review the branch, run `flutter analyze` + `flutter test`, `flutter run` to eyeball dark+light.
2. Add the sketch-103 winner row to `.planning/sketches/MANIFEST.md` — left to you to avoid a
   shared-file collision (row: `103 | markets-page | … | **H1 · Refined split** (impl in
   redesign/markets-tab-260723) | markets, page-layout, table, hero, sparkline`).
3. Commit / PR per Jakub's authorization.

## ⚠️ Heads-up from a run attempt (2026-07-23)
- **I stopped your running app.** With Jakub's go I killed the main-tree `flutter run` (PID 25225,
  `-d macos --dart-define=GW_DEV_TOOLS=true`) so a worktree instance could start (shared Hive
  container lock). Restart yours when convenient — nothing else in the main tree was touched.
- **The markets worktree won't `flutter run` on macOS as-is: signing.** `../GW-markets`'s
  `macos/Runner.xcodeproj/project.pbxproj` carries **`CODE_SIGN_STYLE = Manual` / team `P7T32QQX5V`
  / empty provisioning profile** → `"Runner" requires a provisioning profile` → **BUILD FAILED**.
  The config that actually builds/runs on this machine (your main tree) is **`Automatic` / team
  `9UJNVD92ZW`**. Fix before running the worktree: copy the main tree's `project.pbxproj` over, or
  set Automatic signing + team `9UJNVD92ZW` in Xcode. `macos/Podfile.lock` is also locally modified
  in the worktree. **None of this touches the Dart/markets code** — `flutter analyze` + the sort
  test both pass; it's purely the worktree's macOS signing.
- Simplest path may be to **integrate the branch into your main tree** (which already signs) and run
  there, rather than fixing signing in the throwaway worktree.
