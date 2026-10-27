---
phase: 42
slug: shared-job-submission-off-the-ui-isolate
# status lifecycle: draft (seeded by plan-phase) -> validated (set by validate-phase)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-10-26
---

# Phase 42 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution. Source: 42-RESEARCH.md "Validation Architecture".

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (Flutter 3.41.9 / Dart 3.11.5), hand-written fakes (`implements GeniusApi` + `noSuchMethod` forward), no mocktail |
| **Config file** | none beyond `pubspec.yaml`; analyzer rules in `analysis_options.yaml` and `packages/genius_api/analysis_options.yaml` (nearest file wins) |
| **Setup (once, plan 01 Task 0)** | `git submodule update --init --recursive`, then `flutter pub get` at the root and in `packages/genius_api`. Flutter is not on PATH: `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"` in every shell call |
| **Quick run command** | `flutter test --no-pub test/submit_job test/dev/dev_mock_job_test.dart test/dashboard/compute_panel_wiring_test.dart` |
| **Full suite command** | `flutter test --no-pub --reporter failures-only` (CI runs `flutter test --test-randomize-ordering-seed random`, `.github/workflows/build.yml:1611`) |
| **Static gates** | `dart format --output=none --set-exit-if-changed <changed paths>`; `flutter analyze --no-pub lib test` and `(cd packages/genius_api && flutter analyze --no-pub)` (both exit 1 on infos; capture the exit code before any pipe); `bash tool/check_brace_style.sh` |
| **Estimated runtime** | quick run about 30 s; full suite measured in plan 01 Task 0 |

Baseline: not quoted from memory. Plan 01 Task 0 measures analyze (root and genius_api), the brace check and the full suite on this branch and writes them to `42-01-SUMMARY.md` under `## Baseline`. Older figures (512 on 2026-07-28, 788 on another branch) are stale.

---

## Sampling Rate

- **After every task commit:** the quick run command, plus `dart format` on the changed paths, `bash tool/check_brace_style.sh` and `flutter analyze --no-pub lib test`.
- **After every plan wave:** the full suite command plus both analyze runs, compared with the plan 01 baseline.
- **Before `/gsd-verify-work`:** full suite no worse than the baseline (exit 0 if the baseline was exit 0; otherwise no new failing test name).
- **Max feedback latency:** about 30 s for the quick run.

---

## Phase Requirements -> Test Map

| Req / criterion | Behavior | Test type | Automated command | File exists? |
|-----------------|----------|-----------|-------------------|--------------|
| Criterion 1 (extraction, outcomes unchanged) | Every existing flow, error-channel and outcome test passes UNCHANGED after plan 01 | unit + widget | quick run, plus `git diff --exit-code da551fb5 --` the four existing submit_job test files and `test/dev/dev_mock_job_test.dart` | yes: `job_flow_test.dart`, `submit_job_errors_test.dart`, `submit_job_outcome_test.dart`, `submit_job_cta_state_test.dart` |
| Criterion 1 (dev-mock scenarios, double-submit guard) | Fixture mapping and listener semantics unchanged; retry clears outcome before any await | unit | `flutter test --no-pub test/dev/dev_mock_job_test.dart`; `submit_job_outcome_test.dart` retry test | yes |
| Criterion 1 / D-03 (release safety) | With a scenario armed and the gate closed, the owner takes the real path for submit, cost and gas | unit | `flutter test --no-pub test/submit_job/job_submission_test.dart` | W0: created in 42-01 Task 1 |
| Criterion 2 / D-06 | `submit_job_cubit.dart` makes no direct call to the burn, the gas estimate, the SDK cost or the SDK process (Async names included) | source-grep unit | `flutter test --no-pub test/submit_job/job_submission_test.dart --plain-name "cubit makes no direct"` | W0: created in 42-01 Task 2 |
| Owner behaviour | cost, gas, burn, process ordering; every sealed branch; strings unchanged | unit | `flutter test --no-pub test/submit_job/job_submission_test.dart` | W0: 42-01 Tasks 1-2 |
| Criterion 3 / D-09 | Sync SDK job methods deleted from `GeniusApi`; nothing in `lib/` calls them; cost and process FFI never called through the main-isolate handle | compile + source-grep unit | `flutter analyze --no-pub lib test`, `(cd packages/genius_api && flutter analyze --no-pub)`, `flutter test --no-pub test/submit_job/job_off_ui_isolate_test.dart` | W0: created in 42-02 Task 3 |
| Criterion 3 / D-10 (no sync path from the owner) | An async-only fake whose every other member throws completes the whole flow | unit | `flutter test --no-pub test/submit_job/job_off_ui_isolate_test.dart` | W0: 42-02 Task 3 |
| Criterion 3 / D-10 (UI keeps pumping) | While a slow async cost call, and separately a slow async process call, is pending, frames keep drawing, the spinner keeps scheduling frames, and completing the call lands the same state | widget | `flutter test --no-pub test/submit_job/job_off_ui_isolate_test.dart --plain-name "keeps pumping"` | W0: 42-02 Task 3 |
| Criterion 3 (real SDK, real feel) | Panel keeps animating during a real cost and process call; residual poll hitch measured | manual walk | none (phase 48) | manual-only |

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 42-01-00 | 01 | 1 | ISO-01 (prerequisite) | - | N/A (environment and baseline) | env check + focused run | `test -f .dart_tool/package_config.json && test -f squidrouter/pubspec.yaml && flutter --version` then the quick run | yes | pending |
| 42-01-01 | 01 | 1 | ISO-01, criteria 1-2 | T-42-01, T-42-02, T-42-03, T-42-04, T-42-05 | Armed fixture with the gate closed takes the real path; no burn on missing data; facts captured before the first await; bridge hash kept on bridgedNotProcessed | unit + widget | quick run, then `git diff --exit-code da551fb5 --` the existing test files, then format, brace check, analyze | W0 (`job_submission_test.dart` created here) | pending |
| 42-01-02 | 01 | 1 | ISO-01, criteria 1-2 | T-42-01, T-42-06, T-42-07 | Cost and gas release-safety cases; no new log line; exhaustive result switches | unit + source-grep | quick run, `flutter test --no-pub test/submit_job/job_submission_test.dart --plain-name "cubit makes no direct"`, format, brace, analyze, full suite | W0 (extends the Task 1 file) | pending |
| 42-02-01 | 02 | 2 | ISO-01, criterion 3 | T-42-08, T-42-09, T-42-11, T-42-12, T-42-13 | Worker closure captures only the job JSON; `Isolate.run` rethrows; native string freed in the worker; main-isolate guards unchanged; cost catch logs no job data | unit | `flutter test --no-pub test/submit_job test/dev/dev_mock_job_test.dart`, format, brace, `flutter analyze --no-pub lib test`, `(cd packages/genius_api && flutter analyze --no-pub)` | yes | pending |
| 42-02-02 | 02 | 2 | ISO-01, criterion 3 | T-42-09 | Process error still propagates as before | unit + widget | quick run, format, brace, analyze | yes | pending |
| 42-02-03 | 02 | 2 | ISO-01, criterion 3 | T-42-08, T-42-14 | No sync SDK job method left; owner cannot reach any other member; UI keeps scheduling frames while a call is pending | source-grep + unit + widget | `flutter test --no-pub test/submit_job/job_off_ui_isolate_test.dart`, quick run, format, brace, both analyze runs, full suite | W0 (`job_off_ui_isolate_test.dart` created here) | pending |

---

## Wave 0 Requirements

- [ ] Environment: submodules initialised and `flutter pub get` at the root and in `packages/genius_api` (42-01 Task 0, executor only).
- [ ] `test/submit_job/job_submission_test.dart`: owner tests with a hand fake (submit missing data / bridge failed / bridged-not-processed / done, cost ok / zero, gas missing / failed / ok, armed-but-gated release-safety cases, `devSubmitResult` mapping, `DevMockJob.instance.clear()` in tearDown) and the cubit boundary guard (42-01 Tasks 1-2).
- [ ] `test/submit_job/job_off_ui_isolate_test.dart`: async-only throwing fake, lib/ sync-name sweep, genius_api main-handle guard, two "keeps pumping" widget tests (42-02 Task 3).
- [ ] The three existing fakes switch to the async SDK methods in plan 02 only (`submit_job_errors_test.dart`, `submit_job_outcome_test.dart`, `job_flow_test.dart`), signatures only.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| The compute panel keeps animating while a real SDK cost call and a real process call run | ISO-01, criterion 3 | `flutter test` cannot load the native SuperGenius SDK; under fakes a synchronous call would not block anything either, so the widget tests prove only that the flow awaits the call | Phase 48 walk: price and submit a job on each platform (dev-mock scenarios where SDK-CA still returns cost 0) and watch the spinner and a scroll during the call |
| Residual hitch: the 1 s processing-status poll (`lib/bloc/app_bloc.dart:253-259`) and the balance reads are synchronous SDK calls on the UI isolate and wait on the SDK's global mutex while a worker holds it for a 100-800 ms job call | ISO-01 (known limit, research Open Question 1) | Needs the real SDK and real timing; not fixable inside "no UI change, no new capability" without pausing the polls, which is a separate decision for Braian | Phase 48 walk: note whether a shorter, roughly once-a-second stutter remains during pricing. Record the result in phase 48's verification; phase 42 VERIFICATION lists it as deferred, not passed |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency under 30 s for the quick run
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
