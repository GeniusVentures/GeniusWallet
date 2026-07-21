---
quick_id: 260720-uhe
type: execute
wave: 1
depends_on: [260720-gzq]
files_modified:
  - lib/dashboard/home/view/dashboard_screen.dart
  - lib/chart/crypto_live_chart.dart
autonomous: false
requirements:
  - todo:2026-07-20-dashboard-live-chart-overflows-by-6px
  - user-decision:harmonise-dashboard-section-spacing-to-one-4pt-token

must_haves:
  truths:
    - "Every gap the user reads as 'space between dashboard sections' — under the top bar, between side-by-side cards, between stacked cards, and at the outer edges — is the SAME value, GeniusWalletConsts.space8 (16), at all three breakpoints."
    - "The dashboard live-chart card never paints a RenderFlex overflow stripe at ANY window size, including a deliberately short two-column window (~800x500) that reproduced the 6.3px overflow before this change."
    - "No content is silently clipped in release: the chart's price text shrinks under height pressure instead of overflowing its box."
    - "gzq does not regress: markets grid, mobile one-column dashboard, and desktop dashboard cards all still render their full soft card shadow, in light AND dark."
    - "Only two files change; GWDecorations.surface and GeniusWalletElevation.card are byte-identical."
  artifacts:
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/chart/crypto_live_chart.dart
  key_links:
    - "Inter-card gap is the ONLY room GeniusWalletElevation.card's shadow (blurRadius 16, offset (0,4)) has before a neighbour's opaque surface fill covers it — 16 clears the 16px horizontal reach exactly. Below 16 re-opens gzq."
    - "Every pixel of vertical spacing added to the desktop layouts is taken from the chart card's Expanded share — spacing and chart height are the same arithmetic, which is why they ship together."
    - "CryptoLiveChart's price AutoSizeText is an INFLEXIBLE Column child with a fixed fontSize; it is the sole source of the overflow. Capping it as a fraction of the available height is what makes overflow arithmetically impossible."
---

<objective>
Land ONE spacing rhythm across the dashboard (a single 4-pt token for the top-bar gap, the inter-section gaps, and the outer edges) AND make the live-chart card structurally incapable of overflowing. These are one change: the spacing pass takes vertical room from exactly the card that is already 6.3px short, so landing either alone leaves nobody able to attribute the result.

Purpose: the rhythm currently reads uneven because desktop section cards sit at a **0px** gap (both `_OverviewContributionsRow` and `_ChartMarketsRow` are plain `Row`s with no `spacing:`) while the mobile top gap is 18px — and the chart card silently clips content in release builds.
Output: two files touched, token-based spacing throughout, `gridSpacing` retired, and a chart that shrinks its price text instead of overflowing.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/todos/pending/2026-07-20-dashboard-live-chart-overflows-by-6px.md
@.planning/quick/260720-gzq-fix-clipped-surface-card-shadows-on-the-/260720-gzq-PLAN.md
@lib/dashboard/home/view/dashboard_screen.dart
@lib/chart/crypto_live_chart.dart
@lib/theme/genius_wallet_consts.dart

# ---------------------------------------------------------------------------
# TOKEN CHOICE — 16 (space8), NOT the 8 that was shown. Deviation is explicit.
# ---------------------------------------------------------------------------
# The user approved "one value from the 4-pt scale", with 8 as the shape shown and
# explicit permission to pick a neighbouring token if the arithmetic forces it.
# It does:
#
#   GeniusWalletElevation.card = blurRadius 16, offset (0,4).
#   Horizontal shadow reach ~16px. Downward reach ~20px (blur 16 + offset 4).
#
# The gap between two cards is the ONLY room that shadow has before the neighbour's
# OPAQUE surface fill covers it. An 8px gap buries half the shadow — that is
# precisely the bug quick task gzq exists to fix, and gzq's must_haves are still
# binding. 16 is the SMALLEST 4-pt token that clears the horizontal reach exactly.
#
# What 16 does to each measured number:
#   desktop outer edge / top-bar gap   6 -> 16   (was too tight, and 0 shadow room)
#   desktop card-to-card gap           0 -> 16   (the actual complaint; 0 today)
#   mobile top gap (6 outer + 12 list) 18 -> 16  ("slightly too large" -> even)
#   mobile side clearance (6 + 16)     22 -> 16  (still == the 16px reach)
#   mobile inter-section gap           20 -> 16  (THE ONE RISK — see below)
#
# ACCEPTED RISK, and the walk is the arbiter: mobile stacked sections drop from
# gzq's approved 20 to 16, which is 4px short of the ~20px DOWNWARD reach. Those
# outer 4px are the shadow's faintest tail (a few percent of a 0x59 / 0x1F base
# alpha). If the walk shows ANY visible slicing between stacked mobile sections,
# the fallback is mechanical: raise the single token to GeniusWalletConsts.space10
# (20) everywhere — still one value, still harmonised, just looser. Do NOT fix it
# by special-casing mobile back to 20; that re-breaks the one-value decision.
#
# ---------------------------------------------------------------------------
# CHART ARITHMETIC — the coupling, stated up front
# ---------------------------------------------------------------------------
# The reported failure is NOT in the mobile layout, despite the todo's hypothesis.
# Mobile sections are wrapped in ConstrainedBox(maxHeight: 350), so the chart card
# there always gets exactly 350px no matter the window height — it cannot overflow,
# and "enlarging the window vertically fixes it" would be impossible. Back-solving
# the reported constraint BoxConstraints(0<=w<=368, h=37.8) instead lands on the
# TWO-COLUMN desktop layout at roughly an 808x500 window:
#   width : (808 - 12 outer) / 2 - 24 card padding = 368   [matches]
#   height: (500 - 12 outer - 300 overview) / 2 - 24 padding - ~33 title = 37.8
# So gzq's ListView padding is NOT the cause. The cause is the Expanded-driven
# desktop column at a short window height. Record this correction in the SUMMARY.
#
# Why 37.8 overflows by 6.3: the chart Column's FIRST child is an inflexible
# AutoSizeText at fontSize 28. AutoSizeText shrinks to fit WIDTH, never height, and
# a Column hands its children unbounded height. 28 * ~1.5 line metrics = 42.1, plus
# the Column's spacing: 2 = 44.1. 44.1 - 37.8 = 6.3. Exactly the reported number.
#
# This plan's spacing pass makes that WORSE before Task 2 fixes it. In two-column at
# the same window: +20px consumed by the outer padding (6->16 on both edges), +16 by
# the new gap under the overview row, +16 by the new gap between chart and markets.
# The chart card is one of two Expandeds, so it loses ~26px -> ~11.8px of content
# box -> a ~32px overflow if Task 1 shipped alone. Task 2 makes overflow impossible
# at ANY height, so the two tasks MUST land together.
#
# ---------------------------------------------------------------------------
# HARD CONSTRAINTS
# ---------------------------------------------------------------------------
#   - Do NOT edit GWDecorations.surface or GeniusWalletElevation.card (shared).
#   - Do NOT change the markets GridView in markets_screen.dart (gzq owns it).
#   - Do NOT change DashboardScrollContainer's INNER card padding value (12).
#     Inner padding is content inset, not an inter-section gap. Out of scope.
#   - Do NOT change card content, tap wiring, or appearance-toggle wiring.
#   - No hardcoded EdgeInsets numbers — GeniusWalletConsts tokens only.
#   - Per CLAUDE.md: mark intentional simplifications with a `ponytail:` comment
#     naming the ceiling and the upgrade path.
#
# ENVIRONMENT
#   macOS. A debug build is ALREADY RUNNING — prefer hot reload, do not rebuild.
#   `flutter test` does NOT compile on this branch. `flutter analyze` is a GATE,
#   not evidence: baseline ~409 issues / 0 errors — report the DELTA only.
#   CLAUDE.md: DO NOT CREATE COMMITS. Write files only; the user commits separately.
#   Never `git add -A` / `git add .` / `git commit -a` (six skip-worktree files
#   carry the developer's personal Apple signing).
</context>

<tasks>

<task type="auto">
  <name>Task 1: Harmonise every dashboard gap to GeniusWalletConsts.space8 (16) and retire the untokenised local const</name>
  <files>lib/dashboard/home/view/dashboard_screen.dart</files>
  <action>
One value — `GeniusWalletConsts.space8` (16) — for every gap the user reads as space between sections, at all three breakpoints. The file already imports `genius_wallet_consts.dart`. `Row`/`Column` both accept `spacing:` on this Flutter version (the codebase already uses it in `crypto_live_chart.dart`), so use that rather than inserting `SizedBox` separators.

Delete the untokenised top-level `const double gridSpacing = 12;` at line 24 and repoint all four of its uses. It is referenced nowhere outside this file (verified). Deletion over addition, and the project rule forbids raw spacing literals.

`_threeColumnLayout` (~:98-144):
- Outer `Padding`: `EdgeInsets.all(gridSpacing / 2)` (6) -> `const EdgeInsets.all(GeniusWalletConsts.space8)` (16).
- The outer `Row` (left column + `TransactionsDashboardView`): add `spacing: GeniusWalletConsts.space8`.
- The inner `Column` holding the two flex-45 / flex-55 `Expanded`s: add `spacing: GeniusWalletConsts.space8`.

`_twoColumnLayout` (~:146-173):
- Outer `Padding`: same 6 -> `const EdgeInsets.all(GeniusWalletConsts.space8)`.
- The outer `Column` (overview `ConstrainedBox` + `Expanded`): add `spacing: GeniusWalletConsts.space8`.
- The inner `Row` (chart/markets column + transactions): add `spacing: GeniusWalletConsts.space8`.
- The inner `Column` (chart `Expanded` above markets `Expanded`): add `spacing: GeniusWalletConsts.space8`.
- These sit inside a `const Expanded(child: Row(...))`. The token is a compile-time const double, so the `const` stays valid — keep it.

`_OverviewContributionsRow` (~:176-191) and `_ChartMarketsRow` (~:193-205):
- Add `spacing: GeniusWalletConsts.space8` to each `Row`. These two are the root of the complaint — they are plain `Row`s today, so adjacent section cards touch at a 0px gap and each card's shadow is fully covered by its neighbour's opaque fill.

`OneColumnDashBoardView.build` (~:219-262):
- DELETE the outer `Padding(padding: const EdgeInsets.all(gridSpacing / 2))` wrapper entirely and return the `RefreshIndicator` directly. Its 6px was stacking with the ListView padding to produce the uneven 18px top gap and 22px sides.
- `ListView` padding: `EdgeInsets.symmetric(horizontal: space8, vertical: space6)` -> `const EdgeInsets.all(GeniusWalletConsts.space8)` (16 on all four sides).
- Inter-section `spacing` const: `SizedBox(height: GeniusWalletConsts.space10)` (20) -> `SizedBox(height: GeniusWalletConsts.space8)` (16).
- Leave the five `ConstrainedBox` sections and their `maxHeight` values EXACTLY as they are. Those caps are what make the mobile chart immune to the overflow, and changing them would move a variable this plan needs held still.

`DashboardScrollContainer` (~:264-286):
- `EdgeInsets.all(gridSpacing)` -> `EdgeInsets.all(GeniusWalletConsts.space6)`. Same value (12), token migration only — this is the card's inner content inset, deliberately NOT harmonised to 16.
- Leave the `GWColors` read, its explanatory comment, and `GWDecorations.surface(...)` untouched.
  </action>
  <verify>
    <automated>flutter analyze lib/dashboard/home/view/dashboard_screen.dart && test "$(grep -c 'GeniusWalletConsts.space8' lib/dashboard/home/view/dashboard_screen.dart)" -ge 10 && test "$(grep -v '^\s*//' lib/dashboard/home/view/dashboard_screen.dart | grep -c 'GeniusWalletConsts.space10')" -eq 0</automated>
  </verify>
  <done>The single token appears at 10+ sites (2 outer paddings, 6 `spacing:` arguments, 1 ListView padding, 1 SizedBox); the 20px token no longer appears in code; the local `12` const is gone and its four uses are repointed; the mobile outer `Padding` wrapper is deleted; the five `ConstrainedBox` maxHeights, `DashboardScrollContainer`'s decoration, and the inner card padding VALUE (12) are unchanged; `flutter analyze` reports 0 errors and no new warnings vs baseline.</done>
</task>

<task type="auto">
  <name>Task 2: Make the live chart shrink its price text under height pressure so RenderFlex overflow is arithmetically impossible</name>
  <files>lib/chart/crypto_live_chart.dart</files>
  <action>
The overflow source is the FIRST child of the `Column` at ~:206: an inflexible `AutoSizeText` with a hard `fontSize: widget.priceHeight`. AutoSizeText fits to width, never height, and a Column gives children unbounded height — so at fontSize 28 it demands ~42px however little room exists. Cap it as a FRACTION of the available height and the Column can no longer exceed its box.

Do NOT reach for `Flexible`/`Expanded` on the price text: it would then share the flex pool with the chart's own `Expanded` and get a proportional slice at every height, shrinking the price on large cards and leaving dead space. The existing `LayoutBuilder` already knows the real number — branch on it.

Inside the `LayoutBuilder` builder (~:203), directly after the existing `isHeightBounded` line, add:

- A compact threshold derived from `widget.priceHeight`, not a bare magic number: a factor of 3.5 (so 98px for the dashboard's `priceHeight: 28`, 168px for the default 48). Rationale to put in the comment: ~1.5x covers the price line's own metrics and the remainder covers the change row plus enough left over for the chart to be worth drawing. Deriving it from `priceHeight` keeps the invariant true for any caller instead of only the two current ones.
- `isCompact` = height is bounded AND `constraints.maxHeight` is below that threshold.
- `priceFontSize` = when compact, `min(widget.priceHeight, constraints.maxHeight * 0.45)`; otherwise `widget.priceHeight`. `min` is already available from the existing `dart:math` import.
- Immediately after computing it, the runnable check CLAUDE.md requires (there is no test harness on this branch, and an assert fires in debug exactly when the logic breaks):
  an `assert` stating that when compact, `priceFontSize * 1.5` is less than or equal to `constraints.maxHeight`, with a message naming the invariant. 0.45 x 1.5 = 0.675, so it holds with margin for any font metrics up to 1.5.
- A `ponytail:` comment naming the ceiling — one threshold instead of measuring the header, so the change row pops in/out at exactly that height — and the upgrade path: measure the header with a `TextPainter` and branch on the real height.

Then apply it in `chartContent`:
- `spacing: 2` -> compact yields 0, otherwise 2.
- The price `AutoSizeText`'s `style` uses `priceFontSize` instead of `widget.priceHeight`.
- The change `Row` guard `if (_hasData)` -> also require NOT compact, so the +$/% row drops out when there is no room for it. Its chip has its own vertical padding and is the second-largest inflexible block.

Leave everything else exactly as-is: the `!isHeightBounded` fallback that gives an unbounded chart `maxWidth * 0.6`, the `LineChart` config, the zoom/pan `IconButton` row, `widget.child`, and the `PulsingSkeleton` loading branch.

Sanity numbers to expect after the change, at the reproducing two-column window: available 37.8 -> compact -> font `min(28, 17.0)` = 17.0 -> text ~25.5px, spacing 0, no change row, `Expanded` skeleton absorbs the remaining ~12px. No overflow. At a normal card height of ~293 -> not compact -> font 28, change row present, identical to today's rendering.
  </action>
  <verify>
    <automated>flutter analyze lib/chart/crypto_live_chart.dart && test "$(grep -c 'isCompact' lib/chart/crypto_live_chart.dart)" -ge 4 && test "$(grep -c 'ponytail:' lib/chart/crypto_live_chart.dart)" -ge 1 && test "$(grep -c 'assert(' lib/chart/crypto_live_chart.dart)" -ge 1</automated>
  </verify>
  <done>The compact branch exists and is read at 4+ sites (threshold, font size, Column spacing, change-row guard); the debug `assert` encodes the no-overflow invariant; a `ponytail:` comment names the threshold ceiling and the TextPainter upgrade path; at a normal card height the rendering is byte-for-byte the same as today (font 28, spacing 2, change row shown); `flutter analyze` reports 0 errors and no new warnings vs baseline.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
One spacing rhythm plus a chart that cannot overflow — deliberately landed together, because the spacing pass takes vertical room from the card that was already short.

Spacing, all at `GeniusWalletConsts.space8` (16): desktop outer/top gap 6 -> 16; desktop card-to-card gaps 0 -> 16 (they were plain `Row`s with no gap at all — this is the complaint's root); mobile top gap 18 -> 16, sides 22 -> 16, inter-section 20 -> 16. The untokenised local `12` const is retired.

**Deviation from the 8px shape you were shown, on purpose:** the card shadow reaches 16px sideways, so an 8px gap would bury half of it under the neighbouring card and re-open the exact clipping bug quick task `gzq` fixed. 16 is the smallest 4-pt token that clears it. Still one value everywhere.

Chart: the price text now shrinks when the card is short instead of overflowing. Also a correction worth knowing — the overflow was NOT in the mobile layout as the todo assumed (mobile sections are height-capped at 350px and cannot overflow); it is the two-column desktop layout at a short window, so `gzq` did not cause it.
  </what-built>
  <how-to-verify>
The app is already running. Hot reload first; only do a full `flutter run -d macos --dart-define=GW_DEV_TOOLS=true` if the reload looks stale. Flip light/dark in place with the dev-tools bubble's **Appearance** section; populate the wallet with the bubble's **MOCK** section (holdings + txns) so the cards have real content. Mouse click-drag does NOT scroll on Flutter desktop — use a two-finger trackpad gesture.

**1. THE OVERFLOW REPRO — do this first, it is the load-bearing check.**
Size the window to roughly **800 wide x 500 tall** (two-column dashboard, deliberately short). Before this change that produced yellow/black stripes on the Bitcoin chart card and a `RenderFlex overflowed by 6.3 pixels` console line. Confirm: NO stripes, NO overflow line in the console. The price may render small or the +$/% row may drop out at that size — that is the fix working, not a defect. Now drag the window shorter still (~400 tall) and confirm it still never stripes. Both modes.

**2. THE RHYTHM — is it actually even?**
At a wide window (three-column, >1536) and a medium one (two-column, 768-1536), in BOTH modes: the gap under the top bar, the gaps between side-by-side cards, and the gaps at the outer edges should all read as the SAME distance. Previously the side-by-side cards touched outright. If any gap still reads off, say WHICH one and at which width.

**3. SHADOWS — gzq must not regress. Both modes, all three breakpoints.**
- Desktop dashboard: each section card should now show its full soft shadow all round; they had none before (cards were flush).
- **Mobile one-column** (narrow the window under 768): scroll all five stacked sections. This is the one accepted risk — stacked gaps went 20 -> 16. Look specifically for any shadow being sliced where one section meets the next, and at the left/right list edges, and above the first / below the last section.
- Markets screen grid: unchanged by this task, but confirm its card shadows are still whole.
If mobile stacked shadows slice, say so — the fallback is raising the single token from 16 to 20 everywhere, which is a one-line change.

**4. REGRESSION SWEEP.** Drag the window slowly across all three breakpoints in both modes and watch the console: no RenderFlex overflow anywhere, no card content clipped, chart still live-updates and its zoom/pan buttons still work. At normal card heights the chart should look exactly as it did before (big price, +$/% row present).

Approve only if the repro window is clean AND the rhythm reads even AND no shadow regressed.
  </how-to-verify>
  <resume-signal>Type "approved", or describe which gap still reads off / what still stripes / where a shadow slices.</resume-signal>
</task>

</tasks>

<threat_model>
No new trust boundary. Layout constants and one text-size computation inside two widget build methods — no input handling, no new data flow, no dependency, no package install. STRIDE register: not applicable (T-uhe-NA: no threat introduced).
</threat_model>

<verification>
- `flutter analyze lib/dashboard/home/view/dashboard_screen.dart lib/chart/crypto_live_chart.dart` -> 0 errors, zero new warnings against the ~409-issue baseline. Report the DELTA only; analyze is a gate, never evidence.
- Blocking human walk is the only real evidence: overflow repro window, rhythm at three breakpoints, shadow non-regression, both modes.
- Confirm via `git diff --stat` that exactly two files changed and that `genius_wallet_decorations.dart`, `genius_wallet_elevation.dart`, and `markets_screen.dart` are untouched.
</verification>

<success_criteria>
- One token (`GeniusWalletConsts.space8` = 16) governs the top-bar gap, every inter-section gap, and the outer edges, at all three breakpoints.
- The two-column desktop layout at ~800x500 produces no overflow stripe and no console overflow line, in either mode.
- Mobile, two-column, and three-column dashboards plus the markets grid all still render full card shadows in light AND dark.
- At normal card heights the chart is visually identical to before the change.
- Exactly two files modified; shared decoration/elevation untouched; no raw spacing literals introduced; the deviation from 8 to 16 is recorded with its reason.
</success_criteria>

<output>
Write files ONLY — per CLAUDE.md, DO NOT CREATE COMMITS. The user authorises commits separately.
Never `git add -A`, `git add .`, or `git commit -a`.

Files this task may touch:
- lib/dashboard/home/view/dashboard_screen.dart
- lib/chart/crypto_live_chart.dart

Create `.planning/quick/260720-uhe-harmonise-dashboard-spacing-restore-chart-height/260720-uhe-SUMMARY.md` when done. Record in it, explicitly:
1. The token deviation (8 -> 16) and the shadow-reach reason.
2. The correction to the todo's root-cause hypothesis: the overflow is the two-column desktop layout at a short window, NOT the mobile ListView padding gzq added — mobile sections are capped at `maxHeight: 350` and cannot overflow.
3. That `.planning/todos/pending/2026-07-20-dashboard-live-chart-overflows-by-6px.md` stays OPEN until the blocking walk is approved.
</output>
