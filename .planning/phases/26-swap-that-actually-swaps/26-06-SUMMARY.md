---
phase: 26
plan: 06
subsystem: swap
tags: [squid, execution, honest-recording, hive]
status: complete-pending-walk
requires: [26-05]
provides: [real-submit, honest-transaction-record]
affects: [lib/squid_router, lib/hive, packages/genius_api]
tech-stack:
  added: []
  patterns: [injected orchestrator as the screen's test seam]
key-files:
  created: [test/squid_router/swap_submit_test.dart]
  modified: [lib/squid_router/swap_screen.dart, lib/squid_router/swap_execution.dart, lib/hive/services/transaction_storage_service.dart, packages/genius_api/lib/src/genius_api.dart]
  deleted: []
decisions:
  - "The screen reads sideEffectsFor and never re-derives it; _applyOutcome returns early on !storeRow, so every toast, receipt and write sits behind the triple."
  - "The pending row is written under the real hash BEFORE polling, then re-put under the same key. addTransaction is box.put(tx.hash, tx), so the second write resolves the first."
  - "SwapScreen takes `execute` and `storage` parameters defaulting to the real ones — the cases drive every outcome with no network, no key and no Hive."
metrics: {tasks: 2, commits: 2, completed: 2026-09-16}
actuals: {tokens: 19000, tasks: 2, commits: 2}
---

# Phase 26 Plan 06: Delete the lie Summary

`_submitSwap` no longer fabricates anything. It runs the orchestrator, reads `sideEffectsFor`, and
does only what that permits. Both `// TODO` markers and the invented `completed` Transaction with
`hash: ""` are gone.

## Deviations from Plan

**[Rule 1 - Bug] The provider seam was half-wired, and the test found it.** `_loadTokens` used the
injected `widget.provider` while `_fetchRoute` still called the global `swapProvider` — introduced
in 26-04 when the seam was added for the catalogue only. The screen was talking to two different
providers, and in a test the quote path went to the real network and failed. Fixed at
`swap_screen.dart:338`; all four provider calls now go through `widget.provider`.

**[Rule 3 - Blocking] `GeniusApi` had no `allowance` wrapper.** 26-02 added `Web3.allowance` but
only wrapped `approve`. Added a six-line wrapper beside `rawBalanceOf` so the widget layer does not
construct `Web3` itself.

**[Beyond the plan's file list]** `TransactionStorageService` gained a `const` constructor so it can
be a default parameter value; that made four existing call sites lintable under
`prefer_const_constructors`, so they gained `const`.

**The fixture guard caught its own first defect.** The page header is also titled "Swap", so
`find.text('Swap')` matched the title and `findsOneWidget` passed while the CTA sat on the **Retry**
rung — every assertion was vacuous. The cases now target `find.widgetWithText(GWButton, 'Swap')` and
additionally assert `Retry` is absent.

## Verification

Real output, this machine, this branch:

- `flutter test test/squid_router/swap_submit_test.dart --no-pub` → **+9, All tests passed!**
- `flutter analyze --no-pub` → "No issues found!", exit **0**
- `dart format --set-exit-if-changed lib test` → exit 0; `tool/check_brace_style.sh --count` → `0`
- `grep "TODO" ` inside `_submitSwap` → none; no `Transaction(hash: "")` anywhere in the file
- Every `showToast` / `showTransactionDetails` / `addTransaction` in `_applyOutcome` sits behind
  `effects.storeRow` / `.showToast` / `.showReceipt`
- `flutter test --no-pub` → 1311 pass / 5 skip / **3 fail** — all three are `26-08`'s in-flight
  `TransactionStatus` work by the other agent on this branch (`transaction_receipt_copy_test.dart`
  ×2, `transaction_row_subtitle_test.dart`), none touch swap code

## Open for the human — THIS PLAN IS NOT DONE

The plan's `<human-check>` has not been run and cannot be by me: **one real swap on Base mainnet
(chainId 8453, not the dead 84531 "Base - Sepolia") with a throwaway wallet.** It needs funds and a
key. Until it runs, no swap has ever actually executed through this code path — the orchestrator and
the screen are proven against stubs and the live read-only endpoints only.

Record the hash here when it is done. `status:` above stays `complete-pending-walk` until then.

## Self-Check: PASSED

`test/squid_router/swap_submit_test.dart` exists. Commits `5bc269ae`, `b7582013` both resolve.
