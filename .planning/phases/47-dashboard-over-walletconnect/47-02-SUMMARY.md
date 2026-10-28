---
phase: 47-dashboard-over-walletconnect
plan: 02
subsystem: gnus-bridge
tags: [walletconnect, parity, contract]
requires: [47-01 handleGnusRequests and FakeWalletKit]
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
- Cases: getAccounts; estimate (priced, `-32602`); listJobs; getJob (no record, a record); getEarnings; an
  error with `data.reason` (`-32012 view_only`); `4200` for the retired method; submit over WalletConnect then
  the same key directly (equal answers, one burn).
- Mutation: sending the null result as a bare null fails the null-encoding test. Restored.

## Contract changes (shared with the dashboard session)
All in `.planning/research/v4.0-gnus-rpc-contract.md`, marked `(D, 2026-10-28)`. The encoding is what the
context decided, so the dashboard's decode is unchanged; the doc now states it.
- Section 2: four bullets after the WalletConnect bullet (approval rule, Verify-attested origin and fail-closed
  rule with the dev loopback exception, error-data and `{}` encoding, 11 minute request lifetime). One word
  changed in the existing bullet: "approves a session" became "approves a gnus session", since a proposal with
  no gnus method is approved as an ordinary dApp.
- Section 4: one paragraph, `disconnect` over WalletConnect is `session_delete` or `session_expire`.
- Section 6: one bullet, WalletConnect origins are checked with Reown Verify, not the WebView allowlist.

## Deviations
None. The plan said fix only the encoding if a case differs; none did.

## Known stubs
None.

## Self-Check: PASSED
