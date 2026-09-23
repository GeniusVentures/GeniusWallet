---
phase: 31-send-native-coins-and-erc-20-tokens
reviewed: 2026-09-23T21:00:58Z
iteration: 2
depth: standard
files_reviewed: 30
files_reviewed_list:
  - packages/genius_api/lib/web3/web3.dart
  - packages/genius_api/lib/web3/send_service.dart
  - packages/genius_api/lib/web3/api_response.dart
  - packages/genius_api/lib/src/genius_api.dart
  - assets/json/networks/networks.json
  - lib/bloc/app_bloc.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/dashboard/home/widgets/transaction_utils.dart
  - lib/dashboard/transactions/cubit/transactions_cubit.dart
  - lib/reown/handle_dapp_requests.dart
  - lib/reown/send_transaction_details.dart
  - lib/reown/utilities.dart
  - lib/send/recipient_field.dart
  - lib/send/send_cubit.dart
  - lib/send/send_screen.dart
  - lib/tokens/token_info_screen.dart
  - lib/utils/wallet_utils.dart
  - test/account/sdk_row_actions_test.dart
  - test/dashboard/dashboard_send_entry_test.dart
  - test/dashboard/transaction_asset_chain_test.dart
  - test/dashboard/transaction_receipt_fee_row_test.dart
  - test/reown/handle_dapp_requests_test.dart
  - test/send/recipient_field_test.dart
  - test/send/send_cubit_test.dart
  - test/send/send_rpc_test.dart
  - test/send/send_screen_test.dart
  - test/send/send_service_test.dart
  - test/send/send_token_test.dart
  - test/tokens/coin_page_stat_rail_test.dart
findings:
  critical: 1
  warning: 6
  info: 5
  total: 12
status: issues_found
---

# Phase 31: Code Review Report (iteration 2)

**Reviewed:** 2026-09-23T21:00:58Z
**Depth:** standard, plus the call chain into web3dart 3.0.2/3.0.3, `wallet` 0.0.18, `swap_execution.dart` and `swap_screen.dart`
**Files Reviewed:** 30 (the 19 fix commits, `717ce858..164781b9`)
**Status:** issues_found

## Summary

I checked every fix in the code rather than taking `31-REVIEW-FIX.md`'s word for it. Gates run here: `check_brace_style.sh`, `check_raw_colors.sh` and `check_no_new_key_logging.sh --scan-tree` all exit 0. The 11 phase test files pass (169 tests). No planning ids and no `_buildFoo` appear in the added lines. `SendState` still carries no key.

**The WR-03 fix breaks signing everywhere (CR-04).** The app resolves web3dart **3.0.2**; `packages/genius_api` resolves 3.0.3. In 3.0.2, `signTransaction` returns an EIP-1559 transaction without its `0x02` type byte, and only `sendTransaction` added it. The new code signs and then calls `sendRawTransaction` directly, so every send, swap and dApp transaction is broadcast as a bare RLP list, and a node rejects it. I checked this by signing under the app's own `package_config.json`: the first byte is `0xf8`, where it should be `0x02`. The regression test cannot see this: it hashes whatever bytes were broadcast and compares that to the returned hash.

Other new defects: swap behaviour changed despite the fix report's claim that it did not (WR-17). The WR-07 and WR-06 fixes now misreport a native over-balance and an RPC failure (WR-19, WR-20). The signer has no timeout, so the "unconfirmed" path never fires on a stall (WR-18). WR-15 is only half fixed.

### Status of iteration-1 findings

| ID | Status | Verified how |
|----|--------|--------------|
| CR-01 | Resolved | `rootNav` pops the root navigator (`send_screen.dart:236,260,269`); the cancel branch checks `context.mounted`. Three tests mount `/send` in a `ShellRoute`. |
| CR-02 | Resolved | `SendReview.decimals` feeds `formatTokenAmount` (`send_screen.dart:244`). The test expects `100 USDC`. |
| CR-03 | Resolved | EIP-681 parse (`recipient_field.dart:22-46`). Tests cover the `/transfer?address=` form, `/approve` and a 64-hex payload. |
| WR-01 | Resolved | `settle()` drops the result after an edit (`send_cubit.dart:498-514`). |
| WR-02 | Resolved | The sign call is wrapped in try/catch, and each Hive write is guarded by `_write` (`send_cubit.dart:625-635,704-711`). |
| WR-03 | **Open. Regressed into CR-04.** | See CR-04 and WR-18. |
| WR-04 | Resolved | Checked against the real `isEip55ValidEthereumAddress`: checksummed passes, a one-character case typo fails, lowercase and uppercase pass. Zero is refused in `review()`. The wallet-name check lowercases first, so it is unaffected. The payout field now refuses a bad checksum (see IN-11). |
| WR-05 | Resolved | Network and Token rows (`send_transaction_details.dart:80-83`). |
| WR-06 | Resolved for a revert. Introduces WR-20. | The token balance is read before `estimateGas`, and the test fake reverts. |
| WR-07 | Resolved. Introduces WR-19. | `value` is attached (`send_cubit.dart:547`, `send_service.dart:287`). |
| WR-08 | Resolved | Market tip is capped at `eth_gasPrice`, with a `ponytail:` comment (`send_service.dart:101-111`). The comment is now accurate. |
| WR-09 | Resolved | `0x420…0F` `getL1FeeUpperBound(uint256)` is the post-Fjord GasPriceOracle. Chain set `{10, 8453, 84532, 11155420}`: only 8453 and 84532 are in the catalogue, and no non-OP chain is included. A failed read throws, so Review is blocked rather than assuming zero. See IN-10 for the settled fee. |
| WR-10 | Resolved | `canSendFrom` excludes `tracking` and `sgnus`. sgnus wallets are SDK account addresses (`app_bloc.dart:617-640`) with no key in secure storage. |
| WR-11 | Resolved. Introduces WR-21. | Unawaited and sequential, and each read is capped at 15 s, so launch cannot hang offline. The fan-out is bounded by the number of pending rows (see IN-12). |
| WR-12 | Resolved | The toast follows the settled status (`send_screen.dart:296-314`). |
| WR-13 | Resolved | `recipientError`, `amountError`, and a form-level `GWWarningNote` live region. |
| WR-14 | Resolved | The catalogue is 84532. A saved 84531 no longer matches in `app_bloc.dart:120-123`, so it falls back to `networks.first`, and the dropdown just shows no selection. No other Hive key stores a chain id. |
| WR-15 | **Partially open** | The base-units label is fixed. The native value is recorded but never shown. See WR-15 below. |
| WR-16 | **Partially open** | Send-service reads are capped. The signer's own RPC calls are not. See WR-18. |

The iteration-1 Info items (IN-01 to IN-07) were out of the fixer's scope and still stand. They are not repeated here.

## Critical Issues

### CR-04: The signer broadcasts EIP-1559 transactions without their `0x02` type byte. Every send, swap and dApp transaction is rejected.

**File:** `packages/genius_api/lib/web3/web3.dart:723-741`; `pubspec.lock` (web3dart 3.0.2) vs `packages/genius_api/pubspec.lock` (3.0.3); `test/send/send_rpc_test.dart:184-211`
**Issue:** The WR-03 fix replaced `client.sendTransaction` with `signTransaction` + `sendRawTransaction`. The app builds against the root lockfile, which pins **web3dart 3.0.2** (`.dart_tool/package_config.json` → `web3dart-3.0.2`). In 3.0.2, `signTransactionRaw` returns `rlp.encode([...])` for an EIP-1559 transaction, and the `0x02` prefix is added only inside `sendTransaction` (`web3dart-3.0.2/lib/src/core/client.dart:335-340`). Version 3.0.3 moved the prefix into `signTransactionRaw`, which is why the package's own resolution hides the bug.

This signer always builds an EIP-1559 transaction, because `maxFeePerGas` is never null. I signed one under the app's `package_config.json`: `isEIP1559=true firstByte=0xf8`. Under the package's config it was `0x02`. A node decodes the bare 12-element list as a legacy transaction and returns an RPC error, so:
- every `/send`, every Squid swap (`swap_screen.dart:498`) and every dApp `eth_sendTransaction` (`handle_dapp_requests.dart:224`) fails, where each worked before this commit;
- the "unconfirmed" hash is `keccak256` of the wrong bytes, so it could never match a mined transaction.

The regression test passes against the defect. It compares `result.data` to `keccak256(broadcast)`, which is true whatever the bytes are, and never asserts that the broadcast is a typed envelope.
**Fix:** Normalise the envelope so the result does not depend on which web3dart resolves, and pin the test to it:
```dart
var signed = await client.signTransaction(credentials, transaction, chainId: chainId);
// web3dart <3.0.3 returns the EIP-1559 body without its type byte.
if (transaction.isEIP1559 && signed.first >= 0xc0) {
  signed = prependTransactionType(0x02, signed);
}
```
```dart
// send_rpc_test.dart, in the unanswered-broadcast case
expect(broadcast, startsWith('0x02'));
```
Also align the two lockfiles (bump the root to web3dart 3.0.3, or constrain `genius_api`'s range), so package tests run the same library the app ships.

## Warnings

### WR-15 (still open, narrowed): the native value of a mixed token call is stored but never shown

**File:** `lib/reown/handle_dapp_requests.dart:297-300`; `lib/dashboard/home/widgets/transaction_utils.dart:711`; `lib/dashboard/home/widgets/transaction_displays.dart:964`
**Issue:** The second `TransferRecipients` row is written, but every history view reads `recipients.first` only (the list row's amount and the detail drawer's counterparty). Nothing in `lib/` iterates past the first recipient. The user still cannot see that native value went to the contract, which is what WR-15 was about.
**Fix:** Surface it in the detail drawer, for example an extra `TxDetailRow(label: 'Also sent', value: '${formatTxAmount(r.amount)} ${tx.coinSymbol}')` for each `tx.recipients.skip(1)`. Alternatively, put the native value on a dedicated field that the drawer already renders.

### WR-17: Swap now treats an "unconfirmed" broadcast as a confirmed one. The fix report says swap is unchanged, and it is not.

**File:** `lib/squid_router/swap_screen.dart:497-504`; `lib/squid_router/swap_execution.dart:264-289`
**Issue:** The swap `send` callback returns `response.data` without checking `isSuccess`. Before this change, `data` was always null on failure, so the swap returned `SwapSendFailed`. Now `ApiResponse.unconfirmed` carries a hash, so `executeSwap` takes it as proof that "the hash is real, so the transfer is on the network" (`swap_execution.dart:273`). It writes a pending row and polls Squid 20 times. A never-received transaction then sits as a pending swap for good ("nothing else ever re-polls a stored swap"), and the user gets none of the "check history before sending again" warning that `/send` shows. No test covers this path.
**Fix:** Decide the behaviour explicitly. Either keep the old contract:
```dart
send: (tx) async {
  final response = await api.signAndSendTransaction(...);
  return response.isSuccess ? response.data : null;
},
```
Or carry the unconfirmed flag into `SwapOutcome` and word the result like `/send` does. Add a swap test for `ApiResponse.unconfirmed` either way.

### WR-18: The signer's own RPC calls have no timeout, and its "maybe sent" classification is too wide

**File:** `packages/genius_api/lib/web3/web3.dart:723,730-741,748`
**Issue:** There are two parts.
1. **Too narrow.** WR-16 capped the send-service reads, but not `signTransaction` (its nonce read), `sendRawTransaction`, or the diagnostic `getTransactionReceipt` after a successful broadcast. `package:http`'s `Client()` has no response timeout. A stalled broadcast never throws, so the `unconfirmed` branch, which exists for exactly that case, is unreachable. A stall in the diagnostic receipt read *after* the node accepted the transaction keeps `signAndSendTransaction` from returning at all. No pending row is written, `busy` stays true, and if the user leaves, the funds have moved with no record.
2. **Too wide.** web3dart raises `RPCError` only for a JSON error body (`json_rpc.dart:62-71`). An HTML 429 or 502 from a rate limiter throws `FormatException`. The endpoint answered, so the transaction was almost certainly not accepted, yet it is classified as possibly sent. That leaves a pending row which, per the WR-11 `ponytail:`, never settles.

**Fix:**
```dart
txHash = await client.sendRawTransaction(signed).timeout(rpcReadTimeout);
} on RPCError catch (e) { return ApiResponse.error(...); }
  on FormatException catch (e) { return ApiResponse.error(...); } // the node answered
  catch (e) { return ApiResponse.unconfirmed(...); }            // timeout / IO
...
final receipt = await client.getTransactionReceipt(txHash).timeout(rpcReadTimeout);
```
Also wrap `signTransaction` in `.timeout(rpcReadTimeout)`. A timeout there is safe to report as not sent, because nothing has been broadcast yet.

### WR-19: Sending more of the native coin than the balance now reports "Couldn't estimate the network fee"

**File:** `lib/send/send_cubit.dart:542-562`; `test/send/send_cubit_test.dart:272-286`
**Issue:** WR-07 attaches `value: rawAmount` to `estimateGas`. On geth-family nodes (geth, bor, op-geth), estimating a call whose `value` exceeds the sender's balance fails with "insufficient funds for gas * price + value". The catch at `:599` turns that into the fee message, so the `rawAmount + fee.maxCost > balance` check at `:556` never runs for a plain over-balance. This is WR-06's defect again, now on the native path. The test "amount plus fee above balance names the gas coin" (balance 0, amount 0.5) passes only because the fake `estimateSendFee` never refuses. It anchors on the fake, not on chain behaviour.
**Fix:** Read the native balance first, and refuse `rawAmount > balance` before estimating, the same way the token path already does:
```dart
final balance = await api.nativeBalance(address: walletAddress, rpcUrl: rpcUrl);
if (tokenContract == null && rawAmount > balance) {
  settle(amountError: "Not enough $gasSymbol to cover the amount and the fee.");
  return;
}
final fee = await api.estimateSendFee(...);
```
Make the test fake throw when `value > balance`.

### WR-20: A failed or stalled token balance read is reported as "Your USDC balance doesn't cover this amount"

**File:** `lib/send/send_cubit.dart:520-533`; `packages/genius_api/lib/web3/web3.dart:303-330`; `test/send/send_rpc_test.dart` ("ends a token balance read")
**Issue:** `rawBalanceOf` swallows every error, now including the 15 s timeout, and returns `BigInt.zero`. WR-06 moved the balance check ahead of the fee read, so a dead RPC or a rate-limited `eth_call` on a token send now tells the user they lack funds, and puts that message on the Amount field. Before the reorder, the same failure came out as a fee error. The new RPC test asserts the zero, so it holds the misreport in place.
**Fix:** Let the send path tell "zero" apart from "unknown". Either add a throwing variant for `SendReads` (for example `readTokenBalance` without the catch) and use it in `review()` and `useMax()`, or have `rawBalanceOf` return `BigInt?`, with null on failure, and map null to `"Couldn't read your $symbol balance."`.

### WR-21: A send settled during its own poll shows up twice in history

**File:** `lib/send/send_cubit.dart:672-681`; `lib/dashboard/transactions/cubit/transactions_cubit.dart:13-31`; `lib/bloc/app_bloc.dart:130-140`
**Issue:** `submit()` writes the pending row to Hive, polls for up to about 60 s, then calls `transactions.addTransaction(resolved)`. Leaving `/send` does not stop that. Any `LoadWallets` in that window reloads Hive into the cubit's identity-keyed `Set`, including the pending instance, and starts `settlePendingSends`; dashboard pull-to-refresh dispatches one (`dashboard_screen.dart:149`). `submit()` then adds a *second* instance with the same hash. The history shows two rows for one send, pending and completed, or completed twice. That invites exactly the "did it go through?" resend the phase works to prevent. `replaceTransaction` was added in this same fix set but is not used here.
**Fix:** `transactions.replaceTransaction(resolved);` at `send_cubit.dart:681`. It removes any row with that hash and then adds, so it is also correct when no earlier row exists.

## Info

### IN-08: Tapping Send after `/send` was torn down throws on a closed cubit

**File:** `lib/send/send_screen.dart:276-285`
**Issue:** CR-01 added a `context.mounted` guard to the cancel branch only. If the `BlocProvider` is disposed while the root drawer is open (its key changes on a wallet or network switch, or the shell route is replaced), tapping Send calls `cubit.submit()`, whose first `emit` throws `StateError`. Nothing is signed, but the error is unhandled.
**Fix:** Move the `if (!context.mounted) { return; }` above the `shouldSend` branch so it guards both answers.

### IN-09: The dApp path drops the hash of an unconfirmed broadcast

**File:** `lib/reown/handle_dapp_requests.dart:230-248`
**Issue:** Behaviour is unchanged from before (it checks `isSuccess` first), but the new `ApiResponse.unconfirmed` hash is discarded. The dApp is told the call failed and no row is written, so a dApp retry can still double-send, which is the risk WR-03 was about.
**Fix:** When `result.data != null` on failure, record a pending row under that hash, so the startup settle picks it up.

### IN-10: A settled Base send records less than it cost

**File:** `packages/genius_api/lib/web3/send_service.dart` (`feePaid`); `lib/send/send_cubit.dart:173,236-243`
**Issue:** `feePaid` is `gasUsed * effectiveGasPrice`, which excludes the OP-Stack L1 data fee. The review drawer shows `maxCost` with the L1 fee included, but the settled row on 8453 or 84532 drops it.
**Fix:** Parse the receipt's `l1Fee` field (OP-Stack receipts carry it) and add it, or label the row "L2 fee".

### IN-11: The address-error wording no longer matches the check behind it

**File:** `lib/account/sdk_account_manager.dart:757-766`; `lib/send/recipient_field.dart:71-76`
**Issue:** The payout field now refuses a mixed-case address with a bad checksum, but still says "Not a complete address - 42 characters starting with 0x." The recipient field shows the checksum message for a `0X…` (capital-X) input, which `isEvmAddress` rejects because of the prefix, not the checksum.
**Fix:** Reuse the recipient field's checksum branch in the payout form. Test `trimmed.startsWith('0x')` before blaming capitals.

### IN-12: Every `LoadWallets` starts another settle round

**File:** `lib/bloc/app_bloc.dart:131-140`
**Issue:** Settling is bounded, but it re-runs on every pull-to-refresh, and rounds can overlap. A dropped transaction, which never settles, is read again on every refresh, for up to 15 s per row. The writes are idempotent, so no data is lost.
**Fix:** Keep a `Future? _settling` in `AppBloc` and skip a new round while one is running.

---

_Reviewed: 2026-09-23T21:00:58Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
_Iteration: 2_
