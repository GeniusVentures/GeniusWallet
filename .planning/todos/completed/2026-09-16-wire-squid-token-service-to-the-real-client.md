---
created: 2026-09-16T00:00:00.000Z
title: Wire SquidTokenService to the real squidrouter submodule client
area: swap
priority: high
resolves_phase: 26
files:
  - lib/squid_router/squid_token_service.dart
  - lib/squid_router/swap_screen.dart
  - squidrouter/examples/squid_client_example.dart
---
> **Resolved 2026-09-17 by Phase 26.** The service this todo names was deleted rather than wired; the seam is `SwapProvider` → `SquidSwapProvider`, and every plan below landed and was walked on Base mainnet. `26-VERIFICATION.md` passed 33/33.

> **Roadmap split (2026-09-16, v2.0):** this todo is implemented across three phases —
> 26 (client init + catalogue), 27 (route/balances/slippage), 28 (real submit + honest
> recording). Tagged `resolves_phase: 26` as the entry point so phase-26 planning surfaces
> it; see ROADMAP.md `# Milestone v2.0`.

## Problem

The `/swap` tab **lies to users**. End to end it looks finished — polished Phase 8 skin,
route card, CTA ladder — but every network touchpoint is fake:

- `squid_token_service.dart`: `fetchTokens()`, `fetchBalances()` and `getRoute()` all return
  hardcoded mock data (`mockTokens`, `mockSquidBalances`, `mockSquidRoute`); the real HTTP
  calls sit commented out behind "restore this later when ready".
- `swap_screen.dart:307` (`_submitSwap()`): `// TODO: invoke Squid API` — nothing is executed.
- `_submitSwap()` then records a **fake `TransactionStatus.completed` transaction with
  `hash: ""`** and toasts success. A user who "swaps" here has swapped nothing and their
  transaction history says otherwise.

Meanwhile the **finished, working Squid v2 Dart client** sits unused in the `squidrouter/`
submodule (built May 2025; `28489b7` "Fully working default-api-test.dart").

**Decision context** (see `.planning/notes/2026-09-16-swap-architecture-archaeology.md`):
2026-09-16 go-forward = major listed tokens swap via Squid in-app; GNUS cross-chain stays on
the native bridge (`lib/dashboard/bridge/`); GNUS-on-a-router is out of scope.

## Solution

Wire the service to the real client and make submit real:

1. Replace the three mocked methods in `SquidTokenService` with calls into the
   `squidrouter/` submodule client. The integration shape is already demonstrated in
   `squidrouter/examples/squid_client_example.dart`:
   `Squid(config: SquidConfig(integratorId: …, apiKey: …))` → `await squid.init()` →
   `squid.tokens` / `squid.chains` / balances / route.
2. Implement `_submitSwap()` for real: take the fetched route, submit the transaction
   through the wallet's existing send path, and record the outcome from the actual result.
3. Delete the fake-completed-transaction recording — a failed or unsubmitted swap must never
   be persisted as `completed`.

### Constraints & facts to carry into the plan

- **Do not modify `squidrouter/`** — auto-generated submodule (AGENTS.md). Consume it as-is.
- **integratorId**: repo only contains the `'test-api'` placeholder
  (`squid_client_example.dart:9`). The team likely already holds a real integratorId
  (Jakub, 2026-09-16) — **confirm where it lives** and load it via config, not a hardcoded literal.
- **Rate limits**: free tier is 1 RPS dev / 10 RPS prod. The tab debounces quote fetches at
  500ms (`swap_screen.dart` `_debouncedFetchRoute`) — check burst behaviour against the limit.
- **GNUS is absent from Squid's catalogue** (recorded `c730c83f`). Accepted: the swap tab
  trades major tokens; GNUS cross-chain = the native bridge. Consider whether the token
  pickers should communicate that division.
- Existing D-09 contract (route-error → `—` + red notice + Retry, never a stale quote) must
  survive the switch from mock to real error sources.
