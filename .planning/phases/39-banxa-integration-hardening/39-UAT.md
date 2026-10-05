---
status: testing
phase: 39-banxa-integration-hardening
source: [39-VERIFICATION.md]
started: 2026-09-30T21:10:00Z
updated: 2026-10-05T12:00:00Z
---

## Current Test

number: 1
name: Build without the key, and a production build while GNUS is unlisted
expected: |
  Reads "Buying isn't set up in this build" and "GNUS isn't on Banxa yet" respectively
awaiting: user response

## Tests

### 1. Build without the key, and a production build while GNUS is unlisted
expected: Reads "Buying isn't set up in this build" and "GNUS isn't on Banxa yet" respectively
result: [pending]
note: 2026-10-05 sandbox build with GNUS unlisted reads "GNUS isn't on Banxa yet" with Check again, fine in both modes and at phone width. The no-key build is not walked yet.

### 2. Buy card, checkout header, result view and Buy orders badge in light and dark, at phone and desktop width
expected: Readable, contrast correct, no overflow
result: passed
note: Windows, 2026-10-05. Seeded Buy orders (dev bubble) show all four buckets correctly. Re-walked after the layout fixes in Gaps.

### 3. Checkout on Windows, macOS, Android (GW_Test AVD) and iOS, including the ID step camera/microphone prompt, Android file upload and the leave prompt; Linux browser flow finishing via polling
expected: Each platform loads checkout in-app (Linux: system browser with waiting screen), prompts are the OS ones, and Done follows the polled status
result: [pending]
note: Windows passed 2026-10-05 (in-app checkout, ID face check, return). macOS, Android, iOS and Linux not walked.

### 4. Rotate the production Banxa key in the Banxa dashboard and set BANXA_API_KEY in the repository Actions secrets
expected: Old key (still in git history and old binaries) is dead; CI builds get the new key masked
result: [pending]

### 5. GATE A, return URL: create one order with geniuswallet://banxa/callback
expected: Order is created; return is followed or harmlessly ignored while polling reaches Done. If Banxa rejects it, switch BanxaApiService.redirectUrl to an https page on gnus.ai
result: passed
note: 2026-10-05, sandbox buying ETH via GW_BANXA_TEST_COIN (GNUS still unlisted). Banxa accepted geniuswallet://banxa/callback and the return was followed.

### 6. GATE B, sandbox buy: build with GW_BANXA_SANDBOX=true and a sandbox key, pay with the test card, reach complete under Buy orders with one toast
expected: Order completes end to end; Done and the toast appear without the return URL
result: [pending]
note: 2026-10-05, ETH stand-in: order reached Payment received after the return. Complete and the toast not yet observed; GNUS itself still unlisted in sandbox.

## Summary

total: 6
passed: 2
issues: 2
pending: 4
skipped: 0
blocked: 0

## Gaps

- Fixed: returning from checkout showed "Complete payment" for a paid order until the next poll, because Banxa still reports pendingPayment for a few seconds. The return now re-reads every 3s for up to 30s.
- Fixed: checkout filled the whole desktop window and its header crowded the phone layout; it is now a 480px dialog on desktop with a trimmed header, and the Buy page header is centred like Swap.
