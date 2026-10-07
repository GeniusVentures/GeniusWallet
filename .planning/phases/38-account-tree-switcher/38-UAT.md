---
status: testing
phase: 38-account-tree-switcher
source: [38-VERIFICATION.md]
started: 2026-09-29T00:00:00Z
updated: 2026-09-29T00:00:00Z
---

## Current Test

number: 1
name: One account list with nested children
expected: |
  The switcher shows one "Accounts" list; each child sits indented under its main, once.
awaiting: user response

## Tests

### 1. One account list with nested children
steps:
  a. Open the switcher on desktop and at phone width. One "Accounts" section; no "Sending from" / "Node running as" lists.
  b. Each SDK account shows on its wallet's row; an unlinked account has its own row; watch-only rows never offer "Run node as this".
  c. With the node running and a child registered, the child sits under its main (chevron collapses it). With the node down, the list is flat with "Child wallets show while the node is running."
expected: Each step behaves as described.
result: [pending]

### 2. Two independent tags
steps: Tap a row, then use "Run node as this" on a different row.
expected: Tapping moves only "Selected"; "Run node as this" moves only "On node", and is refused with the reason while a child operation from the running account is pending.
result: [pending]

### 3. Child actions from the tree
steps: On a nested child row menu, Fund, Recover, Revoke.
expected: Same pending badge, lock and toast as on the Child wallets screen.
result: [pending]

### 4. Dev presets repaint the open switcher
steps: With `GW_DEV_TOOLS`, keep the switcher open and switch CHILD WALLETS presets.
expected: The tree repaints to match each preset without closing.
result: [pending]

### 5. Light-mode visual pass
expected: Tags, chevron, indentation and dimmed locked rows read clearly in light and dark mode.
result: [pending]

## Summary

total: 5
passed: 0
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps
