# Project Research Summary

**Project:** GeniusWallet — milestone v3.0 "Child wallets & account linking"
**Domain:** Flutter self-custody wallet, native SDK over Dart FFI, bloc/cubit
**Researched:** 2026-09-28
**Confidence:** HIGH

## Executive Summary

This milestone binds 11 unbound `GeniusSDK.h` child-wallet functions (plus `GetPubSub`), wires a
long-missing SDK-address-to-ETH-wallet link, and collapses two previously separate account pickers
into one header switcher with two independent selections ("node identity" vs "active/send wallet").
No new dependency is needed — `ffigen`, `dart:ffi`, and `package:ffi` already cover everything the
new structs and out-params require; the work is disciplined hand-splicing into the existing
FFI file, not new tooling.

The core risk is not binding mechanics but honesty and confusion: every child-transfer/lifecycle
call (`Fund`, `Recover`, `Revoke`, `Register`, `Detach`, `ReplaceMain`) returns "submitted," never
"confirmed" — the SDK gives no tx hash and no completion callback — so the UI must model a
`pending` state and never collapse `GENIUS_NODE_RET_OK` into a success toast. Balance reads return
an ambiguous 0 (empty vs not-yet-synced). And the new switcher merges two real, independently
mutable selections into one control — the single biggest UX risk in the milestone — so a
send-from-wrong-account bug is the thing most worth designing against.

Recommended approach: land read-only, dependency-free value first (account linking, then the
switcher, then read-only child list), defer every write path (fund/recover/revoke/detach/replace)
until the pending-state pattern and the SDK-wallet-switch UX are proven, and build every plan
against `lib/dev/` mocks since live testnet is currently blocked by an unrelated
`INITIALIZING_BLOCKCHAIN` loop.

## Key Findings

### Recommended Stack

No new packages. `ffigen ^20.1.1` (dev-only, run ad hoc — there's no committed `ffigen.yaml` or
regen script despite the file's "auto-generated" header) generates the new struct/out-param shapes;
hand-splice only the new symbols into `genius_api_ffi.dart`, never a full regen (it would reformat
all 27 existing bindings). Bind the 11 child functions synchronously, matching `transferTokens`/
`mintTokens`, not the one isolate-wrapped outlier (`selectGeniusAccountAsync`) — add an isolate only
if a real jank is observed. `GeniusSDKGetPubSub()`'s handle must never be passed to `GeniusSDKFree`
(node-owned).

### Expected Features

**Must have (table stakes):** one-tap unified switcher; account list with avatar/label/balance;
inline add/import; every SDK account visibly linked to its source wallet (no orphan "Super Genius
Wallet N" rows); honest pending-vs-confirmed state on every write.

**Should have (differentiators):** the dual "SDK wallet" vs "active wallet" identity split (no
consumer EVM wallet has this); register-your-own-account-as-child for personal multi-account
custody; fund/recover between own accounts with pre-filled recipient.

**Defer (v2+):** any UI for `game_id`/`publisher_id`/`dev_wallet`/`peers_cut` metadata fields — no
current consumer reads them; default empty/zero, hidden.

**Protocol facts that drive design:** `RegisterChild`/`DetachChild`/`ReplaceMain` must run on the
**child's own** node; `RevokeChild`/`RecoverFromChild` must run on the **main's own** node — so
several write actions require switching SDK identity mid-flow. One main per child (single `reg/`
record, higher sequence wins). No formal registration-status enum; three real levels (not
registered / CRDT-visible / consensus-certified) with no field exposing which.

### Architecture Approach

Keep the two existing, separately-owned selections (`AppBloc.selectedSDKAccount`,
`WalletDetailsCubit.selectedWallet`) as-is; add the missing link (`AppState.sdkAccountLinks`,
persisted via a new `saveSDKAccountLink`/`getSDKAccountLinks` pair in `local_secure_storage`) rather
than merging state owners. The link is captured as a byproduct of `_registerWallet` (diff
`getAvailableAccounts()` before/after), since no FFI call derives an SGNUS address without
registering it.

**Major components:**
1. `lib/account/account_switcher.dart` + `account_switcher_drawer.dart` — new, composes two
   `BlocBuilder`s (AppBloc + WalletDetailsCubit), replaces `SDKAccountManagerButton` +
   `AccountDropdownSelector`.
2. `packages/genius_api/lib/src/genius_api.dart` — new `getSDKAccountLinks()`, diff-and-persist in
   `_registerWallet`, and the 11 new child-function wrappers + `getPubSub`, following the existing
   `calloc`/`GeniusSDKFree` idiom.
3. `lib/child_wallets/` (new cubit + view, mirroring `lib/wallets/` layout) — owns child list,
   balances, and the pending-operation map for the *currently selected SDK account*; never holds a
   private key.

### Critical Pitfalls

1. **Submitted != confirmed shown as done** — model every fund/recover/revoke/register/detach/
   replace-main result as `pending`, never a direct success toast; no tx hash exists to poll toward
   confirmation, only CRDT re-query as a weaker proxy.
2. **Balance 0 is ambiguous** (empty vs not-yet-synced) — pair with node sync/processing state,
   never render a bare 0 right after a fund action.
3. **One switcher, two silent selections** — label "node running as" vs "sending from" explicitly;
   never let one selection implicitly change the other; confirmation drawers always name the active
   wallet.
4. **Account-switch race** — nothing today guards against switching SDK identity mid-submission;
   serialize switch vs. submit through a single in-flight bloc/cubit guard (no new dependency).
5. **Metadata `char[128]` overflow** — validate UTF-8 byte length client-side before crossing FFI;
   never surface a mnemonic through the new linking display (must stay address-only in state).

## Implications for Roadmap

### Disagreement on build order — and the recommendation

The three research files order things differently:
- **Architecture** proposes: (1) account linking, (2) header switcher, (3) child wallets — pure
  dependency order, UI-first, FFI bindings deferred to phase 3.
- **Features** proposes: bind FFI first, then linking+switcher, then read-only children, then
  register+fund, then recover/revoke/detach/replace-main — an incremental-risk MVP ladder within
  the child-wallet feature itself.
- **Pitfalls** implies binding (with dev mocks) should happen early, before any UI consumes child
  calls, so struct/ownership bugs are caught in isolation.

**These are not actually in conflict — they operate at different granularities.** Architecture
orders the three *phases*; Features and Pitfalls both order *what happens inside* the child-wallet
phase once reached. **Recommendation: follow Architecture's 3-phase skeleton, and inside phase 3
follow Features'/Pitfalls' internal ladder** (bind all 11 functions with dev-mock fixtures first →
read-only list+balances → register+fund → recover/revoke/detach/replace-main last, since those need
the riskiest, least-tested SDK-wallet-switch-to-child flow). Reasoning: account linking and the
switcher are cheap, dependency-free, and immediately valuable on their own — shipping them first
de-risks the one genuinely uncertain non-child piece (legacy link backfill) before any child-wallet
work depends on it, while the child-wallet phase's internal risk ladder is already well-reasoned in
Features/Pitfalls and shouldn't be re-litigated per sub-step.

### Phase 1: Account Linking
**Rationale:** Foundation, no new SDK binding required; de-risks legacy-backfill uncertainty early.
**Delivers:** `sgnusAddress -> ethAddress` link captured/persisted; honest "Unlinked SDK account"
labeling replaces "Super Genius Wallet N".
**Avoids:** Pitfall 11 (mnemonic-in-state) — enforce address-only linking now, before any UI reuses it.

### Phase 2: Unified Header Switcher
**Rationale:** Depends on phase 1's real link data; pure UI/composition over existing state, no new FFI.
**Delivers:** `AccountSwitcher`/`AccountSwitcherDrawer` on desktop and mobile, retiring the two old widgets.
**Avoids:** Pitfall 7 (SDK-vs-active-wallet confusion) and Pitfall 6 (switch race) — needs its own
UI-SPEC pass and an in-flight guard designed here for reuse in phase 3.

### Phase 3: Child Wallets
**Rationale:** Largest, highest-risk phase; needs the link map (phase 1) and the switch-guard
pattern (phase 2) already in place.
**Delivers, in this internal order:** bind all 11 functions + `GetPubSub` with dev-mock fixtures →
read-only child list + balances (`GetRegistrationsForMain`, `GetChildBalanceAll`) → register child →
fund child → recover/revoke/detach/replace-main (deferred to last — needs the SDK-wallet-switch-to-child
flow, the least-tested direction).
**Avoids:** Pitfalls 1-5, 8-10 (stale bindings, out-param free bugs, metadata overflow, fire-and-
forget-as-done, balance ambiguity, double-submit, UI-isolate jank, no live network).

### Phase Ordering Rationale

- Dependency order from Architecture drives the 3-phase skeleton; internal risk-ladder order from
  Features/Pitfalls drives phase 3's step sequence.
- Read-only work (linking, list+balances) is pulled forward in both dimensions — cheapest and safest.
- Every write path (fund/recover/revoke/detach/replace-main) is pushed to the end and shares one
  pending-state/in-flight-guard mechanism designed once in phase 2, reused in phase 3.

### Research Flags

Needs deeper research during `/gsd-plan-phase --research-phase <N>`:
- **Phase 3 (Child Wallets):** 11 distinct FFI signatures, two different "pending" semantics
  (balance-poll vs. cross-node registration visibility), and the SDK-wallet-switch-to-child flow.

Standard patterns (skip research-phase):
- **Phase 1 (Account Linking):** reuses existing `_registerWallet`/`local_secure_storage` conventions.
- **Phase 2 (Header Switcher):** reuses existing bloc/cubit composition pattern; only the visual
  layout needs a UI-SPEC pass, not FFI research.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified against actual header, generated file, wrapper source |
| Features | HIGH (protocol) / MEDIUM (UX) | Protocol mechanics read from SuperGenius source; competitor UX inferred by analogy, not re-verified |
| Architecture | HIGH | All claims cite current code; legacy-link backfill flagged LOW internally |
| Pitfalls | HIGH (code/header) / MEDIUM (SuperGenius fix mechanism) / LOW (live testnet) | Fix-commit mechanism inferred from titles only; testnet currently unreachable |

**Overall confidence:** HIGH

### Gaps to Address

- **Legacy SDK account re-add idempotency** (unverified from header alone) — confirm behaviorally
  in phase 1 before relying on diff-based backfill for pre-existing accounts.
- **Live testnet verification** is blocked by an unrelated `INITIALIZING_BLOCKCHAIN` loop — every
  child-call phase must ship a `lib/dev/` mock fixture and treat testnet UAT as a flagged, possibly
  deferred criterion, not a blocking gate.
- **Native GeniusSDK binary version** — the 12 researched symbols require a prebuilt built from
  SuperGenius `c575a16`+; verify the binary in use actually has them before phase 3 planning, or
  `NativeLibrary` construction throws at binding time.

## Sources

### Primary (HIGH confidence)
- `GeniusSDK.h` (child function block, `GeniusSDK/build/Windows/Release/GeniusSDK/include/GeniusSDK.h`)
- `packages/genius_api/lib/src/genius_api.dart`, `packages/genius_api/lib/ffi/genius_api_ffi.dart`
- `lib/account/*`, `lib/bloc/app_bloc.dart`, `lib/bloc/app_state.dart`, `lib/wallets/cubit/wallet_details_cubit.dart`
- `packages/local_secure_storage/lib/src/local_secure_storage_base.dart`
- SuperGenius `c575a16`: `TransactionManager.cpp/hpp`, `GeniusNode.hpp/cpp`, `Blockchain.cpp`, `SGTransaction.proto`
- `.planning/PROJECT.md`, `AGENTS.md`

### Secondary (MEDIUM confidence)
- SuperGenius `git log` fix-commit titles (account-switch race mitigations) — mechanism inferred, diffs not pulled

### Tertiary (LOW confidence)
- Competitor wallet UX (MetaMask/Rabby/Phantom) — general knowledge, not independently re-verified this session
- Live testnet behavior — currently blocked by `INITIALIZING_BLOCKCHAIN`

---
*Research completed: 2026-09-28*
*Ready for roadmap: yes*
