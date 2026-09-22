# Phase 30: dApp calldata decoding (end blind signing) - Context

**Gathered:** 2026-09-19
**Status:** Ready for planning

<domain>
## Phase Boundary

The Reown approval drawers describe what is about to be signed instead of showing
raw or absent calldata: ERC-20 `transfer`/`approve` in human terms, known-router
swaps as "swapping X → Y", and everything else explicitly labelled an unknown
contract call. Decoding is display-only — the signed payload is byte-identical to
what it is today.

Requirements: DAP-01, DAP-02, DAP-03.

</domain>

<decisions>
## Implementation Decisions

### Token identity and amounts

- **D-01:** No network call on the signing path. Address → (symbol, decimals)
  resolves offline only, from `WalletDetailsCubit.state.coins`, which
  `handleDappRequests` already holds. An RPC round trip inside the last human
  checkpoint before a signature adds latency and a hostile-RPC failure mode to
  the one screen that must not stall.
- **D-02:** An unresolved token never assumes 18 decimals. It renders the raw
  base-unit integer, explicitly marked as unverified, next to the contract
  address. A wrong decimals guess shows a confident, wrong amount — worse than
  admitting the token is unknown.
- **D-03:** `SendTransactionDetails` takes the unit symbol as a parameter rather
  than hard-coding `ETH` on its four rows. Without this, decoding an ERC-20
  renders "You send 100 ETH" for 100 USDC — a worse lie than today's blind
  signing. — **Reversibility:** costly — it is a const-constructed widget whose
  seven strings are pinned field-by-field by the Phase 21 contract test.

### What the drawer warns about

- **D-04:** An `approve` at or near max-uint256 carries its own explicit
  unlimited-spending warning, via the existing `GWWarningNote`. This is the
  main drain vector in the wild and costs one comparison — it is not an edge
  case and is not deferred.
- **D-05:** The unknown-call treatment replaces the raw
  `Text(event.params.toString())` debug dump that the non-send branch renders
  today. That also retires the only non-tokenised surface on this path (a fixed
  dark `deepBlueCardColor` fill with hard-coded `Colors.white70`, which breaks
  in light mode).

### Router decoding (DAP-02)

- **D-06:** An explicit chain-keyed router allow-list, shipping with only the
  router the companion dApp actually uses. A known router carrying an
  unrecognised selector falls through to the unknown-call treatment — never a
  partial guess. Confidently mislabelling a swap is worse than saying the call
  cannot be read.

- **D-11:** Squid's router does not expose a readable `swap(tokenIn, tokenOut, amount)`.
  Verified against this repo's own recorded live response
  (`test/squid_router/fixtures/route_response_executable.json` on the phase-26
  branch): target `0xce16F69375520ab01377ce7B88f5BA8C48F8D666`, selector
  `0x58181a80`, 2.3 KB of calldata. At fixed offsets, arg0 is **exactly**
  `fromToken.address` and arg1 is **exactly** `fromAmount`. `toToken.address`
  appears only nested at a route-dependent position, and `toAmount` does not
  appear at all.

  So this phase decodes the **input side only** — "Swapping 1.0 GNUS via Squid" —
  and explicitly tells the user the destination token cannot be read from the
  transaction and should be checked on Squid before approving. Finding the
  destination by scanning the blob for a known token address is a heuristic a
  hostile payload can seed, and a signing screen is the wrong place for one.

  **Known deviation:** this does not satisfy DAP-02's literal "swapping X → Y".
  It is the most that can be read with certainty. Record it in the phase
  verification rather than claiming the criterion is met.

  **UNVERIFIED:** the offsets above come from ONE fixture — a same-chain Base
  swap. Cross-chain, native-token and multi-hop routes may differ, and may use a
  different selector. The decoder must treat a non-matching selector or a short
  payload as unreadable rather than reading garbage from those offsets.

### Scope of the two broken sign methods

- **D-07:** Fix the `params[0]` cast that runs before the method check, so
  `personal_sign` and `eth_signTypedData` stop throwing and the dApp always
  receives a JSON-RPC response. This is the root cause inside the exact function
  this phase rewrites, and today it leaves callers hanging with no answer at
  all. Both methods route to the same cannot-decode presentation; a real EIP-712
  renderer is deferred.

### Honesty of the persisted record

- **D-08:** The decoded symbol replaces the hard-coded `coinSymbol = "ETH"`
  where it is written into the Hive transaction, so history agrees with what the
  user approved. Decoding only the drawer would leave the receipt contradicting
  the screen that authorised it.

### Safety invariants

- **D-09:** Decoding reads a copy. The `tx` map handed to
  `signAndSendTransaction` is passed by reference into the signer, so it is
  never written to — not lowercased, not `0x`-stripped, not re-encoded. A test
  asserts the map is identical before and after decoding. — **Reversibility:**
  one-way — this is the byte-identity contract the phase promises; breaking it
  changes what users sign.
- **D-10:** Phase 21's contract test is amended deliberately, not worked around.
  Its Case 6 asserts every decimal number on screen is one of the four values
  passed in, which a decoded amount fails by construction. The allow-set extends
  to decoded amounts; the no-fiat-`$` assertion and all six
  approve/reject/dismiss outcomes stay exactly as they are.

### Claude's Discretion

The user asked for judgement over exhaustiveness: *"just do what you think
matters, edge cases for now is not a big priority"*. Read as: minimum viable
decoding of the calls that actually occur, not exhaustive ABI coverage. No
EIP-712 renderer, no multi-router matrix, no speculative selector catalogue.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase boundary and requirements
- `.planning/ROADMAP.md` "Phase 30: dApp calldata decoding" — goal, 4 success criteria, security note
- `.planning/REQUIREMENTS.md` lines 169-171 — DAP-01, DAP-02, DAP-03

### The security fence this phase inherits
- `.planning/phases/21-drawer-language-rollout-the-four-decided-drawer-designs-appl/21-CONTEXT.md` §"Security fence - the two signing drawers" — 033-B1 confirm chrome, behavioural identity, and the standing rule that a warning must be backed by data. Phase 30 is the phase that supplies the data.

### Project rules
- `AGENTS.md` — wallet-safety rules, the reuse ladder, comment budget, always-brace-`if`
- `.claude/skills/review-pr/SKILL.md` — what a reviewer checks on a signing-path diff

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **`web3dart` 3.0.2 (already a dependency)** ships the whole ABI codec: `ContractAbi.fromJson`, `ContractFunction.encodeName()`, 4-byte selectors via `keccakUtf8(...).sublist(0, 4)`, and `TupleType.decode` for arguments. Do not hand-roll a decoder. The roadmap's "no built-in calldata decoder" note is true of `reown_walletkit` only.
- **`packages/genius_api/lib/web3/web3.dart:42`** already parses an ERC-20 ABI fragment (`name`, `decimals`, `balanceOf`, `symbol`). Adding `transfer` and `approve` is a small edit to an existing constant, not a new artifact.
- **`GWWarningNote`** (`lib/components/feedback/gw_warning_note.dart`) is the existing component for both the unlimited-approval and unknown-call warnings; it already solves amber-on-light contrast.
- **`formatTokenAmount(BigInt, int)`** in `lib/squid_router/squid_util.dart` formats base units on this branch. `toBaseUnits` and `capDecimals` are NOT on this branch — they live on the unmerged swap stack. Do not assume them.
- **`ApproveTransactionDrawer.show`** is content-agnostic by design and takes a `content` widget — decoded output slots in with no change to the drawer itself.

### Established Patterns
- `SendTransactionDetails` states its own invariant: it performs no arithmetic, parsing or unit conversion. Decode and format upstream in `handle_dapp_requests.dart`; pass formatted strings down.
- Both drawers are current-generation `GWColors`/`GeniusWalletConsts` widgets. This phase inherits no styling debt in them.

### Integration Points
- `lib/reown/handle_dapp_requests.dart` — one `if/else` is the entire method router; there is no per-method handler registration. The `data` field is read nowhere today.
- `test/reown/approve_drawer_contract_test.dart` — the behavioural-identity gate (see D-10).
- `test/components/drawer_padding_invariant_test.dart` — a hand-maintained census of `ResponsiveDrawer.show` call sites. A new drawer file fails this test until it is added, by design.

</code_context>

<specifics>
## Specific Ideas

No visual references supplied. The phase rides the 033-B1 confirm chrome already
shipped by Phase 21 — no new drawer language.

</specifics>

<deferred>
## Deferred Ideas

- **A real `personal_sign` / EIP-712 renderer.** D-07 stops the silent failure and gives those methods an honest cannot-decode screen; rendering typed data readably is its own phase.
- **RPC token metadata with a cache.** D-01 rules a network call out of the signing path. A background resolver that warms a metadata box is a separate piece of work, and would make D-02's unverified case rarer.
- **Additional routers.** D-06 ships one. Each further router is a self-contained addition to the allow-list.
- **Deduplicating `parseHexToBigInt`**, which exists identically in `lib/reown/utilities.dart` and `packages/genius_api/lib/web3/utilities.dart`.
- **The silent zero fallback in `parseHexToBigInt`** — malformed input currently renders `0 ETH` on a signing prompt. An existing test pins that behaviour as the current truth, so changing it is a deliberate decision, not a drive-by fix.

</deferred>
