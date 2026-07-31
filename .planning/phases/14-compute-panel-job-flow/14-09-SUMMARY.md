---
phase: 14-compute-panel-job-flow
plan: 09
subsystem: ui
tags: [flutter, flutter_bloc, go_router, dashboard, compute-panel, submit-job, sentry, wcag]

requires:
  - phase: 14-compute-panel-job-flow
    provides: "compute_state.dart's pure resolver/view-model and eight-state ladder (plan 01), the retry-capable AppBloc feed flag (plan 02), the dashboard wiring on real data (plan 08)"
provides:
  - "compute_state.dart: startingUp renders no bar (only processing does), keeps its percentage as trailing, and its sub-line is the feed-health copy (Feed live/Feed stopped) rather than the SDK's raw init message"
  - "ComputeLink.retry renamed to ComputeLink.reconnect (Reconnect ›) - the dead-feed affordance already shipped in 14-08, so this is a rename, not a new member"
  - "JobInFlightBody: one spinner (Starting your job) over a quiet, static, numbered two-item list (Bridging GNUS / Starting the job), not two independent spinners"
  - "JobResultBody's bridgedNotProcessed terminal: softened label (Bridged · job not started yet), no bordered GWWarningNote box, plain instructional sentence, still the copyable bridge hash, still no balance figure, still no Try again"
  - "_ResultFooter's bridgedNotProcessed branch: a Get help button routing to /logs (SubmitLogsScreen) with the failure prefilled, alongside the existing Close button - router captured before the drawer's _close() pops"
  - "SubmitLogsScreen accepts an optional initialMessage; router.dart's /logs route threads state.extra into it"
  - "Step 1's rejected-file treatment (JobChooseFileBody) now renders the shared GWWarningNote instead of the deleted feature-local _InlineError"
affects: [dashboard, compute-panel, submit-job, logs, navigation]

tech-stack:
  added: []
  patterns:
    - "Router handle captured into a local BEFORE a drawer's _close()/pop runs, when the destination (a ShellRoute tab) and the drawer (root-navigator route) live under different navigators - the same hazard swap_settings_drawer.dart:52-63 hit once already."
    - "A renamed enum member over a new one when an affordance already ships under a different label - avoids stranding the original, unreachable member."

key-files:
  created: []
  modified:
    - lib/dashboard/compute/compute_state.dart
    - lib/components/wallet_overview.dart
    - lib/dashboard/compute/compute_panel.dart
    - lib/bloc/app_state.dart
    - lib/bloc/app_bloc.dart
    - lib/submit_job/view/widgets/job_steps.dart
    - lib/logs/submit_logs_screen.dart
    - lib/navigation/router.dart
    - test/dashboard/compute_state_test.dart
    - test/dashboard/compute_state_distinct_test.dart
    - test/dashboard/compute_panel_height_test.dart
    - test/dashboard/compute_panel_wiring_test.dart
    - test/theme/compute_contrast_test.dart
    - test/submit_job/job_flow_test.dart

key-decisions:
  - "Task 2 checkpoint (Get help's destination) was pre-decided by Jakub 2026-07-31 as feedback-prefilled - the Feedback tab (/logs) with the failure prefilled - and implemented as specified, not re-litigated."
  - "_InlineError deleted; step 1's rejected file now renders the shared GWWarningNote (8 call sites across 5 files vs. 1 for the deleted class)."
  - "No backoff added to RetryProcessingStatus on repeated failure - the catch's cancel-on-throw is already the most aggressive backoff possible; recorded in code (app_bloc.dart) and here, per Task 1f."
  - "The frozen-bar variant DECISION.md's file table asked for on the dead-feed branch was refused, with reasons recorded below - it was never built."
  - "ComputeLink.retry was renamed to ComputeLink.reconnect rather than adding a new member - the dead-feed affordance already shipped in 14-08, so a second member would strand the first."
  - "The bridgedNotProcessed close button keeps its shipped label, Close, not DECISION.md's Done - the shared closeButton also serves done and bridgeFailed, which DECISION.md says are unchanged, and Done is the wrong word on a screen reporting the job did not start."

patterns-established: []

requirements-completed: [CMP-01, CMP-04, CMP-05, CMP-07, CMP-08, CMP-10]

coverage:
  - id: D1
    description: "startingUp renders no determinate bar and no bar value, and still renders its percentage as trailing; processing is unchanged."
    requirement: "CMP-04"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_state_test.dart#viewForComputeState — the scale test"
        status: pass
      - kind: unit
        ref: "test/theme/compute_contrast_test.dart#The bar fill clears 3:1 against its track (barStates now [processing] only)"
        status: pass
    human_judgment: false
  - id: D2
    description: "startingUp's sub-line is the feed-health line for a live feed (Feed live); unavailable's sub-line is the feed-health line for a dead feed (Feed stopped) with the Reconnect › affordance."
    requirement: "CMP-07"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_panel_wiring_test.dart#the retry affordance dispatches RetryProcessingStatus, which clears the unavailable flag"
        status: pass
    human_judgment: false
  - id: D3
    description: "ComputeState still has exactly eight members and every state's pairwise-distinct tuple check still passes."
    requirement: "CMP-04"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_state_distinct_test.dart#every ComputeState.values member renders a distinct tuple"
        status: pass
    human_judgment: false
  - id: D4
    description: "Every ComputeState fits the 274px height budget, measured (not estimated), at both widths and both units."
    requirement: "CMP-04"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_panel_height_test.dart (all state/width/unit combinations)"
        status: pass
    human_judgment: false
  - id: D5
    description: "The in-flight step renders one spinner over a quiet, numbered two-item list, not two independent spinners."
    requirement: "CMP-05"
    verification:
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart#JobInFlightBody renders one spinner over a quiet numbered list naming the bridge and the job start as two separate operations"
        status: pass
    human_judgment: false
  - id: D6
    description: "The bridgedNotProcessed terminal shows the softened label, a plain sentence with no bordered box, the copyable hash, no balance figure, no Try again, and a Get help button routed to /logs with the failure prefilled."
    requirement: "CMP-08"
    verification:
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart#bridgedNotProcessed: reachable, shows its own content, and the footer offers NO retry - only Close"
        status: pass
    human_judgment: true
    rationale: "The Get help button's own tap-through to /logs (opening the Feedback tab with the prefilled message actually visible and sendable) was not exercised end to end in a widget test - the hermetic test host has no GoRouter ancestor, and the router handle is captured lazily inside onPressed specifically so building/rendering the button never requires one. A human should tap Get help in the running app and confirm the composer opens pre-filled with the hash and sends normally (human-check item 6, not run this session)."
  - id: D7
    description: "_InlineError no longer exists anywhere in lib/; step 1's rejected file renders the shared GWWarningNote."
    requirement: "CMP-10"
    verification:
      - kind: other
        ref: "grep -rn \"_InlineError\" lib/ -> exit 1, no matches"
        status: pass
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart#JobChooseFileBody a picker failure renders inline, not as a toast"
        status: pass
    human_judgment: false

duration: not tracked precisely (no reliable start timestamp captured this session; the working session spanned reading, implementing, and verifying all three tasks in one continuous pass)
completed: 2026-07-31
status: complete
---

# Phase 14 Plan 09: Compute panel copy/state cleanup and job-flow terminal softening Summary

**`startingUp` loses its determinate bar and gains feed-health copy (`Feed live`/`Feed stopped`, `Reconnect ›`), the in-flight step becomes one spinner over a quiet two-item numbered list, and the `bridgedNotProcessed` terminal is softened to a plain sentence with a `Get help` button that opens the Feedback tab pre-filled with the bridge hash - all without commits, per `AGENTS.md` and this session's explicit no-commit override.**

## Performance

- **Duration:** not tracked precisely (single continuous session)
- **Tasks:** 3/3 complete (Task 2's checkpoint was pre-decided by Jakub; implemented, not re-asked)
- **Files modified:** 14 (8 `lib/`, 6 `test/`)
- **Files created:** 0
- **Commits:** 0 (absolute constraint - see `<hard overrides>` below)

## Task completion

### Task 1: The panel stops promising a denominator it does not have, and says whether the feed is alive

Complete. In `lib/dashboard/compute/compute_state.dart`:

- `showBar` narrowed from `startingUp || processing` to `processing` alone. `startingUp`'s `barValue` stays `null` (preserving `ComputeStatusView.barValue`'s own "non-null iff `showBar`" contract); its percentage survives as `trailing`, computed directly from the clamped `initPercentage` rather than from a bar value that no longer exists.
- `startingUp`'s sub-line is now the fixed string `Feed live`; `unavailable`'s is `Feed stopped`. The `initStatusMessage` parameter and the `startingUpFallbackMessage` const are both deleted, with the one call site (`wallet_overview.dart:206`, now renumbered) updated to drop the argument.
- `ComputeLink.retry` renamed to `ComputeLink.reconnect`, label changed to `Reconnect ›`. The bloc event `RetryProcessingStatus` keeps its name - the link is what the user reads, the event is what the bloc does, and re-arming a cancelled timer genuinely is a retry regardless of what the link is called.
- `AppState.initMessage` is left in place with a `ponytail:` comment naming the ceiling (emitted, read by nothing) and the upgrade path (the network page or an un-parked stall detector).
- `_onRetryProcessingStatus` (`app_bloc.dart`) gained a comment recording the no-backoff decision with its three supporting facts (see "No-backoff decision" below).
- The frozen-bar variant DECISION.md's file table asked for was refused - not built (see "Frozen bar refusal" below).
- Doc comments on `showBar` and `showBalanceFiatSubline` were rewritten because the old text's rationale is now backwards (see "Doc-comment corrections" below).

**Deviation (necessary consequence, not a Rule 1-3 bug):** `lib/dashboard/compute/compute_panel.dart`'s `onLinkTap` doc comment named `Retry ›` literally; updated to `Reconnect ›` to match the rename. This file is not in the plan's declared `files_modified`, but leaving a doc comment referencing a deleted label would be a stale-comment bug caused directly by this task's own rename.

### Task 2: `Get help` destination - PRE-DECIDED, not re-asked

Jakub selected **feedback-prefilled** (the Feedback tab, `/logs`, with the failure prefilled) on 2026-07-31, before this execution began. Implemented exactly as specified in the plan's option text - see Task 3c below for what was built. No alternative was considered or offered.

### Task 3: One spinner over two named steps, a calm burned-tokens terminal, one treatment for a rejected file

Complete. In `lib/submit_job/view/widgets/job_steps.dart`:

- **3a.** `JobInFlightBody` rebuilt: a single `GWSpinner(size: 16)` row reading `Starting your job` (`bodySm`/`textPrimary`), followed by an indented, quiet, static list of `1 Bridging GNUS` / `2 Starting the job` (13px/`textSecondary`, `space3` between rows), followed by the unchanged closing sentence. `_InFlightRow` reworked to take an `index` and render a small numbered marker (20px circle, `borderSubtle` hairline, `labelMd` at `fontSize: 11`/`w600` - echoing `job_step_list.dart`'s `_StepBadge` recipe without promoting it, since this is only its second consumer) plus its label; the spinner moved up to `JobInFlightBody`. The two operation strings are byte-identical to before.
- **3b.** `bridgedNotProcessed`'s `GWStatusDot` label changed to `Bridged · job not started yet`. The bordered `GWWarningNote` was deleted and replaced with a plain `Text` (`bodySm`/`textSecondary`): `Your GNUS was bridged, but the job has not started. Keep the transaction below.` Everything else in the branch (the `GWCopyRow` for the bridge hash, the conditional `submitError` line, `Your balance is updating`) is unchanged.
- **3c.** `_ResultFooter`'s `bridgedNotProcessed` branch now returns a `Row` of two `GWButtonVariant.secondary` buttons: `Get help` and the existing `Close`. `Get help`'s `onPressed` captures `GoRouter.of(context)` into a local **before** calling `_close()` (which resets the cubit, resets `manualIndex`, and pops the root navigator via `onDismissDrawer`), builds the prefill message from `state` while `state` is still valid, then pushes `/logs` with the captured router handle **after** `_close()` has run - so the navigation never touches a context mid-unmount. `SubmitLogsScreen` gained an optional `initialMessage` parameter, seeded into `_feedbackController.text` in `initState`; `router.dart`'s `/logs` route now passes `state.extra as String?` (losing `const`). The prefill message (`_bridgedNotProcessedHelpMessage`) interpolates only `state.bridgeHash` and, when non-empty, `state.submitError` - no address, key, mnemonic, or balance figure (T-14-36's mitigation).
- **3d.** `_InlineError` deleted entirely. `JobChooseFileBody`'s file-rejection branch now renders `GWWarningNote(state.fileError)`.

## Real measured heights (not this plan's 268px arithmetic)

Ran `test/dashboard/compute_panel_height_test.dart` with a temporary height-probe print (added, captured, then reverted - confirmed via `diff` against a pre-edit backup that the file returned byte-identical to its pre-probe state):

| State | Panel height (both widths, both units) |
|---|---|
| noWallet | 224px |
| disconnected | 268px |
| notLinked | 268px |
| unavailable | 268px |
| **startingUp** | **268px** |
| processing | 234px |
| jobComplete | 268px |
| ready | 268px |

**The plan's derived 268px for `startingUp` is exactly what was measured** - the arithmetic in the plan (`256 - 10 (lost bar/space3) + 22 (gained fiat sub-line/space2)`) turned out correct, not merely close. Every state, including `startingUp`, sits at 268px or below against the 274px budget - the same 6px of headroom the other 268px states already had. No state exceeded 274px; nothing needed to be shaved.

The scale test's rounding, run rather than assumed: `(0.525).clamp(0.0, 1.0) * 100 = 52.5`, and Dart's `.round()` on `52.5` produces **53** (confirmed via a throwaway `dart run` script), so `startingUp`'s `trailing` at `initPercentage: 0.525` is `'53%'`, identical to `processing`'s `trailing` at `processingPercentage: 52.5`. The re-pointed test asserts this equality directly rather than hardcoding the string, so it stays correct if the rounding direction were ever revisited.

## Doc-comment corrections (Task 1a)

`ComputeStatusView.showBalanceFiatSubline`'s doc comment used to say the fiat line is dropped by "the tallest states (bar visible)". After this plan the ONLY bar state is `processing`, and per `14-08-SUMMARY.md`'s own measured table `processing` is the **shortest** non-empty state (234px), not the tallest - the old rationale is now backwards. Rewritten to say the true reason: a state already showing a bar (with its own trailing `%`) has nothing left for a second, unrelated fiat readout to say, so the fiat line stays reserved for states that have no bar to speak for them. `showBar`'s own doc comment was similarly rewritten to explain why `startingUp` lost its bar (a stalled feed with no real denominator) rather than merely listing which states show one.

## No-backoff decision (Task 1f)

Recorded in `app_bloc.dart` as a comment on `_onRetryProcessingStatus`, and here: `_onProcessingStatusTicked`'s `catch` (`app_bloc.dart:284-305` in the current file, not the stale `:192-195` DECISION.md cites - see drift #2 below) cancels `_processingTimer` immediately on every throw. `_onRetryProcessingStatus` only calls `_startProcessingPolling()`, which cancels-before-recreating and is therefore idempotent and leak-proof. So a tap on `Reconnect ›` costs at most ONE further FFI call before the feed goes quiet again if the node is still down - there is no automatic retry loop for a backoff to rate-limit, because cancel-on-throw already is the most aggressive backoff possible. Adding a failure counter would cost new `AppState`, a disabled/cooling-down link rendering, and copy for a condition that structurally cannot occur, and would remove the immediate retry in the one case that most plausibly recovers: a user who just brought the node back up.

## Frozen bar refusal (Task 1d)

Not built, by design. DECISION.md's file table names "frozen-bar rendering on the dead-feed branch" and the sketch draws `bar:'frozen'` on its state 04, but:

- `_ComputeProgressBar`'s own doc comment (`compute_panel.dart`) requires a non-null value specifically so "a caller with no live reading cannot construct this widget at all," and names a determinate indicator on a stopped feed as "a false statement about a job the user paid for." A frozen bar on the dead-feed branch is that statement made with MORE confidence, not less.
- The phase's own threat register (`14-08-PLAN.md`'s `T-14-29`, severity high) already carries this refusal.
- Board C - which DECISION.md itself adopts - exists specifically to delete this shape.

The sketch's state 04 also keeps the label `Starting up` under an error dot; that divergence is **not** built either, because it would require reordering the state ladder (`unavailable` outranks `startingUp` in `resolveComputeState`, a locked contract from plan 01 guarded by `compute_state_distinct_test.dart`). The shipped label stays `Status unavailable`.

## DECISION.md drifts (from the plan's `<notes>`) - confirmed or corrected

1. **"A dead node currently renders as Ready" is false** - confirmed. `app_bloc.dart`'s catch sets `processingFeedStatus: unavailable`, `resolveComputeState` returns `ComputeState.unavailable` for it, and the panel already renders `Status unavailable` / (now) `Feed stopped` / `Reconnect ›` under an error dot, per plan 08. What remained for this plan was copy only.
2. **`app_bloc.dart:192-195` is now a comment, inside the dev-mock guard, not the catch** - confirmed. The real catch is at `:284-305`; the cancel call (`_processingTimer?.cancel()`) is at `:291` in the current file.
3. **`compute_panel.dart:322` is `_UnitToggle`, not `_SublineRow`** - confirmed by reading the current file; `_SublineRow` now lives further down (`_ComputeTile` calls it inline within its `Column`). `_ComputeCardTile` and `_ComputeProgressBar` have both drifted further from the sketch's cited line numbers too, consistent with 14-08's own note.
4. **`app_bloc.dart:138` is not the processing poll** - confirmed. The 1s `Timer.periodic` inside `_startProcessingPolling` is at line 149 in the current file. The reasoning built on it (a 250ms spike trace cannot supply an `N` for a 1s poll) is unaffected.
5. **The `bridgedNotProcessed` close button is labelled `Close`, not `Done`** - confirmed and kept. DECISION.md's before/after table shows `Done` on both sides of its row, which asserts a rename the shipped code never made. `Close` stays, per the plan's own Task 3c instruction.
6. **"one new `ComputeLink` member" is really a rename** - confirmed and implemented as a rename. `ComputeLink.retry` already existed and was already dispatched (`wallet_overview.dart`, proven by `compute_panel_wiring_test.dart`) before this plan; renamed to `reconnect` rather than adding a second member, which would have stranded the first as unreachable.

## Files Created/Modified

- `lib/dashboard/compute/compute_state.dart` - `showBar` narrowed to `processing`; `startingUp`'s bar/trailing split; `initStatusMessage`/`startingUpFallbackMessage` deleted; feed-health sub-lines; `ComputeLink.retry` renamed to `reconnect`; doc comments corrected.
- `lib/components/wallet_overview.dart` - dropped `initStatusMessage` argument; `ComputeLink.retry` case renamed to `reconnect` with an updated comment.
- `lib/dashboard/compute/compute_panel.dart` - one doc-comment fix (`Retry ›` -> `Reconnect ›`), necessary consequence of the rename.
- `lib/bloc/app_state.dart` - `ponytail:` comment added to `AppState.initMessage` naming its now-zero-reader status and upgrade path.
- `lib/bloc/app_bloc.dart` - no-backoff decision comment added to `_onRetryProcessingStatus`.
- `lib/submit_job/view/widgets/job_steps.dart` - `JobInFlightBody`/`_InFlightRow` rebuilt (one spinner, numbered list); `bridgedNotProcessed` softened (label, no box, plain sentence); `_ResultFooter`'s `bridgedNotProcessed` branch gains `Get help`; `_InlineError` deleted, replaced by `GWWarningNote` in `JobChooseFileBody`.
- `lib/logs/submit_logs_screen.dart` - added optional `initialMessage` constructor parameter, seeded into the feedback controller in `initState`.
- `lib/navigation/router.dart` - `/logs` route now threads `state.extra as String?` into `SubmitLogsScreen`, loses `const`.
- `test/dashboard/compute_state_test.dart` - scale test re-pointed at `trailing` equality (with `barValue`/`showBar` asserted directly) instead of a `barValue` that no longer exists on `startingUp`.
- `test/dashboard/compute_state_distinct_test.dart` - dropped the deleted `initStatusMessage` argument.
- `test/dashboard/compute_panel_height_test.dart` - dropped `initStatusMessage`; corrected the doc comment describing the (now-gone) ellipsis-path fixture for `startingUp`.
- `test/dashboard/compute_panel_wiring_test.dart` - `Retry ›` -> `Reconnect ›` in both the assertion and the tap.
- `test/theme/compute_contrast_test.dart` - dropped `initStatusMessage`; `barStates` narrowed from `[startingUp, processing]` to `[processing]` (startingUp no longer renders a `computeBarFill` key).
- `test/submit_job/job_flow_test.dart` - `JobInFlightBody` test updated to one spinner + numbered-list assertions; `bridgedNotProcessed` label assertions updated in both the widget-level and end-to-end tests; end-to-end test gains a `Get help` render assertion; the no-retry guard (`find.textContaining('Try')`, `findsNothing`) is unchanged and still passes.

## Decisions Made

See `key-decisions` in the frontmatter. The one decision with product weight (Task 2's `Get help` destination) was already made by Jakub on 2026-07-31 and is implemented, not re-litigated, here.

## Deviations from Plan

### Auto-fixed / necessary-consequence edits

**1. [Rule 1-adjacent - stale-comment fix, necessary consequence of Task 1c's rename] Updated `compute_panel.dart`'s `onLinkTap` doc comment**
- **Found during:** Task 1
- **Issue:** The doc comment on `ComputePanel.onLinkTap` named `Retry ›` literally as one of the affordance labels it documents. After renaming `ComputeLink.retry` to `reconnect` (and its label to `Reconnect ›`), that comment describes a label the code no longer produces.
- **Fix:** Updated the comment to say `Reconnect ›`.
- **Files modified:** `lib/dashboard/compute/compute_panel.dart`
- **Verification:** `flutter analyze` clean; not testable by an automated assertion (it is a doc comment), confirmed by re-reading.

---

**Total deviations:** 1, a necessary consequence of Task 1c's own rename (not scope creep - the file is one line, doc-comment only, and is a direct fallout of a change the plan explicitly requires).
**Impact on plan:** No behavioural change; no scope creep beyond a stale-comment fix caused by this plan's own rename.

## Issues Encountered

None that required deviation beyond the one documented above. Two things worth naming as non-issues:

1. The temporary height-probe `print()` added to `compute_panel_height_test.dart` to capture real per-state heights was reverted before final verification; confirmed via `diff` against a pre-edit backup that the file is byte-identical to its state before the probe was added.
2. The full test suite's total count dropped from **823** (14-08's own baseline) to **821** in this session. This is fully explained, not a regression: `test/theme/compute_contrast_test.dart`'s `barStates` list shrank from `[startingUp, processing]` (2 states × 2 appearance modes = 4 generated tests) to `[processing]` alone (1 state × 2 modes = 2 generated tests), per Task 1e's explicit instruction, because `startingUp` no longer renders `ValueKey('computeBarFill')` at all. 823 - 2 = 821. Every one of the 821 that ran, passed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All three `<must_haves>` truths hold: `startingUp` shows no determinate bar with a promised denominator; the panel says whether the feed is alive in both directions through existing slots; the in-flight step names two operations without implying which is running; the burned-tokens terminal states its outcome once, keeps the hash, offers `Get help` as a way forward that is not paying twice, and still has no `Try again`; step 1's rejected file has exactly one visual treatment (`GWWarningNote`) in the app.
- `ComputeState.stalled` (the ninth state) and option D (an extra cubit `emit`) remain deliberately out of scope and untouched, per the plan's own fence.
- The `Get help` end-to-end tap-through (drawer closes, `/logs` opens with the message actually visible, sending still works) was not exercised in an automated test - see coverage item D6's rationale - and is a candidate for the human-check walk below.
- Six `.planning/ROADMAP.md` passages are stale per the plan's own `<notes>` (recorded there, not edited here, per the parallel-sessions rule): the `RetryProcessingStatus`/`SGNUSConnectionStatusWidget` block 14-08 already closed, and `CMP-01..CMP-10` never being written into `REQUIREMENTS.md`. Neither is this plan's to fix.

### Human-check walk NOT performed this session

The plan's `<human-check>` block (8 items, requiring `--dart-define=GW_DEV_TOOLS=true` and a live app/device walk) was **not run this session** - this was code-only execution, consistent with 14-08's own precedent. In particular, item 6 (tapping `Get help` and confirming the composer opens pre-filled and still sends) has no automated equivalent in this session's verification and should be walked by a human before this plan is considered fully verified.

### State file updates - NOT performed, by explicit instruction

Per this session's hard overrides and the plan's own `<constraints>` ("Do not write `.planning/ROADMAP.md`, `STATE.md`, `MANIFEST.md` or `HANDOFF.json` unless this session holds the executor role"), no `gsd-tools query state.*` / `roadmap.*` / `requirements.*` commands were run, and no commit of any kind was made - not per-task, not for this SUMMARY, not for metadata. All work described above is uncommitted in the working tree, exactly as required.

## Verification - real captured output

- `flutter analyze` (repo-wide, run fresh in this session, twice, both after Task 1 and again after Task 3): **"No issues found!"** both times (15.0s baseline before any edit; 30.1s/28.6s after all edits).
- `bash tool/check_brace_style.sh --count`: **0**
- `bash tool/check_raw_colors.sh --count`: **0**
- `bash tool/check_no_new_key_logging.sh` against all 8 `lib/` files touched: **"OK: no new key logging (no diff for ...)"**
- `grep -rn "_InlineError" lib/`: **no matches** (exit 1)
- `grep -c "ComputeState.startingUp" lib/dashboard/compute/compute_state.dart`: **5**
- `flutter test --no-pub test/dashboard/compute_state_test.dart test/dashboard/compute_state_distinct_test.dart test/dashboard/compute_panel_height_test.dart test/dashboard/compute_panel_wiring_test.dart test/theme/compute_contrast_test.dart`: **90/90 passed**
- `flutter test --no-pub test/submit_job/job_flow_test.dart`: **22/22 passed**
- `flutter test --no-pub test/freeze_rule_test.dart`: **1/1 passed**
- `flutter test --no-pub` (full suite, run twice fresh in this session): **821/821 passed, 0 failures, exit code 0** both times - down from 14-08's own 823/823 baseline by exactly 2, fully explained above (a plan-mandated shrink of `compute_contrast_test.dart`'s bar-state matrix from 2 states to 1, not a regression).
- `dart format --set-exit-if-changed` across every file touched this plan: **"Formatted 14 files (0 changed)"** (two files were auto-reformatted by an earlier `dart format` invocation during this session and re-verified clean afterward; `flutter analyze` and the full test suite were re-run after that reformat and stayed clean/passing).

**Nothing in the above is attributable to the concurrent 09-08 (Banxa) agent.** `git status --short` throughout this session showed only this plan's own files plus the Banxa-owned files that agent's already-landed, uncommitted work touched (`lib/banxa/**`, `test/banxa/**`, `lib/screens/banxa_buy_screen.dart`, `lib/screens/order_details_page.dart`); `lib/navigation/router.dart` is the one file both this plan and 09-08 touch, and this plan's edit (`/logs`'s route builder) does not disturb the `/buy`/`/buy/orders` routes 09-08 added (confirmed present and unchanged by grep).

## Self-Check: PASSED

- All 8 `lib/` files and 6 `test/` files claimed modified confirmed present on disk with the described changes (re-read after editing where noted above).
- `_InlineError` confirmed absent from `lib/` via `grep -rn`.
- `git log --oneline -3` confirms HEAD is unchanged from before this session - no commit was created, per the absolute no-commits constraint.
- `git status --short` confirms the working tree contains only this plan's own changes plus the concurrent 09-08 (Banxa) agent's already-uncommitted edits - no other file was touched.

---
*Phase: 14-compute-panel-job-flow*
*Completed: 2026-07-31*
