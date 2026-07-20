---
phase: quick-260720-dty
plan: 01
subsystem: ui
tags: [flutter, dev-tooling, dev_tools_bubble, wcag, light-mode]

requires:
  - phase: quick-260720-bgl
    provides: DevToolsBubble draggable dev-only overlay widget (collapsed FAB + expanded panel)
provides:
  - dev-tools bubble expanded panel reorganized into 4 collapsible sections (MOCK, TEST FLOWS, NAVIGATE, APPEARANCE)
  - _Section collapsible-header helper + _devButton compact gw-styled button helper
  - Test tx/swap/buy actions inlined as legible text buttons (status hue moved to a decorative dot, labels always gw.textPrimary)
  - lib/test/test_transaction_button.dart, lib/reown/test/test_swap_buttons.dart, lib/reown/test/test_buy_buttons.dart, lib/test/dev_tools_widget.dart deleted
affects: [05-dashboard, any future phase touching lib/dev/dev_tools_bubble.dart]

tech-stack:
  added: []
  patterns:
    - "Dev-panel section pattern: _Section(label, expanded, onToggle, gw, children) — chevron header + tappable InkWell, Column body rendered only when expanded"
    - "Status-hue-as-accent-dot: _devButton(label, onTap, {accent}) always renders the label in gw.textPrimary; accent (if given) paints only an 8px decorative dot, never text color — keeps WCAG AA on the light gw.surfaceMenu panel regardless of the semantic hue"

key-files:
  created: []
  modified:
    - lib/dev/dev_tools_bubble.dart
  deleted:
    - lib/test/test_transaction_button.dart
    - lib/reown/test/test_swap_buttons.dart
    - lib/reown/test/test_buy_buttons.dart
    - lib/test/dev_tools_widget.dart

key-decisions:
  - "GWColors needed inside the _devButton instance method (which the plan's signature keeps gw-free) is captured via a late GWColors _gw field, set at the top of _buildExpandedPanel each build — avoids widening the method signature past what the plan specified while still giving the label its correct appearance-aware color."
  - "_Section renders its children in a plain Column (not a Wrap) so each section's caller controls its own internal layout (Wrap of buttons for MOCK/TEST FLOWS/NAVIGATE, a Row for APPEARANCE's toggle) rather than forcing one layout shape on every section."
  - "The 'Add tx' handler's context.read<GeniusApi>().getSGNUSTransactionsController() call moved from build-time (as in the original TestTransactionButton, which read it once per widget build) into the onPressed body itself — functionally equivalent since the same GeniusApi/controller instance is resolved either way, and keeps every TEST FLOWS handler self-contained inside its own _devButton call."
  - "PLAN ADJUSTMENT (orchestrator-directed, Rule 2/3-class fix applied before Task 2's delete gate): also deleted lib/test/dev_tools_widget.dart, the OLD header-row DevToolsWidget superseded by the dev-tools bubble in quick 260720-bgl. It was the only remaining non-bubble importer of the three Test* widgets (grep-confirmed: no import, no DevToolsWidget() usage anywhere in lib/, only stale doc-comment mentions), so it would have tripped the plan's delete grep-gate had it survived."
  - "Stale doc-comment mentions of [DevToolsWidget] in design_gallery_screen.dart (:52-53) and token_probe_screen.dart (:12) were left as-is (dev_tools_bubble.dart's own doc comment already correctly describes the bubble as DevToolsWidget's replacement) — low-value doc-only edit outside this task's file scope; flagged here rather than risking scope creep."

requirements-completed: [260720-dty]

coverage:
  - id: D1
    description: "Expanded dev bubble panel reorganized into 4 collapsible sections (MOCK, TEST FLOWS, NAVIGATE, APPEARANCE) with correct default open/closed state (MOCK/APPEARANCE open, TEST FLOWS/NAVIGATE closed) and working chevron toggles"
    requirement: "260720-dty"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Toggle interaction, default-state visibility, and section layout are visual/interactive behaviors flutter analyze cannot verify; requires the Task 3 human walk (outstanding, see below)."
  - id: D2
    description: "Test tx/swap/buy actions inlined as compact gw-styled text buttons running their original flows verbatim; no hardcoded Colors.*Accent remains in the bubble; the three orphaned Test* widget files (plus the newly-orphaned dev_tools_widget.dart) are deleted and unreferenced"
    requirement: "260720-dty"
    verification:
      - kind: other
        ref: "plan's grep gate (no test_transaction_button/test_swap_buttons/test_buy_buttons references, files deleted, no Colors.*Accent in dev_tools_bubble.dart) -> OK"
        status: pass
      - kind: other
        ref: "flutter analyze lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Whether every inlined action still opens the correct drawer / injects the tx / shows the toast, and whether every label is actually legible on the light gw.surfaceMenu panel, requires exercising the running debug build -- Task 3's blocking human-verify checkpoint, not performed by this run."

duration: ~20min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-dty: Sectionize the dev-tools bubble into collapsible sections Summary

**Reworked `lib/dev/dev_tools_bubble.dart`'s expanded panel into four collapsible sections (MOCK, TEST FLOWS, NAVIGATE, APPEARANCE) via a new `_Section` helper, and inlined the Test tx/swap/buy flows as compact `_devButton` text buttons whose labels always render in `gw.textPrimary` — fixing the light-mode illegibility of the old icon-only `Colors.*Accent` buttons. Deletes the three now-orphaned `Test*` widget files, plus (plan adjustment) the fully-dead old `DevToolsWidget` that was their only other referencer.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 2 of 2 auto tasks complete; Task 3 is a blocking human-verify checkpoint, not performed by this run
- **Files modified:** 1 modified, 4 deleted

## Accomplishments

- Added four per-section `bool` expand flags (`_mockExpanded = true`, `_testFlowsExpanded = false`, `_navigateExpanded = false`, `_appearanceExpanded = true`) matching the D-01 default-state requirement.
- Added the private `_Section` `StatelessWidget`: chevron (`expand_more`/`chevron_right`) + uppercase-style label header (`InkWell` → `onToggle`), body rendered only when `expanded`.
- Added the private `_devButton(label, onTap, {accent})` method: a tightened `TextButton` whose label is always `gw.textPrimary`; `accent`, when passed, paints only an 8px circular dot, never the text.
- Reorganized the panel body into the four sections in order MOCK → TEST FLOWS → NAVIGATE → APPEARANCE, each wired to its own `setState` toggle. MOCK's four scenario buttons (Populated/Long-extreme/Missing icon/Clear) and NAVIGATE's Tokens/Gallery pushes were re-expressed via `_devButton` with identical `DevMockHoldings`/`WalletDetailsCubit`/`context.push` wiring. APPEARANCE keeps its original `Row` (icon + Light/Dark label + `GWAppearance.instance.setMode`) untouched.
- Inlined all nine Test* actions into TEST FLOWS as `_devButton` calls with status-color accent dots: Add tx (success), Approve conn (warning), Swap OK (success), Swap fail (error), Approve swap (info), Swap success (success), Swap failed (error), Buy OK (success), Buy fail (error) — each handler body copied verbatim from the deleted widgets (same drawer classes, same args, same toast).
- Deleted `lib/test/test_transaction_button.dart`, `lib/reown/test/test_swap_buttons.dart`, `lib/reown/test/test_buy_buttons.dart` after inlining, plus `lib/test/dev_tools_widget.dart` (plan adjustment, see below).
- Updated imports: removed the three `Test*` widget imports; added `package:genius_api/genius_api.dart`, the six reown/squid/banxa drawer imports, `genius_wallet/test/dev_overrides.dart`, `genius_wallet/components/toast/toast_manager.dart`, and `genius_wallet/theme/genius_wallet_colors.dart` (for the `statusSuccess`/`statusError`/`statusWarning`/`statusInfo` accent constants).

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Add `_Section` + `_devButton` helpers and reorganize the panel body into 4 collapsible sections** - `c29fa0d` (feat)
2. **Task 2: Inline the Test tx/swap/buy flows as legible gw-styled buttons and delete the orphaned Test\* widgets (+ plan-adjustment deletion of `dev_tools_widget.dart`)** - `ddd9978` (feat)

Task 3 is a `checkpoint:human-verify` gate (`gate="blocking"`) — not a commit-producing task. Per this run's instructions, the walk was intentionally NOT performed by the executor.

## Files Created/Modified/Deleted

- `lib/dev/dev_tools_bubble.dart` - Reworked expanded panel: 4 `_Section`s, `_devButton` helper, inlined test-flow handlers
- `lib/test/test_transaction_button.dart` - Deleted (orphaned after inline)
- `lib/reown/test/test_swap_buttons.dart` - Deleted (orphaned after inline)
- `lib/reown/test/test_buy_buttons.dart` - Deleted (orphaned after inline)
- `lib/test/dev_tools_widget.dart` - Deleted (plan adjustment; the OLD `DevToolsWidget`, fully superseded by the bubble in quick 260720-bgl, and the only remaining non-bubble importer of the three `Test*` widgets)

## Decisions Made

- `GWColors` needed inside `_devButton` (an instance method, not a closure, per the plan's exact signature `_devButton(String label, VoidCallback onTap, {Color? accent})`) is captured via a `late GWColors _gw` field set at the top of `_buildExpandedPanel` on every build, rather than widening the method's parameter list.
- `_Section` renders `children` in a plain `Column`, not a `Wrap` — each call site supplies its own single child (a `Wrap` of buttons for MOCK/TEST FLOWS/NAVIGATE, a `Row` for APPEARANCE's toggle), so the section shell stays agnostic to internal layout.
- `Add tx`'s `context.read<GeniusApi>().getSGNUSTransactionsController()` call moved from build-time (original `TestTransactionButton` resolved it once per widget build) into the `onPressed` body — functionally equivalent (same `GeniusApi`/controller instance either way) and keeps every TEST FLOWS handler self-contained.
- **Plan adjustment (orchestrator-directed):** also deleted `lib/test/dev_tools_widget.dart` in the same commit as the three `Test*` files. It was fully orphaned (grep-verified: zero real `import`/`DevToolsWidget()` usage in `lib/`, only stale doc-comment mentions) and was the only remaining non-bubble importer of the three widgets being deleted — leaving it in place would have tripped the plan's own delete grep-gate.
- Stale `[DevToolsWidget]` doc-comment mentions in `lib/dev/design_gallery_screen.dart` (~:52-53) and `lib/dev/token_probe_screen.dart` (~:12) were **left unchanged** — `dev_tools_bubble.dart`'s own top-of-file doc comment already correctly identifies the bubble as `DevToolsWidget`'s replacement, so the dangling references are low-value doc drift, not a functional gap. Left as-is to avoid scope creep beyond this task's declared file list; noted here per the task instructions rather than silently skipped.

## Deviations from Plan

### Auto-fixed Issues

**1. [Plan adjustment / Rule 2-class fix] Deleted the newly-discovered fourth orphaned file, `lib/test/dev_tools_widget.dart`**
- **Found during:** Task 2 (pre-flight grep before running the delete gate)
- **Issue:** The plan's Task 2 deletes the three `Test*` widget files after confirming the bubble is their only importer. `lib/test/dev_tools_widget.dart` — the pre-260720-bgl header-row widget — still imported and used all three, so it would have failed the plan's own "confirm bubble is the only importer" precondition and the delete grep-gate.
- **Fix:** Verified `dev_tools_widget.dart` itself has zero real referencers anywhere in `lib/` (no `import`, no `DevToolsWidget()` instantiation — only stale doc-comment text mentions), then deleted it alongside the three `Test*` files in the same Task 2 commit.
- **Files modified:** `lib/test/dev_tools_widget.dart` (deleted)
- **Verification:** Plan's grep gate + `grep -r "import.*dev_tools_widget" lib/` (zero matches) + `flutter analyze lib/dev/dev_tools_bubble.dart` (0 issues).
- **Committed in:** `ddd9978`

---

**Total deviations:** 1 (orchestrator-flagged plan adjustment, applied as instructed before execution began — not an executor-discovered deviation under the standard Rule 1-4 process)
**Impact on plan:** Necessary for the plan's own delete grep-gate to pass; no scope creep — same deletion class (orphaned dev-only widget files), no behavior change to any live code path.

## Issues Encountered

None beyond the plan-adjustment deletion documented above.

## User Setup Required

None — no external service configuration required.

## Known Stubs

None.

## Threat Flags

None — this task touches only dev-gated (`kDebugMode && kShowDevTools`) code, matches the plan's `T-dty-01` threat register entry (accept, no gating change), and installs no new packages.

## Outstanding

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been performed.** Exact recipe (from `260720-dty-PLAN.md`), on the running `GW_DEV_TOOLS=true` build (hot-reload, do NOT start a fresh build):

1. Open the dev bubble (tap the bug FAB). Confirm four sections appear: MOCK + APPEARANCE OPEN by default; TEST FLOWS + NAVIGATE COLLAPSED by default.
2. Tap each section header — chevron flips and the body expands/collapses. Toggle all four both ways.
3. Switch to LIGHT mode via APPEARANCE. Confirm every section header, every button label, and the drag-handle 'Dev'/close X are clearly legible on the light panel (no near-invisible text, no neon-on-white). Switch back to DARK and confirm the same.
4. In MOCK: run Populated, Long/extreme, Missing icon, Clear — dashboard reacts exactly as before.
5. In NAVIGATE: Tokens opens the token-probe screen; Gallery opens the design gallery.
6. In TEST FLOWS: tap each button (Add tx, Approve conn, Swap OK/fail, Approve swap, Swap success/failed, Buy OK/fail) — each opens the same drawer / injects the tx + toast as before.
7. Confirm the bubble still DRAGS and stays clamped within the viewport (below the header, no edge overflow) in both collapsed and expanded states.

Resume signal: "approved" (both modes legible, all sections + flows working) or a description of issues.

## Next Phase Readiness

- Code changes are analyze-clean and committed (`c29fa0d`, `ddd9978`); no blockers for continuing other work.
- The Task 3 walk should be run before or alongside the next phase-05 walk, since it closes out the last known dev-tooling legibility/organization gap from the 260720-bgl walk feedback.

---
*Quick task: 260720-dty-sectionize-the-dev-tools-bubble-into-col*
*Completed: 2026-07-20*

## Self-Check: PASSED

- FOUND: lib/dev/dev_tools_bubble.dart
- CONFIRMED DELETED: lib/test/test_transaction_button.dart
- CONFIRMED DELETED: lib/reown/test/test_swap_buttons.dart
- CONFIRMED DELETED: lib/reown/test/test_buy_buttons.dart
- CONFIRMED DELETED: lib/test/dev_tools_widget.dart
- FOUND: .planning/quick/260720-dty-sectionize-the-dev-tools-bubble-into-col/260720-dty-SUMMARY.md
- FOUND: c29fa0d
- FOUND: ddd9978
