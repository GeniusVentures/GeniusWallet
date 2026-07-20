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
  - "[Walk A fix] Anchor switched from Positioned(left, top) to Positioned(right, top): default spot sits below the header inset from the right edge, and the expanded panel grows down-and-left from that corner for free -- no separate flip-direction logic needed. Supersedes the original 'clamp bounds sized off the collapsed footprint even while expanded' decision, which was the root cause of the off-viewport bug."
  - "[Walk A fix] Expanded panel is bounded via ConstrainedBox(maxWidth: min(260, screenWidth - 2*inset), maxHeight: screenHeight - appBarHeight - 2*inset) + SingleChildScrollView -- SingleChildScrollView has no shrinkWrap param but already hugs its child's natural size by default (unlike ListView/Viewport), so it caps and scrolls only when content actually exceeds maxHeight rather than always rendering at full height"

requirements-completed: [QUICK-260720-bgl]

coverage:
  - id: D1
    description: "DevToolsBubble widget created: draggable collapsed FAB, expanded panel with Test transaction/swap/buy, Tokens, Gallery, and light/dark appearance toggle, anchored top-right below the header and clamped to the viewport in both states"
    requirement: "QUICK-260720-bgl"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Visual/interactive behavior (drag, expand/collapse, live re-skin, viewport clamping) requires a human walk in a running debug build; flutter analyze only proves it compiles clean. Walk A already caught one positioning bug this way (see Deviations) -- the re-walk still needs to confirm the fix."
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

- **Duration:** ~25 min (including the Walk A fix-forward)
- **Tasks:** 2 of 3 (auto tasks complete; Task 3 is a blocking human-verify checkpoint, not performed by this run) + 1 fix-forward commit from Walk A feedback
- **Files modified:** 2

## Accomplishments
- Created `lib/dev/dev_tools_bubble.dart`: a `StatefulWidget` with a collapsed draggable circular FAB (`GestureDetector.onPanUpdate` + clamp to screen bounds, tap-to-expand) and an expanded panel reusing `TestTransactionButton`, `TestSwapButtons`, `TestBuyButtons`, and `Tokens`/`Gallery` push targets verbatim from the old `DevToolsWidget`, plus a light/dark appearance toggle via `GWAppearance.instance.setMode`.
- Removed `DevToolsWidget` from `_buildActionRowWidgets` in `responsive_overlay.dart` — the action row now returns only `NetworkDropdownSelector`, `SDKAccountManagerButton`, `AccountDropdownSelector`, `ReownConnectButton`.
- Wrapped both `DesktopOverlay.build`'s and `MobileOverlay.build`'s Scaffold bodies in a `Stack`, overlaying `const DevToolsBubble()` gated `kDebugMode && kShowDevTools` as the second child — the bubble now occupies zero layout space in the chrome under test.
- Removed the now-unused `package:genius_wallet/test/dev_tools_widget.dart` import and added `package:genius_wallet/dev/dev_tools_bubble.dart`. `lib/test/dev_tools_widget.dart` itself is left in place (its child buttons are reused directly by the bubble via their own imports).
- **[Walk A fix]** Re-anchored the bubble/panel to the top-right corner (below the header) and made both states viewport-clamped, fixing a bug where the expanded panel could disappear off the viewport.

## Task Commits

Each auto task was committed atomically, plus one fix-forward from Walk A feedback:

1. **Task 1: Create the draggable dev-only DevToolsBubble overlay widget** - `23e963e` (feat)
2. **Task 2: Wire the bubble into both overlays and remove DevToolsWidget from the action row** - `8bc5cab` (feat)
3. **Walk A fix: anchor DevToolsBubble top-right and clamp to viewport** - `a91aec0` (fix)

Task 3 is a `checkpoint:human-verify` gate (`gate="blocking"`) — not a commit-producing task. Per this run's instructions, the walk was intentionally NOT performed by the executor; it is a human step (see "Outstanding" below). Walk A (a partial/early pass at that same checkpoint) already surfaced one bug, fixed in `a91aec0`; a full re-walk is still required.

## Files Created/Modified
- `lib/dev/dev_tools_bubble.dart` - New draggable dev-only overlay bubble (collapsed FAB / expanded panel with dev actions + appearance toggle)
- `lib/components/overlay/responsive_overlay.dart` - `DevToolsWidget` removed from the action row; `DesktopOverlay`/`MobileOverlay` bodies wrapped in `Stack` with the gated bubble overlaid

## Decisions Made
- Bubble position is lazily initialised in `build()` via a nullable `Offset ??=` rather than `initState()` (MediaQuery unavailable there) — avoids an extra post-frame callback for a dev-only widget.
- Bubble position is not persisted across app restarts — `ponytail:` comment in source marks this as an accepted, dev-only ceiling.
- **[Superseded by Walk A fix]** ~~Drag-clamp bounds are computed against the collapsed bubble's footprint even in the expanded state~~ — this was the root cause of the off-viewport bug; clamp bounds are now sized off whichever state (collapsed 48x48 vs. expanded viewport-capped panel size) is actually showing.
- **[Walk A fix]** Anchor is `Positioned(right, top)` (inset-from-right-edge, inset-from-top-edge), not `Positioned(left, top)` — the expanded panel grows down-and-left from its top-right corner automatically, so no separate "flip direction when near an edge" logic is needed.
- **[Walk A fix]** `SingleChildScrollView` has no `shrinkWrap` parameter (unlike `ListView`) — it already hugs its child's natural size when given loose constraints and only fills/scrolls once content exceeds the `ConstrainedBox` max, so `ConstrainedBox(maxWidth, maxHeight) > SingleChildScrollView > Column(mainAxisSize.min)` gives cap+shrink+scroll-when-needed with no extra flag.

## Deviations from Plan

### Auto-fixed Issues

**1. [Coordinator-directed fix, post-Task-2] DevToolsBubble expanded panel disappeared off the viewport**
- **Found during:** Walk A (a partial/early pass at the Task 3 checkpoint)
- **Issue:** `_clamp` only ever bounded the drag anchor against the collapsed bubble's 48x48 footprint. When expanded, the 260px-wide, height-unbounded panel reused that same `left`/`top` offset with no size-aware clamping, so — depending on the collapsed bubble's last dragged position — the panel could render partially or fully outside the viewport with no way to scroll it back into view.
- **Fix:** Re-anchored to the TOP-RIGHT corner via `Positioned(right, top)` (default: below the header, inset from the right edge), so the expanded panel naturally grows down-and-left from that corner. `_clamp` now takes the width/height of whichever state is showing and bounds the anchor so neither state can be dragged above the header or past any edge, applied on every drag and on first layout. The panel itself is wrapped in `ConstrainedBox(maxWidth: min(260, screenWidth - 2*inset), maxHeight: screenHeight - appBarHeight - 2*inset)` + `SingleChildScrollView` so it can never exceed the viewport.
- **Files modified:** `lib/dev/dev_tools_bubble.dart`
- **Verification:** `flutter analyze lib/dev/dev_tools_bubble.dart` → 0 issues.
- **Committed in:** `a91aec0`

---

**Total deviations:** 1 auto-fixed (coordinator-directed, found via a partial human walk)
**Impact on plan:** Necessary correctness fix for the checkpoint's own success criteria ("draggable dev-only bubble... expanded panel... within the app"). No scope creep — same file, same widget, no new dev actions or gating changes.

## Issues Encountered
None beyond the Walk A finding documented above (resolved in `a91aec0`).

## User Setup Required
None - no external service configuration required.

## Outstanding

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been fully performed.** Walk A was a partial/early pass that surfaced the positioning bug fixed in `a91aec0`; a full re-walk against the fixed code is still required. Exact recipe (from `260720-bgl-PLAN.md`):

1. Run a debug build with the dev flag: `flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true`.
2. Resize the window across ~1240px width — confirm the top bar shows ONLY the real action widgets (network/SDK/account selectors, Reown connect, Buy GNUS) and no RenderFlex overflow stripes; the real widgets stay on-screen.
3. Confirm a small dev bubble is overlaid on the app, anchored top-right below the header. Drag it to a different corner — it should move and stay fully on-screen, clamped so it can never go above the header or past any edge, without affecting page layout.
4. Tap the bubble — a panel expands with: Test transaction, Test swap, Test buy, Tokens, Gallery, and a light/dark appearance toggle. **Confirm the panel stays fully visible within the window** (grows down-and-left from its top-right corner, never disappears off any edge, and scrolls internally instead of overflowing if content is ever taller than the available space).
5. Tap Tokens → lands on `/dev/token-probe`; back, tap Gallery → lands on `/design_gallery`. Confirm Test transaction/swap/buy still behave as before.
6. Flip the appearance toggle — the whole app re-skins light↔dark live, and the bubble itself re-skins too.
7. (Optional) Run once WITHOUT `--dart-define=GW_DEV_TOOLS=true` — confirm no bubble appears anywhere.

Resume signal: "approved" or a description of issues found (overflow still present, bubble/panel not fully on-screen, not draggable, an action broken, toggle doesn't flip, or bubble visible without the flag).

## Next Phase Readiness
- Code changes are analyze-clean and committed (`23e963e`, `8bc5cab`, `a91aec0`); no blockers for continuing other work.
- The Task 3 re-walk should be run before or alongside the next phase-05 walk, since it directly unblocks clean `_DesktopTopBar` verification at ~1240px (the original motivating regression from the 05-02 walk) and confirms the Walk A positioning fix.

---
*Quick task: 260720-bgl-move-dev-tooling-out-of-the-desktop-top-*
*Completed: 2026-07-20*

## Self-Check: PASSED

- FOUND: lib/dev/dev_tools_bubble.dart
- FOUND: lib/components/overlay/responsive_overlay.dart
- FOUND: .planning/quick/260720-bgl-move-dev-tooling-out-of-the-desktop-top-/260720-bgl-SUMMARY.md
- FOUND: 23e963e
- FOUND: 8bc5cab
- FOUND: a91aec0 (Walk A fix-forward)
