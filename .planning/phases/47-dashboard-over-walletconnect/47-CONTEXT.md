# Phase 47: Dashboard over WalletConnect - Context

**Gathered:** 2026-10-28, autonomously. Every decision is Claude's, marked (D); Braian can overturn any.
**Status:** Ready for planning

<domain>
## Phase Boundary

The dashboard in a desktop browser pairs with GeniusWallet over Reown WalletConnect (Sign Client on the
page, the existing `reown_walletkit` stack in the wallet) and calls every `gnus_*` method, answered by the
same `GnusRpcHandler` and consent as the WebView. The wallet's WalletConnect sessions also stop acting on a
stale or unsignable account. Done: the Linux wallet pairs with the hosted dashboard in a desktop browser and
the walk passes. No WebView work (phases 45-46), no dashboard code (gnus-dashboard phase 6).

</domain>

<decisions>
## Implementation Decisions

### Precondition from phase 44's review
- **D-00:** The 44-REVIEW CR-01/CR-02 fix lands first. `handle` and `eventsFor` take a typed origin (transport
  kind + canonical origin), and connections are keyed on both. Only one prompt is open at a time, across all
  origins. This phase passes a `walletconnect`-kind origin and does no normalisation of its own.

### Session approval
- **D-01 (D):** A proposal is a gnus proposal when its eip155 required or optional methods include any method in
  `GnusRpcMethod.all`. It is approved with those methods (and nothing else) added to the existing EVM methods,
  the requested gnus events among `gnus_accountsChanged`, `gnus_networkChanged` and `gnus_jobUpdated`, and
  chains that always include `eip155:80002`. Proposals without gnus methods are approved as they are today.
  A proposal that does not ask for any implemented gnus method is handled as an ordinary dApp.
- **D-02 (D):** The origin is the peer's page origin, the same value Reown Verify compares with the attestation
  (`Uri.parse(metadata.url).origin`). It is passed to the typed-origin parser as `walletconnect`. The
  verification result is taken once, at the proposal. Requests on the session inherit it, because only the
  holder of the session key can send on the topic.
- **D-03 (D):** Verify outcomes for a gnus proposal:
  - VALID: approved.
  - SCAM or INVALID: rejected, and the user and the page are told why.
  - UNKNOWN: rejected in release builds. In a dev build it is accepted only for a loopback host (`localhost`,
    `127.0.0.1`), for local dashboard work.

  Unknown fails closed for reads too, not only spends. The connection key is the claimed origin, so an
  unverified peer claiming a verified site's URL would inherit that site's WalletConnect connection and read
  its jobs and accounts. Ordinary (non-gnus) proposals are not checked against Verify.
- **D-04 (D):** Before any request is handled, its origin goes through the typed-origin parser again. A restored
  session whose origin no longer parses gets `4100`. Example: a loopback session approved in a debug build,
  then opened in a release build.

### Requests
- **D-05 (D):** Every `gnus_`-prefixed `session_request` goes to `GnusRpcHandler.handle(origin, method, params)`;
  `handleDappRequests` never sees one. Each request gets exactly one answer.
- **D-06 (D):** The Reown Dart wire format has two gaps:
  - `JsonRpcError` carries only code and message. When a `GnusRpcError` has `data`, the WalletConnect message
    is the JSON text `{"message": ..., "data": ...}`.
  - A JSON `null` result cannot be sent, so `null` goes out as `{}`. No result in the contract is an empty
    object.

  The dashboard's WalletConnect client reverses both. The contract records this in section 2.
- **D-07 (D):** Approving the session (the existing connection drawer) exposes only the EVM account. Access to
  gnus methods needs the handler's first-call connect prompt, keyed `walletconnect` + origin and listed under
  Connected sites. Two dialogs on first use is accepted: they grant different things.
- **D-08 (D):** reown_sign 1.4.1 expires a wallet-side pending request after a fixed 5 minutes, whatever the
  page's own expiry is. A gnus request gets its pending expiry raised to `kGnusConfirmTimeout` plus 60 s when
  it arrives. Mark it `ponytail:` with the upgrade: drop it once Reown honours the request expiry. A reply
  that cannot be delivered (page expired, session gone, offline) is logged by type and dropped. A submit
  still completes, and the page recovers it with `gnus_getJob({ idempotencyKey })`.

### Events and session end
- **D-09 (D):** Each gnus session forwards `handler.eventsFor(origin)` as a `session_event` on `eip155:80002`,
  for the event names the session approved only.
  - Forwarding starts for restored sessions and on connect, and stops on delete, expiry or disconnect.
  - Events and replies on one topic go out through one ordered queue.
  - A failed emit is logged by type and dropped. Every reply reflects the current state, and spends recheck,
    so a lost event cannot cause a stale-account spend.
- **D-10 (D):** Over WalletConnect, `disconnect` is the end of the session itself: the page gets `session_delete`
  (with the wallet's reason code and message) or `session_expire`, and the dashboard emits `disconnect` from
  it. The wallet does not send `disconnect` as a session_event, because a deleted session cannot carry one.
- **D-11 (D):** When the selected wallet changes, every session gets `updateSession` with the new account on its
  approved chains, then `accountsChanged` with `[address]`. If the new wallet cannot sign, the session is not
  updated, and `accountsChanged` is sent with `[]`. When the selected network changes, `chainChanged` is
  sent on that chain if the session approved it. The handler already emits the gnus events for wallet, node
  account and network changes.

### Refusals
- **D-12 (D):** The selected wallet is read when the proposal arrives. When it is null, tracking or `sgnus`, every
  proposal (gnus included) is rejected with `UNSUPPORTED_ACCOUNTS` and a toast saying why.
- **D-13 (D):** An `eth_sendTransaction` is refused with `4100`, and nothing is signed, unless its `from` (compared
  case-insensitively) is the selected wallet, that wallet can sign, and the session's approved accounts
  include it. The refusal uses the existing request drawer with a stated reason.

### Ownership, testing, done
- **D-14 (D):** The WalletConnect listeners move out of `ReownConnectButton` into an app-level
  `WalletConnectHost`, provided in `main.dart`. Today the button unmounts below 1024 px, which silently
  drops the handlers, so requests hang. Desktop starts WalletConnect at launch. Mobile is unchanged.
- **D-15 (D):** No test dApp page in this repo. Wallet behaviour is tested with a fake `ReownWalletKit` and
  `GnusHarness`. The live peer is gnus-dashboard's WalletConnect client (its phase 6) on its hosted preview
  (its phase 7), with the domain verified in its Reown Cloud project. If the hosted page is not up at walk
  time, walk against its local dev server on a debug wallet build. The phase stays open until the hosted
  walk passes.

### Claude's Discretion
- File names, the fake's shape, how the host receives chain ids, toast copy (within the earn terminology
  rule), the order of gate commands.

</decisions>

<canonical_refs>
## Canonical References

- `.planning/research/v4.0-gnus-rpc-contract.md` sections 2, 4, 5, 6
- `.planning/ROADMAP.md` Phase 47; `.planning/REQUIREMENTS.md` DWC-01..04
- `.planning/research/v4.0-wallet-identity.md` edge cases 2 and 3
- `.planning/phases/44-dashboard-consent-and-limits/44-CONTEXT.md` (D-13 `eventsFor`), `44-REVIEW.md` CR-01, CR-02
- `lib/reown/` (button, `handle_dapp_requests.dart`, `utilities.dart`, `reown_walletkit_instance.dart`)
- `lib/network/connectivity_fallback.dart` (Linux without NetworkManager), `AGENTS.md`
- reown_sign 1.4.1 `sign_engine.dart`: `_getVerifyContext`, `_setPendingRequest`, `_isValidEmit`

</canonical_refs>

<code_context>
## Existing Code Insights

- `ReownConnectButton` attaches the proposal, request and connect listeners in its own State. It is mounted only
  in `_DesktopTopBar`, at 1024 px and wider (`GeniusBreakpoints.useDesktopOverlay`).
- The session account comes from the button's `walletAddress`, captured when the button builds. The selected
  wallet is never checked with `walletCanSign`.
- `eip155Namespace` hardcodes the events `chainChanged` and `accountsChanged`. The wallet never emits either.
- `handleDappRequests` already guarantees one answer per request and has a wrong-chain drawer to copy.
- Verify on Dart: a 404 or a network failure gives UNKNOWN with the raw metadata URL. A mismatch gives INVALID.
- `test/reown/handle_dapp_requests_test.dart` fakes `ReownWalletKit` with `implements` + `noSuchMethod`.

</code_context>

<deferred>
## Deferred Ideas

- Verify warnings for ordinary dApps, per-request Verify, ending WalletConnect sessions on a Connected sites revoke.
- A pairing entry on Android and iOS (no Connect button exists there).

</deferred>
