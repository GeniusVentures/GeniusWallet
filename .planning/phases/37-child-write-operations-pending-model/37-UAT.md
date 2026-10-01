---
status: testing
phase: 37-child-write-operations-pending-model
source: [37-VERIFICATION.md]
started: 2026-09-29T00:00:00Z
updated: 2026-09-29T00:00:00Z
---

## Current Test

number: 1
name: Live walk of all six child operations
expected: |
  Each operation shows its pending badge, then resolves to its toast or reads "Not confirmed yet" at 2:00. Nothing says done without the balance or list changing.
awaiting: user response

## Tests

### 1. Live walk of all six child operations
steps:
  a. From an SDK account that is not a child: "This account" card, "Register as a child of…", pick another of your accounts. Pending, then it appears in that main's list.
  b. Switch the node to the main (the app offers "Switch and continue"). Fund the child: pending, then "Funded…" once its balance rises.
  c. Recover part of it (not the whole balance): pending, then "Recovered…".
  d. Revoke it: confirmation names both accounts; pending, then it leaves the list.
  e. Register again, then from the child "Detach"; register again, then "Move to another main".
  f. While any of these is pending, the switcher's "Node running as" rows are locked with the reason; the active-wallet rows are not.
expected: Every step behaves as described on the live node.
result: [pending]

### 2. Dev-bubble write modes
steps: With `GW_DEV_TOOLS`, open Child wallets; arm "Writes confirm", "Writes time out", "Writes fail" in turn and run each operation.
expected: Confirm → badge then toast ~3 s later; time out → "Not confirmed yet" at 2:00 with a working "Check again"; fail → the SDK-refusal toast and nothing pending.
result: [pending]

### 3. One transfer per child at a time
expected: A main funding two different children never lets the second exceed its real balance. A second Fund or Recover on the same child is refused while the first is pending or timed out (up to 6 minutes after it was sent), with the reason shown.
result: [pending]

### 4. Account switch during a transfer
expected: A Fund or Recover sent from M1 never resolves once the node has switched away from M1, even after switching back; it reads "Not confirmed yet" and keeps its lock and held amount until 6 minutes after it was sent.
result: [pending]

### 5. Mock and real never mix
expected: A real transfer sent before a dev preset is armed never resolves off mock balances, and a mock transfer never resolves off a real read after "Clear".
result: [pending]

### 6. Launch
expected: The Windows debug build starts and the Child wallets screen, its row menus and the "This account" card render without a crash.
result: [pending]

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0
blocked: 0

## Gaps
