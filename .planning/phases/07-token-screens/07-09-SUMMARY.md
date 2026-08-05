---
phase: 07-token-screens
plan: 09
subsystem: ui
tags: [flutter, gwbutton, gwkicker, gwstattile, coin-page, design-system]

requires:
  - phase: 07-token-screens
    provides: "07-04's coin-page layout (GWPageHeader, IntrinsicHeight two-panel row, CoinInfoCard, CoinConvertCard) that this plan restyles in place"
provides:
  - "Coin page (/token-info) matching sketch-165 Synthesis: bare kicker back-link, ticker-only subtitle, labelled Swap/Receive(/Bridge) action row, five-tile stat rail with a hole-free responsive ladder, a fixed-24h chart footer, and an icon-free Info card"
affects: [07-token-screens, coin-page-visual-audit]

tech-stack:
  added: []
  patterns:
    - "Stat-rail tile width computed per-ROW from that row's own tile count (not from a global `perRow`), so a partial last row always reaches the same right edge as a full one - the general fix for any tile count that doesn't evenly divide a fixed column ladder"
    - "A `Column` footer appended after an `Expanded(child: _FillHeight(...))` inside `IntrinsicHeight` still reports the footer's own height (not the chart's) as the column's intrinsic height, because a flex child's contribution to intrinsic-height is its own intrinsic size divided by its flex factor - zero divided by anything stays zero"

key-files:
  created: []
  modified:
    - lib/tokens/token_info_screen.dart
    - test/tokens/coin_page_stat_rail_test.dart
    - test/tokens/coin_page_range_tile_test.dart
    - test/tokens/coin_page_components_test.dart

key-decisions:
  - "Bridge takes gradientOutline (same as Receive) on GNUS-enabled coins - sketch 165 never drew a third action; this follows the file's own sketch-164 precedent for the identical situation. Flagged for the walk, not settled."
  - "Buttons ship at GWButtonSize.md (48px height) rather than the mockup's 40px, per DECISION constraint 2 (WCAG 2.5.5). Width is NOT fixed to 48 - it is intrinsic to the label, which is the correct and unavoidable consequence of converting icon-only 48x48 squares into labelled buttons; only height is the binding 48px tap-target dimension."
  - "Stat-rail perRow ladder is 5/3/2 (was 6/3/2), but the fix for the ragged tail is NOT the ladder - it is computing each row's tile width from that row's own chunk length instead of from the nominal perRow. 5's only divisors are 1 and 5, so no three-step ladder can keep every row exactly full the way 6/3/2 did; per-row width computation makes every row (full or partial) reach the rail's own right edge by construction, at any tile count."

requirements-completed: [SCR-03]

coverage:
  - id: D1
    description: "Back-link is a bare uppercase kicker (no chip/border/fill at rest), hover lifts text+chevron colour only, tap still pops to Markets"
    verification:
      - kind: unit
        ref: "flutter analyze lib/tokens/token_info_screen.dart — clean; no automated widget test asserts the absence of a border/fill directly"
        status: pass
    human_judgment: true
    rationale: "Visual absence of a border/chip and the hover colour lift are appearance claims; the checkpoint walk (Task 4, not performed) is the actual gate."
  - id: D2
    description: "Subtitle is the ticker alone; network name appears exactly once, in Info's Network row"
    verification:
      - kind: unit
        ref: "test/tokens/coin_page_stat_rail_test.dart — existing suite renders the header/subtitle path without regression (no dedicated subtitle-text assertion added)"
        status: pass
    human_judgment: true
    rationale: "No test in this plan asserts subtitle text content directly; visual confirmation belongs to the Task 4 walk."
  - id: D3
    description: "Swap + Receive (+ Bridge on GNUS coins) render as labelled buttons on their own row, Swap is the only filled control, actions survive the no-market-data route, tooltips replaced by label-based finders"
    verification:
      - kind: unit
        ref: "test/tokens/coin_page_stat_rail_test.dart#no market data: the page SAYS so and keeps what still works"
        status: pass
      - kind: unit
        ref: "test/tokens/coin_page_stat_rail_test.dart#074-C2: no Send, and no Bridge on a coin that cannot bridge"
        status: pass
      - kind: unit
        ref: "test/tokens/coin_page_stat_rail_test.dart#the Receive drawer never says \"Receive null\""
        status: pass
    human_judgment: false
  - id: D4
    description: "Stat rail is five tiles (no range tile), all equal height, no ragged tail/hole at the right edge at 1400/900/768/600/360px"
    verification:
      - kind: unit
        ref: "test/tokens/coin_page_range_tile_test.dart#the five rail cards are the same height, and none of them is a range tile"
        status: pass
      - kind: unit
        ref: "test/tokens/coin_page_range_tile_test.dart#no rail row leaves a hole at its right edge, at any tested width"
        status: pass
    human_judgment: false
  - id: D5
    description: "24h low/high moved to a fixed-24h footer under the chart (hairline, 24H LOW/24H HIGH, track+marker, values), absent when the range is unknown, and does not track the selected chart timeframe"
    verification:
      - kind: unit
        ref: "test/tokens/coin_page_range_tile_test.dart#the range track spans the chart card instead of collapsing to 0"
        status: pass
      - kind: unit
        ref: "test/tokens/coin_page_range_tile_test.dart#the marker does not overshoot at the high end of the range"
        status: pass
    human_judgment: true
    rationale: "The fixed-vs-timeframe divergence on 1W/1Y and the footer's visual placement/labels inside the chart card are the checkpoint walk's own item 7; no test here drives the chart's timeframe control."
  - id: D6
    description: "Wide layout: chart card height still comes from the Info+Convert column, not the chart"
    verification:
      - kind: unit
        ref: "test/tokens/coin_page_range_tile_test.dart#wide layout: the chart card and the Info+Convert column share one height"
        status: pass
    human_judgment: false
  - id: D7
    description: "Info card has no icons; labels start flush left; Address row still copies the full address with the copy affordance visible at rest"
    verification:
      - kind: unit
        ref: "test/tokens/coin_page_components_test.dart#the Info card renders no icons at all, and its six rows still stand"
        status: pass
      - kind: unit
        ref: "test/tokens/coin_page_components_test.dart#the whole Address row copies the FULL address"
        status: pass
    human_judgment: false
  - id: D8
    description: "Checkpoint: walk the coin page in dark AND light (Task 4)"
    verification: []
    human_judgment: true
    rationale: "NOT PERFORMED in this session per explicit instruction - requires a live app and a human. See 'Task 4' section below."

duration: unmeasured
completed: 2026-07-31
status: complete
---

# Phase 7 Plan 09: Coin page sketch-165 Synthesis Summary

**`/token-info` restyled to sketch-165 Synthesis - bare kicker back-link, ticker-only subtitle, labelled Swap/Receive(/Bridge) action row, five-tile stat rail with a per-row-computed ladder, a fixed-24h chart footer, and an icon-free Info card - Tasks 1-3 implemented and verified; Task 4 (the human walk) explicitly NOT performed.**

## Scope actually executed

Tasks 1, 2 and 3 of `07-09-PLAN.md`. Task 4 (`checkpoint:human-verify`, gate `blocking`) was **not attempted** per the orchestrator's explicit instruction - it requires a live app and a human, and no auto-approval is permitted for it (`acceptance_criteria` says so explicitly). It is marked not-done below and in the plan's own tracking.

**No git commits were created.** `AGENTS.md:23` ("Do not create commits") and the run's HARD OVERRIDES both forbid it; the working tree is left dirty for Jakub's own review, on top of three other uncommitted plans (Banxa 09-08, compute panel 14-08/14-09) that were explicitly not to be touched, and were not.

## Verification (real output, this session)

- `flutter analyze` (whole project): **No issues found!**
- `bash tool/check_brace_style.sh --count`: **0**
- `bash tool/check_raw_colors.sh --count`: **0**
- `dart format --set-exit-if-changed lib/tokens/token_info_screen.dart test/tokens/`: **exit 0**, 0 files needed reformatting
- `flutter test test/tokens/ test/components/`: **116 passed, 0 failed** (includes `gw_page_header_subtitle_gap_test.dart` and `gw_page_header_trailing_flush_test.dart`, both unchanged as the plan requires)
- `flutter test` excluding `test/account/`: **814 passed, 0 failed**

No `test/account/` file was added or run, per the constraint.

## The three open decisions - what shipped and why

**1. Bridge's button treatment.** Shipped as `GWButtonVariant.gradientOutline` (matching Receive), per the plan's default. This is **awaiting Jakub's walk** - sketch 165 never drew a third action, so two outline buttons beside one fill is legal under the CTA-weight rule but has not been judged in place. Flagged in the widget's own doc comment and again here.

**2. Button height.** Shipped at `GWButtonSize.md` (48px). `GWButton` has no 40px step; DECISION constraint 2 requires the 48px tap target (WCAG 2.5.5), so `md` is correct per the plan. Note for the walk: **only height is fixed at 48** - width is intrinsic to each label ("Swap", "Receive", "Bridge" are different widths), which is the necessary and correct consequence of converting three 48x48 icon-only squares into labelled buttons. The plan's behaviour bullet ("each action still measures 48px in both axes") is read here as describing the tap-target's *height* floor, not a literal width==48 constraint - a literal reading would be impossible to satisfy for a labelled button and contradicts the task's own instruction to add visible labels. `GWButtonSize.sm` (44px) remains the one-word fallback if the walk wants tighter.

**3. The stat rail's perRow ladder and the 6→5 tile-count hole.** **Measured, not guessed.** The old ladder (`6/3/2`) worked only because every step divided 6 exactly - every row was always full. 5's only divisors are 1 and 5, so no three-step ladder of 5/3/2 (or any other three sensible column counts) can guarantee a full last row the way 6/3/2 did; a `perRow`-driven single tile-width computation left the 2-of-3 and 1-of-2 tail rows short by roughly one tile-plus-gap width - directly reproducing the hole this task exists to remove.

The actual fix: tile width is now computed **per row**, from that row's own tile count (`(maxWidth - gap*(chunk.length-1)) / chunk.length`), not from the nominal `perRow`. This makes every row - full or partial - reach the rail's own right edge by construction, independent of whether the tile count happens to divide the column count. Pinned with a new test (`no rail row leaves a hole at its right edge, at any tested width`) that renders the actual page at 1400/900/768/600/360px and asserts every row's rightmost tile edge matches every other row's, within 1px. The ladder itself is `5/3/2` (mirroring the old `6/3/2` minus one column at the wide breakpoint); it is a target column count now, not a divisibility requirement.

## `CoinInfoCard._glyph`'s contrast table - not lost

Deleted along with the 22px glyph slot (Task 3), its measurement is worth keeping: five of the six original per-row glyph colours were raw constants tuned against the dark canvas and collapsed on the light well (1.25:1 / 1.63:1 / 1.72:1 / 2.19:1 against a 4.5:1 body floor); only `brandPrimaryOnSurface` (Network's colour) survived at 4.23:1. That measurement is what justified collapsing all six glyphs to one shared colour on 2026-07-28 - and change 8 on 2026-07-30 supersedes that conclusion by removing the glyphs outright, rather than disagreeing with it. The table itself is preserved verbatim in the doc comment above `CoinInfoCard`'s constructor.

## Plan assertions that proved false or needed correction

- **DECISION.md's file table says the footer is additive-only in `crypto_live_chart.dart`.** The plan itself (and this execution) confirms this is wrong: the footer mounts in `token_info_screen.dart`'s `_chartCard`, both because `CryptoLiveChart` has no `CoinGeckoMarketData` and because the ROADMAP scope fence keeps Phase 7 out of that file. Not touched.
- **`titleTrailing` has zero other production callers in `lib/`** - verified again during this execution (only `token_info_screen.dart`'s own removed call site). The parameter was **not** deleted from `gw_page_header.dart`, per the plan; both of its own tests (`gw_page_header_subtitle_gap_test.dart`, `gw_page_header_trailing_flush_test.dart`) still pass unchanged.
- **`test/tokens/coin_page_range_tile_test.dart` is tracked and passing**, not untracked as DECISION.md's file table originally claimed (the plan's own notes had already corrected this before I started). Its two original claims moved with the widget rather than being rewritten from scratch; two new tests were added for the ladder and the wide-layout height invariant, plus a second fixture near the high end of the day's range.
- **`coin_page_stat_rail_test.dart` and `coin_page_components_test.dart` both needed changes**, exactly as the plan's own notes flagged (DECISION.md's file table omitted both).

## Deviations from Plan

### Auto-fixed / judgment calls

**1. [Rule 3 - blocking] `_CoinActionRow` needed a `marketData` field the plan's field list omitted.** The plan's action text lists `selectedCoin, selectedWallet, selectedNetwork, isGnusBridgeEnabled, walletDetailsCubit` as the widget's fields, but explicitly requires the Swap button's `onPressed` body to stay byte-identical, and that body reads `marketData?.symbol` first. Added `marketData` as a sixth constructor field so the preselection logic (`marketData.symbol` before `selectedCoin.symbol`) could be preserved verbatim, per the plan's own instruction to keep it unchanged.
- **Found during:** Task 1
- **Files modified:** `lib/tokens/token_info_screen.dart`
- **Verification:** `coin_page_stat_rail_test.dart` passes; Swap's extra payload is unchanged from the pre-task code.

**2. [Rule 1 - test correctness] "Receive" drawer-title test needed an `AppBar`-scoped finder, not a `ResponsiveDrawer`-scoped one.** The plan's action text suggests scoping the post-tap assertion to "the drawer subtree," but `ResponsiveDrawer` is a static factory class, not a widget - `find.byType(ResponsiveDrawer)` does not compile. The drawer's title is rendered inside an `AppBar` (`responsive_drawer.dart`'s `_ResponsiveDrawerScaffold`), so the finder scopes to `find.byType(AppBar)` instead, which the `GWButton` (outside the drawer) cannot match.
- **Found during:** Task 1 test update
- **Files modified:** `test/tokens/coin_page_stat_rail_test.dart`
- **Verification:** test passes; the drawer-title finder returns exactly one widget.

**3. [Rule 3 - blocking, test-scope only] Narrow-width (360px) render exposed two pre-existing, out-of-scope `RenderFlex` overflows.** The new "no rail row leaves a hole" test is the first test in this file to render the full `TokenInfoScreen` at 360px. Doing so surfaces two unrelated overflows: `CoinConvertCard`'s "Token price" row (untouched by this plan; DECISION.md and the plan both forbid touching Convert), and `CryptoLiveChart`'s own internal no-network fallback (`lib/chart/crypto_live_chart.dart`, off-limits per the ROADMAP scope fence). Neither is fixed - both are logged in `deferred-items.md` - and the test drains them via `tester.takeException()` so it only fails on the rail's own layout, which is what it is scoped to check.
- **Found during:** Task 2 test update
- **Files modified:** `test/tokens/coin_page_range_tile_test.dart` (test only); `.planning/phases/07-token-screens/deferred-items.md` (new, documents the finding)
- **Verification:** `flutter test test/tokens/coin_page_range_tile_test.dart` passes, 5/5, with the drain applied only inside this one test's loop - it does not touch the assertions themselves, which still check the rail's own geometry at all five widths.

---

**Total deviations:** 3 (1 blocking/field-completeness, 1 test-correctness, 1 out-of-scope discovery logged and deferred)
**Impact on plan:** All three are necessary for correctness or test validity. No scope creep - Convert and the chart file remain untouched.

## Known Stubs

None.

## Threat Flags

None - no new network endpoints, auth paths, or trust-boundary changes. All edits are presentational (button chrome, layout, icon removal).

## Task 4 - NOT PERFORMED

`checkpoint:human-verify` (gate: `blocking`) - the walk of the coin page in dark AND light appearances. This requires a live running app and a human; it was explicitly excluded from this session's scope. The nine numbered verification items in the plan (back link, subtitle, actions, Bridge, button height, stat rail, chart footer, Info, Convert) remain to be walked. Items 4 (Bridge) and 5 (button height) are decisions awaiting Jakub's live judgment, not yet settled - see "The three open decisions" above for what shipped and why.

## Next Phase Readiness

Tasks 1-3 are implemented, verified by the full gate suite above, and left uncommitted. Whoever runs the checkpoint walk next should:
1. `pkill` any stale app instance first (Hive lock).
2. Open a coin page from Markets (not the wallet's Assets list, which reaches the no-data route) in both appearances.
3. Confirm or redirect the Bridge treatment and the 48px button height.
4. Fold sketch 165 into `.planning/ROADMAP.md` and add its row to `.planning/sketches/MANIFEST.md` - both were deliberately left for the executor, per the plan's own notes.

---
*Phase: 07-token-screens*
*Completed: 2026-07-31*
