---
phase: 03-gw-component-library
plan: 05
subsystem: ui
tags: [flutter, gw-components, port, layout, bottom-drawer, overlays, findings-13-25-26]

# Dependency graph
requires:
  - phase: 03-04
    provides: registration_header.g.dart (imported by app_screen_with_header_desktop/mobile.dart) -- this plan's only reason for being wave 3
provides:
  - "6 layout/screen-wrapper primitives (AppScreenView, AppScreenWithHeaderDesktop, AppScreenWithHeaderMobile, DesktopBodyContainer, ResponsiveGrid, GWScreen), all landed dormant/unconsumed"
  - "BottomDrawer -- content chrome for develop's existing ResponsiveDrawer.show(), landed unconsumed, demoed by plan 03-09"
  - "GWBottomSheet, GWDialog -- generic modal helpers, both orphaned on the source branch, ported for inventory completeness"
  - "Findings 13/25/26 re-verified line-by-line as already-correct on develop's untouched responsive_drawer.dart, and their binding rule recorded for Phase 4"
affects: [03-09, 03-10, 04]

tech-stack:
  added: []
  patterns:
    - "Version-delta fix lives in the consumer, not the protected collision file: when a reference-branch API (GeniusBreakpoints.isNativeApp(context)) doesn't exist on develop's version of a zero-diff-required collision file (breakpoints.dart), the fix is applied to the file that calls it, using develop's closest existing equivalent -- same shape as 03-04's FaIcon precedent, applied to a different collision surface"

key-files:
  created:
    - lib/components/app_screen_view.dart
    - lib/components/app_screen_with_header_desktop.dart
    - lib/components/app_screen_with_header_mobile.dart
    - lib/components/desktop_body_container.dart
    - lib/components/responsive_grid.dart
    - lib/components/scaffold/gw_screen.dart
    - lib/components/bottom_drawer/bottom_drawer.dart
    - lib/components/overlays/gw_bottom_sheet.dart
    - lib/components/overlays/gw_dialog.dart
  modified: []

key-decisions:
  - "Rule 3 auto-fix: responsive_grid.dart's GeniusBreakpoints.isNativeApp(context) does not exist on develop's breakpoints.dart -- a version delta (reference: medium=1644, has isNativeApp(context)+getPlaform+small/tablet; develop: medium=768, no isNativeApp, only no-arg isMobileApp()). breakpoints.dart is this plan's own zero-diff-protected collision file, so the fix was applied in the consumer: GeniusBreakpoints.isNativeApp(context) -> GeniusBreakpoints.isMobileApp() (develop's closest equivalent, drops the unused context arg it doesn't need)."
  - "Findings 13/25/26 confirmed already-true on develop's responsive_drawer.dart (unmodified, zero diff) -- useRootNavigator defaults true (line 13), enableDrag defaults true (line 15), GeniusBreakpoints.medium=768 used for the desktop breakpoint (line 18, breakpoints.dart line 9). Alex's regressed responsive_drawer.dart (hardcoded 800, enableDrag: false in the source tree) intentionally NOT ported -- it is the regression, not the fix."
  - "BottomDrawer landed as content chrome only, per plan: it supplies its own header and must be shown via ResponsiveDrawer.show() with title/actions omitted so _ResponsiveDrawerScaffold renders no competing AppBar. This binding rule carries forward to Phase 4 (see Binding Rule section below)."

requirements-completed: [DS-02]

coverage:
  - id: D1
    description: "All 9 layout, screen-wrapper and overlay files exist at their verified paths; 8 of 9 byte-identical to the reference worktree, responsive_grid.dart carries the one documented Rule 3 fix"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "test -f for all 9 verified paths (all present); cmp -s against reference worktree -- 8 IDENTICAL, responsive_grid.dart diverges only at the documented isNativeApp->isMobileApp call site"
        status: pass
    human_judgment: false
  - id: D2
    description: "responsive_drawer.dart and breakpoints.dart (collision files) show zero diff and still carry useRootNavigator=true, enableDrag=true, medium=768 -- findings 13/25/26 proven already-correct, not regressed"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "git diff --name-only -- lib/components/bottom_drawer/responsive_drawer.dart lib/utils/breakpoints.dart returned empty; positive greps for useRootNavigator=true, enableDrag=true, GeniusBreakpoints.medium, medium=768 all matched; negative grep for width>=800|width>800 under bottom_drawer/ returned 0 matches; exactly 2 files under bottom_drawer/ (bottom_drawer.dart + responsive_drawer.dart, Alex's regressed copy not added)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Zero nav-shell (Phase 4 NAV-01/NAV-02 scope) files leaked into this plan"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "explicit test -f absence check for all 9 components/overlay/ nav-shell files -- none present"
        status: pass
    human_judgment: false
  - id: D4
    description: "flutter analyze lib reports 0 errors after both task commits (54 total info/warning issues -- net +4 from 03-04's 50-issue baseline, all 4 new use_super_parameters info-level lints on this plan's own new files)"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "flutter analyze lib -- 0 errors, 54 issues (info/warning only), confirmed after both task commits"
        status: pass
    human_judgment: false
  - id: D5
    description: "tool/verify_additive_boundary.sh exits 0 after both task commits"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED (exit 0): Check 1 (shadow import boundary) PASS x6, Check 2 (duplicate-class census, still 7 names, subset of baseline) PASS, Check 3 (WIRE- tripwire) PASS"
        status: pass
    human_judgment: false
  - id: D6
    description: "Visual/render correctness of the 9 new files, and the drawer's real open/dismiss/breakpoint-flip behavior"
    human_judgment: true
    rationale: "Dart-only additions, nothing imports any of the 9 files yet -- no build() is called, nothing changes on screen. The drawer's real behavioral proof (mounts over the whole app, swipes to dismiss at mobile width, flips to the desktop side-dialog at exactly 768px) is deferred to plan 03-09's gallery walk per the plan's own <verify><human-check>, which this plan cannot perform (no consumer exists yet)."

# Metrics
duration: 7min
completed: 2026-07-16
status: complete
---

# Phase 3 Plan 05: Layout, BottomDrawer, and Overlays Summary

**Ported 9 layout/screen-wrapper/overlay primitives including `BottomDrawer`, and re-verified findings 13/25/26 as already-correct on develop's untouched `responsive_drawer.dart` -- one Rule 3 mechanical fix for a `GeniusBreakpoints` API version delta.**

## Performance

- **Duration:** 7 min
- **Started:** 2026-07-16T21:14:00Z (approx)
- **Completed:** 2026-07-16T21:21:13Z
- **Tasks:** 2/2
- **Files modified:** 9 (9 created, 0 modified)

## Accomplishments
- Ported 6 layout/screen-wrapper primitives verbatim: `AppScreenView`, `AppScreenWithHeaderDesktop`, `AppScreenWithHeaderMobile` (both depending on 03-04's `registration_header.g.dart`), `DesktopBodyContainer` (distinct from the pre-existing collision file `DesktopContainer`), `ResponsiveGrid`, `GWScreen` (deliberately overlapping in intent with `AppScreenView`, per UI-SPEC §2.5 -- both ported, neither consolidated)
- Ported `BottomDrawer` (modal content chrome: centered title, left close-X, divider, scrollable `ListView.builder` body, optional footer, `deepBlueTertiary` background) -- landed unconsumed, demoed by plan 03-09
- Ported `GWBottomSheet` and `GWDialog` (both orphaned on the source branch, zero callers) for inventory completeness -- flagged as non-canonical; `ResponsiveDrawer` remains the documented sheet/dialog pattern
- Re-verified findings 13, 25, 26 line-by-line on develop's `lib/components/bottom_drawer/responsive_drawer.dart`, confirmed unmodified (zero diff): `useRootNavigator` defaults `true` (finding 13), `enableDrag` defaults `true` (finding 25), desktop breakpoint uses `GeniusBreakpoints.medium` = 768, not a hardcoded 800 (finding 26)
- Rule 3 auto-fix: `responsive_grid.dart`'s `GeniusBreakpoints.isNativeApp(context)` doesn't exist on develop's `breakpoints.dart` -- fixed in the consumer since `breakpoints.dart` is this plan's own zero-diff-protected file
- Confirmed zero nav-shell (Phase 4 scope) files leaked in
- `flutter analyze lib`: 0 errors (54 total info/warning issues, +4 from 03-04's baseline, all 4 being `use_super_parameters` info on this plan's new files)
- `bash tool/verify_additive_boundary.sh`: PASSED after both task commits

## Task Commits

Each task was committed atomically:

1. **Task 1: Port the six layout and screen-wrapper primitives** - `018a9cf` (feat)
2. **Task 2: Port BottomDrawer as content chrome, and bind findings 13/25/26** - `eba5a17` (feat)

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Created/Modified
- `lib/components/app_screen_view.dart` - `AppScreenView`; `SafeArea` + `CustomScrollView` with a `body` sliver and bottom-pinned `footer` sliver. Corrects 02-UI-SPEC.md §9's imprecise "existing develop widget" characterization -- verified it does not exist on develop, it is additive
- `lib/components/app_screen_with_header_desktop.dart` / `app_screen_with_header_mobile.dart` - `AppScreenWithHeaderDesktop` / `AppScreenWithHeaderMobile`; screen-level header + body wrappers, import `registration_header.g.dart`. Verified by caller trace: exclusively imported by un-ported onboarding screens and `pin_screen.dart` (Phase 4/6 territory) -- not app-shell chrome despite the name
- `lib/components/desktop_body_container.dart` - `DesktopBodyContainer`; desktop max-width/padding wrapper, distinct from the pre-existing `DesktopContainer` collision file
- `lib/components/responsive_grid.dart` - `ResponsiveGrid`; responsive column grid. One Rule 3 fix (see Deviations)
- `lib/components/scaffold/gw_screen.dart` - `GWScreen`; second, distinct screen wrapper (`SafeArea` + optional `AppBar` + max content width). Overlaps with `AppScreenView` by design (UI-SPEC §2.5) -- both ported, consolidation deferred to whichever screen phase adopts one
- `lib/components/bottom_drawer/bottom_drawer.dart` - `BottomDrawer`; modal content chrome only, supplies its own header, shown via develop's `ResponsiveDrawer.show()` with `title`/`actions` omitted
- `lib/components/overlays/gw_bottom_sheet.dart` - `GWBottomSheet`; generic modal bottom sheet helper, orphaned on the source branch
- `lib/components/overlays/gw_dialog.dart` - `GWDialog`; generic modal dialog helper, orphaned on the source branch

## Decisions Made
- Ported `GWScreen` and `AppScreenView` both, without consolidating the overlap -- the UI-SPEC (§2.5) records the ambiguity deliberately; picking a winner is a screen phase's call, not this phase's
- Did not port Alex's regressed `responsive_drawer.dart` (hardcoded 800, `enableDrag: false` in the source tree) -- it IS the regression findings 13/25/26 describe, not the fix. `bottom_drawer/` now contains exactly 2 files: `bottom_drawer.dart` (new) and develop's untouched `responsive_drawer.dart`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `responsive_grid.dart`: `GeniusBreakpoints.isNativeApp(context)` -> `GeniusBreakpoints.isMobileApp()`**
- **Found during:** Task 1 (`flutter analyze` after porting `responsive_grid.dart`)
- **Issue:** `flutter analyze` reported one hard error: `undefined_method` -- `GeniusBreakpoints.isNativeApp` does not exist on develop's `lib/utils/breakpoints.dart`. Root cause: a version delta between the reference worktree's `breakpoints.dart` (breakpoints `small=760`/`tablet=1200`/`medium=1644`/`large=1920`, an `isNativeApp(BuildContext)` method delegating to `getPlaform(context)`, and a `Platforms` context-aware helper) and develop's own `breakpoints.dart` (breakpoints `small=640`/`medium=768`/`large=1024`/`xl=1280`/`xxl=1536`, no `isNativeApp`, only a no-arg `isMobileApp()`). This same `breakpoints.dart` is this plan's own zero-diff-protected collision file (task 2's finding-26 assertion depends on it staying untouched), so the fix could not be applied there.
- **Fix:** Changed the one call site in `responsive_grid.dart` from `GeniusBreakpoints.isNativeApp(context)` to `GeniusBreakpoints.isMobileApp()` -- develop's closest existing equivalent (checks `Platform.isAndroid || Platform.isIOS`, same "force single column on native mobile" intent as the reference's non-web branch of `isNativeApp`), dropping the now-unneeded `context` argument.
- **Files modified:** `lib/components/responsive_grid.dart`
- **Verification:** `flutter analyze lib/components/responsive_grid.dart` -- 0 errors (from 1); `flutter analyze lib` -- 0 errors overall; `bash tool/verify_additive_boundary.sh` PASSED; `git diff --name-only -- lib/utils/breakpoints.dart` confirmed empty (the collision file itself was never touched)
- **Committed in:** `018a9cf` (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Necessary for `responsive_grid.dart` to compile at all. Does not touch `breakpoints.dart` (this plan's own zero-diff requirement), does not change any develop-reachable screen (the file is unconsumed), does not reassign any existing token or method.

## Issues Encountered
None beyond the one deviation documented above.

## Binding Rule: Findings 13, 25, 26 (for Phase 4 and every later phase)

Re-verified line-by-line this plan, `lib/components/bottom_drawer/responsive_drawer.dart` shows zero diff from develop and still holds:
- `showDialog(..., useRootNavigator: useRootNavigator)` and `showModalBottomSheet(..., useRootNavigator: useRootNavigator)`, both defaulting `useRootNavigator = true` (line 13) -- **finding 13**
- `enableDrag: enableDrag`, default `true` (line 15) -- **finding 25**
- `MediaQuery.sizeOf(context).width >= GeniusBreakpoints.medium` (line 18), where `GeniusBreakpoints.medium = 768` (`lib/utils/breakpoints.dart:9`) -- **finding 26**

**Whenever a later phase wires `BottomDrawer` into a real screen's drawer, it must:**
1. Keep calling develop's `ResponsiveDrawer.show()` with its current defaults -- `useRootNavigator: true`, `enableDrag: true`, `GeniusBreakpoints.medium` (768). Never reintroduce Alex's hardcoded `800` or `enableDrag: false`.
2. Omit `title`/`actions` on the `ResponsiveDrawer.show()` call so `_ResponsiveDrawerScaffold` renders no competing `AppBar` -- `BottomDrawer` supplies its own header.
3. Never port Alex's `responsive_drawer.dart` file wholesale from the reference worktree -- it is the regression these findings describe, not the fix.

Phase 4 (NAV-01/NAV-02, wiring the nav shell) is the next phase expected to actually mount `BottomDrawer` through `ResponsiveDrawer` in a live screen and should inherit this rule verbatim rather than rediscovering it.

## Stub Tracking
No stubs. All 9 new files are complete, verbatim (or the one documented-deviation) ports of finished hand-written source; none contains a hardcoded empty value or placeholder pending future wiring. None is reachable from `main.dart` this phase -- that dormancy is the plan's explicit, accepted design, not a stub.

## User Setup Required

None. All 9 new files are Dart-only, no `pubspec.yaml` change -- the user's running debug session can pick these up via hot reload (`r`), but there is nothing to see: none of the 9 files is imported by anything reachable from `main.dart` yet. `AppScreenWithHeaderDesktop`/`Mobile` are imported only by un-ported onboarding screens and `pin_screen.dart`; `BottomDrawer`, `GWBottomSheet`, `GWDialog` have zero callers anywhere in the tree.

## Next Phase Readiness
- 9/9 of this plan's files landed: `flutter analyze lib` 0 errors, additive-boundary guard green throughout both task commits.
- Combined with 03-01 through 03-04, 41 of the phase's 50 in-scope files are now on develop.
- Findings 13/25/26 are proven already-true on develop and their binding rule is recorded above, verbatim, for Phase 4 to inherit.
- **What this plan does NOT establish, for plan 03-09/03-10 to carry verbatim:** render correctness of any of the 9 new files, and the drawer's actual open/dismiss/breakpoint-flip behavior in the running app. Nothing calls `build()` on any of them this plan (no consumer exists yet). This is an accepted gap (see coverage item D6), not a deferred PASS.
- Outstanding for the human: the full drawer walk (mounts over the whole app via `useRootNavigator`, swipes down to dismiss at mobile width, flips to the desktop side-dialog at exactly 768px) -- deferred to plan 03-09's gallery, per this plan's own `<verify><human-check>`. Nothing plan-specific requires action before then.

---
*Phase: 03-gw-component-library*
*Completed: 2026-07-16*

## Self-Check: PASSED

All 9 created files confirmed present on disk. Both task commits (`018a9cf`, `eba5a17`) confirmed present in `git log --oneline --all`.
</content>
