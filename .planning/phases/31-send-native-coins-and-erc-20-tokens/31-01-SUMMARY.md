---
phase: 31-send-native-coins-and-erc-20-tokens
plan: 01
status: complete
requirements: [SEND-01]
key-files:
  created: [test/dashboard/transaction_asset_chain_test.dart]
  modified: [packages/genius_api/lib/models/transaction.dart, packages/genius_api/lib/models/transaction.g.dart, lib/dashboard/home/widgets/transaction_utils.dart, lib/dashboard/home/widgets/transaction_displays.dart, lib/reown/handle_dapp_requests.dart, test/reown/handle_dapp_requests_test.dart, .planning/phases/30-dapp-calldata-decoding-end-blind-signing/deferred-items.md]
actuals: { tokens: 4600, tasks: 2, commits: 2 }
---

# Phase 31 Plan 01: the asset/chain split, chain-keyed explorer, an honest dApp receipt

`Transaction` gains `assetSymbol`/`chainId` (nullable, additive); history reads
the asset for title/amount/icon and the chain coin for Network/Network Fee;
the explorer link keys off `chainId`; the dApp receipt records the real
decoded recipient and amount instead of the token contract and zero.

## Baseline vs. after (measured)

`flutter test`: 1590 pass/5 skip → 1599 pass/5 skip, exit 0 (+9, all new).
`flutter analyze`: "No issues found!" at root and in `packages/genius_api`,
before and after. `dart format --set-exit-if-changed lib test`: exit 0.
`check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh`,
`check_onboarding_seed_safety.sh`, `check_agent_rules_sync.sh`: exit 0.
`writeByte(20)` appears once in the regenerated adapter; `git diff --name-only
-- packages/genius_api` lists only the two transaction files.

## Deviations

None — plan executed as written. The tracer's own `<verify>` (an automated
test command, no UI walk) passed as part of committing Task 1; Task 2 depends
directly on Task 1's fields and closes two items phase 30 deferred, so both
ran in this session rather than pausing between them.

## Self-Check: PASSED
