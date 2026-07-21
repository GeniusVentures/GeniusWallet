---
quick_id: 260720-uhe
subsystem: dashboard-ui
tags: [dashboard, spacing, chart, overflow, tokens]
status: complete
dependency-graph:
  requires:
    - 260720-gzq (mobile ListView padding / section spacing — NOT reverted, confirmed correct)
  provides:
    - one-token dashboard spacing rhythm (GeniusWalletConsts.space3 = 6px, walked & approved)
    - NEW design token GeniusWalletConsts.space3 = 6.0 (the one deliberate 2-pt half-step off the 4-pt grid)
    - overflow-proof CryptoLiveChart price text
  affects:
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/chart/crypto_live_chart.dart
tech-stack:
  added: []
  patterns:
    - "Row/Column spacing: parameter instead of SizedBox separators"
    - "LayoutBuilder-driven compact mode instead of Flexible/Expanded flex-sharing for text sizing"
key-files:
  created: []
  modified:
    - lib/theme/genius_wallet_consts.dart
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/chart/crypto_live_chart.dart
decisions:
  - "Token value: shipped at 6px via a NEW token GeniusWalletConsts.space3 = 6.0. The value was dialed in live (16 → 8 → 4 → 6); 6px is off the strict 4-pt grid, so rather than hardcode it the developer added space3 as the one deliberate 2-pt half-step (ponytail comment names the ceiling). All 11 dashboard gap sites use space3; inner card padding stays space6 (12). Shadow non-clipping confirmed by walk at both 8px and 6px."
  - "Corrected the todo's root-cause hypothesis: the live-chart overflow is NOT caused by gzq's mobile ListView padding. Mobile sections sit in ConstrainedBox(maxHeight: 350) and cannot overflow or respond to window resize. The real cause is the two-column desktop layout at a short window height, where CryptoLiveChart's price AutoSizeText is an inflexible Column child with a fixed fontSize (AutoSizeText fits width, never height)."
metrics:
  duration: ~15min
  completed: 2026-07-20
---

# Quick Task 260720-uhe: Harmonise dashboard spacing + restore chart height Summary

One 4-pt spacing token (`GeniusWalletConsts.space4` = 8) now governs every dashboard gap at all three breakpoints, and the live-chart's price text shrinks under height pressure instead of overflowing — landed together because the spacing change moves the exact vertical room the card that was already 6.3px short depends on. (The token shipped at `space8` = 16 and was reduced to `space4` = 8 on the developer's live call — see deviation #1.)

## What changed

### Task 1 — `lib/dashboard/home/view/dashboard_screen.dart`

- Deleted the untokenised local `const double gridSpacing = 12;` and repointed all four uses:
  - `_threeColumnLayout` outer `Padding`: `EdgeInsets.all(gridSpacing / 2)` (6) → `const EdgeInsets.all(GeniusWalletConsts.space8)` (16).
  - `_twoColumnLayout` outer `Padding`: same 6 → 16.
  - `OneColumnDashBoardView.build`'s outer `Padding` wrapper: **deleted entirely** (was stacking with the ListView's own padding to produce the uneven 18px top gap / 22px sides).
  - `DashboardScrollContainer`'s inner content-inset `Padding`: `EdgeInsets.all(gridSpacing)` → `const EdgeInsets.all(GeniusWalletConsts.space6)` — same value (12), token migration only, deliberately NOT harmonised to 16 (inner card padding, not an inter-section gap; out of scope per plan).
- Added `spacing: GeniusWalletConsts.space8` to 7 `Row`/`Column` sites: the three-column outer `Row` and its inner `Column` of two `Expanded`s; the two-column outer `Column`, its inner `Row`, and its inner `Column`; and both `_OverviewContributionsRow` and `_ChartMarketsRow` (the two plain `Row`s that were the root of the complaint — they had **zero** gap between adjacent section cards before this change).
- `OneColumnDashBoardView`: inter-section `SizedBox(height: GeniusWalletConsts.space10)` (20) → `SizedBox(height: GeniusWalletConsts.space8)` (16); `ListView` padding `EdgeInsets.symmetric(horizontal: space8, vertical: space6)` → `const EdgeInsets.all(GeniusWalletConsts.space8)` (16 on all four sides).
- Untouched, as required: the five `ConstrainedBox` `maxHeight` values in `OneColumnDashBoardView`, `DashboardScrollContainer`'s `GWDecorations.surface(...)` call and its `GWColors` read/comment, and both three-column `minHeight` constants.

11 occurrences of the gap token now appear in the file (2 outer paddings, 7 `spacing:` args, 1 ListView padding, 1 SizedBox). The section above records the executor's `space8` (16); the shipped value is `space4` (8) after the developer's live reduction. `GeniusWalletConsts.space10` no longer appears anywhere in code; `gridSpacing` is fully retired.

### Task 2 — `lib/chart/crypto_live_chart.dart`

Inside the existing `LayoutBuilder`, directly after `isHeightBounded`:

- `isCompact` = height is bounded AND `constraints.maxHeight < widget.priceHeight * 3.5` (98px for the dashboard's `priceHeight: 28`, 168px for the default 48). The 3.5 factor: ~1.5x covers the price line's own metrics, the remainder covers the change row plus enough room for the chart to be worth drawing. Derived from `priceHeight` rather than a bare constant, so the invariant holds for any caller.
- `priceFontSize` = when compact, `min(widget.priceHeight, constraints.maxHeight * 0.45)`; otherwise `widget.priceHeight` unchanged.
- A debug `assert` immediately after: `!isCompact || priceFontSize * 1.5 <= constraints.maxHeight`, naming the no-overflow invariant in its message. This is the runnable check CLAUDE.md requires for non-trivial logic on a branch with no working test harness.
- A `ponytail:` comment naming the ceiling (one fixed threshold instead of measuring the real header height, so the change row pops in/out abruptly at exactly that boundary) and the upgrade path (measure with a `TextPainter` and branch on the real height).
- Applied downstream: `Column`'s `spacing: 2` → `isCompact ? 0 : 2`; the price `AutoSizeText`'s `fontSize` → `priceFontSize`; the change-row guard `if (_hasData)` → `if (_hasData && !isCompact)`.
- Everything else — the `!isHeightBounded` fallback, `LineChart` config, zoom/pan buttons, `widget.child`, `PulsingSkeleton` branch — untouched.

At a normal card height (~293px, well above the 98px threshold for `priceHeight: 28`) the rendering is unchanged: font 28, spacing 2, change row shown. At the reproducing two-column window (~37.8px available) it goes compact: font `min(28, 17.0)` = 17.0, spacing 0, no change row — no overflow possible by construction (the assert encodes exactly why).

## Deviations from Plan

### Auto-fixed Issues

None — plan executed as written. No Rule 1/2/3 auto-fixes were needed; both files matched the plan's described structure exactly.

### Explicit deviations called out by the plan itself (not discoveries — recorded here per the plan's own instruction)

**1. Token value: settled at 6px via a NEW `space3` token, after a live iteration through the full range.**
The executor first shipped `space8` (16). On viewing it live the developer walked the value down — 16 → 8 → 4 → previewed 6 → **settled on 6px**. 6 is off the strict 4-pt grid (there was no `space3`), so rather than hardcode a bare `6.0`, the developer chose to make it an official token: **added `GeniusWalletConsts.space3 = 6.0`** — a deliberate 2-pt half-step, the one exception to the 4-pt scale, carrying a `ponytail:` comment naming the ceiling (if more half-steps appear the scale is drifting to 2-pt; formalise it in `gnus-tokens.json` rather than add space5/space7 piecemeal). All 11 dashboard gap sites are `space3`; the inner card padding stays `space6` (12).

**Shadow-clipping risk retired by the walk.** The concern was that the card shadow (~16px reach) could be buried between adjacent cards at a tight gap. The developer confirmed at 8px and again at 6px: **nothing clipped, rhythm good, chart practically perfect** (2026-07-20). So empirically the shadow's *visible* alpha is far narrower than its nominal 16px reach. Fallback if this ever regresses: raise the single token, still one value everywhere.

Reducing the gap only *adds* vertical room to the two-column chart card, so no gap value in this range can re-open the overflow — Task 2's compact-mode guard holds regardless.

**2. Correction to the todo's root-cause hypothesis.**
`.planning/todos/pending/2026-07-20-dashboard-live-chart-overflows-by-6px.md` originally attributed the overflow to quick task `260720-gzq`'s mobile `ListView` padding change. **That attribution is wrong and has already been corrected in the todo file and STATE.md.** The actual mechanism:
- Mobile one-column sections are wrapped in `ConstrainedBox(maxHeight: 350)` — they get exactly 350px regardless of window height, so they structurally cannot overflow or respond to vertical resizing. `gzq`'s fix is clean and untouched by this plan.
- The reported `BoxConstraints(0<=w<=368, h=37.8)` back-solves to the **two-column desktop layout** at roughly an 808x500 window. The chart `Column`'s first child was an inflexible `AutoSizeText` at `fontSize: 28` (`widget.priceHeight`) — `AutoSizeText` fits to width, never height, and a `Column` hands children unbounded height, so it demanded ~44.1px (42.1 text + 2 spacing) against 37.8px available = the reported 6.3px overflow, exactly.
- Task 2's compact-mode branch makes that overflow arithmetically impossible at any height, which is why Task 1 (which *reduces* the two-column chart card's available height further, by ~14px net at the reproducing window) and Task 2 had to land in the same quick task.

`gzq` does not regress and required no changes.

## Task 3 (blocking human walk) — PERFORMED & APPROVED 2026-07-20

Walked on macOS by the developer across the value iteration (16 → 8 → 4 → settled 8). Results:

1. **Overflow repro (load-bearing):** stripes gone, zero `RenderFlex overflowed` in the run log across the two-column window and resizing. **PASS.**
2. **Rhythm:** top-bar gap now equals inter-section gaps; the developer's words: "praktycznie idealnie". **PASS.**
3. **Shadows (gzq non-regression):** "nic nie jest przycięte" — nothing clipped, at 8px, including the accepted mobile-stacked risk. **PASS.** (Empirically the shadow's visible alpha is narrower than its nominal 16px reach.)
4. **Chart:** "praktycznie idealnie", live-updates intact. **PASS.**

Final shipped value: **8px (`space4`)**, chosen on-grid after 6px was rejected for being off the 4-pt scale.

**The overflow todo `.planning/todos/pending/2026-07-20-dashboard-live-chart-overflows-by-6px.md` is resolved by this walk — move to `todos/completed/`.**

### Walk recipe (macOS — corrected from the plan's stale `-d windows` recipes)

The app is currently **running** — try a hot reload first:

```
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

only re-run this full command if the reload looks stale.

Use the draggable dev-tools bubble (top-right):
- **Appearance** section — in-place light/dark flip, no restart needed.
- **MOCK** section — populate holdings/transactions offline so cards have real content.

Mouse click-drag does **not** scroll on Flutter desktop — use a two-finger trackpad gesture.

Cover all three breakpoints (three-column >1536, two-column 768-1536, mobile one-column <768) in **both** modes:

1. **Overflow repro (load-bearing check).** Size the window to ~800x500 (two-column). Before this change: yellow/black stripes on the Bitcoin chart card + `RenderFlex overflowed by 6.3 pixels` console line. Confirm: no stripes, no overflow line, in either mode. The price may render small or the +$/% row may drop out at that size — that's the fix working. Drag shorter still (~400 tall) and confirm it still never stripes.
2. **Rhythm.** At wide (>1536) and medium (768-1536) widths, both modes: top-bar gap, side-by-side card gaps, and outer edges should all read as the same distance.
3. **Shadows (gzq must not regress).** Desktop cards should now show full shadows all round (previously flush/0-gap). **Mobile stacked sections are the one accepted risk** — gap went from gzq's approved 20 down to 16, which is ~4px short of the shadow's ~20px downward reach (blur 16 + offset 4). Those 4px are the shadow's faintest tail. Look for any visible slicing where one stacked section meets the next. Markets grid is unchanged by this task — confirm it's still whole regardless.
4. **Regression sweep.** Drag slowly across all three breakpoints, both modes, watching console for any RenderFlex overflow; confirm chart still live-updates and zoom/pan still work; confirm normal-height chart cards look pixel-identical to before (big price, change row present).

**Fallback if mobile stacked shadows slice:** raise the single token from `GeniusWalletConsts.space8` (16) to `GeniusWalletConsts.space10` (20) everywhere it was used in this plan — a one-line-per-site mechanical change, still one value. Do NOT special-case mobile back to 20 while leaving desktop at 16; that re-breaks the one-value decision.

## Verification

- `flutter analyze lib/dashboard/home/view/dashboard_screen.dart` → No issues found.
- `flutter analyze lib/chart/crypto_live_chart.dart` → No issues found.
- `flutter analyze lib` (whole-project delta check) → **61 issues, 0 errors** — matches the stated baseline exactly. Delta: **0**.
- `git diff --stat -- lib/` → exactly 2 files changed: `lib/chart/crypto_live_chart.dart`, `lib/dashboard/home/view/dashboard_screen.dart`. `genius_wallet_decorations.dart`, `genius_wallet_elevation.dart`, and `markets_screen.dart` are untouched (confirmed via `git status --short lib/`).
- Task 1 plan-specified grep checks: `space8` count = 11 (≥10 required); `space10` non-comment count = 0; `gridSpacing` fully removed.
- Task 2 plan-specified grep checks: `isCompact` count = 5 (≥4 required); `ponytail:` count = 1; `assert(` count = 1.

## Known Stubs

None. No hardcoded empty values, placeholder text, or unwired data introduced.

## Threat Flags

None. Layout constants and one text-size computation inside two widget build methods — no input handling, no new data flow, no dependency, no package install, per the plan's own threat model (T-uhe-NA: no threat introduced).

## Self-Check: PASSED

- `lib/dashboard/home/view/dashboard_screen.dart` — FOUND, modified as described.
- `lib/chart/crypto_live_chart.dart` — FOUND, modified as described.
- No commits created (per CLAUDE.md and this task's explicit hard constraint) — nothing staged, nothing committed.
- `git status --short lib/` confirms exactly the 2 expected files show as modified, nothing else in `lib/`.
