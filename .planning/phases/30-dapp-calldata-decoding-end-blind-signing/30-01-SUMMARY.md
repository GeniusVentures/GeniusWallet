---
phase: 30-dapp-calldata-decoding-end-blind-signing
plan: 01
status: complete
requirements: [DAP-01]
key-files:
  created: [lib/reown/calldata_decoder.dart, test/reown/calldata_decoder_test.dart]
  modified: [lib/reown/send_transaction_details.dart, lib/reown/handle_dapp_requests.dart, packages/genius_api/lib/web3/web3.dart]
actuals: { tokens: 42000, tasks: 3, commits: 4 }
---

# Phase 30 Plan 01: one ERC-20 transfer, decoded end to end

An ERC-20 `transfer` of a known coin now names its real recipient and token.

## Baseline vs. after (measured)

| Check | Baseline | After |
|---|---|---|
| `flutter analyze` | 0 issues, exit 0 | 0 issues, exit 0 |
| `flutter test` | +1216 ~3, exit 0 | +1245 ~3, exit 0 |
| `dart format lib test` | 0 changed, exit 0 | 0 changed, exit 0 |
| brace + raw-colour gates | exit 0 | exit 0 |

Whole-tree `dart format .` was red before and after (365 generated files); CI
checks `lib test`. Pubspec untouched.

## Deviations

- **Task 3's contract-test amendment was skipped** — the brief reserved that
  file for a later plan. Both new symbol params default to `'ETH'`, so its
  Case 6 and const fixture pass untouched.
- **`genius_api/web3/web3.dart` gained an `export ... show EthereumAddress`**
  (outside the plan's file list): importing `package:wallet` here raised
  `depend_on_referenced_packages`; re-exporting from its owner avoids both a
  pubspec change and a lint suppression.
- Extra `unknownCall` guards: blank symbol, decimals outside 0-36, bad `value`.
- Hive still records `coinSymbol = "ETH"`; more in `deferred-items.md`.

## Self-Check: PASSED
