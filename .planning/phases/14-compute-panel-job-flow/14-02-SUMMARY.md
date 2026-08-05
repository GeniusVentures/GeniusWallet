---
phase: 14-compute-panel-job-flow
plan: 02
subsystem: state
tags: [dart, bloc, ffi-polling, state-machine, dev-tools, testing]

# Dependency graph
requires: ["14-01"]
provides:
  - "AppState.processingFeedStatus (ProcessingFeedStatus: neverTicked/live/unavailable) - the compute feed's own health, independent of what the node reports"
  - "AppState.nodeProcessingStatus (NodeProcessingReading: disabled/idle/processing) - the node's tri-state reading, no longer collapsed into a boolean"
  - "AppState.processingCompletedAt - completion timestamp written on the processing-to-not-processing edge"
  - "AppState.initPercentage / AppState.initMessage - the initialization feed, now polled from AppBloc instead of trapped in SGNUSConnectionState's private State"
  - "RetryProcessingStatus event - re-arms _processingTimer after a throw cancelled it"
  - "InitializationStatusTicked event + AppBloc._startInitPolling() - 3s poll of getInitializationStatus(), self-cancelling at completion"
  - "compute_state.dart: NodeProcessingReading, ProcessingFeedReading enums + resolveProcessingFeedReading()/didProcessingJustComplete() pure helpers, backed by test/dashboard/compute_feed_state_test.dart"
  - "DevMockSgnus.initPercentageOverride / .feedUnavailableOverride - make ComputeState.startingUp and ComputeState.unavailable walkable for the first time"
affects: [14-03, 14-04, 14-05, 14-06, 14-07, 14-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Both the success path and the catch path of a polling handler funnel through the same pure derivation function (resolveProcessingFeedReading), so the unavailable/live determination has exactly one implementation"
    - "A second independent Timer + AppEvent (InitializationStatusTicked) added alongside an existing one (ProcessingStatusTicked), each with its own cadence and its own cancellation rule, both torn down in the same close()"

key-files:
  created:
    - test/dashboard/compute_feed_state_test.dart
  modified:
    - lib/bloc/app_state.dart
    - lib/bloc/app_event.dart
    - lib/bloc/app_bloc.dart
    - lib/dev/dev_mock_sgnus.dart
    - lib/dashboard/compute/compute_state.dart

key-decisions:
  - "Task 2 decision 1 (recorded per the plan's own instruction): getInitializationStatus() was used, not getNodeState(). getNodeState() enumerates eight explicit lifecycle values, is already fail-soft through _mapNodeState, and cannot stall at a percentage the way the shipped ring does - but it has zero callers anywhere in lib/ or packages/, so its runtime behaviour is entirely unverified, and verifying it would need a device spike (live node + valid macOS signing profile) that is not a dependency this phase should acquire. getInitializationStatus() has a captured trace (14-RESEARCH.md / sketch 015) showing exactly what it returns. getNodeState() is recorded here as the better long-term source once someone has called it once."
  - "Task 2 decision 2: no connectivity_plus plumbing was added for the disconnected state. 14-RESEARCH.md:713 reads state 09 as device-offline, needing connectivity_plus. The design contract (14-UI-SPEC.md:200,235) resolves it instead from the SGNUS connection stream's own isConnected field, which is already consumed directly in the panel's own file (wallet_overview.dart:172) and already carried on SGNUSConnection (packages/genius_api/lib/models/sgnus_connection.dart:11). Confirmed with `grep -n \"connectivity\" lib/bloc/app_bloc.dart` returning nothing. Adding a connectivity stream would have been dead code."
  - "AppState.nodeProcessingStatus is typed NodeProcessingReading (compute_state.dart's own pure enum), not genius_api's GeniusProcessingStatus. The FFI enum is mapped onto the pure one at the boundary in AppBloc._toNodeProcessingReading. Chosen so compute_state.dart - and the test that pins its derivation rules - stays free of the genius_api/FFI dependency, matching the ComputeDotRole-is-an-enum-not-a-Color house rule 14-01 already established."
  - "ProcessingFeedReading (4-member: unavailable/disabled/idle/processing) is a separate combined enum from ProcessingFeedStatus (3-member: neverTicked/live/unavailable, the actual AppState field type). The combined one exists purely so the throw-wins-regardless-of-last-reading rule and the disabled-vs-idle distinctness rule can be pinned by one function and one small test file, without a bloc harness. AppBloc derives both real AppState fields (processingFeedStatus, nodeProcessingStatus) from it rather than storing it directly."
  - "The initialization poll starts in AppBloc's constructor (right after registering handlers), not inside _onInitializeSDK or _onLoadWallets. Initialization progress does not depend on wallets being loaded, unlike _processingTimer (started from _onLoadWallets); the constructor is the earliest point `api` is available, mirroring sgnus_connection_widget.dart's own start point (didChangeDependencies, i.e. as soon as its dependency exists)."
  - "The dev bubble's two new overrides (initPercentageOverride, feedUnavailableOverride) are consumed inside the existing _onProcessingStatusTicked dev-override branch, exactly as the plan specified, NOT inside the real 3s init-timer handler. This means arming initPercentageOverride only takes visible effect once ProcessingStatusTicked is next dispatched (either by the 1s timer or, in practice, by the dev bubble's own immediate dispatch pattern already documented at that call site) - the real init-timer's own successful reads are unaffected by and can still overwrite a dev override on its own 3s cadence if a live node is also connected. This edge case is out of scope per the plan's literal instruction and is not expected to matter for a dev walk without a live SGNUS node."

requirements-completed: [CMP-01, CMP-10]

coverage:
  - id: D1
    description: "AppState carries three outcomes where app_bloc.dart previously had one boolean: processingFeedStatus (neverTicked/live/unavailable) is set correctly by both the try and catch paths of _onProcessingStatusTicked, is non-nullable with a default (avoiding the copyWith no-op trap), and appears in props."
    requirement: "CMP-01"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_feed_state_test.dart - resolveProcessingFeedReading group"
        status: pass
      - kind: static
        ref: "flutter analyze (repo-wide) - No issues found against my files; the one repo-wide info is in a concurrent agent's file (test/account/account_drawer_show_test.dart), outside this plan's fence"
        status: pass
    human_judgment: false
  - id: D2
    description: "RetryProcessingStatus re-arms _startProcessingPolling() (proven idempotent - cancels before recreating) and clears processingFeedStatus back to neverTicked. The catch block that used to cancel the timer permanently now also flags the feed unavailable in the SAME emit, so a dead feed is no longer pixel-identical to a healthy idle node."
    requirement: "CMP-01"
    verification:
      - kind: static
        ref: "Read of lib/bloc/app_bloc.dart:308-324 (_onRetryProcessingStatus) and :284-305 (catch block) - both present and wired in the constructor's on<> registrations"
        status: pass
    human_judgment: false
  - id: D3
    description: "The initialization percentage and the node's own init message are readable from AppState (initPercentage, initMessage), populated by a 3s self-cancelling poll of getInitializationStatus(), independent of SGNUSConnectionState's private fields."
    requirement: "CMP-10"
    verification:
      - kind: static
        ref: "Read of lib/bloc/app_bloc.dart:326-355 (_startInitPolling, _onInitializationStatusTicked) and lib/bloc/app_state.dart's initPercentage/initMessage fields + props"
        status: pass
    human_judgment: false
  - id: D4
    description: "A job finishing (processing true-to-false) leaves AppState.processingCompletedAt populated; every other transition leaves it untouched (copyWith no-op via null)."
    requirement: "CMP-01"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_feed_state_test.dart - didProcessingJustComplete group (all 4 truth-table cells)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Processing-disabled and processing-idle are distinguishable: AppState.nodeProcessingStatus carries the node's raw tri-state reading via NodeProcessingReading, and resolveProcessingFeedReading maps disabled and idle to different ProcessingFeedReading values - the exact distinction app_bloc.dart:180-182's old `== GENIUS_PR_STATUS_PROCESSING.value` comparison destroyed."
    requirement: "CMP-01"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_feed_state_test.dart - 'the disabled reading and the idle reading map to different results'"
        status: pass
    human_judgment: false
  - id: D6
    description: "DevMockSgnus gained initPercentageOverride and feedUnavailableOverride, both sticky, both consumed in the existing dev-override branch of _onProcessingStatusTicked, both correctly setting processingFeedStatus. Starting-up and status-unavailable are now walkable in a dev build for the first time."
    requirement: "CMP-10"
    verification:
      - kind: static
        ref: "Read of lib/dev/dev_mock_sgnus.dart (new fields/methods) and lib/bloc/app_bloc.dart:199-228 (extended dev-override branch)"
        status: pass
    human_judgment: false

duration: ~50min (not machine-timed at task granularity)
completed: 2026-07-29
status: complete
---

# Phase 14 Plan 02: Compute feed state Summary

**Moved the compute node's truth out of `SGNUSConnectionState`'s private `State` and into `AppBloc`: a three-member feed-health flag replaces the boolean that made a dead feed pixel-identical to an idle node, a tri-state node reading replaces a collapsing `==` comparison, a completion timestamp is written on the processing-to-idle edge, and a new 3s poll surfaces the initialization percentage and message that no sibling widget could previously read.**

## Hard constraints honored

- **No commits, no staging, no git-state mutation.** `CLAUDE.md:23` ("Do not create commits.") is absolute for this session. All five files below remain uncommitted, unstaged changes in the working tree.
- **File ownership fence respected.** Only `lib/bloc/app_bloc.dart`, `lib/bloc/app_state.dart`, `lib/bloc/app_event.dart`, `lib/dev/dev_mock_sgnus.dart`, `lib/dashboard/compute/compute_state.dart`, and the new `test/dashboard/compute_feed_state_test.dart` were touched. Verified via `git status --short` before finishing: every other modified/untracked path belongs to a concurrent plan (14-03's `lib/components/data/`, 14-04's `lib/account/`, the chart agent's `lib/chart/`/`lib/dashboard/home/`/`lib/tokens/token_info_screen.dart`/`lib/components/gw_timeframe_segment.dart`), not to this plan.
- **No new dependencies, no `bloc_test`.** The new state-derivation logic is pinned with plain `test()` cases against pure functions, following 14-01's precedent.
- **No stall detector, no ninth `ComputeState`.** Not touched; `ComputeState` still has exactly eight members, the `ponytail:` comment 14-01 left is untouched.
- **`connectivity_plus` not added.** `grep -n "connectivity" lib/bloc/app_bloc.dart` returns nothing.
- **No em dashes in any text I authored.** Verified with `grep -n "—"` against all five touched files - every hit that remains is pre-existing text I did not write (confirmed by diffing hit line numbers against my edits).

## One gap flagged rather than silently completed: the MOCK buttons

Task 3's action text says "Add the matching MOCK buttons wherever the existing processing mock is exposed" - that control lives in `lib/dev/dev_tools_bubble.dart`. That file is **not** in this plan's `files_modified` frontmatter and **not** in the `YOURS` file-ownership list given in this session's hard constraints, and no other plan in this wave claims it either. Per hard constraint 2 ("Do not read-modify-write anything outside YOURS. If you believe you need to, STOP and say so in your SUMMARY"), I did not touch it.

**What this means concretely:** `DevMockSgnus.initPercentageOverride` and `.feedUnavailableOverride` are fully wired end-to-end on the data side - they exist, are sticky, and are correctly consumed by `AppBloc._onProcessingStatusTicked`'s dev-override branch, which sets `processingFeedStatus` correctly for both. What does **not** exist yet is a UI button to arm them; today they can only be armed by code (e.g. `DevMockSgnus.instance.armFeedUnavailable();` then dispatching a tick), not by a tap in the running app. `ComputeState.startingUp` and `ComputeState.unavailable` are therefore walkable in the sense that the state machinery can produce them, but not yet in the sense of "a person can press a button in `kDebugMode` and see it" - that last wire needs a follow-up touch to `dev_tools_bubble.dart` by whichever plan/agent owns that file next.

## Task-by-task

**Task 1 - Three outcomes where there was one boolean, and a retry that re-arms.**
- `AppState` gained `processingFeedStatus` (`ProcessingFeedStatus`: `neverTicked`/`live`/`unavailable`, non-nullable with a default, documented no-op trap comment), `nodeProcessingStatus` (`NodeProcessingReading`: `disabled`/`idle`/`processing`, non-nullable, `isProcessing` kept unchanged for its other consumers), and `processingCompletedAt` (nullable `DateTime`, write-only through `copyWith`). All three added to the constructor, `copyWith`, and `props`.
- `RetryProcessingStatus` added to `app_event.dart` as an empty class, matching the file's existing no-`Equatable` style.
- `AppBloc._onRetryProcessingStatus` re-arms `_startProcessingPolling()` (idempotent by construction - cancels before recreating) and resets `processingFeedStatus` to `neverTicked`.
- The `catch` block in `_onProcessingStatusTicked` now emits `processingFeedStatus: unavailable` in the SAME emit that cancels `_processingTimer`, closing the bug where a dead feed rendered identically to a healthy idle node.
- The success path now carries `nodeProcessingStatus` through (previously discarded after the `==` comparison), sets `processingFeedStatus: live`, and detects the completion edge (`state.isProcessing` compared BEFORE the emit, per the plan's explicit warning that the previous value is gone after).
- The stale-percentage emit at the old `:184-191` was left inside its `if (isProcessing)` guard, per the plan's instruction not to attempt nulling it there - a comment points at `compute_state.dart`'s `viewForComputeState` as the place that rule is actually enforced.

**Task 2 - Poll the initialization feed, carry the node's own message.**
- A second `Timer` (`_initTimer`) polls `api.getInitializationStatus()` every 3 seconds (matching `sgnus_connection_widget.dart:42`, not `_processingTimer`'s 1000ms), started once from `AppBloc`'s constructor.
- `InitializationStatusTicked` event added, dispatched by the timer, handled by `_onInitializationStatusTicked`, which writes both `initPercentage` and `initMessage` into `AppState`, self-cancels the timer at `percentage >= 1.0`, and swallows read errors (retrying next tick) inside a `try`/`catch` mirroring `sgnus_connection_widget.dart:55-58`.
- `_initTimer` is cancelled in `close()` alongside `_processingTimer`.
- Both of Task 2's required decisions are recorded in `key-decisions` above.

**Task 3 - Dev bubble reach + pinned test.**
- `DevMockSgnus` gained `initPercentageOverride` (`double?`) and `feedUnavailableOverride` (`bool?`), both sticky (matching the existing doc-commented reasoning for `processingOverride`), plus `armInitPercentage`/`clearInitPercentage`/`armFeedUnavailable`/`clearFeedUnavailable` methods mirroring the existing `arm`/`clear` shape.
- Both are consumed inside the existing dev-override branch of `_onProcessingStatusTicked` (extended guard condition, `feedUnavailableOverride` checked first and returns early with `processingFeedStatus: unavailable`; otherwise the existing processing-override path also sets `processingFeedStatus: live` and threads `initPercentage` through).
- Two pure helpers extracted into `compute_state.dart`: `didProcessingJustComplete({wasProcessing, isProcessingNow})` (the completion-edge rule) and `resolveProcessingFeedReading({readThrew, nodeReading})` (the feed-flag rule, returning the new `ProcessingFeedReading` enum). `AppBloc` calls both for real in its success and catch paths rather than duplicating the logic inline - the pure module is the single source of truth for both rules, and the bloc funnels through it.
- `test/dashboard/compute_feed_state_test.dart`: 7 plain `test()` cases covering all 4 cells of the completion-edge truth table (3 named by the plan + the 4th for completeness) and the 3 named feed-flag cases (throw-wins-regardless-of-reading checked against 4 different `nodeReading` values including `null`; disabled-vs-idle distinctness; a healthy `processing` passthrough as a sanity check).

## Measured gates

- **`flutter analyze lib/bloc/`** → `No issues found! (ran in 3.5s)`
- **`flutter analyze lib/dev/ lib/bloc/ lib/dashboard/compute/`** (Task 3's own verify command) → `No issues found! (ran in 3.4s)`
- **`flutter analyze`** (repo-wide, run last) → `1 issue found`: an `unnecessary_import` info in `test/account/account_drawer_show_test.dart:27:8`, which is a concurrent agent's file (14-04's `lib/account/` plan), untouched by me and outside this plan's fence. Zero issues in any file this plan modified.
- **`bash tool/check_brace_style.sh --count`** → `0` (run twice: once immediately after edits, once after the full-suite run below).
- **`flutter test test/dashboard/compute_feed_state_test.dart`** → **7/7 passed.**
- **`flutter test test/dashboard/`** (scoped directory, per this plan's own file scope) → **243/243 passed** - exactly 236 (14-01's own scoped-directory count) + 7 (this plan's new file), confirming no other agent had landed a `test/dashboard/` file at the moment of this run and my addition is exactly accounted for.
- **`grep -n "connectivity" lib/bloc/app_bloc.dart`** → no output (exit 1), confirming the disconnected-state decision was honored.
- **`flutter test`** (full suite, run once at the end) → **570/570 passed, 0 failed.** This is higher than 14-01's 517/535 baseline, entirely expected and NOT a regression - hard constraint 3 says to treat a higher count as concurrent agents' work. The four other wave-2/wave-3 agents (13-04 account, 13-03 data components, 13-05 submit_job, plus the standing chart-restyle agent) have all been landing test files into the same tree throughout this session, visible in `git status --short` above.

## Deviations from Plan

**1. [Scope boundary, not Rule 1-4] `dev_tools_bubble.dart` MOCK buttons not added.** See "One gap flagged rather than silently completed" above. This is not a bug fix, missing-functionality fix, blocker fix, or architectural change under Rules 1-4 - it is a file-ownership fence conflict between the plan's task prose and this session's explicit hard constraints. The hard constraints (and the hard-coded hazard of two agents racing on `dev_tools_bubble.dart`) take precedence. Flagged here per the instruction to stop and say so rather than silently completing or silently skipping.

No other deviations. Every other instruction in Tasks 1-3 was followed literally, including the exact 3s/1000ms interval distinction, the exact ordering of the completion-edge comparison relative to the emit, and both of Task 2's recorded decisions.

## Known Stubs

None. Every new field is populated by real logic (either a real FFI read or a documented, gated dev override); nothing renders a hardcoded empty/placeholder value to a user. There is still no UI consumer of these new `AppState` fields (that is plans 06-08's job per `14-CONTEXT.md`'s component list), so nothing here can yet be user-visible in either direction.

## Threat Flags

None beyond the plan's own `<threat_model>`, all of which were honored as designed:
- **T-14-04** (DoS via `_processingTimer` after a throw) - the cancel-on-throw behavior is unchanged; `RetryProcessingStatus` is the new, explicit way back, verified present and wired.
- **T-14-05** (DoS via the new 3s poll) - self-cancels at completion (`percentage >= 1.0`), cancelled in `close()`, wrapped in `try`/`catch`. All three verified in the code above.
- **T-14-06** (spoofing via `DevMockSgnus`) - the extended dev-override branch is still gated behind the same `kDebugMode && kShowDevTools` compile-time condition as the pre-existing override; no new gate was needed or added.
- **T-14-07** (repudiation via the unavailable flag) - this is the plan's headline fix; verified present in both the catch path and the retry path.
- **T-14-SC** (dependency tampering) - no packages installed; `pubspec.yaml`/`pubspec.lock` untouched (not in `git status --short` above).

## Issues Encountered

None beyond the file-ownership gap already documented above.

## User Setup Required

None.

## Next Phase Readiness

- `AppState` now carries everything Task 1's `must_haves.artifacts` list required: `processingFeedStatus`, `nodeProcessingStatus`, `processingCompletedAt`, `initPercentage`, `initMessage` are all readable from anywhere `AppBloc` is in scope, including a drawer pushed on the root navigator (per the plan's `key_links` note that `AppBloc` sits above `MaterialApp.router`).
- Plans 06-08 (the panel widget wiring `resolveComputeState`/`viewForComputeState` to this new state) can consume these fields directly - `nodeProcessingStatus` is not yet threaded into `resolveComputeState`'s signature (that resolver's inputs are unchanged from 14-01), which is expected: this plan's job was making the data exist and be correct, not wiring the resolver call site.
- **Follow-up needed:** whichever plan next touches `lib/dev/dev_tools_bubble.dart` should add two MOCK buttons calling `DevMockSgnus.instance.armInitPercentage(...)`/`.clearInitPercentage()` and `.armFeedUnavailable()`/`.clearFeedUnavailable()`, following the existing processing-mock button's pattern exactly, so `ComputeState.startingUp` and `ComputeState.unavailable` become walkable by hand, not just by code.
- No blockers for 14-03/04/05 (different files entirely) or for 14-06/07/08 (this plan's whole purpose was to unblock them).

## Self-Check

- `[ -f test/dashboard/compute_feed_state_test.dart ]` → FOUND
- `grep -n "class RetryProcessingStatus" lib/bloc/app_event.dart` → FOUND (`class RetryProcessingStatus extends AppEvent {}`)
- `grep -n "class InitializationStatusTicked" lib/bloc/app_event.dart` → FOUND
- `grep -n "processingFeedStatus" lib/bloc/app_state.dart` → FOUND (field, constructor param, copyWith param+body, props entry)
- `grep -n "initPercentageOverride\|feedUnavailableOverride" lib/dev/dev_mock_sgnus.dart` → FOUND (both fields + arm/clear methods)
- `flutter test test/dashboard/compute_feed_state_test.dart` → 7/7 passed (re-confirmed)
- `flutter analyze lib/bloc/ lib/dev/ lib/dashboard/compute/` → No issues found (re-confirmed)
- `bash tool/check_brace_style.sh --count` → `0` (re-confirmed)
- `git status --short` → only the six files this plan owns are modified/created by me; every other entry belongs to a concurrent agent

## Self-Check: PASSED

---
*Phase: 14-compute-panel-job-flow*
*Plan: 02*
*Completed: 2026-07-29*
