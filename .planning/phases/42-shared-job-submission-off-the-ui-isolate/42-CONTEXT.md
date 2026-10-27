# Phase 42: Shared job submission off the UI isolate - Context

**Gathered:** 2026-10-27 (overnight, `--auto`; every decision below is (D), not yet reviewed by Braian)
**Status:** Ready for planning

<domain>
## Phase Boundary

The compute panel's job flow (price, bridge gas, burn via `bridgeOut`, `GeniusSDKProcess`,
bridged-not-processed) moves out of `SubmitJobCubit` into one shared owner that the panel calls now and
the `gnus_*` handler (phase 43) calls next. Then the SDK cost and process calls move off the UI isolate.
No UI change, no new outcome, no new capability: the panel must behave exactly as it does today.

</domain>

<decisions>
## Implementation Decisions

### Shape of the shared owner
- **D-01:** One plain Dart class, `JobSubmission` (name at planner's discretion), in `lib/submit_job/`, constructed with what the cubit already receives (`GeniusApi`, plus the wallet/network/GNUS-token facts it reads from `WalletDetailsCubit` and `GnusCubit` passed in as values per call, not the cubits themselves). It holds no UI state and never emits. `SubmitJobCubit` keeps all state, emits and copy; it calls the owner and maps results to `SubmitOutcome` exactly as today.
- **D-02:** The owner's results are typed and mirror today's outcomes one to one: cost ok / cost failure (with the same message passthrough as `getBridgeOutGasCost`), gas estimate ok / failure, submit result `done(txHash)` / `bridgedNotProcessed(bridgeHash, processResult)` / `bridgeFailed` / `missingData`. Sealed classes, not strings. Error messages stay word for word.
- **D-03:** The dev-mock fixture (`DevMockJob`, gated by `kDebugMode && kShowDevTools`) moves with the flow into the owner, behind the same gate, so the panel and the future bridge share one mock. The release-safety property (fixture unreachable in release) must still hold and stay tested.
- **D-04:** The cubit's double-submit guard (`isBridgingTokens`, the `outcome` reset on retry) stays in the cubit for this phase. A cross-caller in-flight lock belongs to phase 43 (RPC-06), where a second caller first exists.

### Order of work
- **D-05:** Two plans minimum, in order: (1) the extraction, behaviour-preserving, with every existing `test/submit_job/*` test passing unchanged; (2) the isolate move. Never in one diff (AGENTS.md "refactor first, then change behavior").
- **D-06:** `submit_job_cubit.dart` ends the phase with no direct call to `bridgeOut`, `getBrigeOutGasCost`, `requestGeniusSDKCost` or `requestGeniusSDKProcess` (success criterion 2). A grep-based check in a test or `tool/` script is acceptable proof.

### Off the UI isolate
- **D-07:** Follow the existing precedent, `GeniusApi.selectGeniusAccountAsync` (`packages/genius_api/lib/src/genius_api.dart` ~line 1550, `Isolate.spawn` + `ReceivePort`): add async variants of the cost and process calls in `genius_api` and make the owner use only those. Prefer `Isolate.run` if research confirms it behaves the same with the FFI library handle; otherwise copy the precedent.
- **D-08:** Research must establish, before plan 2 is written, what the precedent relies on: does the spawned isolate re-open the native library, and is the SDK safe to call from a non-main thread while the main isolate also calls it (status polling, balance reads)? If concurrent calls are not safe, serialise SDK job calls through one queue in `genius_api` and mark it with a `ponytail:` comment (ceiling: one SDK job call at a time; upgrade path: SDK-ASYNC). If the precedent is itself unsafe, record it as a blocker and ship plan 1 only.
- **D-09:** Sync `requestGeniusSDKCost` / `requestGeniusSDKProcess` stay in `genius_api` only if something outside the job flow still needs them; otherwise delete them (deletion over addition). No caller in `lib/` may use the sync versions after this phase.
- **D-10:** Proof for success criterion 3: a test that fails if the owner calls the sync SDK methods (fake `GeniusApi` that throws on the sync ones), plus a widget test that the panel keeps pumping frames while a slow fake async cost call is pending. A human-visible "keeps animating" check with the real SDK is deferred to the phase 48 walk; note it in VERIFICATION, do not claim it.

### Claude's Discretion
- File and class names, whether the owner is one class or a class plus a small value type for inputs, and how the existing three `_SeededSubmitJobCubit` test helpers are kept working.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### This phase
- `.planning/ROADMAP.md` § "Phase 42: Shared job submission off the UI isolate" — goal and 3 success criteria
- `.planning/REQUIREMENTS.md` § v4.0, ISO-01; § "SDK dependencies" (SDK-ASYNC, SDK-CA)
- `AGENTS.md` — refactor-first rule, wallet safety, brace style, cubit → repository layering

### Where the flow goes next
- `.planning/research/v4.0-gnus-rpc-contract.md` § `gnus_estimate`, `gnus_submitJob` — the second caller's needs (phase 43); the owner's API must be able to serve them without another refactor (estimate returns cost, gas and balance; submit returns burn hash and outcome)
- `.planning/research/v4.0-webview-bridge-spike.md` § "Latency and UX" — the 100-800 ms UI freeze this phase removes

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/submit_job/cubit/submit_job_cubit.dart`: `_resolveJobCost` (~229), `getBridgeOutGasCost` (~307), `bridgeTokens` (~356), `_bridgeTokensFromDevFixture` (~494), `_processErrorMessage` — the code being moved.
- `lib/dev/dev_mock_job.dart`: `DevMockJob` fixture and scenarios.
- `packages/genius_api/lib/src/genius_api.dart`: `requestGeniusSDKProcess` (~1088), `requestGeniusSDKCost` (~1110), `selectGeniusAccountAsync` (~1550, the isolate precedent), `bridgeOut`, `getBrigeOutGasCost`.

### Established Patterns
- Tests: `test/submit_job/job_flow_test.dart`, `submit_job_errors_test.dart`, `submit_job_outcome_test.dart`, `submit_job_cta_state_test.dart`, each with a `_SeededSubmitJobCubit` that seeds state directly.
- The bridge destination chain id `15305752297694` is hardcoded twice with a TODO; keep one constant in the owner (DRY, same value), do not change the value.

### Integration Points
- `SubmitJobCubit` is constructed in `lib/components/wallet_overview.dart:58` and `lib/navigation/router.dart:320`; both must keep compiling with the same behaviour.
- Phase 43's `gnus_*` handler will construct or receive the same owner.

</code_context>

<deferred>
## Deferred Ideas

- Re-running Process for an existing burn (`bridgedNotProcessed` recovery): contract open question U5, todo `.planning/todos/pending/2026-07-29-can-requestgeniussdkprocess-be-recalled-after-a-successful-bridge.md`. Not this phase.
- Unhardcoding the bridge destination chain id: separate change.

</deferred>
