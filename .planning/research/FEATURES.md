# Feature Research

**Domain:** Multi-account crypto wallet — SDK node identity switcher + on-chain sub-account (child wallet) registration
**Researched:** 2026-09-28
**Confidence:** HIGH for protocol mechanics (read from SuperGenius `c575a16` source + `GeniusSDK.h`), MEDIUM for UX recommendations (inferred by analogy to MetaMask/Rabby/Phantom, not measured)

## Protocol Mechanics (cite: source file:line)

**Who calls what, from which node:**

| Call | Must run on | Why |
|------|-------------|-----|
| `RegisterChild(main_address, metadata)` | The **child's own** node | Signs with its own active account; reads/writes `reg/{own address}` (SuperGenius `TransactionManager.cpp:772-819`) |
| `DetachChild(metadata)` | The **child's own** node | Reads `reg/{own address}`, rewrites main to a zero-address (`TransactionManager.cpp:843-869`) — a child ends its own registration; **main cannot detach a child** |
| `ReplaceMain(new_main, metadata)` | The **child's own** node | Same self-keyed `reg/` read (`TransactionManager.cpp:894-925`) — child alone can move itself to a new main |
| `RevokeChild(child_address)` | The **main's own** node | Builds a `RevokeTransaction` signed by main; `CheckParentChildAuthority`'s revoke branch (`TransactionManager.cpp:5928-6039`) requires signer == `existing_reg.main_address`, record not already detached, and sequence match |
| `FundChild(amount, child_address, token_id)` | Whoever is sending | Ordinary `TransferFunds` to the child's address (`GeniusSDK.h:604-619`) — no special authority, same as any Send |
| `RecoverFromChild(amount, child_address, token_id)` | The **main's own** node | Spends the child's UTXOs, signed with **main's** key, output always goes to `account_m->GetAddress()` — i.e. only to the calling node's own address (`TransactionManager.cpp:715-770`) |

**Detach/Replace-Main being child-initiated-only is the sharpest UX consequence**: to detach a child or move it to a new main, the wallet must switch the *SDK node identity* to that child first, then call the lifecycle op on itself. Revoke is the only main-initiated lifecycle change.

**`GeniusRegistrationMetadata` (`GeniusSDK.h:91-97`, proto `SGTransaction.proto:136-141`):** `game_id`, `publisher_id`, `dev_wallet` (opaque strings/bytes), `peers_cut` (uint64). No consumer of these fields was found anywhere in `src/account` or `src/processing` (grepped) — they're carried on the signed tx but not interpreted by consensus. **Sane default for a user's own sub-account: empty strings, `peers_cut = 0`.** These are game-SDK fields (per-title publisher revenue split), not a personal-wallet concept — don't surface as user-editable.

**Sequence numbers:** each address has exactly one `reg/{address}` CRDT key — **a child can have exactly one main at a time** (confirmed at `GetRegistrationsForMain`'s filter, `TransactionManager.cpp:7164-7207`, which matches on the *current* `main_address` field, so Detach's zero-address rewrite makes the entry vanish from a stale main's list). The auto-derived-sequence overloads (used by all `GeniusSDKRegisterChild`/`DetachChild`/`ReplaceMain` wrappers) read the existing record and use `stored+1` (or `1` if none) — **the wallet never manages sequence numbers itself.** `FilterRegistration` (`TransactionManager.cpp:4361-4443`) rejects zero/non-monotonic sequences and forked `supersedes_sequence` values on ingress from any peer.

**Registration states (no formal enum exists) — three distinct levels of "real":**
1. **Not registered** — no `reg/` record.
2. **CRDT-visible** — appears in `GetRegistrationsForMain` once propagated and passing `FilterRegistration`'s 5 gates (deserialize, child-signature, 128-hex main address, sequence monotonicity, supersedes-sequence fork check). Fast, local, **not yet consensus-final**.
3. **Consensus-certified** — `CheckCertifiedParent` (`Blockchain.cpp:1988-2032`) requires a quorum certificate bound to the registration's exact DAG slot **and** the exact stored tx hash. This is what actually grants main the authority to call `RecoverFromChild` — an uncertified child's funds are not yet recoverable, and a later-rewritten `reg/` record (post-detach) no longer resolves.

**Confirmation observability — the wallet cannot see it today.** None of the six lifecycle/transfer C wrappers (`GeniusSDKRegisterChild`, `DetachChild`, `ReplaceMain`, `RevokeChild`, `FundChild`, `RecoverFromChild`; `GeniusSDK.h:559-720`) return the transaction hash — only `GeniusNodeReturnValue_t` (OK/error). Since `GeniusSDKGetTransactionStatus(tx_id)` needs a hash, **there is no way to poll any of these six calls through to CONFIRMED/FAILED.** The only observable signal is re-querying `GetRegistrationsForMain` and watching an entry appear, change `sequence`, or vanish — which only proves CRDT propagation (level 2 above), not consensus certification (level 3). This is the source of the documented milestone constraint: fund/recover/revoke/detach/replace-main all return "submitted," never "confirmed."

**`GetRegistrationsForMain` entry fields** (`GeniusSDK.h:99-108`, `TransactionManager.hpp:58-64`): `child_address`, `main_address`, `sequence`, `metadata`. No status field — confirms the observability gap above is structural, not a binding omission.

**`GetChildBalance`/`GetChildBalanceAll`** (`GeniusNode.hpp:495-517`): thin aliases over the node's own `GetBalance`, targeting `child_address` in the **locally-synced CRDT UTXO view** — no registration check is performed (works for any address, registered or not). Same 0-is-ambiguous caveat as the node's own balance call: a `0` return means either "genuinely empty" or "not yet synced," indistinguishable. `GetChildBalance` filters by token; `GetChildBalanceAll` sums every token.

**Limits:** no protocol-enforced cap found. `RecoverFromChild` fails closed (`invalid_argument`) only if the node's locally-known UTXOs for `child_address` don't cover the requested amount (`TransactionManager.cpp:743-747) — a liquidity check, not a policy limit.

## Feature Landscape

### Table Stakes (Users Expect These)

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| One switcher, one tap to change active account | Every EVM wallet (MetaMask, Rabby, Phantom) collapses account selection into a single header control | MEDIUM | Replaces two menus (`sdk_account_manager.dart`, `account_dropdown_selector.dart`→`account_drawer.dart`); must hold two *independent* selections, which no competitor UI models directly |
| Account list shows avatar + label + balance | Baseline account-list UX everywhere | LOW | Already exists per-list; needs merging into one switcher |
| Add/import an account inline from the switcher | MetaMask/Rabby/Phantom all support this without leaving the switcher | LOW | `_AddAccountDialog` pattern already exists in `sdk_account_manager.dart` |
| Every account row shows which key/address it maps to (no orphans) | Users distrust an account list with unlabeled or duplicate-looking rows | LOW-MEDIUM | Data already exists (`_registerWallet` links SDK account ↔ ETH wallet); this is a display/wiring fix, not new capability |
| Pending vs confirmed state shown honestly on any write action | Baseline trust requirement for a wallet — a false "success" is the exact bug class this repo has been burned by twice (fake swap success, demo-only Send) | LOW | No new mechanism needed — reuse the existing "submitted" pattern from Send/Squid; do **not** attempt to fake confirmation via polling GetTransactionStatus (unavailable for these calls) |

### Differentiators (Not Standard in EVM Wallets)

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Dual identity: "SDK wallet" (which key the local node runs/participates as) vs "active wallet" (what you're viewing/spending) | No consumer EVM wallet has this split — MetaMask's closest analogue is per-dApp *connection* permissions, not a second simultaneously-running node identity. This is a genuinely new concept the UI must teach, not reuse a known pattern for | HIGH | Two badges/pickers in one control; switching SDK wallet has real side effects (it's who can call `RecoverFromChild`/`RevokeChild`/`DetachChild`/`ReplaceMain` as "self") |
| Register your own sub-account as a "child" with fund/recover | Repurposes a game-studio revenue-split primitive (`game_id`/`publisher_id`/`dev_wallet`/`peers_cut`) for personal multi-account custody — nothing else in the ecosystem does this | MEDIUM-HIGH | Requires switching SDK wallet to the right node (child for detach/replace-main; main for revoke/recover) mid-flow — see dependency below |
| Fund/Recover between your own accounts without full Send friction | Pre-filled recipient (it's already "your" child), one-tap convenience | LOW-MEDIUM | Just `TransferFunds`/`RecoverFromChild` wrappers with the destination fixed |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|------------------|-------------|
| Editable `game_id`/`publisher_id`/`dev_wallet`/`peers_cut` fields in the register-child UI | "Power users" might want to set them | No consumer reads these fields for a personal sub-account; exposing them invites misconfiguration for zero protocol benefit and leaks an internal game-SDK concept into a personal-wallet flow | Default to empty/zero, hidden; only resurface if a future game-integration feature needs them |
| A live "is this registration confirmed yet?" progress indicator | Users expect certainty | The C API gives no tx hash for any of these six calls — a real progress indicator is not buildable without an SDK change; a fake timer would repeat this repo's fake-success bug class | Show "submitted" + a manual/periodic re-check against `GetRegistrationsForMain`/`GetChildBalance*`, explicitly labeled as eventual, not confirmed |
| Let a child register under multiple mains "for redundancy" | Seems safer | Protocol only tracks one `reg/{child}` record — a second registration just overwrites the first (higher sequence wins); a multi-main UI would misrepresent the model and silently orphan the first main | One main per child, enforced by disabling "register" once a child already has an active main (show ReplaceMain instead) |
| Main-initiated Detach or Replace-Main "on behalf of" a child | Feels natural — main manages its children | Protocol only allows child-initiated Detach/ReplaceMain; a main can only Revoke | If a main wants a child gone, use Revoke; label it clearly as "you can end this relationship, but only the child account itself can leave and pick a new main" |

## Feature Dependencies

```
Bind 11 unbound genius_api FFI functions (+ GetPubSub)
    └──requires──> [everything below]

Account linking (SDK account ↔ ETH wallet, visible)
    └──enhances──> Header switcher (rows are legible instead of "Super Genius Wallet N")
    └──requires──> Header switcher (to know which of the user's OWN accounts are eligible children)

List children + balances (GetRegistrationsForMain + GetChildBalanceAll)
    └──requires──> Bound FFI calls only (read-only, lowest risk)

Register child
    └──requires──> Account linking (need a list of the user's other SDK accounts to pick from)

Fund child
    └──requires──> Register child (must be registered — though FundChild itself doesn't check this; UI should)

Recover from child
    └──requires──> SDK-wallet switch UX (must be running as the certified main)
    └──requires──> Registration reaching consensus-certified state (unobservable — see caveat above)

Revoke child ──conflicts──> Detach/Replace-Main (mutually exclusive outcomes on the same reg/ record)

Detach / Replace-Main
    └──requires──> SDK-wallet switch UX (must be running as the child itself, not the main)
```

### Dependency Notes

- **Recover and Revoke require the "SDK wallet" to be switched to main first; Detach and ReplaceMain require it switched to the child first.** This is the single biggest UX/complexity driver in the whole milestone — every write action except Register and Fund needs the header switcher's SDK-wallet picker to be functional and obvious about *which* identity is currently "self" before the action is even offered.
- **Account linking is a hard prerequisite for the child-registration picker**, not just a cosmetic nice-to-have — without it, the UI has no reliable way to present "your other accounts" as child candidates.
- **List children + balances has no write-path dependency** — it's the cheapest, safest, most demoable slice and should land first.

## MVP Definition

### Launch With (v1)

- [ ] List children of the current main with balances (`GetRegistrationsForMain` + `GetChildBalanceAll`) — read-only, no confirmation-observability problem to solve yet
- [ ] Register a child (simplest write: single call, SDK auto-derives sequence)
- [ ] Fund a child (ordinary transfer wrapper, lowest protocol risk, matches existing Send UX)
- [ ] Header switcher shipping the two independent selections (SDK wallet, active wallet), replacing the two old menus
- [ ] Account linking visible everywhere an SDK account is shown

### Add After Validation (v1.x)

- [ ] Recover from child (needs the "switch SDK wallet to main" flow proven solid first)
- [ ] Revoke child (same SDK-wallet-switch dependency, main-side)
- [ ] Detach / Replace-Main (needs the SDK-wallet-switch flow working in the *other* direction — to the child — which is the least-tested path)

### Future Consideration (v2+)

- [ ] Any use of `game_id`/`publisher_id`/`dev_wallet`/`peers_cut` — defer until a game-integration use case actually reads them; no current consumer justifies the UI cost

## Sources

- `GeniusSDK.h` (child functions, `GeniusSDK/build/Windows/Release/GeniusSDK/include/GeniusSDK.h:59-108, 546-720`)
- SuperGenius `c575a16`: `src/account/GeniusNode.hpp:480-730`, `src/account/GeniusNode.cpp:3065-3266`, `src/account/TransactionManager.hpp:58-64`, `src/account/TransactionManager.cpp:660-970, 4361-4450, 5780-6040, 7164-7207`, `src/blockchain/impl/Blockchain.cpp:1988-2032`, `src/account/proto/SGTransaction.proto:120-152`
- `.planning/PROJECT.md` (milestone scope, constraints, existing UI file references)
- `lib/account/sdk_account_manager.dart`, `lib/account/account_dropdown_selector.dart` (existing two-menu pattern being replaced)
- Competitor UX inferred from general knowledge of MetaMask/Rabby/Phantom account switchers (not independently re-verified this session — MEDIUM confidence, standard/stable UX pattern unlikely to have changed materially)

---
*Feature research for: SuperGenius SDK child-wallet protocol + multi-account wallet UX*
*Researched: 2026-09-28*
