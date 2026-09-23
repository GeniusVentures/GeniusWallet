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

`_CoinActionRow` grows a Send `GWButton` beside Swap, shown only when `canSignOn` holds for the
selected network; it pushes `/send` with the same symbol and chainId extra Swap sends. The
coin-page test that claimed Send had no screen now states the real rule. `CoinsScreen`'s
dashboard footer grows a bare Send keyed off holdings (not the fiat total, which testnet coins
leave at zero), pushing `/send` with no extra so the screen offers its picker.

## Measured

`flutter test` 1672/5 -> 1677/5 skip, exit 0 (+5, all new). `flutter analyze` clean at root and
`packages/genius_api`; format and all five `tool/` gates exit 0; touched files LF.

## Deviations

A planning-id citation left in `router.dart` by an earlier wave was out of this plan's scope; the
orchestrator removed it afterwards.

## Manual verification: done 2026-09-23

Walked by Braian on Ethereum Sepolia (11155111) on a Windows debug build: a native send and an
ERC-20 send, both confirmed on-chain, plus the self-send and contract warnings. Results are in
`31-UAT.md`. The walk first needed Sepolia's dead RPC host replaced (`2eebacb9`).

## Self-Check: PASSED
