# Handoff · 2026-07-30 · Charts closed out, coin page reworked, row hover unified

**Branch:** `redesign/jakub-260728`, fast-forwarded to `origin/ui-redesign-port` at `dce14b92`
before any work started - it carried **zero** commits of its own, so this branch is Braian's
Phase 23 work plus this session on top. **PR opens against `ui-redesign-port`, never `main`.**

**Gates, measured at the end of the session, not quoted:**

| Gate | Result |
|---|---|
| `flutter analyze` | **1 issue**, and it is `test/account/account_drawer_show_test.dart` - untracked, local-only, see below |
| `tool/check_brace_style.sh --count` | **0** |
| `tool/check_raw_colors.sh --count` | **0** |
| `dart format --set-exit-if-changed lib` | **exit 0** |
| `flutter test` (all dirs except `test/account/`) | **688 pass / 0 fail** |

`test/account/account_drawer_show_test.dart` is still deliberately absent from git. It hangs the
suite (`testWidgets` + a real Hive box), which is why every test run here excludes `test/account/`.
Do not add it.

---

## 1 · What shipped

### Charts - the topic resumed from `HANDOFF-260729-compute-charts-and-header.md`

- **Coin-page chart header reaches the right edge.** The timeframe segment sat short of it with a
  band of dead space beyond. Cause: a loose `Flexible` for the price plus a `Spacer`, both at the
  default `flex: 1`, splitting free space 50/50; the price does not spend its half and `RenderFlex`
  parks the remainder AFTER the last child. **Identical defect to the one `gw_page_header.dart` was
  fixed for the day before.** Readouts now take one `Expanded`.

- **Markets hero takes the trading frame at 253px.** See §2 - the finding is bigger than the change.

### Coin page (sketch 164, Jakub picked A and C)

- **24h-range tile.** Two problems, and the first hypothesis was wrong: the track was NOT
  collapsing to zero width (measured 189px before any fix). It was painted `surfaceSunken` #06080C
  on a `surfaceElevated` #0C0E14 card - **1.04:1**, darker than its own background - with a
  `borderSubtle` edge at 1.36:1. Light mode hid it, because there `surfaceSunken` is a visible grey.
  Now `borderStrong`, which reads on both canvases. Separately the tile was **77px against its five
  neighbours' 65px** (`space4` + a 4px bar) because a `Wrap` neither stretches nor equalises; the
  rail is now chunked `Row`s under `IntrinsicHeight`. That forced the tile's inner `LayoutBuilder`
  out - it refuses intrinsic queries - so the marker is an `Align` on a fractional x.

- **Read-only Token price is no longer a field.** It is a `GWDetailGrid` row, matching `Total` one
  line below. The rejected alternative was Jakub's own first instinct - keep the box, grey the value
  - and it was rejected on a measurement: `textSecondary` on `surfaceSunken` is 6.20:1 dark but
  **4.23:1 light**, under the 4.5:1 body floor. This variant keeps `textPrimary` and has no such
  debt. It also removes a wart the old comment admitted: a `readOnly` field still takes focus in
  Flutter. `_tokenPriceController` went with it (a `double` was being stringified and re-parsed).

- **Receive / Swap / Bridge gained an edge.** `Icons.qr_code_2` became `Icons.call_received`;
  `swap_horiz` is unchanged, per Jakub. The glyph carries the brand gradient via `ShaderMask` using
  `brandCtaText`, **not** `brandCta` - the raw stops measure 1.65:1 / 2.28:1 on a light surface;
  the helper collapses to flat `#0A6885` (6.30:1) there. Dark stops are 10.39:1 and 7.54:1.

### Row hover - one component, five call sites

`GWHoverRow` in `lib/components/effects/gw_hover_row.dart`. Rounded `radiusMd` highlight, click
cursor, its own transparent `Material`, and an explicit hover colour of `gw.textPrimary` at **6%**
(`kGWRowHoverAlpha`). 6% is one surface step: **1.135** on `surfaceElevated`, against
`surfaceMenu`'s 1.108. Flutter's stock `ThemeData.hoverColor` is 4% (1.086) and every row in the app
was silently inheriting it.

Migrated: `TransactionRow`, `markets_table._dataRow`, `CoinCardRow` (Assets),
`CryptoSparkLineChart` (dashboard Markets panel), `GWTokenRow`.

---

## 2 · The finding that matters most - a "falsified" hypothesis that was not

`markets_hero_height_test.dart` recorded that growing the hero chart 180 → 253 costs the wide card
73px, and `kMarketsHeroChartHeight` sat at 180 for that reason. **The test never reached the wide
layout.** Its host wrapped the card in `SizedBox(width: 1200)` and its comments asserted that width
"clears `GeniusBreakpoints.medium` (768), so this is the WIDE (`IntrinsicHeight` row) layout" - but
it never set `tester.view.physicalSize`, which defaults to **800x600**. The `SizedBox` was clamped
and the card rendered **stacked**. The stacked branch passes `fill: false`: no `Spacer`, no
`IntrinsicHeight`. So of course it grew by exactly the chart's delta. **619.0 and 692.0 are
stacked-layout numbers.** It measured the one layout the claim was never about.

Re-measured with the surface actually set to 1400x1000: the `IntrinsicHeight` row reports
**301.0** - the original derivation to the pixel - and the card holds **367.0** at both 180 and 253,
verified by flipping the constant and re-running. The arithmetic was right; the instrument was wrong.
The handoff's "missing 284px is not yet explained" was never a real gap.

**The rule this earns: a widget test that does not set its surface is not testing the width it
says it is.** Both layouts are now pinned at surfaces that actually produce them, and there is a
separate assertion that the LEFT column still drives the row - which is the real invariant behind
the constant, not the card height.

Stacked hero deliberately stays at 180 (`kMarketsHeroChartHeightStacked`): no `Spacer` there, so
every pixel is real growth, and 180 sits below `kChartFrameMinHeight` so it keeps the axis-free
chart - the same runtime A/B rule the coin page follows.

---

## 3 · Walked, and NOT walked - do not read this as all-green

| Change | Status |
|---|---|
| Range tile, timeframe alignment | **Walked live by Jakub**, dark |
| Read-only row, action icons, hero frame | **Walked live by Jakub**, dark |
| Row hover: Transactions, Markets page, Assets | **Walked live by Jakub**, dark |
| Row hover: **dashboard Markets panel** | **NOT walked.** Fixed after Jakub's last look; hot reload was clean and 688 tests pass, but no human has seen it |
| **Light mode, all of the above** | **NOT walked at all this session** |

The light-mode gap is the honest risk. Every colour decision above carries a measured light figure,
but measured is not seen.

---

## 4 · Left deliberately un-fixed - do not "helpfully" fix these

1. **The timeframe segment is still a fake.** `GWTimeframeSegment` has **no `onChanged`** by design
   (user decision, 2026-07-21, "visual-only"), and the Markets hero carries its own separate copy
   with 24H/7D/30D/1Y labels. Tapping moves the chip and changes nothing. This was the agreed next
   task and is the last thing on these charts that lies.
   `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`

2. **Markets table rows keep a full-width bottom hairline under the rounded highlight.** That rule
   belongs to the TABLE, not the row; insetting it would stop it separating the columns it exists to
   separate. Flagged to Jakub, awaiting his eye in motion.

3. **Four tappable list rows were found and deliberately NOT migrated to `GWHoverRow`** - outside
   the scope Jakub set. Named so the next person does not have to re-sweep:
   `job_step_list.dart:161` (bare `InkWell`, no radius), `sdk_account_manager.dart:710`,
   `submit_logs_screen.dart:661`, `bridge_screen.dart:824` (a `ListTile` with the same buried-ink
   trap as Assets).

4. **Two chart todos are now obsolete and should be closed, not worked:**
   `2026-07-21-chart-zoom-pan-icons-still-raw-colors-white.md` and
   `2026-07-21-chart-zoom-pan-row-overflows-34px.md`. Both describe the zoom/pan buttons, which
   `260729-gt4` deleted.

5. **`.planning/sketches/165-coin-page-schemes/` is NOT in this PR.** It was being written by a
   parallel session while this one was closing (files stamped 11:51-11:53, after this session's own
   work). It is on disk, untracked, and belongs to whoever is writing it.

---

## 5 · Environment

- **Hot reload works across turns** via a FIFO on `flutter run`'s stdin - `echo r > $D/gw.fifo`.
  Never `R`: hot restart kills the app on the native node's RocksDB lock.
- The app was killed at end of session. A stale instance holds the Hive container lock and makes the
  next launch a silent black window.
- The six Apple-signing files remain held out via `skip-worktree`. `git ls-files -v | grep '^S'`
  confirms all six. **Never `git add -A` in this repo.**
- The two cmake fixes this project used to carry in the working tree (`TIMEOUT 3600`, Snappy
  `QUIET`) are now **upstream** - `cmake/` is clean. That note in the older handoffs is stale.
