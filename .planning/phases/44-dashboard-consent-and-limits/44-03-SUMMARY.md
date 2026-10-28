---
phase: 44-dashboard-consent-and-limits
plan: 03
subsystem: gnus-bridge
tags: [consent, rate-limit, events]
requires: [44-01]
provides: [prompt limits, revoke on in-flight calls, eventsFor]
affects: [lib/gnus_bridge/gnus_rpc_handler.dart, lib/gnus_bridge/gnus_rpc_contract.dart]
key-files:
  modified: [lib/gnus_bridge/gnus_rpc_handler.dart, lib/gnus_bridge/gnus_rpc_contract.dart, .planning/research/v4.0-gnus-rpc-contract.md]
status: complete
actuals: {tokens: 60000, tasks: 3, commits: 3}
---

# Phase 44 Plan 03: Prompt limits, revoke, events Summary

Prompts can no longer stack or spam, a revoke lands on calls already running, and transports get only the events an origin may see.

## Commits
- 1c063828 `_prompt`: one open prompt per origin, 3 per minute, `confirm_open` / `rate_limited`
- 245f7284 per-call revoke check (4100), recheck after the confirm, contract bullet
- 1131c243 `eventsFor(origin)`; the unfiltered `events` is `@visibleForTesting`

## Results
- `test/gnus_bridge`: 212 passed (199 before). Mutating the limit to 4 fails three of the new tests.

## Changed existing tests
- `gnus_rpc_submit_test.dart`, "a second submit gets -32005 from any origin, including a retry": the same origin with a new key now gets `confirm_open`; another origin and a same-key retry still get `submit_in_flight`.
- `gnus_connection_test.dart` (this phase): two loops advance `h.clock` 61 s per prompt.

## Decisions
- Prompt times are stamped at open. A prompt that timed out after 10 minutes is older than the window by the next call, so in production it ages out on its own; the test shows it is not exempt.
- Contract file: only the new "Prompt limits (D, 2026-10-28)" bullet in section 6, after the per-origin bullet.

## Known limits
- A submit that already burned when the origin is revoked answers 4100 to the page. The job is recorded; a same-key retry after reconnect replays it.
- Transports must forward only `eventsFor(origin)`.

## Deviations
None.

## Known Stubs
None.

## Self-Check: PASSED
