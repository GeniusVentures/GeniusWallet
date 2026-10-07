---
status: testing
phase: 40-always-available-gnus-bridge
source: [40-VERIFICATION.md]
started: 2026-10-07T00:00:00Z
updated: 2026-10-07T00:00:00Z
---

## Current Test

number: 1
name: Earning wallet bridges from the GNUS coin page
expected: |
  On Windows, dark and light, the GNUS coin page of the earning wallet shows Bridge enabled with no
  caption, and tapping it opens the bridge on GNUS for the selected network.
awaiting: user response

## Tests

### 1. Earning wallet bridges from the GNUS coin page
expected: Bridge enabled, no caption, opens the bridge on GNUS for the selected network (dark and light).
result: [pending]

### 2. Earning switch updates the caption
expected: While switching earning the caption reads "Switching earning. Try again soon."; afterwards the old wallet reads "Only the earning wallet can bridge." and the new one is enabled.
result: [pending]

### 3. Child wallet and other-network cases
expected: A registered child reads "Child wallets can't bridge."; a wallet whose GNUS is on another network reads "GNUS is on {network}. Switch network."
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
