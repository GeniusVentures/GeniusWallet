---
phase: 04-navigation-shell-chrome
plan: 03
subsystem: ui
tags: [flutter, theme-extension, navigation-shell, bottom-nav, go_router, design-system]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome
    provides: "04-02's GWColors ThemeExtension (attached to ThemeData in both light/dark branches) and the fail-soft const-widget read pattern (`Theme.of(context).extension<GWColors>() ?? GWColors.dark()`) that forces const subtrees to rebuild on a live appearance toggle -- responsive_overlay.dart was 04-02's explicit migration_surface DEFERRAL, handed to this plan"
provides:
  - "_DesktopTopBar and _MobileTabBar (both const-instanced) re-skinned to read appearance-aware surfaces/text/borders from GWColors via context, so the desktop top bar and mobile bottom nav flip LIVE on an in-place appearance toggle"
  - "DesktopOverlay's Scaffold background migrated off the hardcoded deepBlueTertiary constant to gw.surfaceBase"
  - "Mobile bottom nav re-skinned with Gen-B's token vocabulary (brandPrimary selected / textSecondary unselected / labelMd labels / borderSubtle hairline / surfaceSheen background) applied to develop's full 8-destination set"
affects: [04-04, 04-05, 04-06, 04-07]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Same const-widget fail-soft GWColors read pattern from 04-02 (`final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` at top of build()), now applied to the two const shell widgets (_DesktopTopBar, _MobileTabBar) plus the non-const DesktopOverlay wrapper for consistency and defense against future const-ification"
    - "GWDecorations.surfaceSheen (an already appearance-aware static getter, reads GWAppearance.isLight directly) is safe to call unguarded inside a widget whose build() already contains a `gw` read -- the ancestor Theme dependency is what forces the re-evaluation, not the getter's own access path"
    - "Widget-level BottomNavigationBar overrides (selectedItemColor/unselectedItemColor/selectedIconTheme/unselectedIconTheme/selectedLabelStyle/unselectedLabelStyle/showSelectedLabels/showUnselectedLabels) take precedence over the app-wide bottomNavigationBarTheme in theme.dart, which currently hides labels (showSelectedLabels/showUnselectedLabels: false) and colors unselected icons with textPrimary instead of textSecondary -- both corrected at the widget level without touching theme.dart (out of this plan's file scope)"

key-files:
  created: []
  modified:
    - lib/components/overlay/responsive_overlay.dart

key-decisions:
  - "Bottom-nav background: GWDecorations.surfaceSheen (not transparent) -- consistent with Gen-B's gw_bottom_nav.dart reference and the rest of the redesign's elevated-surface treatment. Recorded explicitly per the plan's §2.5 instruction."
  - "Fixed DesktopOverlay's Scaffold backgroundColor (GeniusWalletColors.deepBlueTertiary -> gw.surfaceBase) in Task 1 even though Task 1's <action> text is scoped to '_DesktopTopBar's chrome' -- the task's own <done> criteria explicitly names deepBlueTertiary as something that must not survive, and deepBlueTertiary only appears in DesktopOverlay, not _DesktopTopBar. Treated as Rule 2 (missing critical functionality / UI-SPEC §8's explicit trap: 'leaving even one deepBlueCardColor/deepBlueTertiary behind after this phase reintroduces exactly the dark-only-surface problem 04-01 exists to close')."
  - "showSelectedLabels/showUnselectedLabels explicitly set true on the widget-level BottomNavigationBar -- the app-wide bottomNavigationBarTheme in theme.dart currently sets both false, which would have hidden all 8 tab labels regardless of this plan's per-item styling. This is a necessity to satisfy the plan's explicit 'labels labelMd' requirement, not a stylistic add. theme.dart itself was not touched (out of this plan's file_modified scope)."
  - "'Buy GNUS' button text and the desktop destination labels both moved off raw TextStyle(fontSize: ...) onto GeniusWalletTypography.labelMd -- the Buy GNUS text carries no explicit color override (relies on ElevatedButtonThemeData's foregroundColor resolveWith, already GeniusWalletColors.textPrimary, already correct and already rebuilds correctly since the button is non-const and nested under _DesktopTopBar's now-forced rebuild)."
  - "MobileOverlay's AppBar (title + action-row Flexible/SingleChildScrollView) was left completely untouched -- it is non-const, sets no raw hex/px, and already inherits background/title styling correctly from the app-wide AppBarTheme (surfaceElevated bg, titleLg text) wired in 04-01. 'Re-skin its colors/type only' is satisfied by the pre-existing theme wiring; no widget-level change was needed or made."

requirements-completed: [NAV-01, NAV-02]

coverage:
  - id: D1
    description: "_DesktopTopBar re-skinned: gw.surfaceElevated background, GeniusWalletColors.brandPrimary selected accent (static, mode-invariant) / gw.textSecondary unselected ink, GeniusWalletTypography.labelMd destination labels and Buy GNUS CTA text, all read via the fail-soft Theme.of(context).extension<GWColors>() pattern so the const widget flips live on toggle; DesktopOverlay's Scaffold background migrated off deepBlueTertiary to gw.surfaceBase"
    requirement: "NAV-01"
    verification:
      - kind: other
        ref: "flutter analyze lib/components/overlay/responsive_overlay.dart -- No issues found (Task 1 commit 0eefccd)"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 1 commit 0eefccd"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 shell walk (blocking-human checkpoint) -- confirms the live-flip and WCAG AA visually in the running app; NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze proves the code reads the right token but cannot prove the const top bar visually re-skins live in the running app, meets WCAG AA in both modes, or that all 8 routes remain reachable with no runtime exception -- that requires the Task 3 human shell walk (checkpoint:human-verify, gate=\"blocking\"), which is outstanding."
  - id: D2
    description: "_MobileTabBar re-skinned with Gen-B's token vocabulary (brandPrimary selected / textSecondary unselected / labelMd labels / borderSubtle 0.5px top hairline / surfaceSheen background) applied to develop's full 8-destination set, never Gen-B's reduced 4-item list; develop's mobile AppBar retained unchanged; no shell-level GWCanvasBackground added; Web tab still resolves to /web"
    requirement: "NAV-01"
    verification:
      - kind: other
        ref: "flutter analyze lib/components/overlay/responsive_overlay.dart -- No issues found (Task 2 commit 0862dec)"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 2 commit 0862dec"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 shell walk (blocking-human checkpoint) -- confirms the live-flip, WCAG AA, and the breakpoint flip visually; NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze proves the code reads the right token but cannot prove the const bottom nav visually re-skins live in the running app or that all 8 destinations are tappable/reachable end to end -- that requires the Task 3 human shell walk, which is outstanding."

duration: ~5min (Tasks 1-2 only; Task 3 is a blocking-human checkpoint, not yet performed)
completed: 2026-07-18
status: blocked
---

# Phase 04 Plan 03: Navigation Shell Chrome Re-Skin Summary

**Re-skinned develop's `_DesktopTopBar`/`_MobileTabBar` (both const-instanced) onto the GWColors ThemeExtension so the desktop top bar and mobile bottom nav flip live on an in-place appearance toggle, composing Gen-B's token vocabulary onto develop's unchanged 8-destination set.**

Tasks 1-2 (both `type="auto"`) are complete and committed. **Task 3 — the shell walk (criteria 1 + 2, both appearance modes) — is a `checkpoint:human-verify` (`gate="blocking"`) and has NOT been performed.** This SUMMARY documents the auto-task work only; the walk that confirms it actually works live in the running app remains outstanding.

## Performance

- **Started:** ~2026-07-18T10:05 (local)
- **Completed (Tasks 1-2):** 2026-07-18T10:12:09-03:00 (Task 2 commit timestamp)
- **Duration:** ~7 min
- **Tasks:** 2 of 3 (Task 3 pending human verification)
- **Files modified:** 1 (`lib/components/overlay/responsive_overlay.dart`)

## Accomplishments

- `_DesktopTopBar.build()` adds the fail-soft `gw` read (`Theme.of(context).extension<GWColors>() ?? GWColors.dark()`); background `GeniusWalletColors.deepBlueCardColor` -> `gw.surfaceElevated`; unselected destination-label/icon ink `Colors.white.withValues(alpha: 0.6)` -> `gw.textSecondary`; selected accent `Colors.greenAccent` -> static `GeniusWalletColors.brandPrimary` (mode-invariant, left off `gw`); raw `TextStyle(fontSize: 14, ...)` on both the destination labels and the "Buy GNUS" CTA replaced with `GeniusWalletTypography.labelMd`.
- `DesktopOverlay.build()` adds its own fail-soft `gw` read; `Scaffold.backgroundColor` migrated from the hardcoded `GeniusWalletColors.deepBlueTertiary` to `gw.surfaceBase`.
- `_MobileTabBar.build()` adds the fail-soft `gw` read and wraps `BottomNavigationBar` in a `Container` carrying `GWDecorations.surfaceSheen` as background plus a `gw.borderSubtle` 0.5px top hairline (Gen-B's token vocabulary, §2.5) — applied to develop's full, unmodified 8-destination set.
- `BottomNavigationBar` widget-level overrides added: `selectedItemColor`/`selectedIconTheme` = static `GeniusWalletColors.brandPrimary`, `unselectedItemColor`/`unselectedIconTheme` = `gw.textSecondary`, `selectedLabelStyle`/`unselectedLabelStyle` = `GeniusWalletTypography.labelMd` with `FontWeight.w600`/`w500` respectively, `showSelectedLabels`/`showUnselectedLabels` = `true` (overriding the app-wide `bottomNavigationBarTheme` in `theme.dart`, which currently hides both), `type: BottomNavigationBarType.fixed` (explicit, matching the app-wide theme's existing value, kept for self-containment).
- Neither the desktop action row (`DevToolsWidget`, `NetworkDropdownSelector`, `SDKAccountManagerButton`, `AccountDropdownSelector`, `ReownConnectButton`, "Buy GNUS") nor the mobile `AppBar` (title + action row) was restructured, reordered, or had membership changed — both are exactly as they were, only re-skinned where they touched hardcoded tokens.
- `_currentIndex(BuildContext)` (GoRouterState-derived selection) untouched; no `NavigationOverlayCubit` introduced. `GeniusWalletConsts.appBarHeight` (60) untouched. `GeniusBreakpoints`-based desktop/mobile split in `router.dart` untouched (not a file this plan modifies).

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Re-skin the desktop top bar chrome** - `0eefccd` (feat)
2. **Task 2: Re-skin the mobile bottom nav with the Gen-B token vocabulary on develop's 8 destinations** - `0862dec` (feat)

**Task 3: Shell walk — criteria 1 + 2, both appearance modes — NOT YET PERFORMED** (`checkpoint:human-verify`, `gate="blocking"`). No plan-metadata commit has been made; STATE.md/ROADMAP.md are owned by the orchestrator and not updated by this run.

## Files Created/Modified

- `lib/components/overlay/responsive_overlay.dart` — `_DesktopTopBar`, `DesktopOverlay`, `_MobileTabBar` re-skinned per the above; `_TabDestination` list (8 items, order, `/web` path), `_currentIndex`, `MobileOverlay`'s `AppBar`, and the action-row builder function (`_buildActionRowWidgets`) all untouched.

## Decisions Made

- Bottom-nav background: `GWDecorations.surfaceSheen`, not transparent — matches Gen-B's `gw_bottom_nav.dart` reference file and the rest of the redesign's elevated-surface treatment. Recorded per §2.5's explicit instruction to record the choice.
- Fixed `DesktopOverlay`'s `deepBlueTertiary` background in Task 1 even though Task 1's `<action>` prose is scoped to "`_DesktopTopBar`'s chrome" — its own `<done>` criteria explicitly names `deepBlueTertiary` as something that must not survive, and that token only appears in `DesktopOverlay`, not `_DesktopTopBar`. Treated as Rule 2 (missing critical functionality / the exact §8 UI-SPEC trap this phase exists to close).
- `showSelectedLabels`/`showUnselectedLabels` explicitly forced `true` at the widget level — the app-wide `bottomNavigationBarTheme` in `theme.dart` currently sets both `false`, which would silently hide all 8 tab labels regardless of this plan's per-item label styling. Necessary to satisfy the plan's explicit "labels labelMd" requirement; `theme.dart` itself was not touched (out of this plan's `file_modified` scope).
- "Buy GNUS" button text moved to `GeniusWalletTypography.labelMd` with no explicit color override — inherits from `ElevatedButtonThemeData.foregroundColor` (already `GeniusWalletColors.textPrimary`), which is correct and already rebuilds properly since the button is non-const, nested inside `_DesktopTopBar`'s now-forced rebuild.
- `MobileOverlay`'s `AppBar` left completely untouched — non-const, no raw hex/px, already inherits correct background/title styling from the app-wide `AppBarTheme` wired in 04-01.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Fixed `DesktopOverlay`'s hardcoded `deepBlueTertiary` background**
- **Found during:** Task 1
- **Issue:** Task 1's `<action>` prose named only `_DesktopTopBar`, but `deepBlueTertiary` — explicitly listed in Task 1's own `<done>` criteria as something that must not survive — is actually used by `DesktopOverlay.build()`'s `Scaffold.backgroundColor`, not `_DesktopTopBar`. Leaving it would reintroduce the dark-only-surface problem UI-SPEC §8 calls out by name.
- **Fix:** Added a fail-soft `gw` read to `DesktopOverlay.build()`; `backgroundColor: gw.surfaceBase` replaces the hardcoded constant.
- **Files modified:** `lib/components/overlay/responsive_overlay.dart`
- **Verification:** `flutter analyze` clean, additive-boundary guard passed, `grep` confirms zero remaining `deepBlueTertiary`/`deepBlueCardColor` references in the file.
- **Committed in:** `0eefccd` (Task 1 commit)

**2. [Rule 2 - Missing Critical] Forced `showSelectedLabels`/`showUnselectedLabels` true on the mobile bottom nav**
- **Found during:** Task 2
- **Issue:** The app-wide `bottomNavigationBarTheme` in `theme.dart` sets `showSelectedLabels: false, showUnselectedLabels: false` globally. Without an explicit widget-level override, none of the 8 destination labels would render, directly contradicting Task 2's `<action>`/`<done>` requirement that labels use `GeniusWalletTypography.labelMd` with distinct selected/unselected weights.
- **Fix:** Added explicit `showSelectedLabels: true, showUnselectedLabels: true` (plus `selectedIconTheme`/`unselectedIconTheme` overrides so unselected icons use `gw.textSecondary` instead of the theme's `textPrimary`) to the widget-level `BottomNavigationBar` inside `_MobileTabBar`. `theme.dart` itself was not touched — this is a local, per-widget override, staying within this plan's `file_modified` scope.
- **Files modified:** `lib/components/overlay/responsive_overlay.dart`
- **Verification:** `flutter analyze` clean, additive-boundary guard passed. Visual confirmation of labels actually rendering is part of the outstanding Task 3 walk.
- **Committed in:** `0862dec` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 2 - missing critical functionality, both required to meet this plan's own explicit `<done>` criteria)
**Impact on plan:** Both fixes are narrowly scoped, token-only substitutions within the single file this plan already modifies. No scope creep, no restructuring, no new files.

## Issues Encountered

None. `flutter analyze` and `bash tool/verify_additive_boundary.sh` passed cleanly after both auto tasks with no fix-attempt iterations needed.

## Verification Results

- **`flutter analyze lib/components/overlay/responsive_overlay.dart`** (per-task scoped, as specified in each task's `<verify>`): "No issues found!" after both Task 1 and Task 2.
- **`flutter analyze lib`** (full repo, extra sanity check beyond the plan's per-task scope): 62 issues (0 errors), matching the phase's known ~62-issue pre-existing baseline exactly, with `grep` confirming zero of them touch `responsive_overlay.dart`.
- **`bash tool/verify_additive_boundary.sh`**: PASSED after both Task 1 and Task 2 — no shadow-import drift, duplicate-class census unchanged, no `WIRE-` markers.
- **Destination set integrity:** confirmed by `grep -n "_TabDestination("` — all 8 `_TabDestination(...)` construction sites present, unmodified, in original order (Dashboard, Transactions, Swap, Markets, News, Web, Feedback, Settings — note: the array's literal order is Dashboard/Transactions/Swap/Markets/News/Web/Feedback/Settings, matching develop; the Web entry's `path: '/web'` is byte-identical to before the diff).

## Known Stubs

None — no hardcoded empty values, placeholder text, or unwired data sources were introduced.

## Threat Flags

None — all changes fall within the plan's declared `<threat_model>`, all mitigated as specified: the additive-boundary guard (T-04-03-01) passed after every task; selection remains single-sourced from `_currentIndex`/`GoRouterState`, no `NavigationOverlayCubit` introduced (T-04-03-02); no `preferences_button.dart` import, no transitive import of out-of-scope surfaces (T-04-03-03).

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

Tasks 1-2 landed the token-correct, appearance-aware `responsive_overlay.dart` re-skin (both `_DesktopTopBar` and `_MobileTabBar`, plus `DesktopOverlay`'s background). `flutter analyze` is clean against the established baseline and the additive-boundary guard is green after every task. **Task 3 — the human shell walk confirming the live-flip, WCAG AA contrast in both modes, and boot/nav-exception-free operation across all 8 routes — is still outstanding** and blocks this plan's close. `04-04..07` should not be treated as unblocked by this SUMMARY alone; the Task 3 gate must close first, per the same D-02-style pattern 04-02 established.

---
*Phase: 04-navigation-shell-chrome*
*Completed: 2026-07-18 (Tasks 1-2 only; Task 3 outstanding)*

## Self-Check: PASSED

Modified file verified present on disk (`lib/components/overlay/responsive_overlay.dart`), this SUMMARY.md verified present on disk. Both task commit hashes (`0eefccd`, `0862dec`) verified present in `git log --oneline --all`.
