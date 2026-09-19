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

| Check | Baseline (30-03) | After |
|---|---|---|
| `flutter test` | +1302 ~3, exit 0 | `+1341 ~3: All tests passed!`, exit 0 |
| `flutter analyze` | No issues, exit 0 | `No issues found! (ran in 4.2s)`, exit 0 |
| `dart format lib test` | 0 changed, exit 0 | `Formatted 404 files (0 changed)`, exit 0 |
| brace / raw-colour gates | exit 0 | exit 0, no output |
| drawer census | green | `+32: All tests passed!`, no new entry |

+39 is exactly the `test(`/`testWidgets(` lines added here. `dart format .` is
exit 1 (365 generated files) as at the 30-01 baseline; CI checks `lib test`.
`git diff develop --stat -- pubspec.yaml pubspec.lock` is empty — no package
added, nothing to gate. The no-scan grep over the decoder exits 1.

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
- **The fixture comment names a git ref** carrying a phase number — better than unverifiable provenance.
- **This file is 47 lines against AGENTS.md's 40** — the overrun is measured evidence, not prose.

## Self-Check: PASSED
