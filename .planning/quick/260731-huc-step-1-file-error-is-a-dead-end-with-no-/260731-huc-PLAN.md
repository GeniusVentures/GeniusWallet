---
phase: 260731-huc
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/submit_job/view/widgets/job_steps.dart
  - test/submit_job/job_flow_test.dart
  - lib/submit_job/cubit/submit_job_cubit.dart      # TASK 3 ONLY - CONFLICT, owned by 260731-hrn
  - test/submit_job/submit_job_errors_test.dart     # TASK 3 ONLY - the cubit's own test
autonomous: false
requirements: [QUICK-260731-HUC]

must_haves:
  truths:
    - "With fileError set and the picker closed, step 1 renders a Choose a JSON file control whose onPressed is non-null and which reaches SubmitJobCubit.openFilePicker."
    - "A rejection that arrives while a file is already held shows BOTH the held file name and the warning, so the body stops contradicting the enabled Continue in the footer."
    - "RESTING and FILE-HELD-no-error render exactly what they render today - the restructure adds an escape, it does not redecorate working states."
    - "The doc comment claiming a rejected file is recoverable is true of the code beneath it."
    - "Cancelling the OS picker leaves step 1 in the state it was in, with no warning painted (Task 3, gated)."
  artifacts:
    - lib/submit_job/view/widgets/job_steps.dart
    - test/submit_job/job_flow_test.dart
  key_links:
    - "JobChooseFileBody.onChooseFile <- JobFlowBody._buildSteps (job_steps.dart:98) <- context.read<SubmitJobCubit>().openFilePicker - the single wire that makes the new button an escape rather than decoration."
    - "SubmitJobCubit lifetime = WalletsOverviewState (wallet_overview.dart:60) - fileError outlives the drawer, which is why an in-body escape is the ONLY escape."
---

<objective>
Step 1 of the job flow is a trap. `JobChooseFileBody.build` early-returns a bare
`GWWarningNote` when `state.fileError` is set (`job_steps.dart:166-176`), and the
only branch that ever renders `Choose a JSON file` sits below it, unreachable.
The cubit outlives the drawer (`wallet_overview.dart:60`), so closing and
reopening does not clear it. Only an app restart does. Jakub hit this live today.

Purpose: give the FILE REJECTED rendering a way out, and stop recording a
cancelled picker as a failure.
Output: a restructured `JobChooseFileBody`, three regression tests that fail
against today's code, and a gated cubit change.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@lib/submit_job/view/widgets/job_steps.dart
@lib/submit_job/cubit/submit_job_state.dart
@test/submit_job/job_flow_test.dart
</context>

<constraints>

**DO NOT COMMIT. DO NOT PUSH.** This overrides the GSD atomic-commit default.
Leave every change uncommitted in the working tree on branch
`redesign/jakub-260730`. Jakub reviews locally and opens the PR himself into
`ui-redesign-port`. This is his standing rule, not a per-task preference.

**No em dashes** in any code, comment, test name or string. Write " - ".

**Parallel-task file ownership.** Two other quick tasks are live.
- `260731-hrn` owns `lib/dev/*`, `lib/submit_job/cubit/submit_job_cubit.dart`,
  `lib/bloc/app_bloc.dart`, `lib/components/wallet_overview.dart`.
- `260731-hsb` owns `lib/components/coins/view/coins_screen.dart`,
  `lib/dashboard/chart/*`, `lib/navigation/router.dart`.
- **This task owns `lib/submit_job/view/widgets/job_steps.dart` and its tests.**

Tasks 1 and 2 touch only owned files. Task 3 touches `submit_job_cubit.dart`,
which belongs to `260731-hrn` - it is gated behind the Task 2b checkpoint and
must not be started before that checkpoint returns.

**Line numbers have already drifted.** Quick task `260731-elz` edited
`submit_job_cubit.dart` earlier today. The numbers in the bug report are stale.
Verified current positions: the cancel branch is at **:216**, the
`FormatException` branch at **:219-222**, the size cap at **:124-129**, the
`isFilePickerOpen: true` emit at **:98**, `resetFileError()` at **:102**,
`resetCostError()` at **:108**. Re-verify before editing - `260731-hrn` may
have moved them again.

</constraints>

<findings>

Four things were established by reading the source, and they change the shape of
the fix. Do not re-derive them.

**1. The sketch contains the dead end. The implementation did not drop anything.**
`166-compute-missing-screens/screens.html:393-396` renders FILE REJECTED as
`drawer(0, [wrap('warn', ...warnNote...)], wrap('button', '<button disabled>Continue</button>'))`
- warning note in the body, disabled `Continue` in the footer, and no choose
control anywhere. RESTING at `:387-389` is the only one of the three renderings
that draws a `Choose file` button. The implementation reproduced the design
faithfully; the design is what is wrong. The sketch's own closing note ("Nothing
new here at all... the only judgement left is `GWWarningNote` vs `_InlineError`")
shows the omission was never noticed, because the review question was about
which error treatment to use, not about what the user does next.

So Task 1 is a **deliberate, recorded deviation from sketch 166**, not a
correction of a porting slip. Say so in the code comment.

**2. `job_steps.dart` is the ONLY consumer of `fileError` in `lib/`.**
`grep -rn "fileError" lib/` outside the cubit returns exactly three hits, all in
this file: the branch condition (:166), the render (:175), and a comment (:644).
The state field's own doc comment still claims it is "Surfaced as a toast titled
for the picker" (`submit_job_state.dart:52-55`) - that has not been true since
the toast host was superseded. Two consequences: the blast radius of Task 3 is
one string plus tests, and there is no second surface that would still offer an
escape once this one fails to.

**3. The footer already disagrees with the body.** `JobFlowFooter` case 0
(`job_steps.dart:646-654`) gates `Continue` on `state.uploadedJson`, deliberately
not on `fileError`, so that a fresh rejection cannot un-continue an
already-accepted file. Correct - but it means that today, when a rejection lands
on top of a held file, the body shows only a warning while the footer shows an
enabled `Continue`. The body has erased the file the footer is still pointing at.
Fixing the ordering (finding 4) resolves this too.

**4. The existing test proves the point about weak tests.**
`job_flow_test.dart:302-315` ("a picker failure renders inline, not as a toast")
asserts the warning renders and no `SnackBar` appears. It passes against the
broken code. That test is exactly the shape the bug report warns about, and it is
already in the tree.

</findings>

<decisions>

**D-01. The escape is `GWWarningNote` + the existing `Choose a JSON file`
`GWButton`.** No new control, no new copy, no new component. Both the RESTING
branch (:225-229) and the file-held branch (:199-203) already build that exact
button with `GWButtonVariant.gradientOutline` and that exact label. The label
stays byte-identical, because three existing tests and the drawer provider test
find the button by that string.

**D-02. `fileError` stops being an exclusive branch and becomes an additive
element.** Restructure the tail of `build` from a chain of early returns into one
`Column` whose leading element is state-chosen and whose warning is conditional.
This is what makes the FILE-HELD-plus-error case renderable at all, and it is why
the fix is a restructure rather than adding a button to one branch.

**D-03. A rejection while a file is held shows the held file AND the warning.**
(The "also consider" question, answered yes.) Reason: finding 3. The user still
has a valid file; the new one was refused; the footer is right that they can
continue. Erasing the file name to show the warning makes the body lie about what
the user has. Order: status dot, file grid, warning, button - the record of what
they hold, then what just failed, then what they can do.

**D-04. `isFilePickerOpen` keeps its early return, unchanged.** It is a genuinely
exclusive state - there is no useful action to offer while the OS dialog owns the
screen, and offering a second `Choose a JSON file` button behind a modal OS dialog
would be a second trap. The spinner branch is copied across verbatim.

**D-05. Cancelling the picker sets no error at all.** (Fix 2.) On
`result == null || result.files.isEmpty`, emit nothing beyond the `finally`
block's `isFilePickerOpen: false`. The state keeps whatever it held. Reason: a
user dismissing an OS dialog has made a deliberate choice, not suffered a
failure. There is nothing to fix, nothing to retry, and nothing was lost - the
warning register asks the user to react to their own decision. Note the
interaction the bug report flags: `openFilePicker` already calls
`resetFileError()` on entry (:102), so cancel after a genuine rejection lands the
user back in a clean RESTING state, which is the right outcome - they reopened
the picker precisely to get past that rejection, and backing out of it is not a
reason to re-assert it.

**D-05 does not substitute for D-01/D-02.** The size cap (:124-129) and the
`FormatException` branch (:219-222) still set `fileError`, and both are genuine
rejections that must render. D-05 makes the trap rarer; only D-01/D-02 make it
survivable. Both are required.

**D-06. Fold the two error resets into the picker-open emit.** (The second "also
consider" question.) `emit(isFilePickerOpen: true)` at :98, then
`resetFileError()` at :102 and `resetCostError()` at :108 inside the `try`, is
three emits and three rebuilds where one would do, and it opens a window in which
the state carries an open picker AND a stale error. Be honest about the value:
that window is **not user-visible**, today or after Task 1, because D-04 keeps
`isFilePickerOpen` outranking `fileError` in the build chain. This is a tidy, not
a fix. It is scoped as an optional sub-step of Task 3 and may be dropped without
affecting anything else in this plan.

**D-07. `submit_job_state.dart:52-55`'s "Surfaced as a toast" doc is stale**
(finding 2) but is NOT corrected here. That file is adjacent to `260731-hrn`'s
cubit work and the correction is cosmetic. Recorded so the next reader does not
trust it.

</decisions>

<tasks>

<task type="auto">
  <name>Task 1: Give the FILE REJECTED rendering a way out</name>
  <files>lib/submit_job/view/widgets/job_steps.dart</files>
  <action>
Restructure `JobChooseFileBody.build` (currently :145-232) per D-02.

Keep the `state.isFilePickerOpen` early return exactly as it stands (D-04) -
copy the `Row` with `GWSpinner(size: 20)` and the `Preparing your job` label
across without touching a token.

Replace everything after it - the `fileError` early return, the
`uploadedFileName` early return, and the trailing RESTING return - with a single
`Column` (`crossAxisAlignment: CrossAxisAlignment.start`,
`mainAxisSize: MainAxisSize.min`) built from a local `hasFile` derived from
`state.uploadedFileName.isNotEmpty`, with three conditional spreads in this
order:

1. When `hasFile`: the existing `GWStatusDot(color: gw.statusSuccess, label:
   'File selected')`, a `SizedBox(height: GeniusWalletConsts.space6)`, the
   existing `GWDetailGrid` holding one `_DetailRow(label: 'File', value:
   state.uploadedFileName, gw: gw)`, and another `space6`.
   Else when `state.fileError` is empty: the existing resting caption `Text`
   ("Upload a JSON file describing the job you want to run.") at
   `GeniusWalletTypography.bodySm` in `gw.textSecondary`, plus a `space6`.
   The `else if` is load-bearing: the file-held branch does not render the
   caption today and must not start.
2. When `state.fileError` is not empty: `GWWarningNote(state.fileError)` plus a
   `space6`.
3. Unconditionally: the `GWButton` with `variant: GWButtonVariant.gradientOutline`,
   `label: 'Choose a JSON file'`, `onPressed: onChooseFile`. One button, one call
   site, reached by every non-picker-open state.

Verify by inspection that all four reachable renderings come out as intended
before running anything: RESTING = caption + button (byte-identical to today);
FILE REJECTED with no file = warning + button (sketch 166's body plus the
button it omitted); FILE HELD with no error = dot + grid + button
(byte-identical to today); FILE HELD with a rejection = dot + grid + warning +
button (D-03, new and previously unrenderable).

Then repair the comments, which currently assert the opposite of what the code
does:
- The block comment at :166-176 justifies `GWWarningNote` on the grounds that
  "a rejected file is recoverable (pick another one, nothing is spent)". Keep
  that justification - it is now true - and move it to sit with the conditional
  warning. Add, in your own words, that the control which makes it true is the
  shared button below, and that this is a recorded deviation from sketch 166
  (finding 1): the sketch's FILE REJECTED rendering draws the note and a
  disabled `Continue` and no choose control, so the escape is added here on
  purpose rather than restored.
- The class doc at :120-134 names the sketch's three renderings. Extend it to
  say that the tail of `build` is now one column rather than three exclusive
  branches, and why (D-03: a rejection landing on a held file must not erase the
  file, because `JobFlowFooter` case 0 keeps `Continue` enabled off
  `uploadedJson` and the two halves would otherwise disagree about the same
  moment).
- Leave the comment at :640-645 in `JobFlowFooter` alone. It is correct.

Change nothing else in this file. No new imports are needed - `GWStatusDot`,
`GWDetailGrid`, `GWWarningNote`, `GWButton` and `_DetailRow` are all already in
scope and all keep their existing call shapes.
  </action>
  <verify>
    <automated>flutter analyze lib/submit_job/view/widgets/job_steps.dart && flutter test test/submit_job/job_flow_test.dart</automated>
  </verify>
  <done>
`flutter analyze` on the file is clean. All four pre-existing `JobChooseFileBody`
tests (`job_flow_test.dart:284-365`) still pass unmodified, including the two
that assert the byte-identical RESTING and FILE-HELD renderings. The tail of
`build` contains exactly one `GWButton`.
  </done>
</task>

<task type="auto">
  <name>Task 2: Three regression tests aimed at the trap itself, not at the warning</name>
  <files>test/submit_job/job_flow_test.dart</files>
  <action>
Add three tests. The discriminating assertion in each is that a control exists
AND fires - finding 4 shows that asserting the warning renders is not enough,
because that test already exists and already passes against the broken code.

Before writing the implementation of Task 1's counterpart assertions, confirm
these fail: stash Task 1's change (or run them against `git stash`) and check
that tests A and B fail on a missing `Choose a JSON file`, and C fails on
`pickCalls`. A test that passes both before and after is not a regression test
for this defect.

**A - into the existing `JobChooseFileBody` group** (after the ":302 renders
inline" test): a rejected file offers a working way to choose another. Pump
`_host(JobChooseFileBody(state: const SubmitJobState(fileError: 'The Selected
File is not valid json'), onChooseFile: () => tapped = true))` with a captured
`var tapped = false`. Assert the warning text renders, that
`find.text('Choose a JSON file')` finds one widget, that the resolved
`GWButton`'s `onPressed` is non-null (a disabled escape is not an escape), then
tap it and assert `tapped` is true.

**B - same group**: a rejection arriving on top of a held file keeps the file
visible (D-03). Seed `SubmitJobState(uploadedFileName: 'job-payload.json',
fileError: 'File is too large (max 5 MB).')` with an `onChooseFile` capture.
Assert all four of: the `File selected` label, the file name, the warning text,
and a tappable `Choose a JSON file` that fires the callback. Name the test after
what it protects - the body and the footer agreeing about a state where the user
still holds a valid file.

**C - into the existing `JobDrawer` group** (which already installs
`_FakeFilePickerPlatform` in its `setUp`): prove the escape reaches the real
cubit through the real drawer, not just a callback in a widget test. Build the
harness with `_build()`, and replace the group's default `resultBuilder` with a
counting one - a closure over a local `var pickCalls = 0` that increments and
returns null, so no change to `_FakeFilePickerPlatform` itself is needed. Pump
`_drawerHost(harness.cubit)`, tap `open`, settle. Seed the error directly with
`harness.cubit.setFileError('The Selected File is not valid json')` - a public
cubit method - rather than by driving a rejection, so this test is INDEPENDENT
of whether Task 3 lands. Settle, assert the warning renders and the button
renders, tap the button, settle, and assert `pickCalls` is 1 and
`tester.takeException()` is null. That is the trap and its exit, end to end.

Do not modify the existing `:302` test - it still correctly guards the
inline-not-toast decision. Do not modify
`job_flow_test.dart:766`'s `'No file selected.'` assertion here; it belongs to
Task 3.
  </action>
  <verify>
    <automated>flutter test test/submit_job/job_flow_test.dart</automated>
  </verify>
  <done>
Three new tests pass against Task 1's code and were each observed to fail
against the pre-Task-1 code. The full `job_flow_test.dart` file is green with no
pre-existing test modified.
  </done>
</task>

<task type="checkpoint:decision" gate="blocking">
  <name>Task 2b: CONFLICT gate - confirm before writing to another task's file</name>
  <files>none - this task writes nothing</files>
  <action>
Stop. Present the decision below to the orchestrator and wait for a selection.
Do not edit `lib/submit_job/cubit/submit_job_cubit.dart` before this returns -
that file belongs to quick task `260731-hrn`, which is running right now.
Record the selection verbatim in the SUMMARY; Task 3 branches on it.
  </action>
  <decision>Whether to apply the cancel-is-not-an-error fix (D-05/D-06) now, given that it lands in a file owned by parallel quick task 260731-hrn.</decision>
  <context>
Fix 2 changes `lib/submit_job/cubit/submit_job_cubit.dart:216` (and, optionally,
:98/:102/:108). That file is owned by `260731-hrn` for the duration of this
session and was already edited today by `260731-elz`. Editing it from this task
risks a silent overwrite of concurrent work.

Blast radius is small and known: `job_steps.dart` is the only consumer of
`fileError` in `lib/` (finding 2), so the change is one branch plus two test
assertions. Tasks 1 and 2 are already complete and already make the trap
survivable on their own - this fix makes it rarer, it does not make it
recoverable. Nothing downstream is blocked by deferring it.
  </context>
  <options>
    <option id="apply-now">
      <name>Apply Task 3 in this task</name>
      <pros>Both halves of the defect close together and ship in one review. The change is 1 line plus 2 test assertions.</pros>
      <cons>Touches another task's file. If 260731-hrn is mid-edit, one of the two edits loses.</cons>
    </option>
    <option id="hand-off">
      <name>Hand the cubit change to 260731-hrn</name>
      <pros>No cross-task write. That task already has the file open.</pros>
      <cons>The two halves land in separate reviews; the handoff can be dropped.</cons>
    </option>
    <option id="defer">
      <name>Ship Tasks 1 and 2 only, file D-05 as a todo</name>
      <pros>Zero conflict risk. The trap is already survivable.</pros>
      <cons>Cancelling the picker keeps painting a warning at a user who did nothing wrong.</cons>
    </option>
  </options>
  <resume-signal>Select: apply-now, hand-off, or defer</resume-signal>
</task>

<task type="auto">
  <name>Task 3: Cancelling the picker stops being an error (GATED - do not start before the checkpoint resolves)</name>
  <files>lib/submit_job/cubit/submit_job_cubit.dart, test/submit_job/submit_job_errors_test.dart, test/submit_job/job_flow_test.dart</files>
  <action>
**Run this task ONLY if the checkpoint returned `apply-now`.** On `hand-off`,
write the change up in the SUMMARY as a handoff note for `260731-hrn` and stop.
On `defer`, write it to `.planning/todos/pending/` and stop. In both of those
cases this task produces no code.

If applying: first re-read `submit_job_cubit.dart` and re-locate the cancel
branch. The bug report's line numbers are stale and `260731-hrn` may have moved
them again since this plan was written.

**3a (required).** In `openFilePicker`, the `else` arm that currently calls
`setFileError('No file selected.')` (:216 as of writing) becomes a no-op arm.
Cancelling emits nothing - the `finally` block's `isFilePickerOpen: false` is
the whole state transition (D-05). Leave a comment saying why: a dismissed OS
dialog is a decision, not a failure, and `resetFileError()` on entry means
cancelling after a rejection correctly lands the user back in RESTING. Name the
two paths that still DO set `fileError` - the size cap and the `FormatException`
branch - so nobody later reads this as "file rejection no longer surfaces".

Both other `setFileError` call sites stay exactly as they are.

**3b (optional, droppable).** Fold `fileError: ''` and `costError: ''` into the
same `emit` that sets `isFilePickerOpen: true`, and delete the now-redundant
`resetFileError()` / `resetCostError()` calls at the top of the `try`. Three
emits become one. Per D-06 this is a tidy with no user-visible effect - if the
file has drifted under you, or the surrounding lines look freshly edited, skip
3b and keep 3a. `resetFileError` and `resetCostError` themselves stay (they have
other callers and are part of the cubit's public surface).

**3c. Update the two assertions that encode the old behaviour.**
- `test/submit_job/submit_job_errors_test.dart:242` - the test named
  "no file selected -> fileError only". Rename it for what now happens
  (cancelling the picker leaves no error) and invert the assertion:
  `fileError` is empty, alongside the existing empty `costError` / `submitError`
  checks. Add an assertion that a previously held `uploadedFileName` survives a
  cancel, since that is the substantive half of D-05 and nothing else covers it.
- `test/submit_job/job_flow_test.dart:766` - the drawer provider-hazard test
  ends by asserting `fileError` equals the cancel string. That test exists to
  prove both subtrees resolve the same cubit, not to pin the cancel copy.
  Re-point the final assertion at something that still proves the cubit was
  reached: assert `fileError` is empty and no exception was thrown, and adjust
  the surrounding comment.

Do not touch Task 2's test C - it seeds the error via `setFileError` precisely so
this task cannot invalidate it.
  </action>
  <verify>
    <automated>flutter analyze && flutter test test/submit_job/</automated>
  </verify>
  <done>
Either: the checkpoint returned `apply-now`, cancelling the picker sets no
error, and every test under `test/submit_job/` passes. Or: the checkpoint
returned `hand-off` / `defer`, no file was modified by this task, and the
change is recorded in the SUMMARY or in `.planning/todos/pending/`.
  </done>
</task>

</tasks>

<verification>

Run all four gates from the repo root after the last executed task:

```
flutter analyze
flutter test
tool/check_brace_style.sh
tool/check_raw_colors.sh
```

Expected: analyze 0/0 (root and `genius_api`); tests 852 passing against the 849
baseline (+3 from Task 2; Task 3 rewrites assertions without changing the count);
both gate scripts 0/PASS.

If the test total is not 849 + 3, find out why before reporting. Two other quick
tasks are adding tests to the same tree, and a number that only roughly matches
is how a real regression gets waved through.

**Human walk (Jakub, on the running app).** The trap is reproducible in one
click, which is what makes it walkable without dev tooling:
1. Open the compute panel job drawer, step 1.
2. Tap `Choose a JSON file`, press Escape in the OS dialog.
   - Before Task 3: the amber note appears AND a working `Choose a JSON file`
     button sits under it. Tap it - the dialog reopens. That alone is the fix.
   - After Task 3: nothing happens at all. Step 1 sits exactly as it was.
3. Pick a genuinely invalid file (any `.json` containing non-JSON text). The
   warning appears with the button beneath it. Tap the button, pick a valid
   file, and confirm step 1 advances to Cost.
4. With a valid file already accepted, tap back to step 1, tap `Choose a JSON
   file`, pick the invalid file again. Confirm the held file name stays visible
   above the warning and `Continue` in the footer is still enabled (D-03).

</verification>

<success_criteria>

- With `fileError` set and the picker closed, step 1 renders an enabled
  `Choose a JSON file` control that reaches `SubmitJobCubit.openFilePicker`.
- A rejection arriving on a held file shows the file name, the warning and the
  button together.
- RESTING and FILE-HELD-no-error render what they rendered before this plan.
- Three new tests, each observed to fail against pre-Task-1 code.
- The `job_steps.dart` comment about recoverability is true of the code below it,
  and the deviation from sketch 166 is recorded there.
- All four gates pass; test total is 852.
- **Nothing is committed and nothing is pushed.** The working tree carries the
  change for Jakub's review.

</success_criteria>

<output>
Write `.planning/quick/260731-huc-step-1-file-error-is-a-dead-end-with-no-/260731-huc-SUMMARY.md`.

Record: which checkpoint option was chosen and what Task 3 actually did; whether
3b was applied or dropped and why; the observed failure output from running
Task 2's tests against pre-Task-1 code (the evidence that they are regression
tests); the final test count; and, as an outstanding item, that sketch 166's
FILE REJECTED rendering still shows the dead end and should be corrected or
annotated the next time that sketch is touched (finding 1), along with the stale
"Surfaced as a toast" doc on `submit_job_state.dart:52-55` (D-07).
</output>
