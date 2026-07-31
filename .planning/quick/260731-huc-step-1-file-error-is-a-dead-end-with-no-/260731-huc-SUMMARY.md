---
phase: 260731-huc
plan: 01
subsystem: submit_job
tags: [job-flow, submit-job, bugfix, ui-deviation]
dependency-graph:
  requires: []
  provides:
    - "JobChooseFileBody escape from FILE REJECTED"
    - "cancel-is-not-an-error fix in SubmitJobCubit.openFilePicker"
  affects:
    - lib/submit_job/view/widgets/job_steps.dart
    - lib/submit_job/cubit/submit_job_cubit.dart
tech-stack:
  added: []
  patterns:
    - "additive Column with conditional spreads instead of exclusive early returns, so two once-mutually-exclusive states (file held + error) can render together"
key-files:
  created: []
  modified:
    - lib/submit_job/view/widgets/job_steps.dart
    - lib/submit_job/cubit/submit_job_cubit.dart
    - test/submit_job/job_flow_test.dart
    - test/submit_job/submit_job_errors_test.dart
decisions:
  - "Checkpoint 2b resolved apply-now (per orchestrator instruction: 260731-hrn's executor had not started, edits were serialised) - Task 3 executed in full."
  - "D-06 (fold the three openFilePicker emits into one) dropped, not applied. The cubit file is under active concurrent edit by 260731-hrn/elz today; 3b was explicitly optional/droppable and the plan itself says to skip it when the surrounding lines look freshly edited, which they do."
metrics:
  duration: "~40 min"
  completed: 2026-07-31
status: complete
---

# Phase 260731-huc Plan 01: Give step 1's FILE REJECTED rendering a way out Summary

Restructured `JobChooseFileBody` from three exclusive early-return renderings into one additive
`Column`, so a rejected file always renders a working `Choose a JSON file` button next to its
warning - fixing a real dead end Jakub was trapped in live (only an app restart cleared it, because
`fileError` outlives the drawer). Also made cancelling the OS file picker set no error at all,
instead of painting a warning at a user who made a deliberate, ungerroneous choice.

## What Was Built

**Task 1 - the escape (`job_steps.dart`).** `JobChooseFileBody.build`'s tail (everything after the
`isFilePickerOpen` early return) is now one `Column` with two conditional leading elements (file-held
dot+grid, or the resting caption - mutually exclusive via `else if`) followed by a conditional warning
and, unconditionally, the shared `Choose a JSON file` `GWButton`. Four reachable renderings verified
by inspection and by test:
- RESTING = caption + button (byte-identical to before).
- FILE REJECTED, no file held = warning + button (sketch 166's body, plus the button it omitted).
- FILE HELD, no error = dot + grid + button (byte-identical to before).
- FILE HELD + a fresh rejection = dot + grid + warning + button (new, previously unrenderable - this
  is the case where the body used to erase the file the footer's enabled `Continue` was still
  pointing at).

Comments repaired: the block comment justifying `GWWarningNote` on "a rejected file is recoverable"
now states plainly why that is true (the shared button below it) and records that this is a
deliberate DEVIATION from sketch 166, not a restoration of something the port dropped - the sketch's
own FILE REJECTED drawing has no choose control at all, only a warning and a disabled `Continue`. The
class doc was extended to say why the tail is one column rather than three branches.

**Task 2 - three regression tests (`job_flow_test.dart`).** Each asserts a control exists AND fires,
not just that a warning renders (the existing `:302` test already asserted that and already passed
against the broken code - it proves nothing about the trap):
- "a rejected file offers a working way to choose another" - warning renders, button renders,
  `onPressed` is non-null, tapping it fires the callback.
- "a rejection arriving on top of a held file keeps the file visible" - the `File selected` dot, the
  file name, the warning, and a working button all render together (D-03).
- "the choose-another escape reaches the real cubit through the real drawer" - drives the real
  `JobDrawer`/`SubmitJobCubit` (not a widget-test callback), seeds `fileError` via the cubit's public
  `setFileError`, taps the button, and asserts the picker's `pickFiles` was actually invoked
  (`pickCalls == 1`) with no exception.

**Checkpoint 2b - resolved `apply-now`** per the orchestrator's explicit instruction: quick task
`260731-hrn`'s planner had not yet returned, so its executor had not started and edits to
`submit_job_cubit.dart` were serialised behind this task finishing. Recorded verbatim as instructed.

**Task 3a (required) - cancel is not an error (`submit_job_cubit.dart`).** In `openFilePicker`, the
`else` arm that used to call `setFileError('No file selected.')` on a cancelled/empty pick is now a
no-op with a comment explaining why (D-05): a dismissed OS dialog is a decision, not a failure - the
`finally` block's `isFilePickerOpen: false` is the whole state transition, and because
`resetFileError()` already ran on entry, cancelling after a genuine rejection correctly lands the user
back in a clean RESTING state. The size-cap and `FormatException` branches are untouched and still
set `fileError` - named in the comment so this isn't misread later as "file rejection no longer
surfaces."

**Task 3b (optional) - DROPPED.** `submit_job_cubit.dart` is owned by `260731-hrn` and was already
edited today by `260731-elz` (visible in the file's own `2026-07-31`-dated comments around
`_devJobScenario`, `1a`/`1c` fixes). The plan explicitly says to skip 3b when the surrounding lines
look freshly edited, and they do. 3b was purely a tidy (three emits into one, with no user-visible
effect per D-06) - skipping it costs nothing and keeps this task's footprint in a contested file to
the single required line.

**Task 3c - updated the two assertions pinned to the old cancel behavior.**
- `submit_job_errors_test.dart` - renamed the "no file selected -> fileError only" test to describe
  what now happens, inverted the assertion to `fileError` empty, and added a same-cubit two-pick
  sequence proving a previously held file survives a cancel (the substantive half of D-05, not
  covered anywhere else).
- `job_flow_test.dart`'s drawer provider-hazard test - re-pointed its final assertion from
  `fileError == 'No file selected.'` to `fileError` empty, with a comment explaining the test still
  proves the tap reached the real cubit (no exception thrown), it just no longer pins cancel copy
  that D-05 deleted.

## Verification Evidence

**Regression tests observed FAILING against pre-Task-1 code** (this is the load-bearing evidence -
a test that was already green proves nothing here, and `job_flow_test.dart:302-315` is exactly that
trap):
- "a rejected file offers a working way to choose another": failed with
  `Expected: exactly one matching candidate / Actual: Found 0 widgets with text "Choose a JSON file"`
  - the button genuinely does not exist in that state today.
- "a rejection arriving on top of a held file keeps the file visible": failed with
  `Expected: exactly one matching candidate / Actual: Found 0 widgets with text "File selected"` -
  the body genuinely erases the held file today.
- "the choose-another escape reaches the real cubit through the real drawer": failed the same way
  (`Choose a JSON file` not found) end to end through the real cubit and drawer.

**After Task 1's fix, all three pass**, along with every pre-existing test in the file - full
`job_flow_test.dart` run: 28/28 passing (was 25 before this plan's two new tests plus the one added
to the `JobDrawer` group).

**`test/submit_job/` full run:** 64/64 passing.

**Full four gates, run after all tasks:**
- `flutter analyze`: 0 issues.
- `flutter test`: **852/852 passing** (849 baseline + 3 new), confirmed by two independent full runs
  after the parallel quick tasks' concurrent edits settled. Two earlier runs taken mid-session showed
  transient failures (836/3 failed, then 847/1 failed) - both traced to `lib/tokens/token_info_screen.dart`
  and its tests, which belong to parallel quick task `260731-hsb` and were mid-edit (a
  not-yet-created `token_info_args.dart`) at those moments; not this task's files, not a regression
  introduced here. Both final full runs (after hsb's work stabilized) landed on exactly 852/852 with
  zero failures anywhere, matching the plan's expected total precisely.
- `tool/check_brace_style.sh`: PASS (exit 0).
- `tool/check_raw_colors.sh`: PASS (exit 0).

## Outstanding Items (not fixed here, recorded per plan's output spec)

- **Sketch 166's FILE REJECTED rendering still shows the dead end.** `166-compute-missing-screens/screens.html:393-396`
  draws the warning note and a disabled `Continue` with no choose control - the same shape this plan
  fixed in code. The sketch itself was never corrected or annotated. Next time sketch 166 is touched,
  it should either gain the same escape or an explicit note that the shipped implementation
  deliberately deviates here.
- **`submit_job_state.dart:52-55`'s `fileError` doc comment is stale** (D-07): it still says "Surfaced
  as a toast titled for the picker," which has not been true since the toast host was superseded -
  `job_steps.dart` is the only consumer of `fileError` in `lib/` and it renders inline. Not corrected
  here because that file sits adjacent to `260731-hrn`'s concurrent cubit work and the fix is purely
  cosmetic.

## Human Walk (for Jakub)

1. Open the compute panel job drawer, step 1. Tap `Choose a JSON file`, press Escape/Cancel in the
   OS dialog. Step 1 should stay exactly as it was - no warning, nothing painted. (Before this fix,
   an amber "No file selected." note used to appear; now there is nothing to react to, which is the
   point of Task 3.)
2. Pick a genuinely invalid file (any `.json` containing non-JSON text, or any non-JSON file). The
   warning note should appear WITH a working `Choose a JSON file` button beneath it - tap it, the
   dialog reopens. That is the fix for the original trap: no restart needed.
3. Pick a valid JSON file after that and confirm step 1 advances to Cost.
4. With a valid file already accepted, tap back to step 1, tap `Choose a JSON file`, pick an invalid
   file again. Confirm the held file name stays visible above the new warning, and that the footer's
   `Continue` is still enabled (D-03 - the body and footer now agree).

## Self-Check: PASSED

Files confirmed present with the described changes:
- FOUND: lib/submit_job/view/widgets/job_steps.dart (restructured `JobChooseFileBody.build`)
- FOUND: lib/submit_job/cubit/submit_job_cubit.dart (cancel arm is now a no-op)
- FOUND: test/submit_job/job_flow_test.dart (three new tests, one assertion re-pointed)
- FOUND: test/submit_job/submit_job_errors_test.dart (one test renamed and inverted)

No commits were made and nothing was pushed, per this task's standing constraint - the working tree
carries every change above, uncommitted, for Jakub's own review and PR.
