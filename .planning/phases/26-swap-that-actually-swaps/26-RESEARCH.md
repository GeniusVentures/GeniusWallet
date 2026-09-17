---
phase: 26
name: Swap that actually swaps
created: 2026-09-16
method: code read + empirical verification on this machine
---

# Research

Everything below was run, not read about. Web sources are cited only where they are the authority.

## The Squid client already exists in this repo

`.gitmodules` declares `squidrouter`, `banxa` and `tokeninfo`. The `squidrouter` submodule is a
generated Dart OpenAPI client for Squid v2: **336 Dart files, 109 committed `.g.dart` files**, so no
`build_runner` step. It is **not** in `pubspec.yaml` and is imported nowhere in `lib/`.

| Need | Already provided |
|---|---|
| Base URL | `squidrouter/lib/src/api.dart:15` — `https://v2.api.squidrouter.com` |
| `x-integrator-id` | `ApiKeyAuthInterceptor` injects it; set `apiKeys['IntegratorId']` |
| `POST /v2/route` | `getRoute({required RouteRequest})` → `RouteResponseData` |
| Quote without a tx | `RouteRequest.quoteOnly` |
| Estimate tree | `Estimate`: `toAmount`, `toAmountMin`, `exchangeRate`, `aggregatePriceImpact`, `gasCosts`, `feeCosts`, `actions`, `estimatedRouteDuration`, + USD variants |
| Tx to sign, quote id | `RouteResponseDataRoute.transactionRequest` / `.quoteId` |
| Id for polling | **the `x-request-id` RESPONSE HEADER** — *not* `RouteResponseData.requestId`, which is null. See the live-call section |
| `GET /v2/status` | `getStatus()` → `StatusResponse` |

`RouteRequest` fields: `fromChain`, `fromToken`, `fromAmount`, `fromAddress?`, `toChain`, `toToken`,
`toAddress?`, `slippage?`, `quoteOnly?`, plus hooks and fallbacks.

### Verification run 2026-09-16

- `dart pub get` in `squidrouter/` → exit 0, 68 deps
- `dart analyze` in `squidrouter/` → **0 errors**; 60 warnings in `lib/` (unused imports, unused
  optional params — generated-code noise), 91 in `test/`
- Root `analysis_options.yaml:8-9` already excludes `banxa` and `squidrouter`, so none of that
  reaches the app's gate
- Added `squidrouter: {path: squidrouter}` → `flutter pub get` exit 0, 6 deps added
- `flutter analyze` on the app → **"No issues found"**, exit 0, 84s
- Smoke test: built a `quoteOnly` `RouteRequest`, serialized it via `standardSerializers`, and
  resolved `getRoute` / `getStatus` / `Squidrouter.basePath` → **2/2 passed**
- All reverted; tree left clean

**Caveat.** Commit `094d6f6d` is titled *"Removed unused `squidrouter` submodule"* — dropped once,
later restored. If anyone remembers why, ask before building on it.

## What is there today

| Thing | State |
|---|---|
| `squid_token_service.dart:10, 33, 56` | `fetchTokens` / `fetchBalances` / `getRoute` each `return mock…` on the first line |
| The commented "real" calls | Reference `$_baseUrl`, **never defined anywhere** — would not compile. Also point at `testnet.api.squidrouter.com/v1`, retired |
| `swap_screen.dart:301` | `// TODO: invoke Squid API`, then fabricates a `completed` Transaction, success toast, receipt, Hive write |
| `lib/squid_router/models/` | Flat shapes fitted to the mock; duplicates the submodule |
| Rate on screen | Constant `993.72` |

## ERC-20: not in the SDK, but the machinery is

Grepped all of `packages/genius_api/lib/` for `approve` / `allowance` / `erc20` → **zero hits**.

Everything needed is nonetheless in `packages/genius_api/lib/web3/web3.dart`:

- Shared ERC-20 ABI at `:42` — has `name`, `decimals`, `balanceOf`, `symbol`. **Add two entries.**
- `balanceOf()` at `:208` — the read pattern `allowance()` mirrors
- `executeBridgeOutTransaction()` at `:424` — the write pattern `approve()` mirrors: build tx →
  `EthPrivateKey.fromHex(getPrivateKeyStr(wallet))` → `client.sendTransaction(..., chainId:)`
- `signAndSendTransaction()` at `:550` — takes a raw `{to, value, data, gas, maxFeePerGas,
  maxPriorityFeePerGas}` map, exactly the shape of `transactionRequest`. Proven in the dApp path at
  `handle_dapp_requests.dart:152`

Spender is `transactionRequest.target`; amount is `fromAmount`.

**`executeBridgeOutTransaction` drops its own error** — its `catch (e)` builds
`ApiResponse.error(e.toString())` with no `return`, so every failure falls through to
`'Failed to bridge: unknown'`. Do not inherit this when copying the pattern. Logged as
`11-FINDINGS.md` F-03.

## Flow

1. `getRoute(quoteOnly: true)` while the user types → display only, no `transactionRequest`
2. On submit, `getRoute(quoteOnly: false)` → real `transactionRequest`, `quoteId`, `requestId`
3. `allowance(owner, spender: transactionRequest.target)`; if short, `approve(exact fromAmount)`
4. `signAndSendTransaction(transactionRequest)` → hash
5. Poll `getStatus(transactionId: hash, requestId, fromChainId, toChainId, quoteId)` until
   `success`, `partial_success`, `needs_gas` or `not_found`. **`requestId` must be read from the
   `x-request-id` response header of the route call** — the body field is null
6. Only now write the transaction, and write the status that actually came back

## Live call against the real API, 2026-09-16

Integrator ID received and verified with a real `POST /v2/route`, `quoteOnly: true`, on **Base
8453**, GNUS → USDC. **HTTP 200.** The ID works and needs no upgrade to quote.

What came back:

| Field | Value |
|---|---|
| `exchangeRate` | **0.75627** — the mock's `993.72` was invented, off by ~1300x |
| `aggregatePriceImpact` | **0.03 %** |
| `toAmount` / `toAmountMin` | 756270 / 747951 (USDC, 6 decimals) |
| `estimatedRouteDuration` | 1 s |
| `gasCosts` / `feeCosts` | 1 / 0 |
| `actions` | `['swap', 'swap']` — GNUS → AERO → USDC via **Aerodrome Solidly** |
| `quoteId` | present |
| `transactionRequest` | **absent**, as documented for `quoteOnly` |

**GNUS on Base is real but THIN.** Squid resolves it as `GENIUS AI`, 18 decimals, coingecko id
`genius-ai`, `usdPrice` 0.7585. An earlier note here called the liquidity risk "closed" on the
strength of 0.03 % impact — that was a **1 GNUS trade, i.e. $0.76**, and was not representative.
Measured properly, 2026-09-16:

| Trade | Impact |
|---|---|
| 1 GNUS (~$0.76) | 0.03 % |
| 100 GNUS (~$76) | **2.93 %** |
| 1000 GNUS (~$758) | **HTTP 400 — "Price impact is above 5%. Try reducing the swap amount."** |

Base is still the right **walk** chain: the walk spends a few dollars, well inside the usable band.
It is **not** evidence that users can swap meaningful GNUS amounts on Base. That is a liquidity
problem, not a provider problem, and no aggregator can fix it.

### Squid rejects a route above 5% price impact

`POST /v2/route` returns **HTTP 400** with
`{"message":"Price impact is above 5%. Try reducing the swap amount.","type":"BAD_REQUEST"}`.

This is a normal, reachable user state for a thin token like GNUS — not an exceptional error.
**26-07 must surface it as its own message**, distinct from a network failure, and it should
suggest a smaller amount the way Squid's own text does. `RouteRequest.bypassGuardrails` exists;
do not reach for it, it exists to let a user eat a >5% loss.

### The generated client's spec has drifted from the live API

`getSDKInfo()` **cannot parse the real `/v2/sdk-info` response.** The generated `EvmChain` declares
`enableBoostByDefault` non-nullable; the live API sends it **null on all 82 chains** and omits it
entirely on 25 EVM chains. Verified directly, 2026-09-16 — the whole payload is rejected.

`squidrouter/` is a generated submodule and may not be edited (AGENTS.md), so the adapter reads
that endpoint off the generated client's **own dio instance** — same base path, timeouts and
integrator-ID interceptor — and deserializes only the `tokens` array, each through the generated
`Token.serializer`. This made `dio` a direct dependency, pinned to the already-present 5.11.1.

**`getRoute` is unaffected** — it has been exercised live throughout and parses fine.

**26-06 must expect the same failure shape from `getStatus`.** Do not assume a generated operation
works because it compiles; call it against the live API early and be ready to fall back to the same
dio-plus-partial-deserialization pattern. The spec is a snapshot, not a contract.

### The requestId trap

`requestId` is **null in the response body**. It arrives as the **`x-request-id` response header**:

```
x-request-id: 80fa846bc50426fb4b890a1c111b693f
x-integrator-id: supergenius-…
```

`getStatus` needs it. The generated client returns dio's `Response<RouteResponseData>`, so
`response.headers.value('x-request-id')` reaches it — but any code reading
`RouteResponseData.requestId` gets null and polling silently breaks. **26-05 must take it from the
header.**

No `ratelimit-*` headers are returned, so the 1 RPS ceiling is not observable from a response.
Debounce on the client rather than reacting to a header that does not exist.

## Rate limits and the ID's lifecycle

Squid issues every new integrator ID at **1 RPS** (testing/development) and upgrades that same ID
to **10 RPS** for production on request (Discord or `support@squidrouter.com`). There is no
separate development and production ID — it is one ID with a tier upgrade.

1 RPS is a real constraint on the quote path: `getRoute(quoteOnly: true)` fires while the user
types. **Debounce it.** Do not fire per keystroke, or development will hit the limit constantly and
look like a bug in our code.

Undocumented, and asked of Squid: whether an ID can be rotated if it leaks, and whether one
organisation may hold several.

## Integrator fees exist and are modelled

Squid splits integrator-collected fees 50/50. `integrator_fee.dart` in the submodule carries
`address`, `percentage`, `flat`, optional `address2`/`percentage2`, `waivePlatformFee` and
`enabled`, and `fee_details.dart` surfaces it on the response.

`RouteRequest` has **no** `integratorAddress` field — its only custom param is
`jitoTipFeeInLamports` (Solana). So the fee is most likely configured server-side against the
integrator ID, not per request. Unconfirmed; asked of Squid.

Out of scope for this phase. Recorded because it is a revenue decision that is cheaper to make at
onboarding than to retrofit.

## No testnet

Squid docs: *"Currently Squid only supports mainnet since maintaining liquidity across testnets is
not feasible."* No testnet endpoint, no testnet integrator ID — never existed.

## Validation Architecture

What must be provable, and how, given no testnet exists:

| Dimension | Signal | Where |
|---|---|---|
| Request shape | `RouteRequest` serializes with the fields Squid expects, `quoteOnly` included | Unit test, no network |
| Response parse | A recorded real `/v2/route` body deserializes into `RouteResponseData` with a non-null `estimate` | Fixture test, no network |
| Quote display | Rate, price impact, fee and gas rendered on screen equal the parsed `estimate` values, not constants | Widget test against a fixture |
| No-lie invariant | **No toast, receipt, or Hive write occurs on any path that did not produce a tx hash** | Unit test over `_submitSwap`'s outcomes — the regression guard for the original bug |
| Allowance logic | `approve` is requested when allowance < amount and skipped when sufficient; requested amount equals `fromAmount`, never max | Unit test with a stubbed client |
| Error surfacing | Route failure, approve rejection, send failure and non-success terminal status each produce a distinct user-visible message and no stored row | Unit tests per branch |
| Live execution | One real swap on **Base mainnet 8453**; hash resolves on the explorer; stored row matches chain truth | Manual, recorded in the phase walk |

The first six need no funds and no integrator ID beyond a recorded fixture. Only the last does.

## Sources

- https://docs.squidrouter.com/getting-started/integrator-quickstart — integrator ID application
- https://docs.squidrouter.com/api-and-sdk-integration/api/swap-and-bridge-example.md — approve
  requirement, status polling parameters
- https://docs.squidrouter.com/additional-resources/additional-dev-resources/testnet-or-mainnet.md —
  mainnet-only statement
- https://docs.squidrouter.com/api-and-sdk-integration/key-concepts/collect-fees — integrator fee
  sharing, 50/50 split
