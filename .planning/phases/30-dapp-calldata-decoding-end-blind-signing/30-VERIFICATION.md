---
phase: 30-dapp-calldata-decoding-end-blind-signing
verified: 2026-09-19T00:00:00Z
status: gaps_found
score: 3/4 roadmap success criteria verified
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "SC2 — Known-router swap calls decode to a 'swapping X → Y' summary in the drawer"
    status: partial
    reason: >-
      Only X ships. The drawer says "Swapping 1 GNUS via Squid" and states in
      words that the destination token and amount cannot be read. Squid's
      calldata carries fromToken/fromAmount at fixed offsets but toToken only
      nested at a route-dependent position and toAmount not at all, so "→ Y" is
      not readable with certainty. The phase refused the blob-scan heuristic
      that would have produced it. This is recorded, not hidden: REQUIREMENTS.md
      DAP-02 is unchecked with an explicit PARTIAL note, both traceability
      tables read "Partial", and 30-04-SUMMARY.md carries a "DAP-02 is NOT met"
      section.
    artifacts:
      - path: lib/reown/calldata_decoder.dart
        issue: "tryDecodeSwapInput reads word 0 and word 1 only; no destination is decoded"
      - path: lib/reown/dapp_call_details.dart
        issue: "headline is 'Swapping <amount> <symbol> via <router>' — no destination clause"
    missing:
      - "Either a human-accepted override recording this as a bounded deviation, or a later phase that reads the destination from a source that carries it (a Squid multicall ABI, or the dApp-side route the user already saw)"
human_verification:
  - test: >-
      Debug build with a live WalletConnect session: approve one ERC-20 transfer
      and one Squid swap, in both light and dark appearance.
    expected: >-
      The transfer drawer names the real recipient, the token amount and the
      token's own symbol; the swap drawer reads "Swapping X <SYM> via Squid"
      with the destination-unreadable caution; both are legible in light mode.
    why_human: "Real relay session, real dApp payload, real appearance switch — no widget test covers the device path."
  - test: >-
      On a non-ETH EVM network (Polygon or BNB), send a plain native transaction
      from a dApp and compare the approval drawer's unit with the history row's.
    expected: "Both should name the same currency."
    why_human: "Requires a funded wallet on that chain; see finding W-1 — the drawer still hard-codes ETH while the receipt now records the network symbol."
---

# Phase 30: dApp calldata decoding (end blind signing) — Verification Report

**Phase Goal:** The Reown approval drawers decode calldata so the user signs with their eyes open — token moves and known-router swaps described in human terms, undecodable calls labeled as exactly that.
**Verified:** 2026-09-19, branch `phase-30-calldata-decoding`, HEAD `74418295`
**Status:** gaps_found — 3/4 roadmap success criteria met; SC2 partially met by design and honestly recorded
**Re-verification:** No — initial verification

## Gates re-run by the verifier (not inherited)

| Gate | Command | Real output | Exit |
|---|---|---|---|
| Suite | `flutter test` | `00:22 +1341 ~3: All tests passed!` | 0 |
| Analyzer | `flutter analyze` (exit captured before pipe) | `No issues found! (ran in 3.7s)` | 0 |
| Format | `dart format --output=none --set-exit-if-changed lib test` | `Formatted 404 files (0 changed) in 0.93 seconds.` | 0 |
| Braces | `bash tool/check_brace_style.sh` | no output | 0 |
| Raw colours | `bash tool/check_raw_colors.sh` | no output | 0 |
| Seed safety | `bash tool/check_onboarding_seed_safety.sh` | `PASSED -- all seven checks hold over the finished tree.` | 0 |
| Tree | `git status --porcelain` | `?? squid.local.json` only (untracked, unrelated) | — |

1341 pass / 3 skip / 0 fail. Matches the state reported at hand-off.

## Goal Achievement — the four roadmap success criteria

| # | Success criterion | Status | Evidence |
|---|---|---|---|
| 1 | ERC-20 `transfer`/`approve` decode and the drawer shows the decoded action | ✓ CONFIRMED | Decoder + handler + drawer verified end to end; see SC1 below (includes a verifier-run behavioural probe) |
| 2 | Known-router swap calls decode to "swapping X → Y" | ⚠️ PARTIALLY MET — **NOT CONFIRMED** as written | Input side only, by evidence, and recorded as Partial in three places; see SC2 |
| 3 | Undecodable calldata renders an explicit unknown-contract warning, never a plain send | ✓ CONFIRMED | Raw `event.params.toString()` dump deleted outright; warning surface + tests; see SC3 |
| 4 | Decoding is display-only — the signed payload is byte-identical | ✓ CONFIRMED | Same map instance, same call args as `develop`; byte-identity tests proven fail-on-mutation by injection; see SC4 |

**Score: 3/4.**

---

### SC1 — ERC-20 decode reaches the drawer: **CONFIRMED**

Chain traced, all four levels:

- **Decode.** `lib/reown/calldata_decoder.dart` — `_tryDecodeAddressAmount` gates on the 4-byte selector, then `TupleType([AddressType(), UintType()]).decode(bytes.buffer, 4)`. Selectors are pinned against the ABI (`the hardcoded selector agrees with the ABI` group), and the ABI fragment in `packages/genius_api/lib/web3/web3.dart` gained `transfer`/`approve`.
- **Summarise.** `summarizeTransaction` yields `tokenTransfer` (recipient / amount / symbol) or `tokenApprove` (spender / allowance / symbol), with `recipient`/`amount` left null on an approve — so an approval is *structurally* unable to render through the send body.
- **Wire.** `lib/reown/handle_dapp_requests.dart:108-118` passes `summary.recipient!` as `toAddress` (explicitly *not* `tx['to']`, which is the contract), `summary.amount!`, `summary.symbol!` as `amountSymbol`.
- **Render.** `SendTransactionDetails` no longer hard-codes `ETH` on its rows; `amountSymbol`/`feeSymbol` are separate so gas keeps the chain's currency.

Automated evidence: `test/reown/calldata_decoder_test.dart` (82 tests) and `approve_drawer_contract_test.dart` Case 7 (decoded fixture: no fiat `$`, every decimal on screen is one of its own four fields, `USDC` on screen, and the "You send" row does *not* say ETH).

**Verifier-run behavioural probe.** Case 7 uses a hand-built fixture, so I added three temporary assertions inside the existing end-to-end handler test (`the record written after an approval carries that symbol`), which drives a real `eth_sendTransaction` with real `transfer` calldata through `handleDappRequests`, and ran them:

```
expect(_onScreen(tester, '1.5 USDC'), isTrue);   // amount + decoded unit
expect(_onScreen(tester, '0x5aAe'),  isTrue);    // calldata recipient
expect(_onScreen(tester, '0xdbF0'),  isFalse);   // NOT the token contract
→ 00:00 +20: All tests passed!   EXIT=0
```

The probe was reverted (`git checkout --`) and the tree re-confirmed clean. This closes the only link the shipped tests covered by composition rather than by assertion.

### SC2 — known-router swaps: **NOT CONFIRMED as written; partially met and honestly recorded**

What ships (verified): `kKnownRouters = {8453: {'0xce16f6…d666': 'Squid'}}`; `knownRouterName(chainId, to)` gates on the wallet's own selected chain; `tryDecodeSwapInput` reads word 0 (`fromToken.address`) and word 1 (`fromAmount`) behind the `0x58181a80` selector gate; the headline reads `Swapping 1 GNUS via Squid`; the caution states the destination token and amount are not in the transaction and must be checked on the dApp.

What does not ship: the "→ Y" half. No destination is decoded, and nothing scans the payload for one — I read the whole decoder; there is no search over the blob, and the test helper `_expectNoDestinationNamed` asserts the destination symbol, the destination address, `→`, `->`, `You receive`, `Token out` and `Amount out` are all absent from the screen in five separate swap cases.

**Is the partial honestly recorded? CONFIRMED — in every place asked for:**

| Location | Text |
|---|---|
| `.planning/REQUIREMENTS.md:170` | `- [ ] **DAP-02**: … — PARTIAL: the input side … ships … "→ Y" is not met because Squid's calldata does not carry the destination token or amount at any fixed offset` (checkbox deliberately **unticked**) |
| `.planning/REQUIREMENTS.md:213` (traceability table) | `Partial — input side only` |
| `.planning/ROADMAP.md:1511` (v2.0 traceability table) | `Partial — input side only; the destination is not in the transaction` |
| `30-04-SUMMARY.md` | `## Known deviation: DAP-02 is NOT met` |
| `30-CONTEXT.md` D-11 | records the single-fixture evidence and the UNVERIFIED caveat on cross-chain routes |
| `STATE.md:8` | `DAP-02 is recorded PARTIAL, not met` |

**Does anything overclaim it? NOT OVERCLAIMED.** `grep -rn "→\|->" lib/reown/*.dart` → no matches. The only `Swapping` string in `lib/` outside the swap screen is `'Swapping $amount $symbol via $router'`. ROADMAP's SC2 text is left as originally written (the contract is not edited to fit the result), and Phase 30's roadmap checkbox is still `[ ]`.

**To close this gap, one of two things — both human decisions:**

```yaml
overrides:
  - must_have: "Known-router swap calls decode to a swapping X → Y summary in the drawer"
    reason: >-
      Squid's calldata carries fromToken/fromAmount at fixed offsets but the
      destination only nested at a route-dependent position, and toAmount not at
      all. The input side plus an explicit "destination unreadable" statement is
      the most that can be read with certainty; finding Y by scanning the blob
      is a heuristic a hostile payload can seed, on a signing screen.
    accepted_by: "{name}"
    accepted_at: "{ISO timestamp}"
```

…or a follow-up phase that gets the destination from a source that actually carries it (a full Squid multicall ABI decode, or the route the dApp already showed the user), which is new work, not gap closure.

### SC3 — undecodable calldata: **CONFIRMED, and the raw dump is genuinely deleted**

- `grep -rn "params.toString()" lib/` → **exit 1, no match**. The `develop` version is gone, not restyled: the removed hunk is `color: gw.deepBlueCardColor` / `Text(event.params.toString(), style: const TextStyle(color: Colors.white70))`, i.e. the fixed-dark, light-mode-broken card went with it (D-05 satisfied). `check_raw_colors.sh` exits 0.
- The replacement is `DappCallDetails` with `kUnreadableRequestWarning` ("GeniusWallet could not read what this request does. Approving it may move funds in ways this screen does not show.") inside the existing `GWWarningNote`.
- **Never a plain send** is structural, not stylistic: `handle_dapp_requests.dart` routes only `nativeSend` and `tokenTransfer` to `SendTransactionDetails`; every other kind goes to `DappCallDetails`, which carries no amount hero and no "You send" row. Four separate tests assert `find.textContaining('You send')` finds nothing on the unknown, approve, unverified and swap bodies.
- Signature methods and unhandled methods get the same treatment plus their own copy, and are declined.

### SC4 — display-only, byte-identical payload: **CONFIRMED, by injection**

Three independent legs:

1. **Same instance.** `transactionParam()` returns `params.first` — never a copy — pinned by `expect(identical(transactionParam([tx]), tx), isTrue)`.
2. **Same call.** `git show develop:lib/reown/handle_dapp_requests.dart` signs with `signAndSendTransaction(tx: tx, sourceChainId: chainId, rpcUrl: rpcUrl, address: walletAddress)`; HEAD is argument-for-argument identical. Nothing between decode and signature touches `tx`.
3. **No in-place writes — proven, not asserted.** Three tests now guard this (`every key and value survives a decode unchanged`, `an undecodable transaction is left alone too`, and a fourth-wave `the recorded route leaves the signed map untouched`). To confirm the property the tests claim **still holds after four waves of edits**, I injected a one-line mutation into `summarizeTransaction`:

```dart
tx['to'] = (tx['to'] as String).toLowerCase();   // verifier injection, reverted
```

```
00:00 +49 -2: … every key and value survives a decode unchanged [E]
  Expected: '0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB'
    Actual: '0xdbf03b407c01e7cd3cbea99509d93f8dddc8c6fb'
  "to" was rewritten during decoding
00:00 +77 -5: Some tests failed.   EXIT=1
```

Three of the guards failed on the mutation, including the wave-4 Squid one. The injection was reverted, `git status` re-confirmed clean, and `flutter test test/reown/calldata_decoder_test.dart` returned `+82: All tests passed!`. The `mixed-case contract address still resolves its coin` test is the companion that stops the guard passing vacuously (it forces the lowercasing code path to actually run, on a copy).

One scoping note, stated honestly: the guard is a shallow comparison. Every value in an `eth_sendTransaction` map is a `String` (immutable), so this is sufficient today; it would not catch mutation of a nested mutable value if one ever appeared.

---

## The commitments the phase made to itself

| Commitment | Status | Evidence |
|---|---|---|
| **D-02** — no path assumes 18 decimals | ✓ CONFIRMED | `grep -n "18" lib/reown/calldata_decoder.dart` matches only `kSquidSwapSelector = '0x58181a80'`. `_resolveToken` returns null on null / empty / unparseable / negative / >36 decimals and on a blank symbol; the group `UNRESOLVED decimals are never assumed to be eighteen` covers all six, each asserting `unverifiedToken`, `amount == '1500000'`, no `.`, `symbol == null`. The drawer then labels the row `Amount (smallest units)`. |
| **D-04** — unlimited warning at 2^255, reaching the screen | ✓ CONFIRMED | `kUnlimitedApprovalThreshold = BigInt.two.pow(255)`, comparison `>=`, pinned inclusive at exactly 2^255, negative one wei below, and the constant asserted to be 2^255 and not 2^256−1. Flag → words: `dappCallWarning` prepends the unlimited sentence, and the widget test drives real max-uint calldata through `summarizeTransaction` → `DappCallDetails` and asserts the word `unlimited` is on screen (and absent for a 1.5 USDC allowance). Also fires for *unverified* tokens — same drain vector. |
| **D-11 guards** — non-matching selector, short payload, out-of-range offset | ✓ CONFIRMED | Non-matching selector: the same 2.3 KB payload under `0xdeadbeef` → null; a listed router with an unknown selector renders `Unknown call to Squid` with no `Swapping`/`Token in`/`Amount in` row. Short payload: 67 bytes (one byte short of two words) → null; selector-only → null; `_minimumCalldataBytes = 68` is checked *before* the tuple read, so the fixed-offset read can never run off the end, and the decode is additionally wrapped in try/catch. Off-chain: the same payload with no selected network, or off Base, is an `Unknown contract call` with `Squid` absent. Non-hex, odd-length, `'0x' + 'f'*4096` all return null / `returnsNormally`. |
| **Bug 1** — `params[0]` cast before the method check | ✓ GONE | `classifyDappRequest(method, params)` reads the method first and checks the *shape* of `params.first` without casting; `personal_sign` / `eth_signTypedData` / `_v4` all classify without throwing, and six malformed param shapes return `unsupportedMethod` instead of throwing. Handler tests drive each method through the real handler and assert exactly one answer comes back. |
| **Bug 2** — `Errors.USER_REJECTED.toInt()` (null, not 5000) | ✓ GONE | `grep -rn "toInt()" lib/reown/` → exit 1. `userRejectedError()` uses `Errors.getSdkError(...)`; tests assert the literal `5000` **and** separately pin `int.tryParse(Errors.USER_REJECTED)` as null — the round-trip trap avoided. |
| **Bug 3** — hard-coded `coinSymbol = "ETH"` | ✓ GONE from the signing path | `grep -rn "coinSymbol: 'ETH'" lib/` hits only `lib/dev/*` and `lib/test/dev_overrides.dart`. The record now takes `receiptSymbol(summary, nativeSymbol: …)`: token symbol for a decoded token, the contract address for an unverifiable one (never an invented ticker), the network symbol for a plain send. End-to-end test asserts `transactions.state.single.coinSymbol == 'USDC'` after a real approval. |

## Findings

| # | Severity | Finding |
|---|---|---|
| G-1 | Gap (human decision) | SC2 / DAP-02 partial — see above. Bounded by evidence, recorded everywhere, not overclaimed. Needs an accepted override or a follow-up phase. |
| W-1 | Warning (new asymmetry, untested) | **A plain native send still says ETH on the drawer while the receipt now says the truth.** `handle_dapp_requests.dart:114` passes `amountSymbol: isTokenTransfer ? summary.symbol! : 'ETH'`, and `feeSymbol` is never passed (defaults `'ETH'`), while the Hive record now uses the network symbol. The catalogue in `assets/json/networks/networks.json` ships `matic`, `bnb` and `gnus` networks, so on Polygon the drawer reads "You send 1.0 ETH / Gas Fee … ETH" and history records `POL`. Before this phase both were wrong-and-consistent; now they disagree. D-03 moved the hard-coded ETH out of the widget; the call site kept one. `DappCallDetails` does *not* have this problem — it uses `network?.symbol` (a handler test asserts `0.0100000000 eth` on Base). No test pins the native-send unit either way. 30-01's must-have said "a native send renders exactly as it does today", so this is in-scope-by-omission rather than a regression — but it is the same lie class the phase set out to end. |
| H-1 | Minor hygiene | `test/reown/handle_dapp_requests_test.dart:130` names a sibling test file in a comment (`See \`account_drawer_show_test.dart\` for why this is implements plus noSuchMethod`) — AGENTS.md forbids naming test files in source comments. Commit `189a888f` swept two such references but missed this one. File added by this phase. |
| H-2 | Minor hygiene (documented trade) | `test/reown/calldata_decoder_test.dart:95` cites `refs/heads/phase-29-integrator-fee:…` as fixture provenance — a phase number in source. 30-04's summary declares this deliberately ("better than unverifiable provenance"). Recording it so the choice stays visible. |
| I-1 | Info | Two `TODO`s remain in `handle_dapp_requests.dart` (network-match-on-swap, pending-transaction display). `develop` had four; the two this phase owned (`parse this out of the transaction data`, `record the coin symbol instead of hard coding`) are gone. No `TBD`/`FIXME`/`XXX` anywhere in the phase's files. |
| I-2 | Info (not this phase's) | `deferred-items.md` records six pre-existing decision/threat IDs in `lib/reown/`. Two of those files *were* touched by later plans in other blocks (`approve_transaction_drawer.dart:37` `(T-21-12)`; `send_transaction_details.dart`'s 35-line 033-B1/T-21-11 doc comment), so the note's "files 30-01 does not touch" is slightly narrower than the truth — but the violations themselves are inherited and **are not this phase's failures**. This phase *removed* two of them (`(D-03)` in the send body, a `file:line` citation in the approve drawer). |
| I-3 | Info | `STATE.md:43` still lists Phase 30 as `Not started` in the phase table while `stopped_at` on line 8 says `COMPLETE (4/4)` — internal drift in the file GSD's own tooling is known to corrupt on this repo (see `deferred-items.md`). |
| I-4 | Info | The Squid fixture's own `"value": "0"` is decimal, not `0x`-prefixed; the tests substitute `'0x0'`. A real payload arriving with a non-`0x` value falls to `unknownCall` by `_nativeValue`'s design (correct for `eth_sendTransaction`, whose quantities are hex by spec) — noted only because the recorded artefact and the exercised value differ. |

**AGENTS.md hygiene on the phase's own files, overall:** doc comments in the three `lib/reown/` files the phase wrote are all ≤3 lines (checked mechanically); no decision IDs, plan numbers or phase numbers appear in `calldata_decoder.dart`, `dapp_call_details.dart`, `handle_dapp_requests.dart`, `approve_transaction_drawer.dart`'s edited block, or `web3.dart`; `check_brace_style.sh` exits 0; the one deliberate simplification carries a `ponytail:` marker naming its ceiling and upgrade path (declining every signature until an EIP-712 renderer exists). Only H-1 and H-2 land against this phase.

## Human verification — NOT RUN

**The plans' own `<human-check>` has not been executed.** 30-04 task 3 asks for: *a debug build with a real WalletConnect session, approving one ERC-20 transfer and one Squid swap, confirming the drawer names the token and amount expected, in both light and dark appearance.* No plan records it as done; `STATE.md` line 8 ends with "Next: human walk of the two drawers on a real WalletConnect session".

Everything above was verified against the code and against tests I ran myself. What tests cannot reach, and what therefore remains unconfirmed on real hardware:

1. A real relay session delivering a real dApp payload — every test here drives a fake `ReownWalletKit`.
2. A live Squid swap built by the companion dApp today, rather than one route recorded once on Base. D-11's own UNVERIFIED caveat stands: cross-chain, native-token and multi-hop routes may use different offsets or a different selector. The guards make the failure mode "unreadable", not "wrong" — but that has never been observed against a second live payload.
3. Light-mode legibility on device. Widget tests pump `GWColors.light()` and assert text presence and no exception; they do not measure what the eye sees.
4. The W-1 unit mismatch on a non-ETH chain.

## Verdict

**The phase goal is achieved for three of its four criteria, and the fourth is short by exactly the amount the evidence is short — and says so.**

ERC-20 transfers and approves decode and reach the drawer with the right token, amount and counterparty; unreadable calldata is named unreadable with a warning and can no longer be dressed as a send; the raw params dump and its light-mode-broken dark card are deleted; and the display-only contract is not merely asserted but proven fail-on-mutation by injection, after four waves of edits. The three bugs the phase inherited are gone, with the null-code trap pinned by a test that would catch its return. D-02, D-04 and D-11's guards all hold under test.

The one gap is DAP-02's "→ Y", and the honest reading is that the phase chose a smaller true statement over a larger guessed one on a signing screen — then wrote the shortfall into the requirement, both traceability tables, the summary and the state file rather than ticking it. That is the behaviour this project's no-unearned-PASS rule is meant to produce, and it is why this report records `gaps_found` rather than manufacturing a pass: the criterion as written is not met, and only a human can accept that.

Not yet earned at all: the live walk. Until a debug build with a real WalletConnect session approves one transfer and one swap in both appearances, the last link between "the tests say this renders" and "a user sees this" is unmeasured.

---

_Verified: 2026-09-19 — gates re-run by the verifier, not inherited_
_Verifier: Claude (gsd-verifier)_
