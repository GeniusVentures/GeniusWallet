---
phase: 08-swap-bridge
plan: 02
subsystem: ui
tags: [flutter, go_router, navigation, crash-fix, global-fab]

requires:
  - phase: 08-swap-bridge (plan 01)
    provides: re-skinned GWSwapFab button (already design-system compliant, D-14)
provides:
  - "GlobalSwapFabHost — ported crash-fix host that floats the global swap FAB over every authenticated screen"
  - "The _ready gate that prevents the NAV-02 assert(!_dirty) red screen on cold start"
  - "GlobalSwapFabHost mounted once at MaterialApp.router's builder, DevicePreview kept outermost"
affects: [08-07-verification]

tech-stack:
  added: []
  patterns:
    - "Port with one authorized deviation, documented at the deviation site rather than silently reconciled (D-18a)"
    - "_ready gate defers all router reads past the first frame to avoid re-dirtying MaterialApp during attachRootWidget"

key-files:
  created:
    - lib/components/overlay/global_swap_fab_host.dart
    - test/components/global_swap_fab_host_test.dart
  modified:
    - lib/main.dart

key-decisions:
  - "AI-FAB half (import + second Positioned + doc paragraphs) stripped per D-18a; everything else, including the _ready guard and its attachRootWidget rationale comment, ported verbatim"
  - "/legal kept in _hiddenPaths as a known-inert entry (not a registered route on this branch) per the plan's explicit instruction not to 'fix' it"
  - "main.dart builder composed as (context, child) => DevicePreview.appBuilder(context, GlobalSwapFabHost(router: geniusWalletRouter, child: child ?? SizedBox.shrink()))  — DevicePreview stays outermost, host takes the router explicitly rather than GoRouter.of(context)"

patterns-established:
  - "Verbatim port + one documented deviation, rather than reimplementing from scratch, when carrying a fix across branches"

requirements-completed: [SCR-04]

coverage:
  - id: D1
    description: "GlobalSwapFabHost exists, ported from 7a63b4f with the AI-FAB half stripped; the _ready gate, its attachRootWidget rationale comment, the persistentCallbacks branch, the routerDelegate listener, and the full _hiddenPaths set survive verbatim"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "flutter analyze lib/components/overlay/global_swap_fab_host.dart (0 issues) + grep gates (_ready guard, attachRootWidget, persistentCallbacks, routerDelegate.addListener, _hiddenPaths, exactly 1 Positioned, no submit_job, no gw_ai_fab)"
        status: pass
    human_judgment: false
  - id: D2
    description: "GlobalSwapFabHost mounted once at MaterialApp.router's builder, composed with DevicePreview.appBuilder as the outermost wrapper, passing the same geniusWalletRouter instance; gw_swap_fab.dart confirmed unmodified and still brand-token-compliant (D-14)"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "flutter analyze lib (59/61 baseline held) + grep gates (GlobalSwapFabHost, DevicePreview.appBuilder, geniusWalletRouter present) + git status --porcelain gw_swap_fab.dart empty"
        status: pass
    human_judgment: false
  - id: D3
    description: "Widget tests pin the first-frame gate (no FAB before the post-frame callback lands), hidden-path suppression on /swap, and FAB reappearance after returning to a visible path"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "test/components/global_swap_fab_host_test.dart — all 3 tests pass"
        status: pass
    human_judgment: false
  - id: D4
    description: "Criterion 5's real evidence (a cold start with no !_dirty red screen, FAB visible on dashboard, absent on /swap and onboarding) is earned at a live app run, not a widget test"
    requirement: SCR-04
    verification: []
    human_judgment: true
    rationale: "RESEARCH and the plan are explicit that the real assert(!_dirty) startup crash needs runApp's actual mount timing and is not reproducible under pumpWidget. That repro was originally the 08-07 cold-start walk's job. 08-CONTEXT.md D-22 descopes the 08-07 human walk entirely at Braian's explicit instruction ('do everything until the end... we dont need to test it fully'), so this judgment call is recorded as never exercised, not as passed."

duration: 25min
completed: 2026-07-25
status: complete
---

# Phase 8 Plan 2: GlobalSwapFabHost port and mount Summary

**Ported `GlobalSwapFabHost` (the ROADMAP-criterion-5 `7a63b4f` carry) from `ui-redesign-3.514-develop` with the AI-FAB half stripped per D-18a, mounted it once at `MaterialApp.router`'s builder alongside `DevicePreview.appBuilder`, and added three widget tests pinning the `_ready` gate that prevents the NAV-02 `!_dirty` cold-start crash.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-07-25 (Task 1 commit)
- **Completed:** 2026-07-25 (Task 3 commit)
- **Tasks:** 3/3
- **Files modified:** 3 (2 created, 1 modified)

## Accomplishments
- `lib/components/overlay/global_swap_fab_host.dart` created — a verbatim port of the 143-line `7a63b4f` source, minus the AI-FAB import, its second `Positioned` block, and the doc-comment paragraphs describing that mirror (D-18a, the one authorized deviation). The `_ready` field and its four-line comment, the `_onRouteChanged` guard (`if (!_ready) return;`) with its full multi-line rationale (including the `attachRootWidget`/`idle`-vs-`persistentCallbacks` sentence), the `routerDelegate.addListener`/`removeListener` pair, the `SchedulerPhase.persistentCallbacks` deferral branch, and the complete `_hiddenPaths` set (including the known-inert `/legal` entry) all survive character-for-character.
- `lib/main.dart` now mounts `GlobalSwapFabHost` inside the `MaterialApp.router` builder, with `DevicePreview.appBuilder` kept as the outermost wrapper and the same `geniusWalletRouter` instance passed explicitly (not read via `GoRouter.of(context)`, since the builder's context can sit above the `InheritedGoRouter`). `debugShowCheckedModeBanner`, `locale`, `title`, `theme`, and `routerConfig` are unchanged.
- D-14 re-confirmed without a re-paint: `gw_swap_fab.dart` still resolves its fill through `GeniusWalletGradient.brandCta` and its glyph through `GeniusWalletColors.textOnBrand`, and `git status --porcelain` shows it untouched.
- `test/components/global_swap_fab_host_test.dart` created with a minimal local two-route `GoRouter` (`/dashboard` visible, `/swap` hidden) and three tests: (1) no FAB on the very first frame, FAB present after the post-frame `setState` lands; (2) FAB absent after navigating to `/swap`; (3) FAB reappears after navigating back to `/dashboard`, proving the value of listening to the `routerDelegate` (a `ChangeNotifier`) over `routeInformationProvider`. All three assert `tester.takeException()` is null.

## Task Commits

Each task was committed atomically:

1. **Task 1: Port GlobalSwapFabHost from 7a63b4f with the AI-FAB half stripped** - `43ff62e` (feat)
2. **Task 2: Mount the host at MaterialApp.router's builder, composed with DevicePreview** - `cf3a73c` (feat)
3. **Task 3: Widget-test the _ready gate and the hidden-path behaviour** - `f9de19d` (test)

## Files Created/Modified
- `lib/components/overlay/global_swap_fab_host.dart` - NEW: ported host, AI-FAB half stripped
- `lib/main.dart` - `GlobalSwapFabHost` composed into the `MaterialApp.router` builder
- `test/components/global_swap_fab_host_test.dart` - NEW: `_ready` gate + hidden-path tests

## Decisions Made
- Stripped exactly the AI-FAB import, its `Positioned` block, and the two doc-comment clauses describing the bottom-left mirror (D-18a); rewrote the class doc comment to describe only the swap FAB and added one sentence recording that the AI-FAB mirror was intentionally dropped at port time because WIRE-02 keeps it out of this milestone. No file named `gw_ai_fab.dart` was created or referenced.
- Kept `/legal` in `_hiddenPaths` as a known-inert entry (not a registered route on this branch per a `lib/navigation/` grep) rather than removing it — an unreached hidden-path entry is inert, and dropping it risks un-hiding the FAB if a Legal route lands later.
- `main.dart`'s builder closure: `(context, child) => DevicePreview.appBuilder(context, GlobalSwapFabHost(router: geniusWalletRouter, child: child ?? const SizedBox.shrink()))`. This keeps `DevicePreview` outermost (matching Assumptions Log A2) and hands `GlobalSwapFabHost` the router's own child with a `SizedBox.shrink()` fallback for the nullable `child` MaterialApp's builder signature provides.
- D-21 standing authorization used for: exact grep-gate wording during verification, and confirming the single `flutter analyze` warning delta (none — held at 59) was not a regression before treating it as baseline noise.

## Deviations from Plan

None beyond the plan's own pre-authorized D-18a deviation (the AI-FAB strip), which was executed exactly as specified in Task 1's action block. No Rule 1/2/3 auto-fixes were needed — the port compiled clean on the first pass and the mount required no additional fixup.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
`GlobalSwapFabHost` exists, is mounted once, and its hard-won `_ready` startup guard is preserved verbatim and now has an automated regression test. Criterion 5's automatable half (the guard itself, hidden-path suppression, and reappearance after navigation) is green. The walk half — a live cold start proving no `!_dirty` red screen in the real app — is descoped by D-22 at Braian's explicit instruction, not performed and not fabricated as performed; 08-VERIFICATION.md should record this as deliberately skipped, not passed. `flutter analyze lib` holds at 59 issues (at or below the 61 baseline, matching 08-01's exit state). Full `flutter test` is 252 pass / 1 known pre-existing failure (249 baseline + this plan's 3 new tests; the sole failure remains `local_wallet_storage_test.dart`, entirely commented out, pre-existing and unrelated to this plan). No blockers for 08-03 (swap tab assembly).

---
*Phase: 08-swap-bridge*
*Completed: 2026-07-25*

## Self-Check: PASSED
- FOUND: lib/components/overlay/global_swap_fab_host.dart
- FOUND: lib/main.dart
- FOUND: test/components/global_swap_fab_host_test.dart
- FOUND: .planning/phases/08-swap-bridge/08-02-SUMMARY.md
- FOUND commit: 43ff62e
- FOUND commit: cf3a73c
- FOUND commit: f9de19d
