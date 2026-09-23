---
status: testing
phase: 31-send-native-coins-and-erc-20-tokens
source: [31-VERIFICATION.md]
started: 2026-09-23T21:40:00Z
updated: 2026-09-23T21:40:00Z
---

## Current Test

number: 1
name: Native coin send on a testnet
expected: |
  On Polygon Amoy (80002) or Ethereum Sepolia (11155111), Send a small native amount to a second
  address you control. The review drawer shows the network, recipient, amount and a fee before
  approving; Send in the drawer signs (it does not close the page); history shows the row pending,
  then completed under the same hash with no duplicate; the explorer link opens the testnet explorer
  on that hash; the fee charged is at most the fee shown.
awaiting: user response

## Tests

### 1. Native coin send on a testnet
expected: Fee shown before approving; the drawer's Send signs; one history row goes pending → completed; the explorer link opens the right testnet explorer; fee charged ≤ fee shown. Record the hash and wallet address.
result: [pending]

### 2. ERC-20 send, plus the self-send and contract warnings
expected: On the same testnet, a held ERC-20 sends with its own decimals shown correctly in the drawer (not 10^12 too small) and the fee in the gas coin; one history row labelled with the token, not the gas coin, goes pending → completed; pasting your own address shows the self-send warning; pasting a contract address (e.g. the token's own contract) shows the contract warning. Record the hash.
result: [pending]

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
