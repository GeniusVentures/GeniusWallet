---
task: 260728-u8p
title: "Coin page whole screen (sketch 071-B Stat rail) + no-data state"
status: complete
sketch: 071
variant: B
date: 2026-07-28
commits: false   # CLAUDE.md: "Do not create commits"
analyze_lib: 59  # baseline
tests: "370 pass / 1 fail (from 364/1) - the single failure is the inherited local_wallet_storage_test.dart"
walk: pending
relaunch_required: true
---

# 071-B shipped

Jakub: *"zrób redesign tego całego screenu, łącznie z navigation barem u góry"* - *"bo wygląda
słabo"*. It did, and the reasons were measurable.

**The promise held: zero backend work.** Same CoinGecko endpoint, same model, same Hive box, no new
request. The only logic touched is formatting.

## The three defects, fixed

**1 · `SizedBox(height: 480)` is gone.** That one literal was most of the complaint: with a ~530px
Info+Convert column beside it, the page's content ended near 620px on a 1335px window and **roughly
half the screen was empty**. The chart now takes its height from the viewport via
`coinChartHeight(viewportHeight, isDesktop)` - pure, public and tested, because a constant passes
every screenshot. Floor of 300 so a short window scrolls instead of squashing; mobile keeps 260,
where the page is one scrolling column (152-D) and there is no viewport to fill.

**2 · The page is inside the `ShellRoute`.** It was the only screen in the app outside it
(`router.dart:243`, shell closing at 242), which is why it was the only screen with no navigation.
Now the navbar is the top of the window like everywhere else, and it pushes onto the shell's own
Navigator so the chrome never unmounts.

**3 · One frame for the whole app.** `maxWidth: 1200` centred + `space10` → `xxl` (1536) with a 12px
gutter, copied from `markets_screen.dart`, so the coin title lands on the **same x** as "Markets" on
the page you arrived from. The 48px `AppBar` and its hand-built breadcrumb are deleted; identity and
price are a `GWPageHeader` with a `‹ Markets` chip above it.

## The stat rail

Six tiles above the chart: Rank, 24h change, Volume 24h, Market cap, From ATH, 24h range (with a
position bar). They wrap 6 → 3 → 2 by width rather than ellipsing every value at once.

**Every field was already parsed and already cached** - `/coins/markets` returns all of them by
default and they sit in `marketDataBox` on a 3-minute TTL. This row is the fill for the space the 480
literal wasted, and it costs nothing to fetch.

**The "0 means unknown" rule is enforced, and it is the real risk here.** `fromJson` defaults every
numeric to `0.0` and the rank to `0`, so a coin missing a field would render `$0.00`, `#0` and
`0.00%` - confidently and wrongly. `_formatCompactCurrency`/`_formatCompactDecimal` were lifted out
of `CoinInfoCard` to top level so the rail uses the **same** rule instead of a third copy, plus
`formatPercent` and `formatPrice` in the same shape.

## `GWStatTile`, and a correction I owe

**Sketch 071 claimed this pattern already existed twice** - `markets_hero_card` "and the dashboard
has another" - which made the coin page a third consumer that cleared the promotion bar
automatically. **That was wrong.** `grep` for `GWKicker(dense:` returns exactly ONE hit in the app:
`markets_hero_card.dart:263`, the private `_Stat` used four times. The dashboard has nothing like it.
So the coin page made it a **second file**, under the 3+ bar `GWKicker`, `GWSelectRow` and
`GWWarningNote` each cleared, and I said I would write it locally.

**Jakub overrode that on the instance count** - *"utworz component zatem by byl i by oba miejsca go
uzywaly"* - and he is right: ten uses of one two-line widget, and the widget is small enough that a
component costs less than a second copy. Shipped as `lib/components/cards/gw_stat_tile.dart` with
`_Stat`'s values verbatim, so **the Markets hero moved nothing on screen**; `_Stat` deleted, all four
Markets call sites migrated.

Two things deliberately NOT parameters: the **box** (Markets shows these bare inside its hero, the
coin page puts each in a `GWCard` - composition at the call site, not a `boxed` flag) and the
**range bar** (`_RangeTile` wraps the tile in a Column rather than the component growing a `footer`
slot for one consumer).

## The no-data state

Jakub's decision: *"wtedy no data czy coś"*. Four call sites push `/token-info`; the fourth - the
wallet's own Assets list (`coins_screen.dart:296`) - passes `_marketData[coin.symbol?.toLowerCase()]`,
a map lookup returning **null** for any wallet coin CoinGecko does not cover. The old layout's
`if (marketData != null)` then silently dropped the hero, the action bar **and** the chart, and
nobody had ever drawn the result.

Now `GWEmptyState` says it, and per Jakub's condition **the action bar and the Info card survive** -
Receive does not need a market price. `GWPageHeader` falls back to the `Coin`'s own name and symbol,
because what is missing is the market data, not the coin.

## Checks

`test/tokens/coin_page_stat_rail_test.dart`, 6 tests.

- **The 480 literal cannot come back**: two viewports must give two heights, and the difference must
  equal the difference in viewport height. Plus the floor, plus mobile's fixed 260.
- **0 means unknown**: every formatter returns `N/A` for `0` and `null`, and real values still
  format. The sign is explicit on the way up, because `2.90%` and `+2.90%` read differently beside a
  red one.
- **The no-data page** is a real render, because it is a layout claim: `GWEmptyState` present AND
  `TokenActionBar` AND `CoinInfoCard` still there.

## Walk fix, same session: the chart is now IN LINE

Jakub, on the first look: *"ten graph jest znacznie większy [...] ma być dostosowane do wysokości
łącznych sekcji INFO i CONVERT. Musi być IN LINE."*

Fair, and it is the 480 literal's opposite error: deriving the height from the viewport fixed the
empty page and overshot the other way, leaving the row ragged at the bottom.

The wide layout is now an `IntrinsicHeight` row: the Info+Convert column reports its real height, the
chart reports **zero** and stretches to meet it, so the two columns end on the same line at every
window size and nothing has to be guessed.

The zero is a four-line `RenderProxyBox` (`_FillHeight`) rather than a number, and it is load-bearing
in a way worth recording: `IntrinsicHeight` asks every child how tall it wants to be, and
`CryptoLiveChart` contains an `Expanded`, which **throws** when asked for an intrinsic dimension.
Answering 0 both dodges that and hands the decision entirely to the column beside it.

`coinChartHeight` stays, and stays tested - it is still what the stacked layouts (<1024, mobile, and
the no-data page) use, where there is no column to line up with.

## Consequence to know about

**`TokenDetailHero` now has zero consumers.** Identity and price moved into `GWPageHeader`, so both
its uses are gone. Not deleted here - it is the only implementation of the stacked identity block the
<360 layout used, and nobody has walked the coin page at 360 since. Filed as
`todos/pending/2026-07-28-token-detail-hero-is-now-dead-code.md` with the decision spelled out:
delete it if the header reads well on a phone, re-consume it if not.

## Gates, honestly

`flutter analyze lib` **59** = baseline. `flutter test` **370 pass / 1 fail**, from 364/1; the single
failure is the inherited `local_wallet_storage_test.dart`, commented out since 2025-05-25 and so
missing a `main()`.

**The app was RELAUNCHED, not hot-reloaded, and that is not a formality.** `geniusWalletRouter` is a
top-level `final`, so a route move is never picked up by `r` - reporting a hot reload here would have
been reporting nothing. The old instance was stopped first to avoid the Hive lock.

**WALK PENDING**, and this one needs a real walk more than most:

1. **The navbar at the top of the coin page** - the change the whole task is about, and invisible in
   a screenshot of the content.
2. **Back from all four entry points**: Markets table, Markets search, dashboard Markets, and the
   wallet's Assets list. The route move changed which Navigator `pop` talks to.
3. **The no-data page**, reachable from Assets on a coin CoinGecko does not cover.
4. **Narrow widths**: 900 (the rail wraps to 3), 600 (to 2), and below 768 where the 152-D stack
   takes over. The mobile shell also adds a bottom nav this page has never had.
5. **The stat rail's numbers against the Markets table** for the same coin - they come from the same
   cache and must agree.
