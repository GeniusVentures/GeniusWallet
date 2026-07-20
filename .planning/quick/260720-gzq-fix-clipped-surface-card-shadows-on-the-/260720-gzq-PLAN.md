---
quick_id: 260720-gzq
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dashboard/chart/markets_screen.dart
  - lib/dashboard/home/view/dashboard_screen.dart
autonomous: false
requirements:
  - todo:2026-07-20-surface-card-shadows-clipped

must_haves:
  truths:
    - "In the markets grid (desktop), every elevated surface card renders its full soft card shadow — no shadow is sliced by a neighbouring card or cut at the grid's edges."
    - "In the mobile one-column dashboard (narrow window → OneColumnDashBoardView), every stacked section card renders its full card shadow — no horizontal clipping at the ListView edges and no vertical clipping between sections."
    - "Both effects hold in light AND dark mode."
    - "Nothing else regresses: no new overflow, spacing stays reasonable, and the desktop 2-/3-column dashboard is visually unchanged."
  artifacts:
    - lib/dashboard/chart/markets_screen.dart
    - lib/dashboard/home/view/dashboard_screen.dart
  key_links:
    - "GridView spacing + padding is the ONLY room the card shadow has inside the scroll viewport's hard clip — undersize it and the shadow is cut."
    - "ListView padding (horizontal) + inter-section spacing (vertical) is the ONLY room the mobile section shadows have inside the ListView's default Clip.hardEdge — undersize it and the shadow is cut."
    - "GWDecorations.surface / GeniusWalletElevation.card are shared with the FINE desktop dashboard — they MUST NOT change."
---

<objective>
Give the elevated surface cards (`GWDecorations.surface(elevated: true)` → `GeniusWalletElevation.card`: blurRadius 16, offset (0,4)) enough room for their ~16–20px soft shadow to render fully in the TWO sites where it is currently clipped: the desktop markets grid and the mobile one-column dashboard. Layout-only fix — increase spacing and add padding so the shadow clears neighbouring opaque surfaces and the scroll-viewport clip boundaries.

Purpose: The 05-04 markets walk found the card shadows visibly sliced. Root cause is insufficient room, not the shadow definition or the per-card `Clip.hardEdge` (which clips the child, not the shadow).
Output: Two files touched with token-based spacing/padding; shadows render fully in both modes at both breakpoints.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/todos/pending/2026-07-20-surface-card-shadows-clipped.md
@lib/theme/genius_wallet_elevation.dart
@lib/theme/genius_wallet_decorations.dart
@lib/dashboard/chart/markets_screen.dart
@lib/dashboard/home/view/dashboard_screen.dart

# Shadow extent (from GeniusWalletElevation.card): blurRadius 16, offset (0,4).
#   Effective reach ≈ 16px each side, ≈12px up (blur 16 − offset 4), ≈20px down (blur 16 + offset 4).
# Spacing tokens (GeniusWalletConsts): space6 = 12, space8 = 16, space10 = 20. Both files already import genius_wallet_consts.dart.
# HARD CONSTRAINTS:
#   - Do NOT edit GWDecorations.surface or GeniusWalletElevation.card (shared with the FINE desktop layout).
#   - Do NOT edit the desktop _twoColumnLayout / _threeColumnLayout in dashboard_screen.dart.
#   - Do NOT change card behavior, content sizes, tap wiring, or the appearance-toggle wiring.
#   - Keep the per-card Clip.hardEdge as-is (it clips the child to the rounded rect; it does not clip the shadow).
# A debug build is ALREADY RUNNING — do NOT run flutter build / flutter run. `flutter test` does NOT compile; `flutter analyze` is the only automated gate.
# Windows env. Stage ONLY the two explicit source paths (README.md is dirty — never `git add -A`). Do NOT commit docs or touch ROADMAP.md.
</context>

<tasks>

<task type="auto">
  <name>Task 1: Give the markets grid room for the card shadow (spacing + viewport padding)</name>
  <files>lib/dashboard/chart/markets_screen.dart</files>
  <action>
In the `GridView.builder` at ~:155–163, widen the inter-cell gaps to at least the shadow's reach and add padding on all four sides so edge-cell shadows are not cut by the scroll viewport's clip.

- In the `SliverGridDelegateWithFixedCrossAxisCount`: change `crossAxisSpacing: 8` → `crossAxisSpacing: GeniusWalletConsts.space8` (16, ≥ the ~16px horizontal shadow reach so a neighbour's opaque surface no longer overlaps it) and `mainAxisSpacing: 8` → `mainAxisSpacing: GeniusWalletConsts.space10` (20, ≥ the ~20px downward shadow reach). Leave `crossAxisCount: getCrossAxisCount(context)` and `mainAxisExtent: 80` untouched.
- Change the GridView `padding` from `const EdgeInsets.only(bottom: 16)` to `const EdgeInsets.fromLTRB(GeniusWalletConsts.space8, GeniusWalletConsts.space6, GeniusWalletConsts.space8, GeniusWalletConsts.space10)` (left 16 / top 12 / right 16 / bottom 20) so the first/last row and the left/right columns get clearance inside the viewport for their shadow. The `const` keyword stays valid because these are compile-time const doubles.

Do NOT touch the per-card `Container(clipBehavior: Clip.hardEdge, decoration: GWDecorations.surface(...))` or the `CryptoSparkLineChart` child. Do not add a per-card margin — the widened spacing already provides the room and keeps the grid math simple.
  </action>
  <verify>
    <automated>flutter analyze lib/dashboard/chart/markets_screen.dart</automated>
  </verify>
  <done>Grid uses crossAxisSpacing 16 / mainAxisSpacing 20 and fromLTRB(16,12,16,20) padding; `flutter analyze` on the file reports 0 errors; GWDecorations.surface and the card Container are unchanged.</done>
</task>

<task type="auto">
  <name>Task 2: Give the mobile one-column dashboard sections room for their shadows</name>
  <files>lib/dashboard/home/view/dashboard_screen.dart</files>
  <action>
Only `OneColumnDashBoardView.build` (~:219–257) changes. This is the MOBILE/narrow layout. Do NOT touch `_twoColumnLayout` / `_threeColumnLayout` (desktop, confirmed fine) or `DashboardScrollContainer`.

The inner `ListView` clips its children with the default `Clip.hardEdge`, so each `DashboardScrollContainer` section's ~16px horizontal shadow is cut at the ListView edges, and the 6px inter-section `spacing` (`gridSpacing / 2`) is smaller than the ~20px downward shadow so vertically-adjacent sections cut each other's shadow.

- Add a `padding` to the `ListView`: `padding: const EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space8, vertical: GeniusWalletConsts.space6)` (horizontal 16 gives each full-width section clearance from the ListView's horizontal clip; vertical 12 gives the first/last section top/bottom clearance). This composes with the existing outer `Padding(EdgeInsets.all(gridSpacing / 2))` (6px) for ~22px horizontal / ~18px vertical total — both ≥ the shadow reach.
- Change the inter-section `spacing` const from `SizedBox(height: gridSpacing / 2)` (6px) to `SizedBox(height: GeniusWalletConsts.space10)` (20px) so each section's downward shadow clears the next section's opaque surface.

Leave the five `ConstrainedBox` sections, their `maxHeight` values, the `RefreshIndicator`, and the outer `Padding` unchanged. Do not switch any clipBehavior to `Clip.none` — the padding approach keeps content contained while giving the shadow room.
  </action>
  <verify>
    <automated>flutter analyze lib/dashboard/home/view/dashboard_screen.dart</automated>
  </verify>
  <done>ListView has symmetric(horizontal:16, vertical:12) padding; inter-section spacing is 20px (space10); the five ConstrainedBox sections, DashboardScrollContainer, and the desktop 2-/3-column layouts are unchanged; `flutter analyze` on the file reports 0 errors.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
Widened spacing + added viewport/list padding at the two clipping sites so the elevated surface-card shadow (blurRadius 16, offset (0,4)) renders fully:
- Markets grid: crossAxisSpacing 8→16, mainAxisSpacing 8→20, padding only-bottom-16 → fromLTRB(16,12,16,20).
- Mobile one-column dashboard: ListView padding symmetric(h:16, v:12) added; inter-section spacing 6→20.
No shared token, decoration, or desktop-layout code was touched.
  </what-built>
  <how-to-verify>
Use the debug build that is already running (do NOT rebuild). Toggle light/dark with the dev-tools bubble's Appearance section.

1. DESKTOP — Markets grid: open the Markets screen at a wide window width. In BOTH light and dark, confirm each grid card shows its full soft shadow all around (especially the bottom edge) — no shadow sliced by the neighbouring card and no shadow cut at the top/bottom/left/right edges of the grid. Confirm the grid still looks tidy (no absurdly large gaps, no card overflow warnings in the console).
2. MOBILE breakpoint — Dashboard: resize the window narrow until the dashboard collapses to the single-column layout (OneColumnDashBoardView — the five stacked sections). In BOTH light and dark, scroll through all five sections and confirm each section card's shadow renders fully — no horizontal clipping at the left/right list edges, and the shadow between stacked sections is not cut. Confirm the first (top) and last (bottom) sections' shadows are also complete.
3. REGRESSION check: widen the window back to the 2-/3-column desktop dashboard and confirm it is visually unchanged from before. Confirm no new RenderFlex overflow banners appeared at any width, in either mode.

Approve only if shadows render fully at BOTH breakpoints in BOTH modes AND nothing else regressed.
  </how-to-verify>
  <resume-signal>Type "approved", or describe what still clips / what regressed.</resume-signal>
</task>

</tasks>

<threat_model>
No new trust boundary. This change adjusts only layout spacing/padding constants in two widget build methods — no input handling, no new data flow, no dependency, no package install. STRIDE register: not applicable (T-gzq-NA: no threat introduced).
</threat_model>

<verification>
- `flutter analyze lib/dashboard/chart/markets_screen.dart lib/dashboard/home/view/dashboard_screen.dart` → 0 errors.
- Blocking human-verify walk covers desktop markets grid + mobile one-column dashboard in light AND dark, plus the desktop-layout no-regression check.
- Confirm via diff that GWDecorations.surface, GeniusWalletElevation.card, DashboardScrollContainer, and _twoColumnLayout/_threeColumnLayout are untouched.
</verification>

<success_criteria>
- Markets grid cards render full shadows (both modes), no slicing by neighbours or grid edges.
- Mobile one-column dashboard sections render full shadows (both modes), no horizontal/vertical clipping.
- Desktop 2-/3-column dashboard unchanged; no new overflow at any width.
- Only the two source files changed; token-based spacing (space6/space8/space10) used throughout.
</success_criteria>

<output>
Stage ONLY these two paths (never `git add -A`; README.md is dirty and must stay unstaged):
- lib/dashboard/chart/markets_screen.dart
- lib/dashboard/home/view/dashboard_screen.dart

Do NOT commit docs and do NOT modify ROADMAP.md. Create `.planning/quick/260720-gzq-fix-clipped-surface-card-shadows-on-the-/260720-gzq-SUMMARY.md` when done.
</output>
