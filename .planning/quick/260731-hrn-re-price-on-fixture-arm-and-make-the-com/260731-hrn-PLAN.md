---
phase: quick-260731-hrn
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: true
requirements: [T1-REPRICE, T2A-PROGRESS-MOVES, T2B-JOBCOMPLETE-BUTTON, T3-INIT-SCALE]
files_modified:
  - lib/dev/dev_mock_job.dart
  - lib/dev/dev_mock_sgnus.dart
  - lib/dev/dev_tools_bubble.dart
  - lib/submit_job/cubit/submit_job_cubit.dart
  - lib/bloc/app_bloc.dart
  - test/dev/dev_mock_job_test.dart
  - test/dev/dev_mock_sgnus_test.dart
  - .planning/todos/pending/2026-07-31-sdk-init-percentage-is-0-100-but-read-as-0-1.md

must_haves:
  truths:
    - "Arming a JOB scenario while a file is already chosen re-prices that file immediately: step 2 changes on screen without re-picking."
    - "Pressing Clear while a file is chosen returns cost, gas and balance to whatever the real SDK says, leaving no fixture numbers behind."
    - "Re-pricing does nothing at all when no file has been chosen."
    - "Two live SubmitJobCubits can be opened and closed in any order without a listener outliving its cubit."
    - "With the SGNUS busy fixture armed, the compute panel's progress bar visibly moves and its percentage text changes every second."
    - "ComputeState.jobComplete has a dev button that lands the panel in it directly."
    - "ComputeState.startingUp is reachable from the SGNUS init button and is releasable by Clear."
    - "Every comment and toast that describes when the JOB fixture is read tells the truth after this plan."
  artifacts:
    - test/dev/dev_mock_sgnus_test.dart
  key_links:
    - "SubmitJobCubit listens to DevMockJob.scenario and removes that listener in close(), because the cubit is constructed per-subtree in two places and both instances can be alive at once."
    - "The re-price reads state.uploadedJson, because that field is the only record that a file was chosen and it is what makes the no-op case decidable."
    - "app_bloc's dev branch emits a changing processingPercentage every tick, because that branch has no equality guard and AppState is Equatable, so an unchanging value would produce no rebuild."
    - "The jobComplete dev emit pushes initPercentage to 1.0, because startingUp outranks jobComplete in resolveComputeState and copyWith cannot null initPercentage."
    - "_onInitializationStatusTicked needs the same dev guard _onProcessingStatusTicked has, because its own 3s poll overwrites any armed init override."
---

<objective>
Two live-walk defects in the dev fixtures, plus one recorded finding that is
probably recorded wrong.

1. Arming a JOB scenario does nothing when a file is already chosen. Jakub hit
   this minutes ago: pick a file, watch step 2 fail with "Unable to retrieve
   job cost", press `Priced OK`, nothing changes, Continue stays disabled,
   stuck. The fixture works exactly as built - the whole fixture branch lives
   inside `openFilePicker`, so pricing happens once, at pick time, and no code
   path exists that would re-run it. The fix is to make the scenario
   observable and re-price on change. The fix is NOT to reword the comment
   that promises this already works.
2. The compute panel's two "ongoing job" states cannot be walked properly. The
   mocked processing percentage is a fixed 42.0, so the bar never moves, which
   is most of what a progress affordance needs reviewing for. And
   `ComputeState.jobComplete` has no dev button at all.
3. A pending todo claims the SDK reports init progress on a 0-100 scale. The
   evidence for it is a single traced value, `init=37.0`, which is exactly what
   `DevMockSgnus.armInitPercentage(37)` injects. Determine which it is from the
   code and act accordingly.

Purpose: these are the fixtures a human walk runs on. A fixture that answers
only at one moment, a bar that never moves, and a state with no button are all
the same defect in different clothes - the walk cannot see the thing it exists
to see.

Output: a fixture that re-prices, a bar that moves, a `Job done` button, a
`SGNUS init` button that actually reaches its state and can be released, and a
written verdict on the todo.
</objective>

<constraints>
## DO NOT COMMIT. DO NOT PUSH. DO NOT STAGE.

This overrides the GSD default of an atomic commit per task, and it overrides
anything in the execute-plan workflow that says otherwise. It is Jakub's
standing rule for this project. He reviews locally and opens the PR himself
into `ui-redesign-port`.

Leave every change in the working tree. Do not run `git add`, `git commit`,
`git stash`, `git checkout`, or `git push`. Do not create a branch.

## Files owned by a parallel task - DO NOT TOUCH

Quick task 260731-hsb is running right now on:
- `lib/components/coins/view/coins_screen.dart`
- `lib/dashboard/chart/markets_screen.dart`
- `lib/navigation/router.dart`

Do not open them for editing. `router.dart:362` constructs a `SubmitJobCubit`
and `wallet_overview.dart:60` constructs the other one - Task 1 deliberately
puts the listener INSIDE the cubit precisely so neither construction site needs
a single character changed. If you find yourself wanting to edit `router.dart`,
stop and report instead.

## Branch discrepancy, report it

The task brief names branch `redesign/jakub-260730`. The tree is on
`redesign/jakub-260728`. Do NOT switch, and do NOT create the other branch.
Confirm with `git branch --show-current` at the start and state it in your
report.

## No em dashes

Not in copy, not in Dart comments, not in toasts, not in your report. Write
" - " (space hyphen space). Some existing comments in these files contain them;
leave those lines alone unless you are editing them anyway, and never add a new
one.

## Project rules that bite here

From AGENTS.md:
- Brace every `if`, body on its own line. `tool/check_brace_style.sh` enforces
  it and it will fail you.
- Colours and spacing from tokens only. `tool/check_raw_colors.sh` enforces it.
- Widgets, not `_buildFoo()` helpers, for anything NEW. The existing
  `_buildExpandedPanel` in `dev_tools_bubble.dart` already violates this and is
  NOT in scope.
- Mark intentional simplifications with a `ponytail:` comment naming the
  ceiling and the upgrade path.
- Non-trivial logic leaves one runnable check behind.

## Everything stays behind kDebugMode && kShowDevTools

Every new dev read is gated the same way the existing ones are. In
`SubmitJobCubit` that gate exists in exactly ONE place, the `_devJobScenario`
getter (`submit_job_cubit.dart:30-31`); do not add a second copy of it at an
interception site. In `app_bloc.dart` the gate leads the `&&` chain at `:200`
so the whole branch constant-folds away in release.
</constraints>

<context>
@.planning/STATE.md
@AGENTS.md

@lib/dev/dev_mock_job.dart
@lib/dev/dev_mock_sgnus.dart
@lib/dev/dev_fault_injector.dart
@lib/dev/dev_flags.dart
@lib/dev/dev_tools_bubble.dart
@lib/submit_job/cubit/submit_job_cubit.dart
@lib/submit_job/cubit/submit_job_state.dart
@lib/bloc/app_bloc.dart
@lib/bloc/app_state.dart
@lib/dashboard/compute/compute_state.dart
@lib/components/wallet_overview.dart
@test/dev/dev_mock_job_test.dart
@.planning/todos/pending/2026-07-31-sdk-init-percentage-is-0-100-but-read-as-0-1.md
</context>

<interface_context>
Facts already verified against the source. You do not need to re-derive these,
but you do need to keep them true.

**Task 1 - why arming late does nothing**
- `submit_job_cubit.dart:30-31`: `_devJobScenario` is the single gated read of
  `DevMockJob.instance.scenario`. `fetchGnusBalance`, `openFilePicker` and
  `bridgeTokens` all go through it.
- The fixture pricing branch is `submit_job_cubit.dart:134-204` and it sits
  inside `openFilePicker`. It runs once per pick. Nothing else calls it.
- `submit_job_cubit.dart:206-214` is the only writer of `uploadedFileName`,
  `uploadedJson` and `jobCost`.
- `submit_job_cubit.dart:159-164`'s comment claims arming after the drawer is
  open still works. True only before a pick. That claim is what misled Jakub.
- `dev_tools_bubble.dart:630-635`'s comment on the Clear button claims the JOB
  fixture "is read at the point of use on the next pick or submit". After Task
  1 that is false: clearing notifies listeners and re-prices immediately.

**Task 1 - the precedent to copy**
- `dev_fault_injector.dart:80`: `final ValueNotifier<DevMarketsFault?>
  marketsFault = ValueNotifier(null);` with `armMarketsFault` /
  `disarmMarketsFault` assigning `.value`. Its doc comment at `:64-79` is the
  written argument for sticky-with-an-explicit-off, and it says both arming and
  disarming trigger an immediate refetch.
- The listener for it is registered in `dashboard_screen.dart`'s
  `_MarketsDashboardViewState.initState`. Read it before writing Task 1 so the
  shapes match.

**Task 1 - state defaults you will need**
`submit_job_state.dart`: `uploadedJson` is `Map<String, dynamic>` defaulting to
`const {}` (`:46`, `:76`); `jobCost` int default 0 (`:47`, `:77`);
`jobGasCost` String default `'0.00 Gwei'` (`:48`, `:78`); `costError` String
default `''` (`:61`, `:82`). `copyWith` is plain `x ?? this.x` for all four
(`:109-115`), so passing a default value resets the field and passing null
keeps it.

**Task 1 - what tests can and cannot see**
`kShowDevTools` is `bool.fromEnvironment('GW_DEV_TOOLS')`, false under
`flutter test` because the runner passes no define. Every dev branch in
`SubmitJobCubit` is therefore unreachable from a test by construction. This is
already written down in the header of `test/dev/dev_mock_job_test.dart`. Test
the fixture class, not the cubit. Do not add `--dart-define` to the suite and
do not write a test that silently passes because the gate is off.

**Task 2a - why a fixed percentage cannot move**
- `app_bloc.dart:149`: the processing timer is `Timer.periodic(1000ms)` adding
  `ProcessingStatusTicked`.
- `app_bloc.dart:200-228` is the dev branch. It emits UNCONDITIONALLY, with no
  equality guard, unlike the real path at `:259-270`. `AppState` is Equatable,
  so an emit of an equal state produces no rebuild. A percentage that changes
  each tick therefore produces a rebuild each tick; a constant one produces
  none.
- `app_bloc.dart:221` is the ONLY reference to
  `DevMockSgnus.processingPercentage` in the repo (verified by grep across
  `lib/` and `test/`). It is free to change shape.
- `viewForComputeState` (`compute_state.dart:274-277`) divides
  `processingPercentage` by 100 and clamps, so the fixture must speak 0-100.

**Task 2b - jobComplete is NOT reachable from busy then idle**
- `sinceJobFinished` is computed in `wallet_overview.dart:189-193` from
  `appState.processingCompletedAt`.
- `processingCompletedAt` is written in exactly ONE place: `app_bloc.dart:267`,
  inside the real-SDK `try`, as `justCompleted ? DateTime.now() : null`.
- The dev branch (`:200-228`) returns at `:213` or `:227`, before that line. It
  never computes `didProcessingJustComplete` and never writes the field.
- Therefore arming `SGNUS busy` then `SGNUS idle` does NOT produce
  `jobComplete`. It produces `ready`. A button is genuinely needed. Say this
  plainly in your report - it is the answer to a question Jakub asked and did
  not want a button built on a guess.
- `copyWith` cannot null `processingCompletedAt` (`app_state.dart:147-148`).
  That is deliberate and documented at `app_state.dart:48-54`: the field is
  only ever written by the bloc, never cleared. Do not add a clear flag.
- The 60s decay IS observable: `wallet_overview.dart:66-77`'s 10s balance timer
  exists partly for this, and its own comment says so.
- `resolveComputeState` precedence (`compute_state.dart:131-166`): noWallet,
  disconnected, notLinked, unavailable, startingUp, processing, jobComplete,
  ready. `startingUp` outranks `jobComplete`, and `copyWith` cannot null
  `initPercentage` either (`app_state.dart:149`).

**Task 2b - the two buttons that already work**
- `Feed dead` (`dev_tools_bubble.dart:537-560`) arms `feedUnavailableOverride`;
  the dev branch emits `ProcessingFeedStatus.unavailable` at `:205-213`;
  `resolveComputeState` reads it as `isProcessingUnavailable`. This one works.
  Do not duplicate it.
- `SGNUS init` (`dev_tools_bubble.dart:516-536`) does NOT work. See Task 3.

**Task 3 - the init percentage verdict, already derived**
- `dev_tools_bubble.dart:519` calls `armInitPercentage(37)`, so
  `initPercentageOverride` becomes `37.0`.
- `app_bloc.dart:224` emits that straight into `AppState.initPercentage`, a
  field documented as 0.0-1.0 (`app_state.dart:56-59`).
- `compute_state.dart:154`: `initPercentage < 1.0` is FALSE for 37.0, so the
  ladder falls through. The `SGNUS init` button has never reached
  `ComputeState.startingUp`. It lands on `ready`.
- The todo's trace is `build#1 -> startingUp | init=0.5249999761581421` then
  `build#2 -> ready | init=37.0`. `ready` at `init=37.0` is exactly what the
  fixture value produces. `37.0` is a clean hand-entered integer with none of
  the float32 rounding signature the 0.525 sample carries, and `37` is the only
  such literal in the compute path (grep: `armInitPercentage` has one call
  site).
- The two alternating trace lines also have an explanation:
  `_onInitializationStatusTicked` (`app_bloc.dart:355-380`) has NO dev guard
  and re-emits the real reading every 3s (`:350`), so the real poll and the
  armed fixture take turns writing the same field.
- Verdict: the evidence for "the SDK speaks 0-100" is a value the fixture can
  produce, so that claim is unproven. The demonstrable defect is a fixture
  injecting a 0-100 value into a 0.0-1.0 field. The 0.525 ceiling question is
  still open and only a full boot trace settles it.
</interface_context>

<tasks>

<task type="auto">
  <name>Task 1: Re-price the already-chosen file when the armed scenario changes</name>
  <files>lib/dev/dev_mock_job.dart, lib/submit_job/cubit/submit_job_cubit.dart, lib/dev/dev_tools_bubble.dart, test/dev/dev_mock_job_test.dart</files>
  <action>
Read `dev_fault_injector.dart:56-93` and the listener registration in
`dashboard_screen.dart`'s `_MarketsDashboardViewState.initState` first. Match
those shapes.

1a. In `dev_mock_job.dart`, change `DevJobScenario? scenario;` (`:77`) to
`final ValueNotifier<DevJobScenario?> scenario = ValueNotifier(null);`. Import
`package:flutter/foundation.dart show ValueNotifier` only, with the same
one-line justification `dev_fault_injector.dart:1-5` carries for importing
foundation rather than material. Keep the field NAME `scenario` - the
precedent names the notifier itself, and renaming buys nothing. `arm(value)`
assigns `scenario.value = value`; `clear()` assigns `scenario.value = null`.
Update `balance`, `costShouldFail` and `outcome` to switch on `scenario.value`;
the exhaustive switch in `outcome` must stay exhaustive.

Extend the doc comment on `scenario` with the one fact it is missing and that
cost Jakub a stuck walk: this is a `ValueNotifier` and not a plain field
because `SubmitJobCubit` prices at pick time, so a scenario armed afterwards
must be able to push a re-price rather than wait for a pick that will not come.
Name `DevFaultInjector.marketsFault` as the precedent. Arming the same scenario
twice is still idempotent for free, because `ValueNotifier` only notifies on a
changed value - say so, because the existing "assigns, never toggles" sentence
now has a second mechanism behind it.

1b. In `submit_job_cubit.dart`, `_devJobScenario` becomes
`... ? DevMockJob.instance.scenario.value : null`. The gate stays in this ONE
place.

1c. Extract the pricing branch. Move the whole of `submit_job_cubit.dart:134-204`
(the `final int jobCost;` declaration through the end of the `else` real-SDK
branch) into a new private method on the cubit:

  `Future<int> _resolveJobCost(dynamic jsonData)`

returning the cost. Keep the parameter `dynamic`, not `Map<String, dynamic>`:
the real branch's `isGasFetchable` includes a `jsonData != null` check whose
current meaning depends on that. Move the code, do not rewrite it - every emit,
every comment, every branch keeps its current behaviour and its current
wording, including the comments at `:138-141`, `:145-147`, `:157-164` and
`:188-195`. `openFilePicker` then reads
`final jobCost = await _resolveJobCost(jsonData);` and its existing emit at
`:206-214` is untouched.

The one comment that must change while you move it is `:157-164`. Its claim
about arming after the drawer is open was true only before a pick. Rewrite it
to say what is now true: the balance rides in the same emit as the gas string,
AND a scenario armed after a pick pushes a re-price through the listener added
in 1d, which is the half that was missing.

1d. In `SubmitJobCubit`, register the listener in the constructor body,
alongside the existing `_initialize()` call, gated by the same
`kDebugMode && kShowDevTools` compile-time pair:

  if (kDebugMode && kShowDevTools) {
    DevMockJob.instance.scenario.addListener(_onDevScenarioChanged);
  }

`_onDevScenarioChanged` is a SYNCHRONOUS `void` method that calls
`unawaited(_repriceForDevScenario())` - `unawaited` is already available from
this file's `dart:async` import. Do not pass an async method to `addListener`.

`_repriceForDevScenario()`:
- returns immediately if `isClosed`;
- returns immediately if `state.uploadedJson.isEmpty` - no file chosen, nothing
  to price, and this is the no-op the constraint demands;
- emits a reset of the cost-derived fields to their declared defaults BEFORE
  re-pricing: `jobCost: 0`, `jobGasCost: '0.00 Gwei'`, `costError: ''`. This is
  what makes `Clear` honest: without it a failed real re-price would leave the
  fixture's `42.42 Gwei` on screen under a real error;
- awaits `fetchGnusBalance()`, which already routes itself through
  `_devJobScenario` and so answers from the fixture when armed and from
  `gnusCubit` when cleared. This is what unsticks the fixture's 99999.99
  balance on `Clear`;
- awaits `_resolveJobCost(state.uploadedJson)` and emits `jobCost:` with the
  result, guarded by `!isClosed` exactly like every other emit in this file.

Order matters and is load-bearing: reset first, then balance, then cost. The
reset must not run after the cost, or it erases the answer.

1e. Override `close()`:

  @override
  Future<void> close() {
    if (kDebugMode && kShowDevTools) {
      DevMockJob.instance.scenario.removeListener(_onDevScenarioChanged);
    }
    return super.close();
  }

The gate must be the identical pair used to add, or the two go out of step.
Dart canonicalises instance method tear-offs from the same object, so
`removeListener(_onDevScenarioChanged)` removes the closure that
`addListener(_onDevScenarioChanged)` added. Say that in a one-line comment -
it is the non-obvious fact the whole lifecycle rests on. Add a second line
naming the failure this prevents: the cubit is constructed per-subtree at
`wallet_overview.dart:60` and `router.dart:362`, both instances can be alive at
once, and a leaked listener would emit on a closed cubit the second time the
drawer opens.

1f. Truth in the dev panel. Two places currently promise something false:
- the Clear button's comment (`dev_tools_bubble.dart:630-635`) says the JOB
  fixture needs no dispatch because it is read on the next pick or submit.
  Rewrite: clearing now notifies the cubit's listener, and any file already
  chosen is re-priced against the real SDK on the spot.
- each of the five JOB arm toasts. Add one short sentence to each `message`
  saying that a file already chosen is re-priced immediately. Keep them short,
  keep " - " not em dashes, and do not touch the parts of the copy that are
  already accurate.

1g. `test/dev/dev_mock_job_test.dart` asserts on `.scenario` at lines 19, 25,
31 and 56. Those become `.scenario.value`. Then add a `notifier semantics`
group proving what the cubit now depends on:
- arming from null notifies exactly once;
- arming the SAME scenario a second time does NOT notify (this is the
  idempotence the toasts promise);
- switching from one scenario to a different one notifies;
- `clear()` from an armed scenario notifies, and `clear()` when already clear
  does not;
- a removed listener stops being called.
Use a local counter and `addListener`/`removeListener`, and remove every
listener you add in the test, or the singleton carries it into the next test.
The existing `setUp`/`tearDown` already call `clear`.
  </action>
  <verify>
    <automated>flutter test test/dev/dev_mock_job_test.dart test/submit_job/ &amp;&amp; flutter analyze lib test 2>&amp;1 | tail -3</automated>
  </verify>
  <done>
`DevMockJob.scenario` is a `ValueNotifier`. `SubmitJobCubit` adds a listener in
its constructor and removes it in `close()`, both under the same gate. A
scenario change re-prices `state.uploadedJson` when one exists and does nothing
when it does not. `Clear` re-runs the real balance and the real pricing and
leaves no fixture value on screen. No comment or toast still claims the fixture
is read only at pick time. `test/submit_job/` still passes unchanged, proving
the extraction of `_resolveJobCost` changed no production behaviour.
  </done>
</task>

<task type="auto">
  <name>Task 2: A processing bar that moves, and a Job done button</name>
  <files>lib/dev/dev_mock_sgnus.dart, lib/bloc/app_bloc.dart, lib/dev/dev_tools_bubble.dart, test/dev/dev_mock_sgnus_test.dart</files>
  <action>
2a. Make the mocked processing percentage advance.

In `dev_mock_sgnus.dart`, replace the `static const double
processingPercentage = 42.0` (`:66-68`) with a time-derived instance getter
plus a pure function behind it:

  static const Duration processingStep = Duration(seconds: 1);
  static const double processingStepPercent = 4.0;
  static const double processingCycle = 100.0;

  static double processingPercentageForElapsed(Duration elapsed) { ... }
  double get processingPercentage { ... }

The pure function takes elapsed, divides by `processingStep` to get whole
steps, multiplies by `processingStepPercent`, and takes the result modulo
`processingCycle`. The getter returns 0.0 when nothing is armed, otherwise
`processingPercentageForElapsed(DateTime.now().difference(_processingArmedAt))`
against a new private `DateTime? _processingArmedAt`.

Cadence, and justify it in the doc comment in these terms:
- one step per second, because `app_bloc.dart:149`'s processing timer ticks at
  1000ms and that is the finest cadence this feed can express. A faster ramp
  would only skip values.
- 4 points per step, so a full sweep takes 25 seconds. Long enough to watch the
  bar move and screenshot it at several widths, short enough that nobody waits.
- modulo 100, so the sequence is 0, 4, 8 ... 96, then 0 again. It never reads
  100, because a bar at 100% on a job that has not finished is the one value
  that would be a lie. The loop is also what makes it obviously synthetic: real
  progress does not restart.
- derived from elapsed wall time, not from a counter incremented per tick, so
  it is deterministic given an arm time and cannot drift if a tick is missed.

`arm({required bool processing})` sets `_processingArmedAt = DateTime.now()`
only on a transition INTO processing (`processing && processingOverride !=
true`), and nulls it when `processing` is false. That keeps the documented
idempotence of repeated `SGNUS busy` presses - a second press must not restart
the ramp. `clear()` nulls both the override and `_processingArmedAt`.

In `app_bloc.dart:220-222`, `DevMockSgnus.processingPercentage` becomes
`mock.processingPercentage`. Add a one-line comment stating why a moving value
matters here: the dev branch emits unconditionally, `AppState` is Equatable, so
the changing percentage is what produces a rebuild each tick and therefore a
bar that visibly moves. A constant would emit an equal state and paint nothing.

2b. Add the missing `jobComplete` button.

State the finding in a comment first, because it is the reason the button
exists: `processingCompletedAt` is written only at `app_bloc.dart:267` inside
the real-SDK `try`, and the dev branch returns before reaching it, so `SGNUS
busy` then `SGNUS idle` produces `ready`, not `jobComplete`.

In `dev_mock_sgnus.dart` add a fourth sticky override beside the other three:
`bool? jobCompleteOverride`, with `armJobComplete()` and `clearJobComplete()`,
documented in the same voice as `feedUnavailableOverride`.

In `app_bloc.dart`'s dev branch (`:200-228`), add `mock.jobCompleteOverride ==
true` to the `||` chain in the `if` condition, and handle it AFTER the
`feedUnavailableOverride` early return and BEFORE the generic processing emit:

  emit(state.copyWith(
    isProcessing: false,
    processingPercentage: 0.0,
    processingFeedStatus: ProcessingFeedStatus.live,
    initPercentage: 1.0,
    processingCompletedAt: DateTime.now(),
  ));
  return;

Two of those fields need their reason written down beside them:
- `initPercentage: 1.0` because `startingUp` outranks `jobComplete` in
  `resolveComputeState` and `copyWith` cannot null `initPercentage`, so a
  leftover sub-1.0 reading would mask this state permanently. 1.0 is also the
  only honest value for a node that has just finished a job.
- `processingCompletedAt: DateTime.now()` refreshed on EVERY tick, which is
  what makes this override sticky in the same sense as the other three: the
  walker holds the state while resizing and toggling appearance. Note the
  release behaviour explicitly - once `Clear` releases it the timestamp stops
  refreshing, the real 60s window from `jobCompleteWindow` runs out, and
  `wallet_overview.dart`'s 10s balance timer is what forces the rebuild that
  lets it decay to `ready`. That decay is therefore walkable too, and worth
  putting in the toast.

In `dev_tools_bubble.dart`, add a `Job done` button to the MOCK section
immediately after `SGNUS busy`. It must do the same four things `SGNUS idle`
does, in the same load-bearing order, or the panel resolves to
noWallet/disconnected/notLinked and never reaches the state: arm the override
FIRST, then `updateConnection(DevMockSgnus.instance.connection)`, then
`injectMockWallet(DevMockSgnus.instance.wallet)`, then dispatch
`ProcessingStatusTicked()`. Toast: the panel is in the post-completion
acknowledgement state, it is sticky, and pressing Clear starts the real 60s
window after which it decays to Ready. Tooltip in the same register as its
neighbours.

Add `DevMockSgnus.instance.clearJobComplete();` to the Clear button beside the
existing `clearInitPercentage()` / `clearFeedUnavailable()` calls, and extend
their shared comment - it already warns that a missed clear leaves the node
stuck, and this is a third field with the same trap.

2c. New file `test/dev/dev_mock_sgnus_test.dart`. Open it with the same header
`test/dev/dev_mock_job_test.dart` carries: this covers the fixture class only,
because `kShowDevTools` is false under `flutter test` and every consumer branch
is compiled out here. Cover:
- `processingPercentageForElapsed`: 0s is 0, 1s is 4, 24s is 96, 25s wraps back
  to 0, 26s is 4, and 500ms does not advance;
- the sweep never yields 100 for any whole step in one full cycle;
- `processingPercentage` is 0.0 when nothing is armed;
- `arm(processing: true)` immediately followed by a read is 0.0, and
  `arm(processing: false)` and `clear()` both return it to 0.0;
- `jobCompleteOverride` is null until armed, true once armed, null after
  `clearJobComplete()`, and is NOT touched by `clear()` (that is exactly the
  trap the Clear button's comment warns about, so pin the current behaviour
  whichever way you implement it, and make the test say which).
Use `setUp`/`tearDown` that reset every override on the singleton, following
`dev_mock_job_test.dart`.
  </action>
  <verify>
    <automated>flutter test test/dev/ test/dashboard/ &amp;&amp; flutter analyze lib test 2>&amp;1 | tail -3</automated>
  </verify>
  <done>
`SGNUS busy` produces a percentage that advances 4 points a second, wraps at 96
back to 0, and never reads 100. `app_bloc` reads it through the instance getter
and emits it every tick. A `Job done` button exists, arms the SGNUS fixture the
same way `SGNUS idle` does, and lands the compute panel in
`ComputeState.jobComplete`. Clear releases it. `test/dev/dev_mock_sgnus_test.dart`
pins the ramp arithmetic without a fake clock.
  </done>
</task>

<task type="auto">
  <name>Task 3: Settle the init-percentage scale, and make startingUp actually reachable</name>
  <files>lib/dev/dev_mock_sgnus.dart, lib/dev/dev_tools_bubble.dart, lib/bloc/app_bloc.dart, test/dev/dev_mock_sgnus_test.dart, .planning/todos/pending/2026-07-31-sdk-init-percentage-is-0-100-but-read-as-0-1.md</files>
  <action>
The verdict is already derived in `<interface_context>` above. Confirm it
against the source yourself before changing anything - if the code disagrees
with the verdict, STOP, change nothing in this task, and report the
disagreement. That is a legitimate outcome here.

Given the verdict holds, the defect is a fixture injecting a 0-100 value into a
0.0-1.0 field, and it is fixable here. But the one-line fix alone makes things
WORSE, so all three parts land together or none do:

3a. `dev_tools_bubble.dart:519`: `armInitPercentage(37)` becomes
`armInitPercentage(0.37)`. The toast title `(37%)` stays correct. The tooltip
says "Forces initPercentage: 37" and must become the 0.0-1.0 value with the
percentage in brackets. While you are on that button, add one sentence to the
toast naming what changed: this state was previously unreachable because 37.0
failed the `< 1.0` gate.

3b. Without this part, 3a creates a permanent trap. `_onInitializationStatusTicked`
(`app_bloc.dart:355-380`) has no dev guard and re-emits the real reading every
3s, so an armed 0.37 gets overwritten and the walk flickers between the fixture
and the real feed - which is precisely the alternation the todo's two trace
lines show. Add the same guard shape `_onProcessingStatusTicked` already uses,
at the very top of the handler, ahead of the `try` and for the same stated
reason: the FFI read must not be reached while the override is armed.

  final mock = DevMockSgnus.instance;
  if (kDebugMode && kShowDevTools && mock.initPercentageOverride != null) {
    emit(state.copyWith(initPercentage: mock.initPercentageOverride));
    return;
  }

3c. Without this part, `Clear` cannot escape `startingUp`. `copyWith` cannot
null `initPercentage` (`app_state.dart:149`), and the real init timer
self-cancels once a reading reaches 1.0 (`app_bloc.dart:367-369`), so on a
node that already finished initialising there is no further poll to correct the
released value: the panel would sit in `startingUp` forever after Clear.

Add a one-shot release to `dev_mock_sgnus.dart`, in the idiom
`DevFaultInjector.consumeAccountLoadFailure` already establishes:
- private `bool _initReleasePending = false`, exposed read-only as
  `initReleasePending`;
- `clearInitPercentage()` sets the pending flag only if an override was
  actually armed, then nulls the override;
- `armInitPercentage(...)` drops any pending release, since arming supersedes
  it;
- `bool consumeInitRelease()` returns and spends the flag, false when nothing
  is pending.

In `app_bloc.dart`'s `_onProcessingStatusTicked` dev branch, add
`|| mock.initReleasePending` to the `||` chain, and consume it at the TOP of
the branch, before the `feedUnavailableOverride` early return, so it can never
be stranded pending behind that return:

  final releasedInit = mock.consumeInitRelease();

Then pass `initPercentage: releasedInit ? 1.0 : mock.initPercentageOverride`
in BOTH emits in that branch. Write down why 1.0 and not null: the field cannot
be nulled, 1.0 is the only value that releases the `< 1.0` gate, and it is
self-correcting - if the node is genuinely still initialising, the real 3s poll
resumes the tick after the release and overwrites it with the truth. Note the
interaction with Task 2b's `jobComplete` emit, which already passes 1.0 for its
own reason; if both apply, they agree.

3d. Extend `test/dev/dev_mock_sgnus_test.dart` from Task 2:
- `armInitPercentage(0.37)` stores 0.37, and a value on the 0.0-1.0 scale is
  what the field holds;
- `clearInitPercentage()` after an arm leaves a release pending;
- `clearInitPercentage()` with nothing armed leaves NO release pending;
- `consumeInitRelease()` returns true once and false thereafter;
- `armInitPercentage` after a `clearInitPercentage` leaves no release pending.
Also add one guard test that the value the `SGNUS init` button arms would
resolve to `ComputeState.startingUp`: call `resolveComputeState` directly with
`initPercentage: 0.37` and the other inputs set to a connected, linked, live
node, and assert `startingUp`. That is the test that would have caught this
defect, so it belongs in the tree.

3e. Amend the todo file. Do NOT delete it and do NOT move it to completed. Add
a `## CORRECTION (2026-07-31)` section at the top of the body stating, in this
order: what `init=37.0` actually was and the two independent reasons for
believing it (the fixture's literal 37, and the clean integer against the
0.525 sample's float32 signature); that the SDK-speaks-0-100 claim therefore
has no surviving evidence and must not be acted on; that the fix sketch's point
4 about `_onInitializationStatusTicked` cancelling at `>= 1.0` is correct
behaviour under the 0.0-1.0 reading, not a bug; that the 0.525 ceiling question
is still genuinely open and only a full boot trace settles it; and that this
quick task fixed the fixture and left the SDK contract alone. Retitle the file's
H1 so a reader who only sees the title is not misled - keep the filename, since
another todo links to it by name.
  </action>
  <verify>
    <automated>flutter test test/dev/ test/dashboard/ &amp;&amp; grep -n "armInitPercentage" lib/dev/dev_tools_bubble.dart</automated>
  </verify>
  <done>
The `SGNUS init` button arms a 0.0-1.0 value, the compute panel resolves to
`ComputeState.startingUp`, the armed value survives the 3s init poll, and
pressing Clear releases it instead of pinning the panel in `startingUp`
forever. A test asserts `resolveComputeState` reaches `startingUp` from the
value the button arms. The todo carries a correction that says which of the two
explanations the code supports and what remains genuinely unknown.
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| dev fixture to app state | Fixture values are injected into `AppState` and `SubmitJobState` and rendered as if real |
| user-picked JSON to cubit | Unchanged by this plan; the existing 5 MB length check at `submit_job_cubit.dart:120-129` stays ahead of the read |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-hrn-01 | Information disclosure | Dev fixtures shipping in a release build | high | mitigate | Every new read stays behind the `kDebugMode && kShowDevTools` compile-time const pair that already leads the existing `&&` chains, so the branches constant-fold away in release. No new gate site is introduced in `SubmitJobCubit` - the single `_devJobScenario` getter stays the only one |
| T-hrn-02 | Denial of service | Listener leaked onto a closed `SubmitJobCubit` | medium | mitigate | `close()` removes the listener under the identical gate used to add it, and `_repriceForDevScenario` returns early on `isClosed` as a second line of defence |
| T-hrn-03 | Spoofing | A fixture value read as a real node reading | medium | mitigate | The ramp never reads 100 and visibly loops, `jobComplete` pushes an honest `initPercentage: 1.0`, and the init release is self-correcting against the real 3s poll |
| T-hrn-04 | Tampering | New package installs | low | accept | This plan installs nothing. No package-manager task exists |
</threat_model>

<verification>
Run all four gates after the last task, from the repo root:

    flutter analyze lib test
    flutter test
    tool/check_brace_style.sh
    tool/check_raw_colors.sh

Baseline is 849 passing tests. Report the exact post-change number and account
for every added test. `flutter analyze` must not gain a single new finding.

Take the baseline BEFORE you start, not from this document.
</verification>

<success_criteria>
- Arming a JOB scenario with a file already chosen changes step 2 on screen,
  with no re-pick.
- Pressing Clear with a file already chosen removes every fixture number from
  the flow: cost, gas and balance all come from the real SDK, including its
  failures.
- Arming with no file chosen does nothing at all.
- The compute panel's progress bar moves once a second under `SGNUS busy`.
- `Job done` lands the panel in `ComputeState.jobComplete`.
- `SGNUS init` lands the panel in `ComputeState.startingUp`, holds there, and
  is released by Clear.
- The plan's verdict on the init-percentage todo is confirmed or contradicted
  in writing, with the reason.
- All four gates pass. Nothing is committed, staged, or pushed.
</success_criteria>

<handoff_walk_script>
Include this in your report so Jakub can walk it immediately.

Kill any running instance first. A second instance dies on the Hive container
lock and the symptom is a window where you cannot type. The app binary is
"Genius Wallet.app", with a space.

    flutter run -d macos --dart-define=GW_DEV_TOOLS=true

Task 1, the walk that failed before:
1. Open "New processing job" from the wallet overview with NO JOB scenario
   armed. Pick any JSON file. Step 2 should fail the way it did for Jakub, with
   no native node running.
2. Without closing the drawer, open the dev bubble, expand JOB, press
   `Priced OK`. Step 2 must repopulate with the fixture cost and balance and
   Continue must enable. This is the exact press that did nothing before.
3. Press `Insufficient`. Step 2 must switch to the shortfall note and Continue
   must disable again.
4. Press Clear in MOCK. Cost, gas and balance must go back to whatever the real
   SDK says, which with no node is the failure from step 1. No fixture number
   may survive.
5. Close the drawer, reopen it, and repeat step 2 once. This is the leaked
   listener check: if a listener survived the first close, the second open
   throws.
6. With no file chosen, press any JOB button. Nothing should change and nothing
   should throw.

Task 2:
7. MOCK section, press `SGNUS busy`. Watch the compute panel's bar for 30
   seconds. It must step forward roughly every second, reach 96%, and restart
   at 0. It must never read 100%.
8. Press `Job done`. The panel must read "Job complete" with "just now".
9. Press Clear and wait. Within about 70 seconds the panel must decay to
   "Ready" on its own, no interaction.
10. Press `SGNUS init`. The panel must read "Starting up" at 37%. Leave it for
    10 seconds - it must NOT flicker back to another state.
11. Press Clear. The panel must leave "Starting up".
12. Press `Feed dead` and confirm it still behaves as before. Nothing in this
    plan should have touched it.
</handoff_walk_script>

<output>
Report back in the chat. Do not write a summary file, do not commit.

Your report must state:
- the branch you were on, and the discrepancy with the brief
- the pre-flight test baseline and the post-change number
- the init-percentage verdict, in one sentence, with the evidence you
  personally confirmed, and explicitly whether you agree with this plan's
  derivation
- confirmation, in one sentence, that `SGNUS busy` then `SGNUS idle` does not
  produce `jobComplete`, and the line of code that proves it
- the cadence you chose for the ramp and why, if it differs from this plan
- whether `clear()` touches `jobCompleteOverride` in your implementation, and
  which way your test pins it
- anything you found that this plan got wrong
</output>
