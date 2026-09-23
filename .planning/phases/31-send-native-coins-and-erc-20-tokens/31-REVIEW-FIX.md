---
phase: 31-send-native-coins-and-erc-20-tokens
fixed_at: 2026-09-23T21:16:25Z
review_path: .planning/phases/31-send-native-coins-and-erc-20-tokens/31-REVIEW.md
iteration: 2
findings_in_scope: 9
fixed: 9
skipped: 0
status: all_fixed
---

# Phase 31: Code Review Fix Report (iteration 2)

**Fixed at:** 2026-09-23T21:16:25Z
**Source review:** 31-REVIEW.md (iteration 2)
**Iteration:** 2
**Scope:** CR-04, WR-15 and WR-17 to WR-21. IN-08 and IN-09 were added because they are small and sit in the same code. IN-10 to IN-12 stay open and are not fixed here.

**Summary:** 9 in scope, 9 fixed, 0 skipped. There is one commit per finding, and each has a regression test under the root `test/`, so it runs against the app's web3dart 3.0.2. Each test was run against the pre-fix source first and failed there.

## Fixed Issues

| ID | Commit | What changed |
|----|--------|--------------|
| CR-04 | 1c3f18e1 | After `signTransaction`, the signer adds web3dart's own `prependTransactionType(0x02, …)` when the transaction is EIP-1559 and the first byte is `>= 0xc0` (a bare RLP list). 3.0.3 already returns `0x02…`, so it is left alone. The hash is taken from the final bytes. Tests: the broadcast starts with `0x02` on both the accepted path and the unanswered path, and the hash equals `keccak256` of those bytes. Before the fix the first byte was `0xf8`. No dependency versions changed. |
| WR-15 | d76c5fae | The detail drawer adds an "Also sent `<n> <gas coin>`" row for each `recipients.skip(1)` on a sent, non-SDK transaction. SDK (`isSGNUS`) transfers are skipped, because their extra recipients are UTXO outputs. |
| WR-17 | c76818ea | Swap's `send` now checks `isSuccess`. An unconfirmed hash throws `SwapBroadcastUnanswered`, and `executeSwap` maps that to a new outcome, `SwapSendUnconfirmed`. **Decision:** no row is written, because nothing re-polls a stored swap, so a pending row would never settle. There is no poll and no success toast. The message reads "may or may not have been sent… check your balance and transactions before you try again." The inline notice header changed from "did not go through" to "did not complete", so it no longer contradicts that message. Tests: the orchestrator, the message, and a screen test that runs the real `executeSwap` against the screen's own `send` with an `ApiResponse.unconfirmed` API. |
| WR-18 | 3dc5184f | `signTransaction` (the nonce read), `sendRawTransaction` and the diagnostic receipt read each take `.timeout(rpcReadTimeout)`. A `FormatException` (the node answered with non-JSON, such as HTML) is now an error with no hash. Timeouts and IO failures stay unconfirmed. There are 4 localhost tests: a stalled nonce read, a stalled broadcast, an HTML 502, and a stalled receipt read after a send the node accepted. |
| WR-19 | 15597e09 | `review()` reads the native balance before the estimate and refuses `rawAmount > balance` on the Amount field. The same read is reused for the amount-plus-fee check and the token-fee check. The test fake's `estimateSendFee` now throws when `value > balance`, the way geth does. |
| WR-20 | b679d4a8 | The body of `rawBalanceOf` moved into a new throwing `Web3.readTokenBalance`, exposed as `GeniusApi.readTokenBalance`. `rawBalanceOf` wraps it and still returns zero on failure, for the swap's balance list. `review()` and `useMax()` use the throwing version and say "Couldn't read your USDC balance." The send test fakes now override `readTokenBalance`. |
| WR-21 | be69868a | `submit()` now calls `transactions.replaceTransaction(resolved)` instead of `addTransaction`. The test reloads stored rows into the cubit during the poll and expects exactly one completed row. |
| IN-08 | 450a5275 | `!context.mounted \|\| cubit.isClosed` now guards both answers from the drawer. The test leaves `/send` under the open drawer, taps Send, and expects no StateError and nothing signed. |
| IN-09 | dec50221 | When a dApp broadcast fails but carries a hash, it is written as a pending `transfer` row, which `settlePendingSends` resolves at launch. A warning toast tells the user to check history before trying again. The dApp still gets an error, and that answer is inside the retry loop, so a relay throw cannot skip the row. |

**Needs human verification (logic):**
- **CR-04:** check this on a real chain once: the `0xc0` test for detecting a bare body, and a live send on Amoy or Base Sepolia.
- **WR-17:** decide whether dropping the swap's unconfirmed hash is the right call. The alternative is a pending swap row that nothing ever settles.
- **WR-18:** a `FormatException` is classed as "not taken".
- **IN-09:** the dApp is told the call failed while history shows it as pending.

## Remaining (documented, not fixed)

- **IN-10:** a settled Base send records the fee without the L1 data fee.
- **IN-11:** the payout field's address error wording, and the `0X` prefix case.
- **IN-12:** overlapping settle rounds on `LoadWallets`.
- **Lockfiles:** the root still resolves web3dart 3.0.2 and `packages/genius_api` resolves 3.0.3. Versions were deliberately not bumped. The signer is now correct under both.

## Verification

Every check ran in the **main checkout** (`workflow.use_worktrees: false`, branch `plan/send`).

- `dart format --output=none --set-exit-if-changed lib test` gave `Formatted 444 files (0 changed)`, exit 0.
- `flutter analyze` at the root: `No issues found! (ran in 5.4s)`, exit 0.
- `flutter analyze` in `packages/genius_api`: `No issues found! (ran in 1.1s)`, exit 0.
- `flutter test`: `00:28 +1731 ~5: All tests passed!`. That is 1731 passed and 5 skipped, against a baseline of 1716 and 5, so this run adds 15 tests.
- `check_brace_style.sh` and `check_raw_colors.sh` both exited 0.
- `check_no_new_key_logging.sh --scan-tree` exited 0.
- `check_onboarding_seed_safety.sh` passed all seven checks.
- `check_agent_rules_sync.sh` reported PASS.
- `git ls-files --eol` shows `i/lf w/lf` for all 18 files touched. No planning ids, test-file names or `print(` appear in the added lines.

---

_Fixed: 2026-09-23T21:16:25Z_
_Fixer: gsd-code-fixer_
_Iteration: 2_
