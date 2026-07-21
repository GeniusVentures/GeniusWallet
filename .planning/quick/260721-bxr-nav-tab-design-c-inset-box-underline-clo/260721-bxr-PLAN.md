---
quick_id: 260721-bxr
type: execute
autonomous: true
files_modified:
  - lib/components/overlay/responsive_overlay.dart
  - lib/components/cards/gw_section_title.dart
  - lib/components/coins/view/coins_screen.dart
must_haves:
  truths:
    - "Hovering the currently-active desktop nav tab paints NO hover box (only the cursor changes); the underline is the only active indicator."
    - "Hovering a NON-active desktop nav tab still shows the inset hover box."
    - "The active tab's gradient underline sits CLOSE to the label (~4px under it), not pinned to the bottom of a tall box; the glow does not spill below the inset box."
    - "Assets, Markets, Transactions, and Bitcoin-Chart section headers all have IDENTICAL title→panel-top padding and title→first-row gap (same reserved header height)."
    - "The Assets total stays two-line-stable across empty ($0.00) and funded states with no clipping and no overlap onto the first coin row."
  artifacts:
    - lib/components/overlay/responsive_overlay.dart
    - lib/components/cards/gw_section_title.dart
    - lib/components/coins/view/coins_screen.dart
  key_links:
    - "InkWell.overlayColor gates the active-tab hover box (transparent when isSelected)."
    - "GWSectionTitle's internal ConstrainedBox(minHeight) reserves one shared header height for all four panels; Assets call-site no longer sets its own minHeight."
---

<objective>
Two locked, approved UI fixes on the desktop dashboard, both verified via `flutter analyze` (CLAUDE.md forbids commits) plus a manual walk.

- TASK A: Rework the desktop nav active/hover tab to approved design "C" (inset box + underline CLOSE to the label; active tab shows NO hover box).
- TASK B: Make section-title top padding AND title→first-row gap IDENTICAL across all four dashboard panels by reserving one shared header height inside GWSectionTitle and removing the redundant per-panel reservation from the Assets call-site.

Purpose: Land the approved nav "C" design and equalize panel header geometry without regressing the gradient underline/glow/icons/white-active text, the 18px section title, or panel-body wiring.
Output: Edits to `responsive_overlay.dart`, `gw_section_title.dart`, and `coins_screen.dart`.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md
@.planning/sketches/002-top-navbar/nav-tab-alignment.html
@lib/components/overlay/responsive_overlay.dart
@lib/components/cards/gw_section_title.dart
@lib/components/coins/view/coins_screen.dart
@lib/theme/genius_wallet_consts.dart
</context>

<tasks>

<task type="auto">
  <name>Task A: Nav tab "C" — underline close to label + no hover box on active tab</name>
  <files>lib/components/overlay/responsive_overlay.dart</files>
  <action>
In `_DesktopTopBar` (~:226-337), rework the tab so the gradient underline groups tightly with the label and the active tab suppresses its InkWell hover box. Two changes:

(1) NO hover box on active tab. On the InkWell (~:236), add `overlayColor: isSelected ? const WidgetStatePropertyAll(Colors.transparent) : null`. This makes hovering the active tab paint nothing (WidgetStatePropertyAll<Color?> covers hovered/pressed/focused states); non-active tabs keep `null` → default hover splash inside the inset box. Do not add any persistent active background — the underline stays the only active accent.

(2) Underline CLOSE to the label. Replace the current `Stack[ Center(Row), Positioned(bottom:0, AnimatedContainer underline) ]` with a centered Column that groups label + small gap + underline so the underline rides ~4px under the label instead of the box bottom:
- Shrink the box: change the `SizedBox` height (~:247-249) from `appBarHeight - space4*2` (=52) to a fixed `44.0` so the compact inset makes the slight above-center shift from grouping imperceptible.
- Inside the horizontal-12 Padding + IntrinsicWidth, replace the Stack with `Center( child: Column( mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [ Row(min, [icon,label]), const SizedBox(height: 4), AnimatedContainer(underline) ] ) )`.
- The underline AnimatedContainer keeps everything it has now EXCEPT its explicit horizontal sizing comes from the Column's `stretch` (drop the old `Positioned(left:0,right:0)` — no width prop; stretch makes it track the icon+label content width via IntrinsicWidth). Keep: `duration: 200ms`, `height: 3`, `gradient: isSelected ? GeniusWalletGradient.brandCta : null`, `color: isSelected ? null : Colors.transparent` (gradient-XOR-color guard), `borderRadius: BorderRadius.vertical(top: Radius.circular(3))`, and the `brandPrimaryStrong` @0.5 `blurRadius: 10` glow when selected.
- Keep the `final color = isSelected ? gw.textPrimary : gw.textSecondary` white-active text/icon, `_kIconSize` (23), `spacing: 6`, and the `hideLabels` icon-only branch.

Glow spill: with the 4px gap the underline no longer sits at the box's very bottom, so the 10px glow has room and should not spill below the 44px inset box. If a walk still shows spill past the box bottom, wrap the Column in a `ClipRect` (cheapest fix) rather than reducing the glow — note this as a walk-tunable.
  </action>
  <verify>
    <automated>cd /Users/jakub/Desktop/GeniusAI/GeniusWallet && flutter analyze lib/components/overlay/responsive_overlay.dart</automated>
  </verify>
  <done>flutter analyze clean on the file; the active tab's underline sits ~4px under the label; hovering the active tab paints no box (cursor only); hovering a non-active tab shows the inset hover box; gradient underline + glow + white active text/icon + icon size 23 + hideLabels branch all preserved.</done>
</task>

<task type="auto">
  <name>Task B: Identical section-header height in GWSectionTitle + drop Assets call-site reservation</name>
  <files>lib/components/cards/gw_section_title.dart, lib/components/coins/view/coins_screen.dart</files>
  <action>
Make every panel's title area the same height so title→top padding AND title→first-row gap are identical across Assets / Markets / Transactions / Bitcoin-Chart.

In `gw_section_title.dart` (build ~:34-51): wrap the existing `Row` in a `ConstrainedBox(constraints: const BoxConstraints(minHeight: 44))` (44 = the height the 2-line Assets total needs: amount ~20/26 + 24h-change ~13/18 ≈ 44; matches the old 45 call-site reservation, rounded to the reserved header the component now owns for ALL panels). Keep the Row's `crossAxisAlignment: CrossAxisAlignment.center` so the title (and single-line trailings) center vertically in the reserved height. Do NOT change the outer `Padding(fromLTRB(space4, 2, space4, space8))`, the 18px `titleLg` style, `letterSpacing: -0.2`, or the `?trailing` optional child. Update the doc comment to note the component now reserves a shared header min-height (~44) so all four panels read at one geometry.

In `coins_screen.dart` (Assets header ~:257-283): REMOVE the now-redundant `ConstrainedBox(constraints: const BoxConstraints(minHeight: 45))` wrapper — the component reserves the height for every panel. Pass the inner `Column` (total + conditional 24h-change) directly as `trailing`. Keep the Column exactly as-is: `mainAxisAlignment: center`, `crossAxisAlignment: end`, `mainAxisSize: min`, the fontSize-20/w700 total, and the `if (total > 0)` 24h-change line — this preserves empty↔funded two-line stability (the reserved height now comes from the component, and center-aligned end-column keeps the amount vertically centered in both states).

Do NOT touch panel bodies, coin rows, the Markets/Transactions/Bitcoin trailings, or any *.g.dart. Markets (single-line `Text('Top n · 24h')`), the Transactions FittedBox trailing, and the title-only Bitcoin-Chart case all center cleanly in the reserved height with no code change.
  </action>
  <verify>
    <automated>cd /Users/jakub/Desktop/GeniusAI/GeniusWallet && flutter analyze lib/components/cards/gw_section_title.dart lib/components/coins/view/coins_screen.dart</automated>
  </verify>
  <done>flutter analyze clean on both files; GWSectionTitle reserves a shared ~44px header height with the title centered; the Assets call-site no longer sets its own minHeight; on a walk all four panel headers show identical title→top and title→first-row spacing; the Assets total is 2-line-stable across empty/funded with no clipping and no overlap onto the first coin row.</done>
</task>

</tasks>

<verification>
- `flutter analyze` clean on all three modified files (no new warnings/errors).
- Manual walk (desktop dashboard):
  - Nav: active tab underline is close to the label; hovering active tab = no box; hovering non-active tab = inset box; gradient/glow/white-active text/icons intact; no glow spill below the box.
  - Panels: Assets, Markets, Transactions, Bitcoin-Chart headers share identical title→top and title→first-row spacing; Assets total stable empty↔funded, no clipping/overlap.
- No regressions to: nav logo/gaps, section-title 18px + 4-panel wiring, Markets rows (1nk), Assets rows (vwj), 0ze sweep. No panel-body edits.
</verification>

<success_criteria>
Both tasks land as locked design "C" (nav) and identical panel header geometry (section title), verified by clean `flutter analyze` and the manual walk above. No commits (CLAUDE.md). Light-mode: no separate handling required — both changes are structure/geometry only and inherit existing theme tokens; record any light-mode glow/contrast nit found during the walk as a deferral rather than fixing inline.
</success_criteria>

<output>
Update STATE.md walk row on completion. No commit (CLAUDE.md forbids commits).
</output>
