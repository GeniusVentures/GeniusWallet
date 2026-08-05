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
  - _Section collapsible-header helper + _devButton (now GWButton-backed) compact button helper
  - Test tx/swap/buy actions inlined as legible GWButton (tertiary) buttons, verbatim handlers preserved
  - lib/test/test_transaction_button.dart, lib/reown/test/test_swap_buttons.dart, lib/reown/test/test_buy_buttons.dart, lib/test/dev_tools_widget.dart deleted
affects: [05-dashboard, any future phase touching lib/dev/dev_tools_bubble.dart]

tech-stack:
  added: []
  patterns:
    - "Dev-panel section pattern: _Section(label, expanded, onToggle, gw, children) — chevron header + tappable InkWell, Column body rendered only when expanded"
    - "[SUPERSEDED by walk feedback, commit 2c1527f] ~~Status-hue-as-accent-dot: _devButton(label, onTap, {accent}) always renders the label in gw.textPrimary; accent paints an 8px decorative dot~~ — replaced with the branded GWButton pattern below; hand-rolled TextButton + accent dot still didn't read well enough on the light panel"
    - "Branded dev-action button: _devButton(label, onTap, {tooltip}) wraps GWButton(variant: tertiary, size: sm) — surfaceElevated fill + borderSubtle border + gw.textPrimary label, appearance-aware via the app's existing button component rather than a hand-rolled Theme read. tooltip carries the full description for labels shortened to fit GWButtonSize.sm's single-line ellipsis (Long / extreme -> Long, Missing icon -> No icon, Approve conn -> Conn, Approve swap -> Appr, Swap success -> Succeed, Swap failed -> Failed)"

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
  - "[SUPERSEDED, commit 2c1527f] ~~GWColors needed inside the _devButton instance method is captured via a late GWColors _gw field~~ — removed once _devButton delegates to GWButton, which reads Theme.of(context) itself; the field became dead code and was deleted to keep flutter analyze clean."
  - "_Section renders its children in a plain Column (not a Wrap) so each section's caller controls its own internal layout (Wrap of buttons for MOCK/TEST FLOWS/NAVIGATE, a Row for APPEARANCE's toggle) rather than forcing one layout shape on every section."
  - "[Walk feedback fix, commit 2c1527f] _devButton's action buttons switched from a hand-rolled TextButton + gw.textPrimary Text to the app's branded GWButton(variant: tertiary, size: sm) component — the coordinator's light-mode walk found the plain-text buttons still didn't read well enough; GWButton's tertiary variant (surfaceElevated fill + borderSubtle border + gw.textPrimary label) gives real contrast in both modes using an existing, already-tested component instead of ad hoc styling."
  - "[Walk feedback fix, commit 2c1527f] Dropped the accent parameter/dot entirely per explicit coordinator direction ('this replaces... any leftover accent dots'); GWButton.tooltip now carries each action's full original description (e.g. 'Test Approve Swap Drawer') so meaning isn't lost when a label is shortened to fit GWButtonSize.sm's one-line ellipsis truncation."
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
    description: "Test tx/swap/buy actions inlined as compact GWButton (tertiary) buttons running their original flows verbatim; no hardcoded Colors.*Accent remains in the bubble; the three orphaned Test* widget files (plus the newly-orphaned dev_tools_widget.dart) are deleted and unreferenced"
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
  - id: D3
    description: "Walk feedback fix: all MOCK/TEST FLOWS/NAVIGATE action buttons converted from hand-rolled TextButton to branded GWButton(tertiary, sm) for real light-mode contrast; labels shortened where needed with full descriptions preserved via tooltip"
    requirement: "260720-dty"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Actual legibility of GWButton's tertiary variant on the live light-mode panel, and whether any shortened label still reads clearly, requires the still-outstanding Task 3 re-walk -- this is a pre-walk fix-forward per direct coordinator feedback, not yet re-verified visually."

duration: ~25min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-dty: Sectionize the dev-tools bubble into collapsible sections Summary

**Reworked `lib/dev/dev_tools_bubble.dart`'s expanded panel into four collapsible sections (MOCK, TEST FLOWS, NAVIGATE, APPEARANCE) via a new `_Section` helper, and inlined the Test tx/swap/buy flows into `_devButton` calls now backed by the app's branded `GWButton(variant: tertiary, size: sm)` — fixing the light-mode illegibility of first the old icon-only `Colors.*Accent` buttons, then (per direct walk feedback) the follow-up hand-rolled `TextButton` styling too. Deletes the three now-orphaned `Test*` widget files, plus (plan adjustment) the fully-dead old `DevToolsWidget` that was their only other referencer.**

## Performance

- **Duration:** ~25 min
- **Tasks:** 2 of 2 auto tasks complete + 1 walk-feedback fix-forward commit; Task 3 is a blocking human-verify checkpoint, not performed by this run
- **Files modified:** 1 modified, 4 deleted

## Accomplishments

- Added four per-section `bool` expand flags (`_mockExpanded = true`, `_testFlowsExpanded = false`, `_navigateExpanded = false`, `_appearanceExpanded = true`) matching the D-01 default-state requirement.
- Added the private `_Section` `StatelessWidget`: chevron (`expand_more`/`chevron_right`) + uppercase-style label header (`InkWell` → `onToggle`), body rendered only when `expanded`.
- Reorganized the panel body into the four sections in order MOCK → TEST FLOWS → NAVIGATE → APPEARANCE, each wired to its own `setState` toggle. MOCK's four scenario buttons (Populated/Long/No icon/Clear) and NAVIGATE's Tokens/Gallery pushes were re-expressed via `_devButton` with identical `DevMockHoldings`/`WalletDetailsCubit`/`context.push` wiring. APPEARANCE keeps its original `Row` (icon + Light/Dark label + `GWAppearance.instance.setMode`) untouched, unflagged by the walk feedback.
- Inlined all nine Test* actions into TEST FLOWS as `_devButton` calls: Add tx, Conn, Swap OK, Swap fail, Appr, Succeed, Failed, Buy OK, Buy fail — each handler body copied verbatim from the deleted widgets (same drawer classes, same args, same toast).
- Deleted `lib/test/test_transaction_button.dart`, `lib/reown/test/test_swap_buttons.dart`, `lib/reown/test/test_buy_buttons.dart` after inlining, plus `lib/test/dev_tools_widget.dart` (plan adjustment, see below).
- Updated imports: removed the three `Test*` widget imports; added `package:genius_api/genius_api.dart`, the six reown/squid/banxa drawer imports, `genius_wallet/test/dev_overrides.dart`, `genius_wallet/components/toast/toast_manager.dart`.
- **[Walk feedback fix]** Coordinator's light-mode walk found the plain hand-rolled `TextButton` + accent-dot styling still didn't read well. `_devButton(label, onTap, {tooltip})` now wraps `GWButton(variant: tertiary, size: sm)` for every MOCK/TEST FLOWS/NAVIGATE action button; dropped the accent-dot concept entirely (as directed) and added `tooltip` to carry full descriptions for labels shortened to fit the button's one-line ellipsis (`Long / extreme`→`Long`, `Missing icon`→`No icon`, `Approve conn`→`Conn`, `Approve swap`→`Appr`, `Swap success`→`Succeed`, `Swap failed`→`Failed`). Removed the now-unused `late GWColors _gw` field and `genius_wallet_colors.dart` import (GWButton reads `Theme.of(context)` itself); added `genius_wallet/components/buttons/gw_button.dart`.

## Task Commits

Each auto task was committed atomically, plus one fix-forward from direct coordinator walk feedback:

1. **Task 1: Add `_Section` + `_devButton` helpers and reorganize the panel body into 4 collapsible sections** - `c29fa0d` (feat)
2. **Task 2: Inline the Test tx/swap/buy flows as legible gw-styled buttons and delete the orphaned Test\* widgets (+ plan-adjustment deletion of `dev_tools_widget.dart`)** - `ddd9978` (feat)
3. **Walk feedback fix: replace hand-rolled dev-bubble buttons with branded `GWButton`** - `2c1527f` (fix)

Task 3 is a `checkpoint:human-verify` gate (`gate="blocking"`) — not a commit-producing task. Per this run's instructions, the walk was intentionally NOT performed by the executor; commit `2c1527f` is a pre-walk fix-forward from partial feedback, still awaiting the full re-walk.

## Files Created/Modified/Deleted

- `lib/dev/dev_tools_bubble.dart` - Reworked expanded panel: 4 `_Section`s, `_devButton` helper, inlined test-flow handlers
- `lib/test/test_transaction_button.dart` - Deleted (orphaned after inline)
- `lib/reown/test/test_swap_buttons.dart` - Deleted (orphaned after inline)
- `lib/reown/test/test_buy_buttons.dart` - Deleted (orphaned after inline)
- `lib/test/dev_tools_widget.dart` - Deleted (plan adjustment; the OLD `DevToolsWidget`, fully superseded by the bubble in quick 260720-bgl, and the only remaining non-bubble importer of the three `Test*` widgets)

## Decisions Made

- `_Section` renders `children` in a plain `Column`, not a `Wrap` — each call site supplies its own single child (a `Wrap` of buttons for MOCK/TEST FLOWS/NAVIGATE, a `Row` for APPEARANCE's toggle), so the section shell stays agnostic to internal layout.
- `Add tx`'s `context.read<GeniusApi>().getSGNUSTransactionsController()` call moved from build-time (original `TestTransactionButton` resolved it once per widget build) into the `onPressed` body — functionally equivalent (same `GeniusApi`/controller instance either way) and keeps every TEST FLOWS handler self-contained.
- **Plan adjustment (orchestrator-directed):** also deleted `lib/test/dev_tools_widget.dart` in the same commit as the three `Test*` files. It was fully orphaned (grep-verified: zero real `import`/`DevToolsWidget()` usage in `lib/`, only stale doc-comment mentions) and was the only remaining non-bubble importer of the three widgets being deleted — leaving it in place would have tripped the plan's own delete grep-gate.
- Stale `[DevToolsWidget]` doc-comment mentions in `lib/dev/design_gallery_screen.dart` (~:52-53) and `lib/dev/token_probe_screen.dart` (~:12) were **left unchanged** — `dev_tools_bubble.dart`'s own top-of-file doc comment already correctly identifies the bubble as `DevToolsWidget`'s replacement, so the dangling references are low-value doc drift, not a functional gap. Left as-is to avoid scope creep beyond this task's declared file list; noted here per the task instructions rather than silently skipped.
- **[Walk feedback fix, commit `2c1527f`]** `_devButton` now wraps `GWButton(variant: tertiary, size: sm)` instead of a hand-rolled `TextButton` — the coordinator's walk found the plain-text styling still illegible enough in light mode; `GWButtonVariant.tertiary` (`surfaceElevated` fill + `borderSubtle` border + `gw.textPrimary` label) reuses an existing, already-vetted appearance-aware component rather than another ad hoc fix.
- **[Walk feedback fix, commit `2c1527f`]** The accent-dot concept (status hue as a small decorative `Container`) was removed entirely per explicit coordinator direction, not replaced with an equivalent — `GWButton` has no leading-dot slot built for this purpose, and the directive was clear that tertiary styling should replace it outright, not carry it forward via `leading:`.
- **[Walk feedback fix, commit `2c1527f`]** Six labels were shortened to avoid `GWButtonSize.sm`'s one-line ellipsis truncation at the panel's ~260px width (`Long / extreme`→`Long`, `Missing icon`→`No icon`, `Approve conn`→`Conn`, `Approve swap`→`Appr`, `Swap success`→`Succeed`, `Swap failed`→`Failed`); each shortened button carries its full original description via `GWButton.tooltip` so no meaning is lost, and `Succeed`/`Failed` were deliberately chosen (not `Swap OK`/`Swap fail`, already used by the separate `SwapResultDrawer` buttons) to keep the two distinct swap-outcome drawers visually distinguishable.

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

**2. [Coordinator-directed fix, post-Task-2] Plain TextButtons still didn't read well in light mode**
- **Found during:** A pre-Task-3 partial walk by the coordinator (the full Task 3 checkpoint has not been performed)
- **Issue:** The hand-rolled `TextButton` + `gw.textPrimary` + accent-dot styling introduced in Task 1/2 was still not legible enough on the light `gw.surfaceMenu` panel.
- **Fix:** Converted every MOCK/TEST FLOWS/NAVIGATE action button to the app's branded `GWButton(variant: GWButtonVariant.tertiary, size: GWButtonSize.sm)`, which fills `surfaceElevated`, borders `borderSubtle`, and labels `gw.textPrimary` — an existing, already-tested appearance-aware component. Dropped the accent-dot concept per direct instruction. Shortened six labels that would truncate under `GWButtonSize.sm`'s one-line ellipsis, preserving the full description via `GWButton.tooltip`. Every handler body kept verbatim; the APPEARANCE toggle was left unchanged (not flagged, already appearance-aware).
- **Files modified:** `lib/dev/dev_tools_bubble.dart`
- **Verification:** `flutter analyze lib/dev/dev_tools_bubble.dart` → 0 issues. `git diff --cached --name-only` confirmed only `lib/dev/dev_tools_bubble.dart` staged (README.md left untouched).
- **Committed in:** `2c1527f`

---

**Total deviations:** 2 (1 orchestrator-flagged plan adjustment applied before execution began; 1 coordinator-directed walk-feedback fix-forward applied after Task 2 — neither is an executor-discovered deviation under the standard Rule 1-4 process)
**Impact on plan:** Both necessary corrections directed by the coordinator/orchestrator, not scope creep of the executor's own initiative — same file (`dev_tools_bubble.dart`) for the second fix, same deletion class for the first, no behavior change to any handler.

## Issues Encountered

None beyond the plan-adjustment deletion documented above.

## User Setup Required

None — no external service configuration required.

## Known Stubs

None.

## Threat Flags

None — this task touches only dev-gated (`kDebugMode && kShowDevTools`) code, matches the plan's `T-dty-01` threat register entry (accept, no gating change), and installs no new packages.

## Outstanding

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been performed.** A partial walk already surfaced one issue (fixed in `2c1527f`, see Deviations); the full re-walk against the GWButton fix is still required. Exact recipe (from `260720-dty-PLAN.md`), on the running `GW_DEV_TOOLS=true` build (hot-reload, do NOT start a fresh build):

1. Open the dev bubble (tap the bug FAB). Confirm four sections appear: MOCK + APPEARANCE OPEN by default; TEST FLOWS + NAVIGATE COLLAPSED by default.
2. Tap each section header — chevron flips and the body expands/collapses. Toggle all four both ways.
3. Switch to LIGHT mode via APPEARANCE. Confirm every section header, every button (now `GWButton` tertiary — check contrast against the light `gw.surfaceMenu` panel), and the drag-handle 'Dev'/close X are clearly legible. Switch back to DARK and confirm the same.
4. In MOCK: run Populated, Long, No icon, Clear — dashboard reacts exactly as before. Confirm each shortened label still reads clearly and its tooltip (on hover) shows the full description.
5. In NAVIGATE: Tokens opens the token-probe screen; Gallery opens the design gallery.
6. In TEST FLOWS: tap each button (Add tx, Conn, Swap OK/fail, Appr, Succeed, Failed, Buy OK/fail) — each opens the same drawer / injects the tx + toast as before; confirm the shortened labels don't cause confusion (hover tooltips available if needed).
7. Confirm the bubble still DRAGS and stays clamped within the viewport (below the header, no edge overflow) in both collapsed and expanded states.

Resume signal: "approved" (both modes legible, all sections + flows working) or a description of issues.

## Next Phase Readiness

- Code changes are analyze-clean and committed (`c29fa0d`, `ddd9978`, `2c1527f`); no blockers for continuing other work.
- The Task 3 walk should be run before or alongside the next phase-05 walk, since it closes out the last known dev-tooling legibility/organization gap from the 260720-bgl walk feedback, now including the GWButton fix-forward from this run's partial walk.

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
- FOUND: 2c1527f
