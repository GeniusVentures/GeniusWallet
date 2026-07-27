---
phase: 08-swap-bridge
plan: 05
subsystem: ui
tags: [flutter, squid-router, swap, transactions, dev-tools, drawer-consolidation]

requires:
  - phase: 08-03
    provides: "swap tab assembly (105 A1 layout, CTA ladder) — this plan wires the submit closure's result path on top of it"
provides:
  - "swap_screen.dart's submit closure now calls showTransactionDetails(context, transaction) after the toast, instead of the deleted SwapSuccessDrawer"
  - "transaction_displays.dart's Network Fee row skips a blank tx.fees, matching the Rate row's existing skip-empty contract"
  - "lib/squid_router/{swap_success_drawer,swap_fail_drawer,swap_drawer_content}.dart deleted — no orphaned drawers left behind"
  - "dev_tools_bubble.dart's 'Succeed'/'Failed' buttons repointed to showTransactionDetails with a synthetic swap Transaction"
affects: [08-06-bridge-receipt]

tech-stack:
  added: []
  patterns:
    - "Skip-empty row guard on a shared receipt function: a blank field means 'no fee is known', not 'render a bare label' — the same contract the Rate row already had (tx.exchangeRate ?? '')"

key-files:
  created:
    - test/dashboard/transaction_receipt_fee_row_test.dart
  modified:
    - lib/squid_router/swap_screen.dart
    - lib/dashboard/home/widgets/transaction_displays.dart
    - lib/dev/dev_tools_bubble.dart
  deleted:
    - lib/squid_router/swap_success_drawer.dart
    - lib/squid_router/swap_fail_drawer.dart
    - lib/squid_router/swap_drawer_content.dart

key-decisions:
  - "Task 3 (re-skin swap_settings_drawer.dart, D-13) was NOT executed — the plan's own banner (added 2026-07-27, before this execution) records it as superseded by sketch 063-A landing on 2026-07-26: the file was independently rewritten to the form-drawer archetype (presets + GWFocusRing input + GWButton gradient footer) between this plan's authoring and its execution. Re-verified live: zero ElevatedButton/Ink/greenBlueGreenGradient matches in the current 336-line file, footer already a GWButtonVariant.gradient, TextField already wrapped in GWFocusRing rather than a hardcoded OutlineInputBorder. Re-running Task 3 today would be a no-op at best and a regression at worst (the plan's exact verify gate for double.tryParse would fail against the current file, per the banner's own note — parsing moved to slippage_state.dart)."
  - "Added a `if (mounted)` guard around the new showTransactionDetails(context, transaction) call in swap_screen.dart's submit closure, even though no async gap precedes it in the current code path — matches this file's own established convention (_loadTokens, _fetchRoute both guard context-use with `if (mounted)`) and costs nothing."
  - "dev bubble's synthetic Transactions for 'Succeed'/'Failed' use recipients: const [] and hash: '' (swap-shaped, matching the real submit closure's own empty-hash pattern) rather than inventing recipient data the receipt's isSwap branch never reads."

patterns-established: []

requirements-completed: []

coverage:
  - id: D1
    description: "showTransactionDetails' Network Fee row skips a blank tx.fees (matching the Rate row's existing skip-empty contract); non-blank fees are unchanged"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "test/dashboard/transaction_receipt_fee_row_test.dart (3/3 pass: non-blank fee renders, blank fee omits, swap-shaped tx renders From/To and omits Network Fee)"
        status: pass
    human_judgment: false
  - id: D2
    description: "swap_screen.dart's submit closure routes the swap result through showTransactionDetails(context, transaction) after the existing toast (never instead of it); the Transaction's fees is now blank instead of fromAmount; both D-01 TODO markers, transactionsCubit.addTransaction and TransactionStorageService().addTransaction persistence are untouched; no Squid execution call was added"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "grep gates: showTransactionDetails(context, transaction) + ToastManager.instance.showToast + transactionsCubit.addTransaction + TransactionStorageService() all present; both '// TODO: invoke Squid API' and '// TODO: record transaction' present; zero SquidTokenService.execute/executeRoute//execute matches"
        status: pass
      - kind: other
        ref: "flutter analyze lib (59 issues, at the 61 baseline; zero new issues in swap_screen.dart or transaction_displays.dart)"
        status: pass
    human_judgment: true
    rationale: "That the receipt actually reads correctly for a live swap submission (rows render sensibly in situ, no visual regression) is a human-observed criterion — the 08-07 human walk this would normally route to is explicitly descoped by D-22 at Braian's instruction. Recorded as never exercised, not as passed."
  - id: D3
    description: "The three superseded drawers (swap_success_drawer.dart, swap_fail_drawer.dart, swap_drawer_content.dart) are deleted with no orphaned references; dev_tools_bubble.dart's 'Succeed'/'Failed' buttons now call showTransactionDetails; the reown path (swap_result_drawer.dart, handle_dapp_requests.dart, the dev bubble's 'Swap OK'/'Swap fail' buttons) is fully untouched"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "gates: three files absent (test ! -f); reown drawer file present with rg -c 'SwapResultDrawer.show' == 2 in both handle_dapp_requests.dart and dev_tools_bubble.dart; showTransactionDetails present in dev_tools_bubble.dart; zero non-comment matches of the three deleted import paths in dev_tools_bubble.dart"
        status: pass
      - kind: other
        ref: "flutter analyze lib (59, at baseline) + flutter test (326 pass / 1 known pre-existing failure, up from 285/1 at 08-04's close by exactly this plan's +3 new fee-row tests, minus zero regressions)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Task 3 (re-skin swap_settings_drawer.dart, D-13) — SUPERSEDED, not executed this pass; the file already reads as the redesigned tab's design language via an independent 2026-07-26 rewrite (sketch 063-A)"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "re-verified live at execution time: zero ElevatedButton/Ink(/greenBlueGreenGradient matches in lib/squid_router/swap_settings_drawer.dart; footer is GWButtonVariant.gradient; TextField wrapped in GWFocusRing; 'Swap Settings' title and 'Slippage tolerance' label present"
        status: pass
      - kind: automated_ui
        ref: "n/a — visual fidelity of the current form-drawer archetype is a human_judgment deliverable, out of this plan's scope entirely (the plan's own banner supersedes the task)"
        status: pass
    human_judgment: true
    rationale: "D-22 descopes the 08-07 human walk; the settings drawer's live visual read was never this plan's task in the first place once superseded, and remains unverified by any walk in this milestone."

duration: 25min
completed: 2026-07-27
status: complete
---

# Phase 8 Plan 5: Swap result → 031-B receipt, superseded drawers deleted, dev bubble repointed Summary

**Swap tab's submit closure now shows the shared 031-B receipt (`showTransactionDetails`) alongside its existing toast instead of the deleted `SwapSuccessDrawer`, with the receipt's Network Fee row correctly omitted for the still-unwired swap path (D-01) rather than mislabelling the pay amount as a fee.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-07-27T10:30:00Z
- **Completed:** 2026-07-27T10:52:00Z
- **Tasks:** 2/2 executed (Task 3 skipped — superseded, per the plan's own banner)
- **Files modified:** 3 modified, 1 created, 3 deleted

## Accomplishments
- `test/dashboard/transaction_receipt_fee_row_test.dart` (new): 3 widget tests pinning `showTransactionDetails`'s Network Fee row — non-blank fee renders it unchanged, blank fee omits it entirely, and a swap-shaped Transaction (blank fees, empty hash) renders From/To and omits Network Fee. Written and run RED before the guard existed (blank fee rendered a bare "Network Fee" label with no value — the exact defect named in the plan).
- `transaction_displays.dart`: one guard — `if (tx.fees.trim().isNotEmpty)` around the Network Fee row's `add(...)` call — mirroring the Rate row's existing `tx.exchangeRate ?? ''` skip-empty behaviour. Nothing else in the function changed.
- `swap_screen.dart`'s `_submitSwap()`: the `Transaction`'s `fees:` argument changed from `fromAmount` to `''` (nothing executed per D-01, so no fee exists to report), and the success-drawer call was replaced with `if (mounted) showTransactionDetails(context, transaction)`, placed after the transaction is constructed and after the existing `ToastManager.instance.showToast` call — toast and receipt both fire. Both `// TODO:` markers, the `debugPrint`, `transactionsCubit.addTransaction(transaction)` and the `await TransactionStorageService().addTransaction(...)` persistence call are byte-identical to before. The now-unused `swap_success_drawer.dart` import was dropped.
- Deleted `lib/squid_router/swap_success_drawer.dart`, `swap_fail_drawer.dart` and `swap_drawer_content.dart` — re-verified before deleting that the only remaining references were `swap_screen.dart` (now removed) and `dev_tools_bubble.dart`'s two dev buttons; no other production caller turned up.
- `dev_tools_bubble.dart`'s 'Succeed' and 'Failed' dev buttons now build a synthetic swap `Transaction` (`TransactionStatus.completed` / `.failed` respectively, blank `fees`, blank `hash`) and call `showTransactionDetails(context, tx)` — keeping a manual test entry point for the consolidated receipt. The two reown-path 'Swap OK'/'Swap fail' buttons, `lib/reown/swap_result_drawer.dart` and `lib/reown/handle_dapp_requests.dart` are completely untouched (D-05).

## Task Commits

Each task was committed atomically (Task 1 as TDD RED→GREEN):

1. **Task 1a (RED): failing test for blank-fee Network Fee row guard** - `c848663` (test)
2. **Task 1b (GREEN + swap_screen.dart wiring): route swap result to 031-B, blank the swap fee** - `4e0fae7` (feat)
3. **Task 2: delete the three superseded drawers, repoint dev bubble** - `9ff7c04` (feat)

Task 3 was not executed (superseded — see Deviations below); no commit.

## Files Created/Modified
- `test/dashboard/transaction_receipt_fee_row_test.dart` - new, 3 widget tests for the fee-row guard
- `lib/dashboard/home/widgets/transaction_displays.dart` - Network Fee row now skips a blank `tx.fees`
- `lib/squid_router/swap_screen.dart` - submit closure calls `showTransactionDetails`, fees blanked, unused import dropped
- `lib/dev/dev_tools_bubble.dart` - 'Succeed'/'Failed' buttons repointed to `showTransactionDetails`; three drawer imports replaced with one `transaction_displays.dart` import
- `lib/squid_router/swap_success_drawer.dart` - deleted
- `lib/squid_router/swap_fail_drawer.dart` - deleted
- `lib/squid_router/swap_drawer_content.dart` - deleted

## Decisions Made
- Task 3 skipped as superseded (see plan's own banner, confirmed live at execution time) — see `key-decisions` in frontmatter for the full re-verification.
- Added a defensive `if (mounted)` guard around the new `showTransactionDetails` call, matching this file's own established convention even though no async gap precedes it in this code path.
- Dev bubble's synthetic Transactions use `recipients: const []` and `hash: ''`, mirroring the real submit closure's own swap-shaped Transaction rather than inventing unused recipient data.

## Deviations from Plan

### Task 3 not executed — superseded, per plan's own annotation

The plan file itself carries a banner (dated 2026-07-27, prior to this execution) marking Task 3 "SUPERSEDED — DO NOT EXECUTE": `swap_settings_drawer.dart` was independently rewritten to sketch 063-A's form-drawer archetype on 2026-07-26 (88 lines → 336 lines), landing everything D-13 required (GWButton gradient footer, themed input, "Swap Settings"/"Slippage Tolerance" preserved) and then some (quick-chip presets, a dedicated `slippage_state.dart` module). Re-verified live before skipping: `rg 'ElevatedButton|Ink\(|greenBlueGreenGradient' lib/squid_router/swap_settings_drawer.dart` returns 0 matches; the footer is `GWButtonVariant.gradient`; the field is wrapped in `GWFocusRing`, not a hardcoded `OutlineInputBorder`. This is not a deviation introduced by this execution — it is following the plan's own explicit, pre-dated instruction not to touch the file. Recorded as coverage D4 (human_judgment) rather than silently omitted.

**Total deviations:** 1 (a plan-authored skip, not an execution-time deviation under Rules 1-4)
**Impact on plan:** None — Tasks 1 and 2, the plan's actual outstanding work, are both complete. Criterion 3 (the D-01 deviation re-confirmed and guarded in code) is closed.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
`showTransactionDetails` now serves the swap tab's result, and the blank-fee guard it required is live and tested — 08-06 (bridge receipt) depends on this exact guard existing (per this plan's `key_links`) and can proceed. The three superseded drawers are gone with no dangling references; the reown dApp path (Phase 10 territory) is fully intact per D-05's presence gates. `flutter analyze lib` holds at 59 (≤61 baseline, zero new issues in touched files); `flutter test` is 326 pass / 1 known pre-existing failure (285 baseline at 08-04's close + this plan's 3 new fee-row tests, `local_wallet_storage_test.dart` still the sole pre-existing failure). No blockers.

**Not exercised by an automated test in this plan (flagged, not blocking; D-22 descopes the 08-07 human walk):** whether the receipt reads correctly in situ for a real swap submission (row order, spacing, contrast) is unverified by any live walk this session — recorded as coverage D2's `human_judgment: true`, not as passed.

---
*Phase: 08-swap-bridge*
*Completed: 2026-07-27*
