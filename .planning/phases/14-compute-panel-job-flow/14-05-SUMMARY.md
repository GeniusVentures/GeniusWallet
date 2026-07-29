---
phase: 14-compute-panel-job-flow
plan: 05
subsystem: state-management
tags: [dart, flutter_bloc, cubit, pure-function, state-machine, testing]

# Dependency graph
requires:
  - phase: 14-compute-panel-job-flow
    provides: "ComputeState/ComputeStatusView pure resolver (14-01) - not consumed directly by this plan, but 14-01's SUMMARY set the phase's measured test baseline this plan's own baseline is read against."
provides:
  - "SubmitOutcome enum (notSubmitted/done/bridgedNotProcessed/bridgeFailed) - the discriminator that lets plan 06 render three terminal states from three code branches, one to one"
  - "SubmitJobState.bridgeHash - the burned-token hash, now preserved on the bridged-but-not-processed branch instead of being dropped"
  - "SubmitJobState split into three error channels (fileError/costError/submitError) replacing the single FilePickerError-wrapped field"
  - "SubmitJobCubit.bridgeTokens() passes the underlying gas-shortfall reason through to costError instead of a generic replacement"
  - "A 5 MB file-size cap in openFilePicker(), checked before the file is read into memory"
  - "Every emit in SubmitJobCubit guarded with isClosed"
  - "lib/submit_job/submit_job_cta_state.dart - pure Dart purchase-ladder resolver (SubmitJobCtaState, resolveSubmitJobCtaState, submitJobShortfall, submitJobCtaLabel, submitJobCtaEnabled), fixing the off-by-one (`<` -> `<=`) and the zero-cost/insufficient-funds conflation"
  - "test/submit_job/{submit_job_outcome_test,submit_job_errors_test,submit_job_cta_state_test}.dart - 35 tests, including a hand-written GeniusApi fake (noSuchMethod-forward) and a FilePickerPlatform fake (the package's own DI seam) so the cubit is driven through plain await + state assertions with no mock framework"
affects: [14-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Hand-written GeniusApi test double via `implements GeniusApi` + a `noSuchMethod` forward to super - NOT extending the real GeniusApi, whose constructor eagerly dlopens the native SuperGenius framework and crashes in flutter test's host environment before a single test runs. This is generic Dart (the language's abstract-member-forwarding rule for a class that overrides noSuchMethod), not a mockito import."
    - "FilePickerPlatform.instance swap (the file_picker package's own documented DI seam - extends FilePickerPlatform, override pickFiles) to drive openFilePicker()'s full branch set deterministically, instead of touching the platform channel or leaving the real (unmocked) plugin to throw MissingPluginException."
    - "Cubit-under-test seeded via a same-file test subclass calling the protected `emit` in its constructor body (SubmitJobCubit/GnusCubit) - the house alternative to bloc_test (absent from pubspec.yaml) for pre-loading state a public method can't otherwise reach."
    - "Pure-Dart CTA ladder module (enum + resolver + label + enabled predicate), same shape as lib/dashboard/bridge/bridge_cta_state.dart, doc comment pointing at the sibling test that pins the boundary this module now matches."

key-files:
  created:
    - lib/submit_job/submit_job_cta_state.dart
    - test/submit_job/submit_job_outcome_test.dart
    - test/submit_job/submit_job_errors_test.dart
    - test/submit_job/submit_job_cta_state_test.dart
    - .planning/phases/14-compute-panel-job-flow/14-05-SUMMARY.md
  modified:
    - lib/submit_job/cubit/submit_job_state.dart
    - lib/submit_job/cubit/submit_job_cubit.dart

key-decisions:
  - "SubmitOutcome and bridgeHash are separate fields from the pre-existing txHash, not a reuse - submit_job_screen.dart:48 treats a non-empty txHash as proof of success; writing the burned hash there without a discriminator would raise a success toast on a failed job. This was explicit in the plan and is the single most load-bearing decision in this plan."
  - "The three error channels are named fileError/costError/submitError (not filePickerError/processErrorMessage kept as-is) - chosen because 14-06 (next wave, depends on this plan) consumes this exact contract, and the plan explicitly says the old FilePickerError wrapper class must be deleted (no equality override, so the screen's listenWhen guard fired on every emit including the empty reset)."
  - "submitError absorbs bridgeTokens()'s :176 guard-failure message (previously written directly into filePickerError, bypassing the setter) alongside the pre-existing :199/:214 process-error origins - matches the plan's explicit routing table exactly."
  - "The gas-shortfall passthrough is a one-line change (resp.errorMessage, falling back to the generic line only when empty) - hasEnoughFundsForGas already runs at web3.dart:390 and already produces a specific message; nothing new was built, the message was simply being discarded at the old single-field setFilePickerError call."
  - "File-size cap set at 5 MB, checked via file.length() before file.readAsString() - a round number with no measured job-file corpus to calibrate against; documented as a ponytail (remaining exposure: the parse itself still runs synchronously on the UI isolate; upgrade path is parsing off-isolate)."
  - "submitJobCtaLabel/submitJobShortfall take shortfall as an explicit parameter (mirroring bridge_cta_state.dart's `symbol` parameter) rather than folding balance/cost into the label function - keeps the resolver and the label function each single-purpose and independently testable."
  - "The comparison boundary (`roundedCost > roundedBalance` for insufficientFunds, else ready) rounds both jobCost (int) and gnusBalance (double) to 4 decimal places before comparing - a ponytail marking the ceiling (a fixed-precision compare, not a comparison in the token's smallest unit) and the upgrade path (compare in wei/minions once that value reaches this module)."
  - "costUnknown is checked BEFORE costError in resolveSubmitJobCtaState's precedence (matching the plan's literal precedence list) - a job that has never been priced (jobCost == 0) reads as costUnknown even if a stale costError string happens to be present, since in the real cubit flow those two conditions are mutually exclusive by construction (a cost-lookup failure never advances jobCost past 0, and openFilePicker never sets uploadedJson on that path either, so noFileChosen would win first in practice)."

requirements-completed: [CMP-04, CMP-05, CMP-06, CMP-09, CMP-10]

coverage:
  - id: D1
    description: "The bridged-but-not-processed outcome exists as a distinct SubmitOutcome member, carries the burned-token hash in a separate bridgeHash field (never in txHash), and the bridge-fails/bridge-and-process-both-succeed branches are also fully represented - closing the unrecoverable-hash defect this phase exists to fix."
    requirement: "CMP-04"
    verification:
      - kind: unit
        ref: "test/submit_job/submit_job_outcome_test.dart - all 5 tests"
        status: pass
    human_judgment: false
  - id: D2
    description: "The single filePickerError/processErrorMessage surface is split into three channels (fileError/costError/submitError) matching what the UI must do with each; all nine original call-site origins are routed correctly, the gas-estimate failure's real reason reaches costError instead of a generic replacement, oversized files are refused before being read, and every emit in the cubit is guarded against a closed cubit."
    requirement: "CMP-05"
    verification:
      - kind: unit
        ref: "test/submit_job/submit_job_errors_test.dart - all 15 tests"
        status: pass
    human_judgment: false
  - id: D3
    description: "SubmitJobCtaState resolves 6 rungs in a documented precedence; a user holding exactly the job cost can buy (the `<` -> `<=` fix); a job with jobCost == 0 never reads as insufficient funds; the shortfall is exposed as a printable number; exactly one rung enables the CTA (exhaustive-enum guard)."
    requirement: "CMP-06"
    verification:
      - kind: unit
        ref: "test/submit_job/submit_job_cta_state_test.dart - all 16 tests"
        status: pass
    human_judgment: false
  - id: D4
    description: "No method on SubmitJobCubit re-runs requestGeniusSDKProcess after a successful bridge - the bridged-but-not-processed outcome ships informational-only, per the locked decision that the native re-call safety question is parked."
    requirement: "CMP-09"
    verification:
      - kind: other
        ref: "grep -n 'requestGeniusSDKProcess' lib/submit_job/cubit/submit_job_cubit.dart - exactly one call site, inside bridgeTokens(), no retry/resubmit method added"
        status: pass
    human_judgment: false
  - id: D5
    description: "SubmitJobState's shape (SubmitOutcome + bridgeHash + three error channels) is designed so plan 06 can fix submit_job_screen.dart:48-56's reset-before-toast ordering bug and render all three terminal states, without this plan touching that file."
    requirement: "CMP-10"
    verification: []
    human_judgment: true
    rationale: "This plan deliberately does not touch lib/submit_job/view/ (owned by plan 14-06, next wave). Whether the new state shape is actually SUFFICIENT for that screen rewrite is provable only when 14-06 consumes it - flagged here rather than claimed automatically passed."

duration: ~70min (not machine-timed at task granularity)
completed: 2026-07-29
status: complete
---

# Phase 14 Plan 05: Submit-job cubit outcome, error channels, and CTA ladder Summary

**SubmitJobCubit now preserves the burned-token hash on a failed job start (via a new SubmitOutcome discriminator), splits its single error field into three UI-matched channels, passes the real gas-shortfall reason through instead of a generic line, and a new pure `submit_job_cta_state.dart` module fixes the exactly-affordable-refused and zero-cost-read-as-insufficient bugs.**

## Performance

- **Completed:** 2026-07-29T11:01:37Z
- **Tasks:** 3/3 complete
- **Files created:** 4 (submit_job_cta_state.dart, 3 test files) + this SUMMARY
- **Files modified:** 2 (submit_job_state.dart, submit_job_cubit.dart)

**No commits were created.** `CLAUDE.md`/`AGENTS.md` line 23 ("Do not create commits") is an absolute project rule for this session; this orchestrator prompt's hard constraint 1 repeats it explicitly. All work is left staged only in the working tree.

## Accomplishments

- **`SubmitOutcome` enum** (`notSubmitted`, `done`, `bridgedNotProcessed`, `bridgeFailed`) added to `submit_job_state.dart`, plus a separate `bridgeHash` field. `bridgeTokens()`'s three terminal branches in `submit_job_cubit.dart` each set a distinct outcome; the middle branch (bridge succeeded, job failed to start) now writes `bridgeHash: txHash` where the shipped code silently dropped it, and also triggers the delayed balance refetch (reusing the existing `fetchGnusBalanceWithDelay()` rather than duplicating its 5s delay) since a burn happened on that branch too.
- **Three error channels** (`fileError`, `costError`, `submitError`) replace the single `filePickerError`/`FilePickerError`-wrapper field. All nine original call-site origins are re-routed per the plan's table: file channel takes the picker's three throws; cost channel takes balance/token-info/cost-lookup/missing-precondition/gas-estimate (five origins, all describing "the job cannot be priced yet"); submit channel takes the commit-time guard plus the two pre-existing process-error origins. The `FilePickerError` wrapper class (no equality override, so the screen's `listenWhen` fired on every emit including empty resets) is deleted.
- **The gas-shortfall message now survives.** `getBridgeOutGasCost()` passes `resp.errorMessage` through to `costError`, falling back to the generic line only when empty - `hasEnoughFundsForGas` (`web3.dart:500`, called from `:390`) already runs and already produces a specific "Not enough funds for gas to bridge tokens" message; the fix is a single conditional, not a new check.
- **A 5 MB file-size cap** in `openFilePicker()`, checked via `file.length()` before `file.readAsString()` - an oversized file is refused on the file channel with a message naming the limit, never parsed. Marked with a `ponytail:` comment naming the remaining exposure (the parse itself still runs synchronously on the UI isolate) and the upgrade path (off-isolate parsing).
- **Every `emit` in `SubmitJobCubit` guarded with `if (!isClosed)`** - previously only `fetchGnusBalance`'s emit was guarded; `fetchGnusTokenInfo`'s trailing emit and every error-setter emit were not, reachable because `_initialize()` fires from the constructor and awaits two network calls before the phase's drawer-hosted flow (plan 06+) makes early dismissal far more likely than the current full-screen host.
- **`lib/submit_job/submit_job_cta_state.dart`** created as a pure Dart module (no Flutter import) in the same shape as `lib/dashboard/bridge/bridge_cta_state.dart`: `SubmitJobCtaState` (6 rungs: `submitting` > `noFileChosen` > `costUnknown` > `costError` > `insufficientFunds` > `ready`), `resolveSubmitJobCtaState(...)`, `submitJobShortfall(...)`, `submitJobCtaLabel(...)`, `submitJobCtaEnabled(...)`. Fixes both bugs in the boolean it replaces (`submit_job_screen.dart:65`, `jobCost != 0 && jobCost < gnusBalance`): the `<` becomes `<=` (mirroring `bridge_cta_state.dart:62`'s house-standard boundary, pinned by its own named test), and the zero-cost case gets its own `costUnknown` rung instead of falling into the same accusing flag as a real shortfall.

## Gates measured myself

- **`flutter test test/submit_job/`** (scoped, per this plan's own `<verify>` blocks): **35/35 passed** - 5 in `submit_job_outcome_test.dart`, 15 in `submit_job_errors_test.dart`, 16 in `submit_job_cta_state_test.dart` (indices confirmed independently and combined).
- **`bash tool/check_brace_style.sh --count`**: `0`.
- **`bash tool/check_no_new_key_logging.sh --scan-tree` on all three lib files touched**: `OK` for all three (this plan rewrites the error surface, so this gate was run deliberately, not skipped).
- **`flutter analyze` (full project)**: **11 issues** - see "Anticipated cross-wave breakage" below for the 10 that are mine-by-design, and "Pre-existing, not mine" for the 1 that isn't.
- **`flutter test` (full suite)**: **605/606 passed** at the time measured. The one failure (`test/account/account_drawer_show_test.dart: tapping a row returns that wallet from show()`, a 10-minute timeout) is in an **untracked file this plan never touched**, owned by the concurrently-running plan 14-04 agent (`lib/account/`, `test/account/` per this session's hard constraint 2). Per hard constraint 3 ("Never fix a test you did not write") and AGENTS.md's parallel-session guidance, this was left alone and is reported here, not fixed. All `test/submit_job/*` tests are present and green inside that same full run (confirmed by grepping the run's own output for every test name).

## Anticipated cross-wave breakage (not a defect in this plan's own code)

`flutter analyze` reports **10 new errors, all in `lib/submit_job/view/submit_job_screen.dart`** - a file this plan's hard constraints explicitly forbid editing ("That file belongs to plan 14-06 - do not edit it"). They are every one of:
- `state.filePickerError` / `state.processErrorMessage` no longer exist (replaced by `fileError`/`costError`/`submitError` per Task 2's explicit instruction to delete the wrapper class)
- `submitJobCubit.resetFilePickerError()` / `resetProcessError()` no longer exist (replaced by `resetFileError()`/`resetCostError()`/`resetSubmitError()`)

This is the deliberate, designed consequence of Task 2's contract change, called out explicitly in the phase's defect list ("your state shape must make the fix possible there" for `submit_job_screen.dart:48-56`'s reset-before-toast bug). Plan 14-06 (next wave, `depends_on: ["14-05"]`) is the file that consumes this new contract and will resolve these errors as part of its own rewrite. Leaving `submit_job_screen.dart` compiling against the OLD field names was not an option once the plan's own instructions require deleting the `FilePickerError` class and splitting the single error field - the two are mutually exclusive, and the plan is explicit about which file wins.

## Pre-existing, not mine

`flutter analyze`'s remaining issue - an `unnecessary_import` info in `test/account/account_drawer_show_test.dart:27` - is in the same untracked, concurrently-authored file as the timeout above (plan 14-04's territory, `lib/account/`/`test/account/` per hard constraint 2). Never touched by this plan.

## Files Created/Modified

- `lib/submit_job/cubit/submit_job_state.dart` - `SubmitOutcome` enum, `bridgeHash` field, three error channels replacing `FilePickerError`
- `lib/submit_job/cubit/submit_job_cubit.dart` - three terminal branches set distinct outcomes; nine error origins re-routed; gas message passthrough; file-size cap; every emit guarded
- `lib/submit_job/submit_job_cta_state.dart` - new pure Dart CTA ladder module
- `test/submit_job/submit_job_outcome_test.dart` - 5 tests, hand-written `GeniusApi` fake
- `test/submit_job/submit_job_errors_test.dart` - 15 tests, hand-written `GeniusApi` fake + `FilePickerPlatform` fake
- `test/submit_job/submit_job_cta_state_test.dart` - 16 tests, pure-function only

## Decisions Made

See `key-decisions` in the frontmatter for the full list with rationale. The single most consequential one: `bridgeHash` is a field distinct from the pre-existing `txHash`, never a reuse - writing the burned hash into `txHash` without the `SubmitOutcome` discriminator would raise a false success toast on a job that never started, which is a worse bug than the one this phase exists to fix.

## Deviations from Plan

**None (Rules 1-4 never triggered beyond what the plan itself specified).** Every change in this plan - the outcome enum, the hash preservation, the channel split, the gas-message passthrough, the file-size cap, the emit guards, and the CTA ladder - was explicitly instructed by 14-05-PLAN.md's Task actions. No additional bugs, missing critical functionality, or blocking issues were discovered beyond what the plan already named.

One judgment call not explicitly specified by the plan: the exact field/method names for the three error channels (`fileError`/`costError`/`submitError` and their `set*`/`reset*` pairs) - the plan said "named for what the UI must do about each" without dictating literal identifiers. Chosen to read naturally against the plan's own channel descriptions (file/cost/submit) so plan 06 (which consumes this contract) has an unambiguous, self-describing surface.

## Known Stubs

None. No UI consumer of the new CTA ladder or error channels exists yet (that is plan 06's job); there is no hardcoded/mock data anywhere in the code this plan added.

## Threat Flags

None beyond what the plan's own `<threat_model>` already names. Verified against the register:

- **T-14-15** (the burned-token hash) - mitigated: `bridgeHash` is written on the `bridgedNotProcessed` branch, covered by `submit_job_outcome_test.dart`'s highest-weight assertion (`bridgeHash` is non-empty, not merely that the enum is set).
- **T-14-16** (unbounded file read) - mitigated: the 5 MB length check runs before `readAsString()`, covered by `submit_job_errors_test.dart`'s oversized-file test (asserts the file was never parsed - `jobCost`/`uploadedJson` stay at their defaults).
- **T-14-17** (null-assertion on the picker path) - unchanged, accepted per the plan's own disposition; not touched by this plan.
- **T-14-18** (error string information disclosure) - verified: `check_no_new_key_logging.sh` passes on all three touched lib files; the gas message passed through originates in `web3.dart` and names only a funding condition, never a key or address.
- **T-14-19** (re-running the job after a burn) - confirmed by direct inspection: `requestGeniusSDKProcess` has exactly one call site in the cubit, inside `bridgeTokens()`'s single pass. No retry/resubmit method was added.
- **T-14-SC** (package installs) - no packages installed; `file_picker`'s `FilePickerPlatform` and `mockito`'s presence in `pubspec.yaml` were both pre-existing dependencies, used only via their own public DI seam / Dart language noSuchMethod-forwarding respectively, not `pub add`-ed.

## Issues Encountered

**Testing `SubmitJobCubit` required two hand-written test doubles, documented here since neither existed as a house pattern yet:**

1. **`GeniusApi` cannot be subclassed for tests via `extends`** - its constructor eagerly constructs `FFIBridgePrebuilt()`, which `dlopen`s the native SuperGenius framework (`GeniusWallet.framework/GeniusWallet` on macOS) unconditionally outside the Android branch. That throws immediately in `flutter test`'s host environment, before a single test method runs. Resolved with `implements GeniusApi` + a `noSuchMethod` forward to `super.noSuchMethod` - standard, generic Dart (not a mockito import; `mockito` is present in `pubspec.yaml` but its `Mock` class was deliberately not used, per this plan's constraint to avoid a mock framework).
2. **`FilePicker.pickFiles()` delegates to `FilePickerPlatform.instance`**, a pluggable seam the `file_picker` package itself defines specifically so every platform implementation (macOS/Windows/Linux) can register its own backend. A test-only fake (`extends FilePickerPlatform`, override `pickFiles`) swapped in via `FilePickerPlatform.instance = fake` in `setUp`/restored in `tearDown` let `submit_job_errors_test.dart` drive every branch of `openFilePicker()` deterministically (cancel, invalid JSON, arbitrary throw, oversized file, and the downstream cost-channel origins) without touching a platform channel. `FilePickerPlatform` lives under `file_picker`'s `src/` and is not re-exported from the public barrel, so the import carries a narrowly-scoped `// ignore_for_file: implementation_imports` with a comment explaining why.

Both patterns are recorded here in case plan 06 (or later phases exercising other cubits with `GeniusApi`/`FilePicker` dependencies) want to promote them to a shared test-support file - not done here per the Rule of Three (only two files in this plan need either fake).

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plan 14-06 (next wave, `depends_on: ["14-05"]`) can now consume `SubmitOutcome`, `bridgeHash`, the three error channels, and `submit_job_cta_state.dart` directly. It owns `lib/submit_job/view/` and will resolve the 10 anticipated `flutter analyze` errors in `submit_job_screen.dart` as part of rewriting it - see "Anticipated cross-wave breakage" above.
- The three-channel contract is deliberately UI-treatment-shaped per the plan ("Plan 06 renders this channel inline next to the cost, not as a toast") - `costError` should render inline, `fileError`/`submitError` as toasts, per the plan's own routing rationale.
- `bridgeHash` is the field 14-06 needs for the *bridged, not processed* terminal state's copyable-hash requirement (locked decision: informational only, no retry CTA - `.planning/todos/pending/2026-07-29-can-requestgeniussdkprocess-be-recalled-after-a-successful-bridge.md` remains parked, untouched by this plan).
- The one full-suite test failure (`test/account/account_drawer_show_test.dart`) is unrelated to this plan's scope and should be tracked by whichever agent/plan owns `lib/account/`.

## Self-Check

- `[ -f lib/submit_job/submit_job_cta_state.dart ]` → FOUND
- `[ -f test/submit_job/submit_job_outcome_test.dart ]` → FOUND
- `[ -f test/submit_job/submit_job_errors_test.dart ]` → FOUND
- `[ -f test/submit_job/submit_job_cta_state_test.dart ]` → FOUND
- `flutter test test/submit_job/` → 35/35 passed (re-confirmed)
- `bash tool/check_brace_style.sh --count` → `0` (re-confirmed)
- `grep -n "requestGeniusSDKProcess" lib/submit_job/cubit/submit_job_cubit.dart` → exactly one call site, inside `bridgeTokens()`

## Self-Check: PASSED

---
*Phase: 14-compute-panel-job-flow*
*Plan: 05*
*Completed: 2026-07-29*
