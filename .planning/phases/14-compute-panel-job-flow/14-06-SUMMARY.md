---
phase: 14-compute-panel-job-flow
plan: 06
subsystem: ui
tags: [dart, flutter, flutter_bloc, drawer, step-flow, submit-job]

# Dependency graph
requires:
  - phase: 14-compute-panel-job-flow
    provides: "SubmitOutcome/bridgeHash/three error channels (14-05) - the state shape this plan renders. This plan is 14-05's stated 'sufficiency' test: whether that shape actually supports the screen rewrite, proven here rather than merely claimed."
  - phase: 14-compute-panel-job-flow
    provides: "GWCopyRow (14-03) - this plan is its third consumer, the fact that justified promoting it out of Phase 23's refusal."
provides:
  - "JobStepList/JobStep (lib/submit_job/view/widgets/job_step_list.dart) - the five-step vertical list shape: completed steps collapse to title+summary and stay on screen, the current step shows its body, later steps show title only."
  - "resolveJobStepIndex, JobFlowBody, JobFlowFooter, and the five step-body widgets (JobChooseFileBody/JobCostBody/JobConfirmBody/JobInFlightBody/JobResultBody) in lib/submit_job/view/widgets/job_steps.dart - the shared flow logic both hosts render."
  - "JobDrawer.show(context, cubit: ...) - the drawer host, taking the SubmitJobCubit as an explicit parameter and wrapping BOTH its body and footer subtrees in BlocProvider.value so a barrier tap can never destroy in-flight state."
  - "submit_job_screen.dart rewritten as the full-screen host rendering the identical JobFlowBody/JobFlowFooter pair inside GWScreen, with the two toast listeners and the reset-before-toast bug deleted."
  - "test/submit_job/job_flow_test.dart - 22 tests: JobStepList's collapse rule, each step body in isolation, all three terminals reachable through a real cubit, the purchase boundary at cost==balance, and the provider-hazard/dismiss-reopen/route-safety behaviors specific to the drawer host."
affects: [14-07, 14-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Two sibling subtrees sharing a ValueNotifier<int>, exactly the shape swap_settings_drawer.dart's _SlippageForm/_ApplyFooter already use - the drawer hands JobStepList's body and the footer CTA to ResponsiveDrawer as two SEPARATE widget slots, so neither can read the other's local State; one notifier written by either half and read by both is what keeps them agreeing."
    - "resolveJobStepIndex(state, manualIndex) as the single index-derivation function both JobFlowBody and JobFlowFooter call - steps 0-2 are user-navigable (manualIndex), steps 3-4 are entirely state-derived and override it. Neither host re-derives this independently."
    - "Both step 2's blocked-variant body AND the step-2 footer's Continue-enabled check read the same resolveSubmitJobCtaState(...) call (from 14-05's pure ladder) rather than each re-computing the condition - the exact duplication that produced submit_job_screen.dart's original off-by-one and zero-cost bugs."

key-files:
  created:
    - lib/submit_job/view/widgets/job_step_list.dart
    - lib/submit_job/view/widgets/job_steps.dart
    - lib/submit_job/view/job_drawer.dart
    - test/submit_job/job_flow_test.dart
  modified:
    - lib/submit_job/view/submit_job_screen.dart

key-decisions:
  - "Step navigation for the three pre-flight steps (choose/cost/confirm) is driven by a caller-owned ValueNotifier<int>, not solely by SubmitJobState - the cubit has no field for 'which of steps 0-2 the user is currently reviewing' (that's a pure UI concern, correctly out of the cubit's fence), so JobFlowBody/JobFlowFooter compose it: manualIndex.clamp(0,2) for steps 0-2, overridden unconditionally by state once isBridgingTokens or a terminal outcome is reached (resolveJobStepIndex). This is why dismissing during Cost/Confirm review and reopening returns to the Cost step rather than exactly where the user left off - a deliberate, low-cost simplification, since nothing irreversible has happened yet at those two steps. Dismissing during the in-flight step or after a result IS state-derived and is proven to survive dismiss/reopen by test."
  - "Auto-advancing from step 0 (Choose) to step 1 (Cost) is done via a BlocConsumer listener keyed on the isFilePickerOpen true->false transition landing with uploadedJson non-empty, not by comparing uploadedJson.isEmpty transitions. The latter would only fire on the FIRST successful pick; re-opening step 0 to pick a different file (uploadedJson already non-empty) would never re-advance past the choose step on a second pick. The isFilePickerOpen-edge condition fires identically on a first pick and a re-pick."
  - "Step 4 (in flight) renders two GWSpinner rows that animate together for the whole isBridgingTokens window, not two independently-sequenced spinners - SubmitJobCubit (plan 05's file, out of this plan's fence) gives no intermediate signal between bridgeOut() completing and requestGeniusSDKProcess() starting; both happen inside one async function with no emit between them. What the plan requires is that the two operations are named as two operations, not collapsed into one spinner - that is satisfied without inventing cubit-side phase tracking this plan isn't authorized to add."
  - "T2's (bridged, not processed) footer renders ONLY a Close button - deliberately overriding 14-UI-SPEC.md:718's 'Try starting the job again' CTA, per this plan's explicit constraint. The parked question (.planning/todos/pending/2026-07-29-can-requestgeniussdkprocess-be-recalled-after-a-successful-bridge.md) is named in a comment directly at that footer's switch case, not just in this SUMMARY, so the next reader who touches that file meets the reasoning in place."
  - "GWStatusDot (14-03) is reused for all three terminal titles' dot+label row rather than hand-rolling a new dot+text Row - it already has the exact neutral-label behavior needed (labelColor omitted -> gw.textPrimary, dot carries only the semantic color)."
  - "JobResultBody's amber helper for T2 duplicates GWWarningNote's light/dark split (a local Color(0xFF92400E) vs GeniusWalletColors.statusWarning) rather than importing a shared token, because no shared appearance-aware gw.statusWarning token exists yet - documented as the same open ceiling GWWarningNote's own doc comment already names (14-UI-SPEC.md §5.3's open item), not a new invention."

requirements-completed: [CMP-04, CMP-05, CMP-06, CMP-10]

coverage:
  - id: D1
    description: "JobStepList renders three step appearances by position relative to currentIndex (done -> title+summary, current -> title+body, pending -> title only), keeps every step's content on screen simultaneously rather than tearing earlier steps down, and is inert (no InkWell, no tap effect) when onTapStep is null."
    requirement: "CMP-10"
    verification:
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart - group 'JobStepList', all 5 tests"
        status: pass
    human_judgment: false
  - id: D2
    description: "Step 1 shows a spinner+line while the picker is open and renders a picker failure inline (never a toast); step 2 renders a neutral working-it-out line at a zero/unpriced cost and a GWWarningNote naming the numeric shortfall when the cost exceeds the balance, sharing resolveSubmitJobCtaState with the footer's enable check; step 4 names the bridge and the job start as two separate operations; the three terminals (done/bridgedNotProcessed/bridgeFailed) render from SubmitOutcome, not from whether a hash string happens to be non-empty, and the bridged-only terminal exposes its hash through GWCopyRow with no button of its own."
    requirement: "CMP-04"
    verification:
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart - groups 'JobChooseFileBody', 'JobCostBody', 'JobInFlightBody', 'JobResultBody', all 9 tests"
        status: pass
    human_judgment: false
  - id: D3
    description: "All three terminals are reachable end to end through a real (fake-backed) SubmitJobCubit and each renders its own distinct content; the bridged-only terminal's footer offers no retry action anywhere in the rendered tree (body or footer); the bridge-failed terminal's footer offers a free retry; a user holding exactly the job cost sees Continue enabled (the <= boundary, from 14-05's ladder, exercised through the widget rather than re-asserted in isolation)."
    requirement: "CMP-06"
    verification:
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart - group 'reaching all three terminals end to end, through a real cubit', all 4 tests"
        status: pass
    human_judgment: false
  - id: D4
    description: "The drawer host (job_drawer.dart) takes the cubit as an explicit parameter, wraps BOTH its body and footer subtrees in BlocProvider.value (the hazard with no precedent anywhere in this repo's ~20 other drawer call sites), creates nothing of its own besides a local step-navigation notifier and therefore disposes nothing else, pops on the root navigator from the caller's captured context, and dismissing/reopening during a landed result shows the same result rather than a reset flow. Closing from the footer dismisses only the drawer, never the route it was opened from."
    requirement: "CMP-10"
    verification:
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart - group 'JobDrawer - the provider hazard with no precedent in this repo', all 3 tests"
        status: pass
    human_judgment: false
  - id: D5
    description: "The full-screen /submit_job route renders the identical JobFlowBody/JobFlowFooter pair the drawer renders, inside GWScreen(maxContentWidth: 640) with the hand-rolled ConstrainedBox/SingleChildScrollView/Align frame deleted; both toast listeners and the reset-before-toast ordering bug (submit_job_screen.dart:48-56 in the shipped code) are gone - resetState is called exactly once in lib/submit_job/view/, from the Close action, after a result has already been shown."
    requirement: "CMP-10"
    verification:
      - kind: unit
        ref: "test/submit_job/job_flow_test.dart - group 'SubmitJobScreen (full-screen host)'"
        status: pass
      - kind: other
        ref: "grep -rn 'resetState' lib/submit_job/view/ - exactly one call site, inside _ResultFooter._close()"
        status: pass
    human_judgment: false

duration: ~90min (not machine-timed at task granularity)
completed: 2026-07-29
status: complete
---

# Phase 14 Plan 06: Job flow step list, five step bodies, and two hosts Summary

**A five-step vertical flow (`JobStepList` + `job_steps.dart`'s `JobFlowBody`/`JobFlowFooter`) renders identically in a drawer (`JobDrawer`, cubit hoisted and explicitly passed in to survive a barrier tap) and the rewritten `/submit_job` full-screen route, replacing the shipped flat form whose result was a toast that erased the screen before showing it.**

## Performance

- **Started:** 2026-07-29T09:58:00Z (session-local; not independently machine-timed)
- **Completed:** 2026-07-29T11:28:49Z
- **Tasks:** 3/3 complete
- **Files created:** 4 (3 lib, 1 test) + this SUMMARY
- **Files modified:** 1 (`submit_job_screen.dart`, full rewrite)

**No commits were created.** `CLAUDE.md`/`AGENTS.md` line 23 ("Do not create commits") is an absolute rule for this session; hard constraint 1 repeats it. All work is left staged only in the working tree - confirmed via `git status --short` before writing this SUMMARY (see "Gates measured myself" below).

## The tree compiles again

At the start of this plan, `flutter analyze` reported 10 errors, all in `submit_job_screen.dart`, from plan 14-05's deliberate deletion of `FilePickerError`/the single error field the old screen read. That file is rewritten from scratch in Task 3. `flutter analyze` (full project, measured after all three tasks) now reports **1 issue total**, and it is `test/account/account_drawer_show_test.dart:27`'s pre-existing `unnecessary_import` info in a concurrently-running agent's file (plan 14-04's territory per this session's hard constraint 2) - not touched by this plan, and present before this plan started.

## Accomplishments

- **`JobStepList`** (`lib/submit_job/view/widgets/job_step_list.dart`) - a plain data class `JobStep` (title/summary/body) plus the list widget. Owns the index badge (pending/current/done, with a checkmark once done), the vertical connector between badges, and the collapse rule. Its class doc comment records the design rationale required by the plan: completed steps stay on screen because step 3 (confirm) needs step 2's (cost) figures still visible while the user confirms spending money step 2 computed - a wizard that tears step 2 down first cannot do that.
- **The five step bodies** (`lib/submit_job/view/widgets/job_steps.dart`): `JobChooseFileBody` (spinner+line while picking, inline file error, nothing otherwise - the footer's button is the choose action), `JobCostBody` (the cost `GWDetailGrid` plus one of the two blocked variants, driven by 14-05's `resolveSubmitJobCtaState` rather than a boolean re-derived here), `JobConfirmBody` (the one-sentence irreversibility line), `JobInFlightBody` (two labelled, simultaneously-spinning operations - see key-decisions for why they can't be sequenced), and `JobResultBody` (the three terminals, switched on `SubmitOutcome`, each with its own dot/note/`GWDetailGrid([GWCopyRow(...)])` combination per `14-UI-SPEC.md` §6.6).
- **`resolveJobStepIndex`**, **`JobFlowBody`**, and **`JobFlowFooter`** (same file) - the shared flow controller both hosts mount. `JobFlowBody` assembles the five `JobStep`s from live `SubmitJobState` and auto-advances from Choose to Cost via a `BlocConsumer` listener keyed on the `isFilePickerOpen` true→false edge (robust to both a first pick and a re-pick from a reopened Choose step). `JobFlowFooter` renders the per-step CTA row, sharing a `ValueNotifier<int>` with `JobFlowBody` across whatever subtree boundary the host imposes - exactly the `swap_settings_drawer.dart` `_SlippageForm`/`_ApplyFooter` pattern, reused because the drawer host hands the body and the footer to `ResponsiveDrawer` as two separate slots that cannot read each other's local state.
- **`JobDrawer`** (`lib/submit_job/view/job_drawer.dart`) - `JobDrawer.show(context, {required SubmitJobCubit cubit})`. Wraps **both** `child` and `footer` in their own `BlocProvider<SubmitJobCubit>.value`, because `ResponsiveDrawer` hands the shell two separate subtrees and wrapping only one leaves the other unable to resolve the cubit - proven by a dedicated test (see below). Creates nothing but its own local step-navigation notifier and disposes only that; the cubit's lifetime stays the caller's, by design, so a barrier tap during the in-flight step cannot destroy it and take the bridge hash with it. Pops on the root navigator from the caller's captured `context`, mirroring `swap_settings_drawer.dart`'s already-shipped fix for the same class of bug.
- **`submit_job_screen.dart` rewritten** as the full-screen host: `GWScreen(maxContentWidth: 640, bottomNavigationBar: JobFlowFooter(...), child: Column([GWPageHeader(...), JobFlowBody(...)]))`, deleting the hand-rolled `ConstrainedBox`/`SingleChildScrollView`/`Align` frame and both toast listeners. The route keeps its own route-scoped cubit instance (`router.dart` untouched).
- **`test/submit_job/job_flow_test.dart`** - 22 tests covering `JobStepList`'s collapse rule, each step body in isolation (including the zero-cost/insufficient-funds split and the two-operations-not-one-spinner requirement), all three terminals reached through a real cubit driven by the same hand-written `GeniusApi`/`FilePickerPlatform` fakes plan 05's test files established, the exactly-affordable boundary, and three drawer-specific behaviors: the provider-resolves-in-both-subtrees hazard, dismiss-and-reopen preserving a landed result, and Close popping only the drawer rather than the route it was opened from.

## Gates measured myself

- **`flutter test test/submit_job/job_flow_test.dart --plain-name "JobStepList"`** (Task 1's own `<verify>` scope - the plan's literal `-n` flag is not recognized by this Flutter version's `flutter test` wrapper; `--plain-name`/`--name` are its equivalents): **5/5 passed**.
- **`flutter test test/submit_job/job_flow_test.dart`** (Task 2's `<verify>` scope, and the whole of this plan's own new test file): **22/22 passed**.
- **`flutter test test/submit_job/ && flutter analyze lib/submit_job/`** (Task 3's exact `<verify>` command): **56/56 tests passed** (22 new + 34 from plans 05's three pre-existing files, all still green), **`flutter analyze lib/submit_job/`: "No issues found!"**.
- **`flutter analyze` (full project)**: **1 issue** - `test/account/account_drawer_show_test.dart:27`, pre-existing, plan 14-04's file, not touched here (see "The tree compiles again" above).
- **`bash tool/check_brace_style.sh --count`**: `0`.
- **`bash tool/check_no_new_key_logging.sh --scan-tree` on all four touched/created lib files**: `OK` for all four.
- **`flutter test test/components/responsive_drawer_body_padding_test.dart`** (this plan's own verification requirement - proves the drawer shell's contract is untouched): **4/4 passed**.
- **`grep -rn "resetState" lib/submit_job/view/`**: exactly one call site, `job_steps.dart`'s `_ResultFooter._close()` - invoked only from the `Close` button on an already-displayed terminal, never before a result is shown.
- **`dart format --set-exit-if-changed`** on all 5 touched/created files: 0 changed (already correctly formatted).
- **Full `flutter test` suite**: **not run**, per this session's hard constraint 3 - `test/account/account_drawer_show_test.dart` hangs for 10 minutes and is plan 14-04's concurrently-in-flight file. `test/submit_job/` (this plan's full scope) and `test/components/responsive_drawer_body_padding_test.dart` (the one cross-cutting file this plan's own `<verification>` names) were run explicitly instead, per instruction.

## Files Created/Modified

- `lib/submit_job/view/widgets/job_step_list.dart` - `JobStepList`, `JobStep`
- `lib/submit_job/view/widgets/job_steps.dart` - `resolveJobStepIndex`, `JobFlowBody`, `JobFlowFooter`, `JobChooseFileBody`, `JobCostBody`, `JobConfirmBody`, `JobInFlightBody`, `JobResultBody`
- `lib/submit_job/view/job_drawer.dart` - `JobDrawer.show(...)`
- `lib/submit_job/view/submit_job_screen.dart` - rewritten as the `GWScreen`-based full-screen host
- `test/submit_job/job_flow_test.dart` - 22 tests

## Decisions Made

See `key-decisions` in the frontmatter for the full list with rationale. The two most load-bearing: (1) step navigation for steps 0-2 is a caller-owned `ValueNotifier<int>` composed with cubit state via `resolveJobStepIndex`, not a field the cubit needs to grow, and (2) T2's footer carries no retry action at all, with the parked backend question named directly in a comment at that footer's code, not only in this document.

## Deviations from Plan

**None beyond what the plan itself specified or explicitly delegated.** Two judgment calls not dictated verbatim by the plan text:

1. **The auto-advance trigger for Choose → Cost** uses the `isFilePickerOpen` true→false edge (with `uploadedJson` non-empty) rather than an `uploadedJson` empty→non-empty transition. The plan specified the *behavior* (advance once a file is accepted) but not the exact signal; the edge chosen is the one that also correctly re-fires on a re-pick from a reopened Choose step, which an empty→non-empty comparison would miss the second time.
2. **`JobChooseFileBody` does not surface `costError`** even in the one edge case where a cost-lookup failure (`jobCost == 0` inside `openFilePicker()`) leaves `uploadedJson` empty and the flow parked on step 0 forever with no visible message. Task 2's `<behavior>` bullet for step 1 is exhaustive about what renders there ("a picker failure renders inline in step 1, not as a toast" - naming only picker failures), and adding a second error surface to that step risked contradicting the plan's literal, tested contract. Left as a known, narrow gap rather than silently patched - noted here per Rule 2's "document instead of guess" fallback, not fixed, since the plan text reads as a deliberate scope line rather than an omission.

## Known Stubs

None. Every step body renders from live `SubmitJobState` fields; there is no hardcoded/placeholder value anywhere in the new code, and every terminal, error, and blocked-variant path is reachable from real cubit state.

## Threat Flags

None beyond what the plan's own `<threat_model>` already names. Verified against the register:

- **T-14-20** (the result step, repudiation) - mitigated: the result is a step that persists until `Close`, `resetState()` runs only at that dismissal (grep-verified, one call site), and both `done`/`bridgedNotProcessed` route their hash through `GWCopyRow`.
- **T-14-21** (drawer dismissal mid-flight, denial of service) - mitigated: `JobDrawer.show` takes the cubit as a parameter and never disposes it; the dismiss-and-reopen test proves a landed result survives a drawer dismissal via the barrier.
- **T-14-22** (a retry on the bridged-only terminal, elevation of privilege) - disposition `transfer`, honored: no retry button exists anywhere in `job_steps.dart`'s T2 branch (body or footer), confirmed by a dedicated test asserting `find.textContaining('Try')` finds nothing in that tree.
- **T-14-23** (step 3's confirmation copy, spoofing) - mitigated: step 3 names the exact amount and irreversibility; step 2's cost grid stays visible above it via `JobStepList`'s own collapse rule.
- **T-14-24** (inline error rendering, information disclosure) - mitigated: every inline error string rendered by this plan's widgets is one of `SubmitJobState`'s three channel values, all originating in plan 05's cubit (which `check_no_new_key_logging.sh` already verified there); nothing new is logged or displayed here beyond those channel values.
- **T-14-SC** (package installs) - no packages installed; every import in this plan's four files resolves to an existing dependency or an in-tree component.

## Issues Encountered

**flutter test's fake-clock timer assertion.** Every test that drives a successful `bridgeTokens()` call through to a `done`/`bridgedNotProcessed` outcome leaves a pending 5-second `Future.delayed` Timer behind (`fetchGnusBalanceWithDelay()`, plan 05's file) - `flutter_test`'s `AutomatedTestWidgetsFlutterBinding` asserts no Timer is left pending when a test ends. Resolved by advancing the fake clock past 5 seconds (`await tester.pump(const Duration(seconds: 6));`) at the end of each such test, letting the timer fire (and its inner `fetchGnusBalance()` call resolve, harmlessly, against the real `CoinService` - visible as benign "Unable to load asset" warnings in test output, not failures) before the test function returns.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- **Plan 14-07** (the compute panel itself) can mount `SubmitJobDashboardButton`-equivalent CTAs that call `JobDrawer.show(context, cubit: ...)` once it creates the `SubmitJobCubit` in the dashboard's own subtree - this plan's `JobDrawer` is ready to consume as-is; nothing here assumes where the cubit is constructed.
- **Plan 14-08** is named in `job_drawer.dart`'s own doc comment as the plan that "mounts it [the cubit] in the dashboard subtree" - confirming the caller-owns-the-cubit contract this plan built against.
- `submit_job_cta_state.dart` (14-05) is now consumed by two call sites in this plan (`JobCostBody` and `JobFlowFooter`'s step-2 branch) reading the identical `resolveSubmitJobCtaState(...)` result, closing the loop 14-05's SUMMARY opened ("Whether the new state shape is actually SUFFICIENT for [this] screen rewrite is provable only when 14-06 consumes it").
- No blockers. The one known, narrow gap (a cost-lookup failure that leaves `uploadedJson` empty has no visible message on step 1) is documented above under Deviations and does not block any of this plan's own success criteria.

## Self-Check

- `[ -f lib/submit_job/view/widgets/job_step_list.dart ]` → FOUND
- `[ -f lib/submit_job/view/widgets/job_steps.dart ]` → FOUND
- `[ -f lib/submit_job/view/job_drawer.dart ]` → FOUND
- `[ -f lib/submit_job/view/submit_job_screen.dart ]` → FOUND
- `[ -f test/submit_job/job_flow_test.dart ]` → FOUND
- `flutter test test/submit_job/` → 56/56 passed (re-confirmed)
- `flutter analyze lib/submit_job/` → "No issues found!" (re-confirmed)
- `bash tool/check_brace_style.sh --count` → `0` (re-confirmed)
- `grep -rn "resetState" lib/submit_job/view/` → exactly one call site, inside `_ResultFooter._close()` (re-confirmed)

## Self-Check: PASSED

---
*Phase: 14-compute-panel-job-flow*
*Plan: 06*
*Completed: 2026-07-29*
