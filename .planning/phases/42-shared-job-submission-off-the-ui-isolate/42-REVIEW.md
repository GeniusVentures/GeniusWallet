---
phase: 42-shared-job-submission-off-the-ui-isolate
reviewed: 2026-10-27T01:33:47Z
depth: standard
files_reviewed: 9
files_reviewed_list:
  - lib/dev/dev_mock_job.dart
  - lib/submit_job/cubit/submit_job_cubit.dart
  - lib/submit_job/job_submission.dart
  - packages/genius_api/lib/src/genius_api.dart
  - test/submit_job/job_flow_test.dart
  - test/submit_job/job_off_ui_isolate_test.dart
  - test/submit_job/job_submission_test.dart
  - test/submit_job/submit_job_errors_test.dart
  - test/submit_job/submit_job_outcome_test.dart
findings:
  critical: 1
  warning: 3
  info: 5
  total: 9
status: issues_found
---

# Phase 42: Code Review Report

**Reviewed:** 2026-10-27T01:33:47Z
**Depth:** standard
**Files Reviewed:** 9
**Status:** issues_found

## Summary

Diff `46d188c4..86478c7c -- lib packages test` (commits 7b273824..126948de).

Checked and clean:
- **Behaviour.** The extraction keeps the old behaviour for every outcome: missing data, bridge failed, bridged-not-processed and done. Error strings are word for word. The balance refetch is skipped on the dev path, as before. `isBridgingTokens` and the `outcome` reset still run before the first await.
- **Release gate.** `devToolsEnabled` is a `const` built from `kDebugMode && kShowDevTools`, and a test covers it.
- **FFI memory.** Both worker entries allocate after the `dylib == null` early return and free with `malloc.free` in a `finally`. That matches `toNativeUtf8`'s default allocator; the old code freed with `calloc.free`. No leak and no use-after-free on the Dart side.
- **Isolate capture.** Each closure captures only the `String jobJson`. No key, mnemonic or `GeniusApi` graph crosses the isolate boundary, and no new log line prints anything secret.
- **Double submit.** No path sends two process calls for one burn.

What is not clean: this phase adds a new way for the code to throw after the burn, and nothing maps it to an outcome. Three smaller quality problems follow.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: A throw from the process isolate after the burn loses the bridge hash and wedges the panel

**File:** `lib/submit_job/job_submission.dart:198-200`, `packages/genius_api/lib/src/genius_api.dart:109-122,1142-1155`, `lib/submit_job/cubit/submit_job_cubit.dart:356-360`

**Fix status:** fixed in 5bfbac6b. `JobSubmission.submit` catches a throw from the async process call and returns `JobBridgedNotProcessed` with the burn hash and `NOT_INITIALIZED`. Test added in `job_submission_test.dart`.

**Issue:** The old sync `requestGeniusSDKProcess` called a function that had already been looked up on the main isolate, so in practice it could not throw after `bridgeOut` returned. The new path can throw at several points, all after the GNUS has been burned:
- `Isolate.run` can fail to spawn or to copy the closure.
- `loadGeniusSDKLibrary()` can throw. It has no catch on iOS and macOS (`ffi_bridge_prebuilt.dart:33`).
- The worker can end without a result.

Any of these propagates out of `JobSubmission.submit` and then out of `SubmitJobCubit.bridgeTokens`. `bridgeTokens` is wired as an unawaited tear-off (`job_steps.dart:697`, `:830`), so the error ends up unhandled. When that happens:
- `isBridgingTokens` stays `true` and the spinner never ends. `resetState()` does not clear `isBridgingTokens`.
- `bridgeHash` is never written, so the user's only proof of the burn is gone.
- The outcome stays `notSubmitted`.

This is the "burn without a recorded process attempt" case. Phase 43's `gnus_submitJob` would inherit it, and a dApp would get a rejected promise for a burn that really happened.

RESEARCH Pitfall 5 said not to fix this because it was "existing behaviour". That premise is wrong: the throw surface is new in this phase.

**Fix:** Catch at the owner, the single point both callers share, and keep the hash:
```dart
final GeniusNodeReturnValue processResult;
try {
  processResult = await geniusApi.requestGeniusSDKProcessAsync(
    jobJson: jsonEncode(jobJson),
  );
} catch (e) {
  debugPrint('GeniusSDKProcess failed after burn: ${e.runtimeType}');
  return JobBridgedNotProcessed(
    txHash,
    GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
  );
}
```
Add one test in `job_submission_test.dart`: a fake whose `requestGeniusSDKProcessAsync` throws must give `JobBridgedNotProcessed` carrying the burn hash.

## Warnings

### WR-01: The `jobSubmission` constructor parameter has no caller

**File:** `lib/submit_job/cubit/submit_job_cubit.dart:33-34`

**Fix status:** fixed in 5cf9ab58. The parameter is removed; the cubit builds its own `JobSubmission`.

**Issue:** `JobSubmission? jobSubmission` is optional and injectable, but no file in `lib/` or `test/` passes it. Every test injects through `geniusApi`. It is a speculative extension point for phase 43, which AGENTS.md forbids ("No abstractions that weren't explicitly requested", YAGNI). It also allows a cubit whose `geniusApi` and `jobSubmission.geniusApi` are different objects.

**Fix:** Drop the parameter and write `final JobSubmission jobSubmission = ...` initialised from `geniusApi`. Add the parameter back in phase 43 if the handler really needs to share an instance.

### WR-02: The dev-fixture decision is still split between the cubit and the owner

**File:** `lib/submit_job/cubit/submit_job_cubit.dart:95-104,221-269`, `lib/submit_job/job_submission.dart:110-116,127-129`

**Fix status:** fixed in e021f698. The cost result carries the fixture balance (`JobCostResult.fixtureBalance`), `JobSubmission.fixtureBalance` serves the balance read, and the cubit branches on the result. The unreachable `??` fallback is gone; the failure branch is shared with the real path. The dev path cannot run under `flutter test` (gate closed), so its behaviour is checked by reading the emits, not by a test.

**Issue:** D-03 says the fixture moves into the owner so the panel and the phase 43 bridge share one mock. In the current code:
- The cubit still decides dev versus real on its own (`isDev` at line 221).
- The cubit still reads `DevMockJob.instance.balance` (lines 99 and 232).
- The cubit still owns the "dev pricing skips the `isGasFetchable` gate" rule.

So every pricing call reads the gate twice, once in the cubit and once in `JobSubmission.cost`, and two branches have to stay in step. A second caller of `cost()`/`estimateGas()` gets the fixture cost and gas but not the fixture balance. That breaks `gnus_estimate`'s "cost, gas and balance" contract in dev mode. The dev-branch fallback `reason ?? 'Unable to retrieve job cost'` (line 242) is unreachable, because the dev `JobCostFailed` always has a reason.

**Fix:** Have the owner return everything a caller needs, for example `JobCostOk(minions)` plus a balance read from the owner (`devBalance`, or an `estimate()` that returns cost, gas and balance). The cubit then branches only on the result type, not on `isDev`. Remove the unreachable `??` fallback.

### WR-03: Closing the window right after the burn can now shut the SDK down before Process runs

**File:** `lib/submit_job/job_submission.dart:184-200`, `packages/genius_api/lib/src/genius_api.dart:1116-1122`, `lib/main.dart:330,375`

**Fix status:** fixed in 66419ca1, with accepted gaps. `shutdownSDK` resets `_isSdkInitialized`, and the window-close path awaits `GeniusApi.waitForJobCall()` (bounded at 10 s) before shutdown. Accepted, marked `ponytail:` in `genius_api.dart`: the synchronous `detached` lifecycle shutdown does not wait, and a close during the bridge burn itself (before the process call starts) is not covered. Upgrade path: SDK-ASYNC or one job-call queue that shutdown drains. No unit test: `GeniusApi` needs the native library to construct.

**Issue:** Before, the continuation after `bridgeOut` ran the sync `GeniusSDKProcess` in the same event-loop turn. A window close or `AppLifecycleState.detached` could not run between the burn and Process. Now Process waits for an isolate to spawn and re-open the library, which creates a short window. If `shutdownSDK()` runs inside that window, it takes the SDK mutex first. The burned job then hits a shut-down node: at best an error code, at worst native undefined behaviour. `_isSdkInitialized` is never reset by `shutdownSDK`, so the main-isolate guard does not catch this. Once the worker holds the mutex, shutdown waits and the job does complete, so only the spawn gap is exposed. The chance is low, but the money is real and the gap did not exist before.

**Fix:** The smallest change: have `shutdownSDK()` set `_isSdkInitialized = false`, so later calls get `NOT_INITIALIZED` and go through the CR-01 path that keeps the hash. Also have the close handler wait for an in-flight job before shutting down, for example a `Future?` field on `GeniusApi` set while a process call runs and awaited with a timeout in `main.dart:330`. Mark it with a `ponytail:` comment if you defer it.

## Info

**Fix status:** IN-01 to IN-05 not changed; none is a correctness bug and IN-01 has a test that pins the throw.

### IN-01: The dev `notSubmitted` case went from a no-op to a throw

**File:** `lib/submit_job/job_submission.dart:221-222`

**Issue:** The old fixture path did `break` on `SubmitOutcome.notSubmitted`. The new one throws `StateError`, which escapes the unawaited `bridgeTokens` with `isBridgingTokens: true`. It is unreachable today and dev-only, but it is a behaviour change inside a refactor-only plan.

**Fix:** Either accept it and say so in the summary, or return `const JobBridgeFailed()`.

### IN-02: The precondition null-check is duplicated inside the owner

**File:** `lib/submit_job/job_submission.dart:131-140,171-182`

**Issue:** `estimateGas` and `submit` repeat the same four-field null-check and unpacking.

**Fix:** Optional. A `JobFacts.isComplete` getter would remove it, but leaving it duplicated also fits the Rule of Three.

### IN-03: The process error copy and missing-data copy stay in the cubit

**File:** `lib/submit_job/cubit/submit_job_cubit.dart:363-372,487-506`

**Issue:** CONTEXT D-01 allows this. Note it for phase 43: if the `gnus_*` handler needs human-readable reasons, map from the code in the owner rather than copying `_processErrorMessage`.

**Fix:** None now. Decide in phase 43.

### IN-04: Persistent frame callbacks are never removed in the widget tests

**File:** `test/submit_job/job_off_ui_isolate_test.dart:344,385`

**Issue:** `addPersistentFrameCallback` cannot be removed. Each test leaves a closure on the shared binding that keeps incrementing a dead `frames` variable. This is harmless today, but a later test that counts frames on the same binding would be fragile.

**Fix:** Guard each callback with a local `var active = true;` flag that is set to false in `addTearDown`.

### IN-05: The source-guard tests only strip full-line `//` comments

**File:** `test/submit_job/job_off_ui_isolate_test.dart:210-213`, `test/submit_job/job_submission_test.dart:354-357`

**Issue:** A sync call name inside a `/* */` block or after trailing code would cause a false failure, and the guard for at least two `Isolate.run(` calls would count commented-out calls. This is a weak signal, not a correctness bug.

**Fix:** None needed. If either guard ever fires falsely, also strip `/* ... */` blocks.

---

_Reviewed: 2026-10-27T01:33:47Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
