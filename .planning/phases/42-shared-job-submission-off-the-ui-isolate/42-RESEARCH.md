# Phase 42: Shared job submission off the UI isolate - Research

**Researched:** 2026-10-26
**Domain:** Flutter/Dart FFI isolates, cubit-to-owner extraction (GeniusWallet, Flutter 3.41.9 / Dart 3.11.5)
**Confidence:** HIGH on the extraction map and the isolate mechanics; MEDIUM on the real-SDK "keeps animating" outcome (see Pitfall 1)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** One plain Dart class, `JobSubmission` (name at planner's discretion), in `lib/submit_job/`, constructed with what the cubit already receives (`GeniusApi`, plus the wallet/network/GNUS-token facts it reads from `WalletDetailsCubit` and `GnusCubit` passed in as values per call, not the cubits themselves). It holds no UI state and never emits. `SubmitJobCubit` keeps all state, emits and copy; it calls the owner and maps results to `SubmitOutcome` exactly as today.
- **D-02:** The owner's results are typed and mirror today's outcomes one to one: cost ok / cost failure (with the same message passthrough as `getBridgeOutGasCost`), gas estimate ok / failure, submit result `done(txHash)` / `bridgedNotProcessed(bridgeHash, processResult)` / `bridgeFailed` / `missingData`. Sealed classes, not strings. Error messages stay word for word.
- **D-03:** The dev-mock fixture (`DevMockJob`, gated by `kDebugMode && kShowDevTools`) moves with the flow into the owner, behind the same gate, so the panel and the future bridge share one mock. The release-safety property (fixture unreachable in release) must still hold and stay tested.
- **D-04:** The cubit's double-submit guard (`isBridgingTokens`, the `outcome` reset on retry) stays in the cubit for this phase. A cross-caller in-flight lock belongs to phase 43 (RPC-06), where a second caller first exists.
- **D-05:** Two plans minimum, in order: (1) the extraction, behaviour-preserving, with every existing `test/submit_job/*` test passing unchanged; (2) the isolate move. Never in one diff (AGENTS.md "refactor first, then change behavior").
- **D-06:** `submit_job_cubit.dart` ends the phase with no direct call to `bridgeOut`, `getBrigeOutGasCost`, `requestGeniusSDKCost` or `requestGeniusSDKProcess` (success criterion 2). A grep-based check in a test or `tool/` script is acceptable proof.
- **D-07:** Follow the existing precedent, `GeniusApi.selectGeniusAccountAsync` (`packages/genius_api/lib/src/genius_api.dart` ~line 1550, `Isolate.spawn` + `ReceivePort`): add async variants of the cost and process calls in `genius_api` and make the owner use only those. Prefer `Isolate.run` if research confirms it behaves the same with the FFI library handle; otherwise copy the precedent.
- **D-08:** Research must establish, before plan 2 is written, what the precedent relies on: does the spawned isolate re-open the native library, and is the SDK safe to call from a non-main thread while the main isolate also calls it (status polling, balance reads)? If concurrent calls are not safe, serialise SDK job calls through one queue in `genius_api` and mark it with a `ponytail:` comment (ceiling: one SDK job call at a time; upgrade path: SDK-ASYNC). If the precedent is itself unsafe, record it as a blocker and ship plan 1 only.
- **D-09:** Sync `requestGeniusSDKCost` / `requestGeniusSDKProcess` stay in `genius_api` only if something outside the job flow still needs them; otherwise delete them (deletion over addition). No caller in `lib/` may use the sync versions after this phase.
- **D-10:** Proof for success criterion 3: a test that fails if the owner calls the sync SDK methods (fake `GeniusApi` that throws on the sync ones), plus a widget test that the panel keeps pumping frames while a slow fake async cost call is pending. A human-visible "keeps animating" check with the real SDK is deferred to the phase 48 walk; note it in VERIFICATION, do not claim it.

### Claude's Discretion
File and class names, whether the owner is one class or a class plus a small value type for inputs, and how the existing three `_SeededSubmitJobCubit` test helpers are kept working.

### Deferred Ideas (OUT OF SCOPE)
- Re-running Process for an existing burn (`bridgedNotProcessed` recovery): contract open question U5, todo `.planning/todos/pending/2026-07-29-can-requestgeniussdkprocess-be-recalled-after-a-successful-bridge.md`. Not this phase.
- Unhardcoding the bridge destination chain id: separate change.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ISO-01 | Pricing or submitting a job, from the bridge or the compute panel, never freezes the wallet UI: the SDK cost and process calls run off the UI isolate and the screen keeps animating during them | Q1 (isolate mechanics, `Isolate.run` plus a top-level entry), Q2 (SDK locking, and the residual-freeze caveat), Q3 (test approach), extraction map (section 4) |
| SDK-ASYNC (dependency, not in scope) | Async or thread-safe cost/process calls on the SDK side | Not needed: the wallet moves the calls itself. The SDK is already thread-safe (single global mutex), see Q2 |
</phase_requirements>

## Summary

The extraction is mechanical and low-risk. `SubmitJobCubit` mixes three things in two methods (`_resolveJobCost` + `getBridgeOutGasCost`, and `bridgeTokens` + `_bridgeTokensFromDevFixture`): SDK/chain calls, the dev fixture, and state emits. The owner takes the first two; the cubit keeps every emit and every user-facing string. The only subtle part is that the real-path cost gate (`isGasFetchable`) reads cubit state (`state.gnusTokenDetails.address`) while the gas call reads a different source (`gnusCubit.state.tokenInfo?.address`); both must be preserved (section 4).

The isolate move is safe to do and `Isolate.run` is the right tool. The precedent re-opens the native library inside the spawned isolate through the top-level `loadGeniusSDKLibrary()`; it does not send any FFI handle across. On Windows and Linux the SDK is statically linked into the executable and looked up with `DynamicLibrary.executable()`, which is process-wide, so the second isolate reaches the same SDK instance. The SDK serialises every public entry point with one global `std::recursive_mutex`, so concurrent calls are thread-safe and no Dart-side queue is needed.

One finding the planner must carry into VERIFICATION: because the SDK holds that global mutex for the whole cost call (which does a live coin-price HTTP request) and the whole process call (which re-prices first), the main isolate's own synchronous SDK polls (the 1 s processing-status tick, the balance reads) block on the mutex while a job call is in flight. Moving the job calls off the UI isolate removes the freeze caused by the call itself but not the freeze caused by a poll that lands inside it. The tests cannot show this. The phase 48 walk must.

**Primary recommendation:** Plan 1 extracts `JobSubmission` (owner + sealed results + dev fixture behind one gate) with all existing tests unchanged. Plan 2 adds `requestGeniusSDKCostAsync` / `requestGeniusSDKProcessAsync` using `Isolate.run` with a top-level entry that takes only a `String`, switches the owner to them, deletes the sync versions, updates the three test fakes, and adds a throw-on-sync fake, a source-grep guard and a frames-keep-pumping widget test. No Dart-side queue.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| SDK cost and process calls (FFI) | `genius_api` package (repository layer) | Worker isolate | AGENTS.md: widgets/cubits do not make direct SDK calls; the isolate entry lives next to `_selectGeniusAccountIsolate` |
| Bridge burn and gas estimate (web3) | `genius_api` (`bridgeOut`, `getBrigeOutGasCost`) | - | Already async; no isolate needed |
| Job flow rules (precondition checks, ordering cost then gas then burn then process, outcome classification) | New `JobSubmission` owner in `lib/submit_job/` | - | One owning module per domain rule; phase 43 is the second caller |
| Dev fixture answers (cost, gas string, outcome, hashes, in-flight delay) | `JobSubmission` behind the one `kDebugMode && kShowDevTools` gate | `DevMockJob` (data only) | D-03 |
| State, emits, copy (error strings, step progression) | `SubmitJobCubit` | - | D-01; copy stays word for word |
| Double-submit guard | `SubmitJobCubit` | - | D-04 |
| Balance refetch after a burn (`fetchGnusBalanceWithDelay`) | `SubmitJobCubit` | `GnusCubit` | Pure UI refresh; stays |

## Standard Stack

No new packages. Everything needed is the Dart SDK and what `genius_api` already imports.

| Library | Version | Purpose | Source |
|---------|---------|---------|--------|
| `dart:isolate` (`Isolate.run`) | Dart 3.11.5 (Flutter 3.41.9) | Run one FFI call off the UI isolate and get the result or the thrown error back | [VERIFIED: probe run this session with `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin\cache\dart-sdk\bin\dart.exe`, Dart 3.11.5, version file at `flutter/flutter/bin/cache/dart-sdk/version`] |
| `dart:ffi` / `package:ffi` | already imported at `packages/genius_api/lib/src/genius_api.dart:1-11` | `toNativeUtf8`, `malloc`/`calloc` in the isolate entry | [VERIFIED: genius_api.dart:1-11] |
| `flutter_test`, hand-written fakes | existing | Tests (no mocktail) | [VERIFIED: test/submit_job/*.dart] |

**Version verification:** `dart --version` equivalent: `cat flutter/flutter/bin/cache/dart-sdk/version` returned `3.11.5`. No registry lookups were needed.

## Package Legitimacy Audit

Not applicable: this phase installs no external packages. `sealed` classes and pattern matching are Dart 3 language features, already used in the codebase (`switch` expressions at `lib/bloc/app_bloc.dart:270`).

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
UI step widgets (job_steps.dart)
   | openFilePicker() / bridgeTokens()
   v
SubmitJobCubit  -- owns state, emits, copy, isBridgingTokens guard (D-04)
   |  1. reads facts synchronously: walletDetailsCubit.state (chainId, rpcUrl, wallet address),
   |     gnusCubit.state.tokenInfo?.address, state.jobCost, state.uploadedJson
   |  2. builds JobFacts value, calls owner, awaits typed result
   |  3. maps result -> state.copyWith(...)  (strings live here)
   v
JobSubmission (new, lib/submit_job/)  -- no emits, no UI state
   |-- dev gate: kDebugMode && kShowDevTools && DevMockJob.instance.scenario.value != null
   |      yes -> answers from DevMockJob (cost 1234, '42.42 Gwei', outcome, hashes, 2 s delay)
   |      no  -> real path below
   |-- cost(jobJson)        --> GeniusApi.requestGeniusSDKCostAsync  --Isolate.run--> worker isolate
   |                                                                        loadGeniusSDKLibrary() -> GeniusSDKGetCost
   |-- estimateGas(facts)   --> GeniusApi.getBrigeOutGasCost (already async, web3 HTTP)
   |-- submit(facts, ...)   --> GeniusApi.bridgeOut (async web3)
   |                        --> GeniusApi.requestGeniusSDKProcessAsync --Isolate.run--> worker isolate
   |                                                                        loadGeniusSDKLibrary() -> GeniusSDKProcess
   v
Native SDK (same process; one global recursive_mutex serialises every entry point)
   ^
   |  main isolate still calls synchronously: GeniusSDKGetProcessingStatus (1 s AppBloc tick),
   |  balance reads (10 s) -- these wait on the same mutex while a job call holds it
```

### Recommended Project Structure

```
lib/submit_job/
├── cubit/submit_job_cubit.dart     # emits + copy only after plan 1
├── cubit/submit_job_state.dart     # unchanged
├── job_submission.dart             # the owner (name at planner's discretion)
└── job_submission_results.dart     # sealed results + JobFacts (or in the same file; two small files is fine)
packages/genius_api/lib/src/genius_api.dart   # + 2 async methods, - 2 sync methods (plan 2), + 2 top-level isolate entries
test/submit_job/job_submission_test.dart      # owner-level tests (new, plan 1)
test/submit_job/job_off_ui_isolate_test.dart  # throw-on-sync fake + frames widget test + grep guard (new, plan 2)
```

### Pattern 1: Owner with typed results (plan 1)

**What:** The owner exposes three calls plus the single dev gate. It returns sealed results; the cubit pattern-matches and emits. Facts come in as a value per call.
**When to use:** All three job-flow calls, so phase 43's handler can call the same three.

```dart
// Shape only - names are at the planner's discretion (D-01, Claude's Discretion).
class JobFacts {
  const JobFacts({this.chainId, this.rpcUrl, this.walletAddress, this.gnusAddress});
  final int? chainId;
  final String? rpcUrl;
  final String? walletAddress;
  final String? gnusAddress;
  bool get complete => chainId != null && rpcUrl != null && walletAddress != null && gnusAddress != null;
}

sealed class JobCostResult { const JobCostResult(); }
final class JobCostOk extends JobCostResult { const JobCostOk(this.minions); final int minions; }
final class JobCostFailed extends JobCostResult { const JobCostFailed([this.reason]); final String? reason; } // reason only set by the dev fixture

sealed class GasEstimateResult { const GasEstimateResult(); }
final class GasEstimateOk extends GasEstimateResult { const GasEstimateOk(this.gas); final String gas; }
final class GasEstimateMissingData extends GasEstimateResult { const GasEstimateMissingData(); }
final class GasEstimateFailed extends GasEstimateResult { const GasEstimateFailed(this.reason); final String? reason; } // resp.errorMessage passthrough

sealed class JobSubmitResult { const JobSubmitResult(); }
final class JobDone extends JobSubmitResult { const JobDone(this.txHash); final String txHash; }
final class JobBridgedNotProcessed extends JobSubmitResult { const JobBridgedNotProcessed(this.bridgeHash, this.processResult); final String bridgeHash; final GeniusNodeReturnValue processResult; }
final class JobBridgeFailed extends JobSubmitResult { const JobBridgeFailed(); }
final class JobMissingData extends JobSubmitResult { const JobMissingData(); }
```

The cost-zero case needs care: today a cost of 0 is not a thrown failure, it flows into `isGasFetchable` (section 4, row C4). Either map `0` to `JobCostFailed` in the owner and have the cubit treat both `JobCostFailed` and "gate false" as 'Unable to retrieve job cost', or return `JobCostOk(0)`. Keep the cubit's `isGasFetchable` expression in the cubit (it reads cubit state).

### Pattern 2: Async SDK call through `Isolate.run` with a top-level entry (plan 2)

**What:** The instance method keeps its main-isolate guards, then runs a top-level function that captures only a `String`. The isolate re-opens the library itself, exactly like the precedent, and returns the raw int. The main isolate maps it.
**Why not `Isolate.spawn` + `ReceivePort`:** the precedent hangs forever if the entry throws (verified below, Pitfall 3). `Isolate.run` rethrows the isolate's error to the awaiting caller.

```dart
// Source: probe run this session (Dart 3.11.5) + packages/genius_api/lib/src/genius_api.dart:64-87 (precedent)
/// Top-level, not a closure over GeniusApi: the isolate gets a String and nothing else.
int _geniusSdkCostIsolate(String jobJson) {
  final dylib = loadGeniusSDKLibrary();
  if (dylib == null) {
    return 0;
  }
  final lib = NativeLibrary(dylib);
  final ptr = jobJson.toNativeUtf8().cast<Char>();
  try {
    return lib.GeniusSDKGetCost(ptr);
  } finally {
    calloc.free(ptr);
  }
}

// inside GeniusApi - guards stay on the main isolate, byte for byte as today
Future<int> requestGeniusSDKCostAsync({required String jobJson}) async {
  if (jobJson.isEmpty || !_isSdkInitialized) {
    return 0;
  }
  try {
    return await Isolate.run(() => _geniusSdkCostIsolate(jobJson));
  } catch (e, stackTrace) {
    debugPrint('Error in GeniusSDKGetCost: $e');   // same log text and same 0-on-error as the sync version
    debugPrint('$stackTrace');
    return 0;
  }
}
```

`requestGeniusSDKProcessAsync` is the same shape: guards `!_isSdkInitialized -> GENIUS_NODE_ERROR_NOT_INITIALIZED`, `jobJson.isEmpty -> GENIUS_NODE_INVALID_ARGUMENT` (genius_api.dart:1088-1095), isolate returns the native `int`, main isolate does `_mapNodeReturnValue(int)` (genius_api.dart:415-422). Note the sync process version has no catch; a thrown isolate error should surface as an exception exactly as a thrown sync FFI error would (the cubit does not catch it today either, see Pitfall 5).

DRY: after D-09 deletes the sync versions, the FFI body exists only in the top-level entries. Do not leave a second copy in the instance methods.

### Anti-Patterns to Avoid
- **A closure that captures `this` inside `Isolate.run`:** it tries to copy the whole `GeniusApi` (BehaviorSubjects, `FFIBridgePrebuilt`, secure storage) into the worker. A plain-Dart probe happened to copy a StreamController-bearing object, so it is not guaranteed to throw, but the real graph holds `NativeLibrary` function tables and a stale `_isSdkInitialized` snapshot. The existing comment at genius_api.dart:1532-1534 says FFI objects are not sendable. Treat it as a hard rule: top-level entry, `String` argument only. [VERIFIED for the plain-Dart behaviour; the failure of the real `GeniusApi` graph is [ASSUMED], not needed to be proven because the rule avoids it]
- **A Dart-side queue "for safety":** the SDK already serialises (Q2). A queue would only add a second lock and a place for a stuck future.
- **`.index` where `.value` is meant:** the precedent sends `GENIUS_NODE_ERROR_NOT_INITIALIZED.index` (genius_api.dart:76) while the success path sends the native value. They coincide today (`GENIUS_NODE_ERROR_NOT_INITIALIZED(1)`, enum at genius_api_ffi.dart:1230-1238), but use `.value` in new code.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Run a function in a worker isolate and get its result or error | `Isolate.spawn` + `ReceivePort` + manual error port | `Isolate.run` | Rethrows the worker's error, closes the port, no hang |
| Serialising SDK calls | A Dart future queue / semaphore | Nothing (the SDK's own `GeniusSDKMutex`) | Already in the native layer for every public entry point |
| Result typing | String or bool flags | Dart 3 sealed classes + switch | D-02; exhaustive switch catches a missing branch at analysis time |
| Checking "cubit no longer calls X" | A custom lint | A `File(...).readAsStringSync()` test | Precedent: `test/banxa/buy_page_layout_test.dart:15` reads `lib/navigation/router.dart` the same way |

## Q1. Isolate precedent: what it relies on

Evidence, in order:

1. **Entry point is top-level and takes a `SendPort` plus a `String`** (`packages/genius_api/lib/src/genius_api.dart:64-87`). It does not receive any FFI handle. It calls `loadGeniusSDKLibrary()` itself (line 73) and builds a fresh `NativeLibrary(dylib)` (line 80). The doc comment says so: "Opens the native library independently (the OS shares code pages across isolates)" (lines 66-68).
2. **`loadGeniusSDKLibrary()`** (`packages/genius_api/lib/ffi_bridge_prebuilt.dart:23-36`): Android `DynamicLibrary.open('libGeniusWallet.so')` in a try/catch returning null; iOS/macOS `DynamicLibrary.open('GeniusWallet.framework/GeniusWallet')` with no catch; everything else `DynamicLibrary.executable()`. On Windows the SDK is linked whole-archive into the exe: "windows/runner/CMakeLists.txt:78 whole-archive links the /MT-only prebuilt sgns::GeniusSDK + TrustWalletCore into the .exe (on Windows the FFI bridge is DynamicLibrary.executable(), so the SDK MUST be in-process" [CITED: memory `geniuswallet-local-build.md`; consistent with windows/CMakeLists.txt:5-6 "The prebuilt native deps ... ship only a static release-CRT (/MT) build"]. A symbol lookup on the executable or loaded library handle is process-wide, so the worker reaches the same SDK globals (`GeniusNodeInstance`) as the main isolate.
3. **The precedent is in production use:** `lib/bloc/app_bloc.dart:926-931` awaits `api.selectGeniusAccountAsync(target)` for every SDK-account switch and treats a throw as a refusal.
4. **Dart-side state is not reachable in the worker.** `_isSdkInitialized` (genius_api.dart:435) and `_ffiBridgePrebuilt` (genius_api.dart:430) are instance fields of a `GeniusApi` on the main isolate. The worker has no `GeniusApi`. The precedent therefore checks `getStartAccountAddress() == null` on the main isolate before spawning (line 1554), and the new async methods must do the same with `_isSdkInitialized` before `Isolate.run`. This is already how section "Pattern 2" is written.
5. **`Isolate.run` vs closure capture** (probe, Dart 3.11.5, plain `dart`): a lambda `() => _top(s)` and a lambda that does not mention `this` both ran and returned. A lambda that referenced an instance field also ran in the plain-Dart probe (it copied the object), so "it throws" cannot be relied on, and "it works" cannot be relied on for the real `GeniusApi`. The safe form is the top-level entry in Pattern 2. [VERIFIED: probe output "topLevel: 3 / closure not using this: 6 / closure using this: 3"]
6. **Error behaviour** (same probe): `Isolate.run(() => throw StateError('boom'))` surfaced `StateError: Bad state: boom` to the awaiting caller. The precedent shape, `Isolate.spawn` whose entry throws, left `await receivePort.first` pending until the probe's 2 s timeout (printed "spawn precedent: hangs (timeout) when the entry throws"). On iOS/macOS `loadGeniusSDKLibrary()` can throw (line 33, no catch), so the precedent could hang the account switch there. Not in this phase's scope to fix; do not copy the shape. [VERIFIED: probe]

Answer to D-07's question: `Isolate.run` behaves the same with the library handle because no handle crosses the boundary; the worker always re-opens the library. Use it.

## Q2. Thread safety of the SDK

- **Evidence the SDK is thread-safe:** `GeniusSDK.cpp` declares `std::recursive_mutex GeniusSDKMutex;` with the comment "ponytail: serialize SDK calls with one lock; if this becomes a bottleneck, split node lifetime from read/write API locks." and every public function begins `const std::lock_guard<std::recursive_mutex> lock( GeniusSDKMutex );`. Verified on GitHub `GeniusVentures/GeniusSDK` `develop` at `54735bf` (2026-10-24) for `GeniusSDKProcess` (develop line 316-318), `GeniusSDKGetCost` (702-704), `GeniusSDKGetBalance` (396-398), `GeniusSDKGetProcessingStatus` (1037-1039), `GeniusSDKSelectGeniusAccount`, `GeniusSDKGetAvailableAccounts`, `GeniusSDKGetNodeState`. The functions without the lock (`GeniusSDKFree`, `GeniusSDKFreeTransactions`, `GeniusSDKMint`'s wrapper, `GeniusSDKMintGNUS`, `GeniusSDKGetRegistrationsForMain`) are not in the job flow. The commit that introduced it is `8342a5d` "Feat: Thread safety inserted", 2026-07-13, on `develop`. The wallet's local prebuilt `GeniusSDK/build/Windows/Release/GeniusSDK/lib/GeniusSDK.lib` is dated 2026-10-15, after that commit. [VERIFIED: `gh api repos/GeniusVentures/GeniusSDK/contents/src/GeniusSDK.cpp?ref=develop`, commit list for the file, `ls -l` of the prebuilt]
- **Which prebuilt each platform downloads is not confirmed here.** The wallet's cmake downloads per-platform prebuilts keyed on the dependency branch (memory `geniuswallet-local-build.md`: "Native build downloads prebuilt deps ... from GeniusVentures GitHub releases"); the Windows one is demonstrably post-mutex. [ASSUMED for Android/Linux/macOS: they are also built from a `develop` newer than 2026-07-13]
- **Other SDK calls on the main isolate that run concurrently with a job call** (all synchronous FFI, all take the same mutex):
  - `AppBloc` processing-status tick every 1000 ms: `lib/bloc/app_bloc.dart:253-259` -> `_onProcessingStatusTicked` -> `api.getProcessingStatus()` (`lib/bloc/app_bloc.dart:409`, `packages/genius_api/lib/src/genius_api.dart:2187-2189`).
  - Balance reads from `WalletOverview` (10 s timer, `lib/components/wallet_overview.dart:71-74`, rebuild-driven), `genius_balance_display.dart:59`, `network_page.dart:61` (3 s), `child_wallets_cubit.dart:101` (10 s), `child_operations_cubit.dart:549`.
- **What a job call holds the lock for:** `GeniusSDKGetCost` -> `GeniusNode::GetProcessCost` -> `GetGNUSPrice` -> `GetCoinprice({"genius-ai"})`, a live price request (SuperGenius `develop` `src/account/GeniusNode.cpp:3306-3345`, `GeniusNode.cpp:3175-3190` for `ProcessImage` which calls `GetProcessCost( *procmgr )` first and then splits and submits the task). The spike measured 100-800 ms for `gnus_estimate` and attributes it to "the SDK does a live coin-price HTTP request inside it" (`.planning/research/v4.0-webview-bridge-spike.md:73`). So `GeniusSDKProcess` is at least as long as the cost call.
- **Recommendation (D-08):** run cost and process off-isolate **unserialised** on the Dart side. The native mutex already makes concurrent calls safe; a Dart queue adds nothing. The precedent is not unsafe, so there is no blocker and plan 2 goes ahead. Do not write a `ponytail:` queue comment; write instead one `ponytail:` comment on the new async methods: "ceiling: the SDK holds one global mutex for the whole call (live price request inside), so main-isolate SDK polls wait behind it; upgrade path: SDK-ASYNC".
- **Residual freeze (carry into VERIFICATION):** a main-isolate poll that fires while the worker holds the mutex blocks the UI thread until the call returns. With a 1 s tick and a 100-800 ms call, a poll lands inside many calls. The user sees a shorter hitch, not none. This is not fixable inside "no UI change, no new capability" without moving or pausing the polls. It is a decision for Braian (Open Question 1), and the success-criterion-3 claim must be limited to "the call itself no longer runs on the UI isolate".

## Q3. Test approach for "fails if cost/process runs on the UI isolate"

**How fakes are built today:** hand-written `class _FakeGeniusApi implements GeniusApi` with a `noSuchMethod` forward; no mocktail. [VERIFIED: test/submit_job/submit_job_errors_test.dart:33-77, submit_job_outcome_test.dart:25-54, job_flow_test.dart:45-71]. Reason given in the files: the real `GeniusApi` constructor dlopens the native framework. Because it is `implements` + `noSuchMethod` forwarding to `super.noSuchMethod`, **any method the fake does not override throws `NoSuchMethodError` when called**. That is the cheapest robust mechanism: it already makes "the owner called a method the test did not expect" fail.

Concretely:

1. **Throw-on-sync fake (D-10, proves "owner never calls the sync SDK methods"):** a fake that overrides `requestGeniusSDKCost` / `requestGeniusSDKProcess` to `throw StateError('sync SDK call on the UI isolate')` and answers the `...Async` ones. Run the full owner flow (cost, gas, submit) and `bridgeTokens()` through it. Note: once plan 2 deletes the sync methods from `GeniusApi`, a fake can no longer `@override` them (analyzer error), so the sync-throw test is only meaningful if the sync methods still exist when the test is written. Two options, pick one in the plan:
   - Keep the throw-on-sync fake in plan 2 *before* the delete task and rely on the source-grep guard afterwards; or
   - (simpler) skip the throw-on-sync fake entirely: once the sync methods are deleted, the compiler is the guard ("no caller in `lib/` may use the sync versions", D-09), and a fake that overrides only the `...Async` methods fails with `NoSuchMethodError` if the owner reaches for anything else. Add the source-grep guard for `lib/` as the explicit test. Recommended.
2. **Source-grep guard (D-06):** one test reading `lib/submit_job/cubit/submit_job_cubit.dart` and asserting it contains none of `bridgeOut`, `getBrigeOutGasCost`, `requestGeniusSDKCost`, `requestGeniusSDKProcess`; and one sweep of `lib/` asserting no file other than the owner calls the sync names. Precedent for reading `lib/` files from a test: `test/banxa/buy_page_layout_test.dart:15` and `Directory('lib').listSync(recursive: true)` at `test/tokens/coin_page_entry_parity_test.dart:82`. Careful: the cubit file and `job_steps.dart`/`dev_mock_job.dart` mention these names in comments (grep earlier: `job_steps.dart:392,773`, `dev_mock_job.dart:12,14`, `submit_job_state.dart:23`, `submit_job_cubit.dart:235,383,492`). Match call syntax (`.requestGeniusSDKCost(` / `.bridgeOut(`), or strip `//` comment lines, or the guard fails on prose.
3. **Frames keep pumping (D-10 widget test):** fake `requestGeniusSDKProcessAsync` returns `Completer<GeniusNodeReturnValue>().future`; drive `bridgeTokens()` without awaiting it; pump `JobInFlightBody` (it contains `GWSpinner`, `lib/submit_job/view/widgets/job_steps.dart:410-423`) for N fixed `tester.pump(const Duration(milliseconds: 100))` calls; assert `cubit.state.isBridgingTokens` is true and the tester drew N frames (e.g. count with `tester.binding.addPersistentFrameCallback`, or check the spinner's animation advanced); then complete the completer and assert the terminal outcome. Use fixed pumps, not `pumpAndSettle` (the spinner never settles). **Honest limit:** inside `flutter test` a sync fake would not block anything, so this test proves the flow awaits the call and the UI stays live around it; it cannot prove the real FFI runs on a worker. The real proof is the compile-level removal of the sync API plus the phase 48 walk.
4. **Pending-timer trap:** the `done` and `bridgedNotProcessed` paths call `unawaited(fetchGnusBalanceWithDelay())`, a 5000 ms `Future.delayed` (`submit_job_cubit.dart:550-553`). In a `testWidgets` body this leaves a pending timer unless the test pumps past 5 s or the cubit is closed first (`fetchGnusBalanceWithDelay` re-emits only if the cubit is open; `fetchGnusBalance` emits behind `!isClosed`). Existing widget tests that reach `done` do `await harness.cubit.bridgeTokens()` before `pumpWidget`; copy that order or end with `await tester.pump(const Duration(seconds: 6))`.

## 4. Extraction map: `SubmitJobCubit` lines touching `geniusApi`, `walletDetailsCubit`, `gnusCubit`, `DevMockJob`

Line numbers are `lib/submit_job/cubit/submit_job_cubit.dart`. The CONTEXT line hints (`_resolveJobCost ~229`, `getBridgeOutGasCost ~307`, `bridgeTokens ~356`, `_bridgeTokensFromDevFixture ~494`) are exact. [VERIFIED: file read this session]

| # | Lines | Touches | What it does | Emit(s) it feeds | Moves to owner? |
|---|-------|---------|--------------|------------------|-----------------|
| C1 | 30-31 | `DevMockJob.instance.scenario.value`, `kDebugMode`, `kShowDevTools` | `DevJobScenario? get _devJobScenario => (kDebugMode && kShowDevTools) ? DevMockJob.instance.scenario.value : null;` the one gate | - | Gate moves to owner (`devScenario`); cubit's `fetchGnusBalance`, listener and `close()` read it from the owner so there is still ONE place. Keep the `close()` gate identical to the constructor gate (lines 46-53 and 625-634) |
| C2 | 46-53, 625-634 | `DevMockJob.instance.scenario.addListener/removeListener` | Re-price listener | `_repriceForDevScenario` emits | Stays in cubit (UI re-price trigger, not job flow) but uses the owner's gate |
| C3 | 56-59, 115, 133 | `gnusCubit.fetchGnusBalance()`, `gnusCubit.fetchGnusInfo()` | Balance and token info into state; `'Unable to fetch GNUS balance'` (119), `'Unable to fetch token information'` (136) | `gnusBalance`, `gnusTokenDetails`, `costError` | Stays in cubit |
| C3b | 104-113 | `_devJobScenario`, `DevMockJob.instance.balance` | Dev balance intercept: `emit(state.copyWith(gnusBalance: balance))` | `gnusBalance` | Stays in cubit; reads `owner.devScenario` and `DevMockJob.instance.balance` (or an owner getter `devBalance`) |
| C4 | 229-305 `_resolveJobCost(dynamic jsonData)` | `_devJobScenario`, `DevMockJob`, `geniusApi.requestGeniusSDKCost`, `state.gnusTokenDetails.address`, then `getBridgeOutGasCost` | see sub-rows | `jobCost` (returned, emitted by caller), `costError`, `jobGasCost`, `gnusBalance` | Cost call + dev answers move; orchestration (`isGasFetchable`) stays |
| C4a | 231-273 dev branch | `DevMockJob.instance.costShouldFail`, `.balance`, `DevMockJob.costErrorMessage`, `.jobCost`, `.jobGasCost` | `costShouldFail`: `jobCost = 0`, emit `costError: DevMockJob.costErrorMessage, gnusBalance: fixture.balance`. Else `jobCost = DevMockJob.jobCost` (1234), emit `jobGasCost: DevMockJob.jobGasCost, gnusBalance: fixture.balance` in ONE emit. Skips both `requestGeniusSDKCost` and `getBridgeOutGasCost` entirely and skips the `isGasFetchable` gate | as listed | Fixture answers move into the owner; the cubit keeps the emit but must still bypass the gate (see Pitfall 6) |
| C4b | 275 | `geniusApi.requestGeniusSDKCost(jobJson: jsonEncode(jsonData))` | Sync SDK cost on the UI isolate. `jsonEncode(jsonData)` on a `null` yields `"null"` (non-empty), so the SDK guard `jobJson.isEmpty` does not catch it | - | Moves; becomes `await owner.cost(jsonEncode(jsonData))` -> async in plan 2 |
| C4c | 277-280 | `jsonData != null`, `state.gnusTokenDetails.address != null`, `jobCost != 0` | `isGasFetchable`. **Reads SubmitJobState's `gnusTokenDetails`, not `gnusCubit.state.tokenInfo`** | - | Stays in cubit (reads cubit state). Do not "simplify" the two token sources into one: tests call `cubit.fetchGnusTokenInfo()` first precisely to satisfy this (`submit_job_errors_test.dart:359-362`) |
| C4d | 294-301 | `getBridgeOutGasCost(jobCost)` / `setCostError('Unable to retrieve job cost')` | Gas attempt when fetchable, else costError. Neither returns early: the file is KEPT and `jobCost` is returned and emitted by the caller (test: `submit_job_errors_test.dart:353-379`) | `costError` / `jobGasCost` then caller emits `jobCost` | Stays (orchestration) |
| C5 | 307-354 `getBridgeOutGasCost(int jobCost)` (public) | `walletDetailsCubit.state.selectedNetwork` (`.chainId`, `.rpcUrl`), `walletDetailsCubit.state.selectedWallet?.address`, `gnusCubit.state.tokenInfo?.address`, `geniusApi.getBrigeOutGasCost(...)` | Reads five facts synchronously, then the call. Destination chain `15305752297694` literal (332) | `costError`, `jobGasCost` | Call moves to owner (`estimateGas(facts, cost)`); the read of the five facts stays in cubit and is passed as `JobFacts`. Public method name `getBridgeOutGasCost` is only called from line 296 (no `lib/` or `test/` caller) |
| C6 | 356-376 | state only | First emit: `isBridgingTokens: true, outcome: SubmitOutcome.notSubmitted, submitError: ''` BEFORE any await | as listed | Stays; order is load-bearing (comment 358-368, test `submit_job_outcome_test.dart:215-241`) |
| C7 | 386-389 | `_devJobScenario` -> `_bridgeTokensFromDevFixture()` | Dev check sits BEFORE the precondition guard | - | Moves into `owner.submit`; the cubit must still evaluate "is dev" once at the top to skip the balance refetch (C9) |
| C8 | 391-416 | `walletDetailsCubit.state`, `gnusCubit.state.tokenInfo?.address`, `state.jobCost`, `state.uploadedJson` | Precondition guard. Emit on failure: `isBridgingTokens: false, submitError: 'Missing required data. Please select a wallet and network.'` | as listed | Rule moves to owner (`JobMissingData`); message stays in cubit |
| C9 | 418-441 | `geniusApi.bridgeOut(sourceChainId, contractAddress, rpcUrl, address, amountToBurn: state.jobCost.toString(), destinationChainId: 15305752297694)` | Burn. On `!isSuccess || data == null`: emit `isBridgingTokens: false, outcome: SubmitOutcome.bridgeFailed, submitError: 'Bridge transaction failed. Please try again.'`. The bridge's own `errorMessage` is deliberately NOT surfaced | as listed | Moves; maps to `JobBridgeFailed` |
| C10 | 446-468 | `geniusApi.requestGeniusSDKProcess(jobJson: jsonEncode(uploadedJson))` | `!= GENIUS_NODE_RET_OK`: `unawaited(fetchGnusBalanceWithDelay())` THEN emit `isBridgingTokens: false, outcome: bridgedNotProcessed, bridgeHash: txHash, submitError: _processErrorMessage(processResult)`. `txHash` stays empty on purpose | as listed | Call moves; maps to `JobBridgedNotProcessed(bridgeHash, processResult)`; refetch + emit stay in cubit |
| C11 | 470-480 | `fetchGnusBalanceWithDelay()` | Success: `unawaited(fetchGnusBalanceWithDelay())` THEN emit `txHash: txHash, outcome: done, isBridgingTokens: false` | as listed | Stays (cubit) |
| C12 | 494-546 `_bridgeTokensFromDevFixture` | `DevMockJob.instance.outcome`, `.inFlightDelay`, `.txHash`, `.bridgeHash`, `.processFailure`, `_processErrorMessage` | `await Future.delayed(DevMockJob.inFlightDelay)` (2 s), switch on `fixture.outcome`. Dev paths do NOT refetch the balance (comment 543-545) | as C9-C11 | Fixture answers move to owner (`submit` returns `JobDone(DevMockJob.txHash)` etc.); the `bridgeFailed` dev text equals the production text byte for byte; `bridgedNotProcessed` dev text goes through the same `_processErrorMessage` |
| C13 | 602-621 `_processErrorMessage` | `GeniusNodeReturnValue` | Copy mapping | `submitError` | Stays in cubit (copy). Owner returns the raw `GeniusNodeReturnValue` |
| C14 | 332, 424 | literal | `15305752297694`, TODO unhardcode | - | One constant in the owner (same value, CONTEXT "Established Patterns"). Do not change the value |

### Outcomes and strings that must be preserved word for word

| Where | Outcome / state | Exact text (copy from the file, do not retype) |
|-------|-----------------|------------------------------------------------|
| line 119 | balance missing | `Unable to fetch GNUS balance` |
| line 136 | token info missing | `Unable to fetch token information` |
| line 300 | cost 0 or token address / json missing | `Unable to retrieve job cost` |
| lines 320-322 | gas: any of network/chainId/gnusAddress/walletAddress/rpcUrl null | `Missing required data for bridge gas estimation. Please select a wallet and network.` (sets `costError`) |
| lines 342-347 | gas failed | `resp.errorMessage` if non-null and non-empty, else `Failed to estimate bridge gas cost.` (also when `resp.data == null`) |
| lines 410-411 | submit missing data | `Missing required data. Please select a wallet and network.` (sets `submitError`, `isBridgingTokens: false`, outcome stays `notSubmitted`) |
| lines 436-437, 517 | bridge failed | `Bridge transaction failed. Please try again.` with `SubmitOutcome.bridgeFailed`, hashes untouched |
| lines 461-463 | bridged, process failed | `SubmitOutcome.bridgedNotProcessed`, `bridgeHash = txHash`, `txHash` empty, `submitError = _processErrorMessage(result)` |
| lines 474-478 | done | `SubmitOutcome.done`, `txHash` set, `bridgeHash` empty |
| lines 604-619 | process messages | `SDK not initialized. Please restart the app and try again.` / `Failed to process the job. Please check your input and try again.` / `Couldn't create the job's tokens.` / `Invalid job data.` / `Token transfer failed.` / `Payment to dev failed.` / `Child wallet registration failed.` / `` (empty for RET_OK) |
| dev_mock_job.dart:130-131 | dev cost failure | `DEV fixture: pricing forced to fail (DevJobScenario.costFailure)` |
| submit_job_state.dart:78 | default | `jobGasCost = '0.00 Gwei'` (reset to `'0.00 Gwei'` in `_repriceForDevScenario` line 88; `resetState` sets `''`) |

Behaviours that are easy to lose in an extraction:
- The cost call happens even when the wallet or network is missing (test `submit_job_errors_test.dart:381-403`: cost 10, no network -> the gas-missing-data message, file kept, `jobCost` emitted).
- In the real path the gas emit (`jobGasCost`) lands BEFORE the caller's `jobCost` emit (C4d runs inside C4 which returns before `openFilePicker` emits `jobCost`, line 183-193). Keep the order.
- All emits after an `await` are guarded by `!isClosed`; the owner must never emit, so the guard stays in the cubit.
- `bridgeTokens` reads walletDetails/gnusCubit/`state` synchronously after the first emit and before the first `await`. When the cubit builds `JobFacts` it must do so at the same point so a wallet switch during the burn cannot change the target of an in-flight call (today's behaviour).

## Common Pitfalls

### Pitfall 1: The UI still hitches when a poll lands inside the job call
**What goes wrong:** Cost and process now run on a worker isolate, but `AppBloc`'s 1 s `getProcessingStatus()` and the balance reads are synchronous FFI on the UI isolate and wait on the SDK's global mutex while the worker holds it.
**Why it happens:** `GeniusSDKMutex` is held for the whole call, including the live price request (Q2).
**How to avoid:** Do not promise more than the call moving off-isolate. Record the ceiling in a `ponytail:` comment and in VERIFICATION. Phase 48's walk checks the real feel. A fix (pause the polls while a job call is in flight, or SDK-ASYNC) is a separate decision.
**Warning signs:** a real-SDK walk shows a shorter-than-before but visible stutter once a second during pricing.

### Pitfall 2: Fakes no longer match after plan 2
**What goes wrong:** Three test fakes override only the sync `requestGeniusSDKCost` / `requestGeniusSDKProcess` (`submit_job_errors_test.dart:43,72`; `submit_job_outcome_test.dart:48`; `job_flow_test.dart:66`). After the owner switches to the async methods, `noSuchMethod` throws `NoSuchMethodError` in every flow test, and `@override` on a deleted sync method is an analyzer error.
**How to avoid:** Plan 1 must NOT change them (success criterion 1: tests pass unchanged). Plan 2 updates exactly those three files to override `...Async` and keeps assertions identical. `test/dashboard/compute_panel_wiring_test.dart` and `test/dev/dev_mock_job_test.dart` do not call the flow and need no change.
**Warning signs:** `NoSuchMethodError: ... requestGeniusSDKCostAsync` in `test/submit_job/`.

### Pitfall 3: Copying the `Isolate.spawn` + `ReceivePort` precedent hangs on a worker error
**What goes wrong:** If the entry throws, `await receivePort.first` never completes and the panel stays on the in-flight step forever (`isBridgingTokens` stays true; the submit button's retry never appears).
**How to avoid:** `Isolate.run`. [VERIFIED: probe]

### Pitfall 4: Dev gate untestable under `flutter test`
**What goes wrong:** `kShowDevTools` is `bool.fromEnvironment('GW_DEV_TOOLS')`, false under `flutter test` (`lib/dev/dev_flags.dart:15`; `test/dev/dev_mock_job_test.dart:6-12`). So the dev branches are unreachable in tests by construction and a moved-but-broken fixture would not fail any test.
**How to avoid:** The testable half of D-03's "release-safety property" is: with `DevMockJob.instance.arm(...)` armed and the gate closed, the owner still takes the real path. Add one owner test: arm `DevJobScenario.bridgeFailed`, call `submit` with a fake API that succeeds, expect `JobDone`. Always `DevMockJob.instance.clear()` in `tearDown` (the singleton leaks across tests; `dev_mock_job_test.dart:14-15` does this). For the fixture's own answers, test the pure mapping `SubmitOutcome -> JobSubmitResult` if it is factored as a pure function, since the gate cannot be opened.

### Pitfall 5: Behaviour change in error handling
**What goes wrong:** `requestGeniusSDKCost` catches and returns 0 (genius_api.dart:1123-1126); `requestGeniusSDKProcess` does not catch (1100-1107). Wrapping both in the same try/catch would turn a thrown process error into `GENIUS_NODE_RET_OK`-adjacent behaviour or swallow it.
**How to avoid:** Mirror each exactly: cost async catches and returns 0; process async lets the isolate error propagate. The cubit does not catch it today, so a throw leaves `isBridgingTokens: true`, which is existing behaviour; do not "fix" it in this phase.

### Pitfall 6: Dev branch loses its gate bypass
**What goes wrong:** In dev, `_resolveJobCost` skips `isGasFetchable` entirely (C4a). If the owner returns dev answers but the cubit still runs `isGasFetchable`, a dev walk with no token info shows `Unable to retrieve job cost`.
**How to avoid:** Keep an explicit `if (owner.devScenario != null)` branch in the cubit's pricing orchestration that emits the fixture's balance/gas/costError exactly as today, or have the owner return a result that carries the balance. Either way the dev walk must behave as before. Capture "is dev" once at the top of `bridgeTokens` (C7) so a scenario cleared mid-flight cannot flip the balance-refetch decision halfway.

### Pitfall 7: Environment, not code
**What goes wrong:** This worktree has no `.dart_tool` and empty `banxa/`, `squidrouter/`, `tokeninfo/` submodule dirs (`git submodule status` shows a leading `-` on all three) while `pubspec.yaml:69` has `path: squidrouter`. `flutter pub get` and any `flutter test` fail until the submodules are initialised.
**How to avoid:** See Environment Availability. Submodule init is a git-state action: executor only (AGENTS.md "Working in parallel sessions").

## Code Examples

### Cubit after plan 1 (shape; strings copied unchanged from the current file)
```dart
// bridgeTokens, after the opening emit (lines 369-375 stay as they are)
final isDev = jobSubmission.devScenario != null;      // captured once, before any await
final facts = JobFacts(                               // read synchronously, same point as today
  chainId: walletDetailsCubit.state.selectedNetwork?.chainId,
  rpcUrl: walletDetailsCubit.state.selectedNetwork?.rpcUrl,
  walletAddress: walletDetailsCubit.state.selectedWallet?.address,
  gnusAddress: gnusCubit.state.tokenInfo?.address,
);
final result = await jobSubmission.submit(facts, jobCost: state.jobCost, jobJson: state.uploadedJson);
switch (result) {
  case JobMissingData():
    // emit isBridgingTokens: false + submitError 'Missing required data. Please select a wallet and network.'
  case JobBridgeFailed():
    // emit isBridgingTokens: false, outcome: bridgeFailed, submitError 'Bridge transaction failed. Please try again.'
  case JobBridgedNotProcessed(:final bridgeHash, :final processResult):
    if (!isDev) { unawaited(fetchGnusBalanceWithDelay()); }   // before the emit, as today
    // emit outcome: bridgedNotProcessed, bridgeHash, submitError: _processErrorMessage(processResult)
  case JobDone(:final txHash):
    if (!isDev) { unawaited(fetchGnusBalanceWithDelay()); }
    // emit txHash, outcome: done, isBridgingTokens: false
}
```
Every emit stays behind `if (!isClosed)`. Braces on every `if`, body on its own line (`tool/check_brace_style.sh`, AGENTS.md).

### Owner-level test fake for plan 2 (shape)
```dart
class _FakeAsyncGeniusApi implements GeniusApi {
  int cost = 10;
  GeniusNodeReturnValue process = GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  Completer<GeniusNodeReturnValue>? processGate;     // set to hold the call pending

  @override
  Future<int> requestGeniusSDKCostAsync({required String jobJson}) async => cost;

  @override
  Future<GeniusNodeReturnValue> requestGeniusSDKProcessAsync({required String jobJson}) =>
      processGate?.future ?? Future.value(process);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `Isolate.spawn` + `ReceivePort` + manual reply | `Isolate.run` | Dart 2.19 | Error propagation, no leaked port, no hang |
| Sync FFI on the UI isolate for cost/process | Worker isolate re-opening the library | this phase | Removes the call itself from the UI thread; the SDK mutex still couples polls to it (Pitfall 1) |

**Deprecated/outdated:** none in play.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Android, Linux and macOS prebuilts are built from a `develop` that includes the 2026-07-13 mutex commit (only the Windows prebuilt's date was checked) | Q2 | If an older SDK without the mutex is linked on some platform, concurrent job-call + poll could race inside the native layer. Mitigation if wrong: add a Dart-side queue around the SDK job calls (the D-08 fallback) |
| A2 | A closure capturing the real `GeniusApi` would fail or misbehave in `Isolate.run` (plain-Dart probe copied an equivalent object without error) | Q1, Anti-patterns | None if the top-level-entry rule is followed; only matters if someone is tempted to simplify |
| A3 | `GeniusSDKProcess` holds the mutex for at least as long as the cost call (it calls `GetProcessCost` first), so the residual-freeze caveat applies to it too | Q2, Pitfall 1 | The caveat would be smaller for process. Does not change the design |
| A4 | The only remaining `lib/` callers of the sync `requestGeniusSDKCost` / `requestGeniusSDKProcess` after the cubit is migrated are none (grep this session found only `submit_job_cubit.dart:275,446` in code; the other hits are comments) | D-09 | If missed, deleting the sync methods breaks a build; the compiler will say so |
| A5 | `ProcessImage`'s extra work beyond pricing (task split, publish) is short relative to the price request | Q2 | If it is long, the poll-block window is longer; no design change |

## Open Questions

1. **Does Braian accept the residual poll-blocks-on-mutex hitch for now?**
   - What we know: the call moves off the UI isolate; the SDK mutex still makes the 1 s status poll wait behind a 100-800 ms job call.
   - What's unclear: whether "keeps animating" is meant strictly.
   - Recommendation: ship as D-07/D-10 describe, write the ceiling into a `ponytail:` comment and VERIFICATION, and let the phase 48 walk decide whether to add "skip the processing-status tick while a job call is in flight" (small, but it is a behaviour/UI-adjacent change and was not asked for).
2. **Where should the cost-0 case live in the sealed type?** (`JobCostFailed` vs `JobCostOk(0)`)
   - What we know: the cubit's `isGasFetchable` depends on cubit state too, so the user-visible `Unable to retrieve job cost` is produced by a combination (C4c).
   - Recommendation: owner returns `JobCostOk(n)` for any int the SDK returns, including 0; the cubit keeps `isGasFetchable` and the message. `JobCostFailed` is then only produced by the dev fixture. Simplest, and no behaviour moves.
3. **Owner built inside the cubit or injected?**
   - Recommendation: keep the cubit constructor signature unchanged (`walletDetailsCubit`, `gnusCubit`, `geniusApi`; 16+ test sites use `super.geniusApi`) and add an optional `JobSubmission? jobSubmission` that defaults to `JobSubmission(geniusApi: geniusApi)`. Phase 43 then constructs its own, or receives the same one.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | all tests, analyze | Present, not on PATH | 3.41.9 / Dart 3.11.5 at `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin` [VERIFIED: `bin/cache/dart-sdk/version` = 3.11.5; CI pins `flutter-version: 3.41.9` at `.github/workflows/build.yml:385`; memory `geniuswallet-local-build.md`] | `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"` per shell call |
| Package config for this worktree | `flutter test` | No: `.dart_tool/package_config.json` missing | - | `flutter pub get` after submodules |
| Git submodules `banxa`, `squidrouter`, `tokeninfo` | `flutter pub get` (`pubspec.yaml:69 path: squidrouter`) | No: empty dirs, `git submodule status` shows `-72f33d07...`, `-77a24e1b...`, `-0a461635...` | - | `git submodule update --init` (needs the HTTPS rewrite from memory `geniuswallet-local-build.md`: `git config --global url."https://github.com/GeniusVentures/".insteadOf "git@github.com:GeniusVentures/"`). Executor only. Or run verification from the main checkout `C:\Users\User\Documents\Projects\GNUS\GeniusWallet` where `build/` exists, after merging |
| Native SuperGenius SDK | none of the tests | Not needed | - | Fakes cover everything; real SDK only for the phase 48 walk |
| Lint scripts | brace style gate | `tool/check_brace_style.sh` present | - | `bash tool/check_brace_style.sh` |

**Missing dependencies with no fallback:** none, once the executor initialises submodules and runs `flutter pub get`.
**Missing dependencies with fallback:** package config and submodules (above).

## Validation Architecture

`workflow.nyquist_validation` is `true` in `.planning/config.json:31`.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (Flutter 3.41.9), hand-written fakes, no mocktail |
| Config file | none beyond `pubspec.yaml`; analyzer rules in `analysis_options.yaml` and `packages/genius_api/analysis_options.yaml` (nearest file wins) |
| Setup (once, executor) | `git submodule update --init` then `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"; flutter pub get` from the worktree root |
| Quick run command | `flutter test --no-pub test/submit_job test/dev/dev_mock_job_test.dart test/dashboard/compute_panel_wiring_test.dart` |
| Full suite command | `flutter test --no-pub --test-randomize-ordering-seed random` (CI uses this without `--no-pub`, `.github/workflows/build.yml:1611`) |
| Static gates | `dart format --output=none --set-exit-if-changed lib test packages/genius_api/lib/src/genius_api.dart`, `flutter analyze --no-pub lib test packages/genius_api` (exits 1 on infos; capture `$?` before any pipe), `bash tool/check_brace_style.sh` |

Baselines: do not quote one from memory. The recorded ones are stale (`512 pass / 1 fail` on 2026-07-28; `788` on another branch). The executor runs the suite at the start of plan 1 and records the number. [CITED: memory `analyzer-config-gotchas.md`, `phase-23-in-progress.md`]

### Phase Requirements -> Test Map
| Req / criterion | Behavior | Test Type | Automated Command | File Exists? |
|-----------------|----------|-----------|-------------------|--------------|
| Criterion 1 (extraction, outcomes unchanged) | Every existing flow, error-channel and outcome test passes UNCHANGED after plan 1 | unit + widget | `flutter test --no-pub test/submit_job` (run before and after the cubit edit; zero edits to these files in plan 1) | Yes: `job_flow_test.dart`, `submit_job_errors_test.dart`, `submit_job_outcome_test.dart`, `submit_job_cta_state_test.dart` |
| Criterion 1 (dev-mock scenarios, double-submit guard) | Fixture mapping and listener semantics unchanged | unit | `flutter test --no-pub test/dev/dev_mock_job_test.dart`; guard: `submit_job_outcome_test.dart:215` retry-clears-outcome | Yes |
| Criterion 1 / D-03 (release-safety) | With a scenario armed and the gate closed, the owner uses the real path | unit | `flutter test --no-pub test/submit_job/job_submission_test.dart` | No: Wave 0 (plan 1) |
| Criterion 2 / D-06 | `submit_job_cubit.dart` has no direct call to `bridgeOut`, `getBrigeOutGasCost`, `requestGeniusSDKCost`, `requestGeniusSDKProcess` | source-grep unit | `flutter test --no-pub test/submit_job/job_off_ui_isolate_test.dart --plain-name "cubit makes no direct"` | No: Wave 0 (plan 1 adds the cubit half; plan 2 adds the `lib/` sweep for the sync names) |
| Owner behaviour (typed results, ordering, strings) | cost -> gas -> burn -> process; every sealed branch | unit | `flutter test --no-pub test/submit_job/job_submission_test.dart` | No: Wave 0 (plan 1) |
| Criterion 3 / D-09, D-10 (no sync SDK on the UI isolate) | Owner only reaches the `...Async` methods; sync methods deleted from `GeniusApi`; `lib/` has no sync callers | compile + source-grep unit | `flutter analyze --no-pub lib test packages/genius_api` plus the grep test above | No: Wave 0 (plan 2) |
| Criterion 3 / D-10 (UI keeps pumping) | While the async process (and cost) fake is pending, frames keep drawing and `isBridgingTokens` stays true; completing it lands the terminal | widget | `flutter test --no-pub test/submit_job/job_off_ui_isolate_test.dart --plain-name "keeps pumping"` | No: Wave 0 (plan 2) |
| Criterion 3 (real SDK, real feel) | Panel keeps animating during a real cost/process call; residual poll hitch measured | manual walk | Phase 48 walk. Write it into VERIFICATION as deferred, not as passed | Manual-only: needs the native SDK, which `flutter test` cannot load |

### Sampling Rate
- **Per task commit:** the quick run command (under 30 s for the submit_job folder).
- **Per wave merge:** full suite plus `dart format` and `flutter analyze` and `bash tool/check_brace_style.sh`.
- **Phase gate:** full suite green (compare to the baseline recorded at plan 1 start) before `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] `test/submit_job/job_submission_test.dart`: owner-level tests with a hand fake (cost, gas missing/failed/ok, submit missing/bridgeFailed/bridgedNotProcessed/done, release-safety armed-but-gated case, `DevMockJob.instance.clear()` in tearDown). Plan 1.
- [ ] `test/submit_job/job_off_ui_isolate_test.dart`: cubit-file grep guard (plan 1), `lib/` sync-name sweep and frames-keep-pumping widget test (plan 2).
- [ ] Update the three fakes to `...Async` in plan 2 only: `submit_job_errors_test.dart`, `submit_job_outcome_test.dart`, `job_flow_test.dart`.
- [ ] Environment: submodules + `flutter pub get` (executor, before any command above).

## Security Domain

`security_enforcement` is `true` (`.planning/config.json:56`), ASVS level 1.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | - |
| V3 Session Management | no | - |
| V4 Access Control | no (phase 43 gates callers) | - |
| V5 Input Validation | yes | The job JSON is a user-picked file; the 5 MB cap and parse stay in the cubit (`_maxJobFileBytes`, line 38). Owner must still return `JobMissingData` for empty `uploadedJson` and zero cost before any burn. The new isolate entries must keep the empty-string guard on the main isolate |
| V6 Cryptography | no new use | No keys cross the isolate boundary: the worker receives only the job JSON string. Nothing derived from a seed or key is added to a Cubit state (AGENTS.md wallet safety) |
| V7 Error handling / logging | yes | Do not log job JSON or wallet addresses in the new `debugPrint`s; the existing cost log prints only the exception and stack trace |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Burn then process fails (money moved, job not started) | Repudiation/Tampering of outcome | Preserve `bridgedNotProcessed` with `bridgeHash` as proof, `txHash` empty (C10) |
| Double burn from overlapping submits | Tampering | D-04: guard stays in cubit; cross-caller lock is phase 43 |
| Dev fixture reachable in release | Elevation of privilege/Spoofing | One gate `kDebugMode && kShowDevTools` in the owner; test the gated-closed case (Pitfall 4) |
| Worker isolate memory leak of native strings | DoS | `calloc.free` in `finally` inside the isolate entry, as the precedent does with `malloc.free` (genius_api.dart:84) and the sync versions do (1106, 1129) |

## Project Constraints (from CLAUDE.md / AGENTS.md)

- Refactor first, then change behaviour; never mix in one diff (AGENTS.md "Dart coding standards" plus "Change discipline"; D-05).
- Brace every `if`, body on its own line; same-line `{` (enforced by `tool/check_brace_style.sh`).
- Widgets, not helper methods; Rule of Three for extraction. The owner is a class, not a widget; do not add a second abstraction (interfaces, factories) for the one second caller that does not exist yet.
- Cubit -> repository layering: no SDK or `Hive`/`File` in widgets. The cubit already uses `File` for the picker; do not add more.
- Wallet safety: no key or mnemonic on a state class; `Random.secure()` only; none apply to this phase but nothing new may log job content tied to a wallet.
- Colours come from tokens: no UI change in this phase.
- Do not create commits (AGENTS.md); GSD atomic commits are separately authorised (memory `gsd-commits-authorized.md`). Executor only touches git. Subagent commits must have no Claude trailer (global CLAUDE.md; memory `gsd-agents-add-claude-trailer.md`).
- Files under `/banxa` and `/squidrouter` (repo root) are generated: do not touch.
- Before calling anything done: `dart format`, `flutter analyze`, `flutter test`; quote real output; Flutter SDK is not on PATH.
- Comments minimal, only the why. Mark deliberate simplifications with `ponytail:` naming ceiling and upgrade path (needed once, on the async SDK methods).
- Parallel sessions: this research session wrote only this file; the executor owns commits and `flutter test` baselines.

## Sources

### Primary (HIGH confidence)
- `packages/genius_api/lib/src/genius_api.dart` (read this session): 64-87 isolate entry, 415-422 `_mapNodeReturnValue`, 424-455 fields, 1088-1133 sync process/cost, 1531-1565 `selectGeniusAccount` + async, 1988-2064 `bridgeOut`/`getBrigeOutGasCost`, 2187-2190 `getProcessingStatus`
- `packages/genius_api/lib/ffi_bridge_prebuilt.dart:1-36`; `packages/genius_api/lib/ffi/genius_api_ffi.dart:1230-1254` (`GeniusNodeReturnValue`)
- `lib/submit_job/cubit/submit_job_cubit.dart`, `submit_job_state.dart`; `lib/dev/dev_mock_job.dart`, `dev_flags.dart`; `lib/bloc/app_bloc.dart:253-259, 905-949`
- `test/submit_job/*.dart`, `test/dev/dev_mock_job_test.dart`, `test/dashboard/compute_panel_wiring_test.dart`
- GeniusSDK `src/GeniusSDK.cpp` on `develop` @ `54735bf` (2026-10-24) via `gh api`; commit `8342a5d` "Feat: Thread safety inserted" 2026-07-13; local checkout `C:\Users\User\Documents\Projects\GNUS\GeniusSDK-src\src\GeniusSDK.cpp:166-179, 259-288, 645-665, 833-850`
- SuperGenius `src/account/GeniusNode.cpp` on `develop` via `gh api`: `ProcessImage` 3175, `GetProcessCost` 3306
- Dart 3.11.5 probe run this session (`Isolate.run` closure capture and error propagation; `Isolate.spawn` hang on entry throw)
- `.planning/research/v4.0-webview-bridge-spike.md:73` (100-800 ms, live price request)

### Secondary (MEDIUM confidence)
- Memory files `geniuswallet-local-build.md`, `analyzer-config-gotchas.md`, `dual-track-ui-redesign-port.md` (Flutter path, `DynamicLibrary.executable()` on Windows, baselines that are now stale)

### Tertiary (LOW confidence)
- None. Items not verified are in the Assumptions Log.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH, no new dependencies
- Architecture / extraction map: HIGH, every line read this session
- Isolate mechanics: HIGH for the pattern; the real `GeniusApi` closure-capture failure is [ASSUMED] but avoided by rule
- SDK thread safety: HIGH for Windows and for the `develop` source; MEDIUM for other platforms (A1)
- Real-SDK "keeps animating": MEDIUM, cannot be tested here (Pitfall 1)

**Research date:** 2026-10-26
**Valid until:** 2026-11-25 (SDK `develop` moves; re-check the mutex lines if the SDK pin changes)
