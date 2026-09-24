---
created: 2026-09-23T23:59:00.000Z
title: dApp request labels match coins by network symbol, which Ethereum and Sepolia share
area: correctness
severity: minor
files:
  - lib/reown/handle_dapp_requests.dart
---

## Problem

`handle_dapp_requests.dart:138` finds the token for a dApp request summary by `Coin.networkSymbol`,
which is `network.symbol` - `eth` for both Ethereum (1) and Ethereum Sepolia (11155111). A request on
one chain can be labelled with the other chain's token. It affects what the drawer shows, not what
is signed (the decoded calldata is what gets approved).

## Fix direction

Use the coin list's owning network (`WalletDetailsState.coinsNetwork`, added for Send) or the
request's chain id, not the symbol.
