---
phase: quick-260731-elz
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: true
requirements: [T1-SILENT-PICK, T2-DEVMOCKJOB, T3-STICKY-PANEL]
files_modified:
  - lib/submit_job/cubit/submit_job_cubit.dart
  - lib/submit_job/submit_job_cta_state.dart
  - lib/dev/dev_mock_job.dart
  - lib/dev/dev_tools_bubble.dart
  - test/submit_job/submit_job_cta_state_test.dart
  - test/submit_job/submit_job_errors_test.dart
  - test/dev/dev_mock_job_test.dart
  - test/dev/dev_tools_bubble_persistence_test.dart

must_haves:
  truths:
    - "Picking a JSON file always changes step 1 on screen: either the filename appears, or a named reason does. Silence is impossible."
    - "A pricing failure renders its reason in step 2, not an endless pricing spinner."
    - "A second pick after a failed first pick is judged on its own merits, not on the stale error."
    - "With a JOB fixture armed, the whole flow runs start to finish with no native SDK: pick, cost, confirm, in flight, terminal."
    - "Each of the five job scenarios is selectable from the dev panel and lands somewhere different."
    - "The dev panel stays open, stays where it was dragged, and keeps its open sections across navigation and overlay flips. Only the X closes it."
  artifacts:
    - lib/dev/dev_mock_job.dart
    - test/dev/dev_mock_job_test.dart
    - test/dev/dev_tools_bubble_persistence_test.dart
  key_links:
    - "openFilePicker's emit is reached on every accepted file, because job_steps.dart's auto-advance listener gates on uploadedJson being non-empty and step 2 is where costError renders."
    - "resolveSubmitJobCtaState checks costError before jobCost == 0, because after task 1 a pricing failure leaves jobCost at 0."
    - "DevMockJob is read as a static singleton at the point of use inside SubmitJobCubit, because the cubit is built per-subtree in two places and the dev bubble has no provider path to it."
    - "The dev panel's open/position/section state lives on a process-lifetime singleton, because the State element is disposed on every route change and overlay flip."
---

<objective>
Make the submit-job flow walkable end to end, and stop the dev panel from
losing itself while Jakub walks it.

Jakub's own words, 2026-07-31: "tak zrob tak bym mogl imitowac stany i
przeechodzic, zalezy mi na sprwadzeniu UI" plus "ii flow". He wants to step
through choose file, cost, confirm, in flight, result and look at each screen,
imitating states as he goes. Every decision below is judged against that one
sentence.

Three parts:
1. The picked file is currently discarded in silence when pricing fails. Fix
   the discard, fix the CTA precedence that would otherwise turn the fix into
   an eternal spinner, and clear the stale error that would make the new
   precedence lie on a retry.
2. A DevMockJob fixture that intercepts the SDK-dependent pricing and
   submission operations so the flow runs with no native node and no real
   GNUS, with every terminal and blocked variant selectable.
3. The dev panel keeps its open state, its position and its open sections
   across navigation, so it survives a walk.

Purpose: today this flow cannot be reviewed at all. Picking a file does
nothing visible, and the two most interesting terminals are unreachable by
any means a human has.

Output: a walkable flow, five armable scenarios, a panel that stays put.
</objective>

<constraints>
## DO NOT COMMIT. DO NOT PUSH. DO NOT STAGE.

This overrides the GSD default of an atomic commit per task, and it overrides
anything in the execute-plan workflow that says otherwise. It is Jakub's
standing rule for this project. He reviews locally and opens the PR himself
into `ui-redesign-port`.

Leave every change in the working tree. Do not run `git add`, `git commit`,
`git stash`, `git checkout`, or `git push`. Do not create a branch.

## Branch discrepancy, report it

The task brief names branch `redesign/jakub-260730`. The tree is on
`redesign/jakub-260728`. Do NOT switch, and do NOT create the other branch.
Confirm which branch you are on with `git branch --show-current` at the start
and state it in your report so Jakub can decide.

## No em dashes

Not in copy, not in Dart comments, not in toasts, not in your report. Write
" - " (space hyphen space) instead. Some existing comments in the files you
touch contain them; leave those lines alone unless you are editing them
anyway, and never add a new one.

## Project rules that bite here

From AGENTS.md, which you must follow:
- Brace every `if`, body on its own line. `tool/check_brace_style.sh` enforces
  it and it will fail you.
- Colours and spacing from tokens only. No `Colors.*` outside `lib/theme/`.
  `tool/check_raw_colors.sh` enforces it.
- Widgets, not `_buildFoo()` helper methods, for anything NEW. The existing
  `_buildExpandedPanel` in dev_tools_bubble.dart already violates this and is
  NOT in scope to refactor.
- Mark intentional simplifications with a `ponytail:` comment naming the
  ceiling and the upgrade path.
- Non-trivial logic leaves one runnable check behind.
</constraints>

<context>
@.planning/STATE.md
@AGENTS.md

@lib/submit_job/cubit/submit_job_cubit.dart
@lib/submit_job/cubit/submit_job_state.dart
@lib/submit_job/submit_job_cta_state.dart
@lib/submit_job/view/widgets/job_steps.dart
@lib/dev/dev_mock_sgnus.dart
@lib/dev/dev_flags.dart
@lib/dev/dev_tools_bubble.dart
@test/submit_job/submit_job_errors_test.dart
@test/submit_job/submit_job_cta_state_test.dart
</context>

<interface_context>
Facts already verified against the source. You do not need to re-derive these,
but you do need to keep them true.

**The silent-discard chain**
- `submit_job_cubit.dart:106-114`: after a successful `jsonDecode`,
  `isGasFetchable` requires `jsonData != null`, a non-null
  `state.gnusTokenDetails.address`, and `jobCost != 0`. When false it calls
  `setCostError('Unable to retrieve job cost')` and returns.
- That return is before the emit at `:119-127` which is the only writer of
  `uploadedFileName`, `uploadedJson` and `jobCost`. The accepted file is lost.
- `costError` renders only in step 2 (`job_steps.dart:292-294`). Step 2 is
  unreachable because the auto-advance listener (`job_steps.dart:59-62`)
  requires `current.uploadedJson.isNotEmpty`, and the step 0 footer's
  `Continue` (`job_steps.dart:646-654`) gates on the same field.
- Step 1 renders only `fileError` (`job_steps.dart:166-176`), which is empty
  in this path. Net effect on screen: nothing at all.
- `jobCost` is 0 because `requestGeniusSDKCost`
  (`packages/genius_api/lib/src/genius_api.dart:537`) returns 0 whenever the
  SDK is not initialized.

**The precedent for not returning**
`getBridgeOutGasCost` failing (`submit_job_cubit.dart:117`, body at
`:175-187`) sets `costError` and returns from ITS OWN method. Control returns
to `openFilePicker`, which then emits. So a gas failure already keeps the
file. Only the pricing failure throws it away. That asymmetry is the bug.

**Emit ordering that must be preserved**
`setCostError` emits, then the final `state.copyWith(...)` in `openFilePicker`
reads the freshest state, so a `costError` set just before it survives. Do not
reorder these, and do not pass `costError` into that final `copyWith`.

**The two cubit construction sites** (why the fixture is a static singleton)
- `lib/components/wallet_overview.dart:60`, inside `initState`.
- `lib/navigation/router.dart:362`, a per-route `create:`.
Neither is above the dev bubble in the widget tree, so the bubble cannot
`context.read` this cubit. The fixture is read at the point of use instead.

**The gating idiom this repo already uses**
`kShowDevTools` is `bool.fromEnvironment('GW_DEV_TOOLS')`
(`lib/dev/dev_flags.dart`), always combined with `kDebugMode` at the call
site. Existing precedent inside a cubit: `banxa_order_cubit.dart:25`. Inside a
bloc: `app_bloc.dart:200`. `flutter analyze` is clean with this idiom, so it
does not trip dead-code.

**The two dev bubble mount sites** (why a plain static singleton is enough)
`responsive_overlay.dart:493` inside `MobileOverlay` and `:520` inside
`DesktopOverlay`. These are two different `Scaffold`s in two mutually
exclusive branches. At most one `DevToolsBubble` is alive at a time.

**The dev panel state fields**
`dev_tools_bubble.dart:73-82`: `_position`, `_expanded`, `_mockExpanded`,
`_testFlowsExpanded`, `_navigateExpanded`, `_banxaExpanded`,
`_appearanceExpanded`. `_expanded = false` is written at exactly one place,
`:234`, the X button. There is no outside-tap dismissal in the code.

**Test harness already in place** (`test/submit_job/submit_job_errors_test.dart`)
- `_FakeGeniusApi` with settable `requestGeniusSDKCostResponse` (int),
  `getBrigeOutGasCostResponse`, `bridgeOutResponse`, `processResponse`.
- `_FakeFilePickerPlatform` with a `resultBuilder`.
- `_build(...)` harness with named params `coin`, `tokenInfo`,
  `selectNetworkAndWallet`, returning `.cubit`, `.geniusApi`, `.dispose`.
Reuse all of it. Do not build a second harness.
</interface_context>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: The picked file survives a pricing failure, and the failure is what the user sees</name>

  <files>
lib/submit_job/cubit/submit_job_cubit.dart
lib/submit_job/submit_job_cta_state.dart
test/submit_job/submit_job_cta_state_test.dart
test/submit_job/submit_job_errors_test.dart
  </files>

  <behavior>
    - Pick a valid JSON file while pricing returns 0: `uploadedFileName` is
      the picked name, `uploadedJson` is non-empty, `jobCost` is 0, and
      `costError` is "Unable to retrieve job cost".
    - Pick a valid JSON file with no wallet or network selected: the file is
      kept and `costError` carries the missing-preconditions reason.
    - Pick a valid JSON file that prices fine: unchanged from today, file kept
      plus a non-zero `jobCost` plus a gas figure.
    - `resolveSubmitJobCtaState` with `hasFileChosen: true`, `jobCost: 0` and
      a non-empty `costError` returns `costError`, not `costUnknown`.
    - `resolveSubmitJobCtaState` with `hasFileChosen: true`, `jobCost: 0` and
      an EMPTY `costError` still returns `costUnknown`. The unpriced case is
      not collapsed into the failure case.
    - A first pick that fails pricing followed by a second pick that succeeds
      leaves `costError` empty and `jobCost` non-zero. The stale error does
      not survive the second pick.
  </behavior>

  <action>
Three edits that must land together. Any one of them alone makes the app worse
than it is now, so do not split them across separate passes.

**1a. Stop discarding the file in `openFilePicker`.**
Replace the early return at `submit_job_cubit.dart:111-114`. Keep computing
`isGasFetchable` exactly as it is, but use it only to decide whether to
ATTEMPT the gas estimate, never to abandon the method. When it is true, await
`getBridgeOutGasCost(jobCost)` as today. When it is false, call
`setCostError('Unable to retrieve job cost')` and skip the gas estimate. Then
fall through to the existing emit in both cases, unconditionally.

Do not call `getBridgeOutGasCost` with a zero cost. It would be a pointless
RPC round trip against an amount of nothing, and the existing test at
`submit_job_errors_test.dart:341` pins that this path produces the
cost-lookup message rather than a gas message.

Leave a comment above the branch naming the precedent it now matches: a gas
estimate failure at the line below already sets the error without returning,
which is why a gas failure keeps the file and a pricing failure did not. Also
name the consequence, because it is not local: keeping the file is what makes
step 2 reachable at all, since the auto-advance listener in `job_steps.dart`
and the step 0 footer both gate on `uploadedJson` being non-empty, and step 2
is the only place `costError` renders.

**1b. `costError` outranks `costUnknown` in `submit_job_cta_state.dart`.**
Swap the two blocks at `:83-92` so the `costError.isNotEmpty` check runs
before the `jobCost == 0` check. Without this, 1a trades a silent screen for a
permanent "Working out what this job costs" spinner over a job whose pricing
has already definitively failed, which is a worse lie than the silence.

Two comments in that file currently assert the opposite and must be rewritten,
not left to contradict the code:
- The precedence list in the doc comment at `:65-66`. State the new order.
- The reasoning paragraph at `:83-85`, which argues that zero is checked first
  so an in-flight lookup is not mistaken for a hard failure. That argument is
  now backwards. The replacement should say what is now true: a zero cost
  means "not priced yet" ONLY while nothing on the cost channel has failed,
  because after the cubit stopped discarding files a failed pricing attempt
  leaves the cost at zero too, and the failure is the more specific fact. Note
  the date and that it was a deliberate reversal, so the next reader does not
  "fix" it back.

The `costUnknown` enum doc at `:31-35` already says "and nothing on the cost
channel has failed", so it is already correct under the new order. Confirm and
leave it.

**1c. Clear the stale cost error when a new file is picked.**
`openFilePicker` calls `resetFileError()` at `:76` but never
`resetCostError()`. Add the reset next to it. Both `_initialize` failures
(`fetchGnusTokenInfo` and `fetchGnusBalance`, which both fail without a live
SDK) and any earlier failed pick leave `costError` set, and after 1b a stale
`costError` outranks everything a fresh successful pick emits. Without this,
1b lies on the second attempt.

**Out of scope, do not fix, do report.**
Under 1a plus 1b, step 2's cost table renders the literal row "Job cost 0
GNUS" above the warning note, because `JobCostBody` prints `state.jobCost`
unconditionally (`job_steps.dart:264-268`). That is honest but reads oddly.
Do not change it here. Note it in your report as an observation for Jakub.

**Tests.**
In `test/submit_job/submit_job_cta_state_test.dart`:
- Add to the `costError rung` group a case with `hasFileChosen: true`,
  `jobCost: 0`, a non-empty `costError`, asserting `costError` and explicitly
  `isNot(costUnknown)`. The test name and a comment must say this precedence
  was reversed deliberately on 2026-07-31, and why: after the cubit stopped
  discarding the file, a pricing failure leaves the cost at zero, so the old
  order rendered a pricing spinner over a known failure forever.
- The two existing `costUnknown` cases pass an empty `costError` and still
  hold. Leave them, and add one line of comment to the group explaining that
  they are now load-bearing in a second way: they pin that the reversal did
  not collapse the genuinely-unpriced case into the failure case.
- Do not delete any existing test in this file.

In `test/submit_job/submit_job_errors_test.dart`:
- `cost lookup returns zero -> costError only` (`:341`): keep every existing
  expectation and add that the file is now KEPT: `uploadedFileName` equals
  the picked name, `uploadedJson` is non-empty, `jobCost` is still 0. Retitle
  it so "only" no longer implies the file was dropped. Add a comment naming
  the change and the reason.
- `missing preconditions for gas estimation -> costError only` (`:362`): same
  treatment, file kept, error unchanged.
- `gas estimate failure` (`:383`): this path already kept the file before
  today's change. Add the `uploadedFileName` assertion here too, as the
  contrast case that pins the asymmetry is gone.
- Add one new test to the `cost channel` group: a first pick with the fake
  cost response at 0 leaves `costError` set, then set the fake cost response
  to a non-zero value and pick again, and assert `costError` is empty and
  `jobCost` is non-zero. This is the 1c regression guard and it is the exact
  scenario Jakub hits on a retry.
  </action>

  <verify>
    <automated>flutter test test/submit_job/submit_job_cta_state_test.dart test/submit_job/submit_job_errors_test.dart</automated>
    <automated>flutter analyze lib/submit_job</automated>
    <automated>grep -n 'resetCostError' lib/submit_job/cubit/submit_job_cubit.dart | grep -c 'resetCostError'</automated>
  </verify>

  <done>
- Picking a file with pricing broken leaves `uploadedFileName` and
  `uploadedJson` populated and `costError` set.
- `resolveSubmitJobCtaState` returns `costError` for a zero cost with a
  non-empty error, and still returns `costUnknown` for a zero cost with an
  empty error.
- Both rewritten comments in `submit_job_cta_state.dart` describe the code
  that is actually there.
- No test was deleted. Every changed test carries a comment saying why.
- The step 2 "Job cost 0 GNUS" observation is in the report, not in a diff.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: DevMockJob, the fixture that makes the whole flow walkable</name>

  <files>
lib/dev/dev_mock_job.dart
lib/submit_job/cubit/submit_job_cubit.dart
lib/dev/dev_tools_bubble.dart
test/dev/dev_mock_job_test.dart
  </files>

  <behavior>
    - `DevMockJob.instance.scenario` is null until armed and null again after
      `clear()`.
    - Arming is idempotent: arming the same scenario twice leaves the same
      state.
    - The balance getter returns the short balance for `insufficientFunds` and
      the affordable balance for every other scenario.
    - The outcome getter maps `bridgeFailed` and `bridgedNotProcessed` to their
      matching `SubmitOutcome` values and everything else to
      `SubmitOutcome.done`.
    - Every `DevJobScenario` value has an outcome. The mapping is exhaustive,
      pinned by iterating `DevJobScenario.values`.
    - The affordable balance is greater than or equal to the fixture job cost,
      and the short balance is less than it. Pinned by assertion so a later
      edit to one constant cannot silently break the priced-OK walk.
  </behavior>

  <action>
This is the task Jakub actually asked for. Weight it accordingly.

**The bar this must clear.** The flow has to run START TO FINISH under the
fixture. Picking a real JSON file must produce a mocked cost so step 2
populates, `Continue` enables, step 3 confirms, step 4 shows in flight, and
step 5 lands on a terminal. A fixture that teleports the cubit to a finished
state does NOT clear this bar. Intercept the SDK-dependent operations,
pricing and submission, and let the real flow run through them.

**2a. Create `lib/dev/dev_mock_job.dart`.**

Copy the shape of `lib/dev/dev_mock_sgnus.dart` exactly: a private
constructor, a `static final instance`, nullable sticky override state, arm
and clear methods, and a DEV-ONLY header comment naming what was unwalkable
before it existed. That file's doc comments are the standard to match: every
constant says WHY it is the value it is, not just what it is.

Contents:
- A top-level `enum DevJobScenario` with five values: `pricedOk`,
  `insufficientFunds`, `costFailure`, `bridgeFailed`, `bridgedNotProcessed`.
  Each value carries a doc comment naming what the walker sees when it is
  armed, and for the last one, that it is otherwise unreachable by any means
  a human has: it requires the bridge to succeed and the native process call
  to fail, which cannot be provoked on a live walk without burning real GNUS.
  That single fact is the strongest reason this fixture is worth building.
- A nullable `DevJobScenario? scenario` field. Null means no override, run
  for real. Sticky, not one-shot, for the same reason `DevMockSgnus`'
  `processingOverride` is sticky: a walker holds a state while resizing,
  toggling appearance and re-running the flow. Say so in the comment and name
  the contrast with `DevFaultInjector`'s one-shot fault.
- `arm(DevJobScenario scenario)` assigns, never toggles. `clear()` nulls it.
- Constants, all obviously synthetic in a screenshot the way
  `DevMockSgnus.address` spells DEV. Do not pick numbers that could pass for a
  real balance:
  - `jobCost`, an `int`, `1234`. A counting run reads as fake at a glance.
  - `affordableBalance`, a `double`, `99999.99`. Nobody holds this.
  - `shortBalance`, a `double`, `12.34`. Produces a clean 1221.66 shortfall
    against the fixture cost, which is what step 2's shortfall note prints.
  - `jobGasCost`, a `String`, `'42.42 Gwei'`. This field is a display string
    on the real state too, not a number.
  - `txHash` and `bridgeHash`, `String`s in the `DevMockSgnus.address` idiom:
    a hex-shaped value with DEV legible in it and a distinct tail per field,
    so the two terminals cannot be confused in a screenshot and neither can
    be mistaken for a chain artefact.
  - `processFailure`, a `GeniusNodeReturnValue`, set to the process-image
    error. The cubit's existing private message mapper turns this into the
    real production sentence, so the `bridgedNotProcessed` terminal shows
    exactly what a genuine failure shows rather than dev prose.
  - `costErrorMessage`, a `String` that names itself as a fixture, since this
    one has no production equivalent to borrow. It is a dev label, not product
    copy, so it sits outside the copy contract. Note that in the comment the
    way `DevMockSgnus` notes it for `walletName`.
  - `inFlightDelay`, a `Duration` of about 2 seconds. Without a pause the
    fixture would flash past step 4 and Jakub would never see the in-flight
    screen, which is one of the five screens he is here to look at. Say that
    in the comment. Mark it `ponytail:` with its ceiling: a fixed delay, not a
    simulation of real bridge latency.
- Derived getters, so the cubit never re-derives the mapping:
  - a balance getter returning the short balance for `insufficientFunds` and
    the affordable balance otherwise.
  - a bool for whether pricing should fail, true only for `costFailure`.
  - a `SubmitOutcome` getter with an exhaustive switch over the enum.

**2b. Intercept in `SubmitJobCubit`.**

Add one private getter that resolves the armed scenario or null, gated with
`kDebugMode && kShowDevTools` in a single place so the gate cannot be
forgotten at an individual site. Import `kDebugMode` from
`package:flutter/foundation.dart` with a `show`, exactly as `app_bloc.dart:10`
does, and note in a comment that flutter_bloc does not re-export it.

Three interception points. Each is a short branch with a DEV-ONLY comment
above it naming the gate and the reason.

1. `fetchGnusBalance`, at the top. When armed, emit the fixture balance and
   return it without touching `gnusCubit`. This is what stops `_initialize`
   from parking a stale "Unable to fetch GNUS balance" error on the state
   before the walk even starts.
2. `openFilePicker`, in the pricing block you just restructured in Task 1.
   When armed, do not call `requestGeniusSDKCost` and do not call
   `getBridgeOutGasCost`. Instead:
   - for the pricing-failure scenario, use a cost of 0 and set the fixture's
     cost error message. This lands the walk on exactly the state Task 1 made
     visible, which is why the two tasks verify each other: if Task 1
     regresses, this button produces a blank step 1 again.
   - otherwise, use the fixture cost and emit the fixture gas string.
   In BOTH branches also emit the fixture balance in the same emit. This is
   the one detail that makes the panel usable mid-walk: it means arming a
   scenario AFTER the drawer is already open still works, because the balance
   no longer depends on having been armed back when the cubit was constructed.
   Then fall through to the same shared emit the production path uses. Do not
   add a second emit path for the dev case.
3. `bridgeTokens`, at the very top, BEFORE the precondition guard at
   `:206-223`. That guard exists only to protect the two SDK calls the fixture
   is replacing, and in a dev environment with no token info it would reject
   every submission before step 4 could ever render. State that in the
   comment, because "the fixture skips a validation guard" is the kind of
   thing a reviewer must see justified rather than discover. The branch emits
   `isBridgingTokens: true`, awaits the fixture delay, then emits one of three
   terminals per the fixture outcome:
   - done: the fixture tx hash, outcome done, bridging false.
   - bridgeFailed: outcome bridgeFailed, bridging false, no hash on either
     field, and the submit error string byte-identical to the production one
     at `:244`.
   - bridgedNotProcessed: outcome bridgedNotProcessed, the fixture bridge hash
     on `bridgeHash` and NOT on `txHash`, bridging false, and the submit error
     produced by passing the fixture's process-failure value through the
     cubit's existing private message mapper.
   Then return. Do not schedule the delayed balance refetch here: the balance
   is fixture-driven and intercepted, so the refetch would sleep 5 seconds and
   re-emit the identical number. Say so in a comment so its absence reads as a
   decision.

Do not touch anything under `packages/genius_api/`. The interception belongs
in the consumer, which is the precedent `app_bloc.dart` set for `DevMockSgnus`.

**2c. Wire the buttons into `lib/dev/dev_tools_bubble.dart`.**

Add one new collapsible `_Section` labelled `JOB`, using the existing
`_Section` widget and the existing `_devButton` helper, placed after the MOCK
section and before TEST FLOWS. Default it to collapsed, matching TEST FLOWS,
BANXA and NAVIGATE. Its expand flag joins the others and must be lifted in
Task 3 along with them, so name it consistently with them.

Five buttons, one per scenario. Labels must be short enough to survive the
small button size's single-line ellipsis in the roughly 260px panel, with the
full description in the `tooltip:` argument, exactly as the BANXA buttons do.
Each handler arms the fixture and raises a toast through the existing
`ToastManager.instance.showToast` pattern. Every toast must say the fixture is
STICKY and released by Clear, since that is the convention the other sticky
fixtures' toasts already established, and must say what the walker will see:
- priced OK: steps 2 and 3 populate, Continue enables, the walk ends on the
  job-started terminal.
- insufficient funds: the cost is above the balance, so step 2 shows the
  shortfall note and Continue stays disabled. The walk deliberately stops
  there. Say that in the tooltip so a stuck Continue does not read as a bug.
- cost failure: pricing fails, step 1 still shows the filename and step 2
  shows the reason. This is the state Task 1 makes visible.
- bridge failed: the walk reaches the terminal where nothing was sent.
- bridged, not processed: tokens burned, job never started. The tooltip should
  say this is otherwise unreachable without spending real GNUS.

Add `DevMockJob.instance.clear()` to the existing `Clear` handler, next to
`DevMockSgnus.instance.clear()`. The comment already sitting there about
separate fields needing separate clears is the right place to extend. Note
that unlike the SGNUS buttons, these need no cubit dispatch to take effect,
because the fixture is read at the point of use on the next pick or submit.

Every call site stays inside the `kDebugMode && kShowDevTools` gate, which the
bubble's own mount sites already provide.

**2d. The runnable check.**

Create `test/dev/dev_mock_job_test.dart` covering the `<behavior>` bullets
above. Pure Dart on the fixture class only. It cannot go through the cubit:
`kShowDevTools` is a `bool.fromEnvironment` const that is false under
`flutter test`, so the dev branches are unreachable there by construction.
State that in a header comment on the test file, because "why is the
interception untested" is the first question a reviewer will have.

Use `addTearDown` to clear the singleton after each test. It is process-wide
state and a leaked scenario would contaminate whatever runs next.
  </action>

  <verify>
    <automated>flutter test test/dev/dev_mock_job_test.dart</automated>
    <automated>flutter analyze lib/dev lib/submit_job</automated>
    <automated>grep -c 'kDebugMode' lib/submit_job/cubit/submit_job_cubit.dart</automated>
    <automated>grep -v '^ *//' lib/dev/dev_tools_bubble.dart | grep -c 'DevMockJob.instance'</automated>
  </verify>

  <done>
- `lib/dev/dev_mock_job.dart` exists with five scenarios, a private
  constructor, a static instance, and a doc comment on every constant saying
  why that value.
- `SubmitJobCubit` intercepts balance, pricing and submission behind a single
  gated getter, and the production path through those methods is unchanged
  when nothing is armed.
- The dev panel has a JOB section with five arm buttons plus a Clear that
  releases the fixture.
- The last grep returns at least 6: five arm handlers plus the clear.
- `flutter analyze` is clean, including no dead-code complaint about the
  gated branches.
  </done>
</task>

<task type="auto">
  <name>Task 3: The dev panel closes only via its X</name>

  <files>
lib/dev/dev_tools_bubble.dart
test/dev/dev_tools_bubble_persistence_test.dart
  </files>

  <action>
**Read this before you start, it changes what the fix is.**

There is NO outside-tap dismissal anywhere in this code. `_expanded = false`
is written at exactly one place, `dev_tools_bubble.dart:234`, the X button.
What Jakub observes as "it closes when I click next to it" is STATE LOSS:
`_expanded` is a `State` field, and any rebuild that disposes the element
resets it to false. Route changes do that. The Mobile to Desktop overlay flip
does that, since `responsive_overlay.dart:493` and `:520` are two different
Scaffolds. Hot reload does that.

So the fix is persistence, not dismissal handling.

**The change.** Add a process-lifetime singleton in
`lib/dev/dev_tools_bubble.dart` holding the panel's state, following the same
private-constructor plus `static final instance` shape as the dev fixtures in
this directory. Move all seven fields onto it, plus the JOB section flag Task
2 added:
- the position offset
- the expanded flag
- the per-section expand flags

The `State` keeps using `setState` to rebuild. It reads and writes the
singleton's fields inside those `setState` calls. Defaults live on the
singleton, so the panel comes up with the same section defaults it has today
on the first launch of a process.

**Why a plain singleton and not a `ValueNotifier`, which is what the brief
asked for.** A `ValueNotifier` earns its listener plumbing when a second,
independent consumer needs to be told. Here there is exactly one consumer and
it already has `setState`, and there is never a second live instance to
notify: `MobileOverlay` and `DesktopOverlay` are mutually exclusive branches,
so at most one `DevToolsBubble` is mounted at a time. Adding notifier
plumbing with no second listener is an abstraction nobody asked for, which
AGENTS.md forbids by name. Put this reasoning in the singleton's doc comment
so the deviation is visible, and name the condition under which it would be
wrong: if a second bubble is ever mounted alongside the first, this must
become a notifier.

If while doing this you find evidence that two instances CAN be live at once,
stop and use a `ValueNotifier` with `addListener` in `initState` and
`removeListener` in `dispose`, and say so in your report.

**Keep the scope here to exactly those field moves.** Do not refactor
`_buildExpandedPanel` into a widget, do not restyle anything, do not touch the
clamping or drag maths beyond repointing them at the singleton's field.

**Verify the dismissal claim rather than trusting it.** Before you finish,
grep this file and `responsive_overlay.dart` for any dismissal path: a
`TapRegion`, an `onTapOutside`, a `ModalBarrier`, a `GestureDetector` or
`InkWell` wrapping the Stack, a `FocusScope` listener. If one exists, this
analysis missed it and the persistence fix alone will not satisfy Jakub. Say
so EXPLICITLY in your report rather than papering over it. If none exists,
say that too, and say that you checked.

**The runnable check.** Create
`test/dev/dev_tools_bubble_persistence_test.dart`. Pump `DevToolsBubble`
inside a `Stack` under a `MaterialApp` whose `ThemeData` carries a
`GWColors.dark()` extension so the widget's theme lookup resolves. Tap the
collapsed bubble to expand it, confirm the panel is showing, then pump a tree
WITHOUT the bubble so the element is disposed, then pump it back and assert
the panel is still expanded. That is the exact lifecycle a route change puts
it through. Use `addTearDown` to reset the singleton's fields, since they are
process-wide and would leak into the next test.

Fallback, and report it if you use it: if the expanded panel cannot be pumped
in a bare test because one of its buttons needs a provider at BUILD time
rather than at press time, do not fight it and do not add providers to make it
work. Assert the persistence at the singleton level instead, in the same file,
and state in your report which check you ended up with and why.
  </action>

  <verify>
    <automated>flutter test test/dev/dev_tools_bubble_persistence_test.dart</automated>
    <automated>flutter analyze lib/dev</automated>
    <automated>grep -v '^ *//' lib/dev/dev_tools_bubble.dart | grep -c 'expanded = false'</automated>
  </verify>

  <done>
- No panel state is a `State` field any more. Position, expanded, and every
  section flag live on the singleton.
- Exactly one place writes the expanded flag to false: the X button. The last
  grep returns 1.
- The persistence test passes, or the documented fallback is in place and
  named in the report.
- The dismissal-path grep result is stated in the report either way.
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| user picked file to cubit | A path chosen in an OS dialog is read and parsed. Already bounded by an extension filter and a 5 MB length check before the read. |
| dev fixture to shipped build | Fixture values could reach a user if a gate is missed. |
| fixture values to screenshot | Synthetic balances and hashes could be mistaken for real ones by a reviewer. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-elz-01 | Elevation of privilege | DevMockJob branches in SubmitJobCubit | high | mitigate | One gated private getter resolves the scenario, so `kDebugMode && kShowDevTools` is expressed once and cannot be forgotten at an individual branch. Verified by the `kDebugMode` grep in Task 2. |
| T-elz-02 | Spoofing | fixture hashes and balances | medium | mitigate | Every fixture value is deliberately impossible: DEV legible in both hash strings, a counting-sequence cost, a balance nobody holds. Task 2 makes this a stated acceptance criterion, not a preference. |
| T-elz-03 | Tampering | bridgeTokens precondition guard skipped when armed | medium | accept | Accepted and documented at the call site. The guard exists only to protect the two SDK calls the fixture replaces, and the branch is unreachable outside a debug build with the define set. |
| T-elz-04 | Information disclosure | cubit state in BlocObserver logs | low | accept | No key or mnemonic is added to state by this plan. The only new values are a synthetic cost, balance and two synthetic hashes. |
</threat_model>

<verification>
Run all four before reporting. Quote real output. Never claim a baseline you
did not run. Flutter resolves on PATH in this environment at
`/Users/jakub/development/flutter/bin/flutter`.

**Pre-flight, before you change anything**
1. `git branch --show-current` and note it.
2. `flutter test 2>&1 | tail -5` and record the pass and fail counts. This is
   your baseline. AGENTS.md documents a day when the baseline drifted from 187
   to 222 and every agent misread a neighbour's tests as its own regression.
   You cannot attribute a failure without this number.

**After the work**
1. `dart format` on every file you touched.
2. `flutter analyze` on the whole project. It exits non-zero on infos and that
   is intentional. Clean means clean.
3. `flutter test` in full. Compare against your pre-flight baseline and
   account for every delta.
4. `./tool/check_brace_style.sh`
5. `./tool/check_raw_colors.sh`

Do not report until all five pass or you can name exactly which pre-existing
failure you inherited, with the pre-flight number to prove it.
</verification>

<success_criteria>
- Picking a JSON file always produces a visible change in the drawer. There is
  no input that leads to a blank step 1.
- A pricing failure reads as a failure, not as an endless spinner.
- A retry after a failed pick is judged on its own merits.
- With any JOB scenario armed and no native SDK, all five screens can be
  reached in order: choose file, cost, confirm, in flight, result.
- The five scenarios land on five different places.
- The dev panel survives navigation with its open state, its position and its
  open sections intact.
- `flutter analyze`, `flutter test`, `check_brace_style.sh` and
  `check_raw_colors.sh` all pass.
- Nothing is committed, staged, or pushed.
</success_criteria>

<handoff_walk_script>
Include this in your report so Jakub can walk it immediately.

Kill any running instance first. A second instance dies on the Hive container
lock and the symptom is a window where you cannot type. The app binary is
"Genius Wallet.app", with a space.

Run with the define. The dev bubble does not appear without it, on every run:

    flutter run -d macos --dart-define=GW_DEV_TOOLS=true

Then, per scenario:
1. Open the dev bubble, expand JOB, press one of the five buttons.
2. Open "New processing job" from the wallet overview.
3. Choose any JSON file on disk. Any valid JSON works, the fixture prices it.
4. Walk: step 1 shows the filename, step 2 shows cost and balance, Continue,
   step 3 confirms, Confirm and pay, step 4 holds for about 2 seconds, step 5
   is the terminal.
5. Press Clear in the MOCK section to release the fixture, or press another
   JOB button to switch scenario, then re-run from step 2.

Expected stops: the insufficient-funds scenario is SUPPOSED to leave Continue
disabled at step 2 with a shortfall note. That is the screen, not a bug.
</handoff_walk_script>

<output>
Report back in the chat. Do not write a summary file, do not commit.

Your report must state:
- the branch you were on, and the discrepancy with the brief
- the pre-flight test baseline and the post-change numbers
- the result of the dev-panel dismissal-path grep, explicitly, either way
- which persistence check you ended up with in Task 3
- the step 2 "Job cost 0 GNUS" observation from Task 1
- anything you found that this plan got wrong
</output>
