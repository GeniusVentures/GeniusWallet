---
phase: 43-gnus-rpc-handler-and-job-record
plan: 03
subsystem: gnus_bridge
tags: [gnus-rpc, amounts, estimate, submit, affordability]
requires: [43-02]
provides: [gnusBalanceBaseUnits, sgnusBalanceBaseUnits, gnus_estimate, submit affordability and post-confirm recheck, cached sgnsNet() read]
affects: [43-04, 43-05]
key-files:
  created: [test/gnus_bridge/gnus_amounts_test.dart, test/gnus_bridge/gnus_rpc_estimate_test.dart]
  modified: [lib/gnus_bridge/gnus_amounts.dart, lib/gnus_bridge/gnus_rpc_handler.dart, test/gnus_bridge/gnus_fakes.dart, test/gnus_bridge/gnus_rpc_submit_test.dart]
decisions: [Affordability is resolveSubmitJobCtaState not a hand comparison, Unreadable balance fails closed in submit and stays null in estimate, Recheck switching/node/payer/chain/gate after confirm]
status: complete
actuals: {tokens: 55000, tasks: 2, commits: 2}
---

# Phase 43 Plan 03: One conversion file, gnus_estimate and the submit refusals Summary

All GNUS amounts convert in `gnus_amounts.dart` with exact string tests; `gnus_estimate` prices without the gate or a burn; `gnus_submitJob` refuses every unaffordable or unsafe case before any burn, including an account change during the confirm.

## Tasks and built

- Task 1 (commit 611c93be): `gnusBalanceBaseUnits(double?)`, `sgnusBalanceBaseUnits(String)`; no double arithmetic on converted values.
- Task 2 (commit 5bca3339): `gnus_estimate` (zero or failed cost is -32010; gas and balance null when unavailable); `gnus_submitJob` gate, cost, balance (-32603 `balance_unavailable`), affordability (-32011), gas, confirm, `_recheckAfterConfirm` (-32015), burn. Helpers `_priceJob`, `_payerBalance`, `_gasPrice`. Fakes: `FakeGnusApi.sgnsNet()`, `SeededGnusCubit.balanceReadable` and `tokenKnown`.

## Numbers

- `flutter analyze --no-pub lib test`: exit 0. `dart format --set-exit-if-changed` clean; `bash tool/check_brace_style.sh` exit 0; new files LF.
- Full suite: +2772 ~6, 0 failed, exit 0 (start 2749, +23). `flutter test test/gnus_bridge test/submit_job`: all passed.

## Deviations, limits

- Rule 2: `GasEstimateMissingData` is `-32603 missing_data` before the confirm in submit; the estimate still returns `gas: null`.
- Gas and cost conversion tests moved into `gnus_amounts_test.dart`.
- The cached `sgnsNet()` future is never refreshed in a session (SDK net applies after restart); 43-04 reuses it.
- Known Stubs: none. Threat Flags: none beyond T-43-14 to T-43-18, all mitigated.

## Self-Check: PASSED

Commits 611c93be and 5bca3339 exist; full suite and analyze green.
