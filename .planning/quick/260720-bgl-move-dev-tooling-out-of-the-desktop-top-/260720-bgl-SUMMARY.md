---
phase: quick-260720-bgl
plan: 01
subsystem: ui
tags: [flutter, dev-tooling, overlay, responsive_overlay, dev_flags]

requires:
  - phase: 02-design-tokens-verification-loop
    provides: GWColors ThemeExtension, GWAppearance singleton, GeniusWalletConsts space/radius scale
provides:
  - DevToolsBubble draggable dev-only overlay widget (collapsed FAB + expanded panel)
  - DevToolsWidget removed from _DesktopTopBar's action row (fixes ~1240px RenderFlex overflow)
  - DesktopOverlay/MobileOverlay bodies wrapped in Stack, bubble overlaid gated kDebugMode && kShowDevTools
affects: [05-dashboard, any future phase touching responsive_overlay.dart or dev tooling]

tech-stack:
  added: []
  patterns:
    - "Dev-only overlay widgets: Positioned inside a Stack wrapping the Scaffold body, gated kDebugMode && kShowDevTools at the insertion site (not inside the widget)"
    - "ValueListenableBuilder<GWAppearanceMode> on GWAppearance.instance for live re-skin of const-hostile widget trees"

key-files:
  created:
    - lib/dev/dev_tools_bubble.dart
  modified:
    - lib/components/overlay/responsive_overlay.dart

key-decisions:
  - "Bubble position is lazily initialised in build() (nullable Offset ??=) rather than initState(), since MediaQuery is unavailable in initState -- avoids a WidgetsBinding.addPostFrameCallback dance for a dev-only widget"
  - "Position not persisted across app restarts (ponytail: dev-only, acceptable ceiling) -- keeps the widget self-contained, no new Hive/prefs key"
  - "Drag clamp bounds are sized off the collapsed bubble footprint even while expanded -- simplest correct behavior for a dev affordance, not a strict polish requirement"

requirements-completed: [QUICK-260720-bgl]

coverage:
  - id: D1
    description: "DevToolsBubble widget created: draggable collapsed FAB, expanded panel with Test transaction/swap/buy, Tokens, Gallery, and light/dark appearance toggle"
    requirement: "QUICK-260720-bgl"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Visual/interactive behavior (drag, expand/collapse, live re-skin) requires a human walk in a running debug build; flutter analyze only proves it compiles clean."
  - id: D2
    description: "DevToolsWidget removed from _buildActionRowWidgets; bubble wired into DesktopOverlay and MobileOverlay behind kDebugMode && kShowDevTools"
    requirement: "QUICK-260720-bgl"
    verification:
      - kind: other
        ref: "flutter analyze lib/components/overlay/responsive_overlay.dart lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Whether _DesktopTopBar actually stops overflowing at ~1240px, and whether the bubble is fully absent without GW_DEV_TOOLS, can only be confirmed by resizing a running debug build -- Task 3's blocking human-verify checkpoint, not yet performed."

duration: ~15min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-bgl: Move dev tooling out of desktop top bar into overlay bubble Summary

**New `DevToolsBubble` draggable overlay widget replaces the header-row `DevToolsWidget`, removing it from `_DesktopTopBar`'s action `Row` (which overflowed at ~1240px) and overlaying it instead in a `Stack` behind `kDebugMode && kShowDevTools`.**

## Performance

- **Duration:** ~15 min
- **Tasks:** 2 of 3 (auto tasks complete; Task 3 is a blocking human-verify checkpoint, not performed by this run)
- **Files modified:** 2

## Accomplishments
- Created `lib/dev/dev_tools_bubble.dart`: a `StatefulWidget` with a collapsed draggable circular FAB (`GestureDetector.onPanUpdate` + clamp to screen bounds, tap-to-expand) and an expanded panel reusing `TestTransactionButton`, `TestSwapButtons`, `TestBuyButtons`, and `Tokens`/`Gallery` push targets verbatim from the old `DevToolsWidget`, plus a light/dark appearance toggle via `GWAppearance.instance.setMode`.
- Removed `DevToolsWidget` from `_buildActionRowWidgets` in `responsive_overlay.dart` — the action row now returns only `NetworkDropdownSelector`, `SDKAccountManagerButton`, `AccountDropdownSelector`, `ReownConnectButton`.
- Wrapped both `DesktopOverlay.build`'s and `MobileOverlay.build`'s Scaffold bodies in a `Stack`, overlaying `const DevToolsBubble()` gated `kDebugMode && kShowDevTools` as the second child — the bubble now occupies zero layout space in the chrome under test.
- Removed the now-unused `package:genius_wallet/test/dev_tools_widget.dart` import and added `package:genius_wallet/dev/dev_tools_bubble.dart`. `lib/test/dev_tools_widget.dart` itself is left in place (its child buttons are reused directly by the bubble via their own imports).

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Create the draggable dev-only DevToolsBubble overlay widget** - `23e963e` (feat)
2. **Task 2: Wire the bubble into both overlays and remove DevToolsWidget from the action row** - `8bc5cab` (feat)

Task 3 is a `checkpoint:human-verify` gate (`gate="blocking"`) — not a commit-producing task. Per this run's instructions, the walk was intentionally NOT performed by the executor; it is a human step (see "Outstanding" below).

## Files Created/Modified
- `lib/dev/dev_tools_bubble.dart` - New draggable dev-only overlay bubble (collapsed FAB / expanded panel with dev actions + appearance toggle)
- `lib/components/overlay/responsive_overlay.dart` - `DevToolsWidget` removed from the action row; `DesktopOverlay`/`MobileOverlay` bodies wrapped in `Stack` with the gated bubble overlaid

## Decisions Made
- Bubble position is lazily initialised in `build()` via a nullable `Offset ??=` rather than `initState()` (MediaQuery unavailable there) — avoids an extra post-frame callback for a dev-only widget.
- Bubble position is not persisted across app restarts — `ponytail:` comment in source marks this as an accepted, dev-only ceiling.
- Drag-clamp bounds are computed against the collapsed bubble's footprint even in the expanded state — simplest correct behavior; not required to be pixel-perfect for a dev affordance.

## Deviations from Plan

None - plan executed exactly as written. Both `flutter analyze` gates (per-task and combined) returned 0 issues on first pass; no auto-fixes were required.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Outstanding

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been performed.** This is a human walk, not an automatable step. Exact recipe (from `260720-bgl-PLAN.md`):

1. Run a debug build with the dev flag: `flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true`.
2. Resize the window across ~1240px width — confirm the top bar shows ONLY the real action widgets (network/SDK/account selectors, Reown connect, Buy GNUS) and no RenderFlex overflow stripes; the real widgets stay on-screen.
3. Confirm a small dev bubble is overlaid on the app. Drag it to a different corner — it should move and stay where dropped, without affecting page layout.
4. Tap the bubble — a panel expands with: Test transaction, Test swap, Test buy, Tokens, Gallery, and a light/dark appearance toggle.
5. Tap Tokens → lands on `/dev/token-probe`; back, tap Gallery → lands on `/design_gallery`. Confirm Test transaction/swap/buy still behave as before.
6. Flip the appearance toggle — the whole app re-skins light↔dark live, and the bubble itself re-skins too.
7. (Optional) Run once WITHOUT `--dart-define=GW_DEV_TOOLS=true` — confirm no bubble appears anywhere.

Resume signal: "approved" or a description of issues found (overflow still present, bubble not draggable, an action broken, toggle doesn't flip, or bubble visible without the flag).

## Next Phase Readiness
- Code changes are analyze-clean and committed (`23e963e`, `8bc5cab`); no blockers for continuing other work.
- The Task 3 walk should be run before or alongside the next phase-05 walk, since it directly unblocks clean `_DesktopTopBar` verification at ~1240px (the original motivating regression from the 05-02 walk).

---
*Quick task: 260720-bgl-move-dev-tooling-out-of-the-desktop-top-*
*Completed: 2026-07-20*

## Self-Check: PASSED

- FOUND: lib/dev/dev_tools_bubble.dart
- FOUND: lib/components/overlay/responsive_overlay.dart
- FOUND: .planning/quick/260720-bgl-move-dev-tooling-out-of-the-desktop-top-/260720-bgl-SUMMARY.md
- FOUND: 23e963e
- FOUND: 8bc5cab
