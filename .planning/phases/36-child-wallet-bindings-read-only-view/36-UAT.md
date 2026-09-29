---
status: testing
phase: 36-child-wallet-bindings-read-only-view
source: [36-VERIFICATION.md]
started: 2026-09-29T00:00:00Z
updated: 2026-09-29T00:00:00Z
---

## Current Test

number: 1
name: Live child list and balances
expected: |
  The running SDK account's "Child wallets" screen lists its registered children with correct GNUS balances.
awaiting: user response

## Tests

### 1. Live child list and balances
steps:
  a. Open the switcher; on the "Node running as" account's row menu, "Child wallets" is enabled (disabled on the other rows, with the reason).
  b. It opens a screen whose header names that account (wallet name over short address).
  c. With a child registered on the testnet: the child appears with its wallet name (or "Unlinked") and short address, and a GNUS balance that matches the node.
  d. With none: "No child wallets registered under this account." With the node down: "Node not running".
  e. Leave the screen open: it refreshes on its own every ~10 seconds; the refresh button re-reads at once.
expected: Each step behaves as described.
result: [pending]

### 2. Dev-bubble presets
steps:
  a. Build with `--dart-define-from-file=squid.local.json` (it carries `GW_DEV_TOOLS`) and open the Child wallets screen.
  b. In the dev bubble's CHILD WALLETS section, switch each preset (none, one child, three children, query error, node not running) and clear.
expected: The open screen follows each preset: empty, one row, three rows (one zero balance, mixed linked/unlinked), error with Retry, "Node not running"; clearing returns to live data.
result: [pending]

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
