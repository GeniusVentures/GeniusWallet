# Sketch 177 - the Assets page

http://localhost:8899/177-assets-full-page/

Phase 25 caps the Home dashboard at the top 5 assets behind a **View all**. Transactions and Markets
already have full screens to land on (`/transactions`, `/markets`). **Assets had nowhere to go** -
there is no `/assets` route. This sketch decides what that page is.

Five variants, all clickable, each with a **FUNDED / EMPTY** switch: Jakub's real wallet has every
balance at zero, and a page that only looks right when full is a page that looks broken most of the
time.

| Scheme | Idea | Verdict |
| --- | --- | --- |
| A | Total, then every asset in fetched order | Cheapest; worst when empty |
| B | `GWControlTrack` segment: All / Holdings / Watch | Good fit, but "Watch" promises a feature that does not exist |
| C | Grouped: "Your holdings" sorted by value, "Other assets" collapsed | Was the recommendation |
| **D** | Search + sort | **CHOSEN** |
| E | Allocation bar first | Best at a glance when funded, collapses when empty |

## DECIDED 2026-08-07: variant **D, simplified** - search + a single value sort

Jakub picked D over the recommended C, then cut it down himself: **sort by value only, tapping
toggles ascending / descending.** No name sort, no 24h sort. The concern (search earns its place at
50+ rows, not 8) was raised before he chose and he decided anyway. Recorded, not silent.

**The cut solves the empty-wallet problem for free.** Default descending puts real holdings on top
and pushes every `$0.00` row to the bottom - which is what C's two-section split was buying. No
grouping needed.

## Component audit for D-simplified

| | Count | What |
| --- | --- | --- |
| Reused as-is | **7** | `GWPageHeader`; `GWTextField` (already carries `leadingIcon`, `hint`, `onChanged` - a search field needs nothing added to it); `CoinCardRow`; `GWEmptyState`; `assets_totals.dart` pure helpers; `WalletDetailsCubit` coin data; `onCoinSelected` -> `/token-info` |
| Adapted | **0** | Dropped by the simplification. One key plus a direction is a few lines, not a model - `markets_sort.dart`'s `MarketSort` enum was only worth mirroring for the three-key version |
| New | **2** | the `/assets` route; the tappable `Value ⇅` affordance |

## Two costs of D that are real and accepted

1. **D does NOT get `CoinsScreen(isDashboard: false)` for free.** That was variant A's whole saving
   (one route, one flag). `CoinsScreen` exposes no hook for filtering or ordering and owns a
   1-minute market-data refresh timer we must not duplicate, so D assembles its own list from
   `CoinCardRow` plus the cubit.

   > **CORRECTION, 2026-08-07, verified in source.** `CoinsScreen(isDashboard: false)` was never
   > compilable in the first place. **There is no `isDashboard` parameter.** The constructor takes
   > `onCoinSelected`, `filterCoins` and `isUseDivider`; `isDashboard` is a local bool *derived* at
   > `coins_screen.dart:247` as `widget.onCoinSelected == null`. So the "cheap option" this section
   > says D gives up did not exist to give up. The conclusion is unchanged and now rests on a true
   > premise. The same false API is repeated in `.planning/phases/25-.../BRIEF.md`'s original open
   > question, annotated there too.
2. **Use `GWPageHeader` ONLY on this page - no `GWSectionTitle` underneath.** Otherwise it prints
   "Assets" twice, which is exactly the duplicate-title defect Jakub flagged on Transactions and
   parked for a separate sweep.

## Still open

Sorting a holding that has a balance but **no market data** (value unknown). Proposal: keep it above
priced rows in descending order, since "you own this and we cannot price it" outranks any priced
row.

## Provenance

Tokens verbatim from `genius_wallet_colors.dart` / `genius_wallet_consts.dart`. Phones are 390x844
at 1:1 with the real shipping bar geometry (60px bar, 64px dock, 26px overhang, 84px slot). Prices
are illustrative; totals, ordering and percentages are computed live from them in every variant.
`node --check` clean; div balance 0.
