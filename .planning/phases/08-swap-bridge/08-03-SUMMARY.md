---
phase: 08-swap-bridge
plan: 03
subsystem: ui
tags: [flutter, gw-colors, gw-button, design-system, squid-router, swap, cta-ladder]

requires:
  - phase: 08-01
    provides: "GWPageHeader.subtitle, re-skinned SwapField (with emptyPlaceholder hook), re-skinned TokenFlipButton, RouteDetailsCard golden test"
provides:
  - "lib/squid_router/swap_cta_state.dart — pure Dart CTA state ladder (resolveSwapCtaState / swapCtaLabel / swapCtaEnabled), 18 unit tests"
  - "swap_screen.dart wearing sketch 105 A1: 560px column, brand-sheen wash, seam flip control, no offset hack"
  - "D-09 route-fetch-error hard contract: em-dash receive field, hidden route card, red inline notice, enabled Retry CTA"
  - "GWButton-driven CTA that renders in every ladder state (no more if (canSwap) visibility gate)"
affects: [08-04-bridge]

tech-stack:
  added: []
  patterns:
    - "Pure-Dart state-resolver module (no Flutter imports) feeding a screen's paint layer — colour mapping stays screen-side, precedence/copy/enabled-rule stay in the pure module, fully unit-testable without pumpWidget"
    - "Column-of-two-cards inside a Stack with Alignment.center for a 'seam' control — no Positioned/pixel math, no magic offset; the framework centres the small child inside the larger Column's bounding box"
    - "Non-gradient CTA rungs hand-rolled (fixed 56px/radiusLg DecoratedBox) beside the two gradient rungs (real GWButton(variant: gradient)) — because GWButton's variant palette is closed over six fixed enums that don't include surfaceMenu/statusError-at-alpha fills, and swap_screen.dart was the only file this task was scoped to touch"

key-files:
  created:
    - lib/squid_router/swap_cta_state.dart
    - test/squid_router/swap_cta_state_test.dart
  modified:
    - lib/squid_router/swap_screen.dart

key-decisions:
  - "CTA colour mapping followed the PLAN's literal grouping (enterAmount/findingRoute/submitting all share surfaceMenu+textPrimary38) over the UI-SPEC's more granular table (which gives findingRoute/submitting textSecondary instead of textPrimary38) — the plan's own prohibitions section explicitly says 'reuse the shipped textPrimary38-on-surfaceMenu disabled treatment' for exactly these three rungs, so that instruction was treated as authoritative. Decided under D-21."
  - "Only `ready` and `routeError` render through the real GWButton(variant: GWButtonVariant.gradient) — the UI-SPEC's CTA-state->colour table locks both to the brand gradient. The other four rungs (enterAmount/insufficientBalance/findingRoute/submitting) render through a small hand-rolled fixed-size (56px/radiusLg) DecoratedBox+Text, because GWButton has no variant whose palette is surfaceMenu-fill/textPrimary38-text or statusError@12%-fill/statusError-text, and gw_button.dart was out of scope for this task's <files> list. Decided under D-21."
  - "The seam-flip 'no magic offset' requirement was satisfied via `Stack(alignment: Alignment.center)` wrapping a Column of the two SwapField cards plus the flip control as a third (non-Positioned) child — Flutter centres the flip control in the Stack's bounding box, which (given the two cards render at near-equal height) lands it on the seam without any Positioned/pixel arithmetic anywhere in the file."
  - "Sheen colours: GeniusWalletColors.brandPrimaryStrong (#0AAEE6, cyan) and brandSecondaryStrong (#0AD89C, mint) — these are the exact named tokens behind the sketch's literal rgba(10,174,230,...) / rgba(10,216,156,...) hexes, so using them satisfies 'never a literal hex from the sketch' while still landing on the sketch's intended hues. Alpha scaled down in light mode (0.10/0.08 dark -> 0.05/0.04 light)."
  - "Card-to-card gap in the seam Stack: space8 (16px) — the plan offered 'space6/space8' as either acceptable; space8 was picked so the 44px flip control's overlap into each card is roughly symmetric (~14px into the pay card, ~6px into the receive card past the reduced gap)."
  - "Route-error notice headline weight bumped to w600 (labelMd's base is w500) for the small emphasis; not specified exactly by UI-SPEC, decided under D-21."

patterns-established:
  - "Behavior-Adding-Task TDD discipline applied to Task 1: test file written and run RED before swap_cta_state.dart existed, then GREEN once the module landed — 18 tests covering every <behavior> bullet plus explicit precedence/boundary cases."

requirements-completed: [SCR-04]

coverage:
  - id: D1
    description: "swap_cta_state.dart: pure-Dart CTA ladder (6-state enum, precedence resolver, label copy, enabled rule) with 18 unit tests covering every rung, the exactly-affordable boundary, the null-balance case, and submitting's outranking of every other rung"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "test/squid_router/swap_cta_state_test.dart (18/18 pass)"
        status: pass
      - kind: unit
        ref: "flutter analyze lib/squid_router/swap_cta_state.dart (0 issues) + purity grep (no material.dart/BuildContext import or usage)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Swap tab laid out to sketch 105 A1: 560px column, brand-sheen wash (IgnorePointer, appearance-aware alpha), subtitle passed to GWPageHeader, flip control moved into the seam via Stack+Alignment.center (no Transform.translate/-170 offset anywhere), duplicated fetchedRoute guard collapsed to one"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "grep gates (maxWidth: 560, subtitle:, IgnorePointer, onFlip: _flipTokens, zero Transform.translate/-170 matches, exactly one 'if (fetchedRoute != null)') + flutter analyze lib (59, at baseline) + flutter test test/squid_router/route_details_card_test.dart (pass, figures undisturbed)"
        status: pass
      - kind: automated_ui
        ref: "n/a — visual fidelity of the sheen/seam is a human_judgment deliverable (D3), this entry only covers the structural/grep-provable half"
        status: pass
    human_judgment: false
  - id: D3
    description: "Visual/contrast fidelity of the 105 A1 re-skin (sheen legibility in both modes, seam-overlap look, disabled-rung WCAG AA) — the 08-07 human walk this would normally route to"
    requirement: SCR-04
    verification: []
    human_judgment: true
    rationale: "08-CONTEXT.md D-22 explicitly descopes the 08-07 human walk at Braian's instruction ('lets just switch the design we dont need to test it fully'). This deliverable is recorded as never exercised, not as passed — the automated gates above (analyze/tests/greps) are the only verification actually run for this plan."
  - id: D4
    description: "CTA ladder wired into swap_screen.dart: resolveSwapCtaState/swapCtaLabel/swapCtaEnabled drive a GWButton(variant: gradient) for ready/routeError and a hand-rolled fixed-size control for the other four rungs; the CTA always renders (if (canSwap) visibility gate removed); no ElevatedButton/Colors.greenAccent survives"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "grep gates (resolveSwapCtaState, swapCtaLabel, GWButtonVariant.gradient, emptyPlaceholder, routeError all present; zero ElevatedButton/Colors.greenAccent matches outside comments; zero 'if (canSwap)' matches) + flutter analyze lib (59) + flutter test (269 pass / 1 known pre-existing failure, up from 252/1 baseline by exactly this plan's +18)"
        status: pass
    human_judgment: false
  - id: D5
    description: "D-09 hard contract: on a failed route fetch, fetchedRoute is nulled, toAmount/toAmountController are cleared (em-dash placeholder shows), the route-details card is hidden, a red inline notice renders with the UI-SPEC's exact copy, and the CTA becomes an enabled Retry that calls _fetchRoute() directly (not the debounce)"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "test/squid_router/swap_cta_state_test.dart's routeError group (routeError -> enabled Retry; routeError outranks insufficientBalance) proves the ladder half; the field-clearing/notice/hidden-card wiring in swap_screen.dart's _fetchRoute catch block and _buildSwapCta/_buildRouteErrorNotice is grep-provable (routeError, emptyPlaceholder present) but its live behaviour was not exercised against a real failing fetch in this pass (SquidTokenService.getRoute() never actually throws against mockSquidRoute per D-18b)"
        status: pass
    human_judgment: true
    rationale: "No widget test drives an actual _fetchRoute() failure end-to-end (the mocked service never throws), so the three-simultaneous-effects contract (em dash + hidden card + enabled Retry) is proven by code inspection and the CTA-state unit tests, not by an integration test. Combined with D-22's descoped 08-07 walk, this specific interaction has no live-rendered verification in this milestone — flagged for future attention if the walk is ever revisited."

duration: 30min
completed: 2026-07-25
status: complete
---

# Phase 8 Plan 3: Swap tab assembly — 105 A1 layout, CTA ladder, D-09 route-error state Summary

**Swap tab re-laid-out to sketch 105 A1 (560px column, seam flip control, brand-sheen wash, `-170` offset hack removed) plus a new pure-Dart `swap_cta_state.dart` module driving a `GWButton`-based CTA ladder that renders in every state, including D-09's hard-contract route-error branch (em-dash field, hidden route card, red notice, enabled Retry).**

## Performance

- **Duration:** ~30 min
- **Started:** 2026-07-25T15:00:00-03:00
- **Completed:** 2026-07-25T15:12:00-03:00
- **Tasks:** 3/3
- **Files modified:** 2 (+ 1 new module, + 1 new test file)

## Accomplishments
- `lib/squid_router/swap_cta_state.dart` (new, pure Dart, no Flutter imports): a 6-state `SwapCtaState` enum, `resolveSwapCtaState()` implementing the exact precedence (`submitting` → `enterAmount` → `routeError` → `insufficientBalance` → `findingRoute` → `ready`), `swapCtaLabel()` returning the UI-SPEC's six copy strings verbatim (symbol-interpolated for insufficient balance, with a null/empty-symbol fallback), and `swapCtaEnabled()` (true only for `ready`/`routeError`) — 18 unit tests, all green.
- `swap_screen.dart` re-laid-out to sketch 105 A1: `maxWidth` 500→560, a single `EdgeInsets.symmetric(horizontal: space10)` Padding wrapping the whole column so the header and cards share one left edge, a two-radial-glow brand-sheen wash (cyan `brandPrimaryStrong` + mint `brandSecondaryStrong`, `IgnorePointer`-wrapped, alpha scaled down in light mode), `GWPageHeader(subtitle: "Trade any token across chains")`, the tune icon re-coloured to `gw.textSecondary`, and the flip control moved into the seam via `Stack(alignment: Alignment.center)` wrapping a `Column` of the two `SwapField` cards — the `Transform.translate(Offset(0, -170))` hack is gone entirely, and the doubled `if (fetchedRoute != null)` guard collapsed to one.
- CTA ladder wired end to end: `resolveSwapCtaState`/`swapCtaLabel`/`swapCtaEnabled` are the single source of truth; `ready`/`routeError` render through the real `GWButton(variant: GWButtonVariant.gradient, size: lg, expand: true)`; the other four rungs render through a small fixed-size (56px/radiusLg) hand-rolled control using `gw.surfaceMenu`/`gw.textPrimary38` (or `gw.statusError`-at-12%/`gw.statusError` for `insufficientBalance`) — the old `if (canSwap)` visibility gate is gone, so the CTA now renders in every disabled state too, with a spinner on the submitting rung.
- D-09's hard contract implemented in `_fetchRoute()`'s catch branch: `routeError = true`, `fetchedRoute = null`, `toAmount = ''`, `toAmountController.clear()` — the receive field then shows the `—` placeholder via `SwapField.emptyPlaceholder`, the route-details card is conditioned on `fetchedRoute != null && !routeError` (hidden), a new inline `_buildRouteErrorNotice` renders the UI-SPEC's exact two-part copy in a `statusError@12%` container, and the Retry rung's `onPressed` calls `_fetchRoute` directly (bypassing the 500ms debounce).
- The submit closure was extracted verbatim into `_submitSwap()`, wrapped with `isSubmitting = true` before the body and `isSubmitting = false` in a `finally` — every line inside (both `// TODO:` markers, the `Transaction(...)` construction, the toast, `SwapSuccessDrawer.show(...)`, `transactionsCubit.addTransaction`, `TransactionStorageService().addTransaction`) is byte-identical to develop.

## Task Commits

Each task was committed atomically:

1. **Task 1: Extract the CTA state ladder into a pure, tested module** - `6595212` (test)
2. **Task 2: Lay out the swap tab as sketch 105 A1 and kill the offset hack** - `88a2d8a` (style)
3. **Task 3: Wire the CTA ladder and D-09's route-error state** - `c7f3087` (feat)

## Files Created/Modified
- `lib/squid_router/swap_cta_state.dart` - new pure-Dart CTA state ladder
- `test/squid_router/swap_cta_state_test.dart` - new, 18 unit tests
- `lib/squid_router/swap_screen.dart` - 105 A1 layout, CTA ladder wiring, D-09 route-error state

## Decisions Made
- CTA colour mapping followed the PLAN's literal grouping (see key-decisions in frontmatter) over UI-SPEC's slightly more granular table — the plan's own prohibitions explicitly mandate reusing the textPrimary38-on-surfaceMenu treatment for exactly the enterAmount/findingRoute/submitting trio.
- The two gradient rungs (`ready`, `routeError`) use the real `GWButton`; the other four use a small hand-rolled fixed-size control, since `gw_button.dart` was out of this task's file scope and no existing `GWButtonVariant` palette matches `surfaceMenu`/`textPrimary38` or `statusError@12%`/`statusError`.
- Seam-flip "no magic offset": `Stack(alignment: Alignment.center)` around a `Column` of the two cards, letting Flutter's own centring do the work instead of any `Positioned`/pixel arithmetic.
- Sheen colours use the named brand tokens (`brandPrimaryStrong`, `brandSecondaryStrong`) that happen to be the exact hex values behind the sketch's literal rgba() figures — satisfies "never a literal sketch hex" while landing on the intended hue.
- Card gap in the seam Stack: space8 (16px), one of the two values the plan explicitly permitted.
- Route-error notice headline uses `FontWeight.w600` for light emphasis (labelMd's base is w500) — not specified exactly by UI-SPEC, Claude's discretion under D-21.

## Deviations from Plan

None — plan executed exactly as written. The judgment calls above are all routine, in-scope discretion explicitly pre-authorized by D-21 (task ordering, exact fill-colour source when two documents disagree in detail, spacing-scale pick between two offered values) and are documented rather than treated as deviations.

## Issues Encountered
- Two grep-gate false positives during self-verification: the module-purity gate (`rg "material.dart|BuildContext"`) and the canSwap-gate-removal gate (`rg "if \(canSwap\)"`) both initially matched my own doc comments (prose mentioning "BuildContext" and a backtick-quoted `` `if (canSwap)` `` reference), not code. Reworded both comments to avoid the literal substrings; the underlying code was already correct in both cases.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
The swap tab now wears sketch 105 A1 end to end and carries a fully ladder-driven CTA with a proven D-09 route-error branch. `08-04` (bridge, the swap-twin per D-10) can mirror the seam-overlap technique (`Stack(alignment: Alignment.center)` around a `Column` of two cards) directly — it required no Positioned math and generalises cleanly to bridge's "You Pay"/"You Receive on {network}" pair, though bridge's flip control is decorative-only or omitted per the bridge screen contract. `flutter analyze lib` holds at 59 (baseline, no regression); `flutter test` is 269 pass / 1 known pre-existing failure (252 baseline + this plan's 18 new `swap_cta_state_test.dart` tests, `local_wallet_storage_test.dart` still the sole pre-existing failure — a "Missing definition of `main` method" load error, not a runtime assertion failure). No blockers.

**Not exercised by an automated test in this plan (flagged, not blocking):** a real end-to-end `_fetchRoute()` failure was not driven through a widget test — `SquidTokenService.getRoute()` never actually throws against the mocked `mockSquidRoute` constant (D-18b), so the three-simultaneous-effects contract (em dash + hidden route card + enabled Retry) is proven by code inspection and the CTA-state unit tests rather than an integration test. Combined with D-22's descoped 08-07 human walk, this is the one corner of this plan with no live-rendered verification.

---
*Phase: 08-swap-bridge*
*Completed: 2026-07-25*

## Self-Check: PASSED
- FOUND: lib/squid_router/swap_cta_state.dart
- FOUND: test/squid_router/swap_cta_state_test.dart
- FOUND: lib/squid_router/swap_screen.dart
- FOUND commit: 6595212
- FOUND commit: 88a2d8a
- FOUND commit: c7f3087
