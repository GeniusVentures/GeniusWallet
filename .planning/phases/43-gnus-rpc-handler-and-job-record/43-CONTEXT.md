# Phase 43: gnus RPC handler and job record - Context

**Gathered:** 2026-10-27 (overnight, auto; every decision below is (D), not yet reviewed by Braian)
**Status:** Ready for planning

<domain>
## Phase Boundary

A transport-independent `gnus_*` handler that answers every method and event in the contract
(`.planning/research/v4.0-gnus-rpc-contract.md`) through the Phase 42 `JobSubmission` owner, plus a
persisted record of every job submitted through it. No WebView, no WalletConnect, no consent UI: tests and
dev mocks drive it. The submit confirm is a seam the handler calls; Phase 44 supplies the real prompt and
per-origin permission.

</domain>

<decisions>
## Implementation Decisions

### Shape
- **D-01:** Home: `lib/gnus_bridge/`. One handler class taking `(origin, method, params)` and returning a result map or a typed `GnusRpcError(code, message, data)`; transports (phases 45-47) only translate. Error codes and method names are constants in one file mirroring the contract's tables (one source of truth in Dart).
- **D-02:** The handler is a plain Dart class, not a Cubit. It reads app state through the existing cubits/repositories it is given (wallet details, node/SDK account, switching state, network) and calls `JobSubmission` for estimate and submit. Widgets never call it directly.
- **D-03:** Start from the spike's `gnus_bridge.dart` (copy what fits, delete the rest). `gnus_getAddress` is retired. The injected JS shim stays out of this phase (phase 45/46).
- **D-04:** Params are validated at the handler boundary (trust boundary): required keys, types, `limit` 1-100, address formats (0x+128 hex SDK, 0x+40 hex EVM), job is a JSON object. Invalid -> `-32602`. Unknown method -> `4200`.

### Readiness and switching
- **D-05:** `4900` when the SDK is not initialized; `-32015` (contract's account-switch code; RPC-09 text) when an SDK account switch is in progress (`switchingSDKAccount` non-null) for every method except `gnus_getAccounts`, which reports `switching: true` instead of failing.

### Submit
- **D-06:** `gnus_submitJob` order: validate -> readiness/switch check -> idempotency lookup -> in-flight check -> estimate via the owner (zero/failed cost -> `-32010`, insufficient balance -> `-32011`, payer cannot sign -> `-32012`) -> confirm seam (reject -> `4001`) -> burn + process via the owner -> record -> result. Bridge failed -> `-32013`, nothing recorded as spent. Burn ok + process failed -> result `status: bridgedNotProcessed` (not an error), recorded.
- **D-07:** Idempotency: key -> first result, kept 24 h, persisted with the job record so it survives a restart. Same key with a different job body (compare a hash of the canonical JSON) -> `-32602` `data.reason: idempotency_key_reused`. In-flight lock is per origin AND global across origins for the burn step (one burn at a time from the wallet), second caller -> `-32005` `data.reason: submit_in_flight`.
- **D-08:** The confirm seam is an injected async callback `(origin, cost, gas, payer, nodeAccount) -> bool`. In this phase tests inject it; the default in app wiring rejects (`4001`) until phase 44 replaces it, so nothing can spend without a confirm.

### Job record
- **D-09:** Persist through the existing Hive pattern (`lib/hive/`, a repository/service like `transaction_storage_service.dart`, hive_ce adapters or a JSON map box). Fields per contract `Job`: jobId (null), burnTxHash, sdkAddress, origin, idempotencyKey, submittedAt, cost, status. No secrets in the record. Records are scoped by `sdkAddress`; `gnus_listJobs` lists the current node account's jobs newest first with an opaque cursor.
- **D-10:** `gnus_getJob` accepts exactly one of `jobId`, `burnTxHash`, `idempotencyKey`; returns `Job` plus `result: null` until SDK-STATUS/RESULT exist.

### Earnings and events
- **D-11:** `gnus_getEarnings`: `balance` = node account SGNUS balance from the existing source the app already shows; `processing.isProcessing` from the existing processing-status source; `jobsProcessed`, `earned.total`, `earned.history` are null. `includeChildren` accepted and ignored.
- **D-12:** Events: the handler exposes a stream of `(event, payload)`; it emits `gnus_accountsChanged` (with the full `gnus_getAccounts` payload) when the selected wallet, SDK account or `switching` changes, `gnus_networkChanged` on SDK network or EVM chain change, `gnus_jobUpdated` when a record's status changes. Driven by listening to existing cubit streams, deduplicated.
- **D-13:** `unit.decimals` comes from the GNUS token info the app already has (`GnusCubit`); `version` is `"1"`.

### Logging
- **D-14:** Log method name, origin and error code only; never params bodies beyond size, never key material (CNS-04's test lands in phase 44, but nothing logged here may need to be taken back).

### Claude's Discretion
- File split inside `lib/gnus_bridge/`, cursor encoding, how the fake transports in tests are shaped.

</decisions>

<canonical_refs>
## Canonical References

- `.planning/research/v4.0-gnus-rpc-contract.md` — every method, param, result, event and error code (canonical)
- `.planning/ROADMAP.md` § Phase 43 (5 success criteria); `.planning/REQUIREMENTS.md` RPC-01..09
- `.planning/research/v4.0-wallet-identity.md` — identity edge cases (node vs payer, switch window, unlinked accounts)
- `.planning/phases/42-shared-job-submission-off-the-ui-isolate/42-01-SUMMARY.md`, `42-02-SUMMARY.md` — the `JobSubmission` API this phase calls
- Spike: `C:\Users\User\Documents\Projects\GNUS\GW-webview-spike\lib\gnus_bridge\gnus_bridge.dart` (read only)
- `AGENTS.md` — wallet safety, layering, braces

</canonical_refs>

<code_context>
## Existing Code Insights

- `lib/submit_job/` — `JobSubmission` owner (phase 42), async SDK calls.
- `lib/bloc/app_state.dart` / `app_bloc.dart` — `selectedSDKAccount`, `switchingSDKAccount`.
- `lib/wallets/cubit/wallet_details_cubit.dart` — selected wallet and network.
- `lib/dashboard/bridge/bridge_gate_cubit.dart` — existing rule for which wallet can pay for a bridge (reuse for `-32012`, do not re-implement).
- `lib/hive/` — storage pattern for the job record.
- `lib/dev/dev_mock_job.dart` — dev scenarios reused for handler tests.

</code_context>

<deferred>
## Deferred Ideas

- Per-origin connect permission, real confirm UI, rate limits, secret-leak test: phase 44.
- `gnus_retryProcess` (contract U5): not until the SDK question is answered.

</deferred>
