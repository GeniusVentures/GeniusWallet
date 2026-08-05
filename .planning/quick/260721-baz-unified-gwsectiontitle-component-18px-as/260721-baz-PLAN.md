---
quick_id: 260721-baz
type: quick-full
mode: validate
autonomous: false
files_modified:
  - lib/components/cards/gw_section_title.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/dashboard/chart/dashboard_markets.dart
  - lib/dashboard/home/widgets/transactions_slim_view.dart
  - lib/dashboard/home/view/dashboard_screen.dart
  - lib/components/overlay/responsive_overlay.dart

must_haves:
  truths:
    - Every dashboard panel (Assets, Markets, Transactions, Bitcoin Chart) renders its section title at 18px (titleLg), left-aligned with the same space4 inset and space8 gap-to-body — visually one system.
    - The Transactions panel title reads at 18px (was 24px headlineLarge) — the intended unification, its segment filter now sits on the title row as trailing.
    - The Bitcoin Chart title reads at 18px (was titleLarge) via the shared component.
    - There is exactly ONE section-title widget (GWSectionTitle) reused by all four panels; no panel keeps an ad-hoc title.
    - Hovering any desktop nav tab shows the icon+label at the vertical center of an inset hover box that does NOT touch the bar's top edge; the gradient underline sits pinned at the box bottom and does not shift the icon+label off-center.
    - Nav underline keeps its 3px brandCta gradient, brandPrimaryStrong glow (blurRadius 10), rounded top (Radius.circular(3)), and content-tracking width; active text/icon stay white (textPrimary); icon size 23; appBarHeight 68.
  artifacts:
    - lib/components/cards/gw_section_title.dart (new — GWSectionTitle)
  key_links:
    - GWSectionTitle imported and mounted in coins_screen.dart, dashboard_markets.dart, transactions_slim_view.dart, dashboard_screen.dart
    - Nav tab InkWell hover box inset via a vertical Padding OUTSIDE the InkWell so the splash is confined to the inset box
---

<objective>
(A) Extract ONE shared dashboard-panel section-title widget — `GWSectionTitle` — that captures the Assets header's exact position (18px titleLg, left-aligned, space4 horizontal inset, space8 gap to body, optional right-aligned trailing), and route all four dashboard panels (Assets, Markets, Transactions, Bitcoin Chart) through it. (B) Fix the desktop nav tab so the icon+label is truly vertically centered in an inset hover box, with the gradient underline pinned to the box bottom and EXCLUDED from the centering.

Purpose: unify the dashboard panel titles (locked at 18px per sketch 004) into one reusable component, and correct the nav tab's off-center icon+label (the underline currently pulls the block above box center).
Output: 1 new widget file + 4 panel edits + 1 nav edit. LAZY: one widget reused 4×; reuse titleLg/space tokens; no new deps; panel bodies untouched.
</objective>

<context>
@.planning/STATE.md
@.planning/sketches/004-section-title/index.html
@lib/theme/genius_wallet_typography.dart
@lib/components/scaffold/gw_page_header.dart
@lib/components/coins/view/coins_screen.dart
@lib/dashboard/chart/dashboard_markets.dart
@lib/dashboard/home/widgets/transactions_slim_view.dart
@lib/dashboard/home/view/dashboard_screen.dart
@lib/components/overlay/responsive_overlay.dart

Reference facts (verified this session):
- Tokens (genius_wallet_consts.dart): space2=4, space4=8, space6=12, space8=16, space3=6, appBarHeight=68, borderRadiusCard=radiusLg.
- titleLg = 18/24 w600, no letterSpacing set (genius_wallet_typography.dart:77). Color follows appearance via `.copyWith(color: gw.textPrimary)`.
- Assets header (coins_screen.dart ~253-301) is the POSITION reference: `Padding(fromLTRB(space4, 0, space4, space8))` → `Row(crossAxisAlignment.center, mainAxisAlignment.spaceBetween, [Text('Assets', titleLg+gw.textPrimary), ConstrainedBox(minHeight:45)>Column(total + optional 24h $·% subline)])`. The ConstrainedBox reserves two-line height so empty ($0.00) and funded states keep identical height — MUST be preserved.
- Markets header (dashboard_markets.dart ~64-88): already titleLg via Padding(fromLTRB(space4,0,space4,space8))+Row(spaceBetween, [Text('Markets'), Text('Top {n} · 24h', bodySm+textSecondary)]).
- Transactions (transactions_slim_view.dart ~78-108): title is `Text('Transactions', textTheme.headlineLarge=24px)` then a SEPARATE `SegmentedButton<Filters>` sibling in a Column(spacing:16). Sketch 004 puts the segment on the title row as trailing.
- Bitcoin Chart (dashboard_screen.dart ~378-382): `AutoSizeText("Bitcoin Chart", textTheme.titleLarge)` in a Column(crossAxisAlignment.start) inside DashboardScrollContainer; body is Expanded>CryptoLiveChart.
- GWPageHeader (components/scaffold/gw_page_header.dart) is for full-PAGE titles (headlineLg, Column) — a DIFFERENT context. Do NOT reuse it; GWSectionTitle is the panel analogue and mirrors its fail-soft gw pattern.
- Nav tab (responsive_overlay.dart ~226-318): Material>InkWell(borderRadius:borderRadiusCard)>SizedBox(height:appBarHeight=68)>Padding(h:12)>IntrinsicWidth>Column(mainAxisSize.max, mainAxisAlignment.center, crossAxisAlignment.stretch, spacing:4, [Row(Icon size _kIconSize=23, label), AnimatedContainer underline 3px]). BUG: the Column centers the WHOLE group [Row + spacing + underline], so the icon+label center sits ~3.5px above box center; and the SizedBox is full 68px so the hover box touches the bar's top edge.
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create the shared GWSectionTitle panel-title widget</name>
  <files>lib/components/cards/gw_section_title.dart (new)</files>
  <action>
Create `GWSectionTitle`, a stateless widget mirroring GWPageHeader's fail-soft pattern but for dashboard PANEL titles. Imports: flutter/material, genius_wallet_consts, genius_wallet_typography, gw_colors.

API: `const GWSectionTitle({super.key, required this.title, this.trailing})` with `final String title;` and `final Widget? trailing;`.

build():
- Fail-soft gw read (registers the Theme dependency so it re-skins on a live appearance toggle): `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();`
- Return `Padding(padding: const EdgeInsets.fromLTRB(space4, 2, space4, space8), child: Row(...))`. Use `GeniusWalletConsts.space4` / `space8`; the top 2 is a literal (matches sketch 004's `padding: 2px space4 space8`).
- Row: `crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceBetween`, children: `[ Text(title, style: GeniusWalletTypography.titleLg.copyWith(color: gw.textPrimary, letterSpacing: -0.2)), if (trailing != null) trailing! ]`.

This captures the Assets header POSITION exactly (space4 inset, space8 gap, center cross-axis, spaceBetween) at the locked 18px titleLg with -0.2 letter-spacing (sketch 004). Single title child (no trailing) left-aligns via spaceBetween. Do NOT wrap title in Flexible — keep it identical to the Assets reference; overflow-prone trailings are handled at the call site (Task 2, Transactions). Add a short doc comment noting this is the panel-title component (18px) and is NOT GWPageHeader (page titles, 24px).
  </action>
  <verify>
    <automated>gmac flutter analyze lib/components/cards/gw_section_title.dart</automated>
  </verify>
  <done>gw_section_title.dart compiles clean; GWSectionTitle exposes `{required String title, Widget? trailing}` and renders titleLg (18px) at fromLTRB(space4,2,space4,space8) with center/spaceBetween Row.</done>
</task>

<task type="auto">
  <name>Task 2: Route all four dashboard panels through GWSectionTitle</name>
  <files>lib/components/coins/view/coins_screen.dart, lib/dashboard/chart/dashboard_markets.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/home/view/dashboard_screen.dart</files>
  <action>
Add `import 'package:genius_wallet/components/cards/gw_section_title.dart';` to each of the four files. Replace each panel's ad-hoc title header with GWSectionTitle. Do NOT touch any panel BODY (rows, lists, chart, footer) — only the title header.

1. Assets (coins_screen.dart ~253-301): Replace the `if (isDashboard) Padding(...Row...)` header with `if (isDashboard) GWSectionTitle(title: 'Assets', trailing: <the existing ConstrainedBox(minHeight:45)>Column(total + optional 24h $·% subline) block, verbatim>)`. Keep the ConstrainedBox/Column trailing EXACTLY as-is (it reserves the two-line height that keeps empty/funded states equal height — do not alter it). Net effect: title top inset shifts 0→2px and gains letterSpacing -0.2 (intended — Assets now IS the shared component). The `if (isDashboard)` guard stays; the value-empty footer below is unchanged.

2. Markets (dashboard_markets.dart ~64-88): Replace the header `Padding(...Row...)` with `GWSectionTitle(title: widget.title ?? 'Markets', trailing: Text('Top ${visibleCoins.length} · 24h', style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary)))`. The `Column`/`Expanded(ListView)` body is unchanged.

3. Transactions (transactions_slim_view.dart ~78-108): Remove the standalone `Text('Transactions', headlineLarge)` AND lift the existing `SegmentedButton<Filters>` out of the Column as a sibling — mount it as the GWSectionTitle trailing: `GWSectionTitle(title: 'Transactions', trailing: <the existing SegmentedButton<Filters>, verbatim>)`. This changes the title 24px→18px (intended unification) and moves the segment onto the title row. The Column's `spacing: 16.0` still governs the gap to the Expanded(list); GWSectionTitle owns its own space8 bottom gap, so drop the now-redundant leading spacing only if it double-gaps (walk-tune). WATCH: the SegmentedButton may be wide for the dashboard panel width — if the walk shows a RenderFlex overflow on the title row, wrap the trailing SegmentedButton in `Flexible(child: FittedBox(alignment: Alignment.centerRight, fit: BoxFit.scaleDown, child: ...))` (executor's call, resolved at walk). Do NOT change Filters/selection logic or the list body.

4. Bitcoin Chart (dashboard_screen.dart ~378-382): Replace `AutoSizeText("Bitcoin Chart", maxLines:1, style: textTheme.titleLarge)` with `const GWSectionTitle(title: 'Bitcoin Chart')` (title only, no trailing). The Column(crossAxisAlignment.start) + Expanded(CryptoLiveChart) body is unchanged; title now reads 18px with the shared space4/space8 inset.

After edits, remove any now-unused imports flutter analyze flags (e.g. if AutoSizeText/headlineLarge references are dropped — verify before deleting; AutoSizeText is still used elsewhere in transactions_slim_view for the count footer, so keep that import).
  </action>
  <verify>
    <automated>gmac flutter analyze lib/components/coins/view/coins_screen.dart lib/dashboard/chart/dashboard_markets.dart lib/dashboard/home/widgets/transactions_slim_view.dart lib/dashboard/home/view/dashboard_screen.dart</automated>
  </verify>
  <done>All four panels mount GWSectionTitle; Assets trailing keeps its reserved two-line height; Markets subtitle + Transactions segment preserved as trailing; Bitcoin Chart title-only; analyze clean, no unused-import warnings.</done>
</task>

<task type="auto">
  <name>Task 3: Center the nav tab icon+label in an inset box; pin the underline to the box bottom</name>
  <files>lib/components/overlay/responsive_overlay.dart</files>
  <action>
Restructure the desktop nav tab (`tabButton`, ~226-318) so the icon+label Row is vertically centered in a hover box that is INSET from the bar's top/bottom edges, and the gradient underline is pinned to the box bottom and EXCLUDED from the centering.

Current: `Material > InkWell(borderRadius) > SizedBox(height: appBarHeight) > Padding(h:12) > IntrinsicWidth > Column(mainAxisSize.max, mainAxisAlignment.center, crossAxisAlignment.stretch, spacing:4, [Row(icon,label), AnimatedContainer(underline)])`.

New structure:
- `Material(color: Colors.transparent, child: Padding(padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4), child: InkWell(...same onTap/borderRadius/mouseCursor..., child: SizedBox(height: GeniusWalletConsts.appBarHeight - GeniusWalletConsts.space4 * 2, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0), child: IntrinsicWidth(child: Stack(...)))))))`.
  - The vertical `Padding(space4)` goes OUTSIDE the InkWell so the hover splash is confined to the inset box (box no longer touches the bar's top/bottom edge; equal top/bottom inset). `space4` (8px) is the starting inset — walk-tunable.
  - `appBarHeight - space4 * 2` is a compile-time const (both are const doubles) → inset box height (68 - 16 = 52).
- Inside, `Stack(children: [ Center(child: <the existing Row(icon,label), verbatim — mainAxisSize.min, spacing:6, Icon size _kIconSize, optional label>), Positioned(bottom: 0, left: 0, right: 0, child: <the existing AnimatedContainer underline, verbatim>) ])`.
  - `Center` fills the box height and vertically centers the Row at the EXACT box center (the underline no longer participates). `IntrinsicWidth` still tracks the Row's content width (Positioned children are excluded from intrinsic width), so the underline via `Positioned(left:0,right:0)` spans exactly the icon+label width — same content-tracking as before.
  - Move the `AnimatedContainer` underline verbatim into the Positioned: keep height 3, the gradient-XOR-color per-state guard (`gradient: isSelected ? GeniusWalletGradient.brandCta : null` / `color: isSelected ? null : Colors.transparent`), `BorderRadius.vertical(top: Radius.circular(3))`, and the brandPrimaryStrong glow `boxShadow` (blurRadius 10). Drop the old Column's `spacing: 4` (the Stack replaces the gap).
- Keep the `hideLabels ? Tooltip(...) : tabButton` return unchanged. Active text/icon color stays `isSelected ? gw.textPrimary : gw.textSecondary`, icon `_kIconSize` (23), `appBarHeight` (68) unchanged.

Do NOT touch the top-bar logo (40), the logo→nav 15px gap, the destinations Row spacing, or the Connect/Disconnect button logic.
  </action>
  <verify>
    <automated>gmac flutter analyze lib/components/overlay/responsive_overlay.dart</automated>
  </verify>
  <done>Nav tab compiles clean; icon+label centered in an inset box (vertical space4 padding outside InkWell, box height appBarHeight-2*space4); underline pinned bottom via Positioned(left:0,right:0), gradient/glow/rounded-top/content-width and white active text/icon all preserved.</done>
</task>

</tasks>

<verification>
- `gmac flutter analyze lib/` is clean (allow the 2 known pre-existing reown info deprecations; no NEW warnings/errors). `flutter analyze` is the gate — NOT commit (CLAUDE.md forbids commits; leave the tree uncommitted).
- No new dependency added; no panel BODY changed; /banxa, /squidrouter, *.g.dart untouched.
- Human walk (dark first): (1) all four dashboard panels show a matching 18px left-aligned title with equal inset/gap; (2) Transactions title is now 18px with its segment on the title row and no overflow; (3) Bitcoin Chart title is 18px; (4) hovering each nav tab (Dashboard/Transactions/Swap/…) shows icon+label at the vertical center of an inset box that does not touch the bar's top edge, underline flush at the box bottom, gradient+glow intact, white active text.
</verification>

<success_criteria>
GWSectionTitle exists once and is the title of all four dashboard panels at 18px; each panel's trailing content/behavior (Assets two-line total, Markets subtitle, Transactions segment) is intact; the nav tab icon+label is centered in an inset box with the underline pinned to the bottom and excluded from the centering; `flutter analyze` clean.
</success_criteria>

<deferrals>
- Light-mode AA pass: dark-first per the active branch convention (0ze/1nk/vwj all deferred light-mode AA for #0AAEE6). GWSectionTitle reads gw.textPrimary/textSecondary (appearance-aware), so it is light-ready, but the dashboard light-mode walk rides the milestone's pending light pass, not this quick task.
- Nav inset value (space4=8) and the Transactions-segment overflow guard (Flexible/FittedBox) are walk-tuned, not pre-locked.
- No test file: per CLAUDE.md + the quick-task constraint, these are widget/layout changes — `flutter analyze` is the check; no hollow test.
</deferrals>

<output>
Update the quick task's STATE row / SUMMARY on completion. Do NOT commit (CLAUDE.md gate) — leave the tree for the human walk.
</output>
