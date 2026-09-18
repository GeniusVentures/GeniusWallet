---
phase: 26
plan: 04
subsystem: swap
tags: [squid, catalogue, balances, provider-boundary, type-migration]
status: complete
requires: [26-02, 26-03]
provides: [swap-token-domain-type, live-catalogue, on-chain-balances]
affects: [lib/swap, lib/squid_router, packages/genius_api]
tech-stack:
  added: [dio (declared; already in the binary as squidrouter's transport)]
  patterns: [catalogue on the provider interface, injected provider as the test seam]
key-files:
  created: [lib/swap/swap_token.dart, test/swap/swap_token_test.dart, test/swap/live_catalogue_walk_test.dart, test/squid_router/swap_balances_wiring_test.dart]
  modified: [lib/swap/swap_provider.dart, lib/squid_router/squid_client.dart, lib/squid_router/squid_swap_provider.dart, lib/squid_router/swap_screen.dart, lib/squid_router/swap_field.dart, lib/squid_router/token_selector_drawer.dart, lib/squid_router/held_tokens.dart, lib/squid_router/swap_preselection.dart, lib/squid_router/swap_allowance.dart, packages/genius_api/lib/src/genius_api.dart]
  deleted: [lib/squid_router/models/squid_token_info.dart, lib/squid_router/models/squid_balance.dart, lib/squid_router/squid_token_service.dart, test/squid_router/squid_balance_test.dart]
decisions:
  - "SwapToken is a domain type, NOT a wrapper around the submodule's Token — the plan's shape would have put a Squid type on every widget signature. grep -rln 'package:squidrouter' lib/ still returns exactly 2."
  - "SquidTokenService is deleted rather than rewritten: a file holding getSDKInfo() would be a third squidrouter importer. The catalogue lives on SwapProvider.tokens."
  - "formattedBalance is now exact (formatTokenAmount) rather than float-formatted. MAX could previously ask for more than the wallet holds."
  - "SwapScreen takes its SwapProvider, defaulting to the real one. That is the whole test seam — the picker cases need no network and no credential."
metrics: {tasks: 3, commits: 5, completed: 2026-09-16}
actuals: {tokens: 34000, tasks: 3, commits: 5}
---

# Phase 26 Plan 04: The catalogue and the balances become real Summary

Every token on the swap screen comes from `/v2/sdk-info` filtered to the selected chain, every
balance from the chain or from the figure the wallet already displays, and `lib/squid_router/models/`
no longer exists. Net −516 lines across the migration commit.

## Deviations from Plan

**[Coordinator rule, binding] `SwapToken` does not wrap `Token`.** The plan asked for "a `SwapToken`
pairing the submodule's `Token` with a nullable `BigInt rawBalance`". That would have put a Squid
type on `SwapField`, `TokenSelectorDrawer` and `SwapScreen`, which the locked decoupling decision
forbids. `SwapToken` carries its own six fields; `SquidSwapProvider` maps `Token` onto it once.
The type and its test live in `lib/swap/` + `test/swap/`, mirroring 26-03, not in `lib/squid_router/`.

**[Rule 3 - Blocking] `getSDKInfo()` cannot parse the live response.** The generated
`GetSDKInfo200Response` rejects the whole payload because `EvmChain.enableBoostByDefault` arrives
null on a non-nullable field — verified against the real credential, twice. The submodule may not be
edited. Fix: read `/v2/sdk-info` off the generated client's own dio (base path, timeouts and the
integrator-ID interceptor all reused), then deserialize only `tokens`, each through the generated
`Token.serializer`. **26-06 should expect the same class of failure from `getStatus`.**
This made `dio` a direct dependency — declared at the locked 5.11.1, same sha256, already in the
binary; `pubspec.lock` changed by one line (`transitive` → `direct main`).

**[Rule 1 - Bug] `formattedBalance` rounded through a double.** It is what MAX puts in the amount
field, and for an 18-significant-digit holding the float expansion can land *above* the real
balance. Now `formatTokenAmount`, which 26-03 already had. `displayBalance` is untouched, so all
four walk magnitudes render exactly as before; the new test asserts the MAX round trip.

**[Rule 2] Provider-reported decimals are gated.** `isPlausibleDecimals` (0–36, integral) drops a
catalogue entry we cannot size, and `SwapToken.decimals` says in its doc that the value is the
aggregator's, not the contract's. This catches the absurd only — it cannot catch 16-for-18. Live
test asserts Squid reports GNUS at 18 on Base, so it notices if that changes.

**[Beyond the plan's file list]** `swap_allowance.dart` exposes `isNativeToken` instead of
duplicating its sentinel set; `genius_api.dart` gains a six-line `rawBalanceOf` wrapper so the
widget layer does not construct `Web3` itself; `squid_client_test.dart`'s fixture gained a seeded
network, because with none the screen now correctly has no chain to fetch for.

**Not done:** `route_details_card.dart` and its test needed no change — 26-03 had already made the
card take symbols. `display` was deleted rather than moved; nothing called it.

## Known wart

`lib/swap/swap_token.dart` imports `lib/squid_router/squid_util.dart` for `formatTokenAmount`. That
file holds no Squid type and never did, but the path inverts the layering. Moving it to `lib/swap/`
is a five-file import churn this already-wide plan did not take.

## Verification

Real output, this machine, this branch:

- `flutter test --no-pub` → **+1269 ~5, All tests passed!**, exit 0 (entering baseline measured here:
  1258 ~4, exit 0)
- `flutter analyze --no-pub` → "No issues found!", exit **0**, root AND `packages/genius_api`
- `dart format --set-exit-if-changed lib test` → exit 0; `tool/check_brace_style.sh --count` → `0`
- `grep -rn "SquidTokenInfo\|SquidBalance\|squid_router/models" lib/ test/` → **no hits**
- `grep -rln "package:squidrouter" lib/` → `squid_client.dart`, `squid_swap_provider.dart` — **2**,
  unchanged from the entering count
- `grep -rn "mockTokens\|mockSquidBalances\|return mock" lib/` → no hits; `ls lib/squid_router/models/`
  → no such directory
- Live, with the real credential: `live_catalogue_walk_test.dart` → **+1** (GNUS found on Base at
  decimals 18, every entry on chain 8453, no balances, cache holds); `live_quote_walk_test.dart` →
  **+1**, so 26-03's path did not regress under the client change

## Open for the human

The GUI walk. `flutter run -d windows --debug --dart-define-from-file=squid.local.json` on a **funded**
wallet: the pay picker should list only held tokens with real balances, the receive picker the chain's
full catalogue. `swap_balances_wiring_test.dart` proves that split headlessly against a stub chain —
five cases, including that one holding costs exactly one RPC round trip — but not the pixels, and not
against a real RPC node.

## Self-Check: PASSED

All four created files exist on disk. Commits `4d102d28`, `2772bf4a`, `3510cc64`, `e7b18d14`,
`6fcb89ce` all resolve. The four deletions in `e7b18d14` are exactly the planned ones.
