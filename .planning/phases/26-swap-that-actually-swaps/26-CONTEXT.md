---
phase: 26
name: Swap that actually swaps
status: unblocked
created: 2026-09-16
---

# Context

## The problem

`swap_screen.dart:301` `_submitSwap` never calls Squid. It fabricates a `completed` Transaction,
shows a success toast, opens the receipt and writes the row to Hive. The service beneath it returns
`mockTokens` / `mockSquidRoute` at a constant rate of 993.72. None of it is behind `kDebugMode`, so
in a release build a user swaps, sees a green receipt and a permanent transaction row, and no funds
move.

A working generated Squid v2 client has been in the repo the whole time as the unused `squidrouter`
submodule. See `26-RESEARCH.md`.

## Decisions locked

- **Use the `squidrouter` submodule.** Do not hand-roll against `http`. Add it as
  `squidrouter: {path: squidrouter}`. Accepted cost: pulls in `dio`, `built_value`,
  `built_collection`, `one_of` — a second HTTP client in the binary.
- **The swap provider must be replaceable.** Squid may be swapped for another aggregator later, so
  no Squid type may escape the adapter. The rule, enforceable by grep:
  **`import 'package:squidrouter/...'` appears in at most the adapter files. No widget, screen,
  orchestrator or shared helper names a Squid type.**
  - Domain types are ours: `SwapQuote`, `SwapToken`, a swap status — named for the domain, never
    `Squid*`. A quote carries what the UI renders (rate, price impact, amounts in base and display
    units, fee and gas summaries, duration), not a passthrough of `route.estimate`.
  - `abstract interface class SwapProvider` is the boundary: quote, build-transaction, status,
    all returning our types. `SquidSwapProvider implements SwapProvider` is the only thing that
    knows `RouteRequest`, `RouteResponseData` or `Estimate` exist.
  - Mapping happens **once**, at the adapter. Nothing downstream re-reads `route.estimate.*`.
  - The `lib/squid_router/` directory is NOT renamed — folder churn would collide across plans.
    What matters is the type boundary, not the layout. Interface and domain types live in
    `lib/swap/`.
  - Decided 2026-09-16, mid-execution of 26-03, after the coupling was observed spreading:
    `squid_token_service.getRoute` had taken `RouteRequest` and returned `RouteResponseData`, and
    `swap_screen.dart` imported `package:squidrouter` directly.
- **Delete `lib/squid_router/models/`.** It duplicates the submodule's generated models, badly.
  Rewriting them was considered and rejected — they should not exist.
- **The integrator ID goes in `--dart-define`**, read via `String.fromEnvironment`, empty default →
  swap reports itself unavailable. Follow `dev_flags.dart:15`. It is compiled into the binary in
  plain text; do not write a comment claiming otherwise.
- **Approve the exact amount, never `uint256.max`.** A standing unlimited allowance to a router
  contract is how drained-wallet incidents happen. The extra signature per swap is the right trade.
- **No visual design changes.** Phase 8 owns the swap skin. A state needing a screen that does not
  exist is a Phase 8 finding, not a redesign here.
- **`swap_cta_state.dart` is reused as-is.** The CTA ladder was never the problem.

## Dependency audit — approved 2026-09-16

The path dependency adds exactly **5** new pub.dev packages (plus the local `squidrouter` itself).
All five sha256 hashes match what pub.dev serves today; none retracted; each locked version is the
current latest; nothing resolved outside what the submodule declares. Dart has no `postinstall`
equivalent and none of the five ships a build hook, native asset or binary.

| Package | Publisher | Verdict |
|---|---|---|
| `dio` 5.11.1 | flutter.cn (verified) | fine — 4.2M downloads/30d |
| `dio_web_adapter` 2.2.2 | flutter.cn (verified) | fine — same repo as dio, mandatory split-out |
| `quiver` 3.2.2 | google.dev (verified) | fine |
| `one_of` 1.5.0 | bdaya-dev.com | **approved with reservations** |
| `one_of_serializer` 1.5.0 | bdaya-dev.com | **approved with reservations** |

**The `one_of` pair is the accepted risk.** 802 LOC combined, last published 2022-05-10, 3 and 0
likes. Its 235k monthly downloads are not independent scrutiny — they are OpenAPI Generator's
`dart-dio` template emitting the dependency into every generated client, ours included. Accepted
because both packages import **zero `dart:` libraries** (verified), so they have no filesystem or
network surface at all, and `pubspec.lock` pins them exactly.

**Known fragility, accepted:** `one_of` declares `sdk: '>=2.12.0 <3.0.0'`, which excludes Dart
3.11.5 on its face. It resolves only because pub rewrites that upper bound to `<4.0.0` for
pre-Dart-3 packages. If that leniency is ever withdrawn, an abandoned package becomes a hard
blocker and the fix is a fork or a vendor. Revisit then, not now.

**No existing dependency is upgraded** — `built_value` and `built_collection` were already in the
lock as transitives. The change is purely additive.

## Status mapping — DECIDED 2026-09-16

Squid reports seven states; `TransactionStatus` had four. **Extend the enum and show the real state
to the user, with a recovery action wherever one exists.** Mapping a state that moved money onto
"completed" or "failed" is a smaller version of the lie this phase exists to remove.

| Squid | Ours | Where the money is | What the user can do |
|---|---|---|---|
| `SUCCESS` | `completed` | Arrived as requested | — |
| `ONGOING` | `pending` | In transit | Wait |
| `NOT_FOUND` | `pending` | Almost certainly fine, not yet indexed | Wait |
| `NEEDS_GAS` | **`needsGas`** (new) | Held in the bridge contract — gas spiked on the destination chain and execution paused | **Add gas on Axelarscan.** The deep link is `StatusResponse.axelarTransactionUrl`, returned by the API — give the real link, never a generic one |
| `PARTIAL_SUCCESS` | **`partialSuccess`** (new) | Destination step reverted. On Axelar routes the user holds **axlUSDC on the destination chain**; on Intents routes the RFQ bridge token is refunded on the **source** chain | Tell them exactly which token arrived and on which chain. Nothing is lost; it is the wrong asset |
| `REFUND` | **`refunded`** (new) | Returned automatically to `order.fromAddress`, usually within ~10 minutes | Nothing — informational, but say so plainly rather than leaving a stuck row |

**Hive safety:** the three new values are **appended** with new `@HiveField` indices (4, 5, 6).
Existing indices 0-3 are never renumbered, so stored transactions keep deserializing.

**Blast radius, measured:** 13 files reference `TransactionStatus.*`; 4 carry switches without a
default arm. Adding values turns those into compile errors, which is the desired outcome — the
compiler finds every render site rather than a default arm silently swallowing a new state.

**These are not "failures".** 26-07 handles failures that leave **no stored row**. All three of
these states have a real transaction and real money somewhere, so they get a stored row and their
own treatment — see plan 26-08.

## Scope fence

In scope: the Squid client wiring, the quote path, ERC-20 allowance/approve, execution, status
polling, and the error states those produce.

Out of scope: the swap screen's layout and styling; Bridge; the Banxa key; the dead Base chain ID
(`11-FINDINGS.md` F-01); the swallowed bridge error (F-03) **except** that `approve()` must not
inherit it.

## Credential — RECEIVED 2026-09-16

The integrator ID is in **`squid.local.json`** at the repo root, gitignored via `*.local.json`.
Never commit it. Run with:

```
flutter run -d windows --debug --dart-define-from-file=squid.local.json
```

Verified live against `POST /v2/route` on Base 8453 — HTTP 200, real quote. See `26-RESEARCH.md`.
Quoting works at the default 1 RPS tier; request the 10 RPS production upgrade before shipping.

## Still worth asking Squid

Application already submitted. These remain open and are not blocking:

**One ID is enough — there is no dev/prod split.** Squid issues every new ID at **1 RPS**
(testing/development) and upgrades that *same* ID to **10 RPS** for production on request via
Discord or `support@squidrouter.com`. Applying now costs nothing later; there is no second
application and no migration.

### Send these five questions with the application

1. **Can an integrator ID be rotated or replaced if it leaks?** Undocumented, and it matters here:
   the ID ships in plain text inside the binary (see the `--dart-define` decision above), so it is
   extractable by anyone with the app. This is the difference between a leak being an inconvenience
   and a leak being permanent. Highest-value question on this list.
2. **Must the ID be kept secret?** If yes, the architecture changes — a client app cannot hold a
   secret, and it would need a proxy service in front. We are assuming it is an identifier, like a
   Reown project ID.
3. **Integrator fee sharing — how is it configured, and what does onboarding require?** Squid
   splits integrator-collected fees 50/50. The generated client models it
   (`squidrouter/lib/src/model/integrator_fee.dart`: `address`, `percentage`, `flat`, plus
   `address2`/`percentage2`, `waivePlatformFee`, `enabled`) — but `RouteRequest` has **no**
   `integratorAddress` field, so it appears to be configured **server-side against the ID** rather
   than per request. Confirm. Easier to set up during onboarding than to retrofit. Business
   decision, not this phase's scope.
4. **Can one organisation hold multiple IDs?** Undocumented. Relevant if we ever want separate IDs
   per build channel or per product.
5. **Is GNUS listed** on the chains we care about — Base 8453 above all — and what does listing
   take if not? `/v2/sdk-info` is the authority, but worth asking directly.

Do **not** ask about the base URL (the submodule pins `https://v2.api.squidrouter.com`, verified),
a testnet ID (there is none), or rate limits (answered above: 1 RPS default, 10 RPS on request).

**Plan 1 is not blocked** — wiring the submodule needs no credential. Plans 2-3 can be written and
only need the ID to run live.

## Testing strategy: split on money, not on network

Squid is mainnet-only: *"maintaining liquidity across testnets is not feasible."* The app's five
testnets stay useful for bridge and jobs but cannot carry a swap.

| Plan | Needs | How it is tested |
|---|---|---|
| 1 Wire the submodule | nothing | `pub get`, analyze, a serialization smoke test |
| 2 Replace the mock service | nothing | Real `/v2/route` with `quoteOnly: true` |
| 3 Live quote on screen | nothing | Same call; real rate, impact, fees, gas |
| 4 allowance / approve | dust | `allowance` is a free read; one `approve` costs gas only |
| 5 Execute + delete the lie | real funds | The first real swap |
| 6 Status polling | real funds | Needs a hash from plan 5 |
| 7 Error states | dust | Underfund and reject on purpose |

Plans 1-3 cost nothing to test and are the bulk of the change. Do them first; the risky part then
shrinks to signing a `transactionRequest` already known to parse.

### Chosen chain: Base mainnet, chainId 8453 (decided 2026-09-16)

Plans 4-7 run on **Base mainnet**. Ethereum was considered and rejected — it buys nothing
representative and costs real money.

GNUS is deployed on all three mainnets, so Base loses no realism:

| Chain | GNUS |
|---|---|
| Ethereum 1 | `0x614577036f0a024dbc1c88ba616b394dd65d105a` |
| **Base 8453** | `0x614577036F0a024DBC1C88BA616b394DD65d105a` (same address) |
| Polygon 137 | `0x127E47abA094a9a87D084a3a93732909Ff031419` |

All three also carry USDC and USDT, so GNUS↔USDC — the realistic user case — works anywhere.

Why cost dominates here: **26-07 exists to produce failures on purpose** (rejected approval,
underfunded wallet, failed send, non-success terminal status), and every attempt burns gas whether
it succeeds or not. A swap is also **two** transactions — an ERC-20 `approve` then the router call
— and because exact-amount approval is locked, every swap re-approves. Iteration count is high by
design.

Nothing under test is chain-specific: Squid's `transactionRequest` is chain-agnostic and
`signAndSendTransaction` already takes `chainId` as a parameter.

**Use Base mainnet 8453 — NOT the "Base - Sepolia" entry in `networks.json`.** That entry carries
`chainId: 84531`, which is Base Goerli, a dead chain (`11-FINDINGS.md` F-01). Using it fails in a
way that looks like a swap bug and is not.

One throwaway wallet, a few dollars. Never a wallet that holds anything.

**Open risk, unverified:** Squid routes against real pools, so GNUS liquidity depth on Base may be
thinner than on Ethereum and could yield a quote with unrepresentative price impact. If the live
walk produces a route that looks wrong, check depth per chain before blaming the code.

## Ordering constraint

**Do not ship plan 5 without plan 6.** A swap that broadcasts and never resolves its status is a
quieter version of the bug being fixed.

## Success criteria

1. A swap on a real network moves real funds, and the receipt's hash resolves on the explorer
2. No success toast, receipt or stored transaction unless a hash came back
3. A failed or rejected swap leaves no row in Hive and tells the user what happened
4. Quote, rate, price impact and fees come from the live route, not a constant
5. `SquidTokenService` contains no `mock*` return and no commented-out HTTP
