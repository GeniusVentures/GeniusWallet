---
phase: 43-gnus-rpc-handler-and-job-record
plan: 03
subsystem: gnus_bridge
tags: [gnus-rpc, amounts, estimate, submit, affordability]
requires: [43-02]
provides:
  - gnusBalanceBaseUnits and sgnusBalanceBaseUnits beside the cost and gas conversions
  - gnus_estimate
  - affordability, balance and post-confirm checks on gnus_submitJob
  - cached SDK network read (one sgnsNet() future per handler)
affects: [43-04, 43-05]
key-files:
  created:
    - test/gnus_bridge/gnus_amounts_test.dart
    - test/gnus_bridge/gnus_rpc_estimate_test.dart
  modified:
    - lib/gnus_bridge/gnus_amounts.dart
    - lib/gnus_bridge/gnus_rpc_handler.dart
    - test/gnus_bridge/gnus_fakes.dart
    - test/gnus_bridge/gnus_rpc_submit_test.dart
decisions:
  - Affordability is resolveSubmitJobCtaState (the panel's rounding and boundary), not a hand comparison
  - An unreadable balance fails closed in submit (-32603 balance_unavailable) and stays null in the estimate
  - After the confirm, switching, node account, payer wallet, chain and a fresh gate are rechecked before the burn
status: complete
actuals:
  tokens: 55000
  tasks: 2
  commits: 2
---

# Phase 43 Plan 03: One conversion file, gnus_estimate and the submit refusals Summary

Every GNUS amount the handler returns is now converted in `gnus_amounts.dart` with exact string tests, `gnus_estimate` prices a job without the gate or a burn, and `gnus_submitJob` refuses every unaffordable or unsafe case before any burn, including an account change while the confirm is open.

## Tasks

| Task | Name | Commit |
| ---- | ---- | ------ |
| 1 | Every amount conversion in one file, with exact tests | 611c93be |
| 2 | gnus_estimate and every submit refusal and outcome | 5bca3339 |

## What was built

- `gnusBalanceBaseUnits(double?)`: null for null, NaN, infinite and negative; goes through `toString()`, expands exponent forms with string operations, then `toBaseUnits`. `sgnusBalanceBaseUnits(String)` for the node's 6-decimal SDK string. No double arithmetic on a converted value.
- `gnus_estimate`: `{cost, gas, balance, network: {sdk, evmChainId}}`. Ignores the gate, never prompts or burns. A zero or failed cost is -32010; gas and balance stay null when unavailable.
- `gnus_submitJob`: gate, cost, balance (null is -32603 `balance_unavailable`), affordability through `resolveSubmitJobCtaState` (-32011), gas, confirm, then `_recheckAfterConfirm` (-32015, with `account_changed` for a moved node, payer or chain, or the gate's own code), then the burn on the facts the user approved.
- Shared private helpers `_priceJob`, `_payerBalance`, `_gasPrice` so the estimate and the submit price one way.
- Fakes: `FakeGnusApi.sgnsNet()`, `SeededGnusCubit.balanceReadable` and `tokenKnown`.

## Numbers

- `flutter analyze --no-pub lib test`: exit 0, no issues.
- `dart format --set-exit-if-changed` clean, `bash tool/check_brace_style.sh` exit 0, new files LF.
- Full suite: +2772 ~6, 0 failed, exit 0. Start 2749, so +23 in this plan.
- `flutter test test/gnus_bridge test/submit_job`: all passed.

## Deviations from Plan

- Rule 2: a gas estimate that reports `GasEstimateMissingData` (no chain, RPC, wallet or token address) is `-32603 missing_data` before the confirm in submit, instead of showing a confirm for a job the owner would then refuse at the burn. The dev fixture never reaches it (its estimate is always Ok). The estimate still returns `gas: null` in that case.
- The gas and cost conversion tests moved from `gnus_rpc_submit_test.dart` into `gnus_amounts_test.dart` (the submit test file is in this plan's file list for Task 2).

## Known limits

- The cached `sgnsNet()` future is never refreshed in a session, by design (the SDK net applies only after a restart). Plan 43-04 reuses it.

## Known Stubs

None.

## Threat Flags

None beyond the plan's register (T-43-14 to T-43-18 mitigated as planned; `GasEstimateFailed.reason` is never forwarded).

## Self-Check: PASSED

Commits 611c93be and 5bca3339 exist; full suite and analyze green.
