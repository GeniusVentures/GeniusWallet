---
phase: 30-dapp-calldata-decoding-end-blind-signing
plan: 04
status: complete
requirements: [DAP-02 (partial), DAP-03]
key-files:
  created: [test/reown/fixtures/squid_route_transaction_request.json]
  modified: [lib/reown/calldata_decoder.dart, lib/reown/dapp_call_details.dart, lib/reown/handle_dapp_requests.dart, test/reown/calldata_decoder_test.dart, test/reown/dapp_call_details_test.dart, test/reown/handle_dapp_requests_test.dart]
actuals: { tokens: 12000, tasks: 3, commits: 6 }
---

# Phase 30 Plan 04: the input side of a swap, and an admission about the rest

## Baseline vs. after (quoted from real output)

`flutter test` +1302 ~3 → `+1341 ~3: All tests passed!`, exit 0; +39 is exactly
the `test(`/`testWidgets(` lines added. analyze `No issues found!`, format
`404 files (0 changed)`, brace, raw-colour and drawer census (`+32`): exit 0.
`dart format .` is exit 1 (365 generated files) as at 30-01; CI checks `lib test`.
`pubspec.yaml`/`pubspec.lock` unchanged against develop — no package added.

## Known deviation: DAP-02 is NOT met

Only X of "swapping X → Y" shipped. In the recorded response word 0 is exactly
`fromToken.address` and word 1 exactly `fromAmount`, but `toToken.address`
appears only nested at a route-dependent position and `toAmount` not at all.
Finding Y by scanning the blob is a heuristic a hostile payload can seed.
Recorded Partial in REQUIREMENTS.md, not ticked.

## Other deviations

- **One chain allow-listed**, not a catalogue: only Base 8453 is evidenced.
- **"1 GNUS", not "1.0"** — `formatTokenAmount` trims trailing zeros.
- **Token resolution is one shared function now** — never-assume-18 has one home.
- **Two handler cases beyond the file list** (Rule 2): cutting `chainId:` would otherwise break no test.
- **A detail row overflowed 19px**; both sides now flex (Rule 1).

## Self-Check: PASSED
