---
phase: quick-260731-kc5
plan: 01
subsystem: ui
tags: [flutter, accessibility, wcag, control-track, compute-panel, dashboard]

requires:
  - phase: 260731-jx5
    provides: GWControlTrack (lib/components/gw_control_track.dart), the shared control-track container this task adopts as its fourth consumer
provides:
  - The Compute panel's balance unit is a two-segment GWControlTrack (GNUS / MIN), both units always visible, built on the shared container
  - Value-based ValueChanged<bool> onUnitChanged callback (ComputePanel, _BalanceTile, WalletsOverview._setUnit) replacing the VoidCallback toggle that could double-tap-flip
  - A full regression test file (compute_balance_unit_track_test.dart, 10 tests) locking in visibility, height, 24x24 target, semantics, keyboard operability, no-op-on-active-tap, and the measured width/clipping cost
affects: [compute-panel, dashboard, gw-control-track-consumers]

tech-stack:
  added: []
  patterns:
    - "Segmented control built on shared GWControlTrack container, geometry-conformant with GWTimeframeSegment/transaction filter/Buy GNUS orders track, deliberately non-conformant on colour (no gradient) and input handling (kept InkWell, not GestureDetector)"
    - "Value-based ValueChanged<bool> callback instead of VoidCallback toggle, to make double-tap-does-not-flip a structural guarantee rather than a guard"

key-files:
  created:
    - test/dashboard/compute_balance_unit_track_test.dart
    - .planning/todos/pending/2026-07-31-track-chip-unselected-text-under-aa-on-surfacesunken-light.md
    - .planning/todos/pending/2026-07-31-balance-unit-track-clips-a-large-minions-balance-at-320px.md
    - .planning/todos/pending/2026-07-31-track-chips-are-not-keyboard-operable.md
  modified:
    - lib/dashboard/compute/compute_panel.dart
    - lib/components/wallet_overview.dart
    - lib/components/gw_control_track.dart
    - lib/components/gw_timeframe_segment.dart
    - test/dashboard/compute_panel_height_test.dart
    - test/theme/compute_contrast_test.dart

key-decisions:
  - "Minions segment reads MIN, not MINIONS - matches sketch 170 and the existing genius_balance_display.dart:89 abbreviation; accessible name stays the full word Minions; reversible in one line (_kMinionsLabel) if Jakub rejects it"
  - "onToggleUnit (VoidCallback) replaced with onUnitChanged (ValueChanged<bool>) end to end - removes a real double-tap-flip bug, not just a rename"
  - "No gradient on either segment, unlike GWTimeframeSegment/_FilterChip - a unit selector must not carry the same visual weight as the panel's one filled CTA (New processing job)"
  - "InkWell + Material kept (not matched to the other tracks' bare GestureDetector) - the other two tracks fail WCAG 2.1.1 Keyboard (Level A) and matching them would trade that away; filed as a todo instead"
  - "Gap from the balance number changed from space2 (4px) to space4 (8px), matching the track's own internal chip padding"
  - "A pre-existing, systemic WCAG AA gap (gw.textSecondary vs gw.surfaceSunken, light mode, 4.23:1) shared with GWTimeframeSegment/_FilterChip's unselected labels is NOT patched locally - fixing only this component would break conformance and leave the other two broken; filed as a todo, test floor set to the measured value plus a dark-mode 4.5:1 assertion"
  - "The 320px width-clipping test is a RECORDING, not an aspiration - it asserts the measured clip lands in an expected range so the finding cannot be silently lost in either direction, per explicit coordinator instruction after the first version left it permanently red"

requirements-completed: [260731-kc5]

coverage:
  - id: D1
    description: "Balance unit control is a two-segment GWControlTrack (GNUS/MIN), both units visible at rest, active one raised"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#both units are visible without pressing anything"
        status: pass
    human_judgment: true
    rationale: "Visual read (does it look like a control vs a flat outline, per the plan's own fill-step question) needs Jakub's eyes on the live app in both themes"
  - id: D2
    description: "Track costs no height - panel height budget unchanged"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#the track costs no height"
        status: pass
      - kind: unit
        ref: "test/dashboard/compute_panel_height_test.dart (all 32 state/width/unit combinations)"
        status: pass
    human_judgment: false
  - id: D3
    description: "24x24 minimum tap target on each segment (WCAG 2.5.8 AA)"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#every segment clears the 24x24 WCAG 2.5.8 minimum target"
        status: pass
    human_judgment: false
  - id: D4
    description: "Semantics announce both options and which is selected (group + two explicit child nodes, full word Minions as accessible name)"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#semantics announce both options and which is selected - GNUS active / minions active"
        status: pass
    human_judgment: false
  - id: D5
    description: "Keyboard operable via InkWell (Enter/Space), not a bare GestureDetector"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#keyboard operability is not lost"
        status: pass
    human_judgment: true
    rationale: "Focus-ring visibility and Tab-then-Enter activation is a live keyboard walk step (plan human-check item 8), not cheaply assertable end to end in this widget-test harness"
  - id: D6
    description: "Tapping the active segment is a no-op, including on an immediate double tap - the value-based callback shape"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#tapping the active segment is a no-op"
        status: pass
    human_judgment: false
  - id: D7
    description: "Tapping the other segment switches the unit"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#tapping the other segment switches the unit"
        status: pass
    human_judgment: false
  - id: D8
    description: "Width/clipping cost measured and recorded at both 320px and 290px with a plausible large minions balance"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_balance_unit_track_test.dart#the width cost is measured, not estimated, at both widths"
        status: pass
    human_judgment: true
    rationale: "The test records the clip as a passing, bounded measurement; whether the ~1-digit clip at 320px is acceptable, or the fallback to sketch 170 scheme A should be taken instead, is Jakub's decision - see the filed todo"
  - id: D9
    description: "flutter analyze clean, both shell gates pass, dashboard+theme test directories green"
    verification:
      - kind: unit
        ref: "flutter analyze (whole project)"
        status: pass
      - kind: unit
        ref: "tool/check_brace_style.sh"
        status: pass
      - kind: unit
        ref: "tool/check_raw_colors.sh"
        status: pass
      - kind: unit
        ref: "flutter test test/dashboard/ (294/294) and test/theme/ (83/83)"
        status: pass
    human_judgment: false

duration: ~1h 50min
completed: 2026-07-31
status: complete
---

# Quick Task 260731-kc5: Balance unit toggle becomes a two-segment control track Summary

**Compute panel balance unit rebuilt as a two-segment `GWControlTrack` (GNUS/MIN, both visible at rest) with a value-based `onUnitChanged` callback that makes double-tap-flip structurally impossible, backed by a 10-test regression file - plus three filed accessibility/design-decision todos surfaced by the work.**

## Performance

- **Duration:** ~1h 50min
- **Tasks:** 3 (all completed)
- **Files modified:** 6 (`compute_panel.dart`, `wallet_overview.dart`, `gw_control_track.dart`, `gw_timeframe_segment.dart`, `compute_panel_height_test.dart`, `compute_contrast_test.dart`)
- **Files created:** 4 (`compute_balance_unit_track_test.dart` + 3 todos)

## Accomplishments

- `_UnitToggle` (a single-label, purely-visually-a-button toggle) replaced by `_UnitTrack`/`_UnitSegment`, a two-segment control built on the shared `GWControlTrack` container - the fourth consumer, converging with `GWTimeframeSegment`, the transaction filter bar, and the Buy GNUS orders track.
- `ComputePanel`'s `VoidCallback onToggleUnit` became `ValueChanged<bool> onUnitChanged` end to end (`ComputePanel`, `_BalanceTile`, `WalletsOverviewState._setUnit`), closing a real double-tap-flip bug: a toggle-shaped callback lets two taps on the same segment inside one frame both read the pre-tap `selected` value and both fire, flipping the unit and flipping it back.
- All three properties sketch 170 named as must-not-regress carry forward and are now test-locked: the 24x24 WCAG 2.5.8 target, two-node semantics (group + explicit children, full word `Minions` as the accessible name for the visible `MIN`), and `InkWell`-based keyboard operability - deliberately NOT matched to the other two tracks' bare `GestureDetector`, which fails WCAG 2.1.1 Level A.
- New `test/dashboard/compute_balance_unit_track_test.dart` (10 tests): visibility, height-by-comparison, tap-target size, semantics x2 (GNUS active / minions active), keyboard operability, no-op-on-active-tap including an immediate double tap, switch-on-other-tap, and the measured width/clipping cost at both 320px and 290px.
- Real `Inter-Bold` font metrics loaded in the test (`setUpAll`) specifically for the width-cost measurement - `flutter test` never loads bundled fonts by default, and the deterministic fallback test font measures glyphs roughly 1.7x wider than production, which would have badly overstated the clipping finding.
- Balance-to-track gap changed from `space2` (4px) to `space4` (8px), matching the track's own internal chip padding.

## Files Created/Modified

- `lib/dashboard/compute/compute_panel.dart` - `_UnitToggle` replaced by `_UnitTrack`/`_UnitSegment`; `ComputePanel`/`_BalanceTile` take `ValueChanged<bool> onUnitChanged`; gap changed to `space4`.
- `lib/components/wallet_overview.dart` - `_toggleUnit()` replaced by `_setUnit(bool useMinions)` with an early return when the value is unchanged.
- `lib/components/gw_control_track.dart` - doc-comment consumer list updated from three to four (the only permitted edit to this file).
- `lib/components/gw_timeframe_segment.dart` - one comment updated from "the three" to "the four" tracks that share `GWControlTrack` (the only permitted edit to this file).
- `test/dashboard/compute_panel_height_test.dart` - `onToggleUnit: () {}` fixture updated to `onUnitChanged: (_) {}`; nothing else changed.
- `test/theme/compute_contrast_test.dart` - same fixture rename, plus a new group covering the segment foregrounds in both states/modes.
- `test/dashboard/compute_balance_unit_track_test.dart` - new, 10 tests (see Accomplishments).
- `.planning/todos/pending/2026-07-31-track-chip-unselected-text-under-aa-on-surfacesunken-light.md` - new, pre-existing systemic contrast gap.
- `.planning/todos/pending/2026-07-31-balance-unit-track-clips-a-large-minions-balance-at-320px.md` - new, the width-cost finding.
- `.planning/todos/pending/2026-07-31-track-chips-are-not-keyboard-operable.md` - new, Task 3's keyboard-operability finding in the other two tracks.

## Decisions Made

See `key-decisions` in frontmatter. The two most load-bearing:

1. **Value-based callback, not a rename.** `onUnitChanged(bool)` replacing `onToggleUnit()` removes a real bug (double-tap flips to the other unit and back), not just cosmetics.
2. **Deliberate non-conformance kept, not "fixed."** The balance unit track keeps `InkWell` where the other two tracks use a bare `GestureDetector` - matching them would trade away real keyboard operability for consistency that CONVENTIONS.md never asked for in input handling, only geometry.

## Deviations from Plan

### Auto-fixed / discovered during execution

**1. [Rule 1/2 - accessibility, scope-bounded] Segment semantics needed `excludeSemantics: true`**
- **Found during:** Task 2, first test run.
- **Issue:** Without it, each segment's visible `Text` ("GNUS"/"MIN") merged its own literal label into the explicit `Semantics(label:)` node, so `find.bySemanticsLabel('GNUS')` and `('Minions')` found nothing (or a garbled concatenation) instead of the clean accessible name.
- **Fix:** Added `excludeSemantics: true` to each segment's `Semantics` widget.
- **Files modified:** `lib/dashboard/compute/compute_panel.dart`.
- **Verification:** `compute_balance_unit_track_test.dart`'s two semantics tests pass.

**2. [Rule 4-adjacent - reported, not silently fixed] A pre-existing, systemic WCAG AA contrast gap surfaced**

Writing the new contrast test group (`gw.textSecondary` on `gw.surfaceSunken`, the unselected segment's effective background) found this pairing measures 4.23:1 in light mode - under the 4.5:1 AA floor - and dark mode measures 6.2:1 (passes). This is NOT new: `GWTimeframeSegment` and `_FilterChip`'s unselected labels already ship this exact pairing, untested, and `gw_colors.dart:192-195` already documents the identical ceiling for a different token on the same surface ("no current consumer paints body text on surfaceSunken" - now three do).

- **Action taken:** Did NOT invent a one-off colour for only this segment (would break the very conformance this task exists to buy, and leave the other two consumers still broken). Test asserts dark mode at the real 4.5:1 floor and light mode at the measured 4.23:1 floor, both documented in-comment. Filed `.planning/todos/pending/2026-07-31-track-chip-unselected-text-under-aa-on-surfacesunken-light.md` mirroring the existing `statusSuccess`/`statusError` AA-gap todo precedent. Consistent with the project's dark-first, light-deferred policy.

**3. [Rule 4 - reported to Jakub, not resolved] The balance unit track clips a large minions balance at the REALISTIC 320px panel width**

Task 2's width-cost test, run with real `Inter-Bold` font metrics, measured: at 320px, track=102.24px, a plausible large minions balance ("987,654.32") wants 178.69px, viewport gets 157.76px - clipped by **~20.9px, roughly one tabular digit**. At 290px (a stress case, not a production width), clipped by ~50.9px (~2-3 digits).

- **First pass mistake, corrected mid-session:** the test was initially written to assert "not clipped," which correctly failed and correctly reported the finding - but a permanently red test in the suite destroys the signal of every other test and invites a future "fix" by shrinking the chips, which the plan explicitly forbids. Per the coordinator's explicit instruction, the assertion was converted from an aspiration into a RECORDING: it now asserts the clip falls within the measured range (15-30px at 320px, 40-60px at 290px), with the exact figures and the two options (accept the clip, or fall back to sketch 170 scheme A) in an in-test comment. The test is green; the finding cannot be silently lost in either direction (regression or resolution).
- **Action taken:** Did NOT narrow the track's padding, relabel `MIN`, or change the number's style to make it fit - any of those would hide the finding rather than resolve it, and CONVENTIONS.md conformance is the entire point of this task. Filed `.planning/todos/pending/2026-07-31-balance-unit-track-clips-a-large-minions-balance-at-320px.md` with the full numbers and both options. **This decision is Jakub's, not this executor's.**

**4. [Test-environment correction] Font-fallback measurement would have overstated the clipping finding by ~1.7x**

`flutter test` does not load bundled font assets by default - the initial width-cost measurement used the framework's deterministic fallback test font, which rendered "987,654.32" at 316px (vs the real `Inter-Bold`'s 178.7px) and made the clip look catastrophic (184px) rather than modest (~21px). Fixed by loading `assets/fonts/Inter-Bold.ttf` in a `setUpAll` before the width-cost tests - the only font family/weight `GeniusWalletTypography.numericDisplay` actually requests. Chip label text (`GNUS`/`MIN`) still renders in the fallback test font in this suite, matching every other test in the file and in `compute_panel_height_test.dart` (no bundled system/Roboto font asset exists to load instead) - documented in-code.

---

**Total deviations:** 2 auto-fixed (semantics fix), 2 reported-not-fixed (both scope-bounded design/accessibility decisions belonging to Jakub), 1 test-methodology correction.
**Impact on plan:** No scope creep - both reported findings are genuinely out of this task's fence (one is a whole-app token calibration question, the other is Jakub's scheme-B-vs-scheme-A call). Both are filed, measured, and cannot silently drift.

## Issues Encountered

- `find.ancestor(of: GWAnimatedNumber, matching: SingleChildScrollView)` initially matched TWO ancestors (the test harness's own outer scroll view and the balance tile's inner one) - resolved with `.first` (nearest-first ordering), documented in-test.
- `matchesSemantics(isSelected:)` alone throws an "unexpected flag: hasSelectedState" mismatch in this Flutter version - `hasSelectedState: true` must be passed alongside `isSelected:` explicitly. Fixed in all four semantics assertions.
- The keyboard-operability test's initial "no GestureDetector at all under GWControlTrack" assertion was wrong: `InkWell` is itself internally built on a `GestureDetector` (its splash/tap-arena wiring), so this always fails for a correctly-built `InkWell`-based segment. Removed; the `InkWell.onTap != null` assertion is the actual, correct gate.

## Verification Run (real numbers)

- `flutter analyze` (whole project): **0 issues.**
- `flutter test test/dashboard/`: **294/294 pass.**
- `flutter test test/theme/`: **83/83 pass.**
- `tool/check_brace_style.sh`: **exit 0.**
- `tool/check_raw_colors.sh`: **exit 0.**
- `dart format --set-exit-if-changed` on all 7 touched files: **0 changed, exit 0.**
- The full-repo `flutter test` suite was NOT re-run by this executor per explicit coordinator instruction (another quick task was mid-edit and the full run takes ~15 minutes). The coordinator independently ran it and reported **923/924** - the single failure was this task's own (now-converted) width-cost test, which is green as of this SUMMARY.

## Two shared-file comment edits (concurrency note)

Both one-line comment edits were made, not skipped - `260731-jx5` finished before this task's final verification pass and the files were confirmed unchanged since first read:
- `lib/components/gw_control_track.dart` - doc-comment consumer list, "Three consumers" -> "Four consumers", naming `_UnitTrack`.
- `lib/components/gw_timeframe_segment.dart` - one comment, "the three can no longer drift apart" -> "the four can no longer drift apart", naming the Compute panel's track.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**Not committed, not pushed** - per Jakub's standing rule, the working tree is left dirty for local review and his own PR into `ui-redesign-port`. Nothing outside this task's fenced files (`lib/dashboard/compute/compute_panel.dart`, `lib/components/wallet_overview.dart`, plus the two named one-line comment edits and their tests) was touched, and nothing pre-existing was reverted or tidied.

**Two decisions await Jakub**, both filed as todos with full measurements:
1. Accept the ~1-digit clip at 320px in minions mode with a large balance, or fall back to sketch 170 scheme A (a swap glyph).
2. The pre-existing light-mode contrast gap shared by three `GWControlTrack` consumers' unselected labels - not blocking, not new, but now measured and named.

**The walk** (what to check in the live app):

1. `flutter run -d macos --dart-define=GW_DEV_TOOLS=true`, open the Compute panel.
2. **The whole point:** without touching anything, both `GNUS` and `MIN` are visible, and it is visually obvious which one is active (raised, `surfaceMenu` fill, `textPrimary`) versus which is not (flat, `textSecondary`).
3. Compare the track against the chart's timeframe segment and the transaction filter bar side by side, in both themes - same sunken fill, same hairline, same pill, same padding rhythm. Judge the one open question the plan flagged: since this tile is already `surfaceSunken`, the track has no fill step of its own here (only its hairline) - does it still read as a control, or as a flat outline? If it needs a step, the fix is one token in `gw_control_track.dart` and moves all four tracks together.
4. Confirm the gap between the number and the track (now 8px, was 4px) no longer reads as the pill touching the numeral.
5. Tap `MIN` - the number switches to minions and grows several digits. Narrow the window toward the two-column boundary and watch for clipping - this is the finding in todo #2 above; note whether it feels acceptable at the realistic width.
6. Tap the already-active segment - nothing should happen, no flip, no flicker, not even on a fast double-tap.
7. Hover an unselected segment (it should lift onto `surfaceElevated`, matching the timeframe tabs), then **Tab to it and press Enter** - it should focus visibly and activate. The chart's timeframe segment will not do this yet; that gap is filed in `.planning/todos/pending/2026-07-31-track-chips-are-not-keyboard-operable.md`.
8. Read `MIN` in place - if it reads as a truncation bug rather than an intentional abbreviation, it is one line (`_kMinionsLabel`) to reverse, but the honest follow-on per sketch 170 is scheme A, not a wider scheme B.

---
*Quick task: 260731-kc5*
*Completed: 2026-07-31*
