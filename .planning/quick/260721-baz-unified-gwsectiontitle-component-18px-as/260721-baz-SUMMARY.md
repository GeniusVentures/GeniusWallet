---
quick_id: 260721-baz
type: quick-full
status: complete
subsystem: dashboard + nav chrome
tags: [ui, dashboard, section-title, nav, layout, dark-first]
key_files:
  created:
    - lib/components/cards/gw_section_title.dart
  modified:
    - lib/components/coins/view/coins_screen.dart
    - lib/dashboard/chart/dashboard_markets.dart
    - lib/dashboard/home/widgets/transactions_slim_view.dart
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/components/overlay/responsive_overlay.dart
metrics:
  tasks: 3
  files: 6
  completed: 2026-07-21
walk: PENDING
committed: false  # CLAUDE.md gate — tree left unstaged for the human walk
---

# Quick 260721-baz: Unified GWSectionTitle across dashboard panels + nav tab vertical-centering fix — Summary

One shared `GWSectionTitle` (18px `titleLg`, `space4` inset, `space8` gap, optional right trailing) now titles all four dashboard panels (Assets, Markets, Transactions, Bitcoin Chart); the desktop nav tab centers its icon+label in an inset hover box with the gradient underline pinned to the box bottom and excluded from the centering.

## What changed

### Task 1 — `GWSectionTitle` (new)
`lib/components/cards/gw_section_title.dart`. Stateless, mirrors GWPageHeader's fail-soft `gw` read. API `{required String title, Widget? trailing}`. Renders `Padding(fromLTRB(space4, 2, space4, space8))` → `Row(center, spaceBetween, [Text(titleLg, gw.textPrimary, letterSpacing -0.2), ?trailing])`. Single-title (no trailing) left-aligns via spaceBetween. Doc comment marks it as the panel-title component (18px) and explicitly NOT GWPageHeader (page titles, 24px). Uses the codebase's null-aware element `?trailing` (matches GWPageHeader; clears `use_null_aware_elements`).

### Task 2 — four panels routed through it
- **Assets** (`coins_screen.dart`): ad-hoc `Padding>Row` header replaced with `GWSectionTitle(title: 'Assets', trailing: <ConstrainedBox(minHeight:45)>Column(total + optional 24h $·% subline)>)` — the reserved two-line total block passed verbatim as trailing, so empty ($0.00) and funded states keep identical height. Title gains the shared 2px top inset + -0.2 tracking (intended; Assets now IS the component). Value-empty footer untouched.
- **Markets** (`dashboard_markets.dart`): header `Padding>Row` replaced with `GWSectionTitle(title: widget.title ?? 'Markets', trailing: Text('Top ${visibleCoins.length} · 24h', bodySm/textSecondary))`. Body Column+Expanded(ListView) untouched. Removed now-unused `genius_wallet_consts` import.
- **Transactions** (`transactions_slim_view.dart`): 24px `headlineLarge` title dropped; `GWSectionTitle(title: 'Transactions', trailing: <segment>)` mounts the filter on the title row (24→18px unification). Walk-tune handling below.
- **Bitcoin Chart** (`dashboard_screen.dart`): `AutoSizeText("Bitcoin Chart", titleLarge)` → `const GWSectionTitle(title: 'Bitcoin Chart')` (title only). Removed the now-unused `auto_size_text` import (it was this file's only AutoSizeText use).

### Task 3 — nav tab center + pinned underline (`responsive_overlay.dart`)
Restructured `tabButton`: a vertical `Padding(symmetric(vertical: space4))` now wraps the InkWell **from outside**, so the hover splash is confined to an inset box that no longer touches the bar's top/bottom edge. Inner `SizedBox(height: appBarHeight - space4*2)` (compile-time const, 68-16=52) holds `IntrinsicWidth > Stack([ Center(child: Row(icon+label)), Positioned(bottom:0,left:0,right:0, child: AnimatedContainer(underline)) ])`. `Center` vertically centers the icon+label at the exact box center; the underline is excluded from that centering, so it can no longer pull the block ~3.5px high. Underline preserved verbatim: 3px, `brandCta` gradient (XOR color guard), `BorderRadius.vertical(top: Radius.circular(3))`, `brandPrimaryStrong` glow blurRadius 10. `IntrinsicWidth` still content-tracks the Row width (Positioned excluded from intrinsic width) so `left:0,right:0` spans exactly icon+label. White active text/icon (`gw.textPrimary`), icon `_kIconSize` 23, `appBarHeight` 68 all unchanged. Logo/gaps/destination spacing/Connect logic untouched.

> Note: the Task-3 block was spliced by line number (Python) rather than the Edit tool because the original had em-dash/arrow (`—`/`→`) chars in comments that broke exact string matching; the new comments use ASCII (`--`/`->`) to avoid the same trap.

## Walk-tune items (plan-checker flagged)

1. **Double-gap after lifting the segment.** The Transactions `Column` had `spacing: 16` and GWSectionTitle adds its own `space8` bottom → ~32px title↔list gap. Fixed by dropping the Column's `spacing: 16.0` entirely so the title→list gap is the shared `space8` (matches the other panels). Because that spacing also fed the list→count-footer gap, I restored just that one gap with an explicit `const SizedBox(height: space8)` before the `Align` footer — no double gap, no regressed footer gap.

2. **Narrow-panel segment overflow.** The 3-4 filter chips beside "Transactions" are the tightest overflow case. Wrapped the **trailing** (not the title) in `Flexible(child: FittedBox(alignment: Alignment.centerRight, fit: BoxFit.scaleDown, child: SegmentedButton(...)))` so it scales down instead of RenderFlex-overflowing. The title `Text` stays unwrapped (matches the Assets reference). Filters/selection logic and the list body are unchanged.

## Verification — real `flutter analyze` output

Tool note: the plan's `gmac` prefix is a `run -d macos` alias on this machine, so analyze was run as `flutter analyze` directly (Flutter at `~/development/flutter/bin`).

- Task 1 — `flutter analyze lib/components/cards/gw_section_title.dart` → **No issues found!** (after switching `if (trailing != null) trailing!` to `?trailing`).
- Task 2 — `flutter analyze` on the 4 panel files → **No issues found!** (after dropping the unused `genius_wallet_consts` import in dashboard_markets.dart).
- Task 3 — `flutter analyze lib/components/overlay/responsive_overlay.dart` → **No issues found!**
- Full gate — `flutter analyze lib/` → 61 issues, **none in any of the 6 touched files** (grep-confirmed). All 61 are pre-existing in untouched files (squid_router unused fields, tokeninfo/web `avoid_print`, tokens `strict_top_level_inference`, web `_goForward` unused). The only issues near scope are the 2 known pre-existing reown info deprecations at `reown_connect_button.dart:158/403` (`use_build_context_synchronously`), matching the 260721-1nk baseline.

## Scope / guardrails honored

- No panel BODY touched (Assets rows, Markets rows, Transactions list, chart). Markets rows (1nk) and Assets rows (vwj) untouched. `/banxa`, `/squidrouter`, `*.g.dart` untouched. No new dependency.
- Nav logo (40), logo→nav 15px gap, destinations Row spacing, Connect/Disconnect logic, gradient underline glow/rounded-top/content-width, white active text/icon — all preserved.
- **No commit** (CLAUDE.md gate): every edit left UNSTAGED. `git diff --cached` empty. ROADMAP.md not touched.

## Deferrals (per plan)

- Light-mode AA pass rides the milestone's pending light pass (dark-first). GWSectionTitle reads `gw.textPrimary`/`textSecondary` so it is light-ready.
- Nav inset value (`space4`=8) and the Transactions-segment overflow guard are walk-tuned, not pre-locked.
- No test file: these are widget/layout changes — `flutter analyze` is the check (CLAUDE.md + no-hollow-test).

## Human walk (dark first) — PENDING

1. All four dashboard panels show a matching 18px left-aligned title with equal inset/gap.
2. Transactions title is 18px with its segment on the title row, no overflow in the narrow right panel, single (not double) gap to the list.
3. Bitcoin Chart title is 18px.
4. Hovering each nav tab shows icon+label at the vertical center of an inset box that does NOT touch the bar's top edge; underline flush at box bottom, gradient+glow intact, white active text.

## Self-Check: PASSED

- `lib/components/cards/gw_section_title.dart` — FOUND (new, untracked).
- 5 modified files present in `git status --short`: coins_screen, dashboard_markets, transactions_slim_view, dashboard_screen, responsive_overlay — all FOUND.
- No commits created (CLAUDE.md gate); nothing staged — VERIFIED (`git diff --cached` empty).
