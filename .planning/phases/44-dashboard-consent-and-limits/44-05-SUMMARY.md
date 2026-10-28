---
phase: 44-dashboard-consent-and-limits
plan: 05
subsystem: gnus-bridge
tags: [security, test, secrets]
requires: [44-02, 44-03]
provides: [secret-leak sweep over every gnus method]
affects: [test/gnus_bridge]
key-files:
  created: [test/gnus_bridge/gnus_secret_leak_test.dart]
  modified: [test/gnus_bridge/gnus_fakes.dart]
status: complete
actuals: {tokens: 40000, tasks: 2, commits: 2}
---

# Phase 44 Plan 05: Secret-leak test Summary

One test plants a fake key and a fake 12-word phrase in every text path the fake wallet has, drives all six methods on success and failure, and fails if any output carries them.

## Commits
- e46879b4 fixtures, detector with positive and negative controls, 13-scenario sweep
- the Sentry commit that follows it: dropping transport, control events, sweep in a guarded zone

## What it covers
- Forms: key as hex (both cases, with and without `0x`), base64 and unpadded base64url; phrase as written, as UTF-8 hex and as base64.
- Planted in: `getSelectedAccountMnemonic`, the cost, balance, gas, burn and SDK-net errors, and the selected wallet's name.
- Collected and checked: 30 replies, events from `eventsFor`, connect and confirm arguments, every `debugPrint` line, and Sentry events.
- Paths: happy path, cost throw, cost 0, unreadable balance, gas error, burn error, signed-then-refused burn, process failure, net read throw, declined connect, declined confirm, rate-limited prompt, bad params, unknown method.

## Results
- `test/gnus_bridge`: 217 passed (212 before). No leak was found, so no source change.
- Teeth: making the catch-all log line print `$e` instead of the type made the sweep fail; reverted.
- The Sentry group asserts a direct capture and an uncaught-error capture are both flagged by the detector; the sweep itself produces no Sentry events.

## Decisions
- The phrase and key are obvious fakes (`alpha bravo ...`, bytes 0x01..0x20), not a BIP39 vector.
- `GnusHarness.create` takes an optional api so the test can plant fixtures.

## Deviations
None.

## Known Stubs
None.

## Self-Check: PASSED
