---
phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl
plan: 02
subsystem: ui
tags: [flutter, drawers, design-system, gw-select-row, bridge]

requires:
  - phase: 21-01
    provides: "GWSelectRow (lib/components/cards/gw_select_row.dart) as the shared 032-A1 list-row primitive, already adopted by 4 callers"
provides:
  - "The bridge destination picker (bridge_screen.dart) as the fifth and last GWSelectRow call site"
  - "Deletion of the private _NetworkPickerRow class -- no hand-rolled list row remains in bridge_screen.dart"
  - "test/dashboard/bridge/bridge_destination_picker_test.dart -- the picker's first-ever behavioural check"
affects: [21-06]

tech-stack:
  added: []
  patterns:
    - "bridge_screen.dart's ListView now opts out of kDrawerBodyPadding (bodyPadding: EdgeInsets.zero) and carries its own space10 inset on the ListView itself, matching network_dropdown_selector.dart's already-shipped shape exactly"

key-files:
  created:
    - test/dashboard/bridge/bridge_destination_picker_test.dart
  modified:
    - lib/dashboard/bridge/bridge_screen.dart

key-decisions:
  - "No wrapper class introduced -- GWSelectRow is called inline in the loop, matching the shape 21-01 already settled on for the token picker (a one-consumer wrapper around a shared row earns nothing)"
  - "Test 2's harness mirrors _showDestinationNetworkPicker's exact shape (same ResponsiveDrawer.show args, same GWSelectRow mapping, same setState+pop tap body) rather than mounting the full BridgeScreen, which needs a WalletDetailsCubit/GeniusApi/NetworkProvider graph that is scaffolding for this check, not its point -- per the plan's own explicit permission to do this and record the choice"

requirements-completed: []

coverage:
  - id: D1
    description: "The bridge destination picker's selected row reads exactly like the selected row in Select Network, Your Accounts, SDK Accounts and the token picker -- one rounded gradient tint with a gradient check, from one source (GWSelectRow)"
    verification:
      - kind: unit
        ref: "test/dashboard/bridge/bridge_destination_picker_test.dart#the currently-selected destination is the only GWSelectRow with selected: true"
        status: pass
      - kind: unit
        ref: "test/components/gw_select_row_test.dart (pre-existing, unmodified) -- proves the shared row's gradient tint + 6.81:1 gradient check"
        status: pass
    human_judgment: true
    rationale: "The must-have truth is partly a visual claim (\"reads exactly like\" the other four pickers) that this session cannot observe live -- see Outstanding Visual Verification. The automated half (selection wiring comes from the shared, tested row) is proven; the pixel-identical claim is not."
  - id: D2
    description: "Picking a destination network still calls the same setState and still pops the same drawer -- the picker's data path is byte-identical to today's"
    verification:
      - kind: unit
        ref: "test/dashboard/bridge/bridge_destination_picker_test.dart#tapping a row pops the drawer and hands back the tapped network"
        status: pass
    human_judgment: false
  - id: D3
    description: "No private list-row widget survives in bridge_screen.dart -- the five list pickers are five call sites of one row, not four plus one"
    verification:
      - kind: unit
        ref: "grep -c 'class _NetworkPickerRow' lib/dashboard/bridge/bridge_screen.dart == 0; grep -c 'GWSelectRow' lib/dashboard/bridge/bridge_screen.dart == 2"
        status: pass
    human_judgment: false

duration: ~15min
completed: 2026-07-30
status: complete
---

# Phase 21 Plan 02: Bridge destination picker to GWSelectRow Summary

**The bridge destination-network picker is now the fifth and last GWSelectRow call site: the hand-rolled `_NetworkPickerRow` (a `borderStrong` rectangle + untinted check) is deleted, replaced by an inline `GWSelectRow` loop matching `network_dropdown_selector.dart`'s shape exactly, with a new two-test behavioural check.**

## Performance

- **Duration:** ~15 min (estimated from commit timestamps; `PLAN_START_TIME` was not captured at session start)
- **Completed:** 2026-07-30T15:41:00Z
- **Tasks:** 2/2
- **Files modified:** 2 (1 edited, 1 new test file)

## Accomplishments
- `_showDestinationNetworkPicker`'s `ListView` now carries its own `space10` inset (the documented `kDrawerBodyPadding` opt-out), matching the other four converted pickers instead of the previous `shrinkWrap`-only, unpadded list.
- Replaced every `_NetworkPickerRow(...)` invocation with an inline `GWSelectRow`, keyed on `network.chainId == toNetwork?.chainId` exactly as before; the tap closure (`setState(() => toNetwork = network)` then `Navigator.of(context).pop()`) is untouched.
- Deleted the private `_NetworkPickerRow` class entirely -- no orphaned dead code left "in case."
- Added `test/dashboard/bridge/bridge_destination_picker_test.dart`, the picker's first-ever test: selection wiring (keyed by `chainId`, not `name`) and the tap-pops-with-tapped-network data path.

## Task Commits

Each task was committed atomically:

1. **Task 1: The bridge destination picker becomes the fifth GWSelectRow call site (D-04)** - `1682131` (feat)
2. **Task 2: The one check this picker owes** - `9ce72d0` (test)

**Plan metadata:** (this commit, docs)

## Files Created/Modified

- `lib/dashboard/bridge/bridge_screen.dart` - Added `GWSelectRow` import; `_showDestinationNetworkPicker`'s `ListView` gained `padding: const EdgeInsets.all(GeniusWalletConsts.space10)` plus a doc comment recording the contrast rationale (old row 1.60:1 border, new row's check 6.81:1); the loop body now builds `GWSelectRow` directly (`leading`: 36x36 `Image.asset` with an errorBuilder same-sized `SizedBox`, `title`: `network.name ?? ''`); the private `_NetworkPickerRow` class (lines 796-845 before this edit) is deleted.
- `test/dashboard/bridge/bridge_destination_picker_test.dart` - NEW. A `_DestinationPickerHarness` `StatefulWidget` mirrors the picker's exact shape (same `ResponsiveDrawer.show` args, same `GWSelectRow` mapping, same tap body) so the two tests assert on `selected` wiring and the tap's observable effect without needing `BridgeScreen`'s full bloc/provider graph.

## Decisions Made

See `key-decisions` in frontmatter. In short: no new wrapper class (Rule of Three, matches 21-01's precedent on the token picker); the test harness reproduces the picker's shape rather than mounting the whole screen, a choice explicitly permitted and recorded per the plan's own instruction to "record that choice in the header comment rather than silently narrowing the test."

## Deviations from Plan

None - plan executed exactly as written. One clarification worth recording: the plan's own `<constraints>` said "Do not commit... the orchestrator serialises the commits, not you," written for a 4-way parallel wave. This execution's actual dispatch instructions (`<sequential_execution>`) explicitly designated this session as the SEQUENTIAL executor with worktree isolation disabled and ownership of STATE.md/ROADMAP.md — a mode not anticipated by the plan file's own wave-1-parallel assumption. Per that dispatch's explicit direction, both tasks were committed atomically as instructed, rather than left in the working tree.

## Issues Encountered

None. No build errors, no flaky tests, no auth gates. `flutter analyze` was 0 issues on both the touched file and the whole `lib/` tree before and after; `packages/genius_api`'s analyze reports a pre-existing, unrelated `lints/recommended.yaml include_file_not_found` warning (exit 0) that predates this plan and touches no file this plan modified -- out of scope per the scope-boundary rule.

## Outstanding Visual Verification (recorded, not claimed)

This session has no running app instance -- the orchestrator owns `flutter run`. Recorded **OUTSTANDING**, not PASS, per this project's standing no-unearned-PASS rule:

- [ ] Bridge tab -> tap the destination chip. In **dark** mode: the currently selected destination shows a rounded gradient tint plus a gradient check; every other row shows neither. No square full-bleed fill, no vertical accent bar, no rectangle border.
- [ ] Repeat in **light** mode. The check glyph must still be the thing that reads first.
- [ ] The rows sit inset from the panel edges and scroll with their inset -- no gap at the top, no double padding, nothing edge-to-edge.
- [ ] Pick a different destination: the drawer closes and the destination chip shows the chain you picked.
- [ ] Narrow the window below 768 so the drawer becomes a bottom sheet, and confirm all four points again.

## Next Phase Readiness

- All five 032-A1 list pickers (`network_dropdown_selector.dart`, `account_drawer.dart`, `sdk_account_manager.dart`, `token_selector_drawer.dart`, `bridge_screen.dart`) now consume `GWSelectRow` directly; `grep -rl 'GWSelectRow' lib/` confirms exactly these five files.
- No private list-row class remains anywhere in scope for D-04.
- 21-06 (the invariant sweep) can verify this picker alongside the other four without further conversion work.

---
*Phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl*
*Completed: 2026-07-30*

## Self-Check: PASSED

- FOUND: `lib/dashboard/bridge/bridge_screen.dart`
- FOUND: `test/dashboard/bridge/bridge_destination_picker_test.dart`
- FOUND commit: `1682131`
- FOUND commit: `9ce72d0`
- Full suite: 734/734 passing (732 baseline + 2 new). `flutter analyze` 0/0 (root + `packages/genius_api`, modulo the pre-existing unrelated `lints/recommended.yaml` warning). `check_brace_style.sh` / `check_raw_colors.sh` both 0. `check_no_new_key_logging.sh --scan-tree` and `check_onboarding_seed_safety.sh` both PASSED. `dart format --set-exit-if-changed lib test` exit 0 (343 files, 0 changed).
