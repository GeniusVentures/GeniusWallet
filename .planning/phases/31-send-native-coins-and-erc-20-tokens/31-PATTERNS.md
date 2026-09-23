# Phase 31: Send native coins and ERC-20 tokens - Pattern Map

**Mapped:** 2026-09-23
**Files analyzed:** 10 (per the four proposed plans in 31-CONTEXT.md / RESEARCH.md's recommended structure)
**Analogs found:** 10 / 10 (RESEARCH.md already did the heavy analog-finding; this file extracts the concrete excerpts the planner copies from)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `packages/genius_api/lib/models/transaction.dart` (edit: new `@HiveField(18)`) | model | CRUD | itself, additive edit — pattern is field 17's own precedent | exact (self-precedent) |
| `packages/genius_api/lib/models/transaction.g.dart` (regenerated, not hand-edited) | model (generated) | CRUD | `build_runner` output — do not hand-copy | n/a, run generator |
| `lib/dashboard/home/widgets/transaction_utils.dart` (edit: new-field readers) | utility | transform | itself, existing `coinSymbol` reader sites | exact (self-precedent) |
| `packages/genius_api/lib/web3/send_service.dart` (new) | service | request-response | `lib/squid_router/swap_execution.dart` (`executeSwap`/`_poll`) + `packages/genius_api/lib/web3/web3.dart` (`approve`, `signAndSendTransaction`, `rawBalanceOf`) | exact (role + data flow) |
| `packages/genius_api/test/send_service_test.dart` (new) | test | request-response | none exists yet in this package — first file, mirror `lib/squid_router/swap_execution.dart`'s own test style (injected `wait`, pure functions) | role-match, cross-package |
| `lib/send/send_cubit.dart` (new) | store/hook | event-driven | `lib/squid_router/swap_screen.dart`'s form-state fields (e.g. `nativeCoinBaseUnits`, `isSubmitting` guard) — no existing `SwapCubit`; swap is a `StatefulWidget`, closest Cubit analog is any form cubit in `lib/wallets/cubit/` | role-match |
| `lib/send/send_screen.dart` (new) | component | request-response | `lib/squid_router/swap_screen.dart` (route target reading `extra`) | exact (role + data flow) |
| `lib/send/recipient_field.dart` (new) | component | request-response | `GWTextField` suffix-slot usage (swap's amount field) + `isEvmAddress`/`getCode` for validation; no existing paste/QR field to copy wholesale | role-match, no exact analog |
| `lib/navigation/router.dart` (edit: add `/send` `GoRoute`) | route | request-response | the existing `/swap` `GoRoute` in the same file | exact |
| `lib/tokens/token_info_screen.dart` (edit: add Send `GWButton` to `_CoinActionRow`) | component | request-response | the same file's own `Swap`/`Receive` buttons in `_CoinActionRow` | exact (self-precedent) |
| `test/tokens/coin_page_stat_rail_test.dart` (edit: flip the "no Send" assertion) | test | request-response | itself — the test being edited, at the exact lines the new CTA must satisfy | exact (self-precedent) |

## Pattern Assignments

### `packages/genius_api/lib/web3/send_service.dart` (service, request-response)

**Analogs:** `lib/squid_router/swap_execution.dart` (poll/write-order shape), `packages/genius_api/lib/web3/web3.dart` (signing, ABI, raw balance)

**Bounded poll pattern** (`lib/squid_router/swap_execution.dart:304-334`, quoted verbatim):
```dart
Future<SwapSettlement> _poll({
  required SwapTransaction route,
  required String hash,
  required Future<SwapSettlement> Function(SwapTransaction route, String hash)
  readStatus,
  required Future<void> Function(Duration delay) wait,
  required int attempts,
  required Duration interval,
}) async {
  var settled = const SwapSettlement(status: SwapStatus.ongoing);
  for (var attempt = 0; attempt < attempts; attempt++) {
    if (attempt > 0) { await wait(interval); }
    try {
      settled = await readStatus(route, hash);
    } catch (_) {
      settled = const SwapSettlement(status: SwapStatus.notFound);
    }
    if (isTerminal(settled.status)) { return settled; }
  }
  return settled; // Unresolved is unresolved, read as pending.
}
```
Send's version swaps `readStatus`/`SwapSettlement` for `Web3Client.getTransactionReceipt(hash)`; a thrown read or a `null` receipt is "not yet", same convention. Every dependency (client, `wait`) must be injected exactly like `executeSwap`'s signature (`swap_execution.dart:200-214`) so the service stays unit-testable with no UI, per the "unit-tested with no UI" bar in CONTEXT.md.

**ERC-20 ABI to extend for `transfer`** (`packages/genius_api/lib/web3/web3.dart:48-56`, quoted verbatim):
```dart
static final abi = ContractAbi.fromJson('''[
  ...
  { "constant": false, "inputs": [{ "name": "_to", "type": "address" }, { "name": "_value", "type": "uint256" }], "name": "transfer", "outputs": [{ "name": "", "type": "bool" }], "type": "function" },
  { "constant": false, "inputs": [{ "name": "_spender", "type": "address" }, { "name": "_value", "type": "uint256" }], "name": "approve", "outputs": [{ "name": "success", "type": "bool" }], "type": "function" }
]''', '');
```
`transfer` is already declared — no ABI edit needed, only `contract.function('transfer').encodeCall([...])` (RESEARCH.md's Pattern 3 shows the full call site).

**Raw (non-`double`) balance read to mirror for native coin** (`packages/genius_api/lib/web3/web3.dart:297-322`, quoted verbatim):
```dart
Future<BigInt> rawBalanceOf({
  required String address,
  required String contractAddress,
  required String rpcUrl,
}) async {
  final client = Web3Client(rpcUrl, Client());
  final contract = DeployedContract(abi, EthereumAddress.fromHex(contractAddress));
  try {
    final result = await client.call(
      contract: contract,
      function: contract.function('balanceOf'),
      params: [EthereumAddress.fromHex(address)],
    );
    return BigInt.parse(result.first.toString());
  } catch (e) {
    return BigInt.zero;
  } finally {
    await client.dispose();
  }
}
```
Native MAX needs `client.getBalance(address)` (already `EtherAmount`, in wei) minus `maxFeePerGas * gasLimit`, clamped to zero — see `nativeCoinBaseUnits`'s own `ponytail:` comment below for why `Coin.balance` (a `double`) must not be the source for the actual on-chain read.

**Decimal-safe conversion, reuse don't reinvent** (`lib/squid_router/squid_util.dart:1-34`, quoted verbatim):
```dart
BigInt? toBaseUnits(String amount, int decimals) {
  if (decimals < 0) { return null; }
  final match = RegExp(r'^(\d*)(?:\.(\d*))?$').firstMatch(amount.trim());
  if (match == null) { return null; }
  final whole = match.group(1) ?? '';
  final fraction = match.group(2) ?? '';
  if (whole.isEmpty && fraction.isEmpty) { return null; }
  final scaled = fraction.padRight(decimals, '0').substring(0, decimals);
  return BigInt.parse('0$whole$scaled');
}

String formatTokenAmount(BigInt raw, int decimals) {
  final divisor = BigInt.from(10).pow(decimals);
  final integerPart = raw ~/ divisor;
  final fractionalPart = raw.remainder(divisor).toString().padLeft(decimals, '0');
  final trimmedFraction = fractionalPart.replaceFirst(RegExp(r'0+$'), '');
  return trimmedFraction.isEmpty ? integerPart.toString() : '$integerPart.$trimmedFraction';
}
```

**MAX-on-native precedent, with its own accepted ceiling** (`lib/squid_router/swap_screen.dart:60-78`, quoted verbatim):
```dart
// ponytail: `Coin.balance` is a double, so a holding needing more than ~17
// significant digits is already rounded before it reaches this line. Accepted
// because it is the same figure the rest of the app displays; the upgrade path
// is a string or BigInt balance on `Coin`. `toStringAsFixed` is what keeps a
// dust balance out of exponent notation, which `toBaseUnits` rejects.
BigInt? nativeCoinBaseUnits(List<Coin> coins, int decimals) {
  if (decimals < 0) { return null; }
  for (final coin in coins) {
    if (coin.address == null && coin.balance != null) {
      return toBaseUnits(
        coin.balance!.toStringAsFixed(decimals.clamp(0, 20).toInt()),
        decimals,
      );
    }
  }
  return null;
}
```
Send's own version should carry the same `ponytail:` comment naming the same ceiling, since it is the identical corner being cut.

**Signing entry point — build the tx map to this exact shape, do not touch the key** (`packages/genius_api/lib/web3/web3.dart:681-709`):
```dart
Future<ApiResponse<String>> signAndSendTransaction({
  required Map<String, dynamic> tx,
  required String rpcUrl,
  required String privateKey,
  required int chainId,
}) async {
  ...
  final transaction = Transaction(
    from: from, to: to, value: EtherAmount.inWei(value),
    maxPriorityFeePerGas: EtherAmount.inWei(maxPriorityFee),
    maxFeePerGas: EtherAmount.inWei(maxFeePerGas),
    data: data, maxGas: gasLimit.toInt(),
  );
```
`tx['maxFeePerGas']`/`tx['maxPriorityFeePerGas']` default to `0x0` if absent — Common Pitfall #1 in RESEARCH.md means Plan 2 must always populate both, never omit them believing a chain is "legacy-only".

**Address validation, reuse verbatim** (`lib/utils/wallet_utils.dart:1-7`, quoted verbatim):
```dart
bool isEvmAddress(String raw) {
  final v = raw.trim();
  return RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(v);
}
```

---

### `lib/send/send_screen.dart` + `lib/navigation/router.dart` (component/route, request-response)

**Analog:** `lib/squid_router/swap_screen.dart` + the existing `/swap` `GoRoute`

**Route pattern to mirror exactly** (`lib/navigation/router.dart:252-265`, quoted verbatim):
```dart
GoRoute(
  path: '/swap',
  builder: (context, state) {
    final extra = state.extra is Map<String, dynamic>
        ? state.extra as Map<String, dynamic>
        : const <String, dynamic>{};
    return SwapScreen(
      preselectSymbol: extra['symbol'] as String?,
      preselectChainId: extra['chainId'] as int?,
    );
  },
),
```
D-03 says `/send` is "built like `/swap` (an `extra` map carrying symbol + chainId)" — copy this shape verbatim with `SendScreen` in place of `SwapScreen`.

**Crash-safe pending-then-resolved write order** (`lib/squid_router/swap_screen.dart:566-605`, quoted verbatim):
```dart
Transaction rowWith(TransactionStatus status) => _swapRow(
  hash: broadcast.hash, status: status, walletAddress: walletAddress,
  networkSymbol: networkSymbol, submitted: submitted,
  recoveryUrl: broadcast.recoveryUrl,
);

// Written BEFORE the resolved status, keyed by the real hash: a crash
// between broadcast and resolution must leave an accurate pending row
// rather than no record of funds that already moved.
await widget.storage.addTransaction(walletAddress, rowWith(TransactionStatus.pending));
final resolved = rowWith(broadcast.status);
await widget.storage.addTransaction(walletAddress, resolved);
...
transactionsCubit.addTransaction(resolved);
```
`TransactionsCubit` has no `==`/`hashCode` override on `Transaction` (RESEARCH.md Pitfall #2) — never call `addTransaction` with the pending instance, only the resolved one, exactly once.

---

### `lib/tokens/token_info_screen.dart` (edit: add Send button to `_CoinActionRow`)

**Analog:** the same file's own `Swap` button, `lib/tokens/token_info_screen.dart:742-779`, quoted verbatim:
```dart
GWButton(
  variant: GWButtonVariant.gradient,
  size: GWButtonSize.sm,
  label: 'Swap',
  leading: const Icon(Icons.swap_horiz),
  onPressed: () => GoRouter.of(context).push(
    '/swap',
    extra: <String, dynamic>{
      'symbol': marketData?.symbol ?? selectedCoin?.symbol,
      'chainId': selectedNetwork?.chainId,
    },
  ),
),
```
Send's CTA is the same shape with `'/send'` and `label: 'Send'`, same `marketData.symbol` FIRST / `selectedCoin` fallback rule (the comment above explains why: `selectedCoin` is the wallet's currently-selected coin, not necessarily the coin this page is showing). Use `push`, not `go` — the same ShellRoute-nesting reasoning documented in that comment block applies identically to `/send`.

---

### `test/tokens/coin_page_stat_rail_test.dart` (edit: flip the "no Send" assertion)

**Current assertion to update** (`test/tokens/coin_page_stat_rail_test.dart:131-158`, quoted verbatim — the exact lines SEND-07 requires editing):
```dart
testWidgets('074-C2: no Send, and no Bridge on a coin that cannot bridge', (tester) async {
  ...
  // Send has no screen and no route - `GeniusApi.transferTokens` has zero
  // callers - so it must not appear at all, including as a disabled box.
  expect(find.widgetWithText(GWButton, 'Send'), findsNothing);

  expect(find.widgetWithText(GWButton, 'Swap'), findsOneWidget);
  expect(find.widgetWithText(GWButton, 'Bridge'), findsNothing);
});
```
This must become `findsOneWidget` once the CTA ships, and the stale "`GeniusApi.transferTokens` has zero callers" comment must be removed or corrected — it is about to become false for the Send button's existence claim (though still true that `transferTokens`/SGNUS itself stays unused per D-01).

---

## Shared Patterns

### Signing / key custody
**Source:** `packages/genius_api/lib/web3/web3.dart:656-709` (`getPrivateKeyStr`, `signAndSendTransaction`)
**Apply to:** `send_service.dart` only. Never `lib/send/send_cubit.dart` — AGENTS.md's wallet-safety rule and RESEARCH.md's V4 note both require the key to resolve and stay entirely inside `genius_api`; `SendCubit` state carries recipient/amount/warnings only.

### Bounded polling
**Source:** `lib/squid_router/swap_execution.dart:304-334`
**Apply to:** `send_service.dart`'s receipt poll (SEND-04).

### Crash-safe history write order
**Source:** `lib/squid_router/swap_screen.dart:575-605`
**Apply to:** wherever Plan 4 submits and persists the send (SEND-07).

### Decimal-safe conversion
**Source:** `lib/squid_router/squid_util.dart:1-34`
**Apply to:** `send_service.dart` for every amount<->wei conversion (SEND-02, SEND-03).

### Route `extra` map shape
**Source:** `lib/navigation/router.dart:252-265`
**Apply to:** the new `/send` `GoRoute` (SEND-06).

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `lib/send/recipient_field.dart` | component | request-response | No existing field combines paste + platform-gated QR scan + debounced async warnings (self-send, contract-code). Build from `GWTextField`'s suffix slot plus the `isEvmAddress`/`getCode` calls quoted in RESEARCH.md's Code Examples — there is nothing to copy wholesale, only pieces to assemble. |
| EIP-1559 fee estimation call site | service (function within `send_service.dart`) | request-response | Nothing in this codebase calls `Web3Client.getGasInEIP1559()` today (RESEARCH.md confirms this is the one genuinely new piece); use the package source cited in RESEARCH.md directly, with the legacy `getGasPrice()` fallback on any throw. |
| Dashboard Send entry + coin picker | component | request-response | RESEARCH.md's own Open Question #1 — no existing per-coin dashboard action row or packaged coin-picker widget exists to copy verbatim; closest chrome is `GWSelectRow` used inline (bridge's destination-network picker) and the mobile bottom-nav Swap dock (`responsive_overlay.dart:341-380`). Planner should treat this as a fresh small widget, measured against the dashboard's current layout at execution time. |

## Metadata

**Analog search scope:** `lib/squid_router/`, `lib/tokens/`, `lib/navigation/`, `lib/utils/`, `lib/reown/`, `packages/genius_api/lib/web3/`, `packages/genius_api/lib/models/`, `test/tokens/` — all already enumerated exhaustively by 31-RESEARCH.md's own source list; this pass re-read the cited ranges directly rather than re-searching.
**Files scanned:** 9 read directly this pass (`web3.dart`, `swap_execution.dart`, `swap_screen.dart` x2 ranges, `squid_util.dart`, `wallet_utils.dart`, `transaction.dart`, `send_transaction_details.dart`, `token_info_screen.dart`, `router.dart`, `coin_page_stat_rail_test.dart`)
**Pattern extraction date:** 2026-09-23
