---
status: testing
phase: 35-unified-header-switcher
source: [35-VERIFICATION.md]
started: 2026-09-29T00:00:00Z
updated: 2026-09-29T00:00:00Z
---

## Current Test

number: 1
name: Live walk of the unified switcher, desktop and phone
expected: |
  One switcher; each selection changes on its own; Send and Swap name the wallet they spend from.
awaiting: user response

## Tests

### 1. Live walk of the unified switcher, desktop and phone
steps:
  a. Desktop: the header shows one chip (no separate SDK chip); its tooltip reads "Sending from X · Node running as Y".
  b. Open it: "Sending from" section first, "Node running as" second, each with its caption.
  c. Pick another wallet under "Sending from": the SDK account under "Node running as" does not move. Pick another SDK account: the active wallet does not move.
  d. Add wallet (create/import) and "Add from phrase or key" from the switcher; delete a wallet and an SDK account from their row menus.
  e. SDK row menu "View balance" shows that account's SGNUS balance.
  f. Phone: tap the wallet pill, same switcher opens as a bottom sheet.
  g. Send: the review drawer's "From" row shows the wallet name over its short address. Swap: the line above the button reads "Sending from <wallet> · Switch ›"; with a watch-only wallet it reads "Can't sign from <wallet>" and the button stays disabled.
expected: Every step behaves as described on a live node.
result: [pending]

### 2. Light and dark, narrow widths
expected: Section headers, captions, badges and the chip label are legible in both modes; the chip label ellipsizes near the narrowest desktop width and on a small phone without clipping the caret; badges never collide with the wallet name.
result: [pending]

### 3. Many accounts
expected: With several wallets and several SDK accounts, row shape, badges and row menus stay the same as with two.
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps
