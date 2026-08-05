---
phase: 07-token-screens
plan: 06
subsystem: ui
tags: [flutter, drawer, appbar, responsive_drawer, gap-closure, sketch-030]

# Dependency graph
requires:
  - phase: 07-token-screens
    provides: "07-01/07-02 token-detail Receive + token-chart re-skins that exposed gap 4 (oversized close ✕, tall header)"
provides:
  - "ResponsiveDrawer shared shell header re-skinned to sketch 030-B1 'Quiet band': left-aligned title, small top-right close ✕, faint 1px brand hairline, compact toolbar height"
affects: [07-08-walk, any-future-drawer-content-plan]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "AppBar.bottom PreferredSize(height 1) as the standing pattern for a header hairline"
    - "Compact IconButton (iconSize 20, BoxConstraints 36x36, padding zero) as the standing pattern for small top-right AppBar actions, matching the existing web_view_windows/web_view_mobile compact IconButton convention"

key-files:
  created: []
  modified:
    - lib/components/bottom_drawer/responsive_drawer.dart

key-decisions:
  - "Used GeniusWalletColors.brandPrimarySubtle (existing named 'brand-primary-subtle' token, alpha ~12% cyan) directly for the hairline, not a GWColors ThemeExtension field — GWColors has no brand-family field (only surfaces/text/status/border), and this exact token is already used decoratively elsewhere (web_view_windows.dart, web_view_mobile.dart) without going through the extension"
  - "toolbarHeight set to a local compact constant (48) instead of the Flutter default 56 — closes gap 4's 'header too tall' complaint without touching any shared height constant used elsewhere (GeniusWalletConsts.appBarHeight=68 is a different component's token, left untouched)"
  - "Close ✕ appended AFTER caller-supplied actions (`[...?actions, closeButton]`) so it coexists with, rather than replaces, any drawer-specific actions"
  - "Treated the 1px hairline as a decorative separator (not a WCAG 1.4.11 graphical object) since it carries no information on its own — same treatment as the pre-existing gw.borderSubtle hairlines elsewhere in the codebase"

requirements-completed: [SCR-03]

coverage:
  - id: D1
    description: "ResponsiveDrawer AppBar re-skinned to sketch 030-B1: centerTitle:false (left title), no leadingWidth:56 leading well, close ✕ is a small (20px icon / 36x36 tap target) top-right action after caller actions, 1px brandPrimarySubtle hairline via AppBar.bottom, compact toolbarHeight (48)"
    requirement: SCR-03
    verification:
      - kind: unit
        ref: "grep gate: centerTitle:false + no leadingWidth:56 + AppBar.bottom PreferredSize + surfaceMenu retained — PASS"
        status: pass
      - kind: other
        ref: "flutter analyze lib/components/bottom_drawer/responsive_drawer.dart — 0 issues"
        status: pass
      - kind: other
        ref: "flutter analyze lib — 59 issues (baseline 61, no new issue attributable to this file)"
        status: pass
      - kind: other
        ref: "tool/verify_additive_boundary.sh — Check 2 census failure confirmed IDENTICAL before/after via temporary HEAD-content swap (not a regression)"
        status: pass
      - kind: unit
        ref: "flutter test test/ — 250 tests, 1 pre-existing failure (test/local_wallet_storage_test.dart missing main(), unrelated load error) — suite compiles and runs cleanly against the change"
        status: pass
    human_judgment: true
    rationale: "Visual truth (actual header height, ✕ size, hairline appearance in the running app across the ~19 callers) is explicitly deferred to the 07-08 human re-walk per the plan; this plan's own verification is grep/analyze/script/test-suite only, no screenshot was taken here."

# Metrics
duration: ~20min
completed: 2026-07-24
status: complete
---

# Phase 07 Plan 06: ResponsiveDrawer Header Re-skin (sketch 030-B1 Quiet band) Summary

**Re-skinned the shared `ResponsiveDrawer` AppBar chrome to sketch 030-B1's "Quiet band" — left-aligned title, small top-right close ✕, faint 1px brand hairline, compact toolbar height — safely, for all ~19 callers at once.**

## Performance

- **Completed:** 2026-07-24
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- `centerTitle: false` — title is now left-aligned (the app's global `titleTextStyle: GeniusWalletTypography.titleLg` already gives it the 18px sketch-spec size, so no per-widget text-style change was needed).
- Removed the `leadingWidth: 56` leading slot and its padded 48px `IconButton(Icons.close)`. The close ✕ now lives in `actions`, appended AFTER any caller-supplied actions (`[...?actions, closeButton]`), sized to a compact 20px icon inside a 36x36 tap target (`padding: EdgeInsets.zero`, `constraints: BoxConstraints(minWidth: 36, minHeight: 36)`) — mirroring the existing compact-IconButton convention already used in `web_view_windows.dart`/`web_view_mobile.dart`.
- Added a faint 1px hairline under the header via `AppBar.bottom: PreferredSize(preferredSize: Size.fromHeight(1), child: Container(height: 1, color: GeniusWalletColors.brandPrimarySubtle))`.
- Set `toolbarHeight: 48` (a new local `_compactToolbarHeight` constant on `_ResponsiveDrawerScaffold`) in place of the Flutter default 56, closing the "header too tall" gap-4 complaint.
- Preserved everything else exactly: the desktop 420px right-panel / mobile bottom-sheet split in `ResponsiveDrawer.show()`, the appearance-aware `gw.surfaceMenu` background reads (both the open-time capture in `show()` and the live-flip `Theme.of(context).extension<GWColors>()` read in `_ResponsiveDrawerScaffold.build()`), the `elevation: 0` / `backgroundColor: Colors.transparent` AppBar, and the `bottomNavigationBar` footer. No blanket body padding was added — body padding remains each caller's own responsibility, per the plan's explicit prohibition (some of the ~19 callers already pad their own bodies; double-padding would regress them).

## Task Commits

1. **Task 1: Re-skin the ResponsiveDrawer header to sketch 030-B1 quiet band** - `1d43a13` (fix)

**Plan metadata:** (this commit, made after this SUMMARY is written)

## Files Created/Modified
- `lib/components/bottom_drawer/responsive_drawer.dart` - `_ResponsiveDrawerScaffold.build()`'s AppBar re-skinned to sketch 030-B1 quiet-band chrome (left title, small top-right close, 1px hairline, compact height); `ResponsiveDrawer.show()` and everything below the AppBar left untouched.

## Decisions Made
- **Hairline token:** used `GeniusWalletColors.brandPrimarySubtle` (a plain static field, alpha ~12% cyan, NOT branched on `_isLight` internally) directly, rather than routing through `GWColors`'s `ThemeExtension`. `GWColors` has no brand-family field at all (only `surfaceBase/Elevated/Menu/Sunken/Overlay`, the `textPrimary*` ladder, `textSecondary`, `statusSuccess/Error`, `borderSubtle/Strong`) — the plan's must-have text names this exact token ("brand-primary-subtle"), and it's already the established decorative pattern for this precise constant in `web_view_windows.dart`/`web_view_mobile.dart` (both read it directly, not through `gw.*`). Because it's translucent (~12% alpha), it reads as a faint tint on both the dark near-black and light near-white `surfaceMenu` canvases without needing a separate light/dark branch.
- **Toolbar height:** picked 48 (a new file-local constant, not a shared `GeniusWalletConsts` token) since no existing shared "compact app bar height" constant fit this specific header — `GeniusWalletConsts.appBarHeight` (68) is the desktop top-nav bar's height, a different component with a different visual intent; reusing it here would have made the drawer header TALLER, not more compact.
- **Close button placement:** `[...?actions, closeButton]` — appended, not prepended, so caller actions (several drawers pass their own `actions` list) keep their natural left-to-right order and the close ✕ is always the rightmost, outermost control, matching sketch 030-B1's "close top-right" spec.
- **WCAG treatment of the hairline:** treated as decorative (not a WCAG 1.4.11 non-text-contrast "graphical object", since it conveys no information beyond separating two zones already visually distinct by their surface color) — consistent with how the codebase's other faint hairlines (e.g. `gw.borderSubtle` in `responsive_overlay.dart`'s mobile tab bar) are used without a contrast-ratio computation. The close ✕ icon's color/contrast was deliberately left untouched (no explicit `color:` override) — it inherits the same `IconThemeData`/AppBar-derived color the pre-existing close button already used, so this plan does not change (and cannot regress) its pre-existing contrast behavior in either mode.

## Deviations from Plan

None - plan executed exactly as written. The one thing worth flagging as a judgment call rather than a deviation: the plan's `read_first` pointed at `lib/theme/gw_colors.dart` for "the brand-primary-subtle / hairline token," but that class has no such field — see "Decisions Made" above for why `GeniusWalletColors.brandPrimarySubtle` (the source-of-truth static token this constant is actually named after) was used instead.

## Issues Encountered
- `tool/verify_additive_boundary.sh` Check 2 (duplicate public class name census) fails both BEFORE and AFTER this change, listing `_Section`, `_SplashState`, `_TimeframeSegment`, `_TimeframeSegmentState`, `_TimeframeTab`, `_TimeframeTabState` — none of which are declared in or related to `responsive_drawer.dart`. Confirmed identical by temporarily swapping the working file's content back to the `HEAD` version (via `git show HEAD:<path>`, not `git stash`, since sibling in-flight commits on the same non-worktree checkout make a plain content-swap-and-restore simpler than a stash push/pop), re-running the script, then restoring the edited file — the failure list was byte-identical in both runs. This is the plan's documented "known pre-existing census failure," not a regression from this task.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- The shared `ResponsiveDrawer` shell now matches sketch 030-B1 for all ~19 callers at once. Visual confirmation (actual rendered header height, ✕ size, hairline visibility in both dark/light modes, and a spot-check of at least one non-Receive drawer such as "More") is deferred to the 07-08 human re-walk, per this plan's own scope.
- No blockers for 07-08.

---
*Phase: 07-token-screens*
*Completed: 2026-07-24*

## Self-Check: PASSED
- FOUND: lib/components/bottom_drawer/responsive_drawer.dart
- FOUND: .planning/phases/07-token-screens/07-06-SUMMARY.md
- FOUND commit: 1d43a13
