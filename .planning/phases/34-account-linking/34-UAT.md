---
status: testing
phase: 34-account-linking
source: [34-VERIFICATION.md]
started: 2026-09-29T00:00:00Z
updated: 2026-09-29T00:00:00Z
---

## Current Test

number: 1
name: Live-testnet walk of account linking
expected: |
  Every SDK account row names its wallet; no "Super Genius Wallet N" row appears.
awaiting: user response

## Tests

### 1. Live-testnet walk of account linking
steps:
  a. Import a key wallet: its SDK row shows the wallet's name at once.
  b. Delete that wallet from the drawer: the SDK row reads "<name> (wallet removed)".
  c. Re-import the same wallet: the SDK row's name comes back.
  d. Delete an SDK account that has a linked wallet: the dialog names the wallet, then both are removed.
  e. On an install with SDK accounts from before this change: after one app start, accounts matching a stored wallet show its name; the rest read "Unlinked", never hidden.
expected: Each step behaves as described; no orphan "Super Genius Wallet N" row at any point.
result: [pending]

### 2. Links are never guessed
expected: No code path assigns a link by name, order or recency. Links come only from a single new address after an add, the SDK's own start address, or a one-to-one leftover pair during backfill.
result: [pending]

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
