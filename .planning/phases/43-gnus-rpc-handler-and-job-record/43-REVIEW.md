---
phase: 43-gnus-rpc-handler-and-job-record
reviewed: 2026-10-27T02:45:18Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - lib/gnus_bridge/gnus_amounts.dart
  - lib/gnus_bridge/gnus_job_store.dart
  - lib/gnus_bridge/gnus_rpc_contract.dart
  - lib/gnus_bridge/gnus_rpc_handler.dart
  - lib/hive/constants/cache.dart
  - lib/hive/init.dart
  - lib/main.dart
  - lib/submit_job/job_submission.dart
findings:
  critical: 1
  warning: 12
  info: 7
  total: 20
status: issues_found
---

# Phase 43: Code Review Report

**Reviewed:** 2026-10-27T02:45:18Z
**Depth:** standard
**Files Reviewed:** 8 (lib diff `e2b8bd31..ec4fe8e5`; tests read for intent only)
**Status:** issues_found

## Summary

The core money gates hold. The default confirm rejects, the in-flight slot is set before the first await and released in `finally`, the gate is re-read fresh before pricing and after the confirm, and no path burns without `_confirm` returning true. The brace check passes (`tool/check_brace_style.sh`, exit 0). Nothing sensitive goes into logs, records or replies.

The defects sit after the burn and around it:
- One path loses the burn record and allows a second burn for the same idempotency key.
- The amount the user approves is not exactly the amount burned.
- The lock does not cover the panel's burns.
- A gas estimate failure that the panel refuses on is let through.
- Several error codes drift from the contract.

The `Expando` is not the simplest option. It exists only to close a Cubit that the handler uses as a fetch helper (WR-09).

## Fix status (2026-10-27)

| Finding | Status | Commit | Note |
|---|---|---|---|
| CR-01 | fixed | d04c0459 | In-memory record per origin and key, checked before the store; failed writes logged and retried 3 times. Ceiling: memory only, a restart after every write failed forgets the key (ponytail). |
| WR-01 | fixed | 6da54829 | The burn converts the decimal string exactly (`toBaseUnits`, moved into genius_api). It refuses a token whose decimals are not 18 (ponytail), so the confirmed cost is the burned amount. |
| WR-02 | fixed | 56d5e1ef | Affordability compares base units against the exact on-chain balance. |
| WR-03 | fixed | b2701b09 | Lock moved into `JobSubmission` (static, all instances); `JobBusy` maps to -32005. The handler keeps its slot for the confirm window. |
| WR-04 | fixed | 5bd97f5f | A failed gas estimate is -32010 before the confirm on submit; the estimate still returns `gas: null`. Contract row updated. |
| WR-05 | fixed | 66bf7859 | |
| WR-06 | fixed, handler only | 1f0e2c7b | `submit(expectedNode:)` skips Process when the SDK reports another account. The panel does not pass it: it has no node account in scope. |
| WR-07 | fixed | 36339949 | 10 min timeout, answers 4001. Contract updated. |
| WR-08 | fixed, depth only | def9ba95 | Depth cap 32 (also stops self-containing maps). The `inputs/outputs/passes` key check is not done. |
| WR-09 | fixed | 56d5e1ef | Balance read through `GeniusApi.readTokenBalance` for the payer and token captured in the request's facts; token through `CoinService`. Private `GnusCubit` and the `Expando` deleted. |
| WR-10 | fixed | 58da6a7e | |
| WR-11 | fixed | 43434464 | |
| WR-12 | fixed | c147a9da | `canSign` is false exactly when submit would answer -32012. Gate still read non-fresh, as events drive it. Contract updated. |
| IN-01 | fixed | 1e550738 | `JobSubmission.maxJobBytes`. |
| IN-02..IN-07 | open | | Out of scope for this pass. |

Verified in the main checkout of this worktree after the last fix: `flutter analyze --no-pub lib test` and `packages/genius_api` clean, brace check clean, full `flutter test` 2878 pass / 6 skip / 0 fail (was 2866).

## Critical Issues

### CR-01: A failed record write after the burn loses the spend and allows a second burn for the same key

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:848-860` (with `_putAnnouncing` at 249-255, and `lib/submit_job/job_submission.dart:212-218`)

**Issue:** The burn has already happened when `_putAnnouncing` runs. Any throw from `_store.put` there (Hive IO error, disk full, closed box) falls through to `handle()`'s generic catch:
- The page gets `-32603 Internal error` for a spend that went through.
- The reply carrying `burnTxHash` is lost.

The early `onBurned` write offers no protection. `JobSubmission.submit` swallows its failure on purpose (lines 212-218), so a single disk fault can fail both writes. In that case nothing records the key, the slot is released, and the page's documented recovery (retry with the same `idempotencyKey`) **burns a second time**.

If only the final write fails, the retry replays the stale `bridgedNotProcessed` record for a job that Process actually accepted.

**Fix:** Once the burn hash exists, the reply must not depend on persistence. Keep an in-memory replay as a fallback:
```dart
final Map<String, Map<String, Object?>> _burnedReplies = {}; // slot -> reply, process lifetime

// in _submitJob, before the store lookup:
final cached = _burnedReplies[slot];
if (cached != null) {
  return cached;
}

// in _burnAndRecord, every post-burn branch:
case JobDone(:final txHash):
  final reply = _submitReply(txHash, nodeAccount, GnusJobStatus.submitted);
  _burnedReplies['$origin|$idempotencyKey'] = reply;
  try {
    await _putAnnouncing(record(txHash, GnusJobStatus.submitted));
  } catch (e) {
    debugPrint('gnus_rpc record failed ${e.runtimeType}');
  }
  return reply;
```
Do the same in `onBurned`: set `_burnedReplies[slot]` to the `bridgedNotProcessed` reply before calling `_store.put`. Add one test with a store whose `put` throws, and assert that a same-key retry does not call `bridgeOut` again.

## Warnings

### WR-01: The `cost` shown to the page and to the confirm is not the amount burned

**File:** `lib/gnus_bridge/gnus_amounts.dart:11,17-22`; burn at `packages/genius_api/lib/web3/web3.dart:472-475`

**Issue:** `cost` is computed as `minions * 10^18` with exact BigInt arithmetic, and the contract calls it "the exact amount the wallet would burn". The burn computes something else: `BigInt.from(double.parse(amount) * pow(10, decimals))`, where `decimals` is read from the token contract.
- The double product is exact only while `minions * 5^18 < 2^53`, which means costs up to 2361 GNUS. Odd costs above that burn a different wei value from the one the user approved.
- On any chain where the token's `decimals()` is not 18, the confirm shows a cost that is wrong by orders of magnitude.

This also goes against D-13 and the contract ("read it, never hardcode it").

**Fix:** Pass base units into the burn: `bridgeOut(amountBaseUnits: BigInt)` in the owner, built with `BigInt.from(minions) * BigInt.from(10).pow(decimals)` from the decimals the burn already reads. Expose those decimals to the handler and use them in `gnusCostBaseUnits` and `unit.decimals`.

### WR-02: Affordability uses the panel's 4-decimal rounding, so a submit can pass with a balance the estimate reports as below cost

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:756-771`

**Issue:** `resolveSubmitJobCtaState` rounds the balance to 4 decimals. With a balance of `9.99996` and a cost of 10:
- `gnus_estimate` reports `balance` `9999960000000000000`, which is below `cost` `10000000000000000000`.
- `gnus_submitJob` judges the same balance "ready", opens the confirm and burns. The burn then reverts on chain or fails as `-32013`.

The contract's single-unit promise breaks at exactly this boundary.

**Fix:** Compare in base units, the same value the estimate returns:
```dart
final balanceUnits = gnusBalanceBaseUnits(balance);
if (balanceUnits == null) { /* balance_unavailable */ }
if (BigInt.parse(cost) > BigInt.parse(balanceUnits)) {
  throw const GnusRpcError(GnusRpcCode.insufficientFunds, 'Insufficient GNUS balance');
}
```

### WR-03: The "one burn at a time" lock does not cover the Submit Job panel

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:137,698-706`; `lib/submit_job/cubit/submit_job_cubit.dart:20`

**Issue:** D-07 asks for one burn at a time from the wallet. `_inFlightSlot` lives in the handler, while the panel builds its own `JobSubmission` and burns through it. A page submit and a panel submit can therefore run `bridgeOut` from the same EVM wallet at the same time. The two transactions race on the nonce, and one can fail or replace the other after the user has confirmed both.

**Fix:** Move the guard into the owner, as a static `bool _burning` checked and set synchronously at the top of `JobSubmission.submit` with a new `JobBusy` result. Map `JobBusy` to `-32005 submit_in_flight`. The per-key retry check can stay in the handler.

### WR-04: A failed gas estimate still opens the confirm, which the panel refuses to do

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:490,773-785`

**Issue:** `GasEstimateFailed` becomes `gas: null` and the submit carries on to the confirm. The panel treats the same result as `costError` (`submit_job_cubit.dart:289-297`) and disables Purchase. The owner's estimate fails on conditions the burn would also hit (`hasEnoughFundsForGas`, for example), so the user is asked to approve a spend the wallet's own UI calls impossible. The result is a `-32013` after the prompt.

The test `a gas estimate that fails does not block the submit` locks in this divergence.

**Fix:** In submit only (not the estimate), treat `GasEstimateFailed` as `-32010` and refuse before the confirm, or record the deviation as a decision in CONTEXT. The current code says it follows "the panel's rule" and does not.

### WR-05: A network change before the confirm is `-32603`, not the contract's `-32015 account_changed`

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:723-729`

**Issue:** The contract (section 5) assigns `account_changed` to `-32015`, and `_recheckAfterConfirm` follows it. This pre-confirm branch sends `account_changed` under `GnusRpcCode.internal`. A page that retries on `-32015` after `gnus_accountsChanged` treats it as a hard internal error instead.

**Fix:** Use `GnusRpcCode.accountSwitching` with message `'Account changed'`, matching lines 547-551.

### WR-06: The node account is not re-checked between the burn and Process

**File:** `lib/submit_job/job_submission.dart:196-226`; `lib/gnus_bridge/gnus_rpc_handler.dart:818-847`

**Issue:** `_recheckAfterConfirm` runs before `bridgeOut`, and `bridgeOut` then awaits secure storage, a gas estimate and the transaction (seconds to minutes). If the SDK account switches in that window, `requestGeniusSDKProcessAsync` runs as the new account (contract U4: the running account is credited). The record and reply still say `sdkAddress: nodeAccount`, so the job lands on, and is listed under, the wrong account. The panel has the same window.

**Fix:** Pass `expectedNode` into `submit`. Right before Process, compare it with the running SDK account and skip Process on a mismatch (return `JobBridgedNotProcessed`). The burn stays recoverable under the right account.

### WR-07: A confirm that never completes holds the burn slot forever

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:796-803`

**Issue:** `_confirm` is awaited with no bound. Suppose Phase 44's prompt is dismissed without completing its future: the route is popped, the widget is disposed, or a WalletConnect session dies. `_inFlightSlot` then never clears, and every later submit from every origin answers `-32005` until restart. The comment at line 134 says the slot is released on every path, but this one never ends.

**Fix:** Bound the seam, for example `await _confirm(...).timeout(const Duration(minutes: 15), onTimeout: () => false)` (matching the 900 s WalletConnect expiry), and document that implementations must complete.

### WR-08: The job object goes to the native SDK with no depth or schema check

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:321-338`

**Issue:** `_jobParam` checks only "non-empty map, string top-level keys, encodes, at most 5 MiB". A 5 MiB `[[[[...]]]]` passes, is re-encoded three times, and is handed to `GeniusSDKGetCost` and Process. A recursive native JSON parser that overflows its stack there crashes the whole process, not just an isolate. D-04 and the contract ("the old `data/model/input` shape is not accepted") also expect a schema check that is missing.

**Fix:** Walk the value once with a depth cap (32, for example) and check that the top level has `inputs`, `outputs` and `passes`. Reject with `-32602 job` otherwise.

### WR-09: The payer balance is read from whichever wallet is selected later; the Expando and private GnusCubit are unneeded

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:472-473,716`; `lib/main.dart:400,547-569`

**Issue:** `GnusCubit.fetchGnusBalance()` reads `walletDetailsCubit.state.selectedWallet` when it is called, which is after the `_priceJob` await. It does not use `facts.walletAddress`, so affordability can be judged on a different wallet from the payer. `_recheckAfterConfirm` misses an A to B to A flip.

The Cubit is used only as a two-method fetch helper. Its emitted state goes nowhere, and closing it is the only reason for the module-level `Expando`.

**Fix:** Inject `CoinService` and call it with the captured facts: `coinService.fetchGnusInfo(networkBefore)` and `coinService.fetchGnusBalance(payer, network)`. Then delete the `GnusCubit` parameter, the `_gnusRpcCubits` Expando and the extra `dispose` line in `main.dart`. This closes the race and is the shortest diff.

### WR-10: `_sgnsNet` caches a failed future for the handler's lifetime

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:259-261`

**Issue:** `sgnsNet()` reads an override file under `appDataDirectory()`. If that read throws once, `_sgnsNet ??=` keeps the failed future. Every later `gnus_getAccounts` and `gnus_estimate`, and every accounts or network event, then fails with `-32603` until the app restarts.

**Fix:**
```dart
Future<SgnsNet> _readSgnsNet() => _sgnsNet ??= _geniusApi.sgnsNet().catchError((Object e) {
  _sgnsNet = null;
  throw e;
});
```

### WR-11: A crafted cursor can return `-32603` instead of `-32602`

**File:** `lib/gnus_bridge/gnus_job_store.dart:251-261`

**Issue:** `int.tryParse('-9223372036854775808')` gives the minimum int, and `.abs()` of that value overflows back to itself (negative). The range check passes, and `DateTime.fromMicrosecondsSinceEpoch` throws `ArgumentError`, not `FormatException`. The handler's `on FormatException` (line 425) misses it, so the call ends as an internal error.

**Fix:** `if (micros == null || micros < -_maxCursorMicros || micros > _maxCursorMicros)`.

### WR-12: `canSign` in `gnus_getAccounts` disagrees with what submit enforces

**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:592-595`

**Issue:** `canSign` is true unless the wallet is watch-only, `sgnus`, or the gate says `child`. Submit refuses `-32012` for `not_earning` and `wrong_network` as well, and refuses `checking` (unreadable registrations, which could be a child). The page is told the payer can sign and then gets refused on every submit.

The gate is also read non-fresh here, so the value can be stale.

**Fix:** `canSign = wallet != null && gnusErrorForGate(_resolveGate().state)?.code != GnusRpcCode.payerCannotSign && walletCanSign(wallet)`, or document `canSign` as "key present" only and add a `submittable` field.

## Info

### IN-01: The 5 MiB cap is a second source of truth
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:19`; `lib/submit_job/cubit/submit_job_cubit.dart:27`
**Issue:** The comment admits it copies a private constant. **Fix:** Make the panel's constant public in `job_submission.dart` (the owner) and use it from both places.

### IN-02: One origin can read another origin's idempotency keys
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:420-424,436-443,253`
**Issue:** `listJobs`, `getJob({burnTxHash})` and broadcast `gnus_jobUpdated` return records from every origin, including `origin` and `idempotencyKey`, to any origin. **Fix:** Redact `idempotencyKey` when `job.origin != origin`, or scope the listing by origin. Decide this before Phase 44 adds more origins.

### IN-03: `role: 'none'` when registrations cannot be read
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:56-58`
**Issue:** A null (unreadable) registration read is reported as a definite `none`. The gate treats the same state as `checking`. **Fix:** Report `role: null` or `'unknown'`, or keep the previous role.

### IN-04: A corrupt record silently breaks idempotency for its key
**File:** `lib/gnus_bridge/gnus_job_store.dart:206-221`
**Issue:** An undecodable record is skipped, so a same-key retry burns again. Hive's crash recovery truncating the box has the same effect. **Fix:** At minimum, keep the raw key of skipped entries. In `byIdempotencyKey`, fail closed (`-32603`) when any record is unreadable.

### IN-05: The dev fixture's constant burn hash overwrites earlier records
**File:** `lib/submit_job/job_submission.dart:178-181,246`
**Issue:** Every dev submit records under `DevMockJob.txHash`. The second dev submit replaces the first record, and its key is no longer idempotent. This is debug only. **Fix:** Suffix the fixture hash with a counter.

### IN-06: The origin is logged raw
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:267,270,273`
**Issue:** Over WalletConnect the origin comes from page-supplied metadata, so newlines can forge log lines. **Fix:** Log `jsonEncode(origin)` or strip control characters.

### IN-07: `sgnsNet()` reads the pending override, not the running net
**File:** `lib/gnus_bridge/gnus_rpc_handler.dart:221-222,259-261`
**Issue:** If the handler is first built after the net picker writes a new value, it reports a net the SDK is not running until restart. Only `staging` exists today. **Fix:** Read the net the SDK started with, captured at init.

---

_Reviewed: 2026-10-27T02:45:18Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
