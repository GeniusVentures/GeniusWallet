# Phase 31: Send native coins and ERC-20 tokens - Research

**Researched:** 2026-09-23
**Domain:** EVM transaction construction/signing (web3dart 3.0.2), Hive schema evolution, Flutter form/drawer UI on an existing go_router shell
**Confidence:** HIGH (every load-bearing claim below is `[VERIFIED: file:line]` against this repo or the pinned package source; the few `[ASSUMED]`/`[CITED]` items are called out explicitly and listed in Assumptions Log)

## Summary

Nothing called Send exists at any layer today (confirmed by `test/tokens/coin_page_stat_rail_test.dart:142-149`, which asserts `find.widgetWithText(GWButton, 'Send')` finds nothing and cites `GeniusApi.transferTokens` as having zero callers - that SGNUS method is explicitly out of scope per D-01). This phase builds a genuinely new capability, but every mechanical piece it needs - address validation, decimal-safe base-unit conversion, transaction signing, a bounded settlement poller, a confirm drawer - already exists in the codebase in a form built for Swap or dApp signing and is directly reusable. The one piece that does not exist anywhere is EIP-1559 fee estimation and on-chain receipt polling; both are cheap to add because `web3dart` 3.0.2 (the version this repo's root `pubspec.lock` actually resolves) already exposes `getGasInEIP1559()`, `estimateGas()`, `getCode()` and `getTransactionReceipt()` as thin RPC wrappers - no new package is needed.

The one non-obvious finding that should shape Plan 2: `Web3.signAndSendTransaction` (`packages/genius_api/lib/web3/web3.dart:681-738`) always builds an EIP-1559-style (type-2) transaction, never a legacy one - `isEIP1559` in web3dart is true whenever `maxFeePerGas != null || maxPriorityFeePerGas != null`, and this method constructs both from the tx map unconditionally (defaulting to `0x0` when absent). That means every chain in `assets/json/networks/networks.json` - including BNB (56), which historically ran legacy-only gas pricing - must go through the same EIP-1559 fee path; there is no legacy fallback in the signer itself, only in the *fee estimation* the caller feeds it. BSC now returns `baseFeePerGas` (pinned at 0 by BEP-226) via `eth_feeHistory`/`eth_getBlockByNumber`, so `getGasInEIP1559()` should not throw there, but the estimate quality is unverified for that chain and the fee code must have a defensive fallback regardless of which RPC/chain misbehaves.

**Primary recommendation:** build Plan 2 as a small, pure, unit-testable send service in `genius_api` that (a) estimates EIP-1559 fees via `Web3Client.getGasInEIP1559()` with a legacy-`getGasPrice()`-doubled fallback on any throw or implausible (near-zero) result, (b) reuses `toBaseUnits`/`formatTokenAmount` from `lib/squid_router/squid_util.dart` for every decimal<->BigInt conversion, (c) builds the ERC-20 `transfer` calldata with the existing `Web3.abi`, and (d) hands the built tx map to the existing `GeniusApi.signAndSendTransaction` unchanged - then mirrors `lib/squid_router/swap_execution.dart`'s bounded-attempts polling pattern (`pollAttempts`/`pollInterval`/injected `wait`) against `Web3Client.getTransactionReceipt` instead of a Squid status endpoint.

## Architectural Responsibility Map

This app has no server tier; "API/Backend" below means the `genius_api` package, which is the sole owner of chain I/O and the signing key.

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Recipient/amount form state, validation messages | Client (new `SendCubit`, `lib/`) | - | Pure form state; must never hold a key (AGENTS.md wallet-safety rule) |
| EIP-1559 fee estimation | API/Backend (`genius_api` `Web3`) | - | Needs a `Web3Client` and BigInt math; this package already owns every other gas/fee read (`getBrigeOutGasCost`, `hasEnoughFundsForGas`) |
| Native/ERC-20 balance reads (exact, raw) | API/Backend (`genius_api` `Web3.rawBalanceOf`, `client.getBalance`) | - | `rawBalanceOf` already exists at `web3.dart:297-322`; native needs an equivalent raw (wei) read, not the existing `double`-returning `getBalance` |
| Transaction build + ABI encode + sign + broadcast | API/Backend (`genius_api` `Web3`/`GeniusApi`) | - | The private key never leaves this package (`GeniusApi.signAndSendTransaction` resolves it internally, `src/genius_api.dart:1244-1254`) |
| Receipt polling to a terminal status | API/Backend (poll loop needs the `Web3Client`) | Client (drives a "submitting/pending/resolved" UI state) | Mirrors `swap_execution.dart`'s existing `_poll` shape |
| History persistence (Hive `Transaction` box) | Database/Storage (`TransactionStorageService`) | Client (`TransactionsCubit` mirrors it in memory) | `TransactionStorageService.addTransaction` keys by `tx.hash` (`transaction_storage_service.dart:30-33`), so overwriting a row is a plain `box.put` with the same key |
| Explorer link / Network row / Network Fee row | Client (`transaction_utils.dart`, `transaction_displays.dart`) | - | Both read `tx.coinSymbol` today; D-05's new field changes what they read, not where the logic lives |
| Entry points / routing (`/send`) | Client (`go_router`, `token_info_screen.dart`, a new dashboard action) | - | Pure UI, mirrors the existing `/swap` route exactly |
| QR scanning | Client (`mobile_scanner` widget), platform-gated | - | No fallback library exists or is needed - hide the affordance where the platform has none |

## User Constraints (from 31-CONTEXT.md)

<user_constraints>

### Locked Decisions

- **D-01 Scope:** native coin and ERC-20 tokens on every chain where `canSignOn(network)` holds.
  SGNUS (`GeniusApi.transferTokens`) is out; it has no hash, a different store and an unknown unit.
- **D-02 Entry points:** a Send CTA on the coin page next to Swap/Receive, with the coin preselected,
  plus a Send action on the dashboard that opens with a coin picker.
- **D-03 Shape:** a `/send` screen inside the ShellRoute, built like `/swap` (an `extra` map carrying
  symbol + chainId). Not a drawer: a keyboard form in a bottom drawer is cramped on a phone.
- **D-04 Safety in v1:** EVM address validation, a warning when the recipient is the wallet's own
  address, and a warning when the recipient has code on-chain (`eth_getCode`). No address-poisoning
  check and no PIN re-entry in this phase.
- **D-05 History model first:** `Transaction.coinSymbol` is the only unit today, so a token send is
  mislabelled whichever symbol it is filed under. Plan 1 adds the asset-vs-chain split as a new Hive
  field, keeps old rows readable, and makes the explorer link and fee row use the chain. This also
  closes the receipt-unit item phase 30 deferred.

### Claude's Discretion

Not explicitly separated in 31-CONTEXT.md beyond the "Proposed plans" list; treated as the planner's
freedom area: exact placement of the dashboard Send action (no existing per-coin dashboard action row
exists to copy verbatim - see Open Questions), the exact fee-estimation fallback strategy for a chain
whose `getGasInEIP1559()` misbehaves, and whether the coin picker for the dashboard entry point is a
new small widget or an adaptation of swap's inline token-list rendering.

### Deferred Ideas (OUT OF SCOPE)

- SGNUS transfers (`GeniusApi.transferTokens`) - D-01.
- Address-poisoning detection - D-04.
- PIN re-entry before a send - D-04.
- EIP-55 checksum validation on the recipient address - inherited from the existing `isEvmAddress`
  helper's own documented scope, not re-opened by this phase.

</user_constraints>

<phase_requirements>
## Phase Requirements

No requirement IDs existed before this research; the following SEND-01..07 set is proposed, mapped to
D-01..D-05 and the four proposed plans. The planner should adopt or adjust these before writing PLAN.md
files.

| ID | Description | Research Support |
|----|-------------|------------------|
| SEND-01 | Transaction history distinguishes the asset sent from the chain it moved on; old rows still read; the explorer link and fee row key off the chain, not the asset symbol | `Runtime State Inventory` below; `packages/genius_api/lib/models/transaction.dart:98-178`, `transaction.g.dart:50-119` (next free `HiveField` index); `transaction_utils.dart`/`transaction_displays.dart` reader census below |
| SEND-02 | A user can send a chain's native coin, sees an EIP-1559 fee estimate before approving, and MAX subtracts the fee | `Code Examples` -> Fee estimation, MAX; `Common Pitfalls` #1, #3, #4 |
| SEND-03 | A user can send a held ERC-20 token on any `canSignOn` chain, sees a fee estimate before approving | `Code Examples` -> ERC-20 transfer calldata; `Web3.abi` at `web3.dart:48-56` |
| SEND-04 | A broadcast send is polled to a terminal on-chain status; the pending history row updates to its resolved state | `Code Examples` -> Bounded poller; `Common Pitfalls` #2 |
| SEND-05 | The send form validates an EVM address, offers paste and (where the platform supports it) QR scan, offers an amount field with MAX, and warns on a self-send or a contract-code recipient | `isEvmAddress` (`wallet_utils.dart:4-7`); `mobile_scanner` platform table below; `eth_getCode` (`client.dart:261-266`) |
| SEND-06 | Two entry points reach Send: the coin page CTA (asset preselected) and a dashboard action with a coin picker | `_CoinActionRow` (`token_info_screen.dart:719-820`); router `extra` pattern (`router.dart:252-265`); Open Questions -> dashboard placement |
| SEND-07 | The confirm-and-submit step shows the built transaction via `SendTransactionDetails`, records a pending history row immediately, shows the resolved outcome, and the coin-page test asserting no Send button is updated rather than left contradicting the new CTA | `send_transaction_details.dart:43-130`; `coin_page_stat_rail_test.dart:131-158`; `swap_execution.dart`'s crash-safe pending-then-resolved write order |

</phase_requirements>

## Standard Stack

No new package is required. Every dependency this phase needs is already declared and pinned.

### Core (already present, reused)

| Library | Version (as resolved by root `pubspec.lock`) | Purpose | Why standard here |
|---------|---------|---------|--------------|
| `web3dart` | 3.0.2 `[VERIFIED: pubspec.lock]` | RPC client, EIP-1559 fee estimation, ABI encode, tx signing, receipt/code reads | Already the app's only EVM library; `genius_api`'s own `pubspec.lock` pins 3.0.3, but the app-level resolution (3.0.2) is what actually builds, and 3.0.2 carries the same `getGasInEIP1559`/`getCode`/`estimateGas` surface (verified directly against the 3.0.2 cache) |
| `eip1559` | 0.6.2 (transitive, via `web3dart`) `[VERIFIED: web3dart-3.0.2/pubspec.yaml import]` | Implements `getGasInEIP1559` by calling `eth_feeHistory` + `eth_getBlockByNumber` on the SAME `rpcUrl` already passed to `Web3Client` | Not a separate network dependency or paid gas-station API - confirmed by reading `eip1559-0.6.2/lib/eip1559.dart:1-33`, which posts to the `url` argument only |
| `mobile_scanner` | 5.2.3 `[VERIFIED: pubspec.lock]` | QR recipient scan | Already a declared dependency per 31-CONTEXT.md; no scanner widget exists yet, but no new package is needed either |
| `hive_ce` | (already pinned) | `Transaction` Hive model storage | Existing `TransactionStorageService`/`TransactionsCubit` |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `web3dart`'s `getGasInEIP1559()` | Hand-rolled `eth_feeHistory` parsing | No benefit - `eip1559` already does exactly this against the same RPC, and reading its ~30-line source (quoted below) confirms it is trustworthy and network-neutral |
| `eip1559` package's percentile-based estimate | A third-party gas-price oracle (Blocknative, Etherscan gas API) | Adds a second network dependency and an API key for zero benefit - every chain here is reachable through the wallet's own configured `rpcUrl` |

**Installation:** none - nothing new to add to `pubspec.yaml`.

## Package Legitimacy Audit

**Not applicable.** This phase installs no new external packages; every dependency used (`web3dart`,
its transitive `eip1559`, `mobile_scanner`, `hive_ce`) is already present in `pubspec.lock` and was
verified directly against the pinned package source in the local pub cache, not merely resolved by
name. No `package-legitimacy check` run is needed and none is required by the planner.

## Architecture Patterns

### System Architecture Diagram

```
Coin page CTA ("Send", coin preselected)      Dashboard "Send" action (coin picker)
        |                                              |
        +---------------------+  go_router  +----------+
                               v
                    /send route (extra: {symbol, chainId})
                               |
                     SendCubit (form state only - NEVER a key)
                     - recipient (isEvmAddress + own-address warning
                       + eth_getCode contract warning, debounced)
                     - amount (typed decimal -> toBaseUnits, MAX chip)
                               |
                     confirm step (SendTransactionDetails, reused)
                               |
              genius_api: Send service (Plan 2, no UI, unit-tested)
              -------------------------------------------------
              1. estimate fee: Web3Client.getGasInEIP1559()
                 (fallback: legacy getGasPrice() on throw)
              2. gas limit: 21000 (native) / client.estimateGas (ERC-20)
              3. build tx map (native: to/value/data=0x;
                 ERC-20: to=contract, data=Web3.abi 'transfer'(to, amount))
              4. GeniusApi.signAndSendTransaction(tx, rpcUrl, address, chainId)
                 -> resolves wallet + private key INTERNALLY, never returns it
                               |
                     hash returned -> write PENDING row to Hive
                     (TransactionStorageService.addTransaction, keyed by hash)
                               |
                     bounded poll: Web3Client.getTransactionReceipt(hash)
                     (mirrors swap_execution.dart's _poll: N attempts,
                      fixed interval, injected `wait`, throws == "not yet")
                               |
                     write RESOLVED row (same hash, same Hive key = overwrite)
                     -> TransactionsCubit.addTransaction(resolved) ONCE
                        (never hand the cubit the pending instance - see
                        Common Pitfalls #2)
                               |
                     history list / drawer reads Transaction.<new asset field>
                     for title/amount/icon, and Transaction.coinSymbol (the
                     CHAIN ticker) for Network / Network Fee / explorer link
```

### Recommended Project Structure

No new top-level folder. New files slot into existing conventions:

```
packages/genius_api/lib/web3/
  send_service.dart          # Plan 2: pure functions, Web3Client + GeniusApi injected, no UI
packages/genius_api/test/
  send_service_test.dart     # Plan 2: NEW test dir for this package (none exists today)
lib/send/
  send_cubit.dart            # Plan 3: form state only
  send_screen.dart           # Plan 3/4: the /send route target
  recipient_field.dart       # Plan 3: paste + QR (platform-gated) + warnings
test/send/
  send_cubit_test.dart
  send_screen_test.dart
```

### Pattern 1: Bounded settlement poller (reuse, don't reinvent)

**What:** `swap_execution.dart` already implements exactly the poll loop Plan 2 needs, generalized
over an injected `readStatus`/`wait` pair with a fixed attempt count and interval, and treats any
thrown read as "not yet" rather than a terminal failure.

**When to use:** any place a broadcast hash needs to become a terminal status without blocking the UI
thread or hanging indefinitely.

**Example (existing code, to mirror, not literally reuse - it is typed to Squid's `SwapSettlement`):**
```dart
// Source: lib/squid_router/swap_execution.dart:307-334 (verified, quoted)
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
    if (attempt > 0) {
      await wait(interval);
    }
    try {
      settled = await readStatus(route, hash);
    } catch (_) {
      settled = const SwapSettlement(status: SwapStatus.notFound);
    }
    if (isTerminal(settled.status)) {
      return settled;
    }
  }

  // Unresolved is unresolved. `walletStatusFor` reads this as pending.
  return settled;
}
```
Plan 2's version replaces `readStatus`/`SwapSettlement` with
`Web3Client.getTransactionReceipt(hash)` and treats a non-null receipt with `status == 1` as
completed, `status == 0` as failed, and `null` (not yet indexed) the same way a thrown read is
treated above - one more "not yet". `pollAttempts: 20` / `pollInterval: Duration(seconds: 3)` (the
swap defaults, `swap_execution.dart:212-213`) is a reasonable starting point for a native/ERC-20
send too, since block times on the chains in scope (Ethereum, Polygon, BNB, Base + their testnets)
are all comfortably under that 60-second window except Ethereum mainnet under congestion, which is
an accepted "still pending, not lost" outcome per the existing swap convention.

### Pattern 2: Crash-safe pending-then-resolved write order (reuse, don't reinvent)

**What:** write the PENDING row to Hive storage immediately after broadcast (before polling), then
overwrite the same key with the resolved row, and only THEN hand the transaction to the in-memory
cubit - exactly once, with the final state.

```dart
// Source: lib/squid_router/swap_screen.dart:575-605 (verified, quoted)
// Written BEFORE the resolved status, keyed by the real hash: a crash
// between broadcast and resolution must leave an accurate pending row
// rather than no record of funds that already moved.
await widget.storage.addTransaction(
  walletAddress,
  rowWith(TransactionStatus.pending),
);
final resolved = rowWith(broadcast.status);
await widget.storage.addTransaction(walletAddress, resolved);
...
transactionsCubit.addTransaction(resolved);
```
This is the pattern that sidesteps Common Pitfall #2 below - it is not incidental, it is the reason
the existing swap flow never shows a duplicate row.

### Pattern 3: ERC-20 transfer calldata (extend the existing `approve()` template)

**What:** `Web3.approve` (`web3.dart:553-601`) already shows the exact shape for a single-argument
ERC-20 call signed and sent through `client.sendTransaction` directly. Plan 2 does NOT call
`client.sendTransaction` directly (that would need the private key in `genius_api`'s `Web3` class,
which is fine - it already lives there - but Plan 2 should prefer the generic, already-audited
`GeniusApi.signAndSendTransaction` path so gas/fee filling is centralized in one place). The encode
step is the reusable part:

```dart
// ABI entry verified verbatim at web3.dart:54:
// { "constant": false, "inputs": [{ "name": "_to", "type": "address" }, { "name": "_value", "type": "uint256" }], "name": "transfer", "outputs": [{ "name": "", "type": "bool" }], "type": "function" },
final contract = DeployedContract(Web3.abi, EthereumAddress.fromHex(tokenContract));
final data = contract.function('transfer').encodeCall([
  EthereumAddress.fromHex(recipient),
  rawAmount, // BigInt, from toBaseUnits(typedAmount, decimals)
]);
final tx = {
  'from': senderAddress,
  'to': tokenContract,      // the TOKEN contract, not the recipient
  'value': '0x0',           // no native value moves in a plain transfer
  'data': bytesToHex(data, include0x: true),
  'gas': '0x${gasLimit.toRadixString(16)}',
  'maxFeePerGas': '0x${maxFeePerGas.toRadixString(16)}',
  'maxPriorityFeePerGas': '0x${maxPriorityFee.toRadixString(16)}',
};
await geniusApi.signAndSendTransaction(
  tx: tx, rpcUrl: rpcUrl, address: senderAddress, sourceChainId: chainId,
);
```
For a native send, `to` is the recipient, `value` is the amount in wei, and `data` is omitted (or
`'0x'`).

### Pattern 4: Decimal-safe amount conversion (reuse, don't reinvent)

```dart
// Source: lib/squid_router/squid_util.dart (verified, quoted)
/// The typed amount as raw base units — the integer the router actually
/// spends. String and BigInt only: a double cannot hold 18 significant
/// digits, and this value is the amount of money that moves.
BigInt? toBaseUnits(String amount, int decimals) { ... }

String formatTokenAmount(BigInt raw, int decimals) { ... }
```
And for MAX on the native coin specifically, mirror `nativeCoinBaseUnits`
(`lib/squid_router/swap_screen.dart:50-78`), which already documents its own `ponytail:` ceiling for
`Coin.balance` being a `double`:
```dart
// Source: lib/squid_router/swap_screen.dart:60-64 (verified, quoted)
// ponytail: `Coin.balance` is a double, so a holding needing more than ~17
// significant digits is already rounded before it reaches this line. Accepted
// because it is the same figure the rest of the app displays; the upgrade path
// is a string or BigInt balance on `Coin`. `toStringAsFixed` is what keeps a
// dust balance out of exponent notation, which `toBaseUnits` rejects.
```
Send's native MAX is this same value MINUS `maxFeePerGas * gasLimit` (clamped to zero, never
negative) - there is no existing helper for the subtraction because nothing in this codebase spends
its own full native balance today; this is new, small BigInt arithmetic, not a hand-rolled parser.

### Anti-Patterns to Avoid

- **Building a legacy (`gasPrice`-only) transaction for a chain believed to be "legacy-only":** the
  signer this phase must use (`Web3.signAndSendTransaction`) cannot send one - it always sets both
  EIP-1559 fields (see Common Pitfall #1). Do not special-case BNB into a different code path; give
  it a working fee estimate instead.
- **Re-deriving the amount-to-wei conversion with `double * pow(10, decimals)`:** this is the exact
  defect `toBaseUnits`'s own doc comment calls out; every existing example in this codebase that
  still does this (`web3.dart:449-453`, the bridge's own amount conversion) is legacy code this
  phase must not copy.
- **Handing the pending transaction instance to `TransactionsCubit`:** see Common Pitfall #2.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| EIP-1559 fee estimate | A hand-written `eth_feeHistory` percentile calculator | `Web3Client.getGasInEIP1559()` | Already implemented, reads the same `rpcUrl`, returns `List<Fee>` with `maxPriorityFeePerGas`/`maxFeePerGas`/`estimatedGas` per requested percentile |
| Decimal string -> base units | Regex + manual padding, or `double` math | `toBaseUnits`/`formatTokenAmount` (`squid_util.dart`) | Already proven correct and precision-safe across the swap flow; a second implementation is a second place to get truncation/rounding wrong |
| ERC-20 transfer encoding | Manual selector + ABI word packing | `Web3.abi` + `ContractFunction.encodeCall` | `Web3.approve` already shows this exact shape for `approve`; `transfer` is one line different |
| Settlement polling | A new `while(true)`/`Timer.periodic` loop | Mirror `swap_execution.dart`'s bounded `_poll` | Already handles "read throws = not yet", bounded attempts, injectable `wait` for tests |
| Address format validation | A new regex | `isEvmAddress` (`wallet_utils.dart:4-7`) | Already used by `sdk_account_manager.dart`; deliberately no EIP-55 check, matching existing scope |
| Contract-vs-EOA check | Heuristic (address prefix, length) | `Web3Client.getCode(address)` (`eth_getCode`) | A free read call; empty bytes = EOA, non-empty = contract, no ambiguity |
| QR scanning | A second scanner package or a hand-rolled camera pipeline | `mobile_scanner` (already declared) | Adding a second QR library for one platform gap (Windows/Linux) is strictly worse than hiding a button |

**Key insight:** every hand-roll risk in this phase already has a working, tested twin in the swap or
dApp-signing code paths. The work is almost entirely assembly and one new schema field, not new
algorithms.

## Runtime State Inventory

Not a rename/refactor/migration phase in the strict sense, but D-05 changes the `Transaction` Hive
schema, so the same discipline applies to that one change:

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | Every existing `transactions_<address>` Hive box on a device already has rows written with `TransactionAdapter.write` writing exactly 18 fields (`writeByte(18)` at `transaction.g.dart:79`, fields 0-17). Adding a new `@HiveField(18)` is additive and nullable, and `hive_ce`'s generated `read()` loop already keys by field index (`fields[i]`), so an old 18-field row simply never populates field 18, and `Transaction(..., <newField>: fields[18] as String?)` must default it via `??`. **No data migration needed - this is a pure code-edit, additive-field change.** `[VERIFIED: packages/genius_api/lib/models/transaction.g.dart:50-119]` |
| Live service config | None - the `Transaction` Hive box is entirely local; nothing external stores this schema. |
| OS-registered state | None. |
| Secrets/env vars | None - no secret or env var references `coinSymbol` or a transaction field by name. |
| Build artifacts | The Hive adapter is generated (`transaction.g.dart`, `// GENERATED CODE - DO NOT MODIFY BY HAND`). After adding the field to `transaction.dart`, `build_runner` must regenerate `transaction.g.dart` (run from `packages/genius_api/`, the package that owns this model) - hand-editing the generated file is possible (as this research did, to inspect it) but the actual plan should run the generator, not hand-edit, to avoid a byte-order mistake in the writer. |

**Next free `HiveField` index for `Transaction`: 18** `[VERIFIED: packages/genius_api/lib/models/transaction.g.dart:79 writes writeByte(18) as the current field count, with fields 0-17 already assigned in transaction.dart:100-156]`.

**Every reader of `tx.coinSymbol` that D-05 must decide about** (grepped across `lib/`, not just the
two files context named):

| Site | Current read | D-05 disposition |
|------|---------------|-------------------|
| `transaction_utils.dart:493` | `title = tx.coinSymbol` (non-swap headline) | Should read the new asset field, falling back to `coinSymbol` for old rows |
| `transaction_utils.dart:684,687` | outgoing/incoming amount + fiat line unit | Should read the new asset field |
| `transaction_utils.dart:661,668` | a `process`-type row's fee amount/unit | Stays `coinSymbol` - a job's fee IS in the chain coin |
| `transaction_utils.dart:728` | `iconSymbols` for the badge icon | Should read the new asset field |
| `transaction_displays.dart:987` | `add(netRows, 'Network', tx.coinSymbol)` | **Stays `coinSymbol`** - this is literally the Network row; D-05 says the chain wins here |
| `transaction_displays.dart:994` | `Network Fee` row, `'${formatTxAmount(tx.fees)} ${tx.coinSymbol}'` | **Stays `coinSymbol`** - gas is always paid in the chain's native coin |
| `transaction_displays.dart:1008` | `getExplorerUrl(tx.coinSymbol, tx.hash)` | **Stays `coinSymbol`**, but `getExplorerUrl` itself should be re-keyed off `chainId` rather than a ticker string lookup - `transaction_utils.dart:11-38`'s `explorerMap` is keyed by lowercased symbol and has no entry for an unverified token's contract address (phase 30's own deferred finding) |
| `dev_mock_transactions.dart`, `dev_tools_bubble.dart`, `test/dev_overrides.dart` | construct mock `Transaction`s with `coinSymbol: 'ETH'` etc. | Dev-only fixtures; add the new field where the mock is meant to exercise a token send |

This table resolves the deferred item in `.planning/phases/30-dapp-calldata-decoding-end-blind-signing/deferred-items.md`
("A token receipt has one unit, and history reads three things off it") - the fix is exactly the split
D-05 already locked: a new asset-unit field for title/amount/icon, `coinSymbol` kept as the chain
ticker for Network/Network Fee/explorer.

## Common Pitfalls

### Pitfall 1: The signer has no legacy-gas code path
**What goes wrong:** A plan assumes it can send a plain `gasPrice`-only transaction on a chain
believed to be "legacy-only" (e.g. BNB), the way `createBridgeOutTransaction` does.
**Why it happens:** `Web3.signAndSendTransaction` always constructs `maxPriorityFeePerGas` and
`maxFeePerGas` from the tx map (defaulting to `0x0` if absent), and web3dart's
`Transaction.isEIP1559` getter (`web3dart-3.0.2/lib/src/core/transaction.dart:102`) is
`maxFeePerGas != null || maxPriorityFeePerGas != null` - both are ALWAYS non-null coming out of this
method, so every send through it is always type-2. `[VERIFIED: packages/genius_api/lib/web3/web3.dart:700-708, web3dart-3.0.2/lib/src/core/transaction.dart:102]`
**How to avoid:** always compute real, non-zero `maxFeePerGas`/`maxPriorityFeePerGas` for every chain
in scope, with a fallback (below) rather than a chain-specific legacy branch.
**Warning signs:** a transaction that reverts or is rejected as underpriced on a specific chain in
testing; a `0x0` fee field reaching the RPC.

### Pitfall 2: `TransactionsCubit` cannot deduplicate a hash update
**What goes wrong:** calling `transactionsCubit.addTransaction(pendingTx)` and later
`transactionsCubit.addTransaction(resolvedTx)` (same hash, different `TransactionStatus`) renders TWO
rows for one send, because `_transactions` is a `Set<Transaction>` and `Transaction`
(`packages/genius_api/lib/models/transaction.dart:98`) has no `==`/`hashCode` override, so it falls
back to identity - two different instances with the same hash are two different Set members.
`[VERIFIED: lib/dashboard/transactions/cubit/transactions_cubit.dart:5-29 — no equality override anywhere in transaction.dart]`
**Why it happens:** the existing swap flow never triggers this because it never hands the cubit the
pending instance - see Pattern 2 above.
**How to avoid:** follow Pattern 2 exactly - write pending to `TransactionStorageService` only, poll,
then call `transactionsCubit.addTransaction` exactly once with the resolved row.
**Warning signs:** a widget test that submits a send and asserts on `TransactionsCubit.state.length`
would immediately catch a violation if written broadly enough to submit-then-poll-then-assert.

### Pitfall 3: `getGasInEIP1559()` can throw on a non-compliant RPC
**What goes wrong:** `eip1559.getGasInEIP1559` does `latestBlock.baseFeePerGas!` - a null-check
`!` - on the response of `eth_getBlockByNumber`. `[VERIFIED: eip1559-0.6.2/lib/eip1559.dart:106-122]`
Any RPC that omits `baseFeePerGas` (a very old client, or a misconfigured/rate-limited endpoint)
throws a `TypeError`, not a caught exception.
**Why it happens:** the package assumes universal EIP-1559 support and does no defensive null
handling.
**How to avoid:** wrap the call in try/catch and fall back to `client.getGasPrice()` (legacy), used
as both `maxFeePerGas` and `maxPriorityFeePerGas` - the RPC still accepts a type-2 transaction with
equal max/priority fees, it is simply not fee-market-optimized. BSC mainnet (chainId 56) is reported
to return `baseFeePerGas` (pinned at 0 by BEP-226) as of the 2026 hardfork `[CITED: web search of BNB Chain forum/docs - not verified against a live BSC RPC response this session]`, so it should not need the
fallback, but the fallback must exist regardless, defensively, for any RPC in the free-tier rotation.
**Warning signs:** an uncaught exception surfacing as a generic error toast instead of a specific
"could not estimate fee" message.

### Pitfall 4: `Coin.balance` is a lossy `double`
**What goes wrong:** computing MAX by reading `Coin.balance` and doing float arithmetic loses
precision on an 18-decimal balance.
**Why it happens:** `Coin.balance` is declared `double?` (`packages/genius_api/lib/models/coin.dart:12`),
not a `String`/`BigInt`.
**How to avoid:** always go through `toStringAsFixed` then `toBaseUnits`, exactly as
`nativeCoinBaseUnits` already does, or read the raw ERC-20 balance directly via
`Web3.rawBalanceOf` (which returns `BigInt` and never touches `double` at all - the safer of the two
for tokens).
**Warning signs:** a MAX send that reverts as "insufficient balance" by a dust amount.

### Pitfall 5: Rapid double-submit can reuse a pending nonce
**What goes wrong:** two Send submissions fired before the first transaction is indexed can both
resolve the same `eth_getTransactionCount(address, "pending")` nonce, so the second either replaces
the first (if its fee is higher) or is rejected as already-known/nonce-too-low.
**Why it happens:** web3dart auto-fills a `Transaction`'s `nonce` from the pending nonce whenever the
caller does not set one (`web3dart-3.0.2/lib/src/core/transaction_signer.dart:55-57`), and
`Web3.signAndSendTransaction`'s tx map never sets `nonce`. `[VERIFIED: web3dart-3.0.2/lib/src/core/transaction_signer.dart:55-57, packages/genius_api/lib/web3/web3.dart:690-708 — no nonce key read from tx]`
**How to avoid:** mirror `swap_screen.dart`'s existing `isSubmitting` guard (`setState(() =>
isSubmitting = false)` in a `finally`, gating the CTA) so a second tap cannot fire before the first
call returns.
**Warning signs:** a "nonce too low" or duplicate-transaction error visible only under fast repeated
taps, easy to miss in a single manual walk.

### Pitfall 6: MAX on a token still needs native gas
**What goes wrong:** MAX on an ERC-20 amount is arithmetically simple (the fee is paid in the native
coin, not the token, so no subtraction is needed on the token side) - but if the wallet's native
balance cannot cover the estimated gas at all, the send will fail regardless of the token amount.
**Why it happens:** gas is always native currency; a wallet can hold plenty of a token and zero
native coin on that chain.
**How to avoid:** `Web3.hasEnoughFundsForGas` already exists (`web3.dart:631-654`) and should gate
the confirm step for BOTH native and token sends, not just be a bridge-only helper.
**Warning signs:** a token send that gets to the confirm screen and then fails silently or with a
generic RPC error.

### Pitfall 7: `mobile_scanner` has no Windows or Linux build
**What goes wrong:** rendering a QR-scan button unconditionally crashes or no-ops on desktop.
**Why it happens:** `mobile_scanner` 5.2.3's own platform-support table lists only Android, iOS,
macOS and Web - Linux and Windows are both marked unsupported. `[VERIFIED: mobile_scanner-5.2.3/README.md "Platform Support" table]`
**How to avoid:** gate the scan affordance the same way `router.dart:267` already gates the `/web`
route (`if (!Platform.isLinux)`) - extend the same idea to also exclude Windows for the scan button
specifically (`Platform.isWindows || Platform.isLinux`), leaving paste as the only recipient-entry
method there.
**Warning signs:** a build/runtime failure or a permanently-disabled button on the platform this repo
is primarily built and verified on (Windows, per CLAUDE.md).

## Code Examples

### Recipient warnings (D-04) - straightforward, no existing helper, but a consistent idiom

```dart
// Own-address comparison follows the exact idiom already used at
// lib/bloc/app_bloc.dart:565 (verified):
//   if (w.address.toLowerCase() == event.address.toLowerCase())
final isSelfSend = recipient.toLowerCase() == selectedWallet.address.toLowerCase();

// Contract-code warning: a free read, debounce on a valid address before calling.
final code = await web3Client.getCode(EthereumAddress.fromHex(recipient));
final hasCode = code.isNotEmpty; // eth_getCode returns 0x for an EOA
```

### Bounded receipt poll sketch (Plan 2, mirrors Pattern 1 above)

```dart
Future<TransactionReceipt?> _pollReceipt(
  Web3Client client,
  String hash, {
  int attempts = 20,
  Duration interval = const Duration(seconds: 3),
  Future<void> Function(Duration) wait = Future.delayed,
}) async {
  for (var i = 0; i < attempts; i++) {
    if (i > 0) await wait(interval);
    try {
      final receipt = await client.getTransactionReceipt(hash);
      if (receipt != null) return receipt; // status field decides completed/failed
    } catch (_) {
      // not yet indexed - keep polling, same convention as swap_execution.dart
    }
  }
  return null; // exhausted: row stays pending, exactly like an unresolved swap
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Legacy `gasPrice` transactions (bridge path, `createBridgeOutTransaction`) | EIP-1559 type-2 (`maxFeePerGas`/`maxPriorityFeePerGas`) via `Web3.signAndSendTransaction` | Already the case for every non-bridge signer in this codebase (swap, dApp signing) | Send must follow the EIP-1559 path too - it is not a new choice, it is the only path the shared signer offers |

**Deprecated/outdated:** none specific to this phase; the codebase has no legacy EIP-1559 tooling to
retire.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | BNB mainnet (chainId 56) currently returns a usable `baseFeePerGas` via `eth_getBlockByNumber`/`eth_feeHistory` on the app's configured RPC (`https://bsc.drpc.org`), so `getGasInEIP1559()` will not throw there. Based on a web search of BNB Chain's BEP-226 documentation/forum posts, not a live call against that RPC this session. | Common Pitfall #3, Summary | If wrong, BNB sends fall through to the legacy-`getGasPrice()` fallback automatically (the fallback is required regardless per this research), so the user-facing risk is a slightly less optimal fee, not a broken send - low impact even if wrong |
| A2 | No existing per-coin "coin picker" widget is reusable verbatim for the dashboard Send entry point (D-02's second entry); the closest precedent is `GWSelectRow` used as an inline list (bridge's destination-network picker) rather than a packaged component. | Open Questions, Don't Hand-Roll | If a reusable picker does exist somewhere ungrepped, the planner builds a small duplicate instead of reusing it - low cost, easily corrected in code review |
| A3 | `pollAttempts: 20` / `pollInterval: 3s` (borrowed from the swap flow's defaults) is an adequate bound for a native/ERC-20 send on the chains in D-01's scope. | Pattern 1 | If block times run longer under congestion (mainnet Ethereum especially), rows are left pending rather than lost - the existing swap flow accepts the same risk, so this is a consistent, not a new, risk |

**If this table is empty:** N/A - see rows above.

## Open Questions

1. **Exact placement of the dashboard Send action (D-02's second entry point)**
   - What we know: no existing per-coin dashboard action row exists to copy - the closest chrome is
     the mobile bottom-nav Swap dock (`responsive_overlay.dart:341-380`) and the coin page's
     `_CoinActionRow` (`token_info_screen.dart:719-820`), neither of which carries a coin picker.
   - What's unclear: whether "a Send action on the dashboard" means a new button near
     `wallet_overview.dart`, an addition to the existing desktop "More" sheet, or something else -
     31-CONTEXT.md does not specify the widget, only the behavior (opens with a coin picker).
   - Recommendation: Plan 4 should measure the dashboard's current layout at execution time (per this
     repo's own "plans rot, designs don't" convention) and pick the lowest-risk insertion point,
     flagging it for a walk rather than guessing a pixel-perfect spec here.

2. **Fee-estimation fallback threshold**
   - What we know: `getGasInEIP1559()` can throw outright (Pitfall 3); it can also return an
     implausibly low priority fee on a chain with few type-2 transactions in its recent history
     (the percentile calculation over `reward` values could legitimately return near-zero if nobody
     is bidding a priority fee).
   - What's unclear: what "implausible" should mean as a numeric threshold to trigger the legacy
     fallback even when no exception was thrown.
   - Recommendation: Plan 2 should treat a caught exception as the only automatic fallback trigger
     (simplest, matches Pitfall 3's actual failure mode) and treat a legitimately-low-but-present
     estimate as valid - inventing a "too low to trust" heuristic risks second-guessing a real quote
     for no evidenced benefit.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `web3dart` RPC connectivity to each chain's `rpcUrl` | Fee estimation, balance reads, signing, polling | Assumed reachable (same RPCs the app already uses for Swap/dApp signing) | n/a | none needed - this is the app's existing chain-access path |
| `mobile_scanner` camera permission | QR scan (Plan 3) | Platform-dependent (Android/iOS/macOS/Web only) | 5.2.3 | Hide the scan button on Windows/Linux; paste remains available everywhere |
| A funded Base Sepolia (or Polygon Amoy) testnet wallet | The one manual walk in Validation Architecture below | Not verified this session - must be arranged before the phase's human walk | n/a | none - this is a hard prerequisite for the live walk, not code |

**Missing dependencies with no fallback:** a funded testnet wallet for the live walk - must be
arranged by the human verifier before that step, not solved in code.

**Missing dependencies with fallback:** QR scanning on Windows/Linux - falls back to paste-only.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (root app) + Dart `test` ^1.24.1 (already declared in `packages/genius_api/pubspec.yaml`, but that package has **no `test/` directory yet** - Wave 0 gap) |
| Config file | none beyond `pubspec.yaml` - this repo has no `dart_test.yaml` |
| Quick run command | `flutter test test/send/ test/tokens/coin_page_stat_rail_test.dart` (app-level); `dart test` run from inside `packages/genius_api/` (package-level, once `test/` exists) |
| Full suite command | `flutter test` (app-level, currently ~1341+ tests per STATE.md's phase-30 baseline) |

### Phase Requirements -> Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SEND-01 | Old 18-field `Transaction` rows still deserialize; new field is read correctly by title/amount/icon derivations, `coinSymbol` still used for Network/Network Fee/explorer | unit (genius_api) + unit (app) | `dart test packages/genius_api/test/transaction_model_test.dart`; `flutter test test/dashboard/transaction_utils_test.dart` | ❌ Wave 0 (genius_api test dir does not exist) |
| SEND-02 | Native send: fee estimate populates before confirm; MAX = balance − fee | unit (genius_api) | `dart test packages/genius_api/test/send_service_test.dart` | ❌ Wave 0 |
| SEND-03 | ERC-20 send: `transfer` calldata matches `tryDecodeErc20Transfer` (self-check, mirrors the dApp decoder's own test pattern) | unit (genius_api) | same file as above | ❌ Wave 0 |
| SEND-04 | Poll resolves pending -> completed/failed; exhausted poll leaves row pending, does not throw | unit (genius_api) | same file as above | ❌ Wave 0 |
| SEND-05 | `isEvmAddress` rejects malformed input; self-send and contract-code warnings fire correctly; QR button absent on a gated platform | widget | `flutter test test/send/send_screen_test.dart` | ❌ Wave 0 |
| SEND-06 | `/send` route reads `extra['symbol']`/`extra['chainId']`; dashboard entry opens a coin picker | widget | `flutter test test/send/send_screen_test.dart` | ❌ Wave 0 |
| SEND-07 | `coin_page_stat_rail_test.dart`'s "no Send button" assertion is updated to assert presence with correct preselection; `SendTransactionDetails` renders the built transaction's real values | widget | `flutter test test/tokens/coin_page_stat_rail_test.dart` | ✅ exists, needs editing, not creating |

### Sampling Rate

- **Per task commit:** the relevant quick-run command above for the file(s) touched.
- **Per wave merge:** `flutter test` (app) + `dart test` (genius_api, once it exists).
- **Phase gate:** full suite green before `/gsd-verify-work`, plus the one manual walk below.

### Wave 0 Gaps

- [ ] `packages/genius_api/test/` — this package has no test directory at all today; Plan 2 creates
      it, since "unit-tested with no UI" (31-CONTEXT.md) is the plan's own stated bar.
- [ ] `packages/genius_api/test/send_service_test.dart` — covers SEND-02, SEND-03, SEND-04.
- [ ] `test/send/` (new app-level directory) — covers SEND-05, SEND-06.
- [ ] No shared fixture gap identified beyond the above - `packages/genius_api` already declares
      `test: ^1.24.1` as a dev dependency, so no framework install step is needed, only the directory
      and its first file.

**Manual-only item (needs a funded testnet wallet):** one live walk sending a small amount of a
testnet ERC-20 (e.g. on Base Sepolia, chainId 84531, `rpcUrl` already in `networks.json`) and the
chain's native coin, confirming: the fee estimate shown matches what is actually charged, the
recipient-is-self and recipient-has-code warnings fire correctly against two prepared addresses, the
history row moves from pending to completed without a duplicate, and the explorer link opens the
correct testnet explorer. Record the two transaction hashes and the wallet address used.

## Security Domain

`security_enforcement: true` in `.planning/config.json` — included.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | No | Unchanged - this phase adds no new authentication surface (D-04 explicitly defers PIN re-entry) |
| V3 Session Management | No | Not applicable to a local signing flow |
| V4 Access Control | Yes | The send form must never expose or accept a private key; `SendCubit` holds form state only (AGENTS.md wallet-safety rule, already enforced pattern-wide) |
| V5 Input Validation | Yes | `isEvmAddress` at the recipient field; `toBaseUnits`'s regex-gated parse at the amount field (both reused, not new) |
| V6 Cryptography | Yes | Signing goes through the existing `GeniusApi.signAndSendTransaction` / `EthPrivateKey.fromHex` path exclusively - no new crypto code, `Random.secure()` is not invoked anywhere in this phase since no new key material is generated |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|-----------------------|
| Recipient address typo/scam substitution | Spoofing | `isEvmAddress` format check + self-send warning + contract-code warning (D-04); address-poisoning detection explicitly deferred, not this phase's job |
| Nonce reuse on rapid double-submit | Tampering (of transaction ordering) | `isSubmitting`-style CTA guard, mirroring `swap_screen.dart` (Common Pitfall #5) |
| A key leaking into UI state / logs | Information Disclosure | `SendCubit` never holds a key; `GeniusApi.signAndSendTransaction` resolves and uses the key entirely inside `genius_api`, returning only a hash or an error string (already the case, verified at `src/genius_api.dart:1238-1257`) |
| Underpriced/zero-fee transaction silently built | Denial of Service (of the user's own send) | The EIP-1559 fee path must never leave `maxFeePerGas`/`maxPriorityFeePerGas` at the `0x0` default `Web3.signAndSendTransaction` falls back to when a field is missing (Common Pitfall #1) |

## Sources

### Primary (HIGH confidence - read directly this session)
- `packages/genius_api/lib/web3/web3.dart` (this repo) - `rawBalanceOf`, `approve`, `hasEnoughFundsForGas`, `signAndSendTransaction`, `Web3.abi`, `createBridgeOutTransaction`
- `packages/genius_api/lib/src/genius_api.dart:1210-1257` (this repo) - `GeniusApi.approve`/`signAndSendTransaction` wrapper, key resolution
- `packages/genius_api/lib/models/transaction.dart` + `transaction.g.dart` (this repo) - Hive schema, next free field index
- `lib/squid_router/swap_execution.dart`, `swap_screen.dart`, `squid_util.dart`, `held_tokens.dart` (this repo) - poll pattern, crash-safe write order, decimal conversion, MAX
- `lib/reown/calldata_decoder.dart`, `send_transaction_details.dart`, `utilities.dart` (this repo) - self-check decode, confirm UI, `formatEth`
- `lib/dashboard/home/widgets/transaction_utils.dart`, `transaction_displays.dart` (this repo) - every `coinSymbol` reader
- `lib/navigation/router.dart`, `lib/tokens/token_info_screen.dart`, `test/tokens/coin_page_stat_rail_test.dart`, `lib/utils/wallet_utils.dart` (this repo) - routing, entry point, test to update, address validation
- `assets/json/networks/networks.json` (this repo) - the 10-chain catalogue, confirming `canSignOn` excludes both SGNUS entries (no `rpcUrl`)
- `web3dart-3.0.2` and `eip1559-0.6.2` source, read directly from the local pub cache (`getGasInEIP1559`, `getCode`, `estimateGas`, `getTransactionReceipt`, `Transaction.isEIP1559`, nonce auto-fill in `transaction_signer.dart`)
- `mobile_scanner-5.2.3/README.md` - Platform Support table

### Secondary (MEDIUM confidence)
- BNB Chain BEP-226 / `eth_feeHistory` behavior on BSC - WebSearch results citing BNB Chain forum/docs and third-party RPC documentation (Dwellir, GetBlock), not a live RPC call against BSC this session

### Tertiary (LOW confidence)
- None used for a load-bearing claim.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new packages, every method cited was read from the pinned source
- Architecture: HIGH - every reuse pattern is quoted verbatim from working code in this repo
- Pitfalls: HIGH for #1/#2/#4/#5/#7 (all directly verified against source); MEDIUM for #3/#6 (the fallback need is verified, the exact BSC behavior is cited, not verified live)

**Research date:** 2026-09-23
**Valid until:** 30 days (stable domain - `web3dart` 3.0.2 and the repo's own existing patterns are not fast-moving; re-verify if `pubspec.lock`'s `web3dart` version changes before this phase executes)
