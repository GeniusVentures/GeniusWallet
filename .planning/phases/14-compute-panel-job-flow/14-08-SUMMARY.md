---
phase: 14-compute-panel-job-flow
plan: 08
subsystem: ui
tags: [flutter, flutter_bloc, dashboard, compute-panel, wcag, accessibility, dart-async]

requires:
  - phase: 14-compute-panel-job-flow
    provides: "compute_state.dart's pure resolver/view-model (plan 01/02), ComputePanel itself (plan 07), the job drawer host with no cubit ownership of its own (plan 06), the retry-capable AppBloc (plan 02), the account drawer's public show() entry (plan 04)"
provides:
  - "The dashboard's first card (lib/components/wallet_overview.dart) mounting ComputePanel on real WalletDetailsCubit/AppBloc/SGNUS-stream data"
  - "All four card affordances wired to real effects: switch-wallet opens the account drawer, retry dispatches RetryProcessingStatus, see-node-status pushes /network, the primary action opens the job drawer with a cubit this subtree owns and disposes"
  - "Five named shipped bugs closed at their measured sites (see below), two superseded widget files deleted with no dangling references"
  - "The unit-toggle capability preserved per Jakub's 2026-07-29 DECIDED resolution: the balance's own unit label is now the >=24x24 tap target, replacing the deleted ToggleButtons block"
affects: [dashboard, wallet-overview, compute-panel, submit-job, account-drawer]

tech-stack:
  added: []
  patterns:
    - "Caller-resolves-state / panel-only-renders split: WalletsOverview resolves ComputeState+ComputeStatusView from bloc/stream inputs and hands ComputePanel a finished, plain result - ComputePanel itself reads no bloc/stream (established by plan 07, consumed here)."
    - "Job-cubit ownership lives in the dashboard subtree that opens the drawer, not in the drawer itself, so a drawer barrier tap cannot destroy an in-flight job's hash (T-14-31)."
    - "A broadcast StreamController.add() needs two tester.pump() calls in a widget test - one for the stream's own microtask delivery, one for the StreamBuilder's follow-up setState."

key-files:
  created:
    - test/dashboard/compute_panel_wiring_test.dart
  modified:
    - lib/components/wallet_overview.dart
    - lib/dashboard/compute/compute_panel.dart
    - test/dashboard/compute_panel_height_test.dart
    - test/theme/compute_contrast_test.dart
    - lib/components/wallet_information.dart
    - lib/components/wallets_overview.dart
    - lib/dev/dev_mock_sgnus.dart

key-decisions:
  - "The unit toggle: DECIDED 2026-07-29 by Jakub, not merely raised here - the balance's own unit label becomes the tap target; the 200x36 ToggleButtons block is deleted."
  - "The plan's corrected '+8px, not 0' arithmetic for the toggle does not match what was measured: the actual cost, measured with a throwaway height probe, is 0px in every state and every unit, in both GNUS and minions, because the toggle sits inline in a Row whose height is governed by the 40px GWAnimatedNumber text, not by the toggle's own 24px minimum. See 'Task 3' section below - this is reported as a plan assertion that turned out false about the actual code, not silently corrected."
  - "The live CoinGecko fiat-price integration was implemented, then deliberately reverted: a real HTTP call fired unawaited from initState is the exact test-hermeticity risk test/account/account_drawer_show_test.dart's header documents for real I/O inside testWidgets. fiatSubline is '' with an inline comment; tracked as a Known Stub below, not a bug this plan closes."
  - "compute_panel.dart, its two 14-07-owned test files, and three unrelated dead-code files (wallet_information.dart, wallets_overview.dart, dev_mock_sgnus.dart) were touched even though only lib/components/wallet_overview.dart and the two deleted widgets were in this plan's declared files_modified - each is documented as a necessary deviation below, not a silent scope change."

patterns-established:
  - "_UnitToggle (compute_panel.dart): Semantics(button:true, label:, value:) + Material(type: transparency) + InkWell for any future tappable-label-as-control - InkWell for keyboard focus/operability, Semantics for screen-reader announcement of which option is active."

requirements-completed: [CMP-01, CMP-03, CMP-07, CMP-08, CMP-09, CMP-10]

coverage:
  - id: D1
    description: "The dashboard's first card renders ComputePanel driven by real data (wallet selection, SGNUS connection stream, AppBloc feed fields), not a fixture."
    requirement: "CMP-01"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_panel_wiring_test.dart#a disconnected node resolves to Disconnected, never Not linked"
        status: pass
      - kind: unit
        ref: "test/dashboard/compute_panel_wiring_test.dart#a connected node whose address differs from the selected wallet resolves to Not linked"
        status: pass
    human_judgment: false
  - id: D2
    description: "The retry affordance dispatches RetryProcessingStatus end to end, clearing the unavailable flag through the real AppBloc (not just proving the enum value)."
    requirement: "CMP-08"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_panel_wiring_test.dart#the retry affordance dispatches RetryProcessingStatus, which clears the unavailable flag"
        status: pass
    human_judgment: false
  - id: D3
    description: "The switch-wallet and see-node-status links open the account drawer / push /network; the primary action opens the job drawer with a cubit this subtree owns and disposes."
    requirement: "CMP-01"
    verification: []
    human_judgment: true
    rationale: "No widget test exercises AccountDrawer.show(), context.push('/network'), or JobDrawer.show() actually opening from this card in this session - the wiring test suite deliberately stays narrow (state resolution + retry only, per the plan's own instruction). The end-to-end human-check walk in the plan's <verification> block (items 4-6) was not performed this session; see 'Human-check walk NOT performed' below."
  - id: D4
    description: "The determinate ring drawn from a feed that stops moving is closed by deleting SGNUSConnectionWidget/SGNUSConnectionStatusWidget; no reference to either class remains in lib/."
    requirement: "CMP-07"
    verification:
      - kind: other
        ref: "grep -rn \"SGNUSConnectionWidget|SubmitJobDashboardButton\" lib/ -> exit 1, no matches"
        status: pass
      - kind: other
        ref: "test ! -f lib/components/sgnus/sgnus_connection_widget.dart && test ! -f lib/components/job/submit_job_dashboard_button.dart -> both true"
        status: pass
    human_judgment: false
  - id: D5
    description: "The zero-balance-painted-as-failure bug and the hardcoded light-mode-invisible colour bug are closed for this card by routing the balance through ComputePanel's themed GWAnimatedNumber, with no zero special-case."
    requirement: "CMP-09"
    verification:
      - kind: unit
        ref: "test/dashboard/compute_panel_height_test.dart (all 32 state/width/unit combinations) - passes; no zero-check branch exists in compute_panel.dart's _BalanceTile"
        status: pass
    human_judgment: false
  - id: D6
    description: "The unit toggle (ToggleButtons block deleted, unit label becomes the >=24x24 tap target, keyboard/screen-reader accessible) per Jakub's DECIDED 2026-07-29 resolution."
    requirement: "CMP-10"
    verification:
      - kind: unit
        ref: "! grep -q ToggleButtons lib/components/wallet_overview.dart -> exit 1 (absent), confirmed"
        status: pass
      - kind: unit
        ref: "test/dashboard/compute_panel_height_test.dart (extended to useMinions: true/false across all 8 states x 2 widths = 32 assertions)"
        status: pass
    human_judgment: true
    rationale: "The >=24x24 hit area and Semantics(button/label/value) were verified via a throwaway repro test during execution (deleted after use, per the plan's no-new-tooling constraint) rather than a permanent assertion in the committed suite - a human should confirm the tap target visually and with VoiceOver/TalkBack per the plan's own human-check item 1, which was not performed this session."

duration: not tracked (session resumed after a context-window compaction; no reliable start timestamp survived the resume)
completed: 2026-07-31
status: complete
---

# Phase 14 Plan 08: Compute panel job flow - dashboard wiring, bug closure, unit-toggle redesign Summary

**`lib/components/wallet_overview.dart` rebuilt to resolve `ComputeState`/`ComputeStatusView` from real `WalletDetailsCubit`/`AppBloc`/SGNUS-stream inputs, mount `ComputePanel` with all four affordances wired (switch-wallet, retry, see-node-status, a dashboard-owned job cubit for the primary action), close all five shipped bugs at their measured sites, delete the two widgets they lived in, and replace the deleted `ToggleButtons` unit switch with a tappable, WCAG-2.5.8-sized unit label per Jakub's already-DECIDED 2026-07-29 resolution.**

## Performance

- **Duration:** not tracked (session spanned a context-window compaction; no reliable elapsed time)
- **Tasks:** 3/3 complete
- **Files created:** 1 (`test/dashboard/compute_panel_wiring_test.dart`)
- **Files modified:** 7 (`lib/components/wallet_overview.dart`, `lib/dashboard/compute/compute_panel.dart`, `test/dashboard/compute_panel_height_test.dart`, `test/theme/compute_contrast_test.dart`, `lib/components/wallet_information.dart`, `lib/components/wallets_overview.dart`, `lib/dev/dev_mock_sgnus.dart`)
- **Files deleted:** 2 (`lib/components/sgnus/sgnus_connection_widget.dart`, `lib/components/job/submit_job_dashboard_button.dart`)

## Task completion

All three tasks in the plan are complete.

1. **Task 1 (feed the panel real data, wire the affordances)** - complete. `WalletsOverview` creates `_gnusCubit`/`_submitJobCubit` in `initState`, disposes both in `dispose`, resolves `computeState`/`view` from the wallet cubit + SGNUS stream + `AppBloc` fields inside `build`, and wires all four affordances (`_handleLinkTap` for switch-wallet/retry/see-node-status; `onNewJob` for the drawer). `test/dashboard/compute_panel_wiring_test.dart` (new, 3 tests) proves the disconnected-vs-not-linked precedence and the retry-to-real-dispatch wire.
2. **Task 2 (close the five bugs, decide the scroll wrapper)** - complete. All five bugs closed (see "The five shipped bugs" below). Both superseded widget files deleted. The scroll wrapper is kept, its comment rewritten with the corrected `dashboard_screen.dart:212/:293/:298` line numbers and the corrected 274px (not 276px) budget.
3. **Task 3 (the unit-toggle decision)** - complete. The `ToggleButtons` block is gone from `wallet_overview.dart`. The unit label in `compute_panel.dart`'s `_UnitToggle` is the new tap target: `>=24x24` (`ConstrainedBox(minWidth: 24, minHeight: 24)`), `InkWell`-based (keyboard focusable/operable), `Semantics(button: true, label: 'Balance unit', value: 'GNUS'|'MINIONS')`. `compute_panel_height_test.dart` extended to cover `useMinions: true`/`false` across all 8 states x 2 widths (32 total height assertions) - all pass.

## The five shipped bugs - before and after

1. **The determinate ring drawn from a feed that stops moving** - `lib/components/sgnus/sgnus_connection_widget.dart:89-90` (`CircularProgressIndicator(value: _initPercentage, ...)`, frozen once `_initTimer` cancels at `percentage >= 1.0`). **After:** file deleted entirely. `ComputePanel`'s compute tile draws a `GWStatusDot` (dot + label) and a bar (`_ComputeProgressBar`) only where `view.showBar` is true, which is gated on the state enum, never on a raw percentage that can go stale. Only the UI half is closed - the stall detector that would let the panel say *stalled* is parked (`.planning/todos/pending/2026-07-29-stall-detector-needs-a-traced-processing-feed.md`); the phase ships eight of the nine designed states as a result. Deleting the lying indicator is unconditional UI work and ships regardless of that parked item.
2. **The permanently cancelled polling timer** - `lib/bloc/app_bloc.dart:192-195` (closed by plan 02; verified end-to-end here). **After:** `WalletsOverviewState._handleLinkTap`'s `ComputeLink.retry` case dispatches `context.read<AppBloc>().add(RetryProcessingStatus())`. `compute_panel_wiring_test.dart`'s third test proves this is real: it seeds `processingFeedStatus: unavailable`, confirms `'Status unavailable'`/`'Retry ›'` render, taps `'Retry ›'`, and confirms `appBloc.state.processingFeedStatus` flips to `neverTicked`.
3. **The vanishing primary action** - `lib/components/job/submit_job_dashboard_button.dart:22-26` (`if (!isSelectedWalletLinkedToSGNUS) return const SizedBox.shrink();`, discarding both addresses that would explain the state). **After:** file deleted entirely. `ComputePanel`'s CTA (`GWButton`) always renders; it is disabled via `onPressed: view.ctaEnabled ? onNewJob : null` and the compute tile's sub-line carries the reason and a way out (e.g. `Choose a wallet ›` / `Switch wallet ›`) instead of a silent empty box.
4. **The zero balance painted as a failure** - `lib/components/wallet_overview.dart:141-148`, with the error token applied at `:145` (pre-rewrite; `Text('No funds available', color: context.gw.statusError)` shown whenever `balance == 0`). **After:** the rewritten `wallet_overview.dart` performs no such check at all - `balance` is passed straight to `ComputePanel`, whose `_BalanceTile` renders it through `GWAnimatedNumber` with zero special-cased nowhere (confirmed by reading `compute_panel.dart`'s `_BalanceTile.build` - there is no zero branch).
5. **The hardcoded light-mode-invisible colour** - `lib/wallets/view/genius_balance_display.dart:81` (`color: widget.fontColor ?? Colors.white`) on the 48px balance. **After:** closed *for this card* by routing the balance through `ComputePanel`'s own themed `GWAnimatedNumber` (`color: gw.textPrimary`) at the display numeric style, which also returns height to budget. `genius_balance_display.dart` itself is left in place, unedited - it has other call sites outside this phase's fence. **The same defect appears a third time**, on the unit suffix, at `genius_balance_display.dart:94` (`color: widget.fontColor ?? Colors.grey`) - confirmed present, not named in `14-CONTEXT.md` or the roadmap, and it stays open: it travels with the widget, not with this card, and belongs to whichever phase re-skins the remaining call sites.

## Deleted files - confirmed with no dangling references

- `lib/components/sgnus/sgnus_connection_widget.dart` (`SGNUSConnectionWidget`, `SGNUSConnectionStatusWidget`)
- `lib/components/job/submit_job_dashboard_button.dart` (`SubmitJobDashboardButton`)
- `grep -rn "SGNUSConnectionWidget\|SubmitJobDashboardButton" lib/` returns nothing (exit 1) after cleanup.

## Unit toggle - the DECIDED resolution and the corrected arithmetic

**This was DECIDED by Jakub on 2026-07-29, not merely raised here** - the plan's Task 3 records the decision text verbatim in its own body. Implemented per that decision:

1. The `ToggleButtons` block is gone from `wallet_overview.dart` (`! grep -q "ToggleButtons" lib/components/wallet_overview.dart` passes).
2. The unit suffix beside the balance number is now `_UnitToggle` (`compute_panel.dart`): `>=24x24` hit area via `ConstrainedBox`, `InkWell`/`Material(type: transparency)` for keyboard focus and operability, `Semantics(button: true, label: 'Balance unit', value: 'GNUS'|'MINIONS')` for screen-reader announcement. The existing `useMinions` plumbing is unchanged in shape - it is threaded as a constructor parameter through `ComputePanel` -> `_BalanceTile` -> `_UnitToggle` rather than the `genius_balance_display.dart:33/:49/:89` call sites the plan's action text names, because this card no longer uses that widget at all (superseded by routing through `ComputePanel`'s own `GWAnimatedNumber`, bug 5 above) - `_useMinions`/`_toggleUnit` in `WalletsOverviewState` is the direct continuation of that same flag under a new home.
3. `test/dashboard/compute_panel_height_test.dart` was extended (not just re-run) to cover `useMinions: true` and `useMinions: false` across all 8 shipped states at both test widths - 32 total assertions, all passing, budget 274px.
4. The control is keyboard-operable (`InkWell`) and announces the active unit (`Semantics(value:)`).

**Plan assertion that turned out false about the actual code:** the plan's Task 3 corrects an earlier "+8px, not 0" cost claim, and separately asserts the 8px is "expected to be available" because "the `≈ $` sub-line is dropped in precisely the states where the compute bar renders - the tall ones." Both the direction of that claim and the final number are contradicted by measurement:

- Per 14-07-SUMMARY.md's own measured table, the bar-showing states (`startingUp` 256px, `processing` 234px) are the *shorter* states, not the tall ones; the fiat sub-line is shown in the *taller* 268px states (`disconnected`, `notLinked`, `unavailable`, `jobComplete`, `ready` - all `showBalanceFiatSubline: !showBar`), which is the reverse of what the plan's narrative says.
- More importantly, a throwaway height probe (`test/dashboard/_height_probe_test.dart`, run then deleted per the plan's no-new-tooling constraint) measured the actual `ComputePanel` content height with the shipped toggle in place, at both `useMinions: true` and `false`, against the exact pre-toggle numbers from 14-07: **every state measures byte-identical to the pre-toggle number** - `noWallet` 224px, `disconnected`/`notLinked`/`unavailable`/`jobComplete`/`ready` 268px, `startingUp` 256px, `processing` 234px, in both units. The toggle's real measured cost is **0px, not +8px**, because it sits inline in a `Row` whose height is governed by the 40px `GWAnimatedNumber` text (taller than the toggle's own 24px minimum), not by the toggle's own constraint. The plan's corrected arithmetic does not materialize in this implementation; the originally-proposed (and explicitly rejected in the plan text) "costs no height" claim is what the measured code actually shows for this specific inline-placement design. Recorded here rather than silently "fixed" in the plan's own reasoning, per the reporting requirement to flag planning-document assertions that do not match the code.

## Phase-level records (this is the last plan in the phase)

- **The Phase 23 GWCopyRow-promotion reversal**, carried forward from `14-03-SUMMARY.md`: Phase 23 declined promoting `GWCopyRow` on a Rule-of-Three floor (two consumers found, not three). Plan 03 of this phase reversed that refusal with cause and promoted it; plan 06 consumed it as the third real consumer (the bridge-hash row in the job-result terminal states), closing the reversal's own condition. See `14-03-SUMMARY.md`'s "Cross-phase decision" section for the full record; stated here once as this phase's final summary, per the plan's own output instruction.
- **The phase ships eight of the nine designed states.** State 04 (*Stalled*) is parked - `.planning/todos/pending/2026-07-29-stall-detector-needs-a-traced-processing-feed.md` names why (the 52.5% stall is on `getInitializationStatus()`, polled at 3s, not on the processing feed a stall detector would need to be traced against) and records the banding math for whoever picks it up.
- **The bridged-but-not-processed terminal (T2) shipped informational only.** `.planning/todos/pending/2026-07-29-can-requestgeniussdkprocess-be-recalled-after-a-successful-bridge.md` names the parked question (whether `requestGeniusSDKProcess` can be safely re-called after a successful bridge) that blocks adding a retry action to that terminal state.
- **The unit toggle decision** is recorded above under its own heading, as this plan's output instruction requires.

## Files Created/Modified/Deleted

- `lib/components/wallet_overview.dart` - full rewrite: owns `GnusCubit`/`SubmitJobCubit`, resolves `ComputeState`/`ComputeStatusView` from real inputs, mounts `ComputePanel`, wires all four affordances, keeps the scroll-safety wrapper with corrected numbers.
- `lib/dashboard/compute/compute_panel.dart` - added `useMinions`/`onToggleUnit` params, replaced the `GWAnimatedNumber` suffix with the new `_UnitToggle` widget (>=24x24, `InkWell`, `Semantics`).
- `test/dashboard/compute_panel_wiring_test.dart` - new; 3 tests proving the disconnected/not-linked precedence and the real retry dispatch.
- `test/dashboard/compute_panel_height_test.dart` - extended to assert both `useMinions` values across all states/widths (32 assertions total).
- `test/theme/compute_contrast_test.dart` - updated `ComputePanel(...)` construction for the two new required params.
- `lib/components/wallet_information.dart` - dead-code stub: removed the deleted widget's import and call site, replaced with `SizedBox.shrink()` + explanatory comment (only importer is a dev-only compile canary).
- `lib/components/wallets_overview.dart` - same treatment; this is a documented dead "shadow" file (`03-SHADOW-NAMES.md`/GAP-06) with the same single dev-canary importer.
- `lib/dev/dev_mock_sgnus.dart` - doc-comment fix only, updated a reference from the deleted `SubmitJobDashboardButton` to the compute panel's primary action.
- `lib/components/sgnus/sgnus_connection_widget.dart` - deleted.
- `lib/components/job/submit_job_dashboard_button.dart` - deleted.

## Decisions Made

See `key-decisions` in the frontmatter. The one decision with product weight (the unit toggle) was already made by Jakub on 2026-07-29 and is implemented, not re-litigated, here; its corrected-vs-measured arithmetic is recorded above rather than silently reconciled.

## Deviations from Plan

### Auto-fixed / necessary-consequence edits (not Rule 1-3 bugs, but scope the plan's own instructions required)

**1. [Rule 2-adjacent - necessary consequence of Task 3's explicit instructions] Touched `compute_panel.dart` and its two 14-07 test files**
- **Found during:** Task 3
- **Issue:** Task 3's `<files>` list names only `lib/components/wallet_overview.dart`, but its own action text requires adding a `useMinions`/`onToggleUnit` API to `ComputePanel`, which lives in a different file owned by plan 07.
- **Fix:** Added the two params to `ComputePanel`/`_BalanceTile`, added `_UnitToggle`, extended `compute_panel_height_test.dart` and updated `compute_contrast_test.dart`'s construction call.
- **Files modified:** `lib/dashboard/compute/compute_panel.dart`, `test/dashboard/compute_panel_height_test.dart`, `test/theme/compute_contrast_test.dart`
- **Verification:** `flutter test --no-pub test/dashboard/compute_panel_height_test.dart` and `test/theme/compute_contrast_test.dart` both pass in full (see Verification below).

**2. [Rule 3 - blocking, compile correctness] Edited two dead-code files and one dev-tool file to remove references to the deleted widgets**
- **Found during:** Task 2
- **Issue:** Deleting `sgnus_connection_widget.dart` and `submit_job_dashboard_button.dart` would leave `lib/components/wallet_information.dart` and `lib/components/wallets_overview.dart` (both reachable only from `lib/dev/generated_closure_canary.dart`, a compile-only dev canary never mounted in the running app) with broken imports, and would leave a stale doc-comment reference to `SubmitJobDashboardButton` in `lib/dev/dev_mock_sgnus.dart`.
- **Fix:** Replaced the dead blocks with `SizedBox.shrink()` plus an explanatory comment in the two dead-code files; reworded the doc comment in `dev_mock_sgnus.dart` to reference the compute panel instead. Comments were reworded to name the deleted *file paths* rather than the literal class names, so the plan's own `grep -rn "SGNUSConnectionWidget|SubmitJobDashboardButton" lib/` verification would not false-positive on documentation.
- **Files modified:** `lib/components/wallet_information.dart`, `lib/components/wallets_overview.dart`, `lib/dev/dev_mock_sgnus.dart`
- **Verification:** `flutter analyze` - "No issues found!"; the grep verification returns nothing.

---

**Total deviations:** 2, both necessary consequences of the plan's own explicit instructions (not scope creep) - one because Task 3's capability lives partly in a different file, one because two dead-code files and one dev-tool file would otherwise fail to compile once the superseded widgets were deleted, which the plan's own `flutter analyze` verification requires to stay clean.
**Impact on plan:** No scope creep. Neither edit changes runtime behaviour of the running app - `wallet_information.dart` and `wallets_overview.dart` are confirmed reachable only from a dev-only compile canary.

## Known Stubs

- **`fiatSubline: ''`** in `lib/components/wallet_overview.dart` - always empty. A live GNUS/USD price feed (CoinGecko's `fetchCoinsMarketData`) was implemented during this session, then deliberately reverted: firing a real, unguarded HTTP call from `initState` risks the exact `flutter test`/`FakeAsync` hang class `test/account/account_drawer_show_test.dart`'s own header extensively documents for real I/O inside `testWidgets`. `ComputeStatusView.showBalanceFiatSubline` still gates correctly; this only means the fiat sub-line renders empty rather than a `≈ $` amount. No bug this plan closes depends on it - it does not block any of the five named shipped bugs or Task 3's must-haves. Flagged here for whichever future plan wires a hermetic price source (e.g. injected via a provider/repository the widget test can fake, rather than called directly from `initState`).

## Threat Flags

None found beyond what the plan's own `<threat_model>` already registers (T-14-29 through T-14-33, T-14-SC) - all five are addressed by the closures/deletions described above, and no new network endpoint, auth path, or trust-boundary crossing was introduced.

## Issues Encountered

1. **`undefined_named_parameter: shrinkWrap`** - wrongly assumed `SingleChildScrollView` had a `shrinkWrap` parameter (by analogy with `ListView`). Fixed by reading `_RenderSingleChildViewport.performLayout()`'s actual behavior (`size = constraints.constrain(child!.size)` - it already hugs the child's size) and removing the erroneous parameter; the doc comment in `compute_panel.dart`'s `_BalanceTile` explains the real mechanism instead.
2. **`const_eval_property_access`** on `const SGNUSConnection(sgnusAddress: _linkedWallet.address, ...)` in the wiring test - a freezed-generated field access is not const-evaluable. Fixed by dropping the `const` keyword on that one call.
3. **Broadcast-stream-needs-two-pumps** - two of the three wiring tests initially failed (`Found 0 widgets with text "Not linked"` etc.) despite a single `tester.pump()` after `emitConnection()`. Root-caused via an isolated throwaway repro (deleted after use) proving a broadcast `StreamController.add()` needs two `tester.pump()` calls - one for the stream's own microtask delivery, one for the `StreamBuilder`'s follow-up `setState`. Fixed by adding a second pump after every emission and after the retry tap, with an inline comment recording why.
4. **Plan verification grep false positives** - my own explanatory comments in the three dead/dev files initially matched the plan's required `grep -rn "SGNUSConnectionWidget|SubmitJobDashboardButton" lib/` (must return nothing). Fixed by rewording all three comments to name the deleted file paths instead of the literal class names.

## Verification - real captured output

- `flutter analyze` (repo-wide, run fresh in this session): **"No issues found! (ran in 17.6s)"**
- `bash tool/check_brace_style.sh --count`: **0**
- `bash tool/check_raw_colors.sh --count`: **0**
- `bash tool/check_no_new_key_logging.sh` against the 5 lib files touched this plan: **"OK: no new key logging"** (exit 0)
- `grep -rn "SGNUSConnectionWidget\|SubmitJobDashboardButton" lib/`: **no matches** (exit 1)
- `test ! -f lib/components/sgnus/sgnus_connection_widget.dart && test ! -f lib/components/job/submit_job_dashboard_button.dart`: **both true**
- `! grep -q "ToggleButtons" lib/components/wallet_overview.dart`: **true** (the string is absent)
- `flutter test --no-pub test/dashboard/compute_panel_wiring_test.dart`: **3/3 passed**
- `flutter test --no-pub test/dashboard/` (the full directory, includes `compute_panel_wiring_test.dart`, `compute_panel_height_test.dart` and all pre-existing dashboard tests): **284/284 passed**
- `flutter test --no-pub test/theme/compute_contrast_test.dart`: **38/38 passed**
- `flutter test --no-pub test/freeze_rule_test.dart`: **1/1 passed**
- `flutter test --no-pub` (full suite, re-run fresh in this session): **823/823 passed, 0 failures, exit code 0** - matches the count from earlier in this same session; no regressions against 14-01's baseline.
- `dart format --set-exit-if-changed` across every file touched this plan: **"Formatted 8 files (0 changed)"**

**Nothing in the above is attributable to the concurrent 09-08 (Banxa) agent.** `git status --short` throughout this session showed only my own files plus the Banxa-owned files that agent is mid-editing (`lib/banxa/**`, `lib/navigation/router.dart`, `lib/screens/banxa_buy_screen.dart`, `lib/screens/order_details_page.dart`, `test/banxa/**`); none of those files were read, edited, or reverted by this work, and every `flutter analyze`/`flutter test` run above returned clean - there were no failures to attribute to either party.

### Human-check walk NOT performed this session

The plan's `<human-check>` block (8 items: every state renders distinctly, the card never scrolls/clips, the primary action is present-but-disabled with a legible reason, switch-wallet actually opens the drawer, retry actually revives the unavailable state visually, a job runs end to end from the card, both terminal states render correctly, a zero balance shows as zero) was **not run this session** - this was code-only execution with the dev-tools bubble not launched and no live app/device walk performed. This is recorded per the plan's own instruction that the human-check items are separate from the automated `<verification>` block, and per the reporting requirement to state clearly what was and was not verified.

## Next Phase Readiness

- The dashboard's first card is fully wired to real data; the phase's stated objective ("mount the panel on real data, wire its affordances, close the five shipped bugs, delete what it supersedes") is met by automated verification.
- Two items remain explicitly parked outside this plan's fence, both already filed as pending todos: the stall detector (state 04) and the bridged-but-not-processed retry question (T2).
- The third occurrence of the light-mode-invisible colour literal (`genius_balance_display.dart:94`) remains open and belongs to whichever future phase re-skins that widget's remaining call sites.
- The empty `fiatSubline` (Known Stub above) is a candidate for a future plan once a hermetic price source is designed.
- The end-of-phase human-check walk (8 items, see above) has not been performed and should be run before this phase is considered fully verified by a human.

## Self-Check: PASSED

- All 9 files claimed created/modified confirmed present on disk (`test/dashboard/compute_panel_wiring_test.dart` through this SUMMARY.md itself).
- Both deleted files confirmed gone (`test ! -f`, both true).
- `git log --oneline -3` confirms HEAD is unchanged from before this session - no commit was created, per the absolute no-commits constraint.
- `git status --short` confirms the working tree contains only this plan's own changes plus the concurrent 09-08 (Banxa) agent's in-progress edits - no other file was touched.

---
*Phase: 14-compute-panel-job-flow*
*Completed: 2026-07-31*
