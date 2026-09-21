---
phase: 30-dapp-calldata-decoding-end-blind-signing
plan: 02
status: complete
requirements: [DAP-01, DAP-03]
key-files:
  created: [lib/reown/dapp_call_details.dart, test/reown/dapp_call_details_test.dart]
  modified: [lib/reown/calldata_decoder.dart, lib/reown/handle_dapp_requests.dart, test/reown/calldata_decoder_test.dart, test/reown/approve_drawer_contract_test.dart]
actuals: { tokens: 62000, tasks: 3, commits: 5 }
---

# Phase 30 Plan 02: approve, unlimited allowance, and the unverified token

Everything that is not a plain send now has a drawer body that says what it
read and admits what it could not.

## Baseline vs. after (measured)

`flutter test` +1245 ~3 → +1275 ~3, exit 0. analyze, format, brace, raw-colour
and drawer census: exit 0 before and after. `grep 18 lib/reown/calldata_decoder.dart`
→ exit 1: the literal is absent, so no decimals path can fall back to it.

## Deviations

- **Headline, warning and rows are three pure functions in
  `dapp_call_details.dart`, not inline in `handle_dapp_requests.dart`** as the
  plan's action said. Inline, the link from a `2^255` allowance to the words on
  screen would have been untestable until plan 03 builds the handler harness.
  The handler now calls them; the widget itself still takes only strings.
- **The unlimited flag is set for unverified approves too**, not just resolved
  ones. An unlimited approve of a token the wallet cannot name is the same
  drain vector.
- **The contract-test amendment 30-01 skipped is done here** (Case 7): 90
  insertions, 0 deletions; every existing case is byte-for-byte untouched.
- **Warning copy is not exercised through the real handler** — the
  `flag → sentence` selection is covered, the cubit wiring is plan 03's.

## Self-Check: PASSED
