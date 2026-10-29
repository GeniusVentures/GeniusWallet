---
phase: 43-gnus-rpc-handler-and-job-record
verified: 2026-10-26T00:00:00Z
status: human_needed
score: 5/5 roadmap criteria verified against fakes and dev mocks; live SDK results blocked by design
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Live cost, burn and process through gnus_estimate / gnus_submitJob on a real node"
    expected: "A real positive cost (not -32010), a burn hash, jobId when the SDK gives one"
    why_human: "Blocked on SDK-CA, SDK-COSTERR, SDK-JOBID. Until then every live estimate is -32010 and a live submit stops before burning."
  - test: "Live job status and results via gnus_getJob"
    expected: "Status beyond submitted/bridgedNotProcessed; result non-null once the SDK answers per job"
    why_human: "Blocked on SDK-STATUS and SDK-RESULT. Today status is stored as submitted or bridgedNotProcessed and result is always null."
  - test: "Live earnings: processed-job counts and earned totals"
    expected: "Real numbers instead of null"
    why_human: "Blocked on SDK-EARNINGS. The null contract is verified; the live value is not available."
  - test: "A real app restart (kill and relaunch the Windows app) after a dev-mock submit"
    expected: "gnus_listJobs / gnus_getJob still return the record"
    why_human: "Persistence is proven by a real-disk Hive close and reopen in tests, not by relaunching the app. Needs a caller, which arrives with the Phase 45/46 transports (walk deferred to Phase 48)."
---

# Phase 43: gnus RPC handler and job record Verification Report

**Phase Goal:** One transport-independent handler answers every `gnus_*` method through the Phase 42 job flow, and every job submitted through it is recorded and survives a restart. No page can reach it yet.
**Verified:** 2026-10-26
**Status:** human_needed
**Re-verification:** No, initial verification

## Gate results (run by the verifier)

| Gate | Result |
| --- | --- |
| `flutter analyze --no-pub lib test` | exit 0, "No issues found" |
| `bash tool/check_brace_style.sh` | exit 0 |
| `flutter test test/gnus_bridge/ test/submit_job/` | exit 0, 268 tests, all passed |
| Claude attribution in commits e2b8bd31..HEAD | 0 matches (claude, anthropic, co-authored) |
| Debt markers in phase files | None added. One pre-existing `TODO` at `lib/submit_job/job_submission.dart:104`, outside the phase diff. |

## Observable Truths (roadmap criteria)

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Every `gnus_*` method through two transports gives identical results and codes: 4200, -32602, 4900, -32015, -32010, never cost "0" | VERIFIED | `gnus_rpc_contract_test.dart` runs each case through `viaDirect` and `viaJson` (JSON round-trip) and asserts `viaJson == jsonDecode(jsonEncode(viaDirect))`. Cases cover unknown method (4200, line 85), bad params (-32602, line 98/150), not initialized (4900, line 162), switching (-32015, line 189), zero cost (-32010, line 201). A final test asserts no reply contains `"cost":"0"`. Handler: `gnusCostBaseUnits` returns null for cost <= 0, so `_priceJob` throws `costUnavailable`. |
| 2 | `gnus_getAccounts` returns node, payer, switching, network in the contract shape; accountsChanged and networkChanged fire on wallet, node account or network change | VERIFIED | `_accountsPayload` in `gnus_rpc_handler.dart` (node.sdkAddress/linkedEvm/role/main, payer.evmAddress/canSign, switching, network, version, unit). `gnus_rpc_events_test.dart` covers wallet, SDK account, link, switch start and end, registrations, chain (networkChanged plus accountsChanged), dedup, processing ticks silent, dispose. |
| 3 | `gnus_submitJob` prices, confirms, burns, processes via the Phase 42 owner; returns burn hash, SDK account, `jobId: null`, status; same key replays without a second burn; concurrent submit gets -32005 | VERIFIED | Handler builds `JobSubmission` (Phase 42 owner) and calls `_jobs.cost`, `_jobs.estimateGas`, `_jobs.submit`; no second burn path. `_submitReply` returns jobId/burnTxHash/sdkAddress/status. Idempotent replay via `_store.byIdempotencyKey`, body-hash mismatch is -32602. `_inFlightSlot` set synchronously before the first await. `gnus_rpc_submit_test.dart` asserts `calls == ['cost','gas','burn','process']`, burn count 1 on replay, and -32005 for same-origin, other-origin and same-key retry (stricter than the contract's per-origin rule: wallet-wide, one burn at a time). |
| 4 | Every job is listed by `gnus_listJobs` and found by `gnus_getJob` with origin, burn hash, SDK account, cost, time, status, also after a restart | VERIFIED | `GnusJob.toContract` carries all fields. `gnusJobsBoxName` opened in `initHive` (`lib/hive/init.dart:54`), `GnusJobStore.app()` reads it. `gnus_job_store_restart_test.dart` uses a real temp dir, `Hive.close()` then reopen, and checks every field plus a handler over the reopened box listing, finding and replaying. Cursor paging tested in `gnus_job_store_test.dart`. Not a true app relaunch (see human items). |
| 5 | `gnus_getEarnings` returns balance and processing flag; counts and earnings are null, never 0 | VERIFIED | `_getEarnings` returns `jobsProcessed: null`, `earned: {total: null, history: null}`; balance via `sgnusBalanceBaseUnits`, unparseable balance is -32603 `balance_unavailable`. Contract matrix asserts `earned.total` null and balance `12500000000000000000`. |

**Score:** 5/5 verified against fakes. 0 behavior-unverified (ordering and cancellation invariants have named tests, see below).

## Money safety

| Check | Status | Evidence |
| --- | --- | --- |
| Default confirm rejects | VERIFIED | `rejectGnusConfirm` returns false and is the constructor default. `main.dart:544-575` constructs `GnusRpcHandler` without a `confirm`, with a comment saying so. Test "the default confirm rejects and nothing burns" asserts `calls` has no `burn`. A throwing confirm also maps to 4001. |
| No burn path without the confirm | VERIFIED | Only `_burnAndRecord` calls `_jobs.submit`, and it is reachable only after `_confirm` returns true. Only caller of `_jobs.submit` in `lib/gnus_bridge` is that line. Post-confirm `_recheckAfterConfirm` re-reads switching, node, payer, chain and the fresh gate. |
| Fails closed on unknown balance, gas data, payer | VERIFIED | Null balance, `missingData`, null payer each throw -32603 before the confirm. Affordability uses the panel's own `resolveSubmitJobCtaState`. |
| Record written on burn, before Process | VERIFIED | `onBurned` callback in `JobSubmission.submit` runs after the burn and before `requestGeniusSDKProcessAsync`; handler writes `bridgedNotProcessed`. Test asserts `seenDuringProcess.status == bridgedNotProcessed`, then `submitted` after. A thrown Process or a throwing `onBurned` does not skip Process or lose the hash. |
| Not reachable from any page | VERIFIED | Only `lib/main.dart` references the handler (RepositoryProvider, nothing reads it). |

## Requirements Coverage

| Req | Status | Evidence |
| --- | --- | --- |
| RPC-01 | SATISFIED | One handler, two-transport matrix. Real WebView and WalletConnect translators are Phases 45/46. |
| RPC-02 | SATISFIED | `_accountsPayload`, reads tests. |
| RPC-03 | SATISFIED | Events tests; jobUpdated also announced on status change. |
| RPC-04 | SATISFIED against fakes; live cost blocked (SDK-CA, SDK-COSTERR) | -32010 for zero or failed cost. |
| RPC-05 | SATISFIED against fakes; live jobId blocked (SDK-JOBID) | `jobId` always null today. |
| RPC-06 | SATISFIED | Replay and -32005 tests. |
| RPC-07 | SATISFIED against fakes; live status/result blocked (SDK-STATUS, SDK-RESULT) | Persisted, listed, found; `result: null`. |
| RPC-08 | SATISFIED against fakes; live counts blocked (SDK-EARNINGS) | Nulls. |
| RPC-09 | SATISFIED | 4900 on all six methods, -32015 on all but getAccounts (which reports `switching: true`). |

No orphaned requirements: REQUIREMENTS.md maps RPC-01..09 to Phase 43 and all nine appear in the plans.

## Anti-patterns and warnings

| Severity | Note |
| --- | --- |
| Info | `ponytail:` markers are present and name their ceilings (18-decimals assumption, whole-box decode per lookup, `isProcessing` false when feed never ticked). Not blockers. |
| Info | In-flight lock is wallet-wide, not per origin as the requirement words it. Stricter than required and covered by tests. Worth a line in the contract doc if not already there. |
| Info | `gnus_estimate` ignores the gate by design (a read) but still requires a ready node. |
| Housekeeping | `.planning/REQUIREMENTS.md` traceability rows (lines 500-508) still say Pending and the ROADMAP plan checkboxes for 43-01..05 are unchecked. The orchestrator should update them on completion; not a code gap. |

## Gaps

None blocking. The live-SDK results (cost, job id, status, results, earnings counts) are recorded above as human_needed, per the phase's stated SDK dependencies. They are not failures.

---

_Verified: 2026-10-26_
_Verifier: Claude (gsd-verifier)_
