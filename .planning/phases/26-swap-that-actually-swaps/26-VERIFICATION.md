---
phase: 26-swap-that-actually-swaps
verified: 2026-09-17T18:11:18Z
status: passed
score: 33/33 must-haves verified
behavior_unverified: 0
overrides_applied: 0
---

# Phase 26: Swap that actually swaps — Verification Report

**Phase Goal:** Replace the mocked Squid layer with the real v2 API; no success shown for a swap that did not happen (ROADMAP.md line 112; success criteria from 26-CONTEXT.md)
**Verified:** 2026-09-17T18:11:18Z
**Status:** passed
**Re-verification:** No — initial verification

## Which goal was verified, and why

`gsd-tools query roadmap.get-phase 26` resolves to the v2.0 section's "Phase 26: Squid client foundation & live catalogue" (ROADMAP.md lines 1523/1531 — four criteria about config loading and pickers). That is not what this phase was built to. The phase directory name, all eight PLAN.md files, every commit subject on the branch and 26-CONTEXT.md target the v1-section entry at ROADMAP.md line 112, whose success criteria are the five items under 26-CONTEXT.md "## Success criteria". Those five, plus every PLAN's `must_haves.truths`, are what this report verifies. The v2.0 entry's four criteria are a strict subset of what was delivered (config-loaded ID, real client, live catalogue in the pickers, honest failure state) and are also satisfied — see Requirements Coverage. The duality itself is a planning-document observation, not a code gap.

## Goal Achievement

### Observable Truths — 26-CONTEXT.md success criteria

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| SC1 | A swap on a real network moves real funds, and the receipt's hash resolves on the explorer | ✓ VERIFIED | Walked 2026-09-17 on Base mainnet 8453 (26-06-SUMMARY): hash `0xc74e959425605f69b0782ef5822dfaaa2ad9d9fc416fa01f9b426da9135b27f7`, block 51436394, 12.290107 USDC received vs 12.338322 quoted (-0.391%, inside 0.5% slippage). Code path: `swap_screen.dart:441` `widget.execute(...)` → `swap_execution.dart` `executeSwap` → `SquidSwapProvider.buildTransaction` (`quoteOnly: false`) → `api.signAndSendTransaction` → `_poll` → `SwapBroadcast`. Human-check accepted as satisfied per orchestrator instruction. |
| SC2 | No success toast, receipt or stored transaction unless a hash came back | ✓ VERIFIED | `swap_execution.dart:97-114` `sideEffectsFor` is an exhaustive switch — only `SwapBroadcast` (the sole shape with a `hash` field) returns any `true`. `swap_screen.dart:500-503` `_applyOutcome` returns early on `!effects.storeRow` before any `addTransaction` / `showToast` / `showTransactionDetails`. Tested at the pure layer (`swap_execution_test.dart:306` "THE GUARD") and the screen layer (`swap_submit_test.dart:226` "stores nothing and claims nothing" over three no-hash shapes, asserting `storage.writes` is empty). Both ran green in this verification. `grep -rn 'hash: ""' lib/` → nothing. |
| SC3 | A failed or rejected swap leaves no row in Hive and tells the user what happened | ✓ VERIFIED | `swap_messages.dart` maps each of the five no-hash shapes to distinct copy, no default arm, no interpolated error (`swap_messages_test.dart:81,94`). `_reportFailure` (`swap_screen.dart:589`) sets `submitFailure`, clears the quote, shows the error toast. Screen test "names itself on screen" per shape passed. Walked 2026-09-17 (26-07-SUMMARY): underfunded native send → "The swap could not be sent. Check that you have enough to cover gas…", no row written, form usable. |
| SC4 | Quote, rate, price impact and fees come from the live route, not a constant | ✓ VERIFIED | `SquidSwapProvider.quote` POSTs `/v2/route` over the generated client's dio with the integrator-ID interceptor; `squidQuoteFromJson` reads `estimate.exchangeRate/aggregatePriceImpact/toAmount/feeCosts/gasCosts`. Data flow: `widget.provider.quote(request)` (`swap_screen.dart:373`) → `fetchedQuote` → `RouteDetailsCard(quote: fetchedQuote!)` (`:1010`) → `formatPercent(quote.priceImpact)`, `quote.totalCostUsd`. `grep -rn "993.72" lib/` → nothing. Mapping pinned against four recorded real bodies (`squid_quote_mapping_test.dart`, `route_wrap_drift_test.dart`); `live_quote_walk_test.dart` hits the real API when the credential is defined (skips otherwise, by design). |
| SC5 | `SquidTokenService` contains no `mock*` return and no commented-out HTTP | ✓ VERIFIED | The file no longer exists (`grep -rn SquidTokenService lib/` → nothing; deleted in `e7b18d14`). `grep -rniE "^\s*return mock" lib/squid_router/` → nothing; `grep -rniE "mockTokens\|mockSquid\|testnet\.api\|_baseUrl" lib/squid_router/ lib/swap/` → nothing. `ls lib/squid_router/models/` → no such directory. |

### Observable Truths — PLAN must_haves (deduplicated against the five above)

| # | Plan | Truth | Status | Evidence |
|---|------|-------|--------|----------|
| 6 | 01 | App code constructs a Squid v2 client and resolves getRoute/getStatus/getSDKInfo without a network call | ✓ VERIFIED | `squid_client.dart` builds `Squidrouter()..setApiKey('IntegratorId', …)` once; `squid_client_test.dart:118-130` asserts v2 host and call resolution, no network. |
| 7 | 01 | The integrator ID comes from the build environment; no literal checked in | ✓ VERIFIED | `const String kSquidIntegratorId = String.fromEnvironment('GW_SQUID_INTEGRATOR_ID')` — the only read site. `grep -rn "test-api" lib/ test/` → nothing. `squid.local.json` matched by `.gitignore:82 *.local.json`; no `*.local.json` tracked. |
| 8 | 01 | With no integrator ID the screen says unavailable, CTA cannot be tapped, no call attempted | ✓ VERIFIED | `swap_screen.dart:161-168` skips `_loadTokens` and clears `isLoading`; `:682` renders the disabled "Swap unavailable" CTA. `squid_client_test.dart:143` "renders the CTA as unavailable and reaches for nothing" passed. |
| 9 | 02 | ERC-20 allowance readable, raw base units | ✓ VERIFIED | `web3.dart:254` `allowance` returns `BigInt`, no decimals division; ABI entry at `:48`; `erc20_abi_test.dart`. `GeniusApi.allowance` wrapper at `genius_api.dart:1191`. |
| 10 | 02 | Approval requested only when short, for exactly the swap amount | ✓ VERIFIED | `swap_allowance.dart` `decideApproval` — `ApproveExactAmount` has a private constructor and one caller. `swap_allowance_test.dart:108,120` ("equals the swap amount exactly", "never uint256 max"). `grep` for `maxUint|ffff…` in `lib/squid_router/ lib/swap/` → nothing. |
| 11 | 02 | Native token needs no approval, no call made | ✓ VERIFIED | `executeSwap` skips `readAllowance` for `isNativeToken`; `swap_execution_test.dart:133` "the native coin is never approved and never read". |
| 12 | 02 | A failed approve returns its own error, not a generic string | ✓ VERIFIED | `web3.dart:590-593` `catch (e) { return ApiResponse.error(e.toString()); }` — contrast `executeBridgeOutTransaction` at `:540` which drops it. `approve_error_test.dart`. |
| 13 | 02 | Raw token balance readable as an exact integer | ✓ VERIFIED | `web3.dart:291` `rawBalanceOf` → `BigInt`; used at `swap_screen.dart:283`. |
| 14 | 03 | Amount sent to Squid is the typed amount in the pay token's base units | ✓ VERIFIED | `squid_util.dart:4` `toBaseUnits` is String/BigInt only (the `double` hits in that file are `formatPercent`, display-side); `quoteRequest` feeds `fromAmount: fromAmountUnits`; `_routeBody` sends `request.fromAmount.toString()`. `squid_util_test.dart`. |
| 15 | 03 | Rate/impact/fees read off the returned estimate; a recorded real body deserializes with non-null estimate | ✓ VERIFIED | `route_parse_test.dart` against `route_response.json`; `route_response.json`/`_cross_chain.json` assert `fromAddress`/`toAddress` are all-zero (confirmed by grep: only `0x000…` on those keys; `_wrap.json` uses `0x111…`). Other 40-hex strings in fixtures are token/router contract addresses (USDC, WETH, GNUS, Squid router), not wallets. |
| 16 | 03 | No quote path can produce a transactionRequest — every quote call is quoteOnly | ✓ VERIFIED | `SquidSwapProvider.quote` sends `'quoteOnly': true` and returns `SwapQuote`, which has no request field; only `buildTransaction` sends `quoteOnly: false`. |
| 17 | 04 | Token list comes from Squid's live catalogue filtered to the selected chain | ✓ VERIFIED | `_fetchCatalogue` GETs `/v2/sdk-info`, deserializes each entry via the generated `Token.serializer`, drops disabled/implausible-decimals; `tokens(chainId)` filters. Cached once per session (`_pendingCatalogue`), failure not cached. `live_catalogue_walk_test.dart` (skips without credential). |
| 18 | 04 | Pay side offers only tokens the wallet holds, decided from a real on-chain balance | ✓ VERIFIED | `swap_screen.dart:255-291` reads `rawBalanceOf` only for catalogue entries whose address is in `wallet.coins`; native from `nativeCoinBaseUnits(wallet.coins, …)`. `held_tokens.dart:27` `hasSpendableBalance` — absent is unspendable, dust is. `swap_balances_wiring_test.dart` (6 cases incl. "reads are bounded to the holdings") passed. |
| 19 | 04 | Balance renders identically for dust, floor, 18-digit fraction, 13-digit whole | ✓ VERIFIED | `swap/swap_token_test.dart` carries the four magnitude fixtures; passed. |
| 20 | 04 | `lib/squid_router/models/` gone; no fabricated token or balance list under lib/ | ✓ VERIFIED | Directory absent; `grep -rn "SquidTokenInfo\|SquidBalance\|squid_router/models" lib/ test/` → nothing. |
| 21 | 05 | Exactly one SwapOutcome shape carries a hash; side-effect triple all-false otherwise; runnable test | ✓ VERIFIED | `sealed class SwapOutcome` with six shapes; only `SwapBroadcast` has `hash`. `swap_execution_test.dart:306-357` passed. |
| 22 | 05 | Submitting re-fetches the route without quoteOnly; the displayed quote is never signed | ✓ VERIFIED | `swap_screen.dart:444` `fetchRoute: () => widget.provider.buildTransaction(request)`; `SwapQuote` is unsignable by type. |
| 23 | 05 | Hash-bearing outcome carries the status Squid reported, or pending on timeout — never assumed | ✓ VERIFIED | `_poll` loops to the bound, terminal via `isTerminal`, returns `SwapSettlement`; `walletStatusFor` maps `ongoing/notFound → pending`. Tests `swap_execution_test.dart:194-246,272-304` passed. Live drift handled: a 404 for an unindexed tx is caught as "not yet" and the hash is kept. |
| 24 | 06 | A broadcast swap stores a row keyed by its real hash, pending first, then resolved | ✓ VERIFIED | `swap_screen.dart:534-539` two `addTransaction` calls under `broadcast.hash`. `swap_submit_test.dart:341` "writes pending first, then the resolved status, one key" passed. Behaviour-dependent truth — covered by a passing behavioural test. |
| 25 | 06 | The fabricated Transaction, unconditional toast and their TODO markers no longer exist | ✓ VERIFIED | `grep -n "TODO" lib/squid_router/swap_screen.dart` → nothing; no `Transaction(hash: "")` anywhere in `lib/`. |
| 26 | 07 | Route failure, unsignable route, approval failure, send failure, non-success terminal status each produce a different message | ✓ VERIFIED | Six shapes → six strings; `_settledMessage` per `TransactionStatus`. `swap_messages_test.dart:81` collects into a set. |
| 27 | 07 | No generic fallback string, no two branches identical | ✓ VERIFIED | Both switches have no default arm; a new shape is a compile error (`sealed`). |
| 28 | 07 | With no integrator ID the swap says unavailable rather than a network error | ✓ VERIFIED | Same gate as #8; `_loadTokens` never runs so no 401 can surface as a route error. |
| 29 | 07 | `lib/squid_router/` holds no fabricated data and no commented-out HTTP | ✓ VERIFIED | Greps in SC5; `git diff --stat 9b4d8225..HEAD -- squidrouter/` and across the whole branch → empty; `git submodule status` unchanged. |
| 30 | 08 | A paused swap offers the link the API returned; no link → no button, never composed | ✓ VERIFIED | `SquidSwapProvider.status` captures `body['axelarTransactionUrl']`; `SwapBroadcast.recoveryUrl` → `Transaction.recoveryUrl` (`@HiveField(17)`, appended). `grep -rniE "axelarscan\|/gmp/" lib/ --exclude-dir=dev` → nothing. `transaction_recovery_states_test.dart:203` "opens the STORED link, not a composed one" passed. |
| 31 | 08 | None of the three states prints the enum name; each says where the money is | ✓ VERIFIED | `transaction_utils.dart:390` `statusWordFor` — Paused/Partial/Refunded; note function `:404`; tests iterate every enum value (`:100`). |
| 32 | 08 | No new colour token; tones are pairs the theme already proves | ✓ VERIFIED | 26-08 diff adds no `Color(`/`Colors.` in `lib/dashboard/home/widgets/`; needsGas reuses pending pair, refunded the cancelled pair. |
| 33 | 08 | Each new state reachable from a filter that already ships; no new chip | ✓ VERIFIED | `transactions_slim_view.dart:111-113` folds the three into the existing failed set; `transaction_filters_test.dart` passed. |

**Score:** 33/33 truths verified (0 present, behaviour-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/squid_router/squid_client.dart` | Client factory keyed on build-time ID | ✓ VERIFIED | 41 lines; `kSquidIntegratorId`, `squidConfigured`, `squidApi()`, `squidDio()`; imported by the adapter and the screen. |
| `lib/squid_router/swap_allowance.dart` | Pure approval rule | ✓ VERIFIED | Used by `executeSwap` and the screen's native check. |
| `lib/squid_router/swap_execution.dart` | Pure orchestrator + sealed outcome | ✓ VERIFIED | No `package:flutter`/`BuildContext` import (grep confirmed). Used at `swap_screen.dart:87,441`. |
| `lib/squid_router/swap_messages.dart` | Outcome → copy | ✓ VERIFIED | Used at `swap_screen.dart:547,590`. |
| `lib/squid_router/squid_swap_provider.dart` | The only Squid-typed adapter | ✓ VERIFIED | `grep -rln "package:squidrouter" lib/` → exactly `squid_client.dart`, `squid_swap_provider.dart`. |
| `lib/swap/{swap_provider,swap_quote,swap_token,swap_transaction}.dart` | Provider-neutral domain types | ✓ VERIFIED | No Squid type crosses the boundary. |
| `test/squid_router/fixtures/route_response{,_cross_chain,_executable,_wrap}.json` | Recorded real bodies | ✓ VERIFIED | Wallet addresses redacted (all-zero / 0x111…); executable fixture has `transactionRequest.target` and type `ON_CHAIN_EXECUTION`. |
| `test/squid_router/swap_execution_test.dart`, `swap_submit_test.dart`, `swap_messages_test.dart`, `route_parse_test.dart`, `swap_allowance_test.dart`, `erc20_abi_test.dart` | Regression guards | ✓ VERIFIED | All ran green in this verification. |
| `test/dashboard/transaction_recovery_states_test.dart` | Recovery-state coverage | ✓ VERIFIED | Ran green. |
| `packages/genius_api/lib/web3/web3.dart`, `src/genius_api.dart` | allowance / approve / rawBalanceOf | ✓ VERIFIED | Present on both layers; no key logging (`grep … | grep -iE "print|log"` → nothing). |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `squid_client.dart` | Squid API auth | `setApiKey('IntegratorId', …)` + `kSquidAuthExtra` on every raw-dio call | ✓ WIRED | Each `squidDio()` call passes `Options(extra: kSquidAuthExtra)`. |
| `swap_screen.dart` `_fetchRoute` | `/v2/route` quoteOnly | `widget.provider.quote(request)` | ✓ WIRED | Single provider seam; the 26-06 half-wired global was fixed (`swapProvider` now only appears as the constructor default). |
| `swap_screen.dart` `_submitSwap` | `executeSwap` | `widget.execute(...)` with real `api.allowance/approve/signAndSendTransaction`, `widget.provider.buildTransaction/status` | ✓ WIRED | Lines 441-472. |
| `executeSwap` | `sideEffectsFor` | `_applyOutcome` reads it and returns on `!storeRow` | ✓ WIRED | No re-derivation from outcome type on the screen. |
| `_applyOutcome` | Hive | `widget.storage.addTransaction(walletAddress, row)` ×2, same key | ✓ WIRED | `TransactionStorageService.addTransaction` = `box.put(tx.hash, tx)`. |
| `SquidSwapProvider.status` | `Transaction.recoveryUrl` | `SwapSettlement.recoveryUrl` → `SwapBroadcast.recoveryUrl` → `rowWith(...)` | ✓ WIRED | Persisted at `@HiveField(17)`. |
| `RouteDetailsCard` | live estimate | `quote: fetchedQuote!` | ✓ WIRED | Level-4 trace: dio response → `squidQuoteFromJson` → state → render. No static fallback. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|--------------------|--------|
| `RouteDetailsCard` | `quote.priceImpact`, `quote.totalCostUsd`, `toAmount` | `POST /v2/route` (quoteOnly) | Yes | ✓ FLOWING |
| `TokenSelectorDrawer` (pay side) | `heldTokens(...)` | `GET /v2/sdk-info` ∩ `wallet.coins` + `rawBalanceOf` RPC | Yes | ✓ FLOWING |
| `TokenSelectorDrawer` (receive side) | catalogue | `GET /v2/sdk-info` | Yes | ✓ FLOWING |
| Transaction row / receipt | `Transaction` under real hash | `signAndSendTransaction` → `/v2/status` | Yes | ✓ FLOWING |
| Unavailable CTA | `widget.swapAvailable` | `String.fromEnvironment` | n/a (gate) | ✓ FLOWING |

### Behavioral Spot-Checks

Ran in this verification (real output, `PATH` prefixed with the pinned Flutter SDK):

| Behaviour | Command | Result | Status |
|-----------|---------|--------|--------|
| Phase test surface | `flutter test --no-pub test/squid_router/ test/swap/ test/dashboard/transaction_recovery_states_test.dart test/assets/networks_native_currency_test.dart` | `+225 ~2: All tests passed!`, exit 0 (the 2 skips are the two live-API walks, gated on `squidConfigured`) | ✓ PASS |
| Analyzer, root | `flutter analyze --no-pub` | "No issues found!", exit 0 | ✓ PASS |
| Analyzer, package | `cd packages/genius_api && flutter analyze --no-pub` | "No issues found!", exit 0 | ✓ PASS |
| Format | `dart format --set-exit-if-changed --output=none lib test` | exit 0 | ✓ PASS |
| Brace style | `bash tool/check_brace_style.sh --count` | 0 | ✓ PASS |
| Fabricated-success bug | `grep -rn 'hash: ""' lib/`; `grep -rn "993.72" lib/` | both empty | ✓ PASS |
| Mock service | `grep -rniE "^\s*return mock" lib/squid_router/`; `grep -rn SquidTokenService lib/`; `ls lib/squid_router/models/` | empty / empty / no such directory | ✓ PASS |
| Submodule untouched | `git diff --stat 9b4d8225..HEAD -- squidrouter/`; same from the branch's merge-base; `git status --short squidrouter` | all empty | ✓ PASS |
| Provider boundary | `grep -rln "package:squidrouter" lib/` | exactly 2 adapter files | ✓ PASS |
| Composed recovery link | `grep -rniE "axelarscan\|/gmp/" lib/ --exclude-dir=dev` | empty | ✓ PASS |
| Credential hygiene | `git ls-files \| grep -i local.json`; `git check-ignore -v squid.local.json` | none tracked; ignored by `.gitignore:82` | ✓ PASS |

The executor's full-suite baseline (1364 pass / 5 skip / 0 fail, exit 0) was not re-run in full; the 225-test phase surface above plus the clean analyzers are this verification's own evidence.

### Probe Execution

No `scripts/*/tests/probe-*.sh` in this repo and none declared by any plan. Not applicable.

### Deviations found outside the plans (26-FINDINGS.md) — all present and tested

| # | Defect | Fix commit | Code present | Test present |
|---|--------|-----------|--------------|--------------|
| 1 | Base native coin labelled BASE, priced $0 | `0e1e8a13` | `Network.nativeSymbol`; `networks.json` 8453 → `nativeSymbol: eth`, `coinGeckoId: ethereum` | `test/assets/networks_native_currency_test.dart` (3 cases) |
| 2 | Swap screen read the USD total as an ETH quantity | `7d896632` | `nativeCoinBaseUnits()` reads `Coin.balance` of the address-less holding; `selectedWalletBalance` never read as a quantity | `swap_balances_wiring_test.dart` "takes its own quantity, not a fiat total" (fixture seeds a fiat-shaped total) |
| 3 | Generated model rejects any route with a `wrap` action (native same-chain swap unquotable) | `cf042c1b` | `SquidSwapProvider.quote` reads raw dio + `squidQuoteFromJson` | `route_wrap_drift_test.dart` (6 cases, incl. "the generated model still rejects" so the bypass cannot be quietly removed) |
| 4 | Price impact printed at aggregator precision | `b6155460` | `formatPercent` in `squid_util.dart` | `squid_util_test.dart` |
| 5 | Receive side jumped ~976px on route failure | `70a16d98` | `swap_field.dart` slot is `Expanded` | `swap_field_placeholder_layout_test.dart` |
| 6 | Completed swap left its spent quote seated | `42a3a042` | `_applyOutcome` clears amounts/quote after a stored row | `swap_submit_test.dart:311` "the form clears, so a spent quote cannot be sent twice" |

### Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
|-------------|--------------|-------------|--------|----------|
| SWAP-01 crit. 1 | 26-01 | Integrator ID from configuration; unconfigured build reports unavailable | ✓ SATISFIED | Truths #7, #8 |
| SWAP-01 crit. 2 | 26-04 | Both pickers list the live catalogue | ✓ SATISFIED | Truth #17 |
| SWAP-01 crit. 3 | 26-02, 26-04 | Balances real; pay side offers only what is held | ✓ SATISFIED | Truths #13, #18 |
| SWAP-01 crit. 4 | 26-03 | Live route quote honouring D-09 | ✓ SATISFIED | SC4; D-09 path at `swap_screen.dart:379-401` intact; `_reportFailure` reuses it |
| SWAP-01 crit. 5 | 26-03 | Slippage feeds the live request | ✓ SATISFIED | `quoteRequest` → `slippage: slippage` → `_routeBody['slippage']` |
| SWAP-01 crit. 6 | 26-03, 26-04 | 1000 ms debounce; catalogue cached | ✓ SATISFIED | `swap_screen.dart:410`; `_pendingCatalogue` |
| SWAP-01 crit. 7 | 26-05, 26-06 | Submit re-fetches executable route and broadcasts via the wallet's send path | ✓ SATISFIED | Truth #22, SC1 (walked) |
| SWAP-01 crit. 8 | 26-05, 26-06, 26-07 | Recorded only from the actual result; every side effect behind `sideEffectsFor` | ✓ SATISFIED | SC2, SC3 |
| v2.0 "Phase 26" SC 1-4 | — | config-loaded ID / real client / live pickers / honest fetch-failure state | ✓ SATISFIED | Subset of the above; fetch failure keeps the shipped error toast + empty list (`swap_screen.dart:243`) |

No orphaned requirements: REQUIREMENTS.md maps only SWAP-01 to phase 26.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/squid_router/swap_screen.dart` | 491-493 | Doc comment on `_applyOutcome` reads "26-07 owns what the user is told instead; until then the shipped route-error path is what speaks" — cites a plan number in source (AGENTS.md forbids) and is stale now that 26-07 landed and `_reportFailure` speaks. Added in `5bc269ae`. | ⚠️ Warning | Cosmetic; misleads a reader, changes no behaviour. Three-line fix. |
| `lib/reown/handle_dapp_requests.dart` | 147-173 | Four pre-existing `TODO`s | ℹ️ Info | Predate the phase (present at `cdd5bfaf`); the phase only added `const` at line 200. Not phase debt. |
| `lib/squid_router/swap_screen.dart` | 605 | `_buildRouteErrorNotice` helper method (AGENTS.md prefers a widget) | ℹ️ Info | Pre-existing D-09 code, untouched by this phase. |
| `lib/squid_router/swap_screen.dart`, `lib/swap/swap_token.dart` | 60, — | Two `ponytail:` markers (Coin.balance is a double; 6-decimal display cap) | ℹ️ Info | Correctly labelled deliberate simplifications with named ceilings. |

No `TBD`/`FIXME`/`XXX` in any phase-touched file. No blockers.

### Human Verification Required

None. Every `<human-check>` in the eight plans was walked on 2026-09-17 on Base mainnet 8453 with a real wallet and is recorded with concrete evidence in 26-06-SUMMARY (real swap, hash above), 26-07-SUMMARY (underfunded send) and 26-08-SUMMARY (three recovery states, both appearance modes). Per the orchestrator's instruction those are accepted as satisfied; nothing else in the phase asserts behaviour a test does not exercise.

### Observations (not gaps)

1. **Roadmap duality.** ROADMAP.md carries two "Phase 26" entries (line 112, v1 section, the one built; lines 1523/1531, v2.0 section, a narrower foundation-only slice). `gsd-tools query roadmap.get-phase 26` returns the v2.0 one. The v2.0 phases 27 and 28 describe work this phase already delivered (live quotes; real execution and honest recording). Planning docs need reconciling; the code is not affected.
2. **REQUIREMENTS.md is stale**: SWAP-01 criterion 7 still says "Code complete, never walked" and the v2.0 table says "unwalked" — both superseded by the 2026-09-17 walk.
3. **MAX does not reserve gas** (26-07 walk): the form offers the full native balance and lets the send fail with an honest message. Whether the 26-06 swap's leftover ~0.0000169 ETH came from Squid trimming or from a non-round balance is still unresolved, per both summaries. Outside this phase's success criteria; worth a todo, not a gap here.
4. **Fifth live-API drift** in the generated `squidrouter` client (wrap routes). All four endpoints now read raw dio; the generated models are used only for `Token` and `RouteRequest` serialization and for the drift-detection test. If the submodule is ever regenerated, `route_wrap_drift_test.dart` says whether the bypass is still needed.
5. Two live-API tests (`test/swap/live_*_walk_test.dart`) are skipped without `GW_SQUID_INTEGRATOR_ID` by design; the executor ran them green with the credential on 2026-09-16.

### Gaps Summary

None. The phase goal — a swap either moves real funds or says why it could not, with no success shown for a swap that did not happen — is achieved in the codebase: the fabricated `completed`/`hash: ""` record and its unconditional toast are gone, every side effect sits behind an exhaustive `sideEffectsFor` guarded at both the pure and screen layers by passing tests, the quote/catalogue/balances/status all come from the network or the chain, the mock service no longer exists, and one real swap on Base mainnet has been walked end to end with its hash recorded. The single warning (a stale plan-citing doc comment) is cosmetic.

---

_Verified: 2026-09-17T18:11:18Z_
_Verifier: Claude (gsd-verifier)_
