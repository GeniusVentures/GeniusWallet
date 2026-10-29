# Phase 43: gnus RPC handler and job record - Research

**Researched:** 2026-10-27
**Domain:** Dart/Flutter in-process JSON-RPC style handler over existing cubits, a Hive-backed job record, the Phase 42 `JobSubmission` owner
**Confidence:** HIGH on where every value comes from; MEDIUM on three contract-level unit and shape questions (see "Contract gaps"), which need a one-line decision each before planning

Line numbers are as read at HEAD `6071167b`. Another session was committing Phase 42 review fixes on this branch while this research ran (HEAD moved from `e079589f`; the owner gained `fixtureBalance`, a process-throw guard and `GeniusApi.waitForJobCall`). Re-measure any cited line before editing it.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Home: `lib/gnus_bridge/`. One handler class taking `(origin, method, params)` and returning a result map or a typed `GnusRpcError(code, message, data)`; transports (phases 45-47) only translate. Error codes and method names are constants in one file mirroring the contract's tables (one source of truth in Dart).
- **D-02:** The handler is a plain Dart class, not a Cubit. It reads app state through the existing cubits/repositories it is given (wallet details, node/SDK account, switching state, network) and calls `JobSubmission` for estimate and submit. Widgets never call it directly.
- **D-03:** Start from the spike's `gnus_bridge.dart` (copy what fits, delete the rest). `gnus_getAddress` is retired. The injected JS shim stays out of this phase (phase 45/46).
- **D-04:** Params are validated at the handler boundary (trust boundary): required keys, types, `limit` 1-100, address formats (0x+128 hex SDK, 0x+40 hex EVM), job is a JSON object. Invalid -> `-32602`. Unknown method -> `4200`.
- **D-05:** `4900` when the SDK is not initialized; `-32015` (contract's account-switch code; RPC-09 text) when an SDK account switch is in progress (`switchingSDKAccount` non-null) for every method except `gnus_getAccounts`, which reports `switching: true` instead of failing.
- **D-06:** `gnus_submitJob` order: validate -> readiness/switch check -> idempotency lookup -> in-flight check -> estimate via the owner (zero/failed cost -> `-32010`, insufficient balance -> `-32011`, payer cannot sign -> `-32012`) -> confirm seam (reject -> `4001`) -> burn + process via the owner -> record -> result. Bridge failed -> `-32013`, nothing recorded as spent. Burn ok + process failed -> result `status: bridgedNotProcessed` (not an error), recorded.
- **D-07:** Idempotency: key -> first result, kept 24 h, persisted with the job record so it survives a restart. Same key with a different job body (compare a hash of the canonical JSON) -> `-32602` `data.reason: idempotency_key_reused`. In-flight lock is per origin AND global across origins for the burn step (one burn at a time from the wallet), second caller -> `-32005` `data.reason: submit_in_flight`.
- **D-08:** The confirm seam is an injected async callback `(origin, cost, gas, payer, nodeAccount) -> bool`. In this phase tests inject it; the default in app wiring rejects (`4001`) until phase 44 replaces it, so nothing can spend without a confirm.
- **D-09:** Persist through the existing Hive pattern (`lib/hive/`, a repository/service like `transaction_storage_service.dart`, hive_ce adapters or a JSON map box). Fields per contract `Job`: jobId (null), burnTxHash, sdkAddress, origin, idempotencyKey, submittedAt, cost, status. No secrets in the record. Records are scoped by `sdkAddress`; `gnus_listJobs` lists the current node account's jobs newest first with an opaque cursor.
- **D-10:** `gnus_getJob` accepts exactly one of `jobId`, `burnTxHash`, `idempotencyKey`; returns `Job` plus `result: null` until SDK-STATUS/RESULT exist.
- **D-11:** `gnus_getEarnings`: `balance` = node account SGNUS balance from the existing source the app already shows; `processing.isProcessing` from the existing processing-status source; `jobsProcessed`, `earned.total`, `earned.history` are null. `includeChildren` accepted and ignored.
- **D-12:** Events: the handler exposes a stream of `(event, payload)`; it emits `gnus_accountsChanged` (with the full `gnus_getAccounts` payload) when the selected wallet, SDK account or `switching` changes, `gnus_networkChanged` on SDK network or EVM chain change, `gnus_jobUpdated` when a record's status changes. Driven by listening to existing cubit streams, deduplicated.
- **D-13:** `unit.decimals` comes from the GNUS token info the app already has (`GnusCubit`); `version` is `"1"`.
- **D-14:** Log method name, origin and error code only; never params bodies beyond size, never key material.

### Claude's Discretion
- File split inside `lib/gnus_bridge/`, cursor encoding, how the fake transports in tests are shaped.

### Deferred Ideas (OUT OF SCOPE)
- Per-origin connect permission, real confirm UI, rate limits, secret-leak test: phase 44.
- `gnus_retryProcess` (contract U5): not until the SDK question is answered.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| RPC-01 | One transport-independent handler; both transports return identical results and codes | Section 6 two-fake-transport test; handler is `(origin, method, params) -> result or GnusRpcError` |
| RPC-02 | `gnus_getAccounts`: node, payer, switching, network | Section 1 source table |
| RPC-03 | `gnus_accountsChanged`, `gnus_networkChanged` | Section 1 event sources |
| RPC-04 | `gnus_estimate`; zero/failed cost is `-32010` | Section 4 (owner result mapping) and Contract gap 2 (gas shape) |
| RPC-05 | `gnus_submitJob` through the one owner | Section 4 |
| RPC-06 | Idempotency and in-flight `-32005` | Section 3 (store) and Section 4 (lock ordering) |
| RPC-07 | Job record, survives restart, `gnus_listJobs`/`gnus_getJob` | Section 3 |
| RPC-08 | `gnus_getEarnings`; nulls not 0 | Section 2 |
| RPC-09 | `4900` and `-32015` | Section 1 (readiness sources) |
</phase_requirements>

## Summary

Every value `gnus_getAccounts` needs already exists in `AppState` (`lib/bloc/app_state.dart`), `WalletDetailsCubit` state and `BridgeGateCubit`; nothing new has to be read from the SDK except the main/child role, which has no single existing getter (a pure function over `ChildOperationsCubit.ownRegistrations()` is the smallest addition). The `JobSubmission` owner already returns the typed outcomes the handler needs. One small, behaviour-neutral addition to the owner is recommended: an optional `onBurned(burnHash)` callback, so the job record is written the moment the burn succeeds rather than after the process call.

Persistence should be one `Box<String>` of JSON strings keyed by lowercased burn hash, opened in `initHive()`. No hive_ce adapter, no typeId, no codegen (the repo's analyzer is blind to `.g.dart`, and typeIds 0-8 are taken). The restart test is a plain `test()` with a real temp dir; widget-style tests use hive_ce's in-memory backend. Both patterns already exist in this repo.

The real risk in this phase is not plumbing. It is that the contract's amount units do not match what the wallet does today (Contract gap 1). Isolate unit conversion in one small file so the decision is a one-function change.

**Primary recommendation:** Build `lib/gnus_bridge/` as a handler with injected readers (no cubit types in its public surface beyond what the app wires), reuse `resolveBridgeGate`/`resolveSubmitJobCtaState`/`toBaseUnits` instead of re-implementing rules, add `onBurned` to the owner, store jobs as JSON strings in one Hive box, and get a decision on the three contract gaps before planning.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Method dispatch, param validation, error mapping | `lib/gnus_bridge/` handler | none | Boundary code translates and delegates (AGENTS "no domain logic in adapters") |
| Who can pay / which gate state blocks | `lib/dashboard/bridge/bridge_gate.dart` (`resolveBridgeGate`) | handler maps state to code | One owner of the rule; handler must not re-derive it |
| Affordability (cost vs balance) | `lib/submit_job/submit_job_cta_state.dart` (`resolveSubmitJobCtaState`) | handler maps to `-32011` | Same rounding and `<=` boundary as the panel |
| Price, gas, burn, process | `lib/submit_job/job_submission.dart` | `GeniusApi` | Phase 42 owner |
| Job record, idempotency, cursor | new `lib/gnus_bridge/` store over Hive | `lib/hive/` | Persistence behind a repository, not in the handler |
| Events | handler stream fed by existing cubit streams | none | Deduplicated by payload |
| Consent / confirm UI | phase 44 | none | Handler only calls a seam |

## Standard Stack

No new packages. Everything below is already a direct dependency [VERIFIED: pubspec.yaml:58-65, read this session].

| Library | Version | Purpose | Note |
|---------|---------|---------|------|
| hive_ce | ^2.19.3 | job record box | `pubspec.yaml:65`; `Box<String>` precedent `Hive.openBox<String>(marketTimestampsBox)` in `lib/hive/init.dart` |
| crypto | ^3.0.6 | sha256 of canonical job JSON | `pubspec.yaml:61`, already imported at `lib/theme/gw_colors.dart:3` |
| flutter_bloc / bloc streams | existing | listen to `AppBloc`, `WalletDetailsCubit`, `ChildOperationsCubit` streams | same listening pattern as `BridgeGateCubit` (`bridge_gate_cubit.dart:43-45`) |
| flutter_test | SDK | all tests | no extra test deps |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| JSON strings in `Box<String>` | hive_ce `@HiveType` adapter | Adapter needs build_runner, a unique typeId (0-8 used: `lib/hive/models/*`, `packages/genius_api/lib/models/transaction.dart:5,15,41,87,98`), registration in `initHive`, and the analyzer cannot see the `.g.dart`. JSON needs none of it. |
| One box for everything | box per node account (like `transactions_$wallet`) | Per-account boxes make the 24 h idempotency lookup and `getJob` by key open and scan several boxes. One box, filter by `sdkAddress`. |

**Installation:** none.

## Package Legitimacy Audit

No external packages are installed by this phase. `crypto` and `hive_ce` are existing direct dependencies. Not applicable.

**Packages removed due to [SLOP] verdict:** none
**Packages flagged as suspicious [SUS]:** none

## Architecture Patterns

### System Architecture Diagram

```
 test fake transport A ----\                      /-- AppBloc.stream (selectedSDKAccount, switchingSDKAccount, sdkAccountLinks)
 test fake transport B -----> GnusRpcHandler -----+-- WalletDetailsCubit.stream (selectedWallet, selectedNetwork, coins)
   (origin, method, params)   |   |   |           \-- ChildOperationsCubit.stream (register/move in flight)
                              |   |   |
              validate -> ready? -> switching? -> method
                              |   |   |
        reads: AppState,      |   |   +--> events stream: (event, payload)
        WalletDetailsState,   |   |           accountsChanged / networkChanged / jobUpdated
        BridgeGate (resolveNow(fresh:true)),
        GnusCubit balance + token info
                              |   |
   gnus_estimate / submitJob --+   +--> GnusJobStore (Hive Box<String>, JSON per burn hash)
        |                                  ^  idempotency lookup (24 h), list, get, upsert
        v                                  |
   JobSubmission.cost -> estimateGas -> [confirm seam] -> submit(onBurned: store.insert) -> result
        |
        +--> JobCostFailed -> -32010, GasEstimate* -> gas null, JobBridgeFailed -> -32013,
             JobBridgedNotProcessed -> status bridgedNotProcessed (result, not error), JobDone -> submitted
```

### Recommended Project Structure
```
lib/gnus_bridge/
  gnus_rpc_errors.dart     # GnusRpcError(code, message, data) + code and method-name constants (D-01)
  gnus_rpc_handler.dart    # the handler, event stream, in-flight lock
  gnus_job_store.dart      # GnusJob record, GnusJobStore over Box<String>, cursor, idempotency
  gnus_amounts.dart        # cost/balance -> base-unit decimal strings (the unit decision lives here only)
  gnus_node_role.dart      # pure: role/main from registrations (no I/O)
test/gnus_bridge/
  gnus_rpc_handler_test.dart
  gnus_job_store_test.dart          # in-memory box
  gnus_job_store_restart_test.dart  # real temp dir, plain test()
  gnus_rpc_events_test.dart
  gnus_node_role_test.dart
  gnus_amounts_test.dart
```
`lib/hive/constants/cache.dart` gains `gnusJobsBoxName = 'gnusJobs'`; `lib/hive/init.dart` opens it in the existing `Future.wait`.

### Pattern 1: Handler takes readers, not cubits
**What:** constructor takes narrow reads (`AppState Function()`, `Stream<AppState>`, `WalletDetailsCubit`, `BridgeGate Function({bool fresh})`, `Future<Token?> Function()`, `Future<double?> Function()`, `bool Function() sdkReady`, `Future<String> Function() sdkNetwork`, `JobSubmission`, `GnusJobStore`, confirm seam, clock). Wiring in `main.dart` passes `bridgeGateCubit.resolveNow`, a `GnusCubit(CoinService(), walletDetails)` for `fetchGnusInfo`/`fetchGnusBalance` (GnusCubit is not app-level: it is built per subtree at `lib/components/wallet_overview.dart:57` and `lib/navigation/router.dart:322`), and the rejecting confirm default.
**When to use:** always here. Tests then need no widget tree: `bridge_submit_gate_test.dart:85-130` already shows a real `BridgeGateCubit` driven by a pushable `WalletDetailsCubit` and a plain `AppState`.

### Pattern 2: Rule reuse, not copy
`-32012`/`-32015`/`4900` come from `BridgeGate.state`; `-32011` comes from `resolveSubmitJobCtaState(...) == SubmitJobCtaState.insufficientFunds`; amounts use `toBaseUnits`. See mapping tables below.

### Anti-Patterns to Avoid
- **Re-deriving can-sign or earning-wallet inside the handler.** The rule has one owner (`resolveBridgeGate`, `bridge_gate.dart:72-121`). Per CONTEXT "reuse, do not re-implement".
- **Passing `$e` to the page.** The spike does (`gnus_bridge.dart` `_dispatch` catch: `GnusBridgeError(GnusBridgeError.internal, '$e')`). Exception text can carry paths and addresses. Return a fixed `Internal error` and log only `e.runtimeType`.
- **Logging `jsonEncode(result)`.** The spike's log entry does. D-14 forbids it.
- **A hive adapter for the record.** See Alternatives.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Can this wallet pay | own wallet-type switch | `resolveBridgeGate` via `BridgeGateCubit.resolveNow(fresh: true)` (`bridge_gate_cubit.dart:71`, same call as `liveBridgeGate`, `bridge_entry.dart:14-16`) | Covers viewOnly, child, switching, notEarning, network, coins |
| Affordability | `cost > balance` | `resolveSubmitJobCtaState` (`submit_job_cta_state.dart:78-120`) | 4-decimal rounding and exact-balance boundary already pinned by tests |
| Decimal string to base units | `double * 1e18` | `toBaseUnits(String, int)` (`lib/squid_router/squid_util.dart:4-21`) | String and BigInt only; a double cannot hold 18 digits |
| Base units to display string | custom | `formatTokenAmount` (`squid_util.dart:23-34`) in tests | exact |
| Canonical JSON hash | custom serializer | `jsonEncode` of a key-sorted copy + `sha256` | ~10 lines; `crypto` already a dependency |
| Wallet can-sign | type checks | `walletCanSign` (`lib/reown/utilities.dart:24-26`), already what the gate uses | one definition |
| Node role | new SDK query | `ChildOperationsCubit.ownRegistrations()` (`child_operations_cubit.dart:232`) + pure function | the only existing reader of registrations |

## Runtime State Inventory

Not a rename/refactor phase. Omitted.

## Findings by question

### 1. Where each `gnus_getAccounts` field comes from

| Field | Source today | Evidence |
|-------|--------------|----------|
| `node.sdkAddress` | `AppState.selectedSDKAccount`, lowercased. Populated from `api.getSelectedAccountAddress()`, which returns null when the SDK is not initialized or answers a placeholder (only `0x` + 128 hex passes) | `app_state.dart:81`; `genius_api.dart:1704` and `sdkAddressOrNull` (`^0x[0-9a-fA-F]{128}$`, `genius_api.dart:58-62`) |
| `node.linkedEvm` | `AppState.nodeWalletAddress` = `sdkAccountLinks[selectedSDKAccount.toLowerCase()]?.walletAddress`; null when unlinked | `app_state.dart:102-103` |
| `node.role`, `node.main` | No single getter. Registrations are read by `GeniusApi.getChildRegistrations(main)` (`genius_api.dart:1782`, zero entries is a valid empty list) and aggregated across own mains by `ChildOperationsCubit.ownRegistrations()` (`child_operations_cubit.dart:232`, returns null when the node is not running or every read failed). Rule to implement as a pure function: node is a `child` of M if it appears in another own main's list (`main = M`); `main` if its own list is non-empty; else `none`. | same two files; the child test mirrors `BridgeGateCubit._refreshChild` (`bridge_gate_cubit.dart:148-217`) |
| `payer.evmAddress` | `WalletDetailsState.selectedWallet?.address` (lowercase it). For a `WalletType.sgnus` or `tracking` wallet there is no EVM signer: return the address only if the wallet is a real EVM wallet, else null | `wallet_details_state.dart:9`; `lib/reown/utilities.dart:24-26` |
| `payer.canSign` | `hasWallet && walletCanSign(wallet) && gate.state != BridgeGateState.child`. `walletCanSign` is false for `tracking` and `sgnus`; the gate adds `child` | `utilities.dart:24-26`; `bridge_gate.dart:85-96` |
| `switching` | `AppState.switchingSDKAccount != null` | `app_state.dart:85`; set at `app_bloc.dart` `_onSelectSDKAccount` (emit `switchingSDKAccount: target`), cleared by `_emitSDKAccounts(settling:)` |
| `network.sdk` | `SgnsNet.name` (only `staging`, `netId` 333). Read with `await api.sgnsNet()` (`genius_api.dart:500`, reads `overrides/sgns_config.json`). The setting only takes effect after a restart, so read it once and cache; it never changes inside a session | `genius_api.dart` `enum SgnsNet { staging(333) }`; `developer_settings_cubit.dart` ("Restart required for changes") |
| `network.evmChainId` | `WalletDetailsState.selectedNetwork?.chainId` (nullable) | `wallet_details_state.dart:10`; `network.dart` `int? chainId` |
| `unit.decimals` | **Not on `GnusCubit`'s token info.** `Token` has only `address, iconPath, name, coinGeckoId, id` (`packages/genius_api/lib/models/token.dart`). `GnusCubit.fetchGnusBalance` returns a `Coin` built by `fetchCoinBalance` with **no `decimals`** (`read_asset.dart:84-114`). The only populated `Coin.decimals` is from `_fetchTokenData` (multicall, `read_asset.dart:203`), reachable as `bridgeCoin(walletDetails.state.coins)?.decimals` (String, `bridge_gate.dart:166`), valid only when the selected network lists GNUS and its coins are loaded. See Contract gap 1. |
| `unit.symbol`, `version` | constants `"GNUS"`, `"1"` | contract |

**Readiness and switching (RPC-09):**
- `4900`: `geniusApi.isSdkInitialized` is false (`genius_api.dart:491`) OR `AppState.selectedSDKAccount == null` while not switching (gate state `notStarted`). Inject as `bool Function() sdkReady`. Note `shutdownSDK()` now sets `_isSdkInitialized = false` (Phase 42 fix), so a closing wallet answers 4900.
- `-32015`: `AppState.switchingSDKAccount != null`, every method except `gnus_getAccounts`. During a switch `selectedSDKAccount` can be the old account or null (`clearSelectedSDKAccount`), so `getAccounts` should report `node.sdkAddress` as `selectedSDKAccount ?? switchingSDKAccount` with `switching: true`.

**Gate state to error code (Claude's discretion, recommended):**

| `BridgeGateState` (`bridge_gate.dart:9-45`) | Code | `data.reason` |
|---|---|---|
| `enabled` | continue | |
| `noWallet`, `viewOnly`, `child` | `-32012` | `no_wallet`, `view_only`, `child` |
| `notEarning`, `wrongNetwork` | `-32012` | `not_earning`, `wrong_network` |
| `switching` | `-32015` | |
| `notStarted` | `4900` | |
| `noGnus`, `gnusElsewhere` | `-32011` | `no_gnus`, `gnus_elsewhere` |
| `balanceUnavailable`, `checking` | `-32603` | `balance_unavailable`, `checking` |

`checking` must block: it is also what the gate returns while the child registrations are unreadable (`isChild == null`, `bridge_gate.dart:107-109`), and letting it through would let a child submit. Note `notEarning` means the contract's "payer and node can differ by design" is, in practice, refused at submit: the gate only enables the wallet linked to the earning account (`bridge_gate.dart:156-163`). `gnus_estimate` is a read and should not apply the gate; gas simply comes back null if the wallet cannot sign.

**Events (RPC-03, D-12):**
- Listen to `AppBloc.stream` (`selectedSDKAccount`, `switchingSDKAccount`, `sdkAccountLinks`), `WalletDetailsCubit.stream` (`selectedWallet`, `selectedNetwork`), and `ChildOperationsCubit.stream` (a register or move changes role with no AppState event; `BridgeGateCubit` listens to it for the same reason, `bridge_gate_cubit.dart:45`).
- On any emission, compute a cheap key (`selectedSDKAccount`, `switchingSDKAccount`, links identity, wallet address and type, chainId, child-op identity). Only when it changes, rebuild the full `getAccounts` payload and compare `jsonEncode` to the last emitted one; emit `gnus_accountsChanged` only on a difference. Rebuilding calls sync FFI (`getChildRegistrations`), so do not do it per AppState emission.
- `gnus_networkChanged` fires on `selectedNetwork?.chainId` change. The SDK network cannot change in a session (restart required), so that half never fires; say so in a comment, do not fake it.
- `AppState` emits often (processing feed, `app_bloc.dart:437` guards some of them); the cheap key is what keeps this quiet.

### 2. `gnus_getEarnings`

- `balance`: `geniusApi.getSGNUSBalance()` (`genius_api.dart:1397`): the SDK's currently selected account balance as a GNUS decimal string with up to 6 decimals (`GeniusTokenValue` comment: "18446744073709.551615", `genius_api_ffi.dart:1201-1204`). Returns `"0"` when the SDK is not initialized, so check `sdkReady` first (4900) rather than report 0. This is what the app already shows (`lib/wallets/view/genius_balance_display.dart:36,52` and `wallet_details_cubit.dart` `readSdkBalance`). `getMinionsBalance()` (`genius_api.dart:1369`) is the exact integer form; prefer it for the base-unit conversion (see Contract gap 1).
- `processing.isProcessing`: `AppState.isProcessing` (`app_state.dart:23`), set from `nodeReading == NodeProcessingReading.processing` (`app_bloc.dart` `_onProcessingStatusTicked`). Caveat the code itself documents: when `processingFeedStatus` is `neverTicked` or `unavailable` (`app_state.dart:39`), `false` is indistinguishable from idle. The contract has no null here. Recommend returning `isProcessing` as-is and listing it as a known limit (Open Question 5).
- `jobsProcessed`, `earned.total`, `earned.history`: `null`. `includeChildren`: accept any bool, ignore.

### 3. Persistence

**Hive pattern in this repo** [VERIFIED: read this session]:
- Box names are constants in `lib/hive/constants/cache.dart`.
- `initHive()` (`lib/hive/init.dart:26-53`) calls `Hive.init(appDataDirectory)`, registers all adapters, opens `preferencesBoxName` alone first (single-instance lock election), then opens the rest concurrently in `Future.wait`. Add `Hive.openBox<String>(gnusJobsBoxName)` to that list. `main.dart:134` calls `initHive()` before anything else and handles the lock-held case.
- Adapter route: `@HiveType` + build_runner + `registerAdapter` in `initHive` + a unique typeId (`lib/hive/models/README.md`). Next free typeId would be 9. Not recommended.
- Service route: `TransactionStorageService` (`lib/hive/services/transaction_storage_service.dart`) opens boxes lazily per wallet. Not recommended here: a lazy open makes every store call async and hides the lock election.

**Recommended store shape**

One box `gnusJobs`, `Box<String>`. Key: lowercased `burnTxHash`. Value: `jsonEncode` of
```
{ "v": 1, "jobId": null, "burnTxHash": "...", "sdkAddress": "0x..128hex lower",
  "origin": "https://...", "idempotencyKey": "...", "bodyHash": "<sha256 hex of canonical job JSON>",
  "submittedAt": "<ISO 8601 UTC>", "cost": "<decimal string>", "status": "submitted|bridgedNotProcessed|..." }
```
No job body, no params, no keys, no mnemonic. `bodyHash` is stored so the `idempotency_key_reused` check survives a restart without keeping the (possibly multi-MB) body.

- `GnusJobStore(Box<String> box)` takes the box in its constructor so tests pass a memory or temp-dir box. Methods: `insert(Job)`, `updateStatus(burnTxHash, status)`, `byBurnHash`, `byIdempotencyKey(key, now)` (newest record with that key whose `submittedAt` is within 24 h), `byJobId`, `page(sdkAddress, limit, cursor)`.
- Lookups scan `box.values` and decode. `// ponytail:` linear scan, fine to a few thousand jobs; upgrade path is a secondary index key (`idem|<origin>|<key>` -> burn hash).
- 24 h applies to the idempotency lookup only. Records themselves are kept (they are the "my jobs" history).
- Cursor: newest first by `(submittedAt desc, burnTxHash desc)`. Opaque cursor = `base64Url("<submittedAt micros>|<burnTxHash>")` of the last returned item; the next page is everything strictly after it in that order. Stable when new jobs are inserted at the head. A malformed cursor is `-32602`.
- A record that fails to decode is skipped and counted in a `debugPrint` (type only); it must not break listing.

**Idempotency key scope.** Look up by `(origin, key)`, not key alone, so one origin cannot probe another origin's results by guessing a key. With one pinned release origin this costs nothing.

**Test setup that avoids the Hive hang** (`.planning/todos/completed/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md`, read this session): real disk I/O inside a `testWidgets` body never completes in the `FakeAsync` zone. Two safe patterns both exist in the repo:
1. Plain `test()` with a real temp dir: `test/dashboard/transaction_row_test.dart:390-402` (`createTemp` + `Hive.init` in `setUp`, `deleteBoxFromDisk` + `Hive.close` + `dir.delete` in `tearDown`) and `test/dashboard/crypto_news_digest_test.dart:31-47`. Use this for the restart test: put via store A, `await Hive.close()`, `Hive.init(dir.path)` again, reopen the box, build store B, assert the record is there.
2. In-memory backend for everything else: `Hive.openBox<String>(name, bytes: Uint8List(0))` (`test/settings/developer_mode_test.dart:11-18`, `test/dashboard/transactions_wallet_switch_test.dart:69-71`). `deleteFromDisk()` throws on this backend, so `box.close()` in `tearDown`.
Every handler and store test in this phase is a plain `test()`, never `testWidgets`, so the trap does not apply; the restart test must stay a plain `test()`.

### 4. How `JobSubmission` reports outcomes, and what the handler needs

Read at HEAD `6071167b` (`lib/submit_job/job_submission.dart`). The class is non-final and takes `GeniusApi`; tests either subclass it (override `cost`, `estimateGas`, `submit`) or pass a `GeniusApi` fake as in `test/submit_job/job_submission_test.dart:33-110`.

| Owner call | Result type | Handler maps to |
|---|---|---|
| `cost(String jobJson)` | `JobCostOk(minions, {fixtureBalance})` / `JobCostFailed([reason, fixtureBalance])`. A raw SDK `0` becomes `JobCostFailed()` (`cost` body) | `JobCostFailed` -> `-32010`, `data.reason` only if `reason` non-null (only the dev fixture sets it today). Never emit `cost: "0"`. |
| `estimateGas(JobFacts, int)` | `GasEstimateOk(String gas)` / `GasEstimateMissingData` / `GasEstimateFailed(reason)` | Any non-Ok -> `gas: null`; the estimate still succeeds (contract: "gas is null when it cannot be estimated"). In `submitJob`, a null gas does not block; the confirm sees null. |
| `submit(JobFacts, {jobCost, jobJson})` | `JobDone(txHash)` / `JobBridgedNotProcessed(bridgeHash, processResult)` / `JobBridgeFailed` / `JobMissingData` | `JobDone` -> `status: submitted`; `JobBridgedNotProcessed` -> result `status: bridgedNotProcessed` (not an error); `JobBridgeFailed` -> `-32013`, nothing recorded; `JobMissingData` -> `-32603` `data.reason: missing_data` (the gate and facts checks run before, so this should be unreachable). A process-call throw after the burn is already folded into `JobBridgedNotProcessed` by the owner (Phase 42 CR-01). |

Facts for the owner: `JobFacts(chainId, rpcUrl, walletAddress, gnusAddress)` as built by `SubmitJobCubit._jobFacts()` (`submit_job_cubit.dart`, `_jobFacts`): `selectedNetwork.chainId/rpcUrl`, `selectedWallet.address`, `gnusCubit.state.tokenInfo.address`. Read once before the first await, as the cubit does, so a wallet switch mid-call cannot retarget the burn.

**What the owner does not do, so the handler must:**
- Balance and the insufficient-funds decision. The panel reads `GnusCubit.fetchGnusBalance()` (a `Coin?` with `double? balance`, `gnus_cubit.dart:42`) and feeds `resolveSubmitJobCtaState`. In dev, `JobCostResult.fixtureBalance` is the balance (Phase 42 WR-02); the handler must prefer it when non-null.
- Burn hash arrives only in the final result. A hard kill between the burn and the end of the process call loses the only proof of a spend. **Recommended owner addition:** an optional named parameter `void Function(String burnHash)? onBurned` on `submit`, called right after `resp.isSuccess` and before the process call. Default null, so the panel and all existing tests are unaffected (behaviour-neutral). The handler passes `store.insert(...)` with status `submitted`; the final result then calls `updateStatus` when it becomes `bridgedNotProcessed`. Add one owner test: callback fires after the burn and before process, and not at all on `JobBridgeFailed`. The dev path (`devScenario != null`) does not need to call it. If the planner prefers zero owner change, the cost is a small data-loss window; state that explicitly in the plan.
- Dev gate is closed under `flutter test` (`kDebugMode && kShowDevTools`, `job_submission.dart:109`), so handler tests inject a `JobSubmission` subclass; `JobSubmission.devSubmitResult(SubmitOutcome)` (`@visibleForTesting`) gives the five outcome objects for free.

**Order and locking in `gnus_submitJob` (D-06, D-07):**
1. validate params; 2. `sdkReady`/switching; 3. idempotency lookup `(origin, key)` within 24 h: same `bodyHash` -> return stored result, different -> `-32602 idempotency_key_reused`; 4. take the in-flight lock; 5. gate map, price, balance, gas; 6. confirm seam; 7. owner `submit`; 8. update record; 9. release the lock in `finally`.
- One Dart bool is enough for D-07: a global "one burn at a time" lock already covers "per origin". Both cases return `-32005 submit_in_flight`.
- Hold the lock from step 4 through step 9, including the confirm (which can wait 900 s on a human). Phase 44's `confirm_open` reason is a different case (a second prompt) and not built here.
- Idempotency step 3 runs before the lock, so a retry of a finished submit does not get `-32005`. A retry of one still in flight does (nothing is recorded yet).
- Only successful burns create records; `4001`, `-32010`, `-32011`, `-32012`, `-32013` leave no record, so a retry with the same key re-runs. That is intended.
- `-32014` stays defined but is never returned by `submitJob` in v1 (D-06 returns the result instead).

### 5. Spike: reuse versus rewrite

Spike file: `C:\Users\User\Documents\Projects\GNUS\GW-webview-spike\lib\gnus_bridge\gnus_bridge.dart` (read, untouched).

| Spike item | Verdict |
|---|---|
| `GnusBridgeError` code/message and `toJson()` | Reuse shape; rename `GnusRpcError`; add `data` map; keep codes 4001, 4100, 4200, 4900, -32602, -32603; add -32005, -32010..-32015 |
| Request envelope parse (`{id, method, params}`) and reply JSON | Belongs to transports (45-47), not the handler. Do not copy |
| `_dispatch` switch | Rewrite. Every method differs |
| `_jobFrom` | Rewrite. The spike accepts the bare params as the job (`params['job'] ?? params`); the contract accepts only `{job: <object>}` |
| `geniusApi.requestGeniusSDKCost` (sync) | Deleted in Phase 42-02; owner is the only caller |
| `kGnusBridgeRealProcess` stub, `stubbed: true` result | Delete. Nothing stubs a burn |
| `gnus_getAddress` | Delete (retired) |
| `confirmJob(origin, job)` | Replace with the D-08 seam `(origin, cost, gas, payer, nodeAccount) -> bool` |
| `catch (e) -> internal '$e'` | Rewrite: fixed message, log `runtimeType` only |
| `GnusBridgeLogEntry` + `ValueNotifier` log + `summary: jsonEncode(result)` | Delete (D-14). Log `method origin code` via `debugPrint` |
| `originOf`, allowlist, `kGnusBridgeChannel`, `kGnusBridgeShim`, `gnusBridgeReplyScript` | Out of scope (44/45/46) |

New code constants (single file, D-01): `-32005` (reasons `rate_limited`, `confirm_open`, `submit_in_flight`), `-32010`, `-32011`, `-32012`, `-32013`, `-32014`, `-32015` per contract section 5 [VERIFIED: v4.0-gnus-rpc-contract.md:204-220].

**Param validation facts (D-04):**
- No v1 method takes an address param. The address formats (`0x`+128 hex, `0x`+40 hex) apply to the result fields and should be asserted in tests, not parsed from input.
- `params` may arrive as null (the spike shim sends `null` for no params): treat null or missing as `{}`; non-object -> `-32602`.
- `limit`: integer 1-100, default 20; accept an integral double (`20.0`) because JS numbers cross as doubles on some transports.
- `getJob`: exactly one non-null of `jobId`, `burnTxHash`, `idempotencyKey`. Validate `burnTxHash` as a non-empty string of bounded length only, **not** as `0x` + 64 hex: the dev fixture hashes are `0xDEV0B0...` (`lib/dev/dev_mock_job.dart:111-117`), which are not hex, and the lookup is an exact match anyway.
- `idempotencyKey`: non-empty string, bounded length (suggest <= 128). It is stored, so it needs a cap.
- `job`: non-empty JSON object, with a size cap on the encoded form. The panel caps files at 5 MB (`submit_job_cubit.dart:27`, private); define one handler constant of the same value rather than importing a private.
- Schema depth is the SDK's: an invalid processing definition prices as 0 and arrives as `-32010` (SDK-COSTERR is the dependency that would distinguish them).

## Contract gaps the plan must resolve (each has a recommendation)

**Gap 1 - amount units (highest risk).** The contract says amounts are integer base units with `display = amount / 10^decimals` (`v4.0-gnus-rpc-contract.md` section 3, `unit`) and that "cost" is burned as-is (U1). Three different units exist in the code:
- Job cost: `JobCostOk(minions)` is a plain `int`. It is passed to `bridgeOut` as `amountToBurn: jobCost.toString()` (`job_submission.dart` `submit`), and `Web3.createBridgeOutTransaction` does `double.parse(amountToBurn) * 10^tokenDecimals` (`web3.dart:472-475`), i.e. the integer is treated as **whole GNUS**. The panel prints `"${jobCost} GNUS"` (`job_steps.dart:105,287`) and compares it directly with a whole-GNUS `double` balance (`submit_job_cta_state.dart:110-118`). The variable is named `minions`, though, so whether the SDK returns whole GNUS or minions is genuinely unresolved [ASSUMED: panel behaviour is the reference per contract U1].
- Payer balance: `Coin.balance`, a `double` in whole GNUS (ERC-20, decimals from chain).
- Node balance: `getSGNUSBalance()` is whole GNUS with 6 decimals; `getMinionsBalance()` is the integer minion form (1 GNUS = 1,000,000 minions: `minionsToGnus`, `child_wallets_cubit.dart:12-17`; `gnusToMinions`, `genius_api.dart` 6-decimal regex).
Returning these as-is would put three scales under one `unit.decimals`. **Recommendation:** convert all three to base units of `unit.decimals` in one file (`gnus_amounts.dart`): `cost = BigInt(jobCost) * 10^decimals`; payer balance and node balance via `toBaseUnits(decimalString, decimals)` (node balance from the minion integer times `10^(decimals-6)`, exact). Then the contract text is true and the dashboard divides once. This follows the panel's real behaviour for the burn. If Braian instead wants "SDK integer as-is" the change is confined to that file. Needs a one-line decision before planning.

**Gap 2 - gas shape.** Contract: `gas: {amount, symbol: <native coin symbol>}`. The owner returns the pre-formatted string `"1.00 Gwei"` (`genius_api.dart:2117`) and the number is the gas **price** in Gwei, not a total cost (`web3.dart:649-651`; `createBridgeOutTransaction` passes `gasPrice`). Also, if the price is null it formats as the literal `"null Gwei"`. **Recommendation:** parse the owner string with one tiny helper into `{amount: "1.00", symbol: "Gwei"}`, treat anything not matching `^\d+(\.\d+)? Gwei$` as null, and change the contract text to "gas price in Gwei". The confirm seam gets the same string the panel shows.

**Gap 3 - nullable fields.** Two spots where "never 0" collides with a required field: `unit.decimals` when the selected network has no loaded GNUS coin, and `balance` in `gnus_estimate` when the RPC read fails (`GnusCubit.fetchGnusBalance` returns null). **Recommendation:** `unit.decimals` null in `getAccounts` (identity reads must not fail on a flaky network) and `-32603 decimals_unavailable` for methods that return amounts; `balance` null in `gnus_estimate` when unread. Add both to the contract text as nullable. Alternative for decimals: a one-time cached `Web3.decimals(...)` read (`web3.dart:372`) per GNUS contract; costs an RPC and new code, so not recommended for v1.

## Common Pitfalls

### Pitfall 1: Lost burn record
**What goes wrong:** the app is killed after `bridgeOut` succeeds and before the process call returns; no record exists and funds are spent.
**How to avoid:** `onBurned` insert (Section 4). Warning sign: the only place a job is written is after `submit` returns.

### Pitfall 2: `checking` gate state treated as pass
**What goes wrong:** `resolveBridgeGate` returns `checking` both for "coins loading" and "child registrations unreadable"; mapping it to "proceed" lets a child wallet submit.
**How to avoid:** map every non-`enabled` state to a refusal (table above).

### Pitfall 3: Dev fixture hash fails a hex validator
`0xDEV0B...` is not hex. Do not validate burn hashes on output or on `getJob` input.

### Pitfall 4: `Hive` box type mismatch
`Hive.box<T>` throws if the box was opened with another type (`transaction_row_test.dart` comment). Open as `Box<String>` everywhere; the store gets the box injected.

### Pitfall 5: Reading registrations on every AppState emission
`getChildRegistrations` is a sync FFI call per own account. Gate recomputation behind the cheap key (Section 1).

### Pitfall 6: Process-in-flight shutdown
Phase 42 added `GeniusApi.waitForJobCall()` for window close, but a close during the burn itself is not covered (its own `ponytail:` comment). Not this phase's to fix; note in the plan so nobody assumes the handler is crash-safe before the burn completes.

### Pitfall 7: CRLF and brace style
CI's brace check fails on CRLF Dart files (memory: crlf-breaks-ci-brace-check). New files must be LF; run `bash tool/check_brace_style.sh`. Every `if` braced on its own line.

## Code Examples

### Error type and gate mapping (shape only)
```dart
// Source: pattern from lib/dashboard/bridge/bridge_gate.dart (BridgeGateState) and the contract section 5
class GnusRpcError implements Exception {
  const GnusRpcError(this.code, this.message, {this.data});
  final int code;
  final String message;
  final Map<String, Object?>? data;
}

GnusRpcError? errorForGate(BridgeGateState s) {
  switch (s) {
    case BridgeGateState.enabled:
      return null;
    case BridgeGateState.switching:
      return const GnusRpcError(-32015, 'Account switch in progress');
    case BridgeGateState.notStarted:
      return const GnusRpcError(4900, 'Wallet not ready');
    case BridgeGateState.noGnus:
    case BridgeGateState.gnusElsewhere:
      return GnusRpcError(-32011, 'Insufficient GNUS', data: {'reason': s.name});
    case BridgeGateState.balanceUnavailable:
    case BridgeGateState.checking:
      return GnusRpcError(-32603, 'Wallet not ready', data: {'reason': s.name});
    case BridgeGateState.noWallet:
    case BridgeGateState.viewOnly:
    case BridgeGateState.child:
    case BridgeGateState.notEarning:
    case BridgeGateState.wrongNetwork:
      return GnusRpcError(-32012, 'Payer cannot sign', data: {'reason': s.name});
  }
}
```

### Canonical body hash
```dart
// Key-sorted recursive copy, then sha256 of jsonEncode. crypto is already a dependency.
Object? _canon(Object? v) => v is Map
    ? {for (final k in (v.keys.map((k) => '$k').toList()..sort())) k: _canon(v[k])}
    : v is List ? [for (final e in v) _canon(e)] : v;
String bodyHash(Map<String, dynamic> job) =>
    sha256.convert(utf8.encode(jsonEncode(_canon(job)))).toString();
```

### Role from registrations (pure)
```dart
// registrations: lowercased main -> lowercased child addresses (from ownRegistrations())
({String role, String? main}) nodeRole(String node, Map<String, Set<String>> registrations) {
  for (final e in registrations.entries) {
    if (e.key != node && e.value.contains(node)) {
      return (role: 'child', main: e.key);
    }
  }
  return ((registrations[node] ?? const {}).isNotEmpty)
      ? (role: 'main', main: null)
      : (role: 'none', main: null);
}
```
When `ownRegistrations()` is null (node not running or all reads failed) the role is unknown; return `role: 'none'` for the read but keep the gate (which treats it as `checking`) as the spend guard.

## State of the Art

| Old | Current | Impact |
|---|---|---|
| Spike `gnus_getAddress` | `gnus_getAccounts` | retired |
| Sync `requestGeniusSDKCost/Process` on the UI isolate | async `Isolate.run` workers, owner is sole caller | handler may await them freely; do not add a Dart-side queue (42-02 decision: SDK serialises with one mutex) |
| Owner without dev balance | `fixtureBalance` on `JobCostResult` | handler reads the dev balance from the cost result |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The panel's treatment of the SDK cost integer as whole GNUS is the unit reference (contract U1) | Contract gap 1 | If the SDK returns minions, both the panel and the handler over-burn by 1e6; needs the SDK team |
| A2 | Role `none` means "neither a main with children nor a child" | Section 1 | Dashboard may expect `main` for any account with a link |
| A3 | A global in-flight bool satisfies "per origin AND global" | Section 4 | If Braian wants per-origin messages to differ, add a second reason value |
| A4 | Gate states `notEarning`/`wrongNetwork` map to `-32012` | Section 1 table | Contract does not name a code for these; a different code is a one-line change |
| A5 | Scoping idempotency lookup by `(origin, key)` is acceptable | Section 3 | None with one pinned origin |
| A6 | `isProcessing` may report false while the feed is unavailable | Section 2 | Dashboard shows "not earning" for a node that is |

## Open Questions

1. **Unit decision (Gap 1).** Recommendation given. Blocks `gnus_amounts.dart` and every amount test.
2. **Gas shape (Gap 2) and nullable fields (Gap 3).** Recommendations given; contract text needs a matching edit.
3. **`onBurned` owner change.** Recommended; the alternative is accepting a data-loss window. The owner is Phase 42's, whose review fixes are still landing on this branch, so sequence the owner edit after that settles.
4. **Is the gate right for `gnus_estimate`?** Recommendation: no, the estimate is a read; only `submitJob` applies the gate.
5. **`isProcessing` when the feed is down.** Recommend as-is plus a documented limit.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | tests, analyze | Present, not on PATH | 3.41.9 / Dart 3.11.5 (per 42-01 plan) | Prefix: `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"` |
| Native GeniusSDK | none (all calls faked) | n/a | n/a | tests use fakes; live cost blocked by SDK-CA |
| Flutter run / device | not needed this phase | n/a | n/a | headless only |

Flutter was not run in this research session (read-only). The baseline to beat is the Phase 42-02 figure: full suite +2692 passed, 6 skipped, 0 failed; `flutter analyze --no-pub lib test` exit 0 (42-02-SUMMARY, read). The review fixes since then may have moved it; Task 0 of the first plan must re-measure before any code change.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (SDK 3.41.9), plain `test()` only for this phase |
| Config file | none; `analysis_options.yaml` at root |
| Quick run command | `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH" && flutter test --no-pub test/gnus_bridge` |
| Full suite command | `flutter test --no-pub --reporter failures-only` (capture `$?` before any pipe) |
| Gates | `flutter analyze --no-pub lib test` exit 0; `dart format --output=none --set-exit-if-changed lib/gnus_bridge test/gnus_bridge lib/submit_job lib/hive`; `bash tool/check_brace_style.sh` |

### Phase Requirements to Test Map

| Success criterion / Req | Behavior | Test | File |
|---|---|---|---|
| SC1 / RPC-01 | Every method via two fake transports gives the same result/code: `4200` unknown, `-32602` bad params (missing job, array params, `limit` 0/101, bad cursor, getJob with 0 or 2 selectors), `4900` SDK not ready, `-32015` during switch (all methods except `getAccounts`, which returns `switching: true`), `-32010` for `JobCostFailed`, never `cost: "0"` | unit | `test/gnus_bridge/gnus_rpc_handler_test.dart` (two transport shims call the same handler: one passes decoded maps, one round-trips through `jsonEncode`/`jsonDecode`; assert deep equality of results and `code`) |
| SC2 / RPC-02 | `getAccounts` shape: node (linked, role main/child/none, main), payer (address, canSign false for tracking/sgnus/child), switching, network, unit, version `"1"`; sdkAddress lowercase 0x+128 hex, evm 0x+40 hex | unit | `gnus_rpc_handler_test.dart`, `gnus_node_role_test.dart` |
| SC2 / RPC-03 | `accountsChanged` on wallet, SDK account, switching flip and link change; `networkChanged` on chainId change; no event when only the processing tick changes; no duplicate on identical payload | unit | `test/gnus_bridge/gnus_rpc_events_test.dart` (broadcast `StreamController<AppState>`, pushable `WalletDetailsCubit` as in `bridge_submit_gate_test.dart:85-130`) |
| SC3 / RPC-04 | `gnus_estimate`: cost, gas (null on `GasEstimateFailed`), balance, network; `-32010` on `JobCostFailed` | unit | `gnus_rpc_handler_test.dart` |
| SC3 / RPC-05 | Submit order: confirm called with (origin, cost, gas, payer, node); reject -> `4001` and no `submit` call; `JobBridgeFailed` -> `-32013`, no record; `JobDone` -> `submitted`, `jobId` null; `JobBridgedNotProcessed` -> result status `bridgedNotProcessed`, record present; `-32011` via `resolveSubmitJobCtaState`; `-32012` for viewOnly/child; default rejecting confirm gives `4001` | unit | `gnus_rpc_handler_test.dart` with a recording `JobSubmission` subclass |
| SC3 / RPC-06 | Same key + same body returns first result, `submit` call count stays 1; same key + different body `-32602` `idempotency_key_reused`; same key after 24 h (injected clock) runs again; second submit while the first awaits a `Completer` confirm gets `-32005 submit_in_flight`, from the same and from a different origin | unit | `gnus_rpc_handler_test.dart` |
| SC4 / RPC-07 | `listJobs` newest first, scoped to current `sdkAddress`, pagination with cursor stable across an insert, limit bounds; `getJob` by each selector; `result: null` | unit | `gnus_job_store_test.dart` (memory box), handler test |
| SC4 / RPC-07 | Restart persistence: record written through store A survives `Hive.close()` + re-init + reopen and is returned by `listJobs`, `getJob`, and still satisfies idempotency | unit, real disk, plain `test()` | `gnus_job_store_restart_test.dart` (pattern `transaction_row_test.dart:390-402`) |
| SC4 | `onBurned` writes the record before the process call completes (owner test) and the final `bridgedNotProcessed` update emits `gnus_jobUpdated` | unit | `test/submit_job/job_submission_test.dart` (new case) + `gnus_rpc_events_test.dart` |
| SC5 / RPC-08 | `getEarnings`: balance string from fake `getSGNUSBalance`/minions, `isProcessing` from `AppState`, `jobsProcessed`/`earned.*` are `null` (assert `isNull`, not 0), `includeChildren: true` accepted | unit | `gnus_rpc_handler_test.dart` |
| RPC-09 | covered by SC1 rows | | |
| D-14 | No log line contains params, result bodies or keys: capture `debugPrint` via `debugPrint = ...` override and assert only `method origin code` appear | unit | `gnus_rpc_handler_test.dart` |
| Owner unchanged | existing submit_job tests have no diff; panel behaviour unchanged after `onBurned` | regression | `flutter test --no-pub test/submit_job test/dev/dev_mock_job_test.dart test/dashboard/compute_panel_wiring_test.dart` and `git diff --exit-code <phase-start> -- test/submit_job/job_flow_test.dart test/submit_job/submit_job_errors_test.dart test/submit_job/submit_job_outcome_test.dart test/submit_job/submit_job_cta_state_test.dart` |
| Boundary guard | `lib/gnus_bridge/` never calls `bridgeOut`, `requestGeniusSDKCost*`, `requestGeniusSDKProcess*`, `getBrigeOutGasCost` directly (source scan, same idiom as `job_off_ui_isolate_test.dart` sweep) | source guard | `gnus_rpc_handler_test.dart` |

"Two fake transports": a fake transport is a few lines, not a framework: `Future<Map> viaDirect(h, origin, method, params)` returns `{'result': ...}` or `{'error': {code, message, data}}`; `viaJson` does the same through a `jsonEncode`/`jsonDecode` round trip of both request and reply. The criterion is that both give deep-equal replies for every method.

### Sampling Rate
- **Per task commit:** `flutter test --no-pub test/gnus_bridge` plus the touched file's analyze.
- **Per wave merge:** focused set above plus `flutter analyze --no-pub lib test`.
- **Phase gate:** full suite at or above the re-measured baseline, brace check, format.

### Wave 0 Gaps
- [ ] `test/gnus_bridge/` does not exist; create with the six files above.
- [ ] Re-measure the baseline at the current HEAD (Phase 42 review fixes landed after the 42-02 summary).
- [ ] A shared fake in `test/gnus_bridge/` for `JobSubmission` (subclass overriding `cost`/`estimateGas`/`submit`, recording calls) and a `GnusJobStore` over a memory box helper.
- [ ] No framework install needed.

## Security Domain

`security_enforcement` is on, ASVS level 1, block on high (`.planning/config.json:56-58`).

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (phase 44 consent) | n/a |
| V3 Session Management | no | n/a |
| V4 Access Control | partly | handler takes `origin` as a parameter and trusts it; origin proof is phase 45. Idempotency lookup scoped by origin |
| V5 Input Validation | yes | hand-written validation at the handler boundary (types, ranges, size caps, bounded strings); no dependency needed |
| V6 Cryptography | no | sha256 of job body only for equality; no keys handled |
| V7 Error handling and logging | yes | fixed error messages, log `method origin code` only |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Replay of a submit (reload, double click, timeout) | Tampering/Repudiation | idempotency key persisted, 24 h, body-hash compare |
| Concurrent submits double-burn | Tampering | single in-flight lock held through confirm and burn |
| Spending without consent | Elevation | default confirm seam rejects (`4001`) until phase 44 |
| Exception text leaks internals to page | Information disclosure | fixed `Internal error`, log type only |
| Oversized job or key fills storage/memory | DoS | size cap on job, bounded key length; growth limits are phase 44 rate limits |
| Key material in logs or state | Information disclosure | no key/mnemonic read anywhere in this phase; record has none; AGENTS wallet-safety rules |
| Child wallet or watch-only spends | Elevation | gate state map; `checking` blocks |

## Sources

### Primary (HIGH, read this session)
- `.planning/phases/43-gnus-rpc-handler-and-job-record/43-CONTEXT.md`; `.planning/research/v4.0-gnus-rpc-contract.md`; `.planning/ROADMAP.md` Phase 43; `.planning/REQUIREMENTS.md` RPC-01..09
- 42-01-SUMMARY.md, 42-02-SUMMARY.md; `lib/submit_job/job_submission.dart`, `submit_job_cubit.dart`, `submit_job_cta_state.dart`
- `lib/bloc/app_state.dart`, `lib/bloc/app_bloc.dart`; `lib/dashboard/bridge/bridge_gate.dart`, `bridge_gate_cubit.dart`, `bridge_entry.dart`; `lib/reown/utilities.dart`
- `lib/wallets/cubit/wallet_details_cubit.dart`, `wallet_details_state.dart`; `lib/dashboard/gnus/cubit/gnus_cubit.dart`; `lib/assets/read_asset.dart`
- `lib/child_wallets/child_operations_cubit.dart`; `lib/squid_router/squid_util.dart`
- `packages/genius_api/lib/src/genius_api.dart` (bridgeOut, getBrigeOutGasCost, balances, registrations, SgnsNet); `packages/genius_api/lib/web3/web3.dart`; `models/coin.dart`, `token.dart`, `network.dart`
- `lib/hive/init.dart`, `constants/cache.dart`, `models/README.md`, `services/transaction_storage_service.dart`; the Hive-hang todo; `test/dashboard/transaction_row_test.dart`, `crypto_news_digest_test.dart`, `test/settings/developer_mode_test.dart`, `test/submit_job/job_submission_test.dart`, `test/dashboard/bridge/bridge_submit_gate_test.dart`
- Spike `gnus_bridge.dart`; `AGENTS.md`

### Secondary / Tertiary
- None. No web research was needed: every question is answered by in-repo source.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH, no new packages, all verified in pubspec
- Architecture and sources of values: HIGH, each cited to a file read this session
- Unit semantics (Gap 1): MEDIUM, the code is clear, the SDK's intent is not
- Pitfalls: HIGH

**Research date:** 2026-10-27
**Valid until:** until Phase 42 review fixes finish landing (re-read `job_submission.dart` then); otherwise 30 days
