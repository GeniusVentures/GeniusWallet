---
phase: 08-swap-bridge
plan: 04
subsystem: ui
tags: [flutter, gw-colors, gw-button, design-system, bridge, cta-ladder, mechanics-preservation]

requires:
  - phase: 08-01
    provides: "SwapField vocabulary (surfaceElevated card, 38px numericDisplay hero, surfaceMenu pill, ResponsiveDrawer conventions) mirrored inline for bridge's Coin/Network-typed fields"
  - phase: 08-03
    provides: "swap_cta_state.dart pattern (pure-Dart ladder module) and the seam/CTA-mapping idiom this plan's bridge_cta_state.dart and _buildCta mirror"
provides:
  - "lib/dashboard/bridge/bridge_cta_state.dart — pure Dart CTA state ladder (resolveBridgeCtaState / bridgeCtaLabel / bridgeCtaEnabled), 16 unit tests"
  - "bridge_screen.dart wearing sketch 120 B1: Phase 7 back-arrow AppBar, 560px column, network route bar with ResponsiveDrawer destination picker, You Pay / You Receive on {network} cards, two-row gas card, GWButton CTA"
  - "bridgeOut(... shouldMintTokens: true) and getBrigeOutGasCost(...) byte-identical to develop — the highest-consequence re-skin in the phase"
affects: [08-06-bridge-result]

tech-stack:
  added: []
  patterns:
    - "Pure-Dart state-resolver module (no Flutter imports) feeding a screen's paint layer — same pattern as 08-03's swap_cta_state.dart, deliberately NOT shared with it (bridge has no route fetch/Retry rung, swap has no gas estimate)"
    - "Debounced mechanics body copied verbatim into a re-skinned TextField.onChanged — only additive, non-mechanical state (isEstimating) wraps the real API call; no argument, guard, or precheck touched"
    - "Submit closure extracted into a named async method (_submitBridge) wrapped with isSubmitting/finally — same shape as 08-03's _submitSwap extraction"

key-files:
  created:
    - lib/dashboard/bridge/bridge_cta_state.dart
    - test/dashboard/bridge/bridge_cta_state_test.dart
  modified:
    - lib/dashboard/bridge/bridge_screen.dart

key-decisions:
  - "Ready CTA label locked to 'Bridge' (develop's own word), not the UI-SPEC's alternative 'Review bridge' — no second confirmation step exists on this screen, so claiming a review step would be a D-02-style fabrication. The plan's own must_haves LOCK this; not a judgment call, just confirming the lock was honored."
  - "Balance null -> insufficientBalance (NOT swap's 'never accuse on missing data' rule). Bridge's own precheck at bridge_screen.dart (fromToken?.balance == null) already treats an unknown balance as insufficient and returns before any API call; the ladder mirrors that exactly rather than importing swap's more lenient rule. Locked by the plan's <behavior> bullets, confirmed in tests."
  - "The pre-debounce window (valid, affordable amount; not estimating; no error; no estimate yet) resolves to estimatingGas, not a seventh rung. Not covered by the plan's <behavior> bullets explicitly — decided under D-21 so the CTA never falsely enables before a real gas estimate exists (fail-closed default)."
  - "The 'You Receive on {network}' card's destination pill is NOT independently tappable — the network route bar's destination chip (Task 2) is the single picker entry point. Avoids two separate tap targets doing the same job, which the plan doesn't specify either way. Decided under D-21."
  - "Task 2's shell edit temporarily left the old You Pay Coin dropdown and gas-cost TextButton/Row in place (removing only the Network dropdown, per its own scope) so each task's own analyze-baseline gate stayed clean in isolation; Task 3 replaced them. Sequencing choice under D-21 standing authorization, not a plan deviation — both tasks' own verify gates passed independently."
  - "Gas card's 'You receive' row uses fromToken?.symbol (dynamically GNUS, since bridge is GNUS-only) rather than a hardcoded 'GNUS' literal — same value, but sourced from the passed-in coin so it can never drift from the actual bridged token."

patterns-established:
  - "Behavior-Adding-Task TDD discipline applied to Task 1: test file written and run RED (compile failure — module didn't exist) before bridge_cta_state.dart existed, then GREEN once the module landed — 16 tests covering every <behavior> bullet plus the exactly-affordable boundary, the null-balance case, and submitting's outranking of every other rung."

requirements-completed: []

coverage:
  - id: D1
    description: "bridge_cta_state.dart: pure-Dart CTA ladder (6-state enum, precedence resolver, GNUS-denominated label copy, enabled rule) with 16 unit tests covering every <behavior> bullet, the exactly-affordable boundary, the null-balance case, and submitting's outranking of every other rung"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "test/dashboard/bridge/bridge_cta_state_test.dart (16/16 pass)"
        status: pass
      - kind: unit
        ref: "flutter analyze lib/dashboard/bridge/bridge_cta_state.dart (0 issues) + purity grep (no material.dart/BuildContext) + ready-label grep (no 'Review bridge')"
        status: pass
    human_judgment: false
  - id: D2
    description: "Bridge shell re-laid-out to sketch 120 B1: Phase 7 back-arrow AppBar (48px toolbarHeight, surfaceSunken, automaticallyImplyLeading: false, 30x30 chevron InkWell) reused verbatim from token_info_screen.dart, 560px centred column, network route bar (non-tappable source chip / arrow / centred Bridge pill / tappable destination chip), destination picker as a ResponsiveDrawer list fed by the SAME availableBridgeNetworks and the SAME setState(() => toNetwork = ...) setter the old dropdown used, dead previousNetwork field removed"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "grep gates (toolbarHeight: 48, automaticallyImplyLeading: false, maxWidth: 560, ResponsiveDrawer, availableBridgeNetworks all present; previousNetwork and TokenSelectorDrawer both absent) + flutter analyze lib (59, at baseline)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Bridge amount cards (You Pay / You Receive on {network}), two-row gas card (You receive + Estimated gas cost, em dash on unknown estimate instead of develop's literal 0), and a GWButton-driven CTA ladder wired to bridge_cta_state.dart — with the 300ms-debounced onAmountChanged body, the _isApiCallInProgress guard, the pre-API balance precheck, all six getBrigeOutGasCost arguments, and bridgeOut(... shouldMintTokens: true)'s all seven arguments byte-identical to develop"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "grep gates (DecimalTextInputFormatter(), milliseconds: 300, _isApiCallInProgress, shouldMintTokens: true, getBrigeOutGasCost, resolveBridgeCtaState, GWButtonVariant.gradient, 'You Receive on', ToastManager.instance.showToast all present; zero DropdownButton/_buildDropdown matches outside comments; zero 'Est. time'/'Estimated time' matches) + flutter analyze lib (59) + flutter test (285 pass / 1 known pre-existing failure, up from 269/1 baseline by exactly this plan's +16)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Visual/contrast fidelity of the 120 B1 re-skin (route bar legibility in both modes, card seam/spacing read as swap's twin, disabled-rung WCAG AA) and the live entry-path re-confirmation (isGnusBridgeEnabled + zero-balance gate at the caller, /bridge still reached only from GNUS token -> More -> Bridge Tokens) — the 08-07 human walk this routes to"
    requirement: SCR-04
    verification: []
    human_judgment: true
    rationale: "This plan is explicitly forbidden (D-12) from adding an in-screen isGnusBridgeEnabled or zero-balance gate, and forbidden (D-23) from ever firing a real bridgeOut(...) call — bridgeOut is a genuine on-chain burn/mint, not a stub. No automated gate may invoke it. Whether a full live walk (including a real submission) happens is an explicit open question for 08-07's checkpoint, not this plan's job."
  - id: D5
    description: "Both mechanics-sensitive additions (isEstimating around the gas call, isSubmitting around the submit closure) are ADDED state only — no existing branch, guard, argument, or precheck was reordered, restructured, or 'tidied'"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "Manual line-by-line diff review during Task 3: the debounce body's try/catch balance precheck, the _isApiCallInProgress guard, the six getBrigeOutGasCost arguments, and both setState outcome branches are textually identical to develop except for the two added isEstimating lines; _submitBridge's body (bridgeOut's seven arguments, the mounted guard, the ToastManager call, the full AlertDialog) is textually identical to develop except for the setState(isSubmitting)/try-finally wrapper"
        status: pass
    human_judgment: false

duration: 35min
completed: 2026-07-25
status: complete
---

# Phase 8 Plan 4: Bridge re-skin — 120 B1 layout (swap-twin), CTA ladder, mechanics untouched Summary

**Bridge screen re-laid-out to sketch 120 B1 (the Swap tab's twin): Phase 7 back-arrow AppBar, 560px column, network route bar with a ResponsiveDrawer destination picker, You Pay/You Receive-on-{network} cards, a two-row gas card with an em-dash honesty fix, and a `bridge_cta_state.dart`-driven `GWButton` CTA — while `getBrigeOutGasCost(...)` and `bridgeOut(... shouldMintTokens: true)`, the real on-chain burn/mint calls, remain byte-identical to develop.**

## Performance

- **Duration:** ~35 min
- **Tasks:** 3/3
- **Files modified:** 1 (`bridge_screen.dart`, 727 -> 923 lines) + 1 new module + 1 new test file

## Accomplishments
- `lib/dashboard/bridge/bridge_cta_state.dart` (new, pure Dart, no Flutter imports): a 6-state `BridgeCtaState` enum, `resolveBridgeCtaState()` implementing the exact precedence (`submitting` → `enterAmount` → `insufficientBalance` → `estimatingGas` → `gasError` → `ready`), `bridgeCtaLabel()` returning GNUS-denominated copy with the ready rung locked to "Bridge" (not "Review bridge" — no second confirmation step exists), and `bridgeCtaEnabled()` (true only for `ready`) — 16 unit tests, all green. Deliberately does NOT share `swap_cta_state.dart`'s enum (bridge has no route fetch/Retry rung; swap has no gas estimate).
- Bridge shell re-laid-out to sketch 120 B1: the Phase 7 back-arrow AppBar convention reused verbatim from `token_info_screen.dart` (48px `toolbarHeight`, `surfaceSunken`, `automaticallyImplyLeading: false`, 30x30 chevron `InkWell`), a centred 560px `ConstrainedBox` column on `gw.surfaceBase`, and a network route bar directly under the header (non-tappable source chip showing `state.selectedNetwork`, arrow, centred "Bridge" pill, tappable destination chip). The destination chip opens a `ResponsiveDrawer.show` list (`_NetworkPickerRow`) fed by the SAME `availableBridgeNetworks` data and calling the SAME `setState(() => toNetwork = newNetwork)` the old `DropdownButton<Network>`'s `onItemChanged` performed — a re-skinned selector, not a new data path. The dead `previousNetwork` field was removed.
- Both amount cards rebuilt in the swap vocabulary (surfaceElevated, radiusLg, borderSubtle hairline, labelMd label, 38px numericDisplay hero, surfaceMenu pill) built inline rather than importing `SwapField` (which is `SquidTokenInfo`-typed, not `Coin`/`Network`-typed). "You Pay"'s pill is fixed (GNUS-only, not tappable, D-12) and its `TextField` keeps `DecimalTextInputFormatter()` and the 300ms-debounced `onAmountChanged` body copied verbatim — same `_isApiCallInProgress` guard, same try/catch pre-API balance precheck returning before any call, same six `getBrigeOutGasCost` arguments, same success/failure `setState` branches. Only `isEstimating` (added state, set true right before the API call, false in both outcome branches) was introduced so the CTA ladder has a real in-flight signal. "You Receive on {toNetwork.name}"'s field stays read-only, driven only by `toAmountController` (the 1:1 echo); its pill is a non-tappable display mirror of `toNetwork` (the route bar's chip is the single picker entry point).
- Gas card: exactly two data-backed rows — "You receive" (the 1:1 echo + `fromToken?.symbol`) and "Estimated gas cost" (`transactionCost`, unchanged). An unknown estimate now renders an em dash (`—`) instead of develop's literal `0`, which read as a free bridge — the one authorized honesty fix inside the re-skin. No "Est. time" row was added (no data source exists for it anywhere in the code — the UI-SPEC lists it speculatively and this plan's `must_haves` explicitly negative-gates it).
- CTA: the `ready` rung renders through the real `GWButton(variant: GWButtonVariant.gradient, size: lg, expand: true)`; every disabled rung renders through a small hand-rolled fixed-size (56px/radiusLg) `DecoratedBox` using `gw.surfaceMenu`/`gw.textPrimary38` (enterAmount/estimatingGas/submitting) or `gw.statusError`-at-12%/`gw.statusError` (insufficientBalance/gasError) — the exact mapping the swap CTA uses (D-15). The submit closure was extracted verbatim into `_submitBridge(context, state)`, wrapped with `isSubmitting = true`/`finally`: `bridgeOut(...)`'s all seven arguments including `shouldMintTokens: true`, the `if (!context.mounted) return;` guard, the `ToastManager.instance.showToast(...)` call, and the full existing result `AlertDialog` are all byte-identical to develop. `08-06` still owns replacing that dialog with the shared receipt.
- `_buildDropdown<T>` deleted once nothing called it; `_cryptoIcon` kept (the AlertDialog still uses it until `08-06`).

## Task Commits

Each task was committed atomically:

1. **Task 1: Extract the bridge CTA ladder into a pure, tested module** - `befe971` (test)
2. **Task 2: Bridge shell — back-arrow AppBar, 560px column, network route bar, destination picker drawer** - `d3af5ed` (style)
3. **Task 3: Bridge amount cards, gas card and gradient CTA — mechanics preserved verbatim** - `8c8548f` (style)

## Files Created/Modified
- `lib/dashboard/bridge/bridge_cta_state.dart` - new pure-Dart CTA state ladder
- `test/dashboard/bridge/bridge_cta_state_test.dart` - new, 16 unit tests
- `lib/dashboard/bridge/bridge_screen.dart` - 120 B1 layout, mechanics-preserved re-skin

## Decisions Made
- Ready CTA label: "Bridge" (locked by the plan's must_haves — develop's own word, no review step exists).
- Balance-null handling: `insufficientBalance`, mirroring bridge's own precheck rather than swap's "never accuse on missing data" rule (locked by the plan's `<behavior>` bullets, confirmed in tests).
- Pre-debounce window (valid amount, no estimate yet) resolves to `estimatingGas` rather than a new rung — fail-closed default so the CTA never falsely enables. D-21 judgment, not specified by the plan.
- "You Receive" card's destination pill is display-only, not a second tap target for the network picker — the route bar's chip is the single entry point. D-21 judgment.
- Task 2/Task 3 sequencing: Task 2 removed only the Network dropdown (keeping the Coin dropdown and old CTA/gas row temporarily) so each task's own `flutter analyze lib` gate passed in isolation at the 59 baseline; Task 3 completed the replacement. Both tasks' verify gates passed independently — not a deviation.
- Gas card's "You receive" row sources the symbol from `fromToken?.symbol` (dynamically GNUS) rather than a hardcoded literal.

## Deviations from Plan

None — plan executed exactly as written. All judgment calls above are routine, in-scope discretion pre-authorized by D-21 and documented rather than treated as deviations.

## Mechanics Preservation Confirmation (D-11, the whole risk of this plan)

Verified line-by-line during Task 3 and by grep gate:
- `bridgeOut(... shouldMintTokens: true)` — all seven arguments (`sourceChainId`, `contractAddress`, `rpcUrl`, `address`, `amountToBurn`, `destinationChainId`, `shouldMintTokens: true`) unchanged, present in `_submitBridge`.
- `getBrigeOutGasCost(...)` — all six arguments (`sourceChainId`, `contractAddress`, `rpcUrl`, `address`, `amountToBurn`, `destinationChainId`) unchanged, present in the pay card's debounce body.
- The 300ms debounce (`Duration(milliseconds: 300)`) — unchanged.
- The `_isApiCallInProgress` guard — unchanged, present at the top of the debounced closure.
- The pre-API balance precheck (`(double.parse(value)) > (fromToken?.balance ?? 0) || fromToken?.balance == null`) — unchanged, still returns BEFORE any API call.
- `isGnusBridgeEnabled` — NOT touched; confirmed absent from `bridge_screen.dart` (grep, zero matches). That gate lives entirely at the caller (`token_info_screen.dart`), as D-12 requires; this plan added no second gate.
- `DecimalTextInputFormatter` — kept, still applied to the pay amount `TextField`'s `inputFormatters`; the class itself is untouched.
- The destination-network selector's behavior — unchanged: same `availableBridgeNetworks` list, same `setState(() => toNetwork = newNetwork)` setter, only the presentation shell changed from `DropdownButton<Network>` to a `ResponsiveDrawer` list.
- The 1:1 echo (`toAmountController.text = value` inside the debounce's success branch) — unchanged.
- Bridge stays a back-arrow sub-screen reached only via `/bridge` — no tab, no swap/bridge toggle was added (grep-confirmed).

**No real `bridgeOut(...)` call was ever fired during this plan's execution** (D-23) — all verification was static (grep gates, unit tests, `flutter analyze`, `flutter test`) plus manual line-by-line diff review of the extracted closures against develop's original text.

## Issues Encountered
None. The large single-file restructuring (727 -> 923 lines) was done via staged, verified edits (shell first, then cards/CTA), with `flutter analyze lib/dashboard/bridge/bridge_screen.dart` run after each stage to catch compile errors early.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
The bridge screen now reads as the Swap tab's twin end to end, with every argument reaching `getBrigeOutGasCost` and `bridgeOut` byte-identical to develop's. `08-06` (bridge result path) can now replace the existing `AlertDialog` in `_submitBridge` with the shared `showTransactionDetails` receipt without touching any mechanics this plan preserved. `flutter analyze lib` holds at 59 (baseline, no regression); `flutter test` is 285 pass / 1 known pre-existing failure (269 baseline + this plan's 16 new `bridge_cta_state_test.dart` tests; `local_wallet_storage_test.dart` remains the sole pre-existing failure, a "Missing definition of `main` method" load error, not a runtime assertion failure). No blockers.

**Note per task instructions:** `requirements.mark-complete` was NOT run for SCR-04 in this plan — SCR-04 closes at phase verification (08-07/08-08), not per-plan, per explicit instruction to avoid the self-contradictory REQUIREMENTS.md state a prior premature mark-complete caused.

---
*Phase: 08-swap-bridge*
*Completed: 2026-07-25*

## Self-Check: PASSED
- FOUND: lib/dashboard/bridge/bridge_cta_state.dart
- FOUND: test/dashboard/bridge/bridge_cta_state_test.dart
- FOUND: lib/dashboard/bridge/bridge_screen.dart
- FOUND commit: befe971
- FOUND commit: d3af5ed
- FOUND commit: 8c8548f
