---
phase: 42-shared-job-submission-off-the-ui-isolate
verified: 2026-10-26T00:00:00Z
status: human_needed
score: 3/3 must-haves verified in code (criterion 3 real-SDK feel deferred)
behavior_unverified: 1
overrides_applied: 0
behavior_unverified_items:
  - truth: "While the compute panel prices or submits a job with the real SDK, the wallet keeps animating"
    test: "Phase 48 device walk: price and submit a job with the real SDK and watch a spinner / animation on each platform"
    expected: "No freeze during the cost and process calls; any shorter hitch from the 1 s processing-status poll landing inside a job call is observed and judged"
    why_human: "flutter test cannot run the real SDK; the SDK holds one global mutex through both calls, so a main-isolate poll can still block briefly. Deferred to phase 48 by design."
human_verification:
  - test: "Phase 48 walk, per platform: price and submit a job with the real SDK while an animation is on screen"
    expected: "UI keeps animating; record any poll hitch"
    why_human: "Needs the real native SDK; deferred by design, not a failure"
---

# Phase 42: Shared job submission off the UI isolate - Verification Report

**Phase Goal:** The compute panel's job flow (price, burn, process, bridged-not-processed) lives in one owner that the panel and the coming bridge both call, and pricing or submitting a job never freezes the wallet UI.
**Verified:** 2026-10-26
**Status:** human_needed (no gaps; one deferred real-SDK check)
**Re-verification:** No, initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Panel prices and submits exactly as before; existing tests pass unchanged after extraction | VERIFIED | `git diff --stat 46d188c4 aacf02b6 -- test/submit_job/ test/dev/dev_mock_job_test.dart` shows only the new `job_submission_test.dart` (+397); the four pre-existing files are untouched at the 42-01 boundary. Focused run (test/submit_job, dev_mock_job_test, compute_panel_wiring_test): +119 all passed, exit 0. Sealed results cover Done, BridgedNotProcessed, BridgeFailed, MissingData, cost failure, gas estimate; dev gate is the single `JobSubmission.devToolsEnabled`/`devScenario`. Later 42-02 edits to those four files are fake-signature changes only (sync overrides deleted); SUMMARY says no assertion changed, diff of those edits was not line-audited. |
| 2 | Panel calls one shared owner; cubit no longer calls `bridgeOut`, `requestGeniusSDKCost`, `requestGeniusSDKProcess` | VERIFIED | `grep` in `submit_job_cubit.dart` for bridgeOut / getBrigeOutGasCost / requestGeniusSDK: one hit, a comment (line 335). Cubit holds `jobSubmission` (default `JobSubmission(geniusApi: geniusApi)`). Owner `lib/submit_job/job_submission.dart` calls `requestGeniusSDKCostAsync`, `getBrigeOutGasCost`, `bridgeOut`, `requestGeniusSDKProcessAsync`; no other `lib/` file calls the async pair. `bridge_screen.dart` calls `bridgeOut` directly, but that is the token bridge, outside the job flow and outside criterion 2. |
| 3 | SDK cost and process calls run off the UI isolate; a test fails if they run on it | VERIFIED (code) / real-SDK feel deferred | `genius_api.dart`: `_geniusSdkCostOffIsolate` / `_geniusSdkProcessOffIsolate` use `Isolate.run`, top-level functions whose closures capture only `jobJson` (String), re-open the library via `loadGeniusSDKLibrary()` and build their own `NativeLibrary`. Sync `requestGeniusSDKCost/Process` are gone; sweep of `lib/` and `packages/genius_api/lib` finds only a doc comment in `job_steps.dart:392`. `job_off_ui_isolate_test.dart` has a regex source guard (with positive-sample self-check) that fails on any `_ffiBridgePrebuilt.sgnsLib.GeniusSDK(GetCost|Process)(` or sync method name, plus an async-only fake. |

**Score:** 3/3 in code; 1 truth carries a behavior-unverified part (real SDK, see below).

Note on test strength: the two "keeps pumping" widget tests use a fake with a pending future, so they prove the cubit does not busy-wait or block frames, not that the native call is off-isolate. The off-isolate proof is the source guard plus the deleted sync API. That is a structural proof, which is adequate for the criterion as worded, but it is not a runtime proof.

### Deferred / Human

"Keeps animating with the real SDK" is deferred to the phase 48 device walk by design (recorded in 42-02-SUMMARY). The SDK takes one global mutex across the whole cost and process calls, and `AppBloc`'s 1 s `getProcessingStatus()` tick plus balance reads still call the SDK synchronously on the UI isolate, so a poll landing inside a job call can hitch the UI. Not a failure; the `ponytail:` comment in `genius_api.dart` names the ceiling and the upgrade path (SDK-ASYNC, or pausing the poll, a decision for Braian).

### Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `lib/submit_job/job_submission.dart` | VERIFIED | Substantive (sealed result families, cost, estimateGas, submit, dev gate); wired from cubit |
| `test/submit_job/job_submission_test.dart` | VERIFIED | New in 42-01, passes |
| `test/submit_job/job_off_ui_isolate_test.dart` | VERIFIED | 7 tests, passes |
| `packages/genius_api/lib/src/genius_api.dart` async + worker entries | VERIFIED | As above |

### Key Links

| From | To | Status |
|------|----|--------|
| `SubmitJobCubit` | `JobSubmission` | WIRED (`jobSubmission` field, injected or default) |
| `JobSubmission` | `GeniusApi.requestGeniusSDK*Async`, `bridgeOut`, `getBrigeOutGasCost` | WIRED |
| `requestGeniusSDK*Async` | `Isolate.run` workers | WIRED |

### Checks Run

| Check | Result |
|-------|--------|
| `flutter analyze --no-pub lib test` | exit 0, "No issues found" |
| `flutter analyze --no-pub` in packages/genius_api | exit 0, "No issues found" |
| `bash tool/check_brace_style.sh` | exit 0 |
| `dart format --set-exit-if-changed` on lib/submit_job, genius_api.dart, test/submit_job | exit 0, 0 changed |
| Focused tests (submit_job, dev_mock_job, compute_panel_wiring) | +119 passed, exit 0 |
| Full suite | NOT run by this verification; SUMMARY's +2692 / 6 skipped / 0 failed is unconfirmed |
| Attribution: `git log da551fb5..HEAD` grep for claude / co-authored / generated with / anthropic | no matches; sole author braianxde |
| Working tree | clean; new files LF |

### Requirements Coverage

| Requirement | Status | Evidence |
|-------------|--------|----------|
| ISO-01 | SATISFIED in code, real-SDK animation deferred to phase 48 | Truths 1-3 above |

No orphaned requirements.

### Anti-Patterns

None found in touched files (no TBD/FIXME/XXX; the `ponytail:` comment is a documented ceiling).

### Probe Execution

Step 7c: SKIPPED (no probes declared by the phase).

### Human Verification Required

1. **Real-SDK animation during pricing and submit (phase 48)**
   - Test: on each platform, price and submit a job with the real SDK with an animation visible; watch for hitches when the processing-status poll fires mid-call.
   - Expected: UI keeps animating; any residual poll hitch is recorded for a decision.
   - Why human: needs the native SDK and a device; deferred by design.

### Gaps Summary

No gaps. Phase 42 delivers the extraction and the isolate move. Only the deferred real-SDK animation check remains.

---

_Verified: 2026-10-26_
_Verifier: Claude (gsd-verifier)_
