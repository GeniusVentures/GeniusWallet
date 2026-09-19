# Phase 30: dApp calldata decoding (end blind signing) - Research

**Researched:** 2026-09-19
**Domain:** EVM ABI decoding (web3dart), WalletConnect/Reown session-request handling, signing-path UI honesty
**Confidence:** MEDIUM-HIGH — the ERC-20 decode path (DAP-01) and the broken-methods fix (part of DAP-03) are HIGH confidence, verified directly against the resolved package sources in the pub cache. The router-swap path (DAP-02) is MEDIUM confidence and its conclusion is a documented non-decode: Squid's on-chain entrypoint is a generic multicall, not a simple `swap(tokenIn, tokenOut, amount)` call, so "X → Y" cannot be produced offline. See §2 below — this is not a research gap, it is the finding.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** No network call on the signing path. Address → (symbol, decimals) resolves offline only, from `WalletDetailsCubit.state.coins`, which `handleDappRequests` already holds.
- **D-02:** An unresolved token never assumes 18 decimals. It renders the raw base-unit integer, explicitly marked as unverified, next to the contract address.
- **D-03:** `SendTransactionDetails` takes the unit symbol as a parameter rather than hard-coding `ETH` on its four rows. — **Reversibility: costly** (const-constructed widget, seven strings pinned by the Phase 21 contract test).
- **D-04:** An `approve` at or near max-uint256 carries its own explicit unlimited-spending warning, via the existing `GWWarningNote`. Not deferred.
- **D-05:** The unknown-call treatment replaces the raw `Text(event.params.toString())` debug dump in the non-send branch today, retiring the fixed dark `deepBlueCardColor`/`Colors.white70` surface.
- **D-06:** An explicit chain-keyed router allow-list, shipping with only the router the companion dApp actually uses. A known router carrying an unrecognised selector falls through to the unknown-call treatment — never a partial guess.
- **D-07:** Fix the `params[0]` cast that runs before the method check, so `personal_sign` and `eth_signTypedData` stop throwing and the dApp always receives a JSON-RPC response. Both methods route to the same cannot-decode presentation; a real EIP-712 renderer is deferred.
- **D-08:** The decoded symbol replaces the hard-coded `coinSymbol = "ETH"` where it is written into the Hive transaction.
- **D-09:** Decoding reads a copy. The `tx` map handed to `signAndSendTransaction` is passed by reference into the signer, so it is never written to. — **Reversibility: one-way** (byte-identity contract).
- **D-10:** Phase 21's contract test is amended deliberately, not worked around. The allow-set extends to decoded amounts; the no-fiat-`$` assertion and all six approve/reject/dismiss outcomes stay exactly as they are.

### Claude's Discretion

The user asked for judgement over exhaustiveness: *"just do what you think matters, edge cases for now is not a big priority"*. Read as: minimum viable decoding of the calls that actually occur, not exhaustive ABI coverage. No EIP-712 renderer, no multi-router matrix, no speculative selector catalogue.

### Deferred Ideas (OUT OF SCOPE)

- A real `personal_sign` / EIP-712 renderer.
- RPC token metadata with a cache.
- Additional routers beyond the one Squid shipped with.
- Deduplicating `parseHexToBigInt` (exists identically in `lib/reown/utilities.dart` and `packages/genius_api/lib/web3/utilities.dart`).
- The silent zero fallback in `parseHexToBigInt` (malformed input renders `0 ETH` — pinned by an existing test).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DAP-01 | Reown approval flow decodes ERC-20 `transfer`/`approve` calldata and shows the decoded action in the drawer | §1 gives a verified, concrete `web3dart` 3.0.2 decode implementation (selectors, offset handling, exact types) |
| DAP-02 | Known-router swap calls decode to "swapping X → Y" in the approval drawer | §2 gives the Squid router address and explains, with evidence, why the swap entrypoint cannot honestly decode to "X → Y" offline — the router allow-list should ship, but expect it to route to the unknown-call presentation per D-06, not a swap summary |
| DAP-03 | Undecodable calldata is labeled an unknown-contract call with a visible warning, never presented as a plain send | §5 (JSON-RPC response contract) + §6 (threat model) + existing D-05 unknown-call presentation already scoped in `30-PATTERNS.md` |
</phase_requirements>

## Summary

`web3dart` 3.0.2 (already resolved, `pubspec.lock`) ships every primitive DAP-01 needs: `ContractAbi.fromJson`, `ContractFunction.selector`, and `TupleType.decode(ByteBuffer, int offset)`. The library has no dedicated "decode inputs" convenience method — `ContractFunction.decodeReturnValues` is output-only — but `TupleType.decode` is the same generic machinery either way; building `TupleType([AddressType(), UintType()])` by hand and calling `.decode(hexToBytes(data).buffer, 4)` (the `offset` parameter skips the 4-byte selector directly, no `sublist` copy needed) is the correct, minimal, fully-supported path. This was verified by reading the actual 3.0.2 source in the pub cache, not assumed from a changelog or a different version.

DAP-02 is where research changes the shape of the plan: Squid's on-chain router (`0xce16F69375520ab01377ce7B88f5BA8C48F8D666`, reported identical on every EVM chain including Base 8453 and Ethereum 1) is a proxy in front of a generic multicall executor (`SquidMulticall.run(Call[] calls)`, `Call = {callType, target, value, callData, payload}`). A user-facing "swap" transaction's calldata is this generic multicall blob, not a fixed `swap(tokenIn, tokenOut, amountIn)` signature — the actual DEX call lives inside an arbitrary nested `callData` targeting an arbitrary DEX contract chosen by the route, which is exactly the off-chain route context D-01 forbids fetching on the signing path. **Recommendation: ship the router allow-list (D-06 infrastructure) keyed by chain → Squid router address, but do not attempt to decode the nested calls.** Every real Squid transaction will — correctly and by design — fall through to the unknown-call treatment, with the one difference that it's a *recognized* router (worth surfacing as "a known router: Squid" in the unknown-call copy, rather than a bare "unknown contract"). This is the honest outcome the task brief asked me to state plainly if true, and it is true.

D-07's fix is a one-line root cause: `(event.params as List<dynamic>)[0] as Map<String, dynamic>` (`handle_dapp_requests.dart:39-40`) runs unconditionally before the method check, but `personal_sign`/`eth_signTypedData` carry `params[0]` as a `String`, not a `Map` (confirmed: `SessionRequestEvent.params` is typed `dynamic`, no shape guarantee). The cast throws, the catch-all at `:242` swallows it, and the dApp gets no JSON-RPC response at all — it hangs. The fix is to route on `method` before doing any params-shape-specific cast. Separately, the *existing* rejection path already has a live, low-severity bug worth fixing while this exact code is being touched: `Errors.USER_REJECTED.toInt()` (`:211`, `:234`) does not do what it looks like — `Errors.USER_REJECTED` is a `String` constant (`'USER_REJECTED'`) from `reown_core`, and `.toInt()` resolves to `reown_sign`'s `EtheraAmountExtension.toInt()` (`int.tryParse(this)`), which returns `null` for a non-numeric string. The JSON-RPC error response is therefore currently sent with `code: null` (silently valid Dart, since `JsonRpcError.code` is `int?` and the serializer's `includeIfNull: false` just omits the field) — technically non-conformant JSON-RPC. The correct call is `Errors.getSdkError(Errors.USER_REJECTED).code`.

**Primary recommendation:** implement DAP-01 as a small, pure, free-function decoder extending the existing `Web3.abi` ERC-20 fragment (`packages/genius_api/lib/web3/web3.dart:42`) with `transfer`/`approve`; implement DAP-02's allow-list as compile-time-constant infrastructure that in practice always defers to DAP-03's unknown-call/known-router presentation for Squid; fix D-07's root-cause cast by branching on `method` first.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| ABI calldata decode (selector match + tuple decode) | Client (Flutter app, pure Dart) | — | Runs entirely offline inside `lib/reown/`; no server tier exists in this app for this concern |
| Router allow-list (chain → address) | Client (compile-time constant) | — | D-01 forbids any runtime/network source; must be a hardcoded `const Map`, never fetched |
| Token symbol/decimals resolution | Client (`WalletDetailsCubit` in-memory state) | — | D-01 explicitly forbids an RPC round-trip on the signing path; the existing Cubit state is the only allowed source |
| Signing-path UI (drawer content) | Client (Flutter widget) | — | `ApproveTransactionDrawer`'s `content` slot, unchanged mechanically per Phase 21 |
| Transaction signing/broadcast | Client (`geniusApi.signAndSendTransaction` → `web3dart` `Web3Client`) | — | Untouched by this phase (D-09); decoding is display-only |
| Persisted transaction record (Hive) | Client (`TransactionStorageService`) | — | D-08 only changes which *symbol string* is written, not the storage mechanism |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `web3dart` | 3.0.2 (resolved, `pubspec.lock`) [VERIFIED: pubspec.lock] | ABI encode/decode, `EthereumAddress`, hex/keccak utilities | Already the project's EVM library; ships the full ABI codec used by DAP-01/02 |
| `reown_walletkit` | 1.4.0 (resolved, `pubspec.lock`) [VERIFIED: pubspec.lock] | WalletConnect v2 session-request transport, `Errors`/`JsonRpcError` model | Already the project's dApp-connectivity library; DAP-03's JSON-RPC response contract lives here |
| `wallet` | 0.0.18 (resolved transitively, `pubspec.lock`) [VERIFIED: pubspec.lock] | `EthereumAddress` type (decode results reference this type) | `web3dart` depends on it internally but does not re-export it — any file naming `EthereumAddress` explicitly must import it directly, exactly as `packages/genius_api/lib/web3/web3.dart:8` already does (`import 'package:wallet/wallet.dart' hide PrivateKey;`) |

**No new dependency is required.** Both libraries the decode path needs are already direct dependencies; `wallet` is already transitively resolved into the same pub workspace and importable exactly the way `genius_api`'s own `web3.dart` already imports it.

### Supporting
None — this phase adds no new packages.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Hand-rolled selector/offset decoding | A dedicated "EVM calldata decoder" package (e.g. `evm_abi` style packages) | Rejected: `web3dart` already ships the exact primitives needed (`TupleType.decode` with an explicit byte offset); adding a second ABI library for two function signatures is unjustified surface area and a new supply-chain dependency for a two-function need |
| Recognizing Squid's full multicall structure (`Call[]` decode + per-DEX sub-selector catalogue) | A speculative selector catalogue covering common DEX routers reachable from Squid's routes | Rejected by Claude's Discretion ("no speculative selector catalogue") and by D-06 ("never a partial guess"); also technically unbounded — the sub-call target varies per quoted route and is not knowable offline |

**Installation:** none — no new packages.

## Package Legitimacy Audit

**N/A — no new external packages are introduced by this phase.** `web3dart` (3.0.2) and `reown_walletkit` (1.4.0) are pre-existing direct dependencies (confirmed in `pubspec.lock`); `wallet` (0.0.18) is a pre-existing transitive dependency already consumed the same way elsewhere in this monorepo (`packages/genius_api/lib/web3/web3.dart`). The Package Legitimacy Gate protocol therefore does not apply; no `npm view`/`pip index`/registry check was run because no package name is being added to `pubspec.yaml`.

## Architecture Patterns

### System Architecture Diagram

```
WalletConnect dApp (e.g. Squid, Uniswap, a generic contract UI)
        │  eth_sendTransaction / personal_sign / eth_signTypedData
        ▼
reown_walletkit.onSessionRequest  (lib/reown/handle_dapp_requests.dart)
        │
        ├─ branch on `method` FIRST (D-07 fix — no shared unconditional params[0] cast)
        │
        ├─ eth_sendTransaction ─┐
        │                       ▼
        │              decode tx['data'] (pure fn, reads a copy — D-09)
        │                       │
        │            ┌──────────┴───────────┐
        │            ▼                      ▼
        │   selector matches          selector doesn't match
        │   transfer/approve          any known ERC-20 fn
        │   (DAP-01)                        │
        │            │              ┌───────┴────────┐
        │            │              ▼                 ▼
        │            │      `to` is a known      `to` is NOT
        │            │      router (D-06          a known router
        │            │      allow-list)                 │
        │            │              │                    ▼
        │            │      selector recognized   DAP-03: unknown-
        │            │      as router swap?       contract-call
        │            │       (Squid: NO in        warning
        │            │        practice, §2)              │
        │            │              │                    │
        │            │              ▼                    │
        │            │      DAP-03: unknown-call,         │
        │            │      "known router" label          │
        │            ▼              │                    │
        │   SendTransactionDetails  └────────┬────────────┘
        │   (unit symbol parameterized,      │
        │    D-02/D-03/D-04 warnings)        ▼
        │            │              cannot-decode / unknown-call content
        │            └──────────────┬─────────────────────┘
        │                           ▼
        │                 ApproveTransactionDrawer.show (UNCHANGED mechanics, Phase 21)
        │                           │
        │                 user approve / reject / dismiss
        │                           │
        ├─ personal_sign ───────────┤  (D-07: same cannot-decode content,
        ├─ eth_signTypedData ───────┘   still gets a real JSON-RPC response)
        │
        ▼
walletKit.respondSessionRequest (JsonRpcResponse success | JsonRpcError reject)
        │
        ▼ (only on eth_sendTransaction approve)
geniusApi.signAndSendTransaction(tx: tx, ...)   ← receives the ORIGINAL, unmutated tx map (D-09)
        │
        ▼
Hive Transaction record — coinSymbol now the DECODED symbol, not hard-coded "ETH" (D-08)
```

### Recommended Project Structure
No new top-level structure — `30-PATTERNS.md` (already written for this phase) specifies file placement precisely: a new pure-Dart decoder file and a new content widget under `lib/reown/`, both following the flat free-function/StatelessWidget conventions already established by `lib/reown/utilities.dart` and `lib/reown/send_transaction_details.dart`. This research does not repeat that mapping; see `30-PATTERNS.md` for the file-by-file plan.

### Pattern 1: ERC-20 selector-then-tuple decode
**What:** Match the calldata's first 4 bytes against a known selector, then decode the remaining bytes as a `TupleType` of the function's parameter types, using the `offset` parameter to skip the selector.
**When to use:** Any fixed, small, known ABI signature — exactly DAP-01's two functions.
**Example:**
```dart
// Source: web3dart 3.0.2, read directly from the pub cache —
// lib/src/contracts/abi/{abi,tuple,integers}.dart (part of package:web3dart/web3dart.dart)
import 'package:web3dart/web3dart.dart';

/// transfer(address,uint256) -> 0xa9059cbb
/// approve(address,uint256)  -> 0x095ea7b3
/// Both selectors are `keccakUtf8('<name>(address,uint256)').sublist(0, 4)` —
/// the same computation `ContractFunction.selector` performs internally
/// (abi.dart:276-278). Hardcoded here as the well-known ERC-20 constants;
/// recommend also asserting them against a derived `ContractFunction.selector`
/// in the unit test so a hand-typed hex typo cannot silently diverge.
const _transferSelectorHex = '0xa9059cbb';
const _approveSelectorHex = '0x095ea7b3';

class DecodedErc20Call {
  const DecodedErc20Call({required this.counterparty, required this.amount});
  final EthereumAddress counterparty; // `to` for transfer, `spender` for approve
  final BigInt amount;
}

/// Returns null on ANY mismatch or malformed input — selector mismatch,
/// too-short calldata, or a decode exception. Never throws across this
/// boundary (matches the existing swallow-and-sentinel convention in
/// lib/reown/utilities.dart and lib/squid_router/squid_util.dart).
DecodedErc20Call? _tryDecodeErc20(String? data, String expectedSelectorHex) {
  if (data == null) return null;
  final Uint8List bytes;
  try {
    bytes = hexToBytes(data);
  } catch (_) {
    return null;
  }
  // 4-byte selector + 2 static 32-byte words = 68 bytes minimum.
  if (bytes.length < 68) return null;
  final selector = bytesToHex(bytes.sublist(0, 4), include0x: true);
  if (selector != expectedSelectorHex) return null;

  try {
    const tuple = TupleType([AddressType(), UintType()]);
    // offset: 4 -- skips the 4-byte selector directly; TupleType.decode's
    // `offset` parameter is a byte offset into the SAME buffer, so no
    // sublist/copy of the calldata is needed (verified: tuple.dart:90-114,
    // integers.dart:26-31 -- `buffer.asUint8List(offset, 32)`).
    final result = tuple.decode(bytes.buffer, 4);
    return DecodedErc20Call(
      counterparty: result.data[0] as EthereumAddress,
      amount: result.data[1] as BigInt,
    );
  } catch (_) {
    return null;
  }
}

DecodedErc20Call? tryDecodeTransfer(String? data) =>
    _tryDecodeErc20(data, _transferSelectorHex);

DecodedErc20Call? tryDecodeApprove(String? data) =>
    _tryDecodeErc20(data, _approveSelectorHex);
```
**Verification notes (read directly from `web3dart-3.0.2` source in the pub cache):**
- `ContractFunction.decodeReturnValues` (abi.dart:286-292) is documented for OUTPUTS and is a thin wrapper: `TupleType(outputs...).decode(hexToBytes(data).buffer, 0)`. There is **no** equivalent `decodeInputs`/`decodeCallValues` convenience method in 3.0.2 — building the `TupleType` from `parameters` (not `outputs`) and calling `.decode` directly, as above, is the correct and only supported path for decoding a call's arguments. [VERIFIED: web3dart-3.0.2 pub cache, `lib/src/contracts/abi/abi.dart:280-293`]
- `TupleType.decode(ByteBuffer buffer, int offset)` (tuple.dart:90-114) treats `offset` as a plain byte offset into `buffer` and adds per-field byte lengths on top of it — it is safe and correct to pass the FULL calldata buffer with `offset: 4`, no `sublist` needed. [VERIFIED: web3dart-3.0.2 pub cache, `lib/src/contracts/abi/tuple.dart:90-114`]
- `hexToBytes` (`lib/src/crypto/formatting.dart:42-46`) strips an optional `0x` prefix and returns a fresh `Uint8List` — its `.buffer` is a clean, correctly-offset `ByteBuffer` (not a view sharing another array's backing store). [VERIFIED: web3dart-3.0.2 pub cache]
- `UintType.decode`/`AddressType.decode` both read exactly 32 bytes per field via `buffer.asUint8List(offset, 32)` (`lib/src/contracts/abi/integers.dart:26-31`) — a too-short buffer throws a `RangeError`, which the `try/catch` above converts into the "cannot decode" sentinel. [VERIFIED: web3dart-3.0.2 pub cache]
- `EthereumAddress` is **not** defined inside `web3dart` — it lives in the `wallet` package (0.0.18) and is used internally by `web3dart`'s `part of` files via an unprefixed, non-re-exported `import 'package:wallet/wallet.dart';`. Any file that names `EthereumAddress` explicitly (as the example above does) must import `package:wallet/wallet.dart` itself. [VERIFIED: `grep -rl "class EthereumAddress"` found it only in `wallet-0.0.18/lib/src/ethereum/ethereum_address.dart`, never inside `web3dart-3.0.2/lib`] The existing precedent for this exact combined import already exists in this repo: `packages/genius_api/lib/web3/web3.dart:8` — `import 'package:wallet/wallet.dart' hide PrivateKey;` alongside `import 'package:web3dart/web3dart.dart';`. [VERIFIED: packages/genius_api/lib/web3/web3.dart:8,14]
- `EthereumAddress` exposes `.with0x` (lowercase hex) and `.eip55With0x` (checksummed) string getters for display. [VERIFIED: `wallet-0.0.18/lib/src/ethereum/ethereum_address.dart:20-26`]
- Add `transfer`/`approve` to the EXISTING `Web3.abi` constant (`packages/genius_api/lib/web3/web3.dart:42-47`) rather than declaring a second ABI JSON blob — that constant already lists `name`/`decimals`/`balanceOf`/`symbol` for the same purpose. [VERIFIED: packages/genius_api/lib/web3/web3.dart:42-47 — full JSON quoted: `{ "constant": true, "inputs": [], "name": "name", ... }, { ...decimals... }, { ...balanceOf... }, { ...symbol... }`]

### Pattern 2: Router allow-list that mostly declines to guess
**What:** A chain-keyed constant map of known router addresses, consulted only to decide the LABEL on an undecodable call ("known router: Squid" vs plain "unknown contract"), not to fabricate a swap summary.
**When to use:** DAP-02, given the finding in §2 below.
**Example:**
```dart
/// D-06: compile-time constant only -- never fetched, never mutated.
/// Ship with exactly the one router the companion dApp (Squid) uses.
/// UNVERIFIED beyond this research pass -- confirm this address against
/// a live Squid v2 `/route` response's `transactionRequest.target` (or
/// current docs.squidrouter.com) at implementation time; the docs page
/// this claim rests on returned 404 during this research session (see §2).
const Map<int, Set<String>> kKnownRouters = {
  8453: {'0xce16f69375520ab01377ce7b88f5ba8c48f8d666'}, // Base
  1: {'0xce16f69375520ab01377ce7b88f5ba8c48f8d666'}, // Ethereum mainnet
};

bool isKnownRouter(int chainId, String toAddress) =>
    kKnownRouters[chainId]?.contains(toAddress.toLowerCase()) ?? false;
```

### Anti-Patterns to Avoid
- **Assuming 18 decimals for an unresolved token (D-02):** a wrong decimals guess produces a confident, wrong amount, which is worse than an explicit "unverified, raw units" label. Never default `decimals` when `WalletDetailsCubit.state.coins` has no match.
- **Fetching a token's `symbol()`/`decimals()` from RPC inside the signing handler (D-01):** adds latency and a hostile-RPC failure mode to the last human checkpoint before a signature. Resolve offline only.
- **Decoding Squid's multicall into a fabricated "X → Y" by pattern-matching common sub-call shapes:** technically possible for the specific routes the developer happens to test, but not reliable across all routes Squid can construct, and explicitly against D-06 ("never a partial guess") and Claude's Discretion ("no speculative selector catalogue").
- **Mutating `tx` during decode (D-09):** e.g. lowercasing `tx['to']` or stripping `0x` in place. Decode must operate on values read out of `tx`, never write back into it — `tx` is passed by reference into `geniusApi.signAndSendTransaction` (`handle_dapp_requests.dart:152` → `packages/genius_api/lib/web3/web3.dart:550`, `hexToBytes(tx['data'])` at `:566`). [VERIFIED: packages/genius_api/lib/web3/web3.dart:549-566]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| ABI selector computation | A manual keccak-of-signature helper | `ContractFunction.selector` (or the well-known hardcoded hex, cross-checked against it in tests) | `web3dart` already computes this correctly (`keccakUtf8(encodeName()).sublist(0,4)`); a hand-rolled version is one more place to typo a hex string |
| ABI argument decoding | A byte-offset parser for `address`/`uint256` | `TupleType([AddressType(), UintType()]).decode(buffer, offset)` | Already handles padding, word-alignment, and dynamic-vs-static layout correctly; hand-rolling risks getting padding or the 32-byte word size wrong |
| JSON-RPC error codes | Ad-hoc integer literals for "user rejected" | `Errors.getSdkError(Errors.USER_REJECTED)` (returns `{code, message}`) from `reown_core` (re-exported by `reown_walletkit`) | The correct, already-imported API; the existing code's `Errors.USER_REJECTED.toInt()` is NOT this and silently produces `code: null` (see Summary) |

**Key insight:** every primitive this phase needs already ships in a dependency already in `pubspec.lock`. The work is composition (selector table + tuple decode + drawer content), not new decoding infrastructure.

## Common Pitfalls

### Pitfall 1: Reusing `decodeReturnValues`-shaped thinking for inputs
**What goes wrong:** Copying the `outputs`-based decode pattern verbatim and forgetting the leading 4-byte selector, producing garbage decoded values (reading the selector's last byte as part of the address word).
**Why it happens:** `decodeReturnValues` is the only convenience method the library ships, and it decodes from offset 0 because return data has no selector.
**How to avoid:** Always decode calldata with `offset: 4`, never `offset: 0`, and add a length guard (`bytes.length < 68`) before decoding.
**Warning signs:** A decoded "amount" that's astronomically large or an address that doesn't checksum-validate — both symptoms of a 4-byte misalignment.

### Pitfall 2: `event.params[0]` cast crashing before the method is even known
**What goes wrong:** `personal_sign`/`eth_signTypedData` requests throw inside the try block before `content` is ever built, get swallowed by the outer `catch (e)`, and the dApp receives **no response at all** — not even a rejection.
**Why it happens:** `(event.params as List<dynamic>)[0] as Map<String, dynamic>` (`:39-40`) runs unconditionally for every method, but `SessionRequestEvent.params` is typed `dynamic` with no shape guarantee (`reown_sign-1.3.9/lib/models/sign_client_events.dart:124`), and `personal_sign`'s/`eth_signTypedData`'s first param is a `String`, not a `Map`.
**How to avoid:** Branch on `method` before doing any params-shape-specific cast; only cast to `Map<String, dynamic>` inside the `eth_sendTransaction` branch.
**Warning signs:** A dApp UI that spins forever on a signature request with this wallet, with nothing in the wallet's own logs beyond a caught, discarded exception.

### Pitfall 3: `Errors.X.toInt()` looks correct but returns `null`
**What goes wrong:** `code: Errors.USER_REJECTED.toInt()` compiles and runs without error, but sends a JSON-RPC error response with `code: null` — the field is silently omitted from the serialized JSON (`JsonRpcError`'s `@JsonSerializable(includeIfNull: false)`).
**Why it happens:** `Errors.USER_REJECTED` is the STRING `'USER_REJECTED'` (a lookup key into `Errors.SDK_ERRORS`), and `.toInt()` resolves to `reown_sign`'s `EtheraAmountExtension.toInt()` (`int.tryParse(this)`), which returns `null` for any non-numeric string. [VERIFIED: reown_core-1.3.8/lib/utils/errors.dart:3-70 (constants + SDK_ERRORS map); reown_sign-1.3.9/lib/utils/extensions.dart:86-91 (`toInt()` extension body: `int.tryParse(this!)`)]
**How to avoid:** Use `Errors.getSdkError(Errors.USER_REJECTED).code` (and `.message`), the API the package actually provides for this.
**Warning signs:** A conforming JSON-RPC client (most dApp SDKs) treating a code-less error response as malformed or falling back to a generic error message instead of "user rejected".

### Pitfall 4: Trusting a decode just because the bytes are the right shape
**What goes wrong:** Calldata that happens to be ≥68 bytes and matches a known 4-byte selector is decoded and presented as "transfer 100 USDC to 0x...", but the target contract may not actually be a standard ERC-20 (selector collisions across differently-typed functions are a known, if rare, Solidity phenomenon).
**Why it happens:** The decoder only inspects the calldata bytes; it has no way to confirm the target contract's real ABI without an RPC call, which D-01 forbids.
**How to avoid:** Always pair the decode with D-02's "unresolved token" framing when `tx['to']` isn't found in `WalletDetailsCubit.state.coins` — see the threat-model section below.
**Warning signs:** N/A by construction if D-02's unresolved-token framing is always applied; the risk is only realized if a future change starts treating every 68-byte-and-matching-selector call as "verified".

## Code Examples

### Amending `test/reown/approve_drawer_contract_test.dart` Case 6 (D-10)

**Read directly** (`test/reown/approve_drawer_contract_test.dart:429-485`). Case 6 pumps a SINGLE fixture, `_txFixture` (a `SendTransactionDetails` with native-ETH-shaped values: `amount: '1.2345'`, `totalGasFee: '0.0010'`, `maxFeePerGas: '0.0020'`, `priorityFee: '0.0007'`), and asserts:
1. no `Text` anywhere contains `$` (line 452-457), and
2. every regex match of `\d+\.\d+` across all on-screen `Text` widgets is a member of `knownNumbers = {amount, totalGasFee, maxFeePerGas, priorityFee}` (lines 463-480).

**Important existing property, already true today, that narrows the fix:** the regex is `\d+\.\d+` — it requires a decimal point. D-02's "raw base-unit integer" for an unresolved token has NO decimal point (it's a plain `BigInt.toString()`), so it will **never** trip this regex on its own. The only way Case 6 "fails by construction" (per D-10's own wording) is when a **resolved** token amount is rendered with a fractional value that ISN'T one of the four literals already in `knownNumbers` — i.e. a decoded ERC-20 `amount` that differs from the native-ETH fixture's `'1.2345'`.

**Recommended minimal amendment — add a sibling test, do not restructure the existing one:**
- **Lines 429-485 (existing Case 6): UNCHANGED.** It continues to prove the native-ETH `eth_sendTransaction` path renders only its own four numbers.
- **New block added directly after line 485** (before the closing `});` / `}` of the outer groups), modeled 1:1 on the existing Case 6 body: a new `const` fixture representing a decoded ERC-20 send (e.g. `_erc20TxFixture = SendTransactionDetails(fromAddress: ..., toAddress: ..., amount: '42.5', totalGasFee: '0.0010', maxFeePerGas: '0.0020', priorityFee: '0.0007', receiveTokenSymbol: null)` — reusing D-03's unit-symbol parameter with e.g. `'USDC'` if the widget grows that field), pumped through `ApproveTransactionDrawer.show` the same way, with its OWN local `knownNumbers` literal (`{_erc20TxFixture.amount, _erc20TxFixture.totalGasFee, ...}`) and the identical `$`-absence and regex-membership assertions.
- **Why this preserves meaning:** the assertion stays an exact enumeration of "the numbers this specific fixture was given" — it still fails the moment any FIFTH, unexplained number (a fiat conversion, a duplicate rendering, a raw-vs-formatted mismatch) reaches the screen for either fixture. Nothing is loosened; a new, independent case is added.
- **Why duplication over parameterizing the existing test:** this file already establishes duplication as its convention (Cases 1/4a and 2/4b and 3/4c are near-identical pairs across the two drawers); a `for`-loop-over-fixtures abstraction here would be a new pattern introduced for exactly one caller, which AGENTS.md's Rule of Three explicitly declines.
- If the planner instead decides `SendTransactionDetails` is NOT reused for decoded ERC-20 sends (a new, separate content widget per `30-PATTERNS.md`'s "No Analog Found" table), the same reasoning applies to that widget's own new test file rather than this one — Case 6 in THIS file would then need no change at all, since it only ever pumps `SendTransactionDetails`.

### D-07 fix shape (method routing before the unsafe cast)

```dart
// BEFORE (handle_dapp_requests.dart:38-41) -- runs for EVERY method:
// final Map<String, dynamic> tx =
//     (event.params as List<dynamic>)[0] as Map<String, dynamic>;
// final String method = event.method;

// AFTER -- branch on method FIRST, only cast to Map inside the branch
// that actually receives a transaction-object param:
final String method = event.method;
final String topic = event.topic;

if (method == 'eth_sendTransaction') {
  final tx = (event.params as List<dynamic>)[0] as Map<String, dynamic>;
  // ... existing eth_sendTransaction handling, decode, drawer, sign/send ...
} else if (method == 'personal_sign' || method == 'eth_signTypedData' ||
    method == 'eth_signTypedData_v4') {
  // D-07: route to the SAME cannot-decode presentation as an unknown
  // contract call (D-05's widget). No `tx` map exists for these methods --
  // params[0] here is a String (the message / typed-data JSON), not a Map.
  // ... build cannot-decode content, show the drawer, then ALWAYS respond:
  // approve -> still cannot actually sign (deferred, per Claude's
  //   Discretion) -- or, if the plan chooses to let these through
  //   unmodified via the existing sign machinery, that is a decision for
  //   the plan, not this research; either way, RESPOND, never let the
  //   catch-all swallow it.
  // reject  -> walletKit.respondSessionRequest with
  //            JsonRpcError(code: Errors.getSdkError(Errors.USER_REJECTED).code,
  //                         message: Errors.getSdkError(Errors.USER_REJECTED).message)
} else {
  // existing unknown-method / unknown-contract-call branch (D-05)
}
```

### Correct JSON-RPC rejection response (fixes the existing `.toInt()` bug)

```dart
// BEFORE (handle_dapp_requests.dart:211, :234):
// error: JsonRpcError(code: Errors.USER_REJECTED.toInt(), message: ...)

// AFTER:
final sdkError = Errors.getSdkError(Errors.USER_REJECTED);
await walletKit.respondSessionRequest(
  topic: topic,
  response: JsonRpcResponse(
    id: requestId,
    jsonrpc: '2.0',
    error: JsonRpcError(code: sdkError.code, message: sdkError.message),
  ),
);
```
[VERIFIED: reown_core-1.3.8/lib/utils/errors.dart:161 — `static ReownCoreError getSdkError(String key, {String context = ''})`]

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| Blind signing: raw params dump, no decode | Decoded, human-readable action for known call shapes; explicit "cannot verify" for everything else | This phase | Matches the direction the whole wallet industry moved (Rabby/MetaMask-style pre-transaction simulation/summary) — but this phase does the offline-only, no-simulation subset of that, deliberately (D-01) |

**Deprecated/outdated:** none specific to this phase's libraries — `web3dart` 3.0.2 and `reown_walletkit` 1.4.0 are both current resolved versions in this repo (not verified against the latest upstream releases; not relevant since the phase works within the already-resolved versions).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Squid's router contract address `0xce16F69375520ab01377ce7B88f5BA8C48F8D666` is current and applies unchanged to Base (8453) and Ethereum (1) | §2 / Pattern 2 | If stale or chain-specific, the allow-list either misses the real Squid transactions (falls to generic unknown-call — safe, just less informative) or, worse, matches the wrong address (low risk: the allow-list is a labeling aid, not a trust decision — the D-05 unknown-call fallback still fires either way since the swap can't be decoded regardless) |
| A2 | Squid's on-chain execution path for a route is the generic `SquidMulticall.run(Call[])` pattern, not a fixed simple swap signature | §2 / Summary | If wrong and a simpler, decodable entrypoint exists for some routes, DAP-02's "X → Y" criterion could partially be met after all — worth a fresh check against a REAL Squid quote's `transactionRequest.data` (first 4 bytes) before committing to "always unknown-call" in the plan |
| A3 | `docs.squidrouter.com/additional-resources/additional-dev-resources/contract-addresses` (the canonical page this research wanted to cite) returned 404 during this session; the address above comes from cross-referencing Etherscan/Polygonscan/Optimism listings labeled "Squid: Router" plus a search-engine synthesis of the docs site's likely content, not a direct successful fetch of the docs page itself | §2 | The address could be stale (Squid v1 vs v2) or the docs URL could have moved; **the plan should re-verify this address (or better, pull it from a real quote response's `transactionRequest.target`) before hardcoding it** |
| A4 | The unlimited-approval threshold `amount >= 2^255` (half of max uint256) is a reasonable single-comparison rule | Not yet in a numbered section — see recommendation below | If real dApps commonly approve amounts between, say, 2^200 and 2^255 as a deliberate "large but not unlimited" pattern, this threshold would over-flag; not observed in this research, standard practice (MetaMask/Rabby-style tooling) is to flag anything close to max as unlimited, and no real ERC-20 total supply is realistically anywhere near 2^255 |

**Recommendation for D-04 (max-uint256 threshold), since the task asked for one simple rule:** compare the decoded `approve` amount against a single constant, `kUnlimitedApprovalThreshold = BigInt.two.pow(255)` (half of `2^256`), and treat `amount >= kUnlimitedApprovalThreshold` as unlimited. This is a single `BigInt` comparison (matching D-04's "costs one comparison" framing), catches the canonical `2^256 - 1` sentinel exactly, tolerates the common off-by-small-amount variants some dApp SDKs produce, and — because no real ERC-20 total supply (even at 18 decimals, even for an intentionally huge-supply meme token) gets remotely close to `2^255 ≈ 5.8×10^76`, this single comparison also naturally satisfies "very large relative to supply" without needing an on-chain `totalSupply()` call, which D-01 forbids anyway. [ASSUMED — the threshold value itself is a defensible engineering choice, not sourced from a spec; flagged for confirmation rather than presented as an industry-standardized constant]

## Open Questions

1. **Does `SendTransactionDetails` get reused for decoded ERC-20 sends, or does DAP-01 get its own content widget?**
   - What we know: D-03 parameterizes `SendTransactionDetails`'s unit symbol, strongly implying reuse for token sends. `30-PATTERNS.md` lists a separate "decoded-call content widget" as a new file, closer in shape to a router/unknown-call presentation.
   - What's unclear: whether a decoded ERC-20 `transfer` renders through the (now-parameterized) `SendTransactionDetails`, or through a new widget that itself embeds `SendTransactionDetails`-like rows.
   - Recommendation: the planner should settle this explicitly in the plan (it directly determines the exact diff to `test/reown/approve_drawer_contract_test.dart` Case 6, discussed above) — either answer is consistent with the locked decisions.

2. **Is there a simpler, decodable entrypoint for SOME Squid routes (e.g. same-chain swaps that don't need the bridge/multicall machinery)?**
   - What we know: the verified pattern (§2) is the generic multicall proxy pattern, cross-confirmed on multiple chains' block explorers.
   - What's unclear: Squid v2's API may route same-chain-only swaps through a simpler path that isn't the multicall (unconfirmed either way in this research pass — the docs page most likely to answer this returned 404).
   - Recommendation: if time allows during planning/implementation, fetch one real Squid v2 quote for a Base same-chain swap and inspect the first 4 bytes of `transactionRequest.data` before finalizing the "always falls to unknown-call" assumption in the plan. If it's still the multicall selector, the phase's chosen approach is confirmed correct as-is.

## Environment Availability

Skipped — this phase has no new external tool/service/runtime dependency. Both libraries used are already resolved into the Flutter/Dart toolchain already required to build this app.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (via Flutter SDK), already used throughout `test/reown/` [VERIFIED: test/reown/utilities_test.dart, test/reown/approve_drawer_contract_test.dart] |
| Config file | none dedicated — standard `flutter test` discovery over `test/` |
| Quick run command | `flutter test test/reown/` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DAP-01 | `tryDecodeTransfer`/`tryDecodeApprove` correctly decode real ERC-20 calldata fixtures and return `null` on malformed/mismatched input | unit (pure Dart, no widget harness — mirrors `test/reown/utilities_test.dart`'s shape) | `flutter test test/reown/<decoder_file>_test.dart` | ❌ Wave 0 — new file |
| DAP-01 | Drawer renders the decoded token/amount instead of raw params for a `transfer`/`approve` calldata fixture | widget (mirrors `test/reown/approve_drawer_contract_test.dart`'s `_openDrawer` harness) | `flutter test test/reown/approve_drawer_contract_test.dart` | ✅ (extend, don't replace — see Code Examples above) |
| DAP-02 | A Squid-router-addressed `eth_sendTransaction` with the router's real multicall calldata renders the "known router, cannot decode" unknown-call presentation, not a fabricated "swap X→Y" | unit/widget (fixture built from a real captured Squid transaction's calldata, or a synthetic one shaped like `SquidMulticall.run(...)`) | same decoder/widget test files as DAP-01 | ❌ Wave 0 — new fixture |
| DAP-03 | An arbitrary/garbage-selector calldata (not matching any known ERC-20 function, not addressed to a known router) renders the plain unknown-contract-call warning | widget | `flutter test test/reown/approve_drawer_contract_test.dart` (or its sibling for the new widget) | ❌ Wave 0 — new case |
| DAP-03 | `personal_sign`/`eth_signTypedData` requests no longer throw inside `onSessionRequest` and always produce a `respondSessionRequest` call (success or `JsonRpcError`) | unit/integration on `handle_dapp_requests.dart`'s handler function, OR a focused test isolating the params-shape branch | none today — `handle_dapp_requests.dart` itself has no dedicated test file | ❌ Wave 0 — new file, per `30-PATTERNS.md`'s suggested `test/reown/handle_dapp_requests_test.dart` |
| D-09 (byte-identity) | The `tx` map is bit-for-bit identical before and after the decode step runs | unit | a simple `Map` equality/identity assertion around the decode call | ❌ Wave 0 — new test, trivial |

### Sampling Rate
- **Per task commit:** `flutter test test/reown/`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `test/reown/<decoder_file>_test.dart` — pure-Dart decode unit tests, covers DAP-01, DAP-02 (fixture proving the multicall selector does NOT match transfer/approve and does not get labeled as a swap)
- [ ] New case(s) in `test/reown/approve_drawer_contract_test.dart` (or a sibling file for a new content widget) — covers DAP-01 drawer rendering, DAP-03 unknown-call rendering, D-10's amended Case-6-equivalent assertion
- [ ] A `tx`-identity test (D-09) — trivial, one assertion
- [ ] Optional: `test/reown/handle_dapp_requests_test.dart` if the planner decides the D-07 method-routing fix warrants a handler-level test rather than only being exercised indirectly through the drawer widget tests
- Framework install: none — `flutter_test` is already a dev dependency and already exercised by the two existing files in `test/reown/`

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | no | Out of scope — this phase does not touch wallet auth/unlock |
| V3 Session Management | no | WalletConnect session lifecycle is unchanged; only the request-handling content changes |
| V4 Access Control | no | No new access-control boundary introduced |
| V5 Input Validation | yes | All calldata (`tx['data']`, `event.params`) is untrusted input from an external dApp; the decoder MUST treat every field as attacker-controlled and fail closed (return `null`/unknown-call) on any malformed, too-short, or unexpected-shape input — never throw uncaught, never guess |
| V6 Cryptography | no | No new cryptographic primitive; keccak/selector computation is read-only hashing already provided by `web3dart`, not a security boundary itself |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Selector-shape confusion: calldata is the right length and matches a known 4-byte selector, but the target contract isn't actually a standard ERC-20 (selector collision or a nonstandard contract) | Spoofing | Always pair a "successful" decode with D-02's unresolved-token framing (raw units + contract address) unless the target address is independently confirmed in `WalletDetailsCubit.state.coins` — never present a decode as verified truth purely because the bytes parsed |
| Lookalike/confusable token symbol rendered from a spoofed or unicode-crafted `symbol()`/`name()` | Spoofing | Mitigated structurally by D-01: symbol/decimals come ONLY from the wallet's own already-vetted `coins` list, never fetched live from the calldata's target contract — an unresolved token renders its raw contract address instead of any attacker-suppliable string |
| `tx.value` (native currency) nonzero alongside decoded ERC-20 `transfer`/`approve` calldata (which should be non-payable, `value` should be 0) | Tampering | Not explicitly required by DAP-01/02/03, but worth the plan considering: if `value` is nonzero on a decoded token call, render both the decoded action AND the native-value line so nothing is hidden — a mismatch here is a signal, not proof of an attack, so this should inform (not block) the drawer content |
| Router allow-list poisoned by a future change that fetches it at runtime instead of compiling it in | Tampering / Elevation of Privilege | D-01's "no network call on the signing path" already forecloses this if honored; the allow-list MUST stay a `const` — flag any future PR that makes it fetched as a regression of this phase's security posture |
| dApp identity spoofing via WalletConnect peer metadata (`dappName`/`dappUrl`/`iconUrl`) while the calldata decode itself is accurate | Spoofing | Pre-existing, orthogonal risk already partially mitigated by Phase 21 (broken-icon handling); decoding calldata makes the MECHANICS of the call trustworthy, it does NOT and should not be presented as verifying the dApp's claimed identity — do not let an accurate "transfer 100 USDC" label imply the requesting dApp itself has been vetted |
| Generic multicall (Squid) calldata containing an attacker-supplied nested `target`/`callData` that a naive "helpful" decode might partially surface (e.g. showing the LAST sub-call's target as if it were "the destination") | Tampering / Information Disclosure (misleading, not leaking) | Do not attempt partial decodes of the multicall's nested `Call[]` array — per §2's finding and D-06, the entire router call should fall through to the unknown-call treatment rather than surface a partial, potentially misleading fragment of the real route |

## Sources

### Primary (HIGH confidence)
- `web3dart-3.0.2` source, read directly from the local pub cache (`C:/Users/User/AppData/Local/Pub/Cache/hosted/pub.dev/web3dart-3.0.2/lib/`) — `src/contracts/abi/abi.dart`, `tuple.dart`, `integers.dart`, `types.dart`, `src/crypto/formatting.dart`, `src/crypto/keccak.dart`
- `reown_core-1.3.8/lib/utils/errors.dart`, `reown_sign-1.3.9/lib/utils/extensions.dart`, `reown_sign-1.3.9/lib/models/sign_client_events.dart` — read directly from the local pub cache
- `wallet-0.0.18/lib/src/ethereum/ethereum_address.dart` — read directly from the local pub cache
- This repo's own `pubspec.lock` (resolved versions), `packages/genius_api/lib/web3/web3.dart`, `packages/genius_api/lib/models/coin.dart`, `lib/reown/handle_dapp_requests.dart`, `lib/reown/utilities.dart`, `lib/reown/send_transaction_details.dart`, `lib/reown/approve_transaction_drawer.dart`, `lib/components/feedback/gw_warning_note.dart`, `test/reown/approve_drawer_contract_test.dart`, `test/components/drawer_padding_invariant_test.dart` — all read directly this session

### Secondary (MEDIUM confidence)
- Squid router address `0xce16F69375520ab01377ce7B88f5BA8C48F8D666`, cross-referenced across Etherscan/Polygonscan/Optimism block-explorer listings labeled "Squid: Router" via `WebSearch` — [CITED: etherscan.io/address/0xce16f69375520ab01377ce7b88f5ba8c48f8d666, polygonscan.com/address/0xce16f69375520ab01377ce7b88f5ba8c48f8d666] — the canonical `docs.squidrouter.com` contract-addresses page itself 404'd when fetched directly this session (see Assumption A3)
- Squid's proxy/multicall architecture (`SquidRouterProxy` delegating to an implementation; `SquidMulticall.run(Call[])` with `enum CallType {Default, FullTokenBalance, FullNativeBalance, CollectTokenBalance}`) — [CITED: etherscan.io contract-code pages for the Squid Router and Squid Multicall addresses, via `WebFetch`/`WebSearch` synthesis] — not independently re-derived from a fetched `.sol` source file in this session; flagged UNVERIFIED at the level of exact struct field names (see A2)
- `route.transactionRequest.{target,data,value}` shape — [CITED: docs.squidrouter.com/api-and-sdk-integration/api/swap-and-bridge-example, via `WebFetch`]
- Max-uint256 sentinel value and general wallet-industry practice of flagging near-max approvals as "unlimited" (Rabby Wallet) — [CITED: rugdoc.io/wiki/docs/introduction-to-rabby, via `WebSearch`]

### Tertiary (LOW confidence)
- None used as load-bearing claims — every claim above is either read directly from source in this session (Primary) or backed by a specific fetched/cited page (Secondary). Where confidence could not be raised past "search-engine synthesis" (the exact Squid contract-addresses doc page and the exact Solidity struct layout), this is called out explicitly in the Assumptions Log rather than presented as verified.

## Metadata

**Confidence breakdown:**
- Standard stack (DAP-01 decode mechanics): HIGH — read directly from the resolved 3.0.2 source, cross-checked against the actual `decodeReturnValues` usage pattern already proven to work in this codebase's dependency graph
- Router/swap decoding (DAP-02): MEDIUM — the conclusion ("cannot honestly decode X→Y offline") is well-supported by multiple independent block-explorer confirmations of the proxy/multicall pattern, but the exact router address and struct layout rest on search-engine synthesis rather than a directly fetched official source (docs page 404'd)
- Broken-methods fix (D-07) and JSON-RPC response contract (DAP-03): HIGH — read directly from `reown_core`/`reown_sign` source and this repo's own `handle_dapp_requests.dart`
- Threat model: MEDIUM — reasoned from the verified mechanics above plus general, well-established EVM/wallet security practice; not independently audited

**Research date:** 2026-09-19
**Valid until:** 30 days for the `web3dart`/`reown_walletkit` findings (stable, already-pinned versions); 7 days for the Squid router address/architecture claims (A3 flags the docs source as unconfirmed — re-verify before the plan hardcodes the address, ideally against a live quote response rather than a cached search result)
</content>
