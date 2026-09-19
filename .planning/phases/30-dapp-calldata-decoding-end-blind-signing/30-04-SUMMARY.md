---
phase: 30-dapp-calldata-decoding-end-blind-signing
plan: 04
status: complete
requirements: [DAP-02 (partial), DAP-03]
key-files:
  created: [test/reown/fixtures/squid_route_transaction_request.json]
  modified: [lib/reown/calldata_decoder.dart, lib/reown/dapp_call_details.dart, lib/reown/handle_dapp_requests.dart, test/reown/calldata_decoder_test.dart, test/reown/dapp_call_details_test.dart, test/reown/handle_dapp_requests_test.dart]
actuals: { tokens: 12000, tasks: 3, commits: 5 }
---

# Phase 30 Plan 04: the input side of a swap, and an admission about the rest

A Squid swap names the token and amount going in, and says on screen that the
destination cannot be read from the transaction.

## Baseline vs. after (quoted from real output)

| Check | Baseline (30-03) | After |
|---|---|---|
| `flutter test` | +1302 ~3, exit 0 | `+1341 ~3: All tests passed!`, exit 0 |
| `flutter analyze` | No issues, exit 0 | `No issues found! (ran in 4.2s)`, exit 0 |
| `dart format lib test` | 0 changed, exit 0 | `Formatted 404 files (0 changed)`, exit 0 |
| brace / raw-colour gates | exit 0 | exit 0, no output |
| drawer census | green | `+32: All tests passed!`, no new entry |

+39 is exactly the count of `test(`/`testWidgets(` lines added here. `dart
format .` is exit 1 (365 generated files) as at the 30-01 baseline; CI checks
`lib test`. `git diff develop --stat -- pubspec.yaml pubspec.lock` is empty, so
no package was added and no install needs gating. `grep -rniE
"toToken|destinationToken|indexOf\("` over the decoder exits 1 — nothing
searches the payload for an address.

## Known deviation: DAP-02 is NOT met

Only X of "swapping X → Y" shipped. In the recorded response word 0 is exactly
`fromToken.address` and word 1 exactly `fromAmount`, but `toToken.address`
appears only nested at a route-dependent position and `toAmount` not at all.
Finding Y by scanning the blob is a heuristic a hostile payload can seed.
Recorded Partial in REQUIREMENTS.md, not ticked.

## Other deviations

- **One chain in the allow-list**, not a catalogue: only Base 8453 is evidenced.
- **"1 GNUS", not "1.0 GNUS"** — `formatTokenAmount` trims trailing zeros; no
  second formatter was written for cosmetics.
- **Token resolution is now one function** shared by the ERC-20 and swap paths,
  so the never-assume-18 guard has one home instead of two.
- **Two handler cases beyond the plan's file list** (Rule 2): without them,
  cutting `chainId: network?.chainId` would break no test.
- **A detail row overflowed 19px** (long label, 19-digit value); both sides now
  flex (Rule 1).
- **The fixture's provenance comment names a git ref** carrying a phase number.
  Judged: unverifiable provenance is worse.

## Self-Check: PASSED
