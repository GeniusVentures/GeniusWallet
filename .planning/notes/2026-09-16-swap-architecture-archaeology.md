---
title: Swap architecture archaeology & go-forward decision
date: 2026-09-16
context: /gsd-explore session — "this project originally intended to use squidrouter, but switched to a new cross-chain swapping system"
area: architecture
tags: [swap, squid, reown, walletconnect, bridge, symbiosis]
---

## The question

What cross-chain swap system did this project actually land on, after starting with SquidRouter?

## The short answer

**Reown WalletKit (WalletConnect v2) is the only swap execution path that ever shipped.**
Symbiosis Finance was *named* once as a contingency (a commit message in the `squidrouter`
submodule — zero code anywhere) and was never pursued. The Squid v2 Dart client was **finished
in the submodule but never wired into the app**; the in-app `/swap` tab runs on mocks to this day.

**Decision (2026-09-16, Jakub):** go-forward = **wire the finished Squid client for major
listed tokens** (ETH/USDC/POL/…); **GNUS cross-chain stays on the native burn→mint bridge**;
Reown remains as general dApp connectivity (it was never really a swap system — it is how
*any* dApp drives transactions through the wallet). Symbiosis is not pursued. Listing GNUS on
a third-party router is explicitly out of scope (it now requires a Squid "market maker loan"
+ BD relationship — a business workstream, not engineering).

## Timeline (recovered from git)

| When | Event |
|---|---|
| 2023-10-20 | Squid Router OpenAPI **V1** spec committed to the `squidrouter` submodule (`785d69e`) — original intent |
| 2025-05-11 → 05-31 | One-month sprint hand-building the **Squid v2 Dart client**: spec (`efa07bf`) → codegen → *"Fully working default-api-test.dart"* (`28489b7`). Mid-sprint, `ee95bf6` (05-26) names the escape hatch: *"…if we decide to switch to symbiosis.finance"* |
| post-sprint (PR #117 / #119) | **Reown WalletKit lands** (`825aac3b` "Wallet Connect support", `7c406150` "Add Buy / Swap (WIP)"). Wallet becomes a WC signing surface; dApps build swap txs and send `eth_sendTransaction`. `0b1fadc3` persists those as `TransactionType.swap` |
| 2026-07 (Phase 8) | The Squid **UI** is re-skinned into the polished `/swap` tab — service stays mocked. `c730c83f` records **GNUS is absent from Squid's catalogue** |
| 2026-08 (Phase 21) | `aaae5080` — the Reown swap result becomes a 031-B1 receipt |

## Current state — three swap-ish surfaces, one real

| Surface | Path | Status |
|---|---|---|
| **Reown dApp swaps** | `lib/reown/` (`handle_dapp_requests.dart` → approve drawers → `geniusApi`) | ✅ Real. dApp sends `eth_sendTransaction` over WC; wallet approves/signs. **Blind-signs**: calldata never decoded (`handle_dapp_requests.dart:44` TODO) — see todo `2026-09-16-decode-dapp-swap-calldata…` |
| **Squid swap tab** | `/swap` → `lib/squid_router/swap_screen.dart` | ⚠️ Hollow shell. `squid_token_service.dart` returns mocks (real calls commented out); `_submitSwap()` has `// TODO: invoke Squid API` and records a fake `completed` transaction with `hash: ""` — see todo `2026-09-16-wire-squid-token-service…` |
| **GNUS bridge** | `lib/dashboard/bridge/` | ✅ Real, separate thing: native burn→mint 1:1 via `bridgeOut(...)`. No router involved. This remains GNUS's cross-chain answer |

The finished-but-unwired Squid client lives in the `squidrouter/` submodule (auto-generated —
do not modify per AGENTS.md). `examples/squid_client_example.dart` shows the intended
integration shape: `Squid(config: SquidConfig(integratorId: …, apiKey: …))` → `init()` →
tokens/chains → balances → route.

## Provider landscape, researched 2026-09-16

*(Caveat: research agent's web search was rate-limited; findings come from direct fetches of
official vendor docs — solid on what the docs say, no independent news scan.)*

- **Squid Router**: healthy; API still free with an `x-integrator-id` header (1 RPS dev /
  10 RPS prod). Since 2025: Squid Intents (RFQ/market-maker routing, sub-5s), multi-bridge
  (Axelar/CCTP/Chainflip/LayerZero).
- **Symbiosis Finance**: alive and actively maintained (docs republished 2026-09-09); JS SDK
  deprecated, REST API is the integration path.
- **Custom app-chain token listing (e.g. GNUS)**: BD-driven on both — Squid now wants a
  "market maker loan" + direct contact (old Axelar ITS path deprecated); Symbiosis wants
  "additional review and setup." Neither is self-serve. This is why GNUS stays on the native bridge.
- **Reown's swaps product** (under Reown Payments) is a white-label via a third-party provider,
  aimed at dApps — not a wallet-side engine, not a shortcut for us.
- **integratorId**: only the placeholder `'test-api'` exists in the repo
  (`squidrouter/examples/squid_client_example.dart:9`). Jakub believes the team already holds
  a real one — confirm where it lives before wiring (see the wiring todo).

## Why this note exists

Before this session, the Symbiosis fact lived only in a submodule commit message and the
"what did we land on" answer lived nowhere. This note is the shared reference.
