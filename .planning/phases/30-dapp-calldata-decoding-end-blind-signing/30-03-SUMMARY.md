---
phase: 30-dapp-calldata-decoding-end-blind-signing
plan: 03
status: complete
requirements: [DAP-03]
key-files:
  created: [test/reown/handle_dapp_requests_test.dart]
  modified: [lib/reown/handle_dapp_requests.dart, lib/reown/calldata_decoder.dart, lib/reown/dapp_call_details.dart, lib/reown/approve_transaction_drawer.dart, test/reown/calldata_decoder_test.dart, test/reown/dapp_call_details_test.dart]
actuals: { tokens: 71000, tasks: 3, commits: 3 }
---

# Phase 30 Plan 03: the unreadable call, the two hung methods, the honest receipt

Every request now leaves the handler with exactly one answer, and the record
written afterwards names what was actually approved.

## Baseline vs. after (measured)

| Check | Baseline (30-02) | After |
|---|---|---|
| `flutter test` | +1275 ~3, exit 0 | +1302 ~3, exit 0 |
| `flutter analyze` | No issues found, exit 0 | No issues found, exit 0 |
| format / brace / raw-colour / seed / key-log gates | exit 0 | exit 0 |

`grep` for `event.params.toString()`, `USER_REJECTED.toInt()` and
`coinSymbol = "ETH"` each exits 1. The rejection code is asserted as the
literal 5000; `int.tryParse(Errors.USER_REJECTED)` is pinned null.

## Deviations

- **A non-string `data` reads as unknownCall**, not the nativeSend an existing
  decoder case pinned: malformed data is not a plain send.
- **The reown import in `calldata_decoder.dart` is narrowed with `show`**;
  bare, it re-exports web3dart and hides the file's real ABI imports.
- **A plain send records the selected network symbol, not a literal ETH** —
  same lie D-08 targets. Consequence in `deferred-items.md`: `getExplorerUrl`
  is keyed on coin symbol, so a token send loses its (wrong-chain) link.
- **Two silences beyond the plan were answered** (Rule 2): an approval with no
  network selected, and the catch-all itself.
- **A stray `git stash -u` + `git checkout <sha> -- .` was run by mistake and
  fully recovered**; the older, unrelated stash was not touched.

## Self-Check: PASSED
