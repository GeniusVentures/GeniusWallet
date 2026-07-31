---
phase: quick-260731-hrn
plan: 01
subsystem: dev-fixtures
tags: [submit-job, compute-panel, dev-tools, sgnus]
status: complete
dependency-graph:
  requires: [260731-huc, 260731-elz]
  provides: [devjob-scenario-notifier, sgnus-processing-ramp, sgnus-jobcomplete-fixture, sgnus-init-scale-fix]
  affects: [lib/submit_job/cubit/submit_job_cubit.dart, lib/dev/dev_mock_job.dart, lib/dev/dev_mock_sgnus.dart, lib/bloc/app_bloc.dart, lib/dev/dev_tools_bubble.dart]
tech-stack:
  added: []
  patterns: [ValueNotifier-backed dev override with a cubit-side listener registered in the constructor and removed in close(), one-shot release flag draining a sticky override that copyWith cannot null]
key-files:
  created:
    - test/dev/dev_mock_sgnus_test.dart
  modified:
    - lib/dev/dev_mock_job.dart
    - lib/submit_job/cubit/submit_job_cubit.dart
    - lib/dev/dev_tools_bubble.dart
    - lib/dev/dev_mock_sgnus.dart
    - lib/bloc/app_bloc.dart
    - test/dev/dev_mock_job_test.dart
    - .planning/todos/pending/2026-07-31-sdk-init-percentage-is-0-100-but-read-as-0-1.md
decisions:
  - "DevMockJob.scenario became a ValueNotifier<DevJobScenario?> so SubmitJobCubit can re-price a file already chosen when a scenario is armed after the pick, not only at pick time."
  - "DevMockSgnus.jobCompleteOverride is a fourth sticky override deliberately NOT cleared by clear() - only by its own clearJobComplete(), called explicitly from the Clear button - matching the trap the other two 14-02 overrides already had."
  - "SGNUS init now arms 0.37 (0.0-1.0), not 37 - the 37.0 value was failing resolveComputeState's < 1.0 gate and had never actually reached ComputeState.startingUp before this task."
metrics:
  duration: "~2.5h"
  completed: 2026-07-31
---

# Quick Task 260731-hrn: Re-price on fixture arm, and make the compute panel's ongoing states walkable Summary

Three dev-fixture defects fixed: arming a JOB scenario after a file is already picked now re-prices
it instead of doing nothing; the compute panel's processing bar now visibly advances and a `Job
done` button reaches `ComputeState.jobComplete` for the first time; and the `SGNUS init` button now
arms a value on the field's actual 0.0-1.0 scale instead of one that silently never reached
`ComputeState.startingUp`.

## Branch and pre-flight

Branch was `redesign/jakub-260730` at the start of this session, matching the task brief exactly -
no discrepancy to report (the file-ownership note referenced a different branch,
`redesign/jakub-260728`, but `git branch --show-current` read `redesign/jakub-260730` throughout).
No branch was switched or created.

Pre-flight baseline, taken before any edit: `flutter test` 866/866 passing (one console-only
`RenderFlex overflowed` warning from `token_info_screen.dart:910`, which is quick task 260731-hsb's
in-progress work on a file this task does not own - not a failure, and not touched here).
`flutter analyze lib test`: 0 issues.

Post-change: `flutter test` **893/893 passing** (866 baseline + 27 new: 6 in
`test/dev/dev_mock_job_test.dart`'s new `notifier semantics` group, 21 in the newly created
`test/dev/dev_mock_sgnus_test.dart`). `flutter analyze lib test`: **0 issues, no new findings.**
`tool/check_brace_style.sh`: exit 0. `tool/check_raw_colors.sh`: exit 0. All four gates pass.

## Task 1: Re-price the already-chosen file when the armed scenario changes

`DevMockJob.scenario` is now a `ValueNotifier<DevJobScenario?>` (was a plain field). `arm`/`clear`
assign `.value`; `balance`, `costShouldFail` and `outcome` all read `.value`.

`SubmitJobCubit`'s pricing branch (previously inline inside `openFilePicker`, lines 134-204 at the
time the plan was written) is extracted into `Future<int> _resolveJobCost(dynamic jsonData)` with
every emit, comment and branch moved verbatim - `test/submit_job/` (85 tests) passes unchanged,
proving the extraction changed no production behaviour.

The cubit's constructor now registers `DevMockJob.instance.scenario.addListener(_onDevScenarioChanged)`
under `kDebugMode && kShowDevTools`, and `close()` removes it under the identical gate.
`_onDevScenarioChanged` is synchronous (required by `ValueNotifier.addListener`) and fires
`unawaited(_repriceForDevScenario())`. `_repriceForDevScenario()`:
1. returns immediately if `isClosed` or if `state.uploadedJson.isEmpty` (the no-op the constraint
   demands - arming with no file chosen does nothing at all);
2. resets `jobCost: 0`, `jobGasCost: '0.00 Gwei'`, `costError: ''` **before** re-pricing, so a failed
   real re-price (e.g. Clear with no native node) doesn't leave a stale fixture value on screen;
3. re-runs `fetchGnusBalance()` (routes through the fixture or the real `gnusCubit` depending on what's
   now armed);
4. re-runs `_resolveJobCost(state.uploadedJson)` and emits the result.

The Clear button's own comment and all five JOB arm toasts were rewritten - none still claims the
fixture is read only at pick time; each now states that a file already chosen is re-priced
immediately.

`test/dev/dev_mock_job_test.dart` gained a `notifier semantics` group (6 tests) pinning: arming from
null notifies once; arming the same scenario twice does not notify; switching scenarios notifies;
`clear()` from armed notifies; `clear()` when already clear does not notify; a removed listener stops
being called.

## Task 2: A processing bar that moves, and a Job done button

`DevMockSgnus.processingPercentage` is now a time-derived instance getter backed by a pure
`processingPercentageForElapsed(Duration)`: 1 step per second (matching `app_bloc.dart`'s 1000ms
processing timer), 4 points per step, modulo 100 (so the sequence is 0, 4, 8 ... 96, then 0 again -
never 100, since a bar at 100% on an unfinished job would be a lie). `arm(processing: true)` only
starts the ramp on a genuine transition into processing, so repeated presses of `SGNUS busy` don't
restart it; `arm(processing: false)` and `clear()` both null the arm time back to 0.0.

**Confirmed: `SGNUS busy` then `SGNUS idle` does NOT produce `jobComplete`.** `processingCompletedAt`
is written only inside `app_bloc.dart`'s real-SDK success path (`justCompleted ? DateTime.now() :
null`, inside the `try` after `api.getProcessingStatus()`); the dev branch returns before ever
reaching that line. `DevMockSgnus.jobCompleteOverride` is a new sticky override (a fourth, alongside
`initPercentageOverride` and `feedUnavailableOverride`) that the dev branch now checks and, when true,
emits `initPercentage: 1.0` (so `startingUp` can never mask `jobComplete`) and refreshes
`processingCompletedAt: DateTime.now()` on every tick (the same stickiness mechanism the other
overrides use). A new `Job done` button in `dev_tools_bubble.dart`, right after `SGNUS busy`, arms it
with the same four-step load-bearing order the SGNUS buttons already use. `clear()` deliberately does
**not** touch `jobCompleteOverride` - only the explicit `clearJobComplete()`, wired into the Clear
button alongside the other two overrides with the same trap.

## Task 3: Settle the init-percentage scale, and make startingUp actually reachable

Re-derived the plan's verdict against current source myself before changing anything, per the
plan's explicit stop condition. It held - see the verdict section below.

`SGNUS init` now arms `0.37` instead of `37` - the field is documented 0.0-1.0
(`packages/genius_api/lib/src/genius_api.dart:81`) and `resolveComputeState`'s gate is
`initPercentage < 1.0`, which `37.0` always failed. **This state had never actually been reachable
from the dev fixtures before this task.**

Two supporting fixes were required or the one-line change alone traps the panel:
- `_onInitializationStatusTicked` gained the same dev guard `_onProcessingStatusTicked` already has,
  at the top of the handler, ahead of the `try` - without it the real 3s init poll would overwrite the
  armed `0.37` on its next tick and the walk would flicker between the fixture and the real feed.
- A one-shot release (`_initReleasePending` / `initReleasePending` / `consumeInitRelease()`, following
  `DevFaultInjector.consumeAccountLoadFailure`'s idiom) was added because `copyWith` cannot null
  `initPercentage` and the real init timer self-cancels once a reading reaches 1.0 - without a release,
  a node that already finished initialising has no further poll to correct a released override, and
  Clear would strand the panel in `startingUp` forever. `clearInitPercentage()` now arms the pending
  release only if an override was actually set; `_onProcessingStatusTicked`'s dev branch consumes it
  at the very top (before the `feedUnavailableOverride` early return) and passes `initPercentage: 1.0`
  when consumed, in both the `feedUnavailableOverride` emit and the general emit (the `jobComplete`
  emit already passes 1.0 unconditionally for its own reason - the two agree where both apply).

A new test asserts `resolveComputeState(initPercentage: 0.37, ...)` resolves to `ComputeState.
startingUp` directly - the test that would have caught this defect before it shipped.

### Init-percentage verdict

**One sentence:** the traced `init=37.0` was `DevMockSgnus.armInitPercentage(37)` being pressed
between the two traced builds, not a genuine SDK reading, so the claim that the SDK speaks 0-100 has
no surviving evidence and the 0.525-ceiling question remains genuinely open.

**Evidence I personally confirmed against source:** `dev_tools_bubble.dart`'s `SGNUS init` button
called `armInitPercentage(37)` (confirmed at the line before my edit); `app_bloc.dart`'s dev branch
passes `initPercentageOverride` straight into `AppState.initPercentage` with no scaling; `compute_
state.dart`'s gate is `initPercentage != null && initPercentage < 1.0`, which `37.0` fails, so the
ladder falls through to `ready`; grep confirmed `armInitPercentage` has exactly one call site in the
whole tree, and its literal is `37`. **I agree with the plan's derivation** - the fixture's literal
match plus the absence of any float32 rounding noise on `37.0` (versus the genuine `0.5249999761581421`
sample) is convincing, and I found nothing in the source that contradicts it.

The todo file was amended (not deleted, not moved to completed) with a `## CORRECTION (2026-07-31)`
section at the top stating what `init=37.0` actually was, that the SDK-speaks-0-100 claim has no
surviving evidence, that the fix sketch's point 4 was describing correct behaviour rather than a bug,
that the 0.525 ceiling question is still open, and what this quick task did and did not touch. The H1
was retitled; the filename is unchanged since another todo links to it by name.

## Cadence and clear() semantics (as requested)

**Cadence:** 1 step per second, 4 points per step, modulo 100 (25-second full sweep) - exactly as the
plan specified. No deviation.

**Does `clear()` touch `jobCompleteOverride`?** No. `clear()` only nulls `processingOverride` and
`_processingArmedAt`. `jobCompleteOverride` is released only by the explicit `clearJobComplete()`.
`test/dev/dev_mock_sgnus_test.dart` pins this directly: `'is NOT touched by clear() - the trap the
Clear button comment warns about, pinned here'` arms `jobCompleteOverride`, calls `clear()`, and
asserts it is still `true`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - blocking compile error] `_onInitializationStatusTicked`'s early `return;` did not
compile**
- **Found during:** Task 3 verification (`flutter test` failed to compile with "A value must be
  explicitly returned from a non-void function").
- **Issue:** the method's declared return type is `FutureOr<void>` but the method is not `async`. A
  bare `return;` inside a non-async function whose return type is `FutureOr<void>` (a union type, not
  literally `void`) is rejected by the analyzer, unlike the async `_onProcessingStatusTicked` where the
  same pattern is legal.
- **Fix:** changed the one early return to `return null;`, which is a legal `FutureOr<void>` value.
  The existing implicit fall-through at the end of the method was left untouched (already legal).
- **Files modified:** `lib/bloc/app_bloc.dart`.
- **Commit:** not committed per this task's constraints - left in the working tree.

**2. [Rule 3 - blocking test failure] `dev_mock_sgnus_test.dart`'s init-release tests leaked state
across tests**
- **Found during:** first run of the new test file.
- **Issue:** `clearInitPercentage()` only arms `_initReleasePending` when an override was actually set
  at call time. The `setUp`/`tearDown` calls to `clearInitPercentage()` were themselves sometimes
  called with an override still armed (left by the previous test), silently setting a pending release
  that the next test then inherited.
- **Fix:** added `DevMockSgnus.instance.consumeInitRelease();` to both `setUp` and `tearDown` to drain
  any stray pending flag between tests.
- **Files modified:** `test/dev/dev_mock_sgnus_test.dart`.
- **Commit:** not committed per this task's constraints.

No other deviations. No architectural changes were needed (Rule 4 never triggered). No auth gates
were encountered.

## Known Stubs

None introduced by this task.

## Threat Flags

None - all three tasks stay entirely inside the `kDebugMode && kShowDevTools` dev-fixture surface
already covered by the plan's own threat register (T-hrn-01 through T-hrn-04). No new network
endpoint, auth path, file access pattern, or schema change was introduced.

## Self-Check: PASSED

Files confirmed present:
- `lib/dev/dev_mock_job.dart` - FOUND (ValueNotifier scenario)
- `lib/submit_job/cubit/submit_job_cubit.dart` - FOUND (listener + `_resolveJobCost` + close override)
- `lib/dev/dev_mock_sgnus.dart` - FOUND (ramp, jobCompleteOverride, init release)
- `lib/bloc/app_bloc.dart` - FOUND (dev branch extended, init-tick guard added)
- `lib/dev/dev_tools_bubble.dart` - FOUND (`Job done` button, `0.37` arm, toast copy)
- `test/dev/dev_mock_sgnus_test.dart` - FOUND (new file, 21 tests)
- `test/dev/dev_mock_job_test.dart` - FOUND (notifier semantics group, 6 tests)
- `.planning/todos/pending/2026-07-31-sdk-init-percentage-is-0-100-but-read-as-0-1.md` - FOUND
  (correction section prepended, H1 retitled, filename unchanged)

No commits were made (per this task's constraints), so there is no commit hash to verify against
`git log` - all changes remain unstaged in the working tree, confirmed by `git status --short`
showing every file above as modified/untracked with nothing staged.

## Walk Script (in order)

Kill any running instance first - a second instance dies on the Hive container lock (symptom: a
window where you cannot type). The app binary is "Genius Wallet.app", with a space.

```
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

**Task 1 - the walk that failed before:**
1. Open "New processing job" from the wallet overview with NO JOB scenario armed. Pick any JSON file.
   Step 2 should fail with no native node running (the pre-existing "Unable to retrieve job cost").
2. Without closing the drawer, open the dev bubble, expand JOB, press `Priced OK`. **Step 2 must
   repopulate with the fixture cost and balance and Continue must enable - this is the exact press
   that did nothing before this task.**
3. Press `Insufficient`. Step 2 must switch to the shortfall note and Continue must disable again.
4. Press `Clear` in MOCK. Cost, gas and balance must go back to whatever the real SDK says (with no
   node running, the same failure as step 1). No fixture number may survive on screen.
5. Close the drawer, reopen it, and repeat step 2 once. This is the leaked-listener check - if a
   listener survived the first close, the second open throws.
6. With no file chosen, press any JOB button. Nothing should change and nothing should throw.

**Task 2:**
7. MOCK section, press `SGNUS busy`. Watch the compute panel's bar for 30 seconds. It must step
   forward roughly every second, reach 96%, and restart at 0. It must never read 100%.
8. Press `Job done`. The panel must read "Job complete" with "just now".
9. Press Clear and wait. Within about 70 seconds the panel must decay to "Ready" on its own, no
   interaction.

**Task 3:**
10. Press `SGNUS init`. The panel must read "Starting up" at 37%. Leave it for 10 seconds - it must
    NOT flicker back to another state.
11. Press Clear. The panel must leave "Starting up".
12. Press `Feed dead` and confirm it still behaves as before - nothing in this plan touched it.
