---
phase: quick-260721-ed9
plan: 01
subsystem: ui-navbar
tags: [top-bar, nav-chips, connect, buy-gnus, sketch-005]
status: complete
dependency-graph:
  requires: []
  provides: [nav_chip_style.dart shared 40px shell/quiet-chip builders]
  affects:
    - lib/network/network_dropdown_selector.dart
    - lib/account/sdk_account_manager.dart
    - lib/account/account_dropdown_selector.dart
    - lib/reown/reown_connect_button.dart
    - lib/components/buttons/gw_button.dart
    - lib/components/overlay/responsive_overlay.dart
tech-stack:
  added: []
  patterns:
    - "Local TextButton.styleFrom overrides instead of touching the shared theme.dart textButtonTheme"
    - "Additive optional height param on GWButton (default null preserves existing size-based heights app-wide)"
key-files:
  created:
    - lib/theme/nav_chip_style.dart
    - test/theme/nav_chip_style_test.dart
  modified:
    - lib/network/network_dropdown_selector.dart
    - lib/account/sdk_account_manager.dart
    - lib/account/account_dropdown_selector.dart
    - lib/reown/reown_connect_button.dart
    - lib/components/buttons/gw_button.dart
    - lib/components/overlay/responsive_overlay.dart
decisions:
  - "navChipShell pins height via BOTH minimumSize AND maximumSize (not fixedSize+Size.fromHeight, which is infinite-width and would blow up the unbounded right Row) plus tapTargetSize.shrinkWrap + VisualDensity.compact so Material's 48px tap floor can't re-inflate the pinned 40px"
  - "navContextChipStyle's hover border is wired via WidgetStateProperty.resolveWith on side (styleFrom's plain side arg is not state-aware)"
  - "connectBrandColor(context) gates on the existing GWAppearance.isLight signal (no new signal invented): dark keeps brandPrimaryStrong (0xFF0AAEE6, clears AA on dark surfaceElevated 0xFF0C0E14), light uses 0xFF0B6E8F (5.8:1+ verified >=4.5:1 in the test) since raw brandPrimaryStrong on light's pure-white surfaceElevated is only ~2.1:1"
  - "GWButton gained an additive optional `height` field (ponytail: local override, default null preserves 48 for every existing md call site) rather than touching GWButtonSize.md app-wide"
metrics:
  duration: ~25min
  completed: 2026-07-21
---

# Quick Task 260721-ed9: Re-skin top-bar right cluster per sketch 005 winner B Summary

One-liner: Normalized all five desktop top-bar right-cluster controls (3 context chips, Connect, Buy GNUS) to a single 40px family via a new shared `nav_chip_style.dart` ButtonStyle builder, applied as local per-control overrides — `theme.dart`'s shared `textButtonTheme` and `GWButtonSize.md` (48, used app-wide) were left untouched.

## What was built

**Task 1 — shared chip builder + runnable check:**
- `lib/theme/nav_chip_style.dart` (new): three top-level functions, no new widget/abstraction.
  - `navChipShell(context)` — the 40px/radiusMd(12)/space6(12)-padding shell shared by all five controls.
  - `navContextChipStyle(context)` — shell + `gw.surfaceMenu` fill, `gw.borderSubtle` rest border, `gw.borderStrong` hover border (state-aware via `WidgetStateProperty.resolveWith` on `side`).
  - `connectBrandColor(context)` — appearance-aware Connect brand color (dark = `brandPrimaryStrong`, light = `0xFF0B6E8F`).
- `test/theme/nav_chip_style_test.dart` (new): 3 tests — shell height (min+max resolve to 40) and radius (12); context-chip style resolves `surfaceMenu` fill and `borderSubtle`→`borderStrong` on hover; both Connect brand colors clear ≥4.5:1 WCAG AA (via `Color.computeLuminance()`, Flutter's built-in relative-luminance implementation — no reimplemented luminance math). **All 3 tests pass.**

**Task 2 — three context chips (chain / SDK / wallet):**
- `network_dropdown_selector.dart`, `sdk_account_manager.dart`, `account_dropdown_selector.dart`: each `TextButton` now carries `style: navContextChipStyle(context)`; internal Row spacing changed from hardcoded `6.0` to `GeniusWalletConsts.space4` (8). Behavior, drawers, responsive label-drop guards, and the SDK-empty `SizedBox.shrink()` early return are all unchanged.

**Task 3 — Connect + Buy GNUS + row gap:**
- `reown_connect_button.dart`: idle "Connect" branch now reads `connectBrandColor(context)` for icon/text/border instead of the hardcoded `brandPrimaryStrong` (so it clears AA in light mode too); button style switched from a bare `TextButton.styleFrom(backgroundColor, side)` to `navChipShell(context).copyWith(backgroundColor: ..., side: ...)`, adopting the 40px/radiusMd/padding shell while keeping its per-state fill+border. All 5 states (idle/connected/connecting/timed-out/retry) and their status colors are preserved verbatim; only shell shape+height changed.
- `gw_button.dart`: added an additive `final double? height` field (default `null`) consumed by `_height` (`height ?? <existing size switch>`). `GWButtonSize.md` itself is untouched — still 48 everywhere except the one call site that passes `height: 40`.
- `responsive_overlay.dart`: the `_DesktopTopBar` right `Row` (wrapping `_buildActionRowWidgets` + Buy GNUS) gained `spacing: GeniusWalletConsts.space4`; the Buy GNUS `GWButton` now passes `height: 40` (variant stays `gradient`, size stays `md` — only height drops to match the family). MobileOverlay's Row was intentionally left untouched (mobile out of scope for this sketch).

## Verification

- `flutter test test/theme/nav_chip_style_test.dart` → **3/3 PASSED** (height-40, radiusMd, surfaceMenu fill, borderSubtle→borderStrong hover, both Connect AA contrasts).
- `flutter analyze` on all 7 touched/created files → **clean**, except 3 pre-existing `info`-level `use_build_context_synchronously` warnings (1 in `network_dropdown_selector.dart:76`, 2 in `reown_connect_button.dart:160,405`) that are unrelated to this task's diff — confirmed via `git diff` that none of those lines were touched by this plan's edits. Per CLAUDE.md/deviation-rule scope boundary, these are out of scope and were left alone (not fixed, not hidden).
- Trap checks: `git diff lib/theme/theme.dart` shows **no change** to `textButtonTheme`; `GWButtonSize.md` still returns **48** in `gw_button.dart` (verified by grep).
- `git status --short` confirms all 6 modified files + 2 new files remain **unstaged/untracked working-tree changes** — nothing staged, nothing committed.

**No commits created — all changes left in the working tree.** No `git add`, `git stage`, `git rm`, or `git commit` was run at any point; the only git commands used were read-only (`git status`, `git diff`, `git log`).

## Files changed

| File | Note |
|---|---|
| `lib/theme/nav_chip_style.dart` | NEW — shared `navChipShell` / `navContextChipStyle` / `connectBrandColor` builders |
| `test/theme/nav_chip_style_test.dart` | NEW — runnable check (height/radius/fill/hover + both AA contrasts), 3/3 passing |
| `lib/network/network_dropdown_selector.dart` | chain chip → `navContextChipStyle`, internal gap → `space4` |
| `lib/account/sdk_account_manager.dart` | SDK chip → `navContextChipStyle`, internal gap → `space4` |
| `lib/account/account_dropdown_selector.dart` | wallet chip → `navContextChipStyle`, internal gap → `space4` |
| `lib/reown/reown_connect_button.dart` | idle Connect → appearance-aware `connectBrandColor`; button style → `navChipShell(context).copyWith(...)`; inner Row gap → `space4` |
| `lib/components/buttons/gw_button.dart` | additive optional `height` field/getter (default null, `GWButtonSize.md` unchanged at 48) |
| `lib/components/overlay/responsive_overlay.dart` | right Row gains `spacing: space4`; Buy GNUS `GWButton` gains `height: 40` |

## Outstanding

- **Walk pending** (Jakub, macOS, both light and dark) per the plan's verification recipe: `flutter run -d macos --dart-define=GW_DEV_TOOLS=true`.
- Reconciled cleanly with the ~210 pre-existing uncommitted lines already in `responsive_overlay.dart` (and `reown_connect_button.dart`) from this session's other in-flight quick tasks (e.g. `eu9`'s appearance-aware `btnFilter`, `bxr`'s nav-tab Design C, `1nk`'s navbar-B underline) — none of that prior work was reverted; this plan's diff is additive on top of it.

## Known Stubs

None.

## Threat Flags

None — pure presentational re-skin, no new trust boundaries, no new inputs, no packages installed.

## Self-Check: PASSED

- `lib/theme/nav_chip_style.dart` — FOUND
- `test/theme/nav_chip_style_test.dart` — FOUND
- `lib/network/network_dropdown_selector.dart` (modified) — FOUND, contains `navContextChipStyle`
- `lib/account/sdk_account_manager.dart` (modified) — FOUND, contains `navContextChipStyle`
- `lib/account/account_dropdown_selector.dart` (modified) — FOUND, contains `navContextChipStyle`
- `lib/reown/reown_connect_button.dart` (modified) — FOUND, contains `navChipShell` + `connectBrandColor`
- `lib/components/buttons/gw_button.dart` (modified) — FOUND, contains `height` field
- `lib/components/overlay/responsive_overlay.dart` (modified) — FOUND, contains `spacing: GeniusWalletConsts.space4` and `height: 40`
- No commits: `git log --oneline -3` HEAD unchanged at `7a95e68` (pre-execution HEAD) — CONFIRMED
