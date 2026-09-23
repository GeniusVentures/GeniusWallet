---
status: complete
phase: 31-send-native-coins-and-erc-20-tokens
source: [31-VERIFICATION.md]
started: 2026-09-23T21:40:00Z
updated: 2026-09-23T22:40:00Z
---

## Current Test

[testing complete]

## Tests

### 1. Native coin send on a testnet
expected: Fee shown before approving; the drawer's Send signs; one history row goes pending → completed; the explorer link opens the right testnet explorer; fee charged ≤ fee shown. Record the hash and wallet address.
result: pass (2026-09-23, Ethereum Sepolia 11155111, walked by Braian; hash not recorded)

### 2. ERC-20 send, plus the self-send and contract warnings
expected: On the same testnet, a held ERC-20 sends with its own decimals shown correctly in the drawer (not 10^12 too small) and the fee in the gas coin; one history row labelled with the token, not the gas coin, goes pending → completed; pasting your own address shows the self-send warning; pasting a contract address (e.g. the token's own contract) shows the contract warning. Record the hash.
result: pass (2026-09-23, Ethereum Sepolia 11155111, walked by Braian: token amount in its own decimals, fee in ETH, network and contract shown, one token-labelled row pending then completed, self-send and contract warnings both shown)

## Summary

total: 2
passed: 2
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps
