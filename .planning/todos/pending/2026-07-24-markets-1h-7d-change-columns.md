# Markets table: wire real 1h % and 7d % change data (columns are placeholders)

**Filed:** 2026-07-24 · **Where:** `lib/dashboard/chart/markets_table.dart`

## What shipped as a placeholder
The Markets table now shows **1h %** and **7d %** columns (between Price and 24h %, then after
24h %) to match the requested layout. They currently render a marked-absent **`-`** via
`_changePlaceholder(gw)` — NOT a fabricated number. Search the file for `ponytail:` to find every
spot. `_minTableWidth` already reserves the width (`_wChange * 3`).

## Why placeholder, not real
`CoinGeckoMarketData` has only `priceChangePercentage24h`. There is no 1h or 7d change field, and
the `/coins/markets` fetch (`coin_gecko_api.dart:140`) does not request them. Wiring real values is
a data-model change (Hive), so it was deliberately deferred and marked rather than faked.

## Upgrade path (to make the columns real)
1. **Fetch** — `coin_gecko_api.dart:140`: append `&price_change_percentage=1h,24h,7d` to the
   `/coins/markets` URL. (Verified live: CoinGecko returns
   `price_change_percentage_1h_in_currency` / `_7d_in_currency` with that param.)
2. **Model** — `lib/hive/models/coin_gecko_market_data.dart`: add nullable
   `priceChangePercentage1h` and `priceChangePercentage7d` (nullable so pre-migration cached
   entries are safe), parse them in `fromJson` from the `*_in_currency` keys, add to `toJson`.
3. **Hive** — new `@HiveField(<next free index>)` on each; regenerate with
   `dart run build_runner build --delete-conflicting-outputs`. Old cached rows lack the fields →
   they read null → keep the `-` fallback until the ~2-min cache refresh (graceful, no crash).
4. **Table** — `markets_table.dart`: replace the two `_changePlaceholder(gw)` calls with real
   change pills (mirror the 24h pill: `changeColor` fill + signed `%`). Optionally add
   `MarketSort.change1h` / `change7d` + wire the header `cell(...)` sort args (currently `null`).

## Note
- 7d % *could* be approximated from the existing `sparkline` (last vs first point) with zero data
  change, but it is granularity-limited and not the accurate CoinGecko figure. The columns were
  kept as honest placeholders instead of shipping an approximation.
- Scope caveat (separate): the app fetches a limited `ids` set, so "the market" here is that set,
  not the true top-N by market cap. A full-market Markets page needs `/coins/markets` without the
  `ids=` filter (top-N + pagination).
