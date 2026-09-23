---
phase: 31-send-native-coins-and-erc-20-tokens
reviewed: 2026-09-23T18:14:33Z
depth: standard
files_reviewed: 27
files_reviewed_list:
  - packages/genius_api/lib/web3/send_service.dart
  - packages/genius_api/lib/src/genius_api.dart
  - packages/genius_api/lib/models/transaction.dart
  - packages/genius_api/lib/models/transaction.g.dart
  - lib/send/send_cubit.dart
  - lib/send/send_screen.dart
  - lib/send/recipient_field.dart
  - lib/navigation/router.dart
  - lib/tokens/token_info_screen.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/dashboard/home/widgets/transaction_utils.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/reown/handle_dapp_requests.dart
  - ios/Runner/Info.plist
  - macos/Runner/Info.plist
  - macos/Runner/DebugProfile.entitlements
  - macos/Runner/Release.entitlements
  - test/send/built_tx_matches_test.dart
  - test/send/recipient_field_test.dart
  - test/send/send_cubit_test.dart
  - test/send/send_screen_test.dart
  - test/send/send_service_test.dart
  - test/send/send_token_test.dart
  - test/dashboard/transaction_asset_chain_test.dart
  - test/dashboard/dashboard_send_entry_test.dart
  - test/tokens/coin_page_stat_rail_test.dart
  - test/reown/handle_dapp_requests_test.dart
findings:
  critical: 3
  warning: 16
  info: 7
  total: 26
status: issues_found
---

# Phase 31: Code Review Report

**Reviewed:** 2026-09-23T18:14:33Z
**Depth:** standard
**Files Reviewed:** 27 (plus the call chain into `web3.dart`, `squid_util.dart`, `reown/utilities.dart`, `responsive_drawer.dart`, the `eip1559` package and `networks.json`)
**Status:** issues_found

## Summary

Key custody holds up. `SendState` carries no key. `tool/check_no_new_key_logging.sh` passes on every send file, and so do `check_brace_style.sh` and `check_raw_colors.sh`. The calldata self-check runs on every review, and native value on a token call is refused. Wei and token amounts stay in `BigInt` throughout the cubit. Hive fields 18 and 19 are nullable and read back as null on old rows. The QR scanner is never built on Windows or Linux.

The flow still cannot ship:

1. **Send cannot complete inside the real router.** The confirm drawer's buttons pop the `/send` page, not the drawer (CR-01). No test uses a `ShellRoute`, and the live walk is still marked PENDING in `31-05-SUMMARY.md`.
2. **The drawer shows the wrong amount for 6-decimal tokens.** USDC and USDT on Ethereum, Polygon and Base are affected (CR-02).
3. **A scanned token payment link can make the token contract the recipient.** This applies to an EIP-681 `/transfer` link (CR-03).

There are also several ways the cubit gets stuck, loses a record, or shows the wrong reason.

## Critical Issues

### CR-01: Confirm drawer's Send/Cancel pop the /send page, not the drawer — the send can never be approved in the app

**File:** `lib/send/send_screen.dart:246`, `lib/send/send_screen.dart:255`, `lib/send/send_screen.dart:262-264`
**Issue:** `ResponsiveDrawer.show` defaults to `useRootNavigator: true` (`responsive_drawer.dart:99,129,164`). `/send` is registered inside the `ShellRoute` (`router.dart:214,268`), and go_router gives that shell its own nested `Navigator`. The footer closures call `Navigator.of(context)` with the `_SendBody` context, which resolves to the shell navigator:
- Tapping **Send** pops the `/send` route with `true`. The drawer stays open on the root navigator, and `shouldSend` never resolves to `true`.
- Tapping **Cancel** does the same. When the user then dismisses the drawer, `shouldSend` is `null`, and `cubit.cancelReview()` runs on a cubit that `BlocProvider` already closed. That throws `StateError: Cannot emit new states after calling close`, and nothing catches it.

`swap_settings_drawer.dart:55-64` records that this exact bug already shipped once in this repo ("popped the SWAP ROUTE"), and its fix is `rootNavigator: true`. `send_screen_test.dart` mounts `SendScreen` under a plain `MaterialApp` (one navigator), so the tracer test passes against a topology the app never uses.
**Fix:**
```dart
final rootNav = Navigator.of(context, rootNavigator: true);
...
onPressed: () => rootNav.pop(false),
...
onPressed: () => rootNav.pop(true),
...
if (shouldSend != true) {
  if (!context.mounted) {
    return;
  }
  cubit.cancelReview();
  return;
}
```
Add one widget test that mounts `/send` under a `GoRouter` with a `ShellRoute`, taps Send, and asserts that `signAndSendTransaction` was called.

### CR-02: Review drawer formats every amount as 18-decimal ETH — a 6-decimal token shows a value 10^12 times too small

**File:** `lib/send/send_screen.dart:232`
**Issue:** `amount: formatEth(review.rawAmount.toString())` divides by 10^18 regardless of the coin. It also uses double division and `toStringAsFixed(10)` (`reown/utilities.dart:37-45`). USDC and USDT are 6-decimal on Ethereum, Polygon and Base (`assets/json/tokens/*.json`). Sending 100 USDC signs `100000000` base units, but the drawer's hero and "You send" row read `0.0000000001 USDC`. The screen that authorises a real transfer does not show what is signed, and `SendTransactionDetails` says every value "arrives already formatted" from the caller. No test opens the drawer for a token: `send_screen_test.dart` only covers MATIC.
**Fix:** Format with the coin's own decimals, using the same exact helper `sendRow` already uses:
```dart
final decimals = cubit.state.coin?.address == null
    ? 18
    : int.parse(cubit.state.coin!.decimals!); // review() already validated it
amount: formatTokenAmount(review.rawAmount, decimals),
```
It is better still to put `decimals` (or the formatted amount) on `SendReview`, so the drawer cannot disagree with the cubit.

### CR-03: `addressFromScan` takes the first 40-hex run — an ERC-20 payment QR seats the token contract as the recipient

**File:** `lib/send/recipient_field.dart:24-25`
**Issue:** An EIP-681 token request, such as MetaMask's "request payment" for a token, has this shape:
`ethereum:0x<TOKEN>@1/transfer?address=0x<RECIPIENT>&uint256=...`. The regex returns the token contract, and `setRecipient` seats it. The contract note then appears, but it is only a note and it does not block the send. Tokens that don't blacklist their own address, such as USDT, are lost for good.

The regex also has no boundary. A QR holding any longer `0x` hex string (a transaction hash or a 32-byte key) yields its first 20 bytes as a valid-looking address that nobody controls. The test at `recipient_field_test.dart:249-253` pins only the plain `ethereum:0xADDR@137` form.
**Fix:** Parse the payload instead of pattern-matching it:
```dart
String? addressFromScan(String raw) {
  final s = raw.trim();
  if (isEvmAddress(s)) {
    return s;
  }
  final uri = Uri.tryParse(s);
  if (uri == null || uri.scheme != 'ethereum') {
    return null;
  }
  // `ethereum:<target>[@chain][/function]?params`
  final path = uri.path;
  final target = RegExp(r'^(?:pay-)?(0x[0-9a-fA-F]{40})(?![0-9a-fA-F])').firstMatch(path)?.group(1);
  if (path.contains('/transfer')) {
    final to = uri.queryParameters['address'];
    return to != null && isEvmAddress(to) ? to : null;
  }
  return target;
}
```
Add tests for the `/transfer?address=` form and for a 64-hex payload (it must return null).

## Warnings

### WR-01: Form stays editable while `review()` is in flight — a stale review lands after an edit cleared it

**File:** `lib/send/send_cubit.dart:350,374,475-485`; `lib/send/send_screen.dart:166-192`
**Issue:** `review()` captures `recipient` and `rawAmount` before its awaits. Neither text field is disabled while `busy`, and `setRecipient`/`setAmount` don't check `busy`. An edit during the fee/balance reads runs `clearReview`, and then `review()` emits a `SendReview` built for the old values. The drawer opens showing the old recipient and amount, and the form shows the new ones. The drawer does match what gets signed, but the invariant "any edit clears the review" is broken, and the user is reviewing values they already changed.
**Fix:** Disable both fields (`enabled: !state.busy`), or check before emitting:
```dart
if (state.recipient.trim() != recipient || toBaseUnits(state.amount.trim(), decimals) != rawAmount) {
  emit(state.copyWith(busy: false));
  return;
}
```

### WR-02: `submit()` has no exception path — a throw leaves `busy` stuck and, after broadcast, no history row

**File:** `lib/send/send_cubit.dart:518`, `:556-568`
**Issue:** `GeniusApi.signAndSendTransaction` calls `_secureStorage.getWallet` (`readAll()` on the platform keychain) outside any `try` (`genius_api.dart:1281`). The two `storage.addTransaction` Hive writes are also unguarded. If either throws, `busy` stays `true` for good, Review and MAX stay disabled, and the error escapes `_review` unhandled. When the throw is a Hive write *after* broadcast, funds have moved, and neither Hive nor `TransactionsCubit` records it.
**Fix:** Wrap the sign call in `try/catch`, and emit `busy: false` with an error on failure. After a hash exists, guard each write separately so that one failed write can't skip `transactions.addTransaction(resolved)` or the final emit:
```dart
try { await storage.addTransaction(walletAddress, rowWith(TransactionStatus.pending)); } catch (_) {}
...
transactions.addTransaction(resolved); // always, once a hash exists
```

### WR-03: An ambiguous broadcast failure is reported as "not sent" and invites a second transfer

**File:** `packages/genius_api/lib/web3/web3.dart:714-734` (reached from `send_cubit.dart:518-536`)
**Issue:** `client.sendTransaction` signs and then calls `eth_sendRawTransaction`. If the RPC accepted the transaction but the HTTP response was lost or timed out, the result is `ApiResponse.error`. The cubit keeps the form and shows the error, and the natural next step (Review, then Send) signs a *second* transfer with the next nonce. The hash can be computed locally before broadcast, but it is thrown away.
**Fix:** Sign with `client.signTransaction` first and compute `keccak256(signed)`. Then call `sendRawTransaction`. On a send error, return the known hash marked as uncertain, and have the cubit poll it (for example, write a pending row) before it reports failure.

### WR-04: Recipient validation accepts a mixed-case address with a bad EIP-55 checksum, and the zero address

**File:** `lib/send/send_cubit.dart:203,351`; `lib/utils/wallet_utils.dart:4-7`
**Issue:** `isEvmAddress` is a bare hex regex. A single-character typo in a checksummed (mixed-case) address, the usual copy-typo case, passes and is sent. `0x000…000` passes with no warning, because it has no code, so the contract note never fires. Checksum validation is the standard guard against this.
**Fix:** In `review()` (and for the field error), reject a mixed-case address whose checksum fails, for example `EthereumAddress.fromHex(recipient, enforceEip55: true)` when `recipient != recipient.toLowerCase()`. Refuse the zero address, or warn about it.

### WR-05: The confirm drawer shows neither the network nor the token contract

**File:** `lib/send/send_screen.dart:226-238`; `lib/tokens/token_info_screen.dart:787-795`
**Issue:** The coin page's Send button seats the coin on `selectedNetwork`, the wallet-wide network, not a network the coin page chose. A user on a "USDC" market page with BNB selected sends BNB-chain USDC, and nothing in the drawer names the chain or the contract. Sending on the wrong chain to an exchange deposit address is a common permanent loss.
**Fix:** Add `Network: ${cubit.network.name}` to the drawer. For a token, also add a truncated contract row (for example `GWCopyRow(label: 'Token', value: tokenContract)`).

### WR-06: Token over-balance is reported as "Couldn't estimate the network fee" — the balance check comes after `estimateGas`, which reverts first

**File:** `lib/send/send_cubit.dart:394-434`
**Issue:** On a real chain, `estimateGas` for `transfer(to, amount > balance)` reverts. The catch at `:486` turns that into the fee message, so the `rawAmount > tokenBalance` branch at `:423` never runs. The test `send_token_test.dart:224-237` passes only because the fake `estimateSendFee` never reverts: it anchors on the fake, not on chain behaviour. A blacklisted or paused token gets the same misleading fee message.
**Fix:** Read `rawBalanceOf` and check it *before* `estimateSendFee`. Make the test's fake throw when `amount > tokenBalance`.

### WR-07: Native-send gas is estimated with no `value`, so the simulation isn't the transaction that is signed

**File:** `packages/genius_api/lib/web3/send_service.dart:244-248`
**Issue:** `estimateGas(sender, to, data)` leaves out `value`. A contract recipient with a non-payable fallback accepts a zero-value call, so the estimate succeeds and review passes. The real send carries value and reverts on-chain, and the user pays the fee for nothing. Contracts whose `receive` costs more when value is attached are also under-estimated.
**Fix:** Pass the amount through: `readSendFee(..., BigInt? value)` → `client.estimateGas(..., value: EtherAmount.inWei(value))`, called with `rawAmount` for native sends. MAX can keep passing none.

### WR-08: The "median" fee is the maximum over 10 blocks, with no ceiling; the comment says otherwise

**File:** `packages/genius_api/lib/web3/send_service.dart:229-236`
**Issue:** `eip1559.getGasInEIP1559` (eip1559 0.6.2) takes the **maximum** of the per-block 50th-percentile reward over the last 10 blocks. It then computes `maxFee = 1.5 * (0.9*base + prio)` in `double`. One outlier block makes that priority fee the one signed, and the full priority is paid, not refunded. The comment "not the most eager quote and not the most conservative, no buffer added" is wrong on both counts. Nothing between `chooseFeePerGas` and the signer caps an absurd answer. The drawer shows it only through `formatEth`, which prints `0.0000000000` for sub-10⁻¹⁰ per-gas values on L2s.
**Fix:** Correct the comment. Add a sanity cap in `chooseFeePerGas`, for example refusing with `SendFeeUnavailable` if `maxPriorityFeePerGas > legacyGasPrice * k`. Alternatively, source priority from `eth_maxPriorityFeePerGas`, and mark the ceiling with a `ponytail:` comment.

### WR-09: MAX and the balance check ignore the OP-Stack L1 data fee on Base

**File:** `lib/send/send_cubit.dart:307,406,439`; `send_service.dart:137-140`
**Issue:** On Base (8453, in the catalogue), the sender also pays an L1 data fee on top of `gasLimit * maxFeePerGas`, and the txpool checks for it. MAX sets the amount to exactly `balance - maxCost`, and review allows `rawAmount + maxCost == balance`. The broadcast is then rejected with "insufficient funds". The fee shown also understates the real cost.
**Fix:** On OP-Stack chains, add the L1 fee from `GasPriceOracle.getL1Fee(rlp)` at `0x420…0F` to `maxCost`. At minimum, hold back a documented margin with a `ponytail:` comment, and label the fee as excluding L1 data.

### WR-10: Send is offered for tracking (watch-only) wallets, which can never sign

**File:** `lib/send/send_screen.dart:43`; `lib/components/coins/view/coins_screen.dart:519-534`; `lib/tokens/token_info_screen.dart:781`
**Issue:** Every gate checks only `canSignOn(network)`. A `WalletType.tracking` wallet gets the full form, the fee reads and the review, and then fails at signing with "No private key provided for signing" (`web3.dart:710-711`). The empty state's own text, "This wallet can't sign", describes a check that the code never makes.
**Fix:** Also require `wallet.walletType != WalletType.tracking` (and exclude `sgnus` if it has no EVM key) in all three gates.

### WR-11: A poll-exhausted send stays "pending" forever, with the max fee recorded as paid

**File:** `lib/send/send_cubit.dart:556-568`; `send_service.dart:150-172`
**Issue:** After about 60 seconds without a receipt (slow chain, dropped RPC, app closed mid-poll), the resolved row is still `pending`. Nothing in the app re-polls pending rows: no other code sets or reconciles `TransactionStatus.pending`. The row's `fees` is `fee.maxCost`, the upper bound, not what was paid. The doc comment's promise ("leaves the row pending, not lost") is true, but the row never reaches its final state.
**Fix:** On history load, re-poll rows that are `pending` and `type == transfer` with a `chainId`, and overwrite them by hash. Until then, label the fee "max" on pending rows.

### WR-12: A reverted transaction gets the success toast "Sent to 0x…"

**File:** `lib/send/send_screen.dart:271-277`
**Issue:** `submit()` returns the resolved row for a `status: false` receipt too (`settledStatus` → `failed`). The screen toasts "Sent to …" for any non-null result.
**Fix:** Branch on `recorded.transactionStatus`: show a failure toast for `failed` and a "Submitted, still confirming" message for `pending`.

### WR-13: Every cubit error is shown under the "To" field, including amount and fee errors

**File:** `lib/send/send_screen.dart:166-169`; `lib/send/recipient_field.dart:49-51`
**Issue:** "Enter an amount to send.", "Not enough MATIC to cover the amount and the fee." and signing errors all appear as the *recipient* field's `errorText`. WCAG 3.3.1 requires identifying the item in error, and here the error sits on the wrong input. The field's own format error also hides the cubit error (`:49`), so a fee error disappears while the address is being edited. The test `send_screen_test.dart:226-256` pins the misplacement.
**Fix:** Split `SendState.error` into `recipientError`, `amountError` and a form-level error. Put the amount and balance messages on the Amount field's `errorText`, and signing and fee messages in a persistent note above Review.

### WR-14: "Base - Sepolia" is signable, but its chain id (84531) doesn't match its RPC (Base Sepolia, 84532)

**File:** `assets/json/networks/networks.json:85-90`; `lib/dashboard/home/widgets/transaction_utils.dart:40-52`; `test/dashboard/transaction_asset_chain_test.dart:67-69`
**Issue:** `canSignOn` passes (chain id and RPC are both present), so Send appears. Every send signs with chain id 84531 and is rejected by a Base Sepolia node. The explorer map comment calls 84531 a "retired" chain that an old row might name. In fact, the live catalogue entry writes it on every new row, and 84532 has no link. The test pins the defect.
**Fix:** Correct the catalogue to `84532`, and add `84532: 'https://sepolia.basescan.org/tx/'`. Better still, verify `eth_chainId` against `network.chainId` once before signing.

### WR-15: dApp receipt rows now record raw base units for unverified tokens and drop the native value of mixed calls

**File:** `lib/reown/handle_dapp_requests.dart:271-279`
**Issue:** For `DappCallKind.unverifiedToken`, `summary.amount` is **raw base units** (`calldata_decoder.dart:458`). The row now reads, for example, `- 1,000,000,000,000,000,000 0x8335…` for 1 token. For a `tokenTransfer` that also moved native value (`summary.nativeAmount != null`), the row records only the token amount, so the native value sent to the contract disappears from history. The old row at least recorded `amountEth`.
**Fix:** For `unverifiedToken`, keep `to`/`amountEth` (or mark the amount as base units). When `summary.nativeAmount != null`, record both values, for example with a second `TransferRecipients` entry for the native amount.

### WR-16: No RPC call has a timeout — a hung RPC leaves Review/MAX spinning indefinitely

**File:** `packages/genius_api/lib/web3/send_service.dart:204,222,265,280`
**Issue:** Each read builds `Web3Client(rpcUrl, Client())` with no timeout. A stalled endpoint keeps `busy == true` until the user leaves the page. During `submit()`, one hung receipt read stalls the poll indefinitely, and the resolved row is never written.
**Fix:** Wrap each call, for example `await client.getBalance(...).timeout(const Duration(seconds: 15))`. `pollReceipt` already treats a throw as "not yet", so no other change is needed there.

## Info

### IN-01: The coin page seats a coin by symbol only, from a coin list that may belong to the previous network

**File:** `lib/send/send_screen.dart:85-104`; `lib/tokens/token_info_screen.dart:791`
**Issue:** `_seatedCoin` matches `walletState.coins` by symbol and ignores `coinsStatus`. `selectNetwork` emits the new network before `getCoins` replaces the list (`wallet_details_cubit.dart:142-145`). After switching A→B→A, the new key's `SendCubit` can seat B's coin, with B's contract, on A. Today's token lists have no duplicate symbols per chain, so a mismatch is caught downstream as a failed read.
**Fix:** Pass the contract address in `extra` and match on it. Seat nothing unless `coinsStatus == WalletStatus.successful`.

### IN-02: `Transaction.assetSymbol` doc contradicts both writers

**File:** `packages/genius_api/lib/models/transaction.dart:158-160`
**Issue:** It says the field is null "on a native send". `sendRow` (`send_cubit.dart:155`) and the dApp path (`handle_dapp_requests.dart:297`) always set it.
**Fix:** Say "null on rows an older build wrote".

### IN-03: Doc comments over the 3-line limit in AGENTS.md

**File:** `lib/send/send_cubit.dart:103-108,196-200,250-254,341-344,500-507`; `packages/genius_api/lib/web3/send_service.dart:96-100,146-149`; `lib/send/recipient_field.dart:19-23,27-30,120-123`; `lib/send/send_screen.dart:208-211`; `lib/dashboard/home/widgets/transaction_utils.dart:40-43,52-55`
**Fix:** Trim each one to the constraint. Move the history into the commit message.

### IN-04: Planning ids in new source comments

**File:** `test/send/send_token_test.dart:1` ("D-01"); `test/components/drawer_padding_invariant_test.dart:64` ("Phase 31's")
**Fix:** Describe the constraint instead of citing the decision or phase.

### IN-05: Per-gas fee rows print `0.0000000000` on L2s; "Gas Fee" is the max, not the estimate

**File:** `lib/send/send_screen.dart:235-237`
**Fix:** Show per-gas values in gwei with `formatTokenAmount(x, 9)`, and label the total "Max network fee".

### IN-06: The private key travels as a hex `String` through the send path

**File:** `packages/genius_api/lib/src/genius_api.dart:1284` → `packages/genius_api/lib/web3/web3.dart:675-678,714`
**Issue:** This code already existed, but the new send path adds a caller to it. AGENTS.md prefers `Uint8List` for secrets, because a `String` cannot be zeroed.
**Fix:** Pass the bytes to `EthPrivateKey(Uint8List)`, then zero the buffer after signing.

### IN-07: Excess decimals are silently truncated; a comma decimal separator is rejected

**File:** `lib/send/send_cubit.dart:374` (`toBaseUnits`, `squid_util.dart:17-20`)
**Issue:** Typing `0.1234567` USDC signs `0.123456` with no notice (made worse by CR-02's display). On locales whose numeric keyboard offers `,`, a value like `1,5` is refused as "Enter an amount to send."
**Fix:** Refuse input with more fraction digits than `decimals`, with a specific message. Normalise `,` to `.` before parsing.

---

_Reviewed: 2026-09-23T18:14:33Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
