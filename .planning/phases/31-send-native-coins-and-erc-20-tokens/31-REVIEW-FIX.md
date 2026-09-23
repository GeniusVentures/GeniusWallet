---
phase: 31-send-native-coins-and-erc-20-tokens
fixed_at: 2026-09-23T20:51:02Z
review_path: .planning/phases/31-send-native-coins-and-erc-20-tokens/31-REVIEW.md
iteration: 1
findings_in_scope: 19
fixed: 19
skipped: 0
status: all_fixed
---

# Phase 31: Code Review Fix Report

**Fixed at:** 2026-09-23T20:51:02Z
**Source review:** 31-REVIEW.md
**Iteration:** 1
**Scope:** every Critical and every Warning, CR-01 to CR-03 and WR-01 to WR-16. The Info findings were out of scope. The one exception is IN-04's "D-01" in `test/send/send_token_test.dart`, which was cleaned because that file was being edited anyway.

**Summary:** 19 in scope, 19 fixed, 0 skipped. There is one commit per finding. Each commit has a regression test, and each test was confirmed to fail on the pre-fix source (`git stash` of the fix, then run the test).

## Fixed Issues

| ID | Commit | What changed |
|----|--------|--------------|
| CR-01 | 3abf809a | The drawer footer now pops `Navigator.of(context, rootNavigator: true)`. `cancelReview` is skipped once `/send` is unmounted. There are 3 new tests that mount `/send` inside a `GoRouter` `ShellRoute`: Send signs, Cancel closes only the drawer, and dismissing after leaving the page raises no StateError. |
| CR-02 | 7b456bb2 | `SendReview` now carries the coin's `decimals`. Every drawer figure uses `formatTokenAmount`, so no double math reaches the screen. The test sends 100 USDC and checks the drawer shows `100 USDC`. |
| CR-03 | c13fbcc1 | `addressFromScan` parses the payload as an EIP-681 URI. For `/transfer`, it seats `?address=`. It rejects other functions and hex runs longer than 40 characters. |
| WR-01 | 2c025467 | Every emit in `review()` after an await now goes through `settle()`, which drops the result if the recipient or amount changed while the reads ran. |
| WR-02 | db998f58 | A throw from the sign call now frees the form with an error. Each Hive write is guarded, so the live history row is always added after a broadcast. |
| WR-03 | 4ed40a3f | The signer now calls `signTransaction` and then `sendRawTransaction`. When the node never answers, it returns `ApiResponse.unconfirmed(keccak256(signed))`; an `RPCError` still returns no hash. The cubit writes an unconfirmed send as a pending row, polls it, and says to check history before sending again. |
| WR-04 | fde1ed93 | `isEvmAddress` now enforces the EIP-55 checksum on mixed-case input (lowercase and uppercase still pass). This applies to every caller. Send refuses the zero address, and the field names a checksum typo. |
| WR-05 | 0ea2eb4a | The drawer shows a `Network` row and a copyable `Token` contract row. The `SendTransactionDetails` doc was trimmed to 3 lines because it cited planning ids. |
| WR-06 | 08153785 | The token balance is read before `estimateGas`. The test fake now reverts on over-balance the way a real chain does. |
| WR-07 | f27bf676 | `readSendFee` and `estimateSendFee` take a `value`, and a native send is simulated with its amount. |
| WR-08 | d314f469 | The comment is corrected. `chooseFeePerGas` falls back to the legacy price when the market tip is above the node's `eth_gasPrice`. That ceiling is marked with a `ponytail:` comment. |
| WR-09 | 15b6ac9b | `SendFee.l1Fee` is included in `maxCost`. On OP-Stack chain ids, `readSendFee` reads `GasPriceOracle.getL1FeeUpperBound(size)`. A failed read throws rather than defaulting to 0. |
| WR-10 | b7ba9763 | A new shared helper, `canSendFrom(wallet, network)`, excludes `tracking` and `sgnus` wallets. It is used at all three gates. |
| WR-11 | 9b175534 | A new function, `settlePendingSends`, runs once after history loads (in AppBloc). It re-reads the receipt of each pending transfer and overwrites the row by hash (new `TransactionsCubit.replaceTransaction`). A pending transfer's fee row now reads "Max Network Fee". |
| WR-12 | e793225a | The toast now follows the settled status: failed, pending ("still confirming", or the unconfirmed-broadcast note), or complete. |
| WR-13 | 0d4e7c4d | `SendState` now has `recipientError`, `amountError` and a form-level `error`. The form-level error appears in a `GWWarningNote` live region above Review. |
| WR-14 | eb21f645 | In `networks.json`, Base Sepolia's chain id is now 84532. `84532` is added to the explorer map. The test now checks that 84532 links to sepolia.basescan, that 84531 still shows no link, and that the catalogue entry is 84532. |
| WR-15 | 71d885ea | For `unverifiedToken`, the amount is recorded as `"<n> base units"`. A token call that also moved native value records a second `TransferRecipients` row for that value. |
| WR-16 | 95d7c6b1 | `rpcReadTimeout` (15 s) now applies to every send read and to the shared `rawBalanceOf`. The tests run against a localhost server that never answers. |

**Needs human verification (logic, not just syntax):** WR-03 treats "no answer from the node" as possibly broadcast and an RPC error as definitely rejected. WR-08 uses the legacy gas price as the ceiling for the market tip. WR-09 uses a 155-byte-plus-calldata bound on transaction size and assumes a post-Fjord oracle. WR-11 re-reads pending rows once per launch, from AppBloc. CR-01 is proven in a ShellRoute test, but the live walk in the real app is still open.

## Notes for the reader

- **WR-14:** a selection saved against 84531 (the Hive `selectedNetworkKeyChainId`) no longer matches, and `AppBloc` falls back to `networks.first`. The user has to pick Base Sepolia again. Nothing else in `lib/`, bridge, squid or the native configs reads 84531 or 84532.
- **WR-11 ceiling:** a dropped transaction never gets a receipt, so its row stays pending. That limit is marked with a `ponytail:` comment.
- **WR-16:** `rpcReadTimeout` is a top-level variable only so the tests can shorten it.
- **WR-03:** the swap and dApp callers still check only `isSuccess`, so their behaviour is unchanged.

## Verification

Every check ran in the **main checkout** (`workflow.use_worktrees: false`, branch `plan/send`).

- `dart format --output=none --set-exit-if-changed lib test` gave `Formatted 444 files (0 changed)`, exit 0.
- `flutter analyze` at the root: `No issues found! (ran in 8.0s)`, exit 0.
- `flutter analyze` in `packages/genius_api`: `No issues found! (ran in 1.2s)`, exit 0.
- `flutter test`: `00:36 +1716 ~5: All tests passed!`. That is 1716 passed and 5 skipped, against a baseline of 1677 passed and 5 skipped, so this run adds 39 tests.
- `bash tool/check_brace_style.sh` and `bash tool/check_raw_colors.sh` both exited 0.
- `bash tool/check_no_new_key_logging.sh --scan-tree` exited 0 (`OK: no key logging ...`).
- `bash tool/check_onboarding_seed_safety.sh` passed all seven checks.
- `bash tool/check_agent_rules_sync.sh` reported `PASS: .github/copilot-instructions.md is in step with AGENTS.md.`
- `git ls-files --eol` shows `i/lf w/lf` for all 30 files touched.

---

_Fixed: 2026-09-23T20:51:02Z_
_Fixer: gsd-code-fixer_
_Iteration: 1_
