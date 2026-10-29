---
phase: 47-dashboard-over-walletconnect
plan: 02
subsystem: gnus-bridge
tags: [walletconnect, parity, contract]
provides: [parity test for all six methods, WalletConnect notes in the gnus rpc contract]
status: complete
actuals: {tokens: 3300, tasks: 2, commits: 2}
key-files:
  created: [test/reown/gnus_wallet_connect_parity_test.dart]
  modified: [.planning/research/v4.0-gnus-rpc-contract.md]
key-decisions: [the encoding in 47-01 matches the context, so no code changed here]
---

# Phase 47 Plan 02: Parity and the contract notes

Every gnus method answers over WalletConnect as it does through the handler directly, once the dashboard
applies the documented decode (an error message that is a JSON object with `message` carries `data`; `{}` is
null). No case differed, so `gnus_wallet_connect.dart` did not change.

## Verification
- `flutter test test/reown/gnus_wallet_connect_parity_test.dart`: 11 passed. `test/reown test/gnus_bridge`
  passed together.
- Cases: all six methods, `-32602`, `-32012 view_only` with data, `4200`, and a submit replayed directly
  (equal answers, one burn).
- Mutation: sending the null result as a bare null fails the null-encoding test. Restored.

## Contract changes (shared with the dashboard session)
All in `.planning/research/v4.0-gnus-rpc-contract.md`, marked `(D, 2026-10-28)`. The encoding is what the
context decided, so the dashboard's decode is unchanged; the doc now states it.
- Section 2: four bullets (approval rule, Verify-attested origin and fail-closed rule with the dev loopback
  exception, error-data and `{}` encoding, 11 minute request lifetime). One word changed in the existing
  bullet: "approves a session" became "approves a gnus session" (a non-gnus proposal is an ordinary dApp).
- Section 4: one paragraph, `disconnect` over WalletConnect is `session_delete` or `session_expire`.
- Section 6: one bullet, WalletConnect origins are checked with Reown Verify, not the WebView allowlist.

Deviations: none.
Known stubs: none. Self-Check: PASSED
