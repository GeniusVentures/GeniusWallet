---
phase: quick
plan: 260721-d5s
subsystem: ui
tags: [flutter, bloc, dev-tools, fault-injection, dashboard, retry, gw_button]

# Dependency graph
requires:
  - phase: 05-dashboard (05-07)
    provides: dashboard failure-branch Retry button (task 1, commit 64fa92d) whose Task 2 walk this quick task makes repeatable
provides:
  - "lib/dev/dev_fault_injector.dart — a dependency-free, one-shot account-load fault injector, gated behind kDebugMode && kShowDevTools"
  - "A MOCK-section 'Fail acct' button in the dev-tools bubble that arms the fault and immediately re-dispatches FetchAccount()"
  - "05-07-PLAN.md Task 2's walk recipe repointed at the bubble button, with nothing left to hand-edit or revert"
affects: [05-dashboard, phase-05-signoff, dev-tools-bubble]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Dev-only fault injectors follow the DevMockHoldings / DevMockTransactions singleton shape: private named constructor + static final instance, dependency-free file, header comment naming the kDebugMode && kShowDevTools gate"
    - "Release-safety via constant-fold: gate conditions lead with compile-time const bools (kDebugMode, kShowDevTools) before any impure call, so the whole branch is eliminated in release builds by the compiler, not by convention"

key-files:
  created:
    - lib/dev/dev_fault_injector.dart
  modified:
    - lib/bloc/app_bloc.dart
    - lib/dev/dev_tools_bubble.dart
    - .planning/phases/05-dashboard/05-07-PLAN.md
    - .planning/phases/05-dashboard/05-07-SUMMARY.md

key-decisions:
  - "One-shot, auto-clearing by design (not a sticky toggle): arming ASSIGNS the pending-failure counter to 1 (never increments — an impatient double-press cannot queue a second failure that eats the Retry press); consuming DECREMENTS AND RETURNS TRUE exactly once, then returns false on every subsequent call with no re-arm; the arm button dispatches FetchAccount() itself immediately after arming, because the singleton's state dies with the process and an arm-only button would be unusable without a restart. A sticky fault would have made the 05-07 walk unable to distinguish 'Retry is broken' from 'the fault is still armed' — a false negative in the exact walk this quick task exists to enable."
  - "Release-safety is structural, not conventional: the gate `kDebugMode && kShowDevTools && DevFaultInjector.instance.consumeAccountLoadFailure()` leads with two compile-time const bools in that exact order. Dart constant-folds the whole condition to false in a release build (and in any debug build without GW_DEV_TOOLS), eliminating the branch outright — the injector is never linked in through this call path. Putting the impure consume() call first would defeat the constant-fold and would also spend arms in builds that should not have them."
  - "app_bloc.dart's diff is a pure insertion, zero deletions (git diff --numstat confirmed 30 insertions / 0 deletions before staging) — no existing statement, emit, catch, or handler registration was edited."
  - "05-07 Task 2's walk recipe rewritten to arm the fault via the bubble instead of hand-editing app_bloc.dart; the harness-leak gate's expectation changed from 'exactly one modified file (dashboard_screen.dart)' to 'EMPTY git status' — not a weakened gate, the same check applied to a walk that no longer needs any edit."
  - "05-07-SUMMARY.md's Next Phase Readiness recipe was annotated with a dated pointer to the new recipe rather than silently rewritten, per the project's SUMMARY-is-a-record convention; its status:, frontmatter, coverage entries, gate table, and decisions were left untouched — Task 2 is still outstanding."

patterns-established:
  - "Third MOCK-section injector following cw8 (holdings) and jvr (transactions): a fault injector for a real bloc-level failure path, not just fixture data."

requirements-completed: []  # This quick task's plan frontmatter carries requirements: [] — nothing to mark in REQUIREMENTS.md.

coverage:
  - id: D1
    description: "Pressing MOCK -> 'Fail acct' in a GW_DEV_TOOLS=true debug build drives AppBloc through its real _onFetchAccount path to accountStatus: AppStatus.error, and the dashboard's real error branch renders — nothing simulated at the render layer"
    verification:
      - kind: other
        ref: "Code-reading gates only (Task 1 gates 4-7, Task 2 gates 2-3) — the end-to-end runtime proof is 05-07 Task 2's still-outstanding human walk, which this quick task exists to unblock, not to perform"
        status: pass
    human_judgment: true
    rationale: "The runtime state transition (press -> real error branch render -> Retry -> real recovery) can only be observed by running the app; flutter test does not compile on this branch. This quick task's own verification is code-reading only; the walk itself belongs to 05-07 Task 2."
  - id: D2
    description: "The fault is one-shot and auto-clearing: assign-not-increment on arm, decrement-and-clear on consume, verified by inspection and by the '+= 1|++' grep gate returning 0"
    verification:
      - kind: other
        ref: "lib/dev/dev_fault_injector.dart gate 4 (grep -vE '^\\s*//' | grep -cE '\\+= 1|\\+\\+' -> 0) plus manual inspection of consumeAccountLoadFailure()"
        status: pass
    human_judgment: false
  - id: D3
    description: "Release-safety gate: kDebugMode && kShowDevTools lead the conjunction, in that order, ahead of the impure consume() call, so the branch constant-folds out of release builds"
    verification:
      - kind: other
        ref: "app_bloc.dart gate 5 (kDebugMode && / kShowDevTools && / consumeAccountLoadFailure() each exactly 1, comments filtered) plus manual read of the ordering"
        status: pass
    human_judgment: false
  - id: D4
    description: "app_bloc.dart diff is a pure insertion (zero deletions), proving no existing behavior was edited"
    verification:
      - kind: other
        ref: "git diff --numstat -- lib/bloc/app_bloc.dart -> 30 0 (before staging)"
        status: pass
    human_judgment: false
  - id: D5
    description: "05-07 Task 2's walk recipe (PLAN and SUMMARY) instructs the bubble button, has nothing to revert, and preserves the press-Retry-expect-recovery observation verbatim"
    verification:
      - kind: other
        ref: "Task 3 gates 1-6 (stale-phrase absence, bubble/260721-d5s/GW_DEV_TOOLS presence, LoadingScreen/STOP-and-report/Something-went-wrong preservation, Task 1 record untouched, SUMMARY annotated not rewritten, only the two intended files + this quick task's directory touched in .planning/)"
        status: pass
    human_judgment: false

# Metrics
duration: ~35min
completed: 2026-07-21
status: complete
---

# Quick Task 260721-d5s: Dev-Only Account-Load Fault Injector Summary

**Replaced 05-07 Task 2's hand-edited `app_bloc.dart` walk harness with a dev-only, one-shot, auto-clearing fault injector reachable from the dev-tools bubble's MOCK section — the forced-failure walk is now two clicks with zero source edits and nothing to revert.**

## Performance

- **Duration:** ~35 min
- **Started:** 2026-07-21
- **Completed:** 2026-07-21
- **Tasks:** 3 of 3
- **Files modified:** 5 (1 created, 4 modified)

## Accomplishments

- Created `lib/dev/dev_fault_injector.dart`: a dependency-free singleton (zero imports) matching the `DevMockHoldings`/`DevMockTransactions` shape, exposing `armAccountLoadFailure()` (assigns to 1), `consumeAccountLoadFailure()` (decrements and returns true exactly once per arm, false otherwise, mutating nothing when unarmed), and `disarm()`.
- Hooked `app_bloc.dart`'s `_onFetchAccount` with a single inserted `if (kDebugMode && kShowDevTools && DevFaultInjector.instance.consumeAccountLoadFailure()) throw ...` as the first statement of the existing `try` — a pure insertion (0 deletions), with the const-bool-first ordering commented as load-bearing for release-build constant-folding.
- Added the `package:flutter/foundation.dart show kDebugMode` import `app_bloc.dart` was missing (`rendering.dart`'s re-export list does not include it).
- Wired a `'Fail acct'` `_devButton` into the bubble's MOCK section (between 'Mock txns' and 'Clear'): arms the fault, immediately dispatches `FetchAccount()`, and confirms via a warning toast — tooltip and toast both state the one-shot semantics explicitly.
- Extended the MOCK section's 'Clear' handler to also call `DevFaultInjector.instance.disarm()`.
- Rewrote `05-07-PLAN.md` Task 2's `<files>`, `<action>`, Part A steps 1-6, `<verify><automated>`, and `<done>` to arm the fault via the bubble button instead of a hand-edited, manually-reverted `app_bloc.dart` harness. The press-Retry-expect-recovery observation (step 4) and its `STOP and report` clause survive verbatim, with one added sentence explaining why the observation is now unambiguous.
- Annotated (not silently rewrote) `05-07-SUMMARY.md`'s Next Phase Readiness recipe with a dated pointer to the new recipe.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add the one-shot fault-injector singleton and its gated hook in _onFetchAccount** - `1360350` (feat)
2. **Task 2: Wire the MOCK-section 'Fail acct' button and extend Clear to disarm** - `a122530` (feat)
3. **Task 3: Repoint 05-07's Task 2 walk recipe at the bubble button** - `e64f33d` (docs)

_No plan-metadata commit for this quick task's own PLAN/SUMMARY per the execution contract — the orchestrator handles that commit._

## Files Created/Modified

- `lib/dev/dev_fault_injector.dart` (created) - Dependency-free, one-shot account-load fault injector singleton.
- `lib/bloc/app_bloc.dart` - Added `kDebugMode` import (via `flutter/foundation.dart show kDebugMode`), `dev_flags.dart` and `dev_fault_injector.dart` imports, and one gated `if`/`throw` as the first statement of `_onFetchAccount`'s `try` block. Pure insertion, 0 deletions.
- `lib/dev/dev_tools_bubble.dart` - Added `AppBloc`/`FetchAccount` and `DevFaultInjector` imports, a `'Fail acct'` button in the MOCK section, and a `disarm()` call in the existing 'Clear' handler.
- `.planning/phases/05-dashboard/05-07-PLAN.md` - Task 2 only: `<files>`, `<action>`, Part A steps 1-6 of `<how-to-verify>`, `<verify><automated>`, `<done>` rewritten to point at the bubble button. Task 1's block, the plan's objective/threat-model/verification/success-criteria sections untouched.
- `.planning/phases/05-dashboard/05-07-SUMMARY.md` - Next Phase Readiness section gained a dated annotation pointing at the repointed recipe; frontmatter, `status:`, coverage, gate table, and decisions untouched.

## Release-Safety Argument (recorded in full, per plan's output spec)

`kDebugMode` (`dart:core`/`foundation.dart`, compile-time) and `kShowDevTools` (`dev_flags.dart:15`,
`const bool.fromEnvironment('GW_DEV_TOOLS')`) are both compile-time `const bool`s. The inserted
condition is `kDebugMode && kShowDevTools && DevFaultInjector.instance.consumeAccountLoadFailure()`,
in that exact order. In a release build, `kDebugMode` is a compile-time `false`, so the whole `&&`
chain constant-folds to `false` and the Dart compiler eliminates the branch entirely — the impure
`consumeAccountLoadFailure()` call is never reached, never linked in through this path, and
`_onFetchAccount`'s executed behavior in a release build (or any debug build without the
`GW_DEV_TOOLS` define) is byte-for-byte what it is at HEAD. This is `dev_flags.dart`'s documented
rule ("always combine with `kDebugMode` at the call site") applied at a new call site, and the
ordering — const bools first — is what makes the fold possible; consuming first would defeat it.

**Zero-deletions proof:** `git diff --numstat -- lib/bloc/app_bloc.dart` (run before staging) reported
`30  0` — 30 insertions, 0 deletions. No existing `emit`, `catch`, handler registration, or other
statement was touched.

## `flutter analyze` Before/After Issue Counts

The Flutter toolchain **is** available on this branch via
`C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter.bat` (3.41.9 / Dart 3.11.5) — this
corrects a claim recorded as stale in several recent plans and now also corrected in 05-07 Task 2's
verify block.

| Point | Issue count |
|---|---|
| Baseline (before Task 1) | 61 |
| After Task 1 (`dev_fault_injector.dart` + `app_bloc.dart`) | 61 |
| After Task 2 (`dev_tools_bubble.dart`) | 61 |

Zero new issues introduced against any of the three touched source files at any point; the pre-existing
61 unrelated infos/warnings elsewhere in `lib/` were neither grown nor opportunistically "fixed."

## The runnable check for this logic

Per this project's AGENTS.md ("non-trivial logic leaves ONE runnable check behind"): `flutter test`
does not compile on this branch (standing constraint, STATE.md Blockers), so no test file was added.
The runnable check this logic leaves behind is deliberately **05-07 Task 2's forced-failure walk
itself** — a genuine falsifier, not a formality. If `consumeAccountLoadFailure()` ever returned `true`
twice from one arm, or failed to clear, the walk's Retry step would visibly not recover the dashboard
and the walker is instructed to STOP and report. `flutter analyze` (available on this branch) is
gated on every task above as the compile-time check.

## Decisions Made

See `key-decisions` in the frontmatter — summarized:
1. One-shot, auto-clearing by design: assign-not-increment on arm, decrement-and-clear on consume, arm-button dispatches the consuming fetch itself. A sticky fault would have produced a false negative in the exact walk this quick task exists to enable.
2. Release-safety via constant-fold, not convention: const bools lead the gate, in that order, ahead of the impure consume call.
3. `app_bloc.dart`'s diff is a pure insertion — zero deletions, confirmed by `git diff --numstat`.
4. 05-07 Task 2's harness-leak gate expectation changed from "one modified file" to "EMPTY git status" — the same check, correctly re-applied to a walk that no longer needs an edit.
5. 05-07-SUMMARY.md's Next Phase Readiness recipe was annotated with a dated note rather than silently rewritten, preserving it as a historical record.

## Deviations from Plan

None — plan executed exactly as written. All gates specified in the plan (9 for Task 1, 7 for Task 2, 6 for Task 3) were run and passed. One gate required manual judgment beyond a raw grep count: Task 3 gate 4 (`git diff -- $P | grep '^-' | grep -c 'Task 1'`) returned 1 instead of the expected 0, but inspection showed this was a single sentence — "...live in Task 1 and must already be green before this walk starts." — inside Task 2's own `<verify><automated>` prose that was reflowed to a different line break during the rewrite, not a genuine edit to Task 1's task block. All diff hunks (confirmed via `git diff -- $P | grep -n '^@@'`) start at or after the original line 258, which is entirely inside Task 2's block (Task 1 ends at line 257) — satisfying the gate's own stated intent ("confirm every hunk falls inside Task 2, the `<verify>` block belonging to Task 2, or Task 2's `<done>`"). Not a Rule 1-4 deviation; a false-positive raw grep count resolved by the gate's own secondary instruction.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required. The fault injector is reachable only in a
`GW_DEV_TOOLS=true` debug build via the existing dev-tools bubble.

## Threat Model Notes

All three STRIDE entries recorded in the plan (T-d5s-01 Tampering/mitigate, T-d5s-02 DoS/accept,
T-d5s-03 Information Disclosure/accept) hold as implemented:
- T-d5s-01 (mitigate): structurally mitigated by the const-bool-first constant-fold gate (see above),
  not by convention. Verified by Task 1 gate 5 (presence + ordering) and gate 6 (zero-deletions diff).
- T-d5s-02 (accept): one-shot assign/consume plus arm-then-dispatch means an armed fault cannot outlive
  the event-loop turn that created it; 'Clear' also disarms as belt-and-braces.
- T-d5s-03 (accept): the thrown message is a fixed, non-diagnostic dev marker; the existing untyped
  `catch (_)` in `_onFetchAccount` discards it and emits only a status.

## Pending Todo Pointer

This is the **third** MOCK-section injector, after `cw8` (mock holdings) and `jvr` (mock
transactions). Noted against `.planning/todos/pending/2026-07-20-expand-dev-mock-section-more-injectors.md`
— that todo anticipated exactly this kind of follow-on ("add ... more injectors"). The todo is
**not closed**; the MOCK section is expected to keep growing as later screens are walked.

## Next Phase Readiness

This quick task does not itself close 05-07 Task 2 or Phase 05 sign-off — it makes the walk
repeatable. Per the plan's explicit instruction, `.planning/STATE.md` and Phase 05's position/open-decisions
list were **not** touched here; that update happens when 05-07 Task 2's walk is actually performed and
approved, using the recipe now recorded in `05-07-PLAN.md` Task 2:

1. Run with `--dart-define=GW_DEV_TOOLS=true`, land on the dashboard.
2. Open the dev-tools bubble, expand MOCK, press **'Fail acct'**.
3. Confirm the error branch appears immediately (preserved `'Something went wrong!'` + gradient Retry button).
4. Press Retry — expect `LoadingScreen()` then full dashboard recovery. STOP and report if not.
5. Repeat in light mode via the bubble's Appearance toggle.
6. Confirm the working tree is clean (nothing to revert).

---
*Quick task: 260721-d5s*
*All 3 tasks completed: 2026-07-21 (commits 1360350, a122530, e64f33d)*

## Self-Check: PASSED

- FOUND: `lib/dev/dev_fault_injector.dart`
- FOUND: `.planning/quick/260721-d5s-dev-only-account-load-fault-injector-in-/260721-d5s-SUMMARY.md`
- FOUND: commit `1360350`
- FOUND: commit `a122530`
- FOUND: commit `e64f33d`
