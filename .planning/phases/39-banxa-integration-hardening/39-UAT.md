---
status: testing
phase: 39-banxa-integration-hardening
source: [39-VERIFICATION.md]
started: 2026-09-30T21:10:00Z
updated: 2026-09-30T21:10:00Z
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

### 2. Buy card, checkout header, result view and Buy orders badge in light and dark, at phone and desktop width
expected: Readable, contrast correct, no overflow
result: [pending]

### 3. Checkout on Windows, macOS, Android (GW_Test AVD) and iOS, including the ID step camera/microphone prompt, Android file upload and the leave prompt; Linux browser flow finishing via polling
expected: Each platform loads checkout in-app (Linux: system browser with waiting screen), prompts are the OS ones, and Done follows the polled status
result: [pending]

### 4. Rotate the production Banxa key in the Banxa dashboard and set BANXA_API_KEY in the repository Actions secrets
expected: Old key (still in git history and old binaries) is dead; CI builds get the new key masked
result: [pending]

### 5. GATE A, return URL: create one order with geniuswallet://banxa/callback
expected: Order is created; return is followed or harmlessly ignored while polling reaches Done. If Banxa rejects it, switch BanxaApiService.redirectUrl to an https page on gnus.ai
result: blocked
reason: Banxa does not list GNUS (production or sandbox, checked 2026-09-30)

### 6. GATE B, sandbox buy: build with GW_BANXA_SANDBOX=true and a sandbox key, pay with the test card, reach complete under Buy orders with one toast
expected: Order completes end to end; Done and the toast appear without the return URL
result: blocked
reason: Banxa does not list GNUS in sandbox (checked 2026-09-30)

## Summary

total: 6
passed: 0
issues: 0
pending: 4
skipped: 0
blocked: 2

## Gaps
