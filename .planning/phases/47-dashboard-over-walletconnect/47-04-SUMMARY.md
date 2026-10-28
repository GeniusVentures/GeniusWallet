---
phase: 47-dashboard-over-walletconnect
plan: 04
subsystem: walletconnect
tags: [reown, events, queue, expiry]
requires: [47-01 handleGnusRequests, 47-02 wire encoding]
provides: [per-session gnus event forwarding, ordered per-topic sends, lifecycle tests]
status: complete
actuals: {tokens: 7200, tasks: 2, commits: 2}
key-files:
  created: [test/reown/gnus_wallet_connect_lifecycle_test.dart]
  modified: [lib/reown/gnus_wallet_connect.dart]
key-decisions: [replies and events share one future chain per topic, a failed emit is dropped]
---

# Phase 47 Plan 04: Live sessions

A connected page now hears the wallet's account, network and own-job changes as `session_event` on
`eip155:80002`, for the names it approved only. Slow prompts and unserveable calls always get an answer.

- Forwarding: one `handler.eventsFor(origin)` subscription per topic, started for sessions active at attach
  and for new ones, cancelled on delete, expiry or the disposer. Revoking the origin stops delivery and a
  later connect resumes it, because `eventsFor` checks the connection per event.
- One future chain per topic carries replies and events, so they leave in the order queued. A send that fails
  is logged by type and dropped; the chain survives. No `disconnect` event is sent (the session end is the signal).
- Task 2 needed no new code: the expiry raise (`kGnusConfirmTimeout` + 60 s, marked `ponytail:`), the
  drop-on-failure reply and the code mapping were written in 47-01. This task added the tests that pin them.

## Verification
- `flutter test test/reown test/gnus_bridge`: 626 passed, 0 failed (lifecycle file: 22). Analyze clean.
- Mutation: skipping the approved-events check, not setting the expiry, and removing the per-topic chain each
  fail the tests meant to catch them (1, 1 and 2 tests). Restored.
- A prompt held 6 minutes on a fake clock and then approved answers once (the fake does not enforce Reown's
  5 minute rule; the test pins the raised expiry value and the single answer).

## Deviations
None.

## Known stubs
None.

## Self-Check: PASSED
