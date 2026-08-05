---
quick_id: 260721-dws
subsystem: dashboard-ui
tags: [dashboard, chart, fl_chart, dashboard-header, tokens, AA]
status: awaiting-verification
dependency-graph:
  requires:
    - 260720-uhe (compact-mode overflow guard in CryptoLiveChart — preserved, not touched)
  provides:
    - "Bitcoin Chart card re-skinned to sketch 006 A→ (coin identity + top-right visual-only timeframe segment, cyan-glow hero, %-pill-only, mint edge chart, styled hover crosshair/tooltip)"
  affects:
    - lib/chart/crypto_live_chart.dart
    - lib/dashboard/home/view/dashboard_screen.dart
tech-stack:
  added: []
  patterns:
    - "Trend color split from chart color: gw.statusSuccess/statusError tints only the % pill and hover-tooltip %; the area chart itself is always brandSecondary (mint), independent of up/down"
    - "Layout-neutral glow overlay: Positioned(width/height) + IgnorePointer inside a Stack behind an AutoSizeText — RenderStack treats width/height-only Positioned children as positioned (not counted for sizing), so the glow cannot re-open a Column overflow"
    - "Private per-file StatefulWidget for a visual-only control (_TimeframeSegment) instead of a new shared file/package, per the plan's scope fence"
key-files:
  created:
    - .planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md
  modified:
    - lib/chart/crypto_live_chart.dart
    - lib/dashboard/home/view/dashboard_screen.dart
decisions:
  - "Timeframe segment ships VISUAL-ONLY this task (user decision 2026-07-21, per plan requirements) — tapping a tab only moves the selected chip; CryptoLiveChart's plotted series and zoom/pan are unchanged. Wiring real 1H/1D/1W/1M/1Y ranges is captured in the new follow-up todo."
  - "Zoom/pan was deliberately KEPT in CryptoLiveChart even though A→'s visual language conceptually replaces it with timeframe tabs — deleting working behaviour violates the port's re-skin-never-restructure rule. The follow-up todo notes a later task must decide whether zoom/pan is redundant once ranges are wired."
  - "fl_chart 1.2.0's LineTouchTooltipData does expose tooltipBorder (BorderSide) in addition to getTooltipColor/tooltipBorderRadius, so the tooltip bubble got a real gw.borderSubtle hairline border, not just fill+radius. The remaining ponytail gap is narrower than the plan anticipated: no first-class drop-shadow (only color+border+radius), not 'no border'."
  - "Selected-timeframe label AA fallback implemented via GWAppearance.isLight (static, no context needed) rather than Theme.of(context).brightness, matching the existing pattern in genius_wallet_elevation.dart."
metrics:
  duration: ~25min
  completed: 2026-07-21
---

# Quick Task 260721-dws: Bitcoin Chart section re-skin (A→) Summary

Re-skinned the dashboard's Bitcoin Chart card to sketch 006's chosen A→ direction: a coin-identity header (₿ · Bitcoin · BTC) balanced against a visual-only 1H·1D·1W·1M·1Y timeframe segment, a centered hero price over a soft cyan glow, a single AA-safe %-pill (USD delta dropped), an edge-to-edge mint area chart, and a styled hover crosshair + tooltip — all existing chart behaviour (live stream, zoom/pan, compact-mode overflow guard, loading skeleton, currency formatting) preserved byte-for-byte in behaviour. **Tasks 1 and 2 (the two `auto` tasks) are complete; Task 3, the blocking human walk, is OUTSTANDING** — this quick task cannot be marked fully complete until that walk is performed and approved.

## What changed

### Task 1 — `lib/chart/crypto_live_chart.dart`

- Added `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` at the top of `build`.
- Split trend from chart color: `trendColor = isUptrend ? gw.statusSuccess : gw.statusError` (replaces raw `Colors.greenAccent`/`Colors.redAccent`); `mintColor = GeniusWalletColors.brandSecondary` is now the chart's fixed color, independent of trend.
- Hero price wrapped in a `Stack` with a `Positioned(width: 240, height: 70)` → `IgnorePointer` → `ImageFiltered(blur sigma 8)` → `DecoratedBox` radial gradient (`brandPrimary` @ 22% → transparent) sitting behind the `AutoSizeText`. Because the glow `Positioned` sets only `width`/`height` (no `top`/`left`/`right`/`bottom`), `RenderStack.isPositioned` still returns `true` for it (Flutter's `isPositioned` getter checks `width`/`height` too, not just the four offsets) — so it does NOT count toward the Stack's intrinsic size, keeping the whole thing layout-neutral and unable to re-open the 260720-uhe compact overflow. Price text also gained `FontFeature.tabularFigures()`.
- Change row reduced to the % pill only — the absolute USD `Text` ("+$…") is deleted. Pill fill = `trendColor.withValues(alpha: 0.2)`, radius `GeniusWalletConsts.radiusXs`, label = `trendColor`; still gated by `if (_hasData && !isCompact)`.
- `LineChartBarData`: `color: mintColor`, `barWidth: 2.4`, `belowBarData` gradient → `mintColor` @ 30% → transparent.
- `getTouchedSpotIndicator`: `FlLine` now solid (`gw.borderStrong`, `strokeWidth: 1`, no `dashArray`); `FlDotData` now shows a glowing mint dot via `getDotPainter` → `FlDotCirclePainter(radius: 5, color: mintColor, strokeWidth: 4, strokeColor: mintColor.withValues(alpha: 0.26))`.
- `LineTouchTooltipData`: `getTooltipColor: (_) => gw.surfaceElevated`, `tooltipBorderRadius: BorderRadius.circular(10)`, `tooltipBorder: BorderSide(color: gw.borderSubtle)`, `fitInsideVertically: true` (in addition to the existing `fitInsideHorizontally: true`). `getTooltipItems` now returns a two-part `LineTooltipItem`: main text = `_formatTime` (11px, `gw.textSecondary`) then a `TextSpan` child for the price (bold, `gw.textPrimary`, 14px) and a second `TextSpan` for that point's % change, colored `gw.statusSuccess`/`gw.statusError` via a new `_percentAt(price)` helper computed against the same `_oldestPrice` the hero price already uses — no new data source.
- New import: `dart:ui` (for `ImageFilter`, following the exact precedent in `lib/components/cards/gw_gradient_border_card.dart`), plus `genius_wallet_colors.dart`, `genius_wallet_consts.dart`, `gw_colors.dart`.
- Preserved verbatim: `_fetchHistoricalData`/`_startLiveUpdates`/`_addNewPricePoint`, the `LayoutBuilder` `isHeightBounded`/`isCompact`/`priceFontSize`/`assert` compact guard, the `!isHeightBounded` `SizedBox` fallback, the `PulsingSkeleton` loading branch, `_zoomIn/_zoomOut/_panLeft/_panRight` and their `IconButton` row, `_onHover`/`_onHoverExit`, and the `NumberFormat` currency formatting.

### Task 2 — `lib/dashboard/home/view/dashboard_screen.dart`

- `ChartDashboardView` now renders `const _ChartSectionHeader()` in place of `GWSectionTitle(title: 'Bitcoin Chart')`. The `GWSectionTitle` import was removed (Rule 1 — it became unused; kept `flutter analyze` clean).
- `_ChartSectionHeader` (new private `StatelessWidget`) reproduces `GWSectionTitle`'s exact geometry: `Padding(EdgeInsets.fromLTRB(space4, 2, space4, space8))` + `ConstrainedBox(minHeight: 44)` + `Row(spaceBetween, center)` with `[_CoinIdentity(), _TimeframeSegment()]` — so the chart card's title→body rhythm still matches Assets/Markets/Transactions.
- `_CoinIdentity` (new private `StatelessWidget`): a 30px circular avatar (`#F7931A` Bitcoin orange, white bold ₿ glyph — canonical brand mark, WCAG logo exemption applies, marked with a `ponytail:` comment naming the hardcoded-to-bitcoin ceiling) + `space3` gap + a column of "Bitcoin" (bold, `gw.textPrimary`, 15px, letterSpacing -0.2) and "BTC" (`gw.textSecondary`, 11px, letterSpacing +0.5).
- `_TimeframeSegment` (new private `StatefulWidget`, default selected index 1 = "1D") + `_TimeframeTab` (new private `StatelessWidget`): a pill-radius `gw.surfaceMenu` container with 3px padding holding 5 tappable pills (1H·1D·1W·1M·1Y). The selected chip = `gw.surfaceElevated` fill + `GeniusWalletElevation.card` shadow; unselected label = `gw.textSecondary`. Selected label color: `GWAppearance.isLight ? gw.textPrimary : GeniusWalletColors.brandPrimary` (both `brandPrimary`/`brandPrimaryStrong` fail AA on the light-mode elevated chip). Tapping a tab only calls `setState` on its own private index — the series in `CryptoLiveChart` below is untouched. `ponytail:` comment on the widget names this ceiling and points at the new follow-up todo.
- `Expanded(child: CryptoLiveChart(coinGeckoCoinId: 'bitcoin', tokenSymbol: 'btc', priceHeight: 28))` kept exactly as-is.
- New imports: `genius_wallet_colors.dart`, `genius_wallet_elevation.dart`, `gw_appearance.dart` (all already used elsewhere in the codebase for the same purposes).
- Captured the follow-up: `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md` records that the timeframe segment ships visual-only, that wiring real ranges is a data change (out of scope for a re-skin), and that a later task must decide whether the kept zoom/pan row becomes redundant once ranges are wired.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed the now-unused `GWSectionTitle` import from `dashboard_screen.dart`**
- **Found during:** Task 2
- **Issue:** After replacing `GWSectionTitle(title: 'Bitcoin Chart')` with `_ChartSectionHeader()`, the `package:genius_wallet/components/cards/gw_section_title.dart` import became unused, which `flutter analyze` would have flagged as a new issue (an `unused_import` lint) — moving the baseline from 61 to 62.
- **Fix:** Deleted the import line. A stray dartdoc `[GWSectionTitle]` bracket reference in `_ChartSectionHeader`'s doc comment was also de-bracketed to plain text, since the symbol is no longer imported/resolvable in this file.
- **Files modified:** lib/dashboard/home/view/dashboard_screen.dart
- **Verification:** `flutter analyze lib` → 61 issues, 0 errors (delta 0, confirmed below)

---

**Total deviations:** 1 auto-fixed (Rule 1, unused-import cleanup)
**Impact on plan:** No scope creep — a mechanical consequence of the header swap the plan explicitly required.

## Issues Encountered

None.

## Verification

- `flutter analyze lib/chart/crypto_live_chart.dart` → No issues found.
- `flutter analyze lib` (whole-project delta check) → **61 issues, 0 errors** — matches the stated baseline exactly. Delta: **0 new errors, 0 new issues.**
- `git status --short` confirms exactly the two declared lib files (`lib/chart/crypto_live_chart.dart`, `lib/dashboard/home/view/dashboard_screen.dart`) plus the new todo `.md` changed by this task — no other files touched, no commit created (per CLAUDE.md's "Do not create commits" and this task's explicit hard constraint), no broad `git add`.
- `flutter test` was NOT run — it does not compile on this branch (documented project-wide blocker); `flutter analyze` is a gate, not evidence.

## Known Stubs

None. The timeframe segment's non-functional state is a documented, plan-mandated scope decision (visual-only this task), not a stub masking an unfinished feature — it is fully described in the new follow-up todo and in this SUMMARY's Decisions.

## Threat Flags

None. No new network endpoints, auth paths, or trust-boundary changes — purely presentational re-skin of an existing local price-chart widget and its header.

## Self-Check: PASSED

- `lib/chart/crypto_live_chart.dart` — FOUND, modified as described.
- `lib/dashboard/home/view/dashboard_screen.dart` — FOUND, modified as described.
- `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md` — FOUND, created as described.
- No commits created — nothing staged, nothing committed (verified via `git status --short`).

## Outstanding — Task 3 (blocking human walk), NOT performed

Task 3 is `type="checkpoint:human-verify"` with `autonomous: false` — per this execution's explicit scope, it was NOT attempted and is NOT marked complete. The developer must run the walk before this quick task can be considered done.

**Recipe (macOS):**

```
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

The app may already be running in a parallel session — a black window at startup is a stale second instance holding the Hive lock (known, documented issue), not a bug in this change. Use the dev-tools bubble: **Appearance** to flip light/dark in place, **MOCK** to populate data offline. The Bitcoin Chart card is the chart cell (bottom-left in the 3-column dashboard; top-left-ish cell in 2-column).

Check, in **both** light and dark:

1. Header: round ₿ coin mark + "Bitcoin" bold + "BTC" muted on the LEFT; a 1H·1D·1W·1M·1Y segment pushed to the RIGHT, one row, aligned like the Assets/Markets/Transactions titles.
2. Tap the timeframe tabs — the selected chip visibly moves; the plotted series does NOT change (intentional this task).
3. Centered price with a soft cyan glow behind it; a SINGLE green/red % pill below it and NO "+$…" USD delta anywhere.
4. The area chart is mint, edge-to-edge, mint→transparent fill.
5. Hover the chart with the mouse — a vertical crosshair snaps to the line, a mint dot sits on the curve, and a tooltip shows that point's date/time + price + % change, follows the cursor, and flips/clamps near edges.
6. Zoom/pan buttons still work.
7. Shrink to the two-column breakpoint (~800×500) — NO RenderFlex overflow stripes (the 260720-uhe guard still holds).

If everything reads correctly, mark Task 3 approved and this quick task complete; STATE.md and the quick-tasks table have NOT yet been updated to reflect completion, pending that approval.
