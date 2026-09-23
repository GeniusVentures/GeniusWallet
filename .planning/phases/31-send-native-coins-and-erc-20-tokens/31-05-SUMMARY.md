---
phase: 31-send-native-coins-and-erc-20-tokens
plan: 05
status: complete
requirements: [SEND-06, SEND-07]
key-files:
  modified: [lib/tokens/token_info_screen.dart, test/tokens/coin_page_stat_rail_test.dart, lib/components/coins/view/coins_screen.dart]
  created: [test/dashboard/dashboard_send_entry_test.dart]
actuals: { tokens: 8200, tasks: 2, commits: 2 }
---

# Phase 31 Plan 05: two entry points into Send, and the live testnet walk

`_CoinActionRow` grows a Send `GWButton` beside Swap, present only when `canSignOn` holds for
the selected network; it pushes `/send` with the same symbol-then-fallback and chainId extra
Swap already sends. The coin-page test that claimed Send has no screen and no route -- true
before 31-02 -- now states the real rule. `CoinsScreen`'s dashboard footer grows a bare Send
button keyed off holdings (not the fiat total, which testnet coins leave at zero), pushing
`/send` with no extra so the screen offers its picker; the coin-picker reuse never shows it.

## Baseline vs. after (measured)

`flutter test`: 1672 pass/5 skip -> 1677 pass/5 skip, exit 0 (+5, all new). `flutter analyze`:
"No issues found!" at root and `packages/genius_api`. `dart format --set-exit-if-changed lib
test`, `check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh
--scan-tree`, `check_onboarding_seed_safety.sh`, `check_agent_rules_sync.sh`: all exit 0.
Every touched file's `git ls-files --eol` shows lf.

## Deviations

- **[Observed, not fixed -- out of scope]** `git diff develop -U0 -- lib packages/genius_api |
  grep -cE 'D-0[1-5]|...'` still prints 1: a `(D-03)` citation in `lib/navigation/router.dart`'s
  `/send` route comment, added by 31-02 before this plan's wave started. `router.dart` is not in
  this plan's `files_modified`; left as-is per the scope boundary rule.

## Manual-Only Verification: PENDING (human)

Not run this session -- `flutter run`/`flutter build` are forbidden here (Hive container lock),
and this needs a funded testnet wallet and a live RPC. On Polygon Amoy (80002) or Ethereum
Sepolia (11155111) -- NOT "Base - Sepolia" (chainId 84531 is the retired Base Goerli id):

1. From the dashboard's Send button, pick a coin, send a small native amount.
2. From that coin's page, tap Send (coin preselected), send a small ERC-20 amount.
3. Check: fee shown in review vs. fee charged on the explorer; self-send and contract warnings
   against two prepared addresses; pending -> completed with exactly one history row; the
   explorer link opens the testnet explorer.
4. Record both transaction hashes and the wallet address used, here, once walked.

## Self-Check: PASSED
