---
phase: 39-banxa-integration-hardening
plan: 06
subsystem: banxa-buy
tags: [banxa, buy, cubit, quote]
requires: [39-05]
provides:
  - "defaultFiatCode and presetAmounts (locale fiat, presets scaled from the method minimum)"
  - "BuyGnusCubit and BuyGnusState with ctaFor; orderStarted one-shot stream"
  - "Sandbox coin-list result recorded in 39-VALIDATION.md"
key-files:
  created: [lib/banxa/banxa_helpers/buy_defaults.dart, lib/banxa/banxa_order/buy_gnus_cubit.dart, lib/banxa/banxa_order/buy_gnus_state.dart, test/banxa/buy_defaults_test.dart, test/banxa/buy_gnus_cubit_test.dart]
  modified: [test/banxa/fake_banxa_api.dart, .planning/phases/39-banxa-integration-hardening/39-VALIDATION.md]
status: complete
actuals: {tokens: 21000, tasks: 3, commits: 3}
---
# Phase 39 Plan 06: Buy cubit and defaults Summary

A GNUS-only Buy cubit with a self-refreshing quote, tap-time destination address and watch-only block, proven by tests before any widget exists.

## Result
- Full `flutter test`: 2304 passed, 6 skipped, 0 failed (plan 05 ended at 2277). `flutter analyze lib test` clean. Format, brace and raw-colour scripts exit 0. ID gate printed 0 on both code commits.
- Commits: feat buy_defaults, feat BuyGnusCubit and state, docs sandbox line. No checkpoints or tracer tasks. STATE.md and ROADMAP.md untouched.
- Sandbox coin list: unchecked (no sandbox key in the shell, production not called). BUY-06 will be recorded as blocked on Banxa at the final gate unless a key appears.
- A mutation check (dropping the generation guard) makes the stale-answer test fail. No screen uses the cubit yet; a later plan wires it.

## Decisions
- A fresh quote is never kept across an input change: amount, method or fiat edits clear it at once, only the 10 s refresh keeps the old numbers while requesting.
- A failed quote sets quoteStale on the first attempt too, so the CTA offers "Refresh quote" instead of sitting on "Getting quote...".
- Fiats with no payment methods are dropped at load; none left is loadFailed.
- createOrder also refuses a non-EVM address, and ctaFor disables the button for it (the plan named only watch-only).
- A create response with an empty id or URL is treated as the same plain failure.

## Deviations from Plan
- [Rule 2] ctaFor and createOrder block non-EVM addresses, as above; the threat register asks for the `isEvmAddress` check at the tap.
- FakeBanxaApi gained more than the two fields: `listError`, `quoteHandler`, and request recorders (`quoteRequests`, `createRequests`, `listCalls`) the tests need.
- Task 1 tests and code were written together, not RED first; the rounding logic is covered by the 1/2/2.5/5 property test.

## Self-Check: PASSED
All five new files exist, three commits are in `git log`, no trailer in any message, no key-like value in the diff.
