---
sketch: 174
name: accounts-sdk-vs-private
question: "How should the accounts sheet tell SDK accounts apart from private wallets - and what constraints does the code impose?"
winner: null
tags: [mobile, ios, accounts, sdk, wallets, sheet, follows-173]
---

# Sketch 174: SDK accounts vs private wallets

## Design Question

Jakub, 2026-08-06: there also has to be a distinction between SDK accounts and Your Accounts - look
in the code for the best way to present it, and whether there are any constraints.

## What the code says

| | SDK accounts | Private wallets |
|---|---|---|
| Source | `api.getAvailableAccounts()` (the native node) | `_baseWallets`, local storage |
| Type | `WalletType.sgnus` | mnemonic / privateKey / keystore / tracking |
| Created in | `app_bloc.dart:605-628` `_mergeSgnusWallet()` | `LoadWallets` |
| Unit | `currencySymbol: 'minions'` | the network currency |
| Balance read by | the native SDK, `readSuperGeniusTokenAssets` (`wallet_details_cubit.dart:198-206`) | the network RPC |
| Transactions | `SgnusTransactionsScreen` (`dashboard_screen.dart:407-411`) | `TransactionsStream` |
| Name | generated `Super Genius Wallet N` (`app_bloc.dart:616-618`) | the user's |
| Rename / Delete | blocked (`account_drawer.dart:307,320`) | available |
| Disappear | when `!connection.isConnected` (`app_bloc.dart:606-609`) | never |

## Two findings that change the design

**1. These are two independent axes, not two kinds of the same thing.**
Picking in the accounts drawer only calls `walletCubit.selectWallet()` (`account_drawer.dart:69`) - it says
"what am I looking at". Which SDK account is **active on the node** is set by a different control:
`sdk_account_manager.dart:185` sends `SelectSDKAccount` → `api.selectGeniusAccountAsync`.
`SelectSDKAccount` is not sent from anywhere else in `lib/`. The list highlight and the node's active
account are two different states, and the UI never says so.

**2. SDK accounts disappear with no message.** The first lines of `_mergeSgnusWallet()`: no connection →
only `_baseWallets` is returned. The list simply shrinks.

## What changed against 173

- Two sections with headings and a one-sentence explanation of each.
- Balances in their real units (minions vs the network currency), not a shared dollar column.
- An `ACTIVE ON NODE` badge plus a `Set on node` action, separating the two axes.
- An explicit disconnected-node state instead of a silent disappearance.
- The payout address visible in the SDK section - it is what joins the two worlds.
- `VIEW ONLY` on a `tracking` wallet.

## Open

- Whether picking an SDK account to view should **also** set it active on the node.
  The code keeps these separate; merging them would be simpler, but it changes node behaviour.
- What to show when the node is connected but there are no SDK accounts at all.
