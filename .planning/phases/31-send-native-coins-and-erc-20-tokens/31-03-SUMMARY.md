---
phase: 31-send-native-coins-and-erc-20-tokens
plan: 03
status: complete
requirements: [SEND-02, SEND-03, SEND-05]
key-files:
  created: [test/send/send_token_test.dart]
  modified: [packages/genius_api/lib/web3/send_service.dart, lib/send/send_cubit.dart, lib/send/send_screen.dart, test/send/send_service_test.dart, test/send/send_cubit_test.dart, test/send/send_screen_test.dart]
actuals: { tokens: 7700, tasks: 2, commits: 3 }
---

# Phase 31 Plan 03: ERC-20 sends and MAX

`buildSendTx` gains a token branch encoding `transfer` calldata against the
existing ABI; `SendCubit` gates a token send on the gas coin covering the
fee and the raw token balance covering the amount, and now runs every
built transaction through `builtTxMatches` before it reaches review. MAX
fills the exact raw token balance, or the native balance minus the max
fee for the gas coin, clamped at zero.

## Baseline vs. after (measured)

`flutter test`: 1633 pass/5 skip -> 1647 pass/5 skip, exit 0 (+14, all
new). `flutter analyze`: "No issues found!" at root and
`packages/genius_api`, before and after. `dart format
--set-exit-if-changed lib test` (plus `send_service.dart`),
`check_brace_style.sh`, `check_raw_colors.sh`,
`check_no_new_key_logging.sh --scan-tree`, `check_onboarding_seed_safety.sh`
and `check_agent_rules_sync.sh`: all exit 0. Every touched file's
`git ls-files --eol` shows lf.

## Deviations

- **[Rule 2]** Wired `builtTxMatches` into `review()` -- 31-02 defined it
  but never called it; now checked on both branches, refusing with
  "Couldn't build this transfer." on a mismatch.
- **[Rule 2]** Added the MAX screen test and a token dust-digit MAX test,
  not in task 2's `files_modified` but required by its own criteria.

## Self-Check: PASSED
