---
phase: quick-260807-bxs
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dashboard/chart/markets_hero_card.dart
  - lib/dashboard/chart/markets_table.dart
  - lib/dashboard/chart/markets_cards.dart
  - lib/dashboard/chart/markets_screen.dart
  - lib/components/gw_timeframe_segment.dart
  - lib/services/coin_gecko/coin_gecko_api.dart
  - test/dashboard/markets_fixtures.dart
  - test/dashboard/markets_hero_height_test.dart
  - test/dashboard/markets_hero_timeframe_test.dart
  - test/dashboard/markets_cards_test.dart
autonomous: true
requirements: [BXS-01, BXS-02, BXS-03, BXS-04]
must_haves:
  truths:
    - "At phone width the GENIUS AI price no longer runs the full width of the hero card: it renders at a typography token, not a hardcoded 48 (BXS-01)."
    - "At phone width the hero chart carries the same price labels down its right edge and date/time labels along its bottom that the desktop chart already carries (BXS-02)."
    - "Tapping 24H, 30D or 1Y re-plots the hero chart against a series actually fetched for that range; tapping 7D re-plots the already-bundled sparkline and spends no network call (BXS-03)."
    - "A fetch that fails or is rate-limited shows a retry affordance in the chart box, never a blank chart (BXS-03)."
    - "The All Markets body is a list of cards carrying icon, name, symbol, price, 24h change, market cap and volume, with no chart on any card, at every width (BXS-04)."
    - "The desktop hero card's measured height and its IntrinsicHeight row are unchanged: 367.0 and 301.0 at a 1400x1000 surface."
  artifacts:
    - lib/dashboard/chart/markets_cards.dart
    - test/dashboard/markets_fixtures.dart
    - test/dashboard/markets_hero_timeframe_test.dart
    - test/dashboard/markets_cards_test.dart
  key_links:
    - "kMarketsHeroChartHeightStacked is DERIVED from kChartFrameMinHeight, so the narrow chart earns the frame by the same runtime rule the desktop one does — no per-surface flag."
    - "GWTimeframeSegment.onChanged is what carries the tapped index out of the shared component into _MarketsHeroCardState; without it the tabs stay cosmetic."
    - "fetchHistoricalPrices' Hive cache key gains the day count for any range other than the default, so a 30D fetch cannot overwrite the dashboard chart's 1D series."
    - "MarketsCards is reached from markets_screen.dart's _buildContent; the page frame, the hero and the 'All Markets' section title are untouched."
---

<objective>
Four fixes to the Markets page, all measured against the running app at 402px and 1400px on 2026-08-07:

1. The hero price is a hardcoded `fontSize: 48` and at 402px it consumes the full card width.
2. The narrow hero chart has no axis labels, because its box is 180px and the frame needs 220.
3. The timeframe tabs are cosmetic — the plotted series is always CoinGecko's bundled 7-day sparkline.
4. The All Markets table's 1h % and 7d % columns render `-` on every row, and the surface should be cards.

Purpose: the Markets page is the one screen where the numbers are the product, and three of the four defects above make it either unreadable at phone width or quietly dishonest about what it is showing.
Output: a hero that fits a phone and labels its axes, timeframe tabs that fetch, and a card list that replaces the table.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@.claude/skills/open-pr/SKILL.md
@lib/dashboard/chart/markets_hero_card.dart
@lib/dashboard/chart/markets_table.dart
@lib/chart/chart_axis.dart
@lib/components/gw_timeframe_segment.dart
@test/dashboard/markets_hero_height_test.dart
</context>

<measured_facts>
Read out of the tree while planning. Stated with file and line so the executor can re-check rather than trust, but they do not need re-deriving.

**`markets_hero_card.dart:121` — the price is a fixed `fontSize: 48`, and it is fixed on purpose.** The comment above it rules out `AutoSizeText` because a width-driven font search re-keys skia's ParagraphCache every resize frame and froze the macOS embedder. That reasoning survives this change: the fix is a second FIXED style chosen by breakpoint, never a measured one.

**`chart_axis.dart:20` and `:119` — `chartUsesFrame(plotHeight) => plotHeight >= 220.0`.** The hero passes the `SizedBox` height into this at `markets_hero_card.dart:408`. Wide is 253 (framed, verified on screen), stacked is 180 (below the threshold, so axis-free). This is the whole of the missing-axes defect. `kChartAxisGutter` is 62.0 and `kChartTimeRowHeight` is 22.0.

**`coin_gecko_api.dart:45` — `days` is hardcoded to 1 in the `market_chart` URL, and the Hive cache is keyed on `coinId` alone (`:33`, `:65`).** Two callers exist and both want the default: `crypto_live_chart.dart:174` and `splash.dart:125`. A `days` parameter that shared the existing cache key would let a 30D markets fetch overwrite the dashboard chart's 1D series.

**`fetchHistoricalPrices` never throws.** Every failure path returns either a stale cache entry or `{}` (`:77`, `:87`). An empty map is therefore the ONLY signal that a failure reached the caller, and a caller that renders it as an empty chart produces exactly the silent blank the brief forbids.

**`GWControlTrack` and the Markets hero's private track are geometrically identical.** Both are `padding: EdgeInsets.all(3)`, a 1px `borderSubtle` hairline, `radiusPill`, and 2px between children (`gw_control_track.dart:43-56` versus `markets_hero_card.dart:651-663`). The two `_TimeframeTab` widgets are the same code in both files. Only the fill differs: `surfaceMenu` on the Markets copy, `surfaceSunken` on the shared one. **Consolidating therefore moves no pixel of height**, which is what lets the pinned wide-card measurements survive Task 2.

**`markets_hero_height_test.dart` pins the wide card at 367.0 and its `IntrinsicHeight` row at 301.0**, with the 301 derived term by term from the LEFT column including the 48px price. Its own failure message says that if the RIGHT column ever becomes the taller one, the 253px chart stops being free. Right column today is roughly 30 (track) + 16 + 253 = 299 against the left's 301 — two pixels of headroom. **Shrinking the price on the WIDE branch would flip that**, which is the measured reason Task 1 shrinks the narrow branch only.

**`markets_sort.dart` has exactly two consumers** (`markets_screen.dart`, `markets_table.dart`) and its own 62-line test. The two hits in `submit_logs_screen.dart` and `submit_logs_feedback_test.dart` are comments citing it as an idiom, not uses.
</measured_facts>

<decisions_settled>
**1. Cards replace the table at ALL widths, not just narrow.**
The brief asked for cards without qualifying a width, and inventing the qualifier would be me deciding something the user did not. Three supporting reasons: keeping both surfaces means holding two renderings of the same rows in sync forever; the table's own 1h % and 7d % columns render a marked-absent `-` on every row today, so preserving the table preserves two visibly empty columns the card design correctly drops; and AGENTS.md prefers deletion over addition. Desktop is not left with a column of stretched full-width cards — it gets two columns off `GeniusBreakpoints.useDesktopLayout`.

The table is phase-16 desktop-approved work, so this is a real change to an approved surface and it is named here rather than buried in a diff. What desktop LOSES is stated in decision 2.

**2. Interactive column sorting goes with the headers, and rank order is preserved.**
Cards have no header row to tap, so tap-to-sort by price / market cap / volume / name is gone. The table's DEFAULT order is kept exactly — one call to the existing `compareMarketRows(MarketSort.rank, true, ...)`, which is rank ascending, i.e. market cap descending, the CoinGecko and CMC convention. `markets_sort.dart` and its test therefore stay live rather than becoming dead code behind a hardcoded `.sort` on rank.

Re-adding a sort control was not in the brief and is not built here. **This is the one affordance the card layout costs, and the summary must surface it to the user as a question rather than leave it to be discovered.**

**3. The hero shrinks at phone width only, and the gate is the AND of the box and the window.**
The wide branch keeps its 48px price verbatim, because `markets_hero_height_test.dart` derives the 301.0 row height from that 48 and the right column is within 2px of overtaking the left. Shrinking desktop would make the 253px chart stop being free and grow the approved card. Narrow gets `GeniusWalletTypography.numericDisplay` (32, w700, tabular) — an actual token, which the current 48 is not.

The constraint handed to planning says to read the window (`GeniusBreakpoints.useDesktopLayout`) and not a widget's own constraints, because a previous task restyled the desktop dashboard by gating on a ~376px panel's width on a 2560px screen. That failure mode cannot occur here — `MarketsHeroCard` has exactly ONE call site (`markets_screen.dart:213`) and it is the page-width surface. But the literal instruction and the card's existing `LayoutBuilder` branch would still disagree in two real cases: a 769-791px desktop window (content 745-767px, so the card STACKS while the window says desktop), and a tablet app at 1024px (`useDesktopLayout` is false on iOS/Android regardless of width, while the box says wide). Typography that disagrees with the layout it is styling is a bug in either direction.

**So `wide` becomes the AND of the two signals** — `c.maxWidth >= GeniusBreakpoints.medium && GeniusBreakpoints.useDesktopLayout(context)` — and BOTH the layout branch and the type step read that one bool. The window is read, as instructed; the box can still veto; and the two can no longer disagree by construction, so no test is needed to prove they agree. The one behavioural change is that a mobile app at >=768px now stacks, which is what every other screen in this app already does.

**4. The narrow chart earns the frame by growing its box, not by lowering the bar.**
`kChartFrameMinHeight` is global — the coin page and the dashboard both measure against it — so lowering it to reach the Markets hero would restyle surfaces this brief never mentioned. Passing a `framed: true` override would violate the rule at `chart_axis.dart:117` that the frame is a runtime measurement of the box and never a per-surface flag. The honest move is the third one: give the narrow chart a box big enough to earn the frame, by DERIVING `kMarketsHeroChartHeightStacked` from `kChartFrameMinHeight` rather than restating 220 as a new magic number.

It costs 40px of card height. Task 1's type step gives back roughly the same amount on the same branch (the price line box goes 48 to 40, the title 24 to 22, and the icon row is unchanged), so the narrow card should land within a few pixels of where it is today. **That is a prediction, not a measurement — Task 1 measures it and the summary reports the real before/after numbers even if they contradict this paragraph.**

**5. 7D spends no network call.**
Locked in the brief. `_seriesFuture` stays null on the 7D tab and the card plots `widget.data.sparkline`, which `fetchCoinsMarketData` already fetched with `sparkline=true`. The API is unkeyed and rate-limited; the default tab must not add a request per page view.

**6. The two timeframe segments become one, because that is the smaller diff AND markets needs the new API anyway.**
`.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md` has been standing since July. Task 2 has to give SOMETHING an `onChanged` regardless, so the choice is between adding a callback to a private copy or adding it to the shared component and deleting the copy. The second is roughly +15 lines on `gw_timeframe_segment.dart` against about -130 in `markets_hero_card.dart`, and it closes the todo. Per `<measured_facts>` it moves no height.

The one visible delta: the Markets track's fill goes from a raised `surfaceMenu` chip to the recessed `surfaceSunken` well that `.planning/codebase/CONVENTIONS.md` documents as the control-track recipe and that the dashboard's segment already uses. That is convention alignment, not a restyle, and it is named here so the reviewer meets it as a decision.

**Rule-of-Three refusals, recorded so they read as decisions and not oversights:** the `%` change pill exists in `markets_hero_card.dart` as private `_ChangePill` and inline in the table — two copies before this change and two after, so it is NOT extracted. `_price` and `_compact` are likewise two copies and stay two copies. `GWStatTile` and `GWCard` ARE reused, because they already exist and already carry exactly this content.
</decisions_settled>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: The narrow hero stops shouting, and earns its axes (BXS-01, BXS-02)</name>
  <files>lib/dashboard/chart/markets_hero_card.dart, test/dashboard/markets_fixtures.dart, test/dashboard/markets_hero_height_test.dart</files>
  <behavior>
    - At a 402x900 surface the price renders at `numericDisplay`'s size and the coin name at `titleMd`'s, and nothing overflows.
    - At a 1400x1000 surface the price still renders at 48 and the coin name at `titleLg`, and the card is still 367.0 tall with a 301.0 `IntrinsicHeight` row.
    - At a 600x1200 surface the hero chart is framed: money labels down the right edge and a date row beneath the plot, exactly as the wide one has.
  </behavior>
  <action>
Extract the test fixture FIRST, then change `lib/`.

Create `test/dashboard/markets_fixtures.dart` holding the three helpers currently private to `markets_hero_height_test.dart` — the rising 30-point sparkline generator, the `CoinGeckoCoin` builder and the `CoinGeckoMarketData` builder — as public top-level functions. Move them verbatim; do not adjust a single field value, because the wide-card literals in that file were measured against exactly this data. Repoint `markets_hero_height_test.dart` at the new file and delete its local copies. Three consumers exist by the end of this plan (this file, Task 2's timeframe test, Task 3's cards test), so the Rule of Three is met, not anticipated. Run the file before touching `lib/` and confirm it is still green with the same numbers — that is the proof the extraction moved nothing.

Then `lib/dashboard/chart/markets_hero_card.dart`:

Change `kMarketsHeroChartHeightStacked` to be DERIVED from `kChartFrameMinHeight` rather than restating a number. Rewrite its doc comment completely: the existing one argues at length FOR staying below the frame threshold, and leaving it in place would leave the file arguing against its own behaviour. The replacement should say that the stacked hero now sits exactly at the threshold because axis labels at phone width were asked for, that the roughly 40px this costs is repaid by the smaller type step on the same branch, and that `chartUsesFrame` still measures the box it is handed so nothing per-surface is being flagged. Keep the sentence explaining that the stacked layout has neither `Spacer` nor `IntrinsicHeight` — it is still true and it is why this constant cannot be raised casually.

In `build`, turn the `final left = Column(...)` expression into a local `Widget buildLeft({required bool wide})` alongside the existing `buildRight({required bool fill})`. Do not lift it to a `StatelessWidget` — it closes over `gw`, `data`, `changeColor` and `up`, and hoisting it would mean threading four constructor arguments to serve one call site. AGENTS.md's widgets-not-helper-methods rule is aimed at extracted `_buildFoo()` methods on the State class; `buildRight` is already the file's own established shape for exactly this, and matching it is the smaller, more consistent diff. Note this reasoning in a comment so the next reader does not "fix" it.

Inside `buildLeft`, two conditional styles and nothing else:

The coin name takes `titleLg` when wide and `titleMd` when not. Keep the `letterSpacing: -0.2`, the `maxLines: 1` and the ellipsis on both branches.

The price takes today's fixed style verbatim when wide — same family, size, height, weight, letter spacing and tabular figures — and `GeniusWalletTypography.numericDisplay` with an explicit `color: gw.textPrimary` when not. Keep and extend the existing comment above it: the reason it is a FIXED style rather than a width-measured one is unchanged and still load-bearing, and the branch is a breakpoint choice between two fixed styles, which does not reintroduce the per-frame font search that froze the embedder. Record in the same comment why the wide branch keeps a size with no token behind it — the wide card's height is pinned by a test that derives its number from this value, and the right column is within about 2px of becoming the taller one, so shrinking it is not free.

In the `content` `LayoutBuilder`, change the `wide` expression to require BOTH the box and the window: the existing `c.maxWidth >= GeniusBreakpoints.medium` AND `GeniusBreakpoints.useDesktopLayout(context)`. Comment it with decision 3's reasoning in two sentences: the window is the authority on device class, the box can still veto when the card is genuinely narrow, and one bool driving both the layout branch and the type step is what makes it impossible for them to disagree. Pass that same bool into `buildLeft`.

Change nothing else. Not the icon size, not a spacing token, not `kMarketsHeroChartHeight`, not `buildRight`'s structure, not `_HeroChart` (Task 2 owns that file region).

Then update `test/dashboard/markets_hero_height_test.dart`:

The two wide tests must pass with their literals UNTOUCHED. **You may not edit 367.0 or 301.0.** If either fails, stop and report it as a finding — it would mean the right column overtook the left and the plan's premise is wrong.

The stacked test currently asserts the chart is axis-free and that the `LineChart` is exactly `kMarketsHeroChartHeightStacked` tall. Both claims invert with this change. Rewrite it to assert the framed relationship instead of a literal: the `LineChart` is shorter than the box by exactly `kChartTimeRowHeight`, and money labels are present. Keep the `expect(find.byType(IntrinsicHeight), findsNothing)` — the stacked branch still has no `IntrinsicHeight` and that is worth keeping pinned.

Add two tests at surfaces that produce the real branches. At 402x900, read the price's resolved `fontSize` off `tester.renderObject<RenderParagraph>(...).text.style` and assert it equals `GeniusWalletTypography.numericDisplay.fontSize`, assert the coin name resolves to `titleMd.fontSize`, and assert `tester.takeException()` is null. At 1400x1000 assert the price resolves to 48 — that test is the guard on decision 3, and its reason string should say that a failure here means the desktop hero was shrunk and the pinned heights are about to move. Locate the price by formatting the fixture's `currentPrice` through the same `NumberFormat.currency` the widget uses rather than hardcoding a dollar string, so the finder cannot drift from the data.

Measure and report the narrow card's total height before and after this task at 402x900. Decision 4 predicts it lands within a few pixels of today. If it does not, say the real number plainly.

Use `pump()`, never `pumpAndSettle()`.

Run `dart format` on only the three files this task touched, then the full gate list in `<verification>`. Commit as one commit, scope `260807-bxs`, subject describing what a user sees. No attribution trailer of any kind.
  </action>
  <verify>
    <automated>flutter test test/dashboard/markets_hero_height_test.dart</automated>
  </verify>
  <done>`markets_fixtures.dart` exists and the wide-card literals still pass through it untouched. The narrow price and title resolve to `numericDisplay` and `titleMd`; the wide ones still resolve to 48 and `titleLg`. The stacked chart is framed and shows money labels. 367.0 and 301.0 were not edited and both pass. The narrow card's before/after height is measured and reported. Analyzer clean, both shell gates 0, full suite green with the arithmetic shown.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: The timeframe tabs actually change the series (BXS-03)</name>
  <files>lib/components/gw_timeframe_segment.dart, lib/services/coin_gecko/coin_gecko_api.dart, lib/dashboard/chart/markets_hero_card.dart, test/dashboard/markets_hero_timeframe_test.dart</files>
  <behavior>
    - Tapping 30D calls the fetch with a 30-day range and re-plots the returned series.
    - Tapping 7D calls nothing and re-plots the bundled sparkline.
    - A fetch that comes back empty shows a retry affordance and no chart.
    - The bottom axis prints clock times for a one-day window and dates for a longer one.
  </behavior>
  <action>
Three files in `lib/`, in this order.

**`lib/components/gw_timeframe_segment.dart`** gains two optional parameters and nothing else. A `List<String> labels` defaulting to a `const` list holding the existing five, and a `ValueChanged<int>? onChanged`. Replace the hardcoded `_labels` static with a read of `widget.labels`. In the tab's `onTap`, keep the `setState` that moves the chip and then notify `widget.onChanged`. Uncontrolled-plus-callback, not fully controlled: the parent never needs to override the chip (a failed fetch leaves the tab selected and shows the error in the chart box, which is correct), and a required `selectedIndex` would break the dashboard's caller for no gain.

Both parameters are optional, so `dashboard_screen.dart`'s call site compiles and renders byte-identically. Confirm that by grep and report the hit list.

Rewrite the two doc paragraphs this makes false. The one stating the Markets hero keeps its own segment and is deliberately not folded in becomes the record that Markets now consumes this component with its own labels, closing the unify todo. The visual-only note is now conditional, not absolute: the component reports the tap and the consumer decides whether anything happens, the dashboard passes no callback and so is still cosmetic, and Markets passes one. Keep the sketch-078 evidence paragraph about the label grammar and the control track — still true, still the reason the recipe is what it is.

**`lib/services/coin_gecko/coin_gecko_api.dart`**: `fetchHistoricalPrices` gains an optional named `int days` defaulting to 1, interpolated into the `market_chart` URL in place of the literal. The Hive cache key becomes the coin id when `days` is the default and the coin id combined with the day count otherwise. Comment why the default keeps the bare id: every entry already in the box was written under that key and both existing callers want the default, so there is no migration and no orphaned entry — while a 30D markets fetch still cannot land on top of the dashboard chart's 1D series, which sharing one key would have allowed. Touch neither existing caller.

**`lib/dashboard/chart/markets_hero_card.dart`**:

Delete the private `_TimeframeSegment` and `_TimeframeTab` widgets entirely and import the shared component.

Add a top-level `const` list of range records pairing each label with its day count — 24H to 1, 7D to 7, 30D to 30, 1Y to 365 — so the labels the segment renders and the days the fetch uses cannot drift apart, and so the test can read the mapping instead of restating it.

Add a top-level `typedef` for the series payload: a record of the values, a start `DateTime` and an end `DateTime`. A typedef rather than a class — it carries no behaviour and needs no equality.

Add a top-level pure function that chooses the bottom-axis `DateFormat` from the window's `Duration`: clock time for a window of about a day, day-and-month for weeks and months, month-and-year beyond roughly a quarter. Top-level and pure for the same reason every rule in `chart_axis.dart` is — an axis-format bug looks like a working chart in every screenshot. Doc-comment it with the failure it prevents: six identical day labels across a 24-hour window is the same class of lie as six identical clock times across a week, which is what the old fixed 7-day assumption produced in one direction.

`MarketsHeroCard` gains one constructor parameter: the fetch function, typed to match `fetchHistoricalPrices` exactly and defaulting to it as a tear-off. Mark it `@visibleForTesting` and doc-comment why it exists rather than leaving it to look like premature configurability: `fetchHistoricalPrices` opens a Hive box, and real Hive I/O inside `testWidgets` hangs forever in this repo — see `.planning/todos/completed/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md`. Without the seam the wiring has no runnable check at all.

`_MarketsHeroCardState` gains the selected index, defaulted to the 7D entry, and a nullable `Future` of the series payload. **Null means the free path**: 7D plots `widget.data.sparkline`, which `fetchCoinsMarketData` already retrieved, with a window synthesised as the last seven days. A tap handler sets the index and sets the future to null for 7D or to a new fetch otherwise.

The fetch helper awaits the injected function, and **throws when the returned map is empty**. Comment that this is not defensive noise: per `<measured_facts>` the API swallows every failure and hands back an empty map, so an empty map is the only failure signal that reaches here, and rendering it as an empty chart is the silent blank the brief forbids. On success, sort the keys ascending before projecting to values — CoinGecko returns them in order today and the map preserves insertion order, but ordering the series the chart plots should not rest on two undocumented behaviours agreeing. Build the payload's start and end from the first and last keys, which are real timestamps.

In `buildRight`, replace the `Align`-wrapped private segment with the shared one carrying the range labels, an initial index of the 7D entry and the tap handler. Inside the chart `SizedBox`, branch on the future: null renders `_HeroChart` directly on the sparkline payload; otherwise wrap it in `FutureStateWidget` with an `onRetry` that installs a fresh fetch future and an `error` child naming the range that failed. `FutureStateWidget` is the right tool here for a reason worth a comment, not just convenience: it is already this screen's loading/error idiom two levels up in `markets_screen.dart`, it supplies the spinner, the retry button and a snackbar for free, and because `FutureBuilder` drops results from a future it is no longer watching, rapid tab taps cannot paint a stale series — no request token needed.

Change `_HeroChart` to take the values plus a real start and end instead of a bare sparkline. Replace the hardcoded seven-day window arithmetic with interpolation across the supplied window, guarding a single-point series. Feed the bottom-row labels from the new format chooser rather than the fixed day-and-month, and leave the tooltip's format alone — it already prints both date and time and is honest at every range. Replace the `ponytail:` block that names the fixed 7-day window as its ceiling; the window is real now for fetched ranges and synthesised only on the free 7D path, so the remaining ceiling is that points are assumed evenly spaced across the window, which holds for CoinGecko's `market_chart` buckets and for `sparkline_in_7d`. Name carrying a timestamp per point as the upgrade path.

Then the bookkeeping. Move `.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md` to `.planning/todos/completed/`. Do NOT close `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md` — that one is about `CryptoLiveChart` on the dashboard, which this task does not touch. Append a dated note to it recording that its step 1, the ranged fetch, is now built and shipped on the Markets hero, so what remains is the dashboard chart's own wiring and the zoom/pan product call in its step 3.

**Test: `test/dashboard/markets_hero_timeframe_test.dart`**, importing Task 1's `markets_fixtures.dart`. Host the card with a fake fetch that records the coin id and day count it was called with and returns a series distinguishable from the fixture sparkline by length. Four claims: tapping 30D calls the fake with 30 days and the plotted spot count becomes the fake's length; tapping 7D never calls the fake and the plotted spot count is the sparkline's; a fake returning an empty map produces a retry affordance and no chart in the box; and the format chooser is exercised directly as a pure function across a one-day, a one-week and a one-year window, with no pump at all.

Read the plotted spots through the `LineChart` widget's own data rather than by scraping labels. Drive the frames with `pump()` and explicit zero-duration pumps to let the future settle — **never `pumpAndSettle()`**, the loading indicator animates indefinitely and would time the test out.

`dart format` the four touched files, run the full gate list, commit as one commit scoped `260807-bxs`. No attribution trailer.
  </action>
  <verify>
    <automated>flutter test test/dashboard/</automated>
  </verify>
  <done>Tapping 30D fetches 30 days and re-plots; tapping 7D fetches nothing; an empty response shows retry and no chart; the axis format chooser is unit-tested at three windows. `markets_hero_height_test.dart`'s 367.0 and 301.0 still pass untouched, proving the track swap moved no height. The dashboard's `GWTimeframeSegment` call site is unedited and the grep hit list is reported. The unify todo is in `completed/`; the CryptoLiveChart todo is still pending with a dated note appended. Analyzer clean, both shell gates 0, full suite green with the arithmetic shown.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Cards replace the markets table (BXS-04)</name>
  <files>lib/dashboard/chart/markets_table.dart, lib/dashboard/chart/markets_cards.dart, lib/dashboard/chart/markets_screen.dart, test/dashboard/markets_cards_test.dart</files>
  <behavior>
    - Each card shows coin icon, name, symbol, price, 24h change, market cap and volume, and no chart.
    - At phone width the cards are one per row; at desktop width two per row.
    - The list is ordered rank ascending, the order the table defaulted to.
  </behavior>
  <action>
Rename the file with `git mv lib/dashboard/chart/markets_table.dart lib/dashboard/chart/markets_cards.dart` so the rename reads as a rename in review rather than as a delete plus an add.

Keep `MarketRow` exactly as it is — the display pair plus its Flutter-free `sort` projection. `markets_screen.dart` builds these and Task 3 does not change how.

Replace `MarketsTable` with a `MarketsCards` `StatelessWidget` taking the same two parameters, `rows` and `onTapRow`. It is stateless because the sort state is the only thing that made the old one stateful, and per decision 2 the sort control goes with the headers.

Delete, and confirm each is genuinely unreferenced afterwards: the seven fixed column-width constants and the minimum-table-width sum, the header builder, the data-row builder, the change placeholder helper, the mini sparkline widget, the sort state and its header-tap handler, and the horizontal-scroll wrapper. Then remove every import the deletions orphaned — the analyzer will name them.

Order the rows with one call to the existing `compareMarketRows` on the rank column ascending. Comment that this is deliberately the module call and not a hardcoded comparison on the rank field, because it keeps `markets_sort.dart` and its 62-line test live and keeps the ordering defined in one place.

Column count comes from `GeniusBreakpoints.useDesktopLayout(context)` — two on desktop, one otherwise. Read the window, not a `LayoutBuilder`: this list is a page-width surface with one call site, and gating on a box's own width is how a previous task restyled the desktop dashboard from a 376px panel. Chunk the ordered list into rows of that many, gapping the columns and the rows with the same spacing token.

**`CrossAxisAlignment.stretch` is forbidden on those rows and the comment must say why.** The list lives inside the page's vertical `SingleChildScrollView`, so the row's incoming height is unbounded, stretch has nothing to resolve against and the children collapse — the same failure the hero card's `IntrinsicHeight` comment documents. Use `start`. Every text in the card is single-line and ellipsised, so the cards are uniform in height by construction and `start` is visually indistinguishable from stretch. Pad an odd final row with an empty flexible child so the last card does not stretch to full width.

The card is a private `_MarketCard` `StatelessWidget` in the same file — a widget, not a method returning a widget, per AGENTS.md. It composes existing components rather than drawing a surface:

`GWCard` with `hoverLift` and the tap callback supplies the surface, the hairline, the radius, the shadow and the app-wide hover recipe. Do not hand-roll a `Container` with a decoration. Wrap it in `Semantics` marking it a button and labelling it with the coin name and its purpose, mirroring what the hero card already does — `GWCard`'s `InkWell` gives focus and Enter/Space activation, the label is what a screen reader needs on top of it.

Inside, a top row and a stat row. The top row is the token icon through the shared `buildTokenIcon`, then a flexible column with the coin name at `titleMd` in `textPrimary` over the uppercased symbol at `labelMd` in `textSecondary`, then an end-aligned column with the price at `numericBody` weight 600 in `textPrimary` over the 24h change pill. Build the pill inline the way the table already did — per the Rule-of-Three refusal in `<decisions_settled>`, two copies exist and two copies remain, and extracting a shared pill for a second caller is the wrong-abstraction trade AGENTS.md warns about.

The stat row is two `GWStatTile`s in equal flexible slots, market cap and 24h volume, fed by the existing compact formatter. That component already renders exactly this label-over-number unit on the hero card for these same two figures, so reusing it is what keeps the card and the hero reading as one screen.

No sparkline, no `LineChart`, no chart of any kind on the card. That is a locked decision and the test pins it.

Keep the file's `_price` and `_compact` helpers as private top-level or static functions on the card. They are the second copy of the hero's, not the third, so they are not extracted.

In `lib/dashboard/chart/markets_screen.dart`, change the import and the one construction site. Nothing else moves — the page frame, the gutters, the scroll viewport, the hero and the `All Markets` section title are all untouched, and the `rows` list is built exactly as before.

Bookkeeping: check whether `.planning/todos/pending/2026-07-24-markets-1h-7d-change-columns.md` exists. If it does, move it to `completed/` with a dated note that the columns it describes no longer exist — the card design dropped both placeholders rather than fill them, so it closes by removal and not by implementation. If it does not exist, say so and move on.

**Test: `test/dashboard/markets_cards_test.dart`**, importing Task 1's `markets_fixtures.dart`. Build a handful of rows with distinct ranks in a deliberately scrambled order. Four claims. At 402x900: one card per row, proven geometrically by the first two cards NOT sharing a top edge. At 1400x1000: two per row, proven by the first two cards sharing one. At either width: the price, market cap and volume strings are on screen and `find.byType(LineChart)` finds nothing — that last one is the locked no-chart decision, and a comment should say so. And the first card in document order carries the rank-1 coin's name, which is the ordering claim.

Use `pump()`, never `pumpAndSettle()`.

`dart format` the touched files, run the full gate list, commit as one commit scoped `260807-bxs`. No attribution trailer.

**Do not open a pull request.** Braian has not authorised one for this branch.
  </action>
  <verify>
    <automated>flutter test test/dashboard/ && flutter analyze</automated>
  </verify>
  <done>`markets_cards.dart` exists as a rename with `MarketRow` unchanged; the table, its column constants, its header, its placeholder cells and its mini sparkline are gone along with their orphaned imports. Cards render one per row at 402px and two at 1400px, ordered rank ascending, with no `LineChart` anywhere in the list. `markets_screen.dart` changed only its import and its one construction site. Analyzer clean, both shell gates 0, full suite green with the arithmetic shown. Nothing is pushed and no PR exists.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| CoinGecko `market_chart` response to the chart | Untrusted remote JSON crossing into a widget that plots it. The `days` parameter is the only new thing this diff sends outward. |
| Hive market/historical cache to the chart | Locally persisted, but written from the boundary above, so a poisoned response persists across launches. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-bxs-01 | Tampering | `fetchHistoricalPrices` Hive cache key | medium | mitigate | The key gains the day count for any non-default range, so a Markets 30D/1Y response cannot be served back to the dashboard chart as its 1D series. Task 2 pins the default key unchanged so no existing entry is reinterpreted. |
| T-bxs-02 | Denial of service | Unkeyed, rate-limited CoinGecko API | medium | mitigate | 7D spends no request (decision 5), so the default tab adds zero load per page view. The existing 3-minute Hive cache and 3-second request timeout both still apply unchanged. A throttled response arrives as an empty map and surfaces as retry, never as a silent blank or a retry loop. |
| T-bxs-03 | Tampering | Remote price series plotted without validation | low | accept | The series is display-only — no balance, quote, fee or signature is derived from it. Same exposure the bundled sparkline already carries. Task 2 sorts by timestamp before plotting, so an out-of-order response cannot draw a scrambled line. |
| T-bxs-04 | Information disclosure | Nothing in this diff touches keys, seeds or addresses | low | accept | No Cubit/Bloc state, no logging, no `toString()` on anything key-derived. `check_no_new_key_logging.sh --scan-tree` is in the gate list regardless. |
| T-bxs-SC | Tampering | package installs | low | accept | No package is added, removed or upgraded. `pubspec.yaml` is not in `files_modified`. |
</threat_model>

<verification>
Run after EVERY task, output quoted, never assumed. The Flutter SDK is not on `PATH` in this environment — resolve it before the first command and say which SDK answered.

1. `dart format` on only the files that task touched.
2. `flutter analyze` — no issues. It exits non-zero on infos by design, so check the exit code rather than eyeballing the tail.
3. `flutter test` — full suite. Measure the pre-change count yourself rather than trusting any number in this plan; report before, after, and the arithmetic connecting them.
4. `bash tool/check_brace_style.sh` — exit 0.
5. `bash tool/check_raw_colors.sh` — exit 0.
6. `bash tool/check_onboarding_seed_safety.sh` — exit 0.
7. `bash tool/check_no_new_key_logging.sh --scan-tree` — exit 0.
8. `bash tool/check_agent_rules_sync.sh` — exit 0.
9. `markets_hero_height_test.dart`'s 367.0 and 301.0 pass after every task, unedited.
10. `git log --oneline` shows one commit per task on `feat/markets-page-cards`, no attribution trailer, and `gh pr list` shows no PR for this branch.
</verification>

<success_criteria>
- At 402px the hero price renders at the `numericDisplay` token, not 48, and the coin name at `titleMd`.
- At 1400px the price is still 48, the card is still 367.0 tall and its `IntrinsicHeight` row still 301.0.
- The narrow hero chart shows money labels down its right edge and date or time labels along its bottom.
- Tapping 24H, 30D or 1Y fetches that range and re-plots it; tapping 7D re-plots the bundled sparkline with no request.
- A failed or throttled fetch shows a retry affordance in the chart box, never a blank chart.
- The All Markets body is cards carrying icon, name, symbol, price, 24h change, market cap and volume, with no chart, one per row at phone width and two at desktop, ordered rank ascending.
- One `GWTimeframeSegment` exists, not two, and the dashboard's call site is byte-identical.
- Eight gates run per task with real numbers reported.
- Three commits, no attribution, no PR.
</success_criteria>

<output>
Create `.planning/quick/260807-bxs-markets-page-shrink-genius-ai-hero-title/260807-bxs-SUMMARY.md` when done.

Beyond the standard sections it must carry:

- **The narrow hero card's height before and after Task 1**, against decision 4's prediction that the type step roughly repays the taller chart. If it does not, the real number and a plain statement that the prediction was wrong.
- **The wide card's 367.0 and 301.0 re-confirmed after EACH of the three tasks**, since Task 2's track swap and Task 3's neighbouring edits both had the opportunity to move them.
- **A direct question to the user about sorting.** Decision 2 drops tap-to-sort by price, market cap, volume and name along with the table headers, keeping only rank order. Ask whether that affordance should come back as a control above the card list, and say that `markets_sort.dart` was kept live specifically so it could.
- **The `days` parameter's blast radius**: the grep confirming both existing `fetchHistoricalPrices` callers are unedited, and the cache keys now in use.
- **The `GWTimeframeSegment` grep hit list** proving the dashboard's call site was not touched.
- The state of both timeframe todos: which moved to `completed/`, which stayed pending and what note was appended.
- Whether the 1h/7d columns todo existed and what happened to it.
- An explicit statement that no PR was opened.
</output>
