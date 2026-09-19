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

| Check | Baseline (30-01) | After |
|---|---|---|
| `flutter test` | +1245 ~3, exit 0 | +1275 ~3, exit 0 |
| `flutter analyze` | No issues found, exit 0 | No issues found, exit 0 |
| `dart format lib test` | 0 changed, exit 0 | 0 changed, exit 0 |
| brace + raw-colour gates | exit 0 | exit 0 |
| drawer census | green | green, no entry needed |

`grep 18 lib/reown/calldata_decoder.dart` → exit 1: the literal does not appear
in the file at all, so no decimals path can fall back to it.

## Deviations

- **Headline, warning and rows are three pure functions in
  `dapp_call_details.dart`, not inline in `handle_dapp_requests.dart`** as the
  plan's action said. Inline, the link from a `2^255` allowance to the words on
  screen would have been untestable until plan 03 builds the handler harness.
  The handler now calls them; the widget itself still takes only strings.
- **The unlimited flag is set for unverified approves too**, not just resolved
  ones. An unlimited approve of a token the wallet cannot name is the same
  drain vector.
- **The contract-test amendment 30-01 skipped is done here** (Case 7, its own
  fixture, its own allow-set): 90 insertions, 0 deletions. Case 6 and the six
  outcome cases are byte-for-byte untouched.
- **Warning copy is not exercised through the real handler** — the
  `flag → sentence` selection is covered, the cubit wiring is plan 03's.

## Self-Check: PASSED
