---
task: 260728-u8p
title: "Coin page whole screen (sketch 071-B Stat rail) + no-data state"
sketch: 071
variant: B
created: 2026-07-28
commits: false   # CLAUDE.md: "Do not create commits"
---

# 071-B on the coin page

Winner B, with the null-`marketData` state answered by Jakub: an explicit no-data message, not a
silent collapse. **Zero backend work** - same endpoint, model and Hive box; only formatting logic is
touched.

## Tasks

### 1 · Route into the ShellRoute
`GoRoute('/token-info')` moves inside the shell's `routes` list. Three knock-ons verified before
changing, not assumed: back navigation from all four push sites, `state.extra` still arriving, and
the mobile bottom nav the page has never had. A router change likely needs a **full relaunch**, not a
hot reload - say so rather than reporting a reload as proof.

### 2 · Header + frame
Delete the 48px `AppBar` and its hand-built breadcrumb. `GWPageHeader(title, subtitle, trailing)`
with a `‹ Markets` back chip above it. Frame `1200 centred + space10` → `xxl (1536) + 12px gutter`,
copied from `markets_screen.dart` so the coin title lands on the same x as "Markets".

Back moves from `Navigator.of(context).maybePop()` to `context.pop()` - inside a shell the go_router
call is the one that means "go back in the route stack" rather than "pop whatever Navigator is
nearest".

### 3 · The 480 literal
`SizedBox(height: 480)` → height derived from the `LayoutBuilder` already present, with a floor so it
never collapses. Nothing overflows today; do not invent an overflow fix.

### 4 · The KPI rail
Six tiles: Rank, 24h change (mint/red), 24h volume, Market cap, From ATH, 24h range (with a position
bar). All six fields are already parsed and cached. **Every number goes through the existing
`_formatCompactCurrency` / `_formatCompactDecimal` "0 means unknown → N/A" rule** - `fromJson`
defaults to `0.0`/`0`, so an absent field would otherwise print a confident `#0` / `$0.00` / `0.00%`.

**The tile is written LOCALLY, not promoted. This corrects the sketch.** 071's README claimed the
pattern exists twice already (`markets_hero_card` + "the dashboard"). Checked: `GWKicker(dense) + a
value` appears in **exactly one** place, `markets_hero_card.dart:263`. The coin page makes it the
**second file**, under the 3+ bar `GWKicker`, `GWSelectRow` and `GWWarningNote` each cleared. Todo
filed instead; a third consumer triggers the promotion.

### 5 · The no-data state
`marketData == null` (reachable from `coins_screen.dart:296`, a map lookup for a wallet coin
CoinGecko does not cover) currently drops the hero, the action bar AND the chart silently. Now:
`GWEmptyState` in place of the price/KPI/chart block, with the **action bar and Info card kept** -
Receive does not need a market price. `GWPageHeader` falls back to the `Coin`'s own name/symbol,
since what is missing is the market data, not the coin.

### 6 · Checks + gates
Three: a tile fed `0` prints `N/A`; `marketData: null` renders the empty state AND still renders the
actions and Info; the chart height is not a constant (differs between two viewport heights - the 480
literal regressing). `analyze lib` 59, `flutter test` from 364/1, no commits.
