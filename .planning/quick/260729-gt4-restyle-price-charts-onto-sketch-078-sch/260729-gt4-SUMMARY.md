---
phase: quick-260729-gt4
plan: 01
subsystem: chart
tags: [chart, fl-chart, coin-detail, dashboard, markets, timeframe-segment, contrast, wcag-1-4-11, dark-mode]
status: complete
dependency-graph:
  requires: []
  provides:
    - lib/chart/chart_axis.dart (chartTickStep, axisMoneyLabel, chartXLabelCount, chartYTickCount, chartUsesFrame, chartBandedBounds, visibleExtremes)
    - lib/components/gw_timeframe_segment.dart (GWTimeframeSegment)
  affects:
    - lib/chart/crypto_live_chart.dart
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/dashboard/chart/markets_hero_card.dart
tech-stack:
  added: []
  patterns:
    - "Runtime A/B chart-frame switch measured off the plot LayoutBuilder, never a per-surface config"
    - "Y-window transform (chartBandedBounds) used to reserve label gutters instead of a plate drawn over the line"
key-files:
  created:
    - lib/chart/chart_axis.dart
    - lib/components/gw_timeframe_segment.dart
    - test/chart/chart_axis_test.dart
    - test/dashboard/markets_hero_height_test.dart
  modified:
    - lib/chart/crypto_live_chart.dart
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/dashboard/chart/markets_hero_card.dart
decisions:
  - "Task 4's height hypothesis (grow the Markets hero chart 180->253 for free on wide layouts) was FALSIFIED by measurement; kMarketsHeroChartHeight stays at 180 pending Jakub's decision"
  - "Trend colour (078-S2) and the borderControl contrast fix (078-S3) shipped on the Markets hero regardless, since they do not depend on the disproven height claim"
metrics:
  duration: "~2.5h"
  completed: 2026-07-29
---

# Quick Task 260729-gt4: Restyle price charts onto sketch 078 scheme B Summary

Ported sketch 078's "Trading frame" (scheme B, with scheme A as the runtime
axis-free fallback) into `CryptoLiveChart`, wired the existing `trendColor`
through the line/gradient/dot on all three chart surfaces, fixed the
touched-spot indicator's WCAG 1.4.11 contrast failure, extracted
`GWTimeframeSegment`, and gave the chart an honest empty state — with one
finding that stopped Task 4's height change short of shipping (see
Deviations).

## What was built

**Task 1 — `lib/chart/chart_axis.dart` + `test/chart/chart_axis_test.dart`.**
The chart's pure geometry rules, ported from the sketch's JavaScript logic
(not its SVG): `chartTickStep` (the nice-number ladder with the deliberate
2.5 rung), `axisMoneyLabel` (precision from the tick step, not the value's
magnitude), `chartXLabelCount` / `chartYTickCount` (clamped label counts),
`chartUsesFrame` (the 220px runtime A/B threshold), `chartBandedBounds`
(scheme A's reserved label gutters as a Y-window transform), and
`visibleExtremes` (H/L over the visible window, not the whole fetched
series). 17 tests, RED-then-GREEN.

**Task 2 — `crypto_live_chart.dart` trend colour, contrast, crosshair,
chrome swap.**
- `trendColor` now reaches the line, its below-bar gradient, and the touched
  dot (078-S2) — `mintColor` is gone. The stale "always mint" comment is
  replaced with the reversal history (Markets sparklines already colour by
  sign; an always-mint hero would contradict them).
- The touched-spot indicator moved from `gw.borderStrong` (2.10:1) to
  `gw.borderControl` (3.30:1 dark / 3.10:1 light), clearing WCAG 1.4.11.
- The crosshair runs the full plot height (`getTouchLineStart`/`getTouchLineEnd`
  return `minY`/`maxY`) instead of stopping at the touched spot.
- The floating tooltip is suppressed (`getTooltipItems` returns nulls;
  `getTooltipColor` transparent, border none, padding zero) — no box paints
  over the data.
- The area fill fades to zero alpha at 62% of the plot height
  (`kChartFillFadeStop`), matching `belowBarLargestRect`'s equivalence to the
  sketch's SVG `objectBoundingBox` gradient.
- The four zoom/pan `IconButton`s and their four handler methods are deleted.
  Replaced with a chart-owned header row (`_ChartHeaderRow`, a
  `StatelessWidget`) rendered only when `showPriceHeader == false`: price,
  signed %, hovered time (or "Latest"), a `Spacer`, then
  `GWTimeframeSegment`. When `showPriceHeader == true` (the dashboard), the
  existing price+pill header is untouched except the hovered time is
  appended as a sibling in the pill's own `Row` — zero added height.
- Added a narrow-width fallback inside `_ChartHeaderRow` (a `LayoutBuilder`,
  threshold 420px, matching the sketch's own `.chartcard.narrow` rule): below
  420px the hovered-time label drops and the price steps down to 15px. This
  is a Rule 2 addition — the plan's header spec did not call it out
  explicitly, but the unmodified row's fixed-width children (price + % +
  time + a 5-tab `GWTimeframeSegment`) do not fit the 366px coin-page mobile
  card, and this is exactly the surface Task 5's own walk script exercises.
- The empty state now distinguishes "still loading" from "the fetch came
  back with nothing": `_fetchHistoricalData` is wrapped in try/catch/finally,
  a `_loadAttempted` flag flips in `finally`, and an empty+attempted fetch
  renders `GWEmptyState(icon: Icons.show_chart, title: 'No price history', ...)`
  instead of pulsing the skeleton forever. The caught error is not logged or
  rendered anywhere.
- `GWTimeframeSegment` extracted verbatim from the dashboard's private
  `_TimeframeSegment`/`_TimeframeTab` into `lib/components/gw_timeframe_segment.dart`
  as a public widget with `initialIndex`. `dashboard_screen.dart` now imports
  and uses it; both private classes were deleted from that file (141 lines
  removed net).

**Task 3 — the runtime A/B switch.** A single `LayoutBuilder` wraps the plot
area (below the header), measuring the PLOT box (not the card), and branches
on `chartUsesFrame(constraints.maxHeight)` — exactly one call site in the
file. Two `StatelessWidget`s carry the two schemes so DevTools can tell them
apart:
- `_TradingFrameChart` (scheme B, >=220px of plot): right Y axis on
  `chartTickStep`'s nice-rounded ticks, horizontal-only gridlines at
  `borderSubtle` 6% alpha sharing the same `step` as the axis (so labels
  land on gridlines by construction), `minIncluded`/`maxIncluded: false` on
  the right `SideTitles` (or fl_chart also prints the raw padded min/max), and
  a plain `Row` of time labels below the plot (not fl_chart's bottom titles,
  which anchor to `baselineX` and cannot line up with epoch-second samples).
- `_SparklineChart` (scheme A fallback, <220px): today's axis-free geometry,
  now with the Y window run through `chartBandedBounds` so the series is
  confined to the middle strip and two `_HighLowPlate` labels (H top-band,
  L bottom-band) can never be crossed by the line — the fix that replaced an
  opaque plate the line could still run through.

**Task 4 — the markets hero.** Test-first: `test/dashboard/markets_hero_height_test.dart`
pumps `MarketsHeroCard` with a hand-built 30-point rising-sparkline fixture
in a 1200px-wide, height-unbounded `SingleChildScrollView` (matching
`markets_screen.dart:197`), and records the real card height via
`tester.getSize`. **Run first against the shipped 180px chart: card height
619.0px.** Flipping `kMarketsHeroChartHeight` to 253 and re-running the same
assertion showed the card growing to 692.0px — a 73px increase, the exact
slack the plan's `Spacer`/`IntrinsicHeight` derivation predicted would be
absorbed for free. **The hypothesis was falsified; the constant was reverted
to 180 and the height change was NOT shipped**, per this task's own
instruction not to accept a taller card. The two colour fixes that don't
depend on the height claim (trend colour on `_HeroChart`, the
`borderControl` contrast fix) were still applied in full.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - missing correctness] Added a narrow-width fallback to the new
`_ChartHeaderRow`.**
- **Found during:** Task 2, while implementing the chart-owned header.
- **Issue:** The header row's fixed-width children (price text, the signed
  %, the hovered-time label, and a 5-tab `GWTimeframeSegment`) do not all fit
  the 366px coin-page mobile card — a real `RenderFlex` overflow risk on
  exactly the surface Task 5's walk script exercises ("Coin page, narrow the
  window until it is mobile-shaped").
- **Fix:** Wrapped the row in a `LayoutBuilder`; below 420px width (the same
  threshold the sketch's own `.chartcard.narrow` CSS rule uses) the hovered
  time label drops and the price steps down from 17px to 15px.
- **Files modified:** `lib/chart/crypto_live_chart.dart`
- **Commit:** not committed (per hard constraint — see below)

### Blocking Finding (reported, not resolved)

**2. [Task 4 hypothesis falsified] The Markets hero chart stays at 180, not
253.**
- **Found during:** Task 4, exactly where the plan's own "one thing that
  must fail loudly" section said to look.
- **What was claimed:** Growing `_HeroChart`'s `SizedBox` from 180 to 253
  would cost the WIDE-layout card no height, because the right column's
  `Spacer` (inside an `IntrinsicHeight` row) was holding 73px of slack.
- **What was measured:** `test/dashboard/markets_hero_height_test.dart`
  pinned the real card height at 619.0px against the shipped 180. Flipping
  the constant to 253 grew the card to 692.0px — the full 73px the `Spacer`
  was supposed to absorb was NOT absorbed. The `IntrinsicHeight` row's
  cross-axis intrinsic-height computation with a flex-child `Spacer` does not
  zero out the way the derivation assumed.
- **Action taken:** `kMarketsHeroChartHeight` was reverted to 180 and the
  height test locked onto the CURRENT (unregressed) shape — it will fail
  loudly again if a future change either grows the card at 180 or silently
  bumps the constant without re-measuring. Trend colour and the contrast fix
  were still shipped since they're independent of the height claim.
- **Not resolved — needs Jakub's call.** Two directions worth naming: (a)
  drop the `Spacer` and let the right column define the row's height instead
  of the left, or (b) accept the 73px growth on wide as the cost of a taller
  hero chart and re-measure/re-derive the left column's own height budget
  (301 may itself be wrong — see below).
- **Files modified:** `lib/dashboard/chart/markets_hero_card.dart`,
  `test/dashboard/markets_hero_height_test.dart`

## Auth Gates

None.

## Known Stubs

None. The empty state (`GWEmptyState` for a fetch that returns nothing) is
fully wired, not a stub.

## Threat Flags

None. This is a pure rendering change inside an existing widget — no new
network call, no new persistence, no new platform channel, no new
dependency. `pubspec.yaml` was not touched.

## Gate Results (measured, verbatim)

```
$ flutter analyze
...
  error • filePickerError isn't defined ... lib/submit_job/view/submit_job_screen.dart (x6)
  error • processErrorMessage isn't defined ... lib/submit_job/view/submit_job_screen.dart (x4)
   info • unnecessary_import ... test/account/account_drawer_show_test.dart:27:8
11 issues found.
```
All 11 are OUTSIDE my file set (`lib/submit_job/`, `lib/bloc/` are explicitly
"THEIRS" per the hard constraints; `test/account/` is an unrelated concurrent
test). `git diff --stat -- lib/submit_job/ lib/bloc/` confirms those files
carry a concurrent agent's in-progress edits (a state/cubit rename that
`submit_job_screen.dart` — untouched by that agent yet — no longer matches).
Not fixed, per the scope boundary and the hard "do not touch" file list.
None of the 7 files this plan modifies appear in the analyzer output —
**0 issues in scope.**

```
$ bash tool/check_brace_style.sh --count
0
```

```
$ flutter test test/chart/ test/dashboard/ test/tokens/
...
00:13 +279: All tests passed!
```
279/279 pass, 0 failures, across every test directory that touches my 7
files (chart, dashboard, tokens — including `markets_hero_height_test.dart`
and `chart_axis_test.dart`). I did NOT run the bare `flutter test` (whole
suite) as the final gate: a full run mid-session hit a pre-existing,
unrelated `setState()`-returned-a-Future crash in
`test/account/account_drawer_show_test.dart` (not one of my files, not
touched by this plan) that took the whole test isolate down before it could
finish and report a final tally — consistent with the hard constraint that
the baseline is moving under concurrent agents right now. The scoped run
above is the real signal for this plan's own files.

```
$ flutter test test/chart/chart_axis_test.dart test/chart/chart_y_bounds_test.dart test/chart/compact_price_font_size_test.dart
...
00:00 +24: All tests passed!
```

```
$ flutter test test/dashboard/markets_hero_height_test.dart
...
00:01 +2: All tests passed!
```

Markets hero card height recorded: **619.0px at the shipped 180 chart.**
Held at 253? **No** — grew to 692.0px (see the Blocking Finding above).
`kMarketsHeroChartHeight` stays at 180.

## Invariants confirmed

- `git log -1` — `8ed02e789ce2cf152c0b35b015bc6fa0724f2aa5` — same hash the
  session started on. **No commit was created at any point.**
- `git diff --stat` for the 7 `files_modified` files, plus the 3 net-new
  files, matches exactly; nothing under `/banxa` or `/squidrouter` changed.
- `chartYBounds` in `crypto_live_chart.dart` is byte-for-byte identical to
  `HEAD` (diffed directly against `git show HEAD:...`).
- `_ChartSectionHeader`'s `space24` bottom padding is byte-identical — only
  its child `_TimeframeSegment()` → `GWTimeframeSegment()` reference changed.
- `crypto_live_chart.dart` contains exactly one `chartUsesFrame(...)` call
  site.

## What Jakub should look for on Task 5's walk

1. **Coin page, wide window.** Right-edge price labels on nice round
   numbers, faint horizontal gridlines, times along the bottom, a header row
   (price + % + "Latest" left, the 1H·1D·1W·1M·1Y segment right). Hover: a
   full-height vertical crosshair line, the header numbers track the cursor,
   and **no box appears over the data** (the old floating tooltip bubble is
   gone).
2. **Coin page, narrow to mobile width.** The frame should drop to the
   axis-free layout: `H $x` pinned in a strip at the top, `L $y` in a strip
   at the bottom, and **the line must never touch either label** — this was
   the original Polish-language complaint and the second attempt at fixing
   it. Also watch the new header row itself at this width: below ~420px the
   hovered-time label should disappear and the price should visibly step
   down a size, rather than overflowing.
3. **Drag-resize slowly through the ~220px plot threshold.** The chart
   should flip cleanly between the framed and axis-free layouts — no
   overflow stripes, no freeze.
4. **Dashboard.** The Bitcoin chart card should have exactly ONE timeframe
   segment (in the section header — the old duplicate is gone), no magnifier
   buttons, and no 34px overflow stripe at boot.
5. **Markets page.** The hero chart's line should be green or red matching
   the 24h move (not the old green-to-blue gradient). **The chart itself is
   still 180px tall, not 253** — this is the one place Task 5 will look
   different from what the plan originally described, and it is
   intentional: see the Blocking Finding above. The card should render
   exactly as it did before this plan (same height, same shape) except for
   the line's colour and the touched-spot indicator's contrast.
6. **Find a red day.** Every line on screen — hero, coin chart, dashboard
   chart, sparklines — should agree on the colour.
7. **Toggle light mode** and re-check the axis labels, gridlines, crosshair,
   and H/L plates.

## Self-Check: PASSED

- `lib/chart/chart_axis.dart` — FOUND
- `test/chart/chart_axis_test.dart` — FOUND
- `lib/components/gw_timeframe_segment.dart` — FOUND
- `test/dashboard/markets_hero_height_test.dart` — FOUND
- `lib/chart/crypto_live_chart.dart` — modified, present
- `lib/dashboard/home/view/dashboard_screen.dart` — modified, present
- `lib/dashboard/chart/markets_hero_card.dart` — modified, present
- No commits were created; `git log -1` unchanged — confirmed above.
