---
phase: 14-compute-panel-job-flow
plan: 01
subsystem: ui
tags: [dart, pure-function, state-machine, dashboard, testing]

# Dependency graph
requires: []
provides:
  - "resolveComputeState(...) - pure Dart resolver returning one of eight ComputeState members from plain values, with a documented, tested precedence ladder"
  - "viewForComputeState(...) - pure Dart view-model builder (ComputeStatusView) carrying dot role, label, sub-line, link, bar, trailing and CTA-enabled state"
  - "ComputeDotRole, ComputeLink (with .label copy accessor) enums"
  - "jobCompleteWindow (60s) and startingUpFallbackMessage constants"
  - "test/dashboard/compute_state_test.dart - the precedence ladder, the four precedence cases, the emptiness guard, the stale-percentage trap, the scale test"
  - "test/dashboard/compute_state_distinct_test.dart - the pairwise-distinctness guard over ComputeState.values, plus the unavailable-vs-ready named assertion"
  - "The measured phase baseline (analyze/brace/test) that plans 02-08 read from this SUMMARY"
affects: [14-02, 14-03, 14-04, 14-05, 14-06, 14-07, 14-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Pure-Dart state resolver + plain view model split (no Flutter import), modelled on lib/dashboard/bridge/bridge_cta_state.dart"
    - "Enum-not-Color for semantic roles, colour mapping deferred to the call site where GWColors is in scope"

key-files:
  created:
    - lib/dashboard/compute/compute_state.dart
    - test/dashboard/compute_state_test.dart
    - test/dashboard/compute_state_distinct_test.dart
    - .planning/phases/14-compute-panel-job-flow/14-01-SUMMARY.md
  modified: []

key-decisions:
  - "Dot role mapping (not specified by the plan's copy contract, which only binds label/sub/link): neutral=noWallet, error=disconnected, warning=notLinked, error=unavailable, brand=startingUp, brand=processing, success=jobComplete, success=ready. unavailable and ready deliberately land on different roles (error vs success) to satisfy the pairwise-distinctness requirement on that specific pair."
  - "ctaEnabled is true only for ComputeState.ready. Not specified by Task 2's behavior bullets; chosen because every other state either has nothing selected, nothing linked, an unreachable node, or a job already in flight. Plan 07/08 can override at the call site if product wants job-complete to also allow a new submission."
  - "Trailing percentage text is emitted whenever a bar renders (startingUp and processing both get a '{pct}%' trailing), per Task 2's literal text: 'the trailing percentage is emitted under the same predicate' as showBar. 14-UI-SPEC.md's copy table (7.1) only lists a trailing value for row 06 (Processing); row 03 (Starting up) has none. Followed the PLAN.md task text over the older UI-SPEC table, since the PLAN.md is this phase's contract and post-dates the pure-function split. Flagged here in case a later plan wants startingUp's percentage suppressed."
  - "startingUpFallbackMessage = 'Preparing the compute node' - no fallback string existed in the copy contract (14-UI-SPEC.md open item 8 says the SDK's real message has never been seen). Chosen to match the panel's 'Compute node' kicker terminology; free to change once the real message is seen on device."
  - "jobCompleteWindow boundary is inclusive (<=) - a job finishing exactly 60s ago still reads as job-complete, not ready. Chosen for determinism over the tie itself, since a job status flipping on a >= vs <= choice at the literal instant is not user-observable."
  - "selectedWalletAddress is a non-nullable String (not String?) - hasSelectedWallet already carries the 'no wallet' signal (its own top rung), so the address parameter never needs to be null in a well-formed call; callers pass '' only when hasSelectedWallet is false, which the noWallet rung intercepts before the address is ever read."

patterns-established:
  - "Precedence ladder as a straight-line if-cascade, one guarded if per rung, top wins, each rung's doc comment on the enum member (not just the resolver) states why it outranks the rung below when that ordering closes a real bug."
  - "Distinctness test iterates EnumType.values rather than a hand-written list, so it self-enforces against any future member (including an un-parked ninth ComputeState) without editing the test."

requirements-completed: [CMP-07, CMP-10]

coverage:
  - id: D1
    description: "Pure resolveComputeState() returns one of eight ComputeState values from plain inputs, enforcing the documented precedence (no wallet > disconnected > not linked > unavailable > starting up > processing > job complete > ready), including the disconnected-over-not-linked false-accusation fix and the empty-wallet-address emptiness guard."
    requirement: "CMP-07"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_state_test.dart - all groups"
        status: pass
    human_judgment: false
  - id: D2
    description: "viewForComputeState() derives showBar/barValue/trailing purely from the resolved state (never from a leftover percentage), normalises both percentage feeds (0-1 and 0-100 scale) into one 0.0-1.0 bar value, and the eight rendered tuples are pairwise distinct with unavailable and ready differing on dot role, label AND sub-line."
    requirement: "CMP-10"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_state_test.dart#viewForComputeState — the stale-percentage trap"
        status: pass
      - kind: unit
        ref: "test/dashboard/compute_state_test.dart#viewForComputeState — the scale test"
        status: pass
      - kind: unit
        ref: "test/dashboard/compute_state_distinct_test.dart - both tests"
        status: pass
    human_judgment: false

duration: ~35min (not machine-timed at task granularity; only the completion timestamp below is a real capture)
completed: 2026-07-29
status: complete
---

# Phase 14 Plan 01: Compute state resolver Summary

**Pure Dart `resolveComputeState`/`viewForComputeState` pair (no Flutter import) resolving eight compute-node states from plain values under a documented precedence, backed by 20 unit tests including a pairwise-distinctness guard that iterates the enum.**

## Performance

- **Completed:** 2026-07-29T10:20:47Z
- **Tasks:** 3/3 complete
- **Files created:** 4 (compute_state.dart, 2 test files, this SUMMARY)
- **Files modified:** 0

**No commits were created.** `CLAUDE.md`/`AGENTS.md` line 23 ("Do not create commits") is an absolute project rule that overrides the GSD executor's normal atomic-commit-per-task contract for this session. All work is left staged only in the working tree (`git status --short` below). This also means the two hard constraints about the concurrently-running chart-restyle agent were respected by construction: this plan never touched `lib/chart/`, `lib/dashboard/chart/`, `lib/dashboard/home/view/dashboard_screen.dart`, or `lib/tokens/token_info_screen.dart`.

## Phase baseline (Task 1) - measured, not quoted from a document

Measured myself, in order, before writing any code:

1. **`flutter analyze`** → `No issues found! (ran in 11.6s)` — clean.
2. **`bash tool/check_brace_style.sh --count`** → `0`.
3. **`flutter test`** (full suite) → **517 tests passed, 0 failed.** Tail of the run: `+517: All tests passed!`. No failing test names to record — the suite was fully green at the moment I measured it.

This **matches** the orchestrator-provided shared baseline of "517 pass / 0 fail at `8ed02e78`" exactly — the parallel chart-restyle agent had not yet landed a net-new test at the moment this baseline was taken. Any later plan in this phase that measures a different (higher) count is seeing that agent's work land, not a regression.

**Two facts recorded rather than assumed, per Task 1's instruction:**

- The working tree was **not clean** at baseline time. `git status --porcelain` showed:
  ```
   M .planning/sketches/MANIFEST.md
   M lib/components/scaffold/gw_page_header.dart
   M lib/tokens/token_info_screen.dart
  ?? (various untracked .planning/ and test/components/ files from prior sketch/handoff sessions)
  ```
  `lib/components/scaffold/gw_page_header.dart` and `lib/tokens/token_info_screen.dart` are the two files the plan named as pre-existing dirt. `test/components/gw_page_header_subtitle_gap_test.dart` — the previously-known standing-failure test for the component `gw_page_header.dart` touches — was **green** in this run (it is one of the 517 passing tests), so its historical failure is not currently reproducing; this is a change worth noting, not a coincidence, since the file that test exercises is mid-edit.
- I did **not** carry in the `+515 -1` figure from `14-RESEARCH.md:1144` or the stale `187` in `test/boot_sequence_test.dart:11`. The number that governs this phase is the **517/0** I measured myself, above.

**Neither dirty file was touched by this plan** — Task 2 and Task 3 only created new files under `lib/dashboard/compute/` and `test/dashboard/`.

## Task-by-task gates (Tasks 2 and 3)

- **`flutter analyze lib/dashboard/compute/compute_state.dart`** → `No issues found!`
- **`grep -c "import 'package:flutter" lib/dashboard/compute/compute_state.dart`** → `0` — confirmed pure Dart, no Flutter import at all.
- **`bash tool/check_brace_style.sh --count`** (re-run after Task 2) → `0`.
- **`flutter test test/dashboard/compute_state_test.dart test/dashboard/compute_state_distinct_test.dart`** → **18/18 passed** (16 in the precedence file, 2 in the distinctness file).
- **`flutter test test/dashboard/`** (scoped directory run, per this plan's own `<verification>` section) → **236/236 passed**, including both new files alongside the existing bridge/transaction dashboard tests.
- **`flutter test test/freeze_rule_test.dart`** → **1/1 passed** — the new pure-Dart file sits inside the scanned `lib/dashboard` directory and passes trivially (no `AutoSizeText`/`FittedBox`, no widgets at all).
- **Full-suite re-run of `flutter analyze` and `bash tool/check_brace_style.sh --count`** after all three tasks → clean / `0`, unchanged from baseline.

I did not re-run the FULL `flutter test` suite a second time after adding the new files (only the scoped runs above), per this session's hard constraint 3 — the shared baseline is moving under a concurrent agent, and a second full-suite run risks misattributing that agent's in-flight test additions as this plan's own delta. The scoped runs above are sufficient evidence that this plan's own two new files, plus everything else under `test/dashboard/`, are green.

## Accomplishments

- `ComputeState` enum: exactly eight members (`noWallet`, `disconnected`, `notLinked`, `unavailable`, `startingUp`, `processing`, `jobComplete`, `ready`), declared in precedence order, with a `ponytail:` comment at the enum documenting why State 04 (Stalled) has no ninth member and naming the parked todo file as the upgrade path.
- `resolveComputeState({...})` implements the exact eight-rung precedence from the plan, with the disconnected-over-not-linked rung documented and tested against the real bug at `wallet_overview.dart:179`, and the new emptiness guard (a connected node with an empty wallet address never falsely reads as not-linked).
- `ComputeDotRole` (`neutral`, `warning`, `success`, `brand`, `error`) — an enum, never a `Color`, per the `bridge_cta_state.dart` house rule cited in the plan.
- `ComputeLink` (`none`, `chooseWallet`, `switchWallet`, `seeNodeStatus`, `retry`) with a `.label` getter bound to the copy contract (`14-UI-SPEC.md:775-783`).
- `ComputeStatusView` plain data class + `viewForComputeState(...)`: derives `showBar`/`barValue`/`trailing` purely from the resolved `ComputeState` (never from a leftover percentage), normalises the two native percentage scales (init 0.0-1.0, processing 0.0-100.0) into one 0.0-1.0 bar value inside the function, and derives `showBalanceFiatSubline` as the exact negation of `showBar`.
- `test/dashboard/compute_state_test.dart`: one test per rung (8), the four named precedence cases from Task 3 (disconnected-over-not-linked, unavailable-over-ready, unavailable-over-starting-up, job-complete-decays-to-ready both sides of the boundary), the emptiness-guard test, the stale-percentage-trap test (named and tied to `app_bloc.dart:184-191`), and the scale test (0.525 both ways).
- `test/dashboard/compute_state_distinct_test.dart`: builds the view model for every `ComputeState.values` member and asserts the five-field perceptual tuple is pairwise distinct across all eight, plus the standalone assertion that `unavailable` and `ready` differ on dot role, label AND sub-line (not merely one of them) — the specific pair `sgnus_connection_widget.dart:125-127` currently renders identically.

## Task Commits

**None.** Per `CLAUDE.md` line 23 and this session's hard constraint 1, no commits, staging, or any git-state mutation was performed. All four created files remain as uncommitted, unstaged changes in the working tree for the orchestrator/user to commit.

## Files Created

- `lib/dashboard/compute/compute_state.dart` - the pure resolver, view model and supporting enums/constants
- `test/dashboard/compute_state_test.dart` - precedence ladder, four precedence cases, emptiness guard, stale-percentage trap, scale test
- `test/dashboard/compute_state_distinct_test.dart` - pairwise-distinctness guard + unavailable-vs-ready named assertion
- `.planning/phases/14-compute-panel-job-flow/14-01-SUMMARY.md` - this file

## Decisions Made

See `key-decisions` in the frontmatter for the full list with rationale. Summary: the plan's `<behavior>` bullets and precedence rungs are fully specified and were followed literally; six smaller choices (dot-role-to-state mapping, CTA-enabled predicate, trailing-percentage-on-startingUp, the fallback SDK message string, the job-complete window's boundary inclusivity, and `selectedWalletAddress`'s non-nullability) were left open by the plan and resolved here with reasoning recorded so plans 02-08 inherit a settled contract rather than an ambiguous one.

## Deviations from Plan

None - Rules 1-4 were never triggered. Nothing in the plan's tasks was broken, missing, blocking, or architecturally insufficient; the six items above are original-design choices the plan explicitly delegated to this task ("the plan cannot invent an answer" for several of these, per `14-UI-SPEC.md` section 9's "genuine gaps, not invented answers" framing), not fixes to something wrong.

## Known Stubs

None. Every field the view model exposes is derived from real logic, not a hardcoded placeholder; there is no UI consumer of this module yet (that is plans 02-08's job), so there is nothing here that could render an empty/mock value to a user.

## Threat Flags

None beyond what the plan's own `<threat_model>` already names. Verified against the register:

- **T-14-01** (percentage tampering) — `barValue` is clamped to `0.0-1.0` in both the `startingUp` and `processing` branches of `viewForComputeState`, so an out-of-range or wrongly-scaled FFI reading cannot drive a bar past its track or render a hundred-times-too-large percentage.
- **T-14-02** (disconnected-over-not-linked repudiation) — pinned by the named precedence test `1. disconnected outranks not-linked...` in `compute_state_test.dart`.
- **T-14-03** (info disclosure via the starting-up sub-line) — confirmed no wallet address, key material or file path is interpolated into any string in this module; the sub-line is either the SDK's own message verbatim or the static fallback constant.
- **T-14-SC** (package installs) — no packages were installed; this plan used only Dart stdlib and existing test tooling.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `resolveComputeState` and `viewForComputeState` are a settled, fully-tested pure contract. Plans 02-08 (the panel widget, the job drawer, height-budget and contrast tests) can consume `ComputeState`/`ComputeStatusView` directly without any widget-pump or bloc-harness testing of the state logic itself.
- The measured 517/0 baseline above is the number every later plan in this phase should read, per this plan's own charter as the phase's baseline-of-record.
- Six design decisions (see above) are recorded but not locked by a checkpoint — if a later plan's UI-SPEC reading disagrees (particularly on whether `startingUp` should show a trailing percentage, or whether the CTA should also enable during `jobComplete`), that is a cheap, contained change confined to `viewForComputeState`'s switch statement, not a resolver rewrite.
- No blockers. The two dirty pre-existing files (`gw_page_header.dart`, `token_info_screen.dart`) remain untouched and unrelated to this plan's scope.

## Self-Check

- `[ -f lib/dashboard/compute/compute_state.dart ]` → FOUND
- `[ -f test/dashboard/compute_state_test.dart ]` → FOUND
- `[ -f test/dashboard/compute_state_distinct_test.dart ]` → FOUND
- `grep -c "import 'package:flutter" lib/dashboard/compute/compute_state.dart` → `0` (confirmed pure Dart)
- `flutter test test/dashboard/compute_state_test.dart test/dashboard/compute_state_distinct_test.dart` → 18/18 passed (re-confirmed)

## Self-Check: PASSED

---
*Phase: 14-compute-panel-job-flow*
*Plan: 01*
*Completed: 2026-07-29*
