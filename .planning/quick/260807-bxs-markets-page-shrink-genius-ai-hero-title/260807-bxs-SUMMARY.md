---
phase: quick-260807-bxs
plan: 01
subsystem: ui
tags: [flutter, fl_chart, coingecko, markets, timeframe, cards]

requires: []
provides:
  - "Markets hero price/title shrink to type tokens at phone width, wide card unchanged (367.0/301.0 pinned)"
  - "Narrow Markets hero chart earns the trading frame (axis labels) by growing its box to kChartFrameMinHeight"
  - "Markets hero timeframe tabs (24H/7D/30D/1Y) actually re-fetch and re-plot; 7D stays free"
  - "fetchHistoricalPrices takes an optional days parameter with a per-range Hive cache key"
  - "GWTimeframeSegment gained optional labels/onChanged, unifying the dashboard and Markets timeframe controls into one component"
  - "All Markets renders as MarketsCards (icon/name/symbol/price/24h%/market cap/volume, no chart), 1 col phone / 2 col desktop, rank ascending"
affects: [markets-page, dashboard-timeframe-segment, coin-gecko-api]

tech-stack:
  added: []
  patterns:
    - "Layout branch and type step read one shared bool (box width AND useDesktopLayout) so they cannot disagree"
    - "A future assigned inside setState() gets a synchronous ..ignore() at creation so a fast-rejecting Future does not zone-report as unhandled before FutureBuilder attaches on the next frame"

key-files:
  created:
    - test/dashboard/markets_fixtures.dart
    - test/dashboard/markets_hero_timeframe_test.dart
    - test/dashboard/markets_cards_test.dart
    - lib/dashboard/chart/markets_cards.dart
  modified:
    - lib/dashboard/chart/markets_hero_card.dart
    - lib/components/gw_timeframe_segment.dart
    - lib/services/coin_gecko/coin_gecko_api.dart
    - lib/dashboard/chart/markets_screen.dart
    - lib/chart/crypto_simple_chart.dart
    - test/dashboard/markets_hero_height_test.dart
    - .planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md
  deleted:
    - lib/dashboard/chart/markets_table.dart

key-decisions:
  - "Cards replace the table at ALL widths, not just narrow (decision 1, per-plan)"
  - "Interactive column sorting is gone with the table headers; rank order is preserved via the existing compareMarketRows, kept live for a future sort control (decision 2, per-plan; user confirmed post-planning: ship rank order now, no sort control this task)"
  - "The hero shrinks at phone width only; wide keeps its 48px price verbatim (decision 3, per-plan)"
  - "The narrow chart earns the frame by growing kMarketsHeroChartHeightStacked to kChartFrameMinHeight, not by lowering the global frame threshold (decision 4, per-plan)"
  - "7D spends no network call -- the free path plots the already-fetched sparkline windowed as the last 7 days (decision 5, per-plan)"
  - "GWTimeframeSegment gained onChanged/labels rather than keeping two private copies (decision 6, per-plan)"

requirements-completed: [BXS-01, BXS-02, BXS-03, BXS-04]

duration: ~2h30m
completed: 2026-08-07
status: complete
---

# Quick Task 260807-bxs: Markets page -- hero shrink, real timeframe tabs, cards Summary

**Markets hero price/title shrink to type tokens at phone width with a framed narrow chart; timeframe tabs (24H/7D/30D/1Y) now genuinely re-fetch via a day-scoped `fetchHistoricalPrices`; the All Markets table is replaced by a two-column-at-desktop card list with no charts.**

## Performance

- **Duration:** ~2h30m
- **Completed:** 2026-08-07T12:37:54Z
- **Tasks:** 3/3
- **Files modified:** 13 (4 created, 8 modified, 1 deleted/renamed)

## Accomplishments

- BXS-01/BXS-02: at 402x900 the hero price resolves to `GeniusWalletTypography.numericDisplay` (32px) and the coin name to `titleMd`, both nothing-overflows; the wide card (1400x1000) still resolves to the fixed 48px price and `titleLg`, and the pinned `367.0`/`301.0` measurements are unedited and still pass. The narrow (600x1200) hero chart is now framed -- money labels down the right edge, a date/time row along the bottom -- by growing `kMarketsHeroChartHeightStacked` to `kChartFrameMinHeight` (220) rather than lowering the global frame threshold.
- BXS-03: tapping 24H/30D/1Y calls `fetchHistoricalPrices(coinId, days: N)` and re-plots the returned series; tapping 7D calls nothing and re-plots the bundled sparkline. A fetch that resolves to an empty map (the only failure signal `fetchHistoricalPrices` ever surfaces) shows a `FutureStateWidget` retry affordance, never a blank chart. The bottom axis picks clock time / day-month / month-year from the real plotted window via a new pure `chooseAxisDateFormat`.
- BXS-04: `MarketsTable` is replaced by `MarketsCards` -- a `GWCard`-based card per coin with icon, name, symbol, price, 24h change pill, market cap and 24h volume, and zero charts. One card per row at phone width, two per row on desktop (`GeniusBreakpoints.useDesktopLayout`), ordered rank ascending via the existing `compareMarketRows`.
- `GWTimeframeSegment` unified: gained optional `labels`/`onChanged` (both default to today's behaviour), and the Markets hero's own private `_TimeframeSegment`/`_TimeframeTab` is deleted in favour of it -- one shared component, not two, closing `.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md`.

## Task Commits

1. **Task 1: The narrow hero stops shouting, and earns its axes (BXS-01, BXS-02)** - `5179b52` (feat)
2. **Task 2: The timeframe tabs actually change the series (BXS-03)** - `5119d84` (feat)
3. **Task 3: Cards replace the markets table (BXS-04)** - `280f9b4` (feat)

No separate plan-metadata commit -- the orchestrator handles the docs commit.

## Files Created/Modified

- `lib/dashboard/chart/markets_hero_card.dart` - narrow price/title type step, AND'd wide bool, timeframe tabs wired to a real fetch, `_HeroChart` takes `values`/`start`/`end` instead of a bare sparkline, private timeframe segment deleted
- `test/dashboard/markets_fixtures.dart` - extracted, public fixture builders (3 consumers by end of plan)
- `test/dashboard/markets_hero_height_test.dart` - repointed at the fixtures file; stacked test rewritten for the framed relationship; two new tests pin the type-token switch at 402x900 and the unchanged 48px at 1400x1000
- `lib/components/gw_timeframe_segment.dart` - optional `labels`/`onChanged`, both default-safe for the two existing call sites
- `lib/services/coin_gecko/coin_gecko_api.dart` - `fetchHistoricalPrices` gained optional `days` (default 1) with a per-range Hive cache key
- `test/dashboard/markets_hero_timeframe_test.dart` - fake-fetch tests for 30D/7D/empty-response, plus unit tests on `chooseAxisDateFormat`
- `lib/dashboard/chart/markets_cards.dart` - renamed from `markets_table.dart`; `MarketsTable` replaced by stateless `MarketsCards` + private `_MarketCard`
- `lib/dashboard/chart/markets_screen.dart` - import + one construction site changed to `MarketsCards`; one stale comment referencing the deleted `MarketsTable` corrected
- `lib/chart/crypto_simple_chart.dart` - one stale comment corrected (cited `markets_table.dart:310-318`, which no longer exists)
- `test/dashboard/markets_cards_test.dart` - geometry (1 col / 2 col), content, no-chart and ordering claims
- `.planning/todos/completed/2026-07-24-unify-timeframe-segment-component.md` - moved from pending, closure note appended
- `.planning/todos/completed/2026-07-24-markets-1h-7d-change-columns.md` - moved from pending, closed by removal
- `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md` - dated note appended (still pending)

## Decisions Made

See `key-decisions` in frontmatter for decisions 1-6, all inherited from the plan's `<decisions_settled>` and executed as written. One additional note: decision 2 asked the summary to pose a direct question to the user about re-adding a sort control. **That question has already been asked and answered** (recorded in the executor's briefing): ship the cards in rank order now, do not build a sort control this task. `markets_sort.dart` and `compareMarketRows` are unchanged and kept live specifically so a sort control can be added above the card list later without rework.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] A future created inside `setState()` could zone-report as an unhandled exception before `FutureStateWidget` ever attached its error listener**
- **Found during:** Task 2, writing `markets_hero_timeframe_test.dart`'s empty-response test
- **Issue:** `_onTimeframeTap` assigns `_seriesFuture = _fetchSeries(days)` inside `setState()`, which does not rebuild synchronously. When the injected fetch rejects fast (an immediate empty map), `_fetchSeries`'s Future could complete with an error before `FutureBuilder` (inside `FutureStateWidget`, built on the *next* frame) had a chance to attach its `.then(onError:)` listener. Dart reports a Future error as an unhandled zone exception if it has zero listeners at the moment it settles, even if a listener attaches moments later -- which is exactly what happened, and the test crashed with an uncaught `StateError` instead of exercising the retry UI.
- **Fix:** Added a `_startFetch` wrapper that appends a synchronous `..ignore()` at creation time (registering a silent listener immediately, in the same call as `_fetchSeries(days)`), while `FutureStateWidget` still receives and handles the *same* Future object normally (Futures support multiple independent listeners). Used at both the tap handler and the retry callback.
- **Files modified:** `lib/dashboard/chart/markets_hero_card.dart`
- **Verification:** `test/dashboard/markets_hero_timeframe_test.dart`'s "a fetch that comes back empty shows a retry affordance and no chart" test passes; full suite green.
- **Committed in:** `5119d84` (Task 2 commit)

**2. [Rule 1 - Bug] Two stale comments referencing the now-deleted `markets_table.dart`**
- **Found during:** Task 3
- **Issue:** `markets_screen.dart` had a comment citing "the horizontal scroll inside MarketsTable" (that scroll wrapper is deleted); `crypto_simple_chart.dart` had a comment citing `markets_table.dart:310-318` for sparkline geometry parity (that file/line no longer exists).
- **Fix:** Rewrote both comments to describe current state without pointing at a deleted location. `crypto_simple_chart.dart`'s own sparkline is unaffected -- only the comment was stale.
- **Files modified:** `lib/dashboard/chart/markets_screen.dart`, `lib/chart/crypto_simple_chart.dart`
- **Verification:** `flutter analyze` clean; both files untouched otherwise.
- **Committed in:** `280f9b4` (Task 3 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1 bugs directly caused by this plan's own changes)
**Impact on plan:** Both fixes were necessary for correctness (deviation 1) or documentation accuracy (deviation 2). No scope creep -- neither touched behaviour outside what the plan already specified.

## Narrow hero card height: before/after (decision 4)

Measured at 402x900 with a throwaway A/B harness (pre-change source read via `git show HEAD`, aliased to avoid symbol collision, deleted before committing -- never landed in the tree):

- **Before (pre-Task-1):** 619.0
- **After (post-Task-1):** 651.0
- **Delta:** +32px

Decision 4 predicted the card would "land within a few pixels of where it is today" (i.e. a near-zero delta), reasoning that the chart's +40px cost is "roughly" repaid by the type step. The plan's own itemized arithmetic in the same paragraph (chart +40, title 24->22 = -2, price 48->40 = -8) actually nets to **+30**, not ~0 -- and the measured +32 matches that itemized arithmetic closely (within 2px, likely rounding/line-height residue), **not** the "few pixels of today" framing. Per the plan's own instruction ("Task 1 measures it and the summary reports the real before/after numbers even if they contradict this paragraph"): the narrow card is honestly ~32px taller than before, not roughly unchanged.

## Wide card 367.0/301.0: re-confirmed after every task

- **After Task 1** (direct measurement): `markets_hero_height_test.dart`'s "the card holds its height at the shipped chart size" (367.0) and "the IntrinsicHeight row is driven by the LEFT column" (301.0) both pass with the literals unedited.
- **After Task 2** (timeframe track swap -- `_TimeframeSegment`/`_TimeframeTab` deleted in favour of `GWTimeframeSegment`, which per `<measured_facts>` is geometrically identical): full suite green (1027/1027), including both pinned tests, unedited.
- **After Task 3** (markets_screen.dart / crypto_simple_chart.dart neighbouring edits, no hero-card changes): full suite green (1031/1031), including both pinned tests, unedited.

## `days` parameter blast radius (Task 2)

```
lib/chart/crypto_live_chart.dart:174:      final historicalPrices = await fetchHistoricalPrices(
lib/dashboard/chart/markets_hero_card.dart:167:    final raw = await widget.fetchHistoricalPrices(widget.coin.id, days: days);
lib/screens/splash.dart:125:      fetchHistoricalPrices('bitcoin'),
```

Both pre-existing callers (`crypto_live_chart.dart:174`, `splash.dart:125`) are unedited and still call positionally with no `days` argument, so both keep the default (`days: 1`) and the bare-`coinId` cache key -- no migration, no orphaned cache entry. Only the Markets hero (`markets_hero_card.dart:167`) passes a non-default `days`, and only its 30D/1Y/24H fetches get the scoped `coinId:days` cache key (7D is free and never calls the fetch at all).

## `GWTimeframeSegment` grep hit list (Task 2)

```
lib/chart/crypto_live_chart.dart:638:            const GWTimeframeSegment(),
lib/dashboard/chart/markets_hero_card.dart:387:            child: GWTimeframeSegment(
lib/dashboard/home/view/dashboard_screen.dart:630:          children: [_CoinIdentity(), GWTimeframeSegment()],
```

The dashboard (`dashboard_screen.dart:630`) and coin-page (`crypto_live_chart.dart:638`) call sites are byte-identical to before this plan -- zero-argument construction, so both stay purely visual. Only the Markets hero passes `labels`/`initialIndex`/`onChanged`.

## Timeframe todos

- `.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md` -> **moved to `completed/`**, with a closure note recording that `GWTimeframeSegment` gained `labels`/`onChanged` and the Markets hero's private copy is deleted.
- `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md` -> **stayed pending**, with a dated (2026-08-07) note appended: step 1 (ranged fetch) and half of step 2 (`onChanged` on the shared segment) are built and shipped, but on the Markets hero, not `CryptoLiveChart` -- `CryptoLiveChart`'s own call site still passes no `onChanged` and remains visual-only. What remains: wiring `CryptoLiveChart._fetchHistoricalData` through the new `days` parameter, and the step-3 zoom/pan product call, neither of which this task touches.

## 1h/7d change columns todo

`.planning/todos/pending/2026-07-24-markets-1h-7d-change-columns.md` existed and **was moved to `completed/`**, closed by removal rather than implementation: the card design drops both placeholder columns entirely (per decision 1, cards replace the table at all widths and the `-` placeholders are not carried forward), so there is no longer a column for the todo's upgrade path to fill.

## Known Stubs

None. All four requirements (BXS-01 through BXS-04) are fully wired end to end -- no hardcoded empty data, no "coming soon" placeholders introduced by this task. (The 1h/7d change data absence, which produced the old table's `-` placeholders, is resolved by removing the columns, not by a new stub.)

## Threat Flags

None. This plan's `<threat_model>` (T-bxs-01 through T-bxs-04, T-bxs-SC) covers every trust boundary this diff touches -- the `days` parameter into `fetchHistoricalPrices`'s cache key and URL, and the remote price series plotted without validation. No new endpoint, auth path, file access pattern or schema change was introduced beyond what the threat model already names.

## Issues Encountered

None beyond the auto-fixed deviations above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Markets page defects (BXS-01 through BXS-04) are all resolved and verified.
- A future task could add a sort control above the card list (decision 2 / the recorded user answer) without rework, since `markets_sort.dart` stayed live.
- `CryptoLiveChart`'s own timeframe wiring (dashboard chart) remains open, tracked by the still-pending 2026-07-21 todo.

---
*Quick task: 260807-bxs*
*Completed: 2026-08-07*

## Self-Check: PASSED

All 13 files listed under `key-files` verified present on disk (and `markets_table.dart` verified deleted). All 3 task commit hashes (`5179b52`, `5119d84`, `280f9b4`) verified present in `git log`.

## Follow-up: table restored on wide

**This section documents a correction made after the three commits above, not something done correctly the first time.** Decision 1 in the plan ("cards replace the table at ALL widths") went in front of Braian without him seeing it first — that was a planning error, not something he asked for. After walking the result he corrected it directly, in two messages:

1. All Markets should be **unchanged on desktop/bigger screens**, cards **only when the data does not fit a table**.
2. Immediately after (Braian, direct): "in the table, remove the 1h / 7d we dont need that filter in the table just in the graph" — reversing his own first instruction (which had asked for the columns to come back with the table) once he'd actually said the words out loud.

### What changed

- **`lib/dashboard/chart/markets_table.dart` is back**, restored from `git show 280f9b4^:lib/dashboard/chart/markets_table.dart` — not rewritten from memory, so the surface is provably unchanged rather than approximately unchanged. `MarketsTable`, its header/data-row rendering, `_MiniSpark`, sort-on-header-tap (`_onHeaderTap`/`MarketSort`), and the horizontal-scroll fallback are byte-identical to that commit, **except**: the `1h %` and `7d %` columns and their `_changePlaceholder` helper are deleted per Braian's second message, and the module-private `_minTableWidth` is renamed to the public `kMarketsTableMinWidth` (a compile-time-constant rename only — it changes no rendering, only what the picker widget below can read).
- **The minimum-width sum was recomputed, not carried forward.** Original (9 columns, `_wChange * 3`, 8 gaps): **1054**. New (7 columns, `_wChange * 1`, 6 gaps): **846**. Carrying the old 1054 forward would have made the table fall back to cards up to 208px earlier than it now needs to, at widths where it genuinely fits.
- **A new fit-gate widget, `MarketsAllSection`** (in `markets_cards.dart`, replacing the old always-cards `MarketsCards`), is the one thing standing between the table and the cards: a `LayoutBuilder` comparing its own measured box against `kMarketsTableMinWidth`, rendering `MarketsTable` when it fits and a private `_MarketsCardGrid` (today's unchanged card design) when it doesn't. The gate is that comparison — not `GeniusBreakpoints.useDesktopLayout` or any other device-class check, per Braian's explicit instruction not to reach for one. `MarketsAllSection` has exactly one call site (`markets_screen.dart`) and is the page-width surface for "All Markets," so measuring its own box is correct here — the doc comment on the class says so explicitly, distinguishing it from the shared-row-widget trap in 260806-hfe (a widget reused across many differently-sized containers, where measuring its own box was the wrong signal).
- **`MarketRow` has one definition again**, in `markets_table.dart` (its original home before this task ever touched the file). `markets_cards.dart` imports it rather than redefining it.
- **File naming:** `markets_table.dart` and `markets_cards.dart` now coexist rather than being merged into one file, because the table (restored, byte-identical rendering minus two deleted columns) and the card grid (this task's own new design) are genuinely two different, independently-evolving pieces of code — one file would obscure which parts are "restored, don't touch" and which are "new, this task's."
- **The `1h`/`7d` columns todo's closure note was rewritten**, not just left standing: it originally closed on "the card design dropped both placeholders"; it now records that the columns are deleted from the table too (a stronger close — see `.planning/todos/completed/2026-07-24-markets-1h-7d-change-columns.md`).

### The horizontal-scroll fallback: dead code today, kept anyway

`MarketsTable`'s own internal `LayoutBuilder` still branches on `c.maxWidth >= kMarketsTableMinWidth`, wrapping in a horizontal-scrolling `SizedBox` when it doesn't. Because `MarketsAllSection` measures the *same* box (no intervening padding/sizing widget sits between the two `LayoutBuilder`s in the actual `markets_screen.dart` tree) against the *same* constant, this inner branch cannot fire in practice through today's one call site — `MarketsAllSection` already routes anything below the threshold to cards before `MarketsTable` is ever mounted. It is **not deleted**, per instruction: `MarketsTable` is a general-purpose widget, not solely `MarketsAllSection`'s callee, and remains genuinely load-bearing for any future direct call site that skips the fit-gate.

### Tests

`markets_cards_test.dart` is rewritten (not merely tweaked) to pin the real rule instead of the retired "1 col phone / 2 col desktop" claim:
- **Exactly at `kMarketsTableMinWidth`** → `MarketsTable` renders, no `GWCard`.
- **One pixel below `kMarketsTableMinWidth`** → cards render (`GWCard` present), no `MarketsTable`.
- The no-chart-on-a-card claim and the rank-1-is-first-in-document-order claim are kept, both now run at a width comfortably below the threshold (`kMarketsTableMinWidth - 400`) so they unambiguously exercise the card grid — the table legitimately has its own `LineChart` (the `_MiniSpark` "Last 7d" column), so "no chart" is a card-only claim now, not a whole-section one.

No new test was added for the restored table's own rendering/sort behaviour — it has none from before (confirmed by grep prior to this task), and `markets_sort_test.dart` (untouched) already covers `compareMarketRows` at the pure-function level.

### Verification (same eight gates, re-run after this correction)

- `flutter analyze`: **0 issues**, exit 0.
- `flutter test`: **1031/1031** passed (same count as after Task 3 — four tests replaced, none added or removed).
- `tool/check_brace_style.sh`, `tool/check_raw_colors.sh`, `tool/check_onboarding_seed_safety.sh`, `tool/check_no_new_key_logging.sh --scan-tree`: all exit 0.
- `tool/check_agent_rules_sync.sh`: exit 1, **identical to the pre-existing baseline failure** measured before any work in this task began (`AGENTS.md`/`.github/copilot-instructions.md` drift, unrelated to any file this task touches) — not fixed, per the scope-boundary rule.
- `markets_hero_height_test.dart`'s pinned 367.0/301.0: unaffected (this correction never touches `markets_hero_card.dart`) and still pass as part of the full suite.
- One atomic commit: `dad514a` — `fix(260807-bxs): restore the All Markets table for wide screens, cards only when it doesn't fit`. No attribution trailer. Not pushed. No PR (`gh pr list --head feat/markets-page-cards` returns empty).

### A place I did not decide for you

Braian's second message said the `1h %`/`7d %` columns don't belong "in the table, just in the graph" — read narrowly, that is about the timeframe/range filter, and the hero graph's tabs already fetch real ranged data (24H/7D/30D/1Y) as of this same task. Nothing in either message asked for a NEW 1h/7d change-percent surface on the graph itself — CoinGecko's `/coins/markets` fetch still does not request `price_change_percentage_1h,7d`, so that data does not exist anywhere in the app today, table or graph. I did not add one. If "just in the graph" meant "put 1h/7d change somewhere on the hero card," that is a new, unscoped surface this task did not build — flagging it rather than guessing.

## Follow-up: stat block becomes a flex (Wrap), not a fixed 2×2 grid

A third, separate correction from Braian: the hero card's stat block (Rank, Market Cap, Volume 24h, All-Time High — `markets_hero_card.dart`, previously two hardcoded `Row`s of `Expanded(GWStatTile)`) should flow as many tiles per row as actually fit, instead of always being two columns.

### What changed

- The two fixed `Row`s are replaced by one `Wrap`, `spacing`/`runSpacing` both `GeniusWalletConsts.space10` (reusing the existing token the file already used for this exact vertical gap, per the "keep spacing on existing tokens" instruction — no new spacing value introduced).
- Each tile is wrapped in a `SizedBox(width: kMarketsHeroStatTileWidth)`. A new top-level constant, not a bare content-sized tile: an un-widthed `GWStatTile` sizes to its own shortest content and the four tiles would never line up as columns, and a `SizedBox` (not a flexible `Expanded`) is also the CEILING Braian asked for — a tile can never grow to fill leftover space on an extra-wide card.
- **Why `Wrap` and not `LayoutBuilder`:** exactly per the instruction — `left` is a child of an `IntrinsicHeight` `Row` on the wide branch, and `LayoutBuilder` throws ("does not support returning intrinsic dimensions") when asked for one. `Wrap` implements intrinsics natively and was the only flow primitive considered; no `LayoutBuilder`-based column-count approach was attempted, per the instruction to stop and say so rather than reach for it — it would have crashed the wide layout, not merely produced a wrong number.
- **`kMarketsHeroStatTileWidth = 152`, measured, not picked by eye.** `GWStatTile`'s label is a bare `GWKicker` with no `maxLines`/`overflow` of its own (unlike the Markets table's header cells, which wrap the same dense-kicker text style in an explicit ellipsis), so a tile narrower than its label wraps the label to two lines instead of truncating it. I measured the exact wrap threshold directly (a throwaway widget test bisecting candidate widths, deleted before committing): 'All-Time High', the widest of the four fixed labels, wraps its `GWKicker` at 150px width and clears at 151px. 152 is that threshold plus 1px of margin.
- **The direct consequence, stated rather than hidden:** at the file's usual 1400×1000 wide surface, the left column (~543px) fits **three** unwrapped tiles per row, not four (`3 × 152 + 2 × space10 = 496` fits; `4 × 152 + 3 × space10 = 656` does not) — the fourth wraps to its own second row. All four only share one row above roughly **1700px** of total card width. At 402px, exactly two fit per row, unchanged from before. This still satisfies "more data in a row instead of always a 2 column structure" at every width it was asked for — it was never a promise that every desktop width shows all four abreast, and a narrower tile that wraps 'All-Time High' onto two lines would have been worse. The alternative of also widening the left column's flex share to force 4-across at 1400px was considered and rejected: that would resize the chart too, which nobody asked for.
- **Jakub's chart-alignment comment** (previously: the wide chart's lower edge lines up with "the Volume 24h / All-Time High stat row") is rewritten, not silently left stale: the `Spacer`-absorption mechanism it documents never actually depended on what specifically sat at the bottom of the left column, only that SOMETHING did — the comment now says that plainly, and no longer points at a second stat row that no longer structurally exists.

### The pinned 367.0/301.0: re-measured, numerically unchanged, structurally flipped

Both were re-measured directly (not assumed) at the file's standard 1400×1000 surface, and at five widths spanning 1400 to 1900 to map exactly where the stat block's row count changes. **The numbers came back identical to before this correction: 367.0 and 301.0.** But which column produces them flipped, and that is the real, load-bearing change this correction records, per the instruction not to just carry a new number without explaining the derivation:

- **Before:** the LEFT column's fixed 2×2 stat grid measured exactly 301.0, and the RIGHT column (timeframe segment + chart) measured "roughly 299" per the original plan's estimate — left drove the row, with about 2px of headroom.
- **Now:** the RIGHT column measures a hard, re-confirmed **301.0** of its own (not an estimate — directly measured), completely independent of the stat block. The LEFT column's height is no longer one fixed number; it is **242.0** when all four tiles share one row (single `Wrap` run) or **301.0** when three do and the fourth wraps (two runs) — the practical range at any width the wide branch renders. Because the right column's fixed 301.0 is always `>=` the left's 242–301 range, **the right column now drives `IntrinsicHeight` unconditionally**, at every width tested (1400 through 1900), not as a close call that could tip either way.
- The test's `reason:` strings and the widget file's doc comments (on `kMarketsHeroChartHeight` and the wide-price `Text`) are rewritten to state this derivation, not just re-assert the same two literals — a future stat-block or chart change could move one side without moving the other, and the test now says which side it is watching.

### Tests

`markets_hero_height_test.dart` (chosen over a new sibling file — this is squarely about the hero card's own pinned geometry, the file's existing subject):
- The existing wide-card group is renamed and its comments/reason strings rewritten to describe the right-column derivation above; the two pinned literals (367.0, 301.0) are unchanged.
- The 1400px "price is still 48" test's failure-reason string is corrected — a failure there no longer implies the pinned heights are about to move (they are not the left column's anymore).
- Two new tests, geometric (off the tiles' rects, not by counting `Row`s), `pump()` only, never `pumpAndSettle()`: at 1800×1000 (a "genuinely wide" surface, not the usual 1400 pin, since 152px tiles need roughly 1700px+ of card width to fit all four) all four `GWStatTile`s share one `Wrap` run's top edge; at 402×900 they do not (the phone-width card still wraps across more than one row, unchanged from before this task).

### Verification (same eight gates, re-run after this correction)

- `flutter analyze`: **0 issues**, exit 0.
- `flutter test`: **1033/1033** passed (up from 1031 — two new geometric tests added, none removed).
- `tool/check_brace_style.sh`, `tool/check_raw_colors.sh`, `tool/check_onboarding_seed_safety.sh`, `tool/check_no_new_key_logging.sh --scan-tree`: all exit 0.
- `tool/check_agent_rules_sync.sh`: exit 1, identical to the pre-existing baseline failure measured before any work in this task began — unrelated to any file this task touches, not fixed, per the scope-boundary rule.
- One atomic commit: `6e8508f` — `fix(260807-bxs): hero stat block flows instead of a fixed 2x2 grid`. No attribution trailer. Not pushed. No PR (`gh pr list --head feat/markets-page-cards` returns empty).

## Follow-up: stat tiles size to content, tighter gap, halved card padding

A fourth correction, in two parts Braian raised together: the stat tiles still "seemed too big" after becoming a `Wrap`, and separately, the card's own padding should also shrink.

### Part 1 — content-sized tiles, not a fixed-width floor

Braian's diagnosis (correct, and it drove the fix): the visible slack was mostly INSIDE each tile, not between them. `kMarketsHeroStatTileWidth` was a uniform 152px box sized to the widest LABEL ("All-Time High"), while the VALUES it held (`#1227`, `$10.6M`, `$45.26`, ...) were far narrower — every tile carried its label's leftover width as dead space next to a short value, and four of those read as one loose block.

- **Dropped the `SizedBox(width: kMarketsHeroStatTileWidth)` wrappers entirely** — each `GWStatTile` now sits directly in the `Wrap` and sizes to its own content (`Wrap` hands children unbounded width, so a tile sizes to its widest line naturally; "All-Time High" cannot wrap under an unbounded constraint, which is why the whole 151px-wrap-threshold derivation from the previous follow-up simply stops applying rather than needing to be re-tuned).
- **`kMarketsHeroStatTileWidth` is deleted**, not left unused — nothing else read it.
- **`spacing` tightens from `space10` (20px) to `space6` (12px)** — reusing the SAME tight horizontal gap this card already uses twice (icon-to-name in the identity row, pill-to-text in the change row), rather than inventing a third spacing value. `runSpacing` stays at `space10`: Braian's own instruction was that rows still need to read as separate rows, and a gap this tight would blur that when the block wraps.
- **The trade, stated plainly per instruction:** content-sized tiles no longer align into a column grid — each value's x-position now depends on its own tile's content width, not a shared grid, so the stat row reads as a chip line rather than a table. This is the direct, real cost of removing the slack. **I did not find the ragged edge looking worse than the old slack did** — the four values (rank, market cap, volume, ATH) are visually distinct enough by their `$`/`#` prefixes and position order that the loss of column alignment reads as compactness, not disorder, but this is a genuine judgment call and Braian should look at the running app himself rather than take that on my word.
- **Knock-on, confirmed by direct measurement, not assumed:** without the fixed-width floor, four tiles now share one row starting around **1217px** of card width (down from ~1700px with the 152px floor) — comfortably below the file's usual 1400px surface. Braian was asked earlier whether to always show 4 tiles per row (at the cost of shortening labels or narrowing the chart) and chose to leave it at 2/3/4-by-width; this change gets him 4-at-1400 anyway, at neither cost, exactly as flagged before building it.

### Part 2 — card padding halved

- `markets_hero_card.dart`'s own outer `Container.padding` changes from `EdgeInsets.all(GeniusWalletConsts.space16)` to `EdgeInsets.all(GeniusWalletConsts.space8)` — an existing 4-pt-scale token (16px), not a new number.
- **Swept the rest of the file for other card-frame insets, per instruction, rather than assuming this was the only one.** Two candidates were found and deliberately left alone:
  - `_ChangePill`'s own `EdgeInsets.symmetric(horizontal: 8, vertical: 3)` — a component's own shape, not the card's frame; halving it would visibly deform the pill.
  - The chart's `EdgeInsets.only(right: kChartAxisGutter)` — load-bearing for the narrow-width axis labels this same task added (BXS-02); halving it would clip the money labels, undoing that fix.
  
  No other padding/`EdgeInsets` occurrence exists in the file — confirmed by grep, not assumed.

### The real numbers, re-measured after BOTH changes together

Braian's own estimate ("`EdgeInsets.all(16)` → `all(8)` removes 16px... 367.0 should land near 351.0") assumed `space16` is 16px. **It is not — `GeniusWalletConsts.space16` is 32px** (this codebase's spacing tokens are `spaceN = 2 × N` above the 4-pt floor), so halving it to `space8` (16px) removes 32px total (16 top + 16 bottom), not 16px. Measured directly rather than trusting either estimate:

| Surface | Before this follow-up | After (content-sizing + padding) |
|---|---|---|
| 1400×1000 card height | 367.0 | **335.0** |
| 1400×1000 `IntrinsicHeight` row | 301.0 | **301.0 — confirmed unaffected**, exactly as predicted: the padding sits outside that row (`Container.padding`, not `content`'s own constraints), so it cannot touch the row's height, only the finished card's. |
| 402×900 card height (stacked branch) | 651.0 | **619.0** (same −32px padding delta; the stat block is still 2 rows tall either way — 3-then-1 now vs. 2-then-2 before — so only the padding change shows up here, not a tile-count change) |

### Tile counts at 402 / 1400 / 1800, confirmed after both changes (not assumed)

- **402px:** 3 tiles share the top row (Rank, Market Cap, Volume 24h), All-Time High wraps alone to a second row. Still 2 rows total, unchanged in row-count from the previous follow-up (only the split changed, from 2-then-2 to 3-then-1, once the fixed-width floor was dropped).
- **1400px:** **all 4 tiles share one row** — this is new since the previous follow-up (which showed 3-then-1 at 1400px under the 152px floor).
- **1800px:** all 4 tiles share one row (unchanged from before — was already true at this width).

### Tests

`markets_hero_height_test.dart`, same file, extended not replaced:
- The pinned wide-card literal is now **335.0** (was 367.0); `IntrinsicHeight` stays **301.0**. Both re-measured directly. The card-height test's `reason:` string states the padding change and the exact 32px delta so a future failure for an unrelated cause is not misattributed to padding.
- The "all four stat tiles share one row" geometric test now pins **1400×1000 directly** (was 1800×1000 in the previous follow-up) — content-sizing makes the claim true at the width Braian actually asked about, so the test targets that width rather than a comfortably-wider one.
- The 402px "tiles do NOT all share one row" test is unchanged in structure (still true, now via a 3-then-1 split instead of 2-then-2).
- `kMarketsHeroStatTileWidth` references removed from test comments along with the deleted constant.

### Verification (same eight gates, re-run after this correction)

- `flutter analyze`: **0 issues**, exit 0.
- `flutter test`: **1033/1033** passed (same count — two tests rewritten in place, none added or removed).
- `tool/check_brace_style.sh`, `tool/check_raw_colors.sh`, `tool/check_onboarding_seed_safety.sh`, `tool/check_no_new_key_logging.sh --scan-tree`: all exit 0.
- `tool/check_agent_rules_sync.sh`: exit 1, identical to the pre-existing baseline failure — unrelated, not fixed, per the scope-boundary rule.
- One atomic commit (both the content-sizing change and the padding halving, per the coordinator's instruction to fold them together): `88808a5` — `fix(260807-bxs): stat tiles size to content, tighter gap, halved card padding`. No attribution trailer. Not pushed. No PR (`gh pr list --head feat/markets-page-cards` returns empty).
