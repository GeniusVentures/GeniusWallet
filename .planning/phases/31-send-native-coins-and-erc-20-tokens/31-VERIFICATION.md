---
phase: 31-send-native-coins-and-erc-20-tokens
verified: 2026-09-23T21:25:08Z
status: passed
score: 20/20 must-haves verified (2 by the live walk in 31-UAT.md)
behavior_unverified: 0
overrides_applied: 0
behavior_unverified_items:
  - truth: "On a signable chain a user types an address and an amount of the native coin, sees the EIP-1559 fee before approving, approves, and the coin moves"
    test: "Send a small native amount on Polygon Amoy (80002) or Ethereum Sepolia (11155111) from a funded testnet wallet"
    expected: "The transaction is accepted by the node, mines, and the balance change matches the amount plus the fee shown in review"
    why_human: "Needs a funded testnet wallet and a live RPC. The EIP-1559 type-byte fix (CR-04) is proven only against a local stub server in test/send/send_rpc_test.dart, not against a real chain."
  - truth: "A real native send and a real ERC-20 send land on a testnet and resolve in history without a duplicate row"
    test: "31-VALIDATION.md's Manual-Only walk: dashboard Send (native) + coin-page Send (ERC-20) on Amoy or Sepolia, self-send and contract warnings against two prepared addresses, pending to completed with one row, explorer link opens"
    why_human: "31-05-SUMMARY.md explicitly records this as 'PENDING (human)' -- not run this session. flutter run/build are forbidden in this environment (Hive container lock)."
human_verification:
  - test: "Send a small amount of a chain's native coin from the /send screen (via the dashboard picker) on Polygon Amoy (80002) or Ethereum Sepolia (11155111) -- not Base Sepolia's retired 84531 id"
    expected: "Fee estimate shown in review matches what the explorer reports as charged; the transaction mines; the history row goes pending -> completed with no duplicate"
    why_human: "Requires a funded testnet wallet and a live RPC broadcast; only unit/widget-level evidence exists in the repo"
  - test: "Send a small amount of a held ERC-20 token (e.g. USDC) from a coin page's Send CTA on the same testnet"
    expected: "Review shows the decoded recipient (not the token contract) and the fee in the gas coin; the row resolves to completed and is labelled with the token, not the chain coin"
    why_human: "Same as above -- live broadcast and receipt confirmation needed"
    self_send_and_contract_checks: "Also confirm the self-send and contract-code warnings fire against two prepared addresses during this same walk, per 31-VALIDATION.md"
---

# Phase 31: Send native coins and ERC-20 tokens Verification Report

**Phase Goal:** A user can send a chain's native coin or an ERC-20 token to an address on any EVM
chain the wallet can sign on, see the fee before approving, and find the send in history labelled
with the right asset and the right chain.
**Verified:** 2026-09-23T21:25:08Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | A token transfer row's headline/amount/icon name the token; its Network Fee row names the chain's gas coin | VERIFIED | `Transaction.assetUnit` getter (`packages/genius_api/lib/models/transaction.dart`); `txRowContent` reads it in `transaction_utils.dart`; Network/Network Fee rows keep `coinSymbol` (`transaction_displays.dart:987,994`); `test/dashboard/transaction_asset_chain_test.dart` passes |
| 2 | A row carrying a chain id links to that chain's explorer (8453 basescan, 80002 amoy); an unlisted chain shows no link | VERIFIED | `kExplorerTxBase`/`explorerUrlFor` in `transaction_utils.dart`; named tests "8453 links to basescan", "80002 links to Amoy", "84531 (retired Base Goerli) shows no link" all pass |
| 3 | A row written by the previous 18-field adapter still reads back, both new fields null, every old field intact | VERIFIED | "a legacy 18-field row survives the new adapter" test passes; `writeByte(20)` regenerated adapter, `fields[18] as String?`/`fields[19] as int?` |
| 4 | A dApp-approved ERC-20 transfer is recorded with the token as asset, decoded recipient/amount, gas coin as coinSymbol, and chain id | VERIFIED | `handle_dapp_requests.dart:290-312` builds the record from `summary.recipient`/`summary.amount`; `test/reown/handle_dapp_requests_test.dart` (168 cases) pass, including the assertion for `assetSymbol 'USDC'`, `coinSymbol 'ETH'`, `chainId 8453` |
| 5 | On a signable chain a user types an address and amount of the native coin, sees the EIP-1559 fee before approving, approves, and the coin moves | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | Form/fee/review path is fully wired and unit/widget-tested (`send_screen_test.dart` drawer shows "Gas Fee" ending in the gas coin); the actual on-chain movement is proven only against a local stub RPC in `send_rpc_test.dart`, never a real chain — routed to human verification |
| 6 | The send appears pending the moment it is broadcast and becomes completed/failed once a receipt arrives: one row, never two | VERIFIED (behavioral test) | `transactions.replaceTransaction(resolved)` (WR-21 fix, `send_cubit.dart:697`); named test "a history reload during the poll leaves one row for the send" passes |
| 7 | A fee estimate never reaches the signer as zero; an RPC without EIP-1559 falls back to legacy gas price | VERIFIED | `chooseFeePerGas` in `send_service.dart`; 6 named tests (throw, zero max fee, outlier tip capped, unreadable legacy, both failing throws, zero legacy throws) all pass |
| 8 | A failed signature, a failed estimate, or a balance short of amount plus fee writes nothing and says why | VERIFIED | `settle()`/try-catch guards in `send_cubit.dart`; cubit tests assert "recording storage stays empty in every failure case" |
| 9 | A user can send a held ERC-20 token; review shows the real decoded recipient and the fee in the gas coin | VERIFIED | `buildSendTx` token branch (`0xa9059cbb` transfer selector); `test/send/send_token_test.dart` builds a 6-decimal USDC transfer and asserts the decoded recipient/amount |
| 10 | The built transfer decodes back to exactly the recipient and amount the form holds, or the review refuses | VERIFIED | `builtTxMatches` defined in 31-02, **wired into `review()` in 31-03** (`send_cubit.dart:595-601`, confirmed as a deviation fix in 31-03-SUMMARY.md); `test/send/built_tx_matches_test.dart` passes |
| 11 | A token send is refused before review when the native balance can't pay the fee, or decimals are unknown | VERIFIED | Native-balance-first check (WR-19 fix) and throwing `readTokenBalance` (WR-20 fix) both present and tested in `send_cubit.dart:520-562` |
| 12 | MAX fills the exact token balance for a token, and native balance minus max fee for the native coin, never below zero | VERIFIED | `maxNativeSendable` (clamped at zero) in `send_service.dart:174-176`; MAX cubit/service/screen tests pass |
| 13 | Pasting or typing the wallet's own address shows a self-send warning | VERIFIED | `setRecipient` sets `selfSend` case-insensitively (`send_cubit.dart:291-299`); `recipient_field_test.dart` paste case passes |
| 14 | A recipient with code on-chain shows a contract warning; a stale or failed check never shows a wrong one | VERIFIED | `_checkContract` applies the answer only if `state.recipient` is unchanged (`send_cubit.dart:308-325`); 5 named cases pass |
| 15 | Paste works everywhere; Scan fills the field on Android/iOS/macOS and is absent on Windows/Linux | VERIFIED | `defaultCanScanQr = !(Platform.isWindows \|\| Platform.isLinux)`; `canScan` gating tests pass |
| 16 | A scanned EIP-681 link yields only its 0x address, validated like typing | VERIFIED | `addressFromScan` regex parse (`recipient_field.dart:20-44`); parsing/gating tests pass |
| 17 | On a coin page for a signable network, a Send button next to Swap/Receive opens /send with that coin seated | VERIFIED | `_CoinActionRow` Send button gated on `canSendFrom` (`token_info_screen.dart:775-790`); seeded test taps Send and captures `{'symbol': 'USDC', 'chainId': 80002}` |
| 18 | Dashboard's Assets section offers Send when the wallet holds something on a signable network; opens the picker | VERIFIED | `coins_screen.dart:515-531`, keyed off holdings (not fiat total) and `canSendFrom`; `test/dashboard/dashboard_send_entry_test.dart` (4 cases) pass |
| 19 | Neither entry appears on an unsignable network; the coin-page test states that rule instead of claiming Send doesn't exist | VERIFIED | `grep -c "no screen and no route" test/tokens/coin_page_stat_rail_test.dart` = 0; test now documents "Send is absent because no coin, wallet or signable network is selected" |
| 20 | A real native send and a real ERC-20 send land on a testnet and resolve in history without a duplicate row | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | 31-05-SUMMARY.md records this walk as **"PENDING (human)"**, not performed this session; routed to human verification |

**Score:** 18/20 truths verified (2 present, behavior-unverified — both are the live-chain walk that needs a funded testnet wallet)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `packages/genius_api/lib/models/transaction.dart` | `assetSymbol`/`chainId` HiveFields 18/19, `assetUnit` getter | VERIFIED | Present, regenerated adapter confirmed (`writeByte(20)`) |
| `lib/dashboard/home/widgets/transaction_utils.dart` | `kExplorerTxBase`, `explorerUrlFor` | VERIFIED | Present and tested |
| `packages/genius_api/lib/web3/send_service.dart` | `SendFee`, `chooseFeePerGas`, `buildSendTx`, `pollReceipt`, `settledStatus`, `feePaid`, `maxNativeSendable`, `readHasCode`, chain reads | VERIFIED | All present, unit-tested, no `print()` calls (grep confirms exit 1) |
| `lib/send/send_cubit.dart` | `SendCubit`, `SendState`, `SendReview`, `sendRow`, `builtTxMatches` | VERIFIED | Present, wired, no key material (`grep -rniE "privatekey\|mnemonic" lib/send/` exits 1 per 31-02 acceptance) |
| `lib/send/send_screen.dart` | `SendScreen`, `/send` route target, review drawer | VERIFIED | Reads real `GeniusApi` from `WalletDetailsCubit` (not a fake) at runtime |
| `lib/send/recipient_field.dart` | `RecipientField`, `addressFromScan`, `defaultCanScanQr`, scan page | VERIFIED | Present, all sub-behaviors tested |
| `test/send/*.dart` | Service/cubit/screen/recipient/token/rpc test coverage | VERIFIED | 7 files, all passing (168+ cases in the `test/send/` + related slice run) |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `lib/send/send_cubit.dart` | `GeniusApi.signAndSendTransaction` | the only signing call | WIRED | `submit()` calls it once; key never leaves `genius_api` |
| `lib/send/send_cubit.dart` | `TransactionsCubit.replaceTransaction` | resolved row, exactly once | WIRED | WR-21 fix confirmed in code and by a behavioral test |
| `lib/navigation/router.dart` | `SendScreen` | `/send` GoRoute, `extra` symbol+chainId | WIRED | `grep -n "path: '/send'"` matches once |
| `lib/send/send_cubit.dart` | `tryDecodeErc20Transfer` | review refuses on mismatch | WIRED | `builtTxMatches` called inside `review()` (fixed as a noted deviation in 31-03) |
| `lib/tokens/token_info_screen.dart` | `/send` | push with extra symbol+chainId | WIRED | Confirmed by a seeded widget test that captures the tapped extra |
| `lib/components/coins/view/coins_screen.dart` | `/send` | push with no extra (picker) | WIRED | Confirmed by `dashboard_send_entry_test.dart` |

### Data-Flow Trace (Level 4)

| Artifact | Data Source | Real? | Status |
|----------|-------------|-------|--------|
| `SendCubit` in `send_screen.dart` | `context.read<WalletDetailsCubit>().geniusApi` | Yes — the real `GeniusApi`, not a fake, at runtime | FLOWING |
| Fee estimate | `Web3Client.getGasInEIP1559()` via `readSendFee`, with legacy `getGasPrice()` fallback | Yes — no hardcoded fee value | FLOWING |
| History row | `TransactionStorageService.addTransaction` / `TransactionsCubit.replaceTransaction`, keyed by the real broadcast hash | Yes | FLOWING |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| SEND-01 | 31-01 | History distinguishes asset from chain; old rows still read; explorer/fee row key off chain | SATISFIED | Truths 1-4 |
| SEND-02 | 31-02, 31-03 | Native send with EIP-1559 fee and MAX | SATISFIED (code); live movement HUMAN NEEDED | Truths 5, 7, 8, 12 |
| SEND-03 | 31-03 | ERC-20 send on any `canSignOn` chain, fee shown | SATISFIED | Truths 9, 10 |
| SEND-04 | 31-02 | Broadcast polled to a terminal status; pending row updates | SATISFIED | Truth 6 |
| SEND-05 | 31-03, 31-04 | Address validation, paste/QR, MAX, self-send/contract warnings | SATISFIED | Truths 11, 13-16 |
| SEND-06 | 31-02, 31-05 | Two entry points: coin-page CTA and dashboard picker | SATISFIED | Truths 17-19 |
| SEND-07 | 31-02, 31-05 | Confirm/submit via `SendTransactionDetails`, pending-then-resolved row, coin-page test corrected | SATISFIED (code); live walk HUMAN NEEDED | Truths 5, 6, 17-19, 20 |

**Traceability gap (reported, not a gap in the phase's own work):** `.planning/REQUIREMENTS.md` has no `SEND-*` section — it only carries "v1 Requirements" and "v2 Requirements — Milestone v2.0: Squid Router integration" (verified: `grep -n "SEND" .planning/REQUIREMENTS.md` returns nothing). The SEND-01..07 IDs were coined in `31-RESEARCH.md`'s Phase Requirements table and carried into `31-CONTEXT.md`'s plan list and the ROADMAP's `**Requirements**: SEND-01, ..., SEND-07` line for Phase 31, and every plan's frontmatter cites a subset of them consistently. No requirement ID is orphaned relative to that source; the gap is that REQUIREMENTS.md itself was never updated with a SEND section, which is a documentation-completeness issue for the project, not evidence that any SEND requirement is unimplemented.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `lib/reown/handle_dapp_requests.dart` | 223 | `TODO: CONFIRM NETWORK ON SWAP MATCHES NETWORK SELECTED IN WALLET` | Info (warning-tier, not blocker-tier) | Pre-existing scope note in a file this phase touched; not a `TBD`/`FIXME`/`XXX` debt marker, does not gate any Send must-have |
| `lib/reown/handle_dapp_requests.dart` | 294 | `TODO: we should show a pending transaction until it completes` | Info (warning-tier) | Partially superseded by this phase's IN-09 fix (a pending row IS now written for an unanswered broadcast); the TODO is about surfacing "pending" state in the dApp-approval UI itself, not history — does not gate a Send must-have |

No `TBD`, `FIXME`, or `XXX` debt markers found in any file this phase modified (`transaction.dart`, `transaction_utils.dart`, `transaction_displays.dart`, `send_service.dart`, `genius_api.dart`, `send_cubit.dart`, `send_screen.dart`, `router.dart`, `recipient_field.dart`, `token_info_screen.dart`, `coins_screen.dart`, `web3.dart`) — the debt-marker blocker gate does not fire.

**Documented-but-deferred findings from 31-REVIEW.md / 31-REVIEW-FIX.md** (all iteration-2, explicitly left open by the fixer, not silently missed):
- **IN-10:** a settled Base/Base-Sepolia send's *recorded* fee (`feePaid`) excludes the OP-Stack L1 data fee, while the pre-approval estimate (`maxCost`, used for MAX and the balance gate) correctly includes it via `readSendFee`'s L1-fee read. This is a post-settlement display accuracy gap, not a truth this phase's must-haves assert — reported here for visibility.
- **IN-11:** the payout field's address-error wording doesn't match its checksum-refusal behavior (a different form, `sdk_account_manager.dart`, outside `lib/send/`).
- **IN-12:** overlapping `LoadWallets` settle rounds — bounded and idempotent per the review, not a correctness bug.
- **Lockfile split:** root resolves web3dart 3.0.2, `packages/genius_api` resolves 3.0.3 — deliberately left unaligned; the CR-04 fix makes the signer correct under both, proven by `send_rpc_test.dart`'s "accepted broadcast is a typed EIP-1559 envelope" case run against the app's own 3.0.2 resolution.

### Code Review Cross-Check

`31-REVIEW.md` (iteration 2) found **1 critical** (CR-04: the EIP-1559 type-byte regression that would have broken every send, swap, and dApp transaction) and **6 warnings**. `31-REVIEW-FIX.md` claims all 9 in-scope findings fixed with one commit each. This verifier did not take that claim on faith — each fix was checked directly in the current tree:

- **CR-04** (critical): `prependTransactionType(0x02, ...)` guard present at `web3.dart:744-746`; the regression test (`send_rpc_test.dart`, "an accepted broadcast is a typed EIP-1559 envelope") passes against the app's actual web3dart 3.0.2 resolution.
- **WR-15, WR-17, WR-18, WR-19, WR-20, WR-21, IN-08, IN-09**: each verified directly in source (see Observable Truths table and inline evidence above); all corresponding tests pass.

No discrepancy found between the fix report's claims and the actual code.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Full test suite | `flutter test` | `+1731 ~5: All tests passed!` | PASS (matches orchestrator-claimed baseline) |
| Root analyze | `flutter analyze` | "No issues found!" | PASS |
| `packages/genius_api` analyze | `flutter analyze` (in package dir) | "No issues found!" | PASS |
| EIP-1559 type-byte fix (CR-04) | `flutter test test/send/send_rpc_test.dart` | 15/15 pass, incl. "an accepted broadcast is a typed EIP-1559 envelope" | PASS |
| Legacy Hive row round-trip | `flutter test test/dashboard/transaction_asset_chain_test.dart` | 1/1 named case pass | PASS |
| Explorer chain-keying | same file, `--plain-name "basescan"/"Amoy"/"retired Base Goerli"` | 3/3 named cases pass | PASS |
| One-row settlement (WR-21) | `flutter test test/send/send_cubit_test.dart --plain-name "reload"` | 1/1 pass | PASS |
| Fee fallback (chooseFeePerGas) | `flutter test test/send/send_service_test.dart --plain-name "legacy"` | 6/6 pass | PASS |
| Coin-page Send entry | `flutter test test/tokens/coin_page_stat_rail_test.dart` | includes "Send opens /send with the coin seated on a signable network" | PASS |
| Dashboard Send entry | `flutter test test/dashboard/dashboard_send_entry_test.dart` | included in the 168-case slice run, all pass | PASS |
| Tool gates | `check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh --scan-tree`, `check_onboarding_seed_safety.sh`, `check_agent_rules_sync.sh` | all exit 0 | PASS |

### Probe Execution

Not applicable — this phase has no `scripts/*/tests/probe-*.sh` convention; verification used `flutter test`/`flutter analyze` per the project's own gates, covered above.

### Human Verification Required

#### 1. Native coin send on a live testnet
**Test:** From the dashboard Send picker, send a small amount of Polygon Amoy's (80002) or Ethereum Sepolia's (11155111) native coin. Not "Base Sepolia" — `networks.json`'s 84531 is the retired Base Goerli id; Base Sepolia's real id (84532) is separately supported per 31-CONTEXT.md's later note.
**Expected:** The fee shown in the review drawer is close to what the explorer reports as actually charged; the send resolves from pending to completed with exactly one history row; the explorer link opens the correct testnet explorer.
**Why human:** Needs a funded testnet wallet and a live RPC broadcast. `flutter run`/`flutter build` are forbidden in this environment (Hive container lock). The EIP-1559 type-byte fix (CR-04) that makes this possible at all is proven only against a local stub RPC server in the test suite, never a real chain node.

#### 2. ERC-20 token send on the same testnet, plus recipient warnings
**Test:** From that testnet coin's page, tap Send (coin preselected) and send a small amount of a held ERC-20 token (e.g. USDC on Amoy). During the same session, paste the wallet's own address (expect the self-send warning) and a known contract address (expect the contract warning).
**Expected:** The review shows the decoded real recipient (not the token contract) and the fee in the gas coin; the resolved history row is labelled with the token as the asset and the chain's coin as the fee unit; both warnings fire correctly.
**Why human:** Same live-broadcast requirement as above; the warnings are unit/widget-tested against fakes but not against a live `eth_getCode` answer on a real recipient.

### Gaps Summary

No coded must-have failed. Every truth that code and tests can prove is VERIFIED: the history-model split (SEND-01), the fee/build/poll/settle service, MAX, the recipient-safety UI, and both entry points are all implemented, wired to real data sources (not fakes) at runtime, and covered by passing named tests — including regression tests for the two-round code review's 1 critical and 6 warning findings (CR-04's EIP-1559 type-byte bug in particular, which would have broken every send, swap, and dApp transaction had it shipped unfixed).

The only gap is the one this phase's own artifacts (`31-VALIDATION.md`, `31-05-SUMMARY.md`) already flag as outstanding: the live testnet walk (a real native send and a real ERC-20 send landing on Polygon Amoy or Ethereum Sepolia) has not been performed. This is inherently a human-only step — it needs a funded wallet and cannot be done by an automated verifier — and the phase's own SUMMARY honestly records it as "PENDING (human)" rather than claiming it. Per this verification's instructions, that routes the phase to `human_needed`, not `passed` and not `gaps_found`.

---

_Verified: 2026-09-23T21:25:08Z_
_Verifier: Claude (gsd-verifier)_

## Human verification (2026-09-23)

Both live checks passed on Ethereum Sepolia (11155111), walked by Braian on a Windows debug build of
`plan/send` — native send and ERC-20 send with both warnings. See `31-UAT.md`. The walk first needed
Sepolia's RPC moved off a host that no longer resolves (`2eebacb9`); Base Sepolia's rejected access
token is filed as a todo.
