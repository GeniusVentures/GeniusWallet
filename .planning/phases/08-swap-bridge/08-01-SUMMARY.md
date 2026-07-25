---
phase: 08-swap-bridge
plan: 01
subsystem: ui
tags: [flutter, gw-colors, design-system, squid-router, swap]

requires:
  - phase: 07
    provides: GWColors token vocabulary, GWCard, GeniusWalletTypography ladder used to re-skin these widgets
provides:
  - "GWPageHeader.subtitle (additive, nullable) — D-07's Swap subtitle hook, unused by any caller yet"
  - "Re-skinned SwapField (38px hero amount, MAX affordance, optional USD line, optional emptyPlaceholder hook)"
  - "Re-skinned TokenFlipButton (44px brandCta seam control)"
  - "Re-skinned RouteDetailsCard with a golden regression test locking its four derived strings"
  - "Re-skinned TokenSelectorDrawer list rows"
affects: [08-03-swap-tab, 08-04-bridge]

tech-stack:
  added: []
  patterns:
    - "GWPageHeader subtitle: additive-only optional param, default null, rendered only when non-null"
    - "SwapField emptyPlaceholder: field-owned amount-presentation override for a future route-error state"
    - "Golden test written BEFORE a paint-only re-skin, run before and after, to prove figures didn't move"

key-files:
  created:
    - test/squid_router/route_details_card_test.dart
  modified:
    - lib/components/scaffold/gw_page_header.dart
    - lib/squid_router/token_flip_button.dart
    - lib/squid_router/swap_field.dart
    - lib/squid_router/route_details_card.dart
    - lib/squid_router/token_selector_drawer.dart

key-decisions:
  - "USD line placed as the last child of the card's Column (after the amount+pill Row), satisfying 'under the amount row' without disturbing the balance/MAX row's layout"
  - "Token pill corner radius uses GeniusWalletConsts.radiusPill (48) for both the InkWell splash and the Container decoration, reproducing develop's pill shape (was hardcoded circular(40)/circular(20)) — not specified exactly by UI-SPEC, decided under D-21"
  - "Removed a stray duplicate '@override' annotation above TokenSelectorDrawer.build while re-skinning that method (Rule 1 — pre-existing harmless bug, in-scope file)"

patterns-established:
  - "Golden-lock-before-paint: write and run the regression test against the UNMODIFIED widget first, then re-skin, then re-run — proves paint-only claims rather than asserting them"

requirements-completed: [SCR-04]

coverage:
  - id: D1
    description: "GWPageHeader gains an optional, additive subtitle (default null); no existing caller changed"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "flutter analyze lib/components/scaffold/gw_page_header.dart (0 issues) + grep gate (this.subtitle / String? subtitle present)"
        status: pass
    human_judgment: false
  - id: D2
    description: "TokenFlipButton re-skinned to a 44px brandCta-gradient seam control; AnimatedRotation/onFlip preserved verbatim"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "flutter analyze lib/squid_router/token_flip_button.dart (0 issues) + grep gate (brandCta, AnimatedRotation present)"
        status: pass
    human_judgment: false
  - id: D3
    description: "SwapField re-skinned: GWCard surface, 38px hero amount, GW-vocabulary token pill, MAX affordance driving the existing onChanged pipeline, optional USD line omitted (not zeroed) when no price known, optional emptyPlaceholder hook"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "flutter analyze lib/squid_router/swap_field.dart (0 issues) + grep gates (fontSize: 38, MAX, fiatValue, formattedBalance, TokenSelectorDrawer.show, String? emptyPlaceholder) + legacy-literal grep (0 matches)"
        status: pass
    human_judgment: true
    rationale: "Visual/contrast fidelity of the re-skin (MAX affordance placement, USD line legibility, token pill proportions) is explicitly deferred to the 08-07 walk per the plan's own acceptance criteria; static analysis + grep gates prove the code exists and compiles correctly but not that it looks right. Note also: 08-CONTEXT.md D-22 descopes the 08-07 human walk entirely at Braian's instruction, so this judgment call is recorded as never exercised, not as passed."
  - id: D4
    description: "RouteDetailsCard's four derived strings (Pricing/Slippage/Price Impact/Fees) are byte-identical before and after a paint-only re-skin, proven against the real mockSquidRoute constant"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "test/squid_router/route_details_card_test.dart#RouteDetailsCard prints the real mockSquidRoute figures"
        status: pass
    human_judgment: false
  - id: D5
    description: "TokenSelectorDrawer list rows moved into GWColors vocabulary; still routes through ResponsiveDrawer.show"
    requirement: SCR-04
    verification:
      - kind: unit
        ref: "flutter analyze lib/squid_router/token_selector_drawer.dart (0 issues) + grep gate (ResponsiveDrawer.show present)"
        status: pass
    human_judgment: false

duration: 20min
completed: 2026-07-25
status: complete
---

# Phase 8 Plan 1: Swap component family re-skin Summary

**Re-skinned GWPageHeader (additive subtitle), TokenFlipButton, SwapField, RouteDetailsCard, and TokenSelectorDrawer into GWColors vocabulary, plus a new golden regression test locking RouteDetailsCard's four derived strings against the real `mockSquidRoute` constant (`1 ETH ~ 0.995 USDT` / `0.5` / `0.51%` / `$0.30`) — criterion 1's automated half.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-07-25T17:31:00Z (first task commit)
- **Completed:** 2026-07-25T17:36:00Z (last task commit)
- **Tasks:** 3/3
- **Files modified:** 5 (+ 1 test file created)

## Accomplishments
- `GWPageHeader` carries an optional, additive `subtitle` (default null) — every existing caller (Transactions, Markets, News, current Swap) renders byte-identically; nothing in this plan uses it yet (08-03 will).
- `TokenFlipButton` re-skinned from a Material `FloatingActionButton` (green-accent fill, deep-blue glyph) to a 44px `InkWell`+`Container` brand-gradient seam control with a `surfaceElevated` punch-through border; `AnimatedRotation`/`onFlip` mechanics untouched.
- `SwapField` re-skinned in place: `GWCard` surface on `surfaceElevated`/`borderSubtle`/`radiusLg`, the D-07-locked 38px hero amount (`numericDisplay.copyWith(fontSize: 38, height: 1.0)`), a `surfaceMenu`+`borderSubtle` token pill, a new MAX affordance (pay side only, known balance, drives the existing `onChanged` pipeline — no second quote path), a new optional USD line via `fiatValue()`/`livePricesBySymbol()` that is OMITTED (never zeroed) when no price is known, and a new optional `emptyPlaceholder` hook (unused this plan) for 08-03's route-error state.
- `RouteDetailsCard`'s four derivations (pricing, slippage passthrough, price impact, fees) are proven byte-identical before and after a paint-only re-skin (`Card` → `surfaceElevated` container, `labelMd` rows, Price Impact value in `statusSuccess`) via a new golden test that imports the real `mockSquidRoute` constant.
- `TokenSelectorDrawer` list rows and search field moved into GWColors vocabulary (`surfaceMenu`, `textPrimary`, `textSecondary`); still routes through `ResponsiveDrawer.show`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add GWPageHeader's optional subtitle and re-skin the flip control for the seam** - `f5518e9` (feat)
2. **Task 2: Re-skin SwapField — 38px hero amount, MAX affordance, optional USD line** - `3170623` (feat)
3. **Task 3: Golden-lock RouteDetailsCard's figures (criterion 1), then paint it; re-skin the token picker** - `08fd30f` (test)

## Files Created/Modified
- `lib/components/scaffold/gw_page_header.dart` - additive optional `subtitle` param
- `lib/squid_router/token_flip_button.dart` - 44px brandCta seam control
- `lib/squid_router/swap_field.dart` - re-skinned field with MAX + USD line + emptyPlaceholder hook
- `lib/squid_router/route_details_card.dart` - paint-only re-skin, derivations untouched
- `lib/squid_router/token_selector_drawer.dart` - GW-vocabulary list rows
- `test/squid_router/route_details_card_test.dart` - new golden test, criterion 1's automated half

## Decisions Made
- USD line placed as the trailing child of the field's Column (after the amount+pill Row, before nothing else follows), which satisfies "under the amount row" while keeping the balance/MAX row's own layout untouched.
- Token pill corner radius: used `GeniusWalletConsts.radiusPill` (48) for both the tap target and the fill decoration, reproducing develop's visually-pill shape (develop hardcoded `circular(40)`/`circular(20)`); UI-SPEC did not lock an exact radius token here, decided under D-21 standing authorization.
- Removed a stray duplicate `@override` annotation immediately above `TokenSelectorDrawer.build` while re-skinning that method — a pre-existing harmless bug in a file already in scope for this task (Rule 1).
- All four predicted golden strings matched develop's actual output exactly on the FIRST run against the unmodified card — no expectation had to be corrected to match reality (Pricing `1 ETH ~ 0.995 USDT`, Slippage `0.5`, Price Impact `0.51%`, Fees `$0.30`).

## Deviations from Plan

None - plan executed exactly as written. The one in-scope cleanup (duplicate `@override`) falls under Rule 1 (auto-fix bugs) and required no separate judgment call beyond what D-21 pre-authorizes.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
The swap component family (header subtitle hook, flip control, amount field with MAX/USD/emptyPlaceholder, route details card, token picker) now wears the redesign and is ready for 08-03 (swap tab assembly) and 08-04 (bridge, the swap-twin) to consume. `flutter analyze lib` holds at 59 issues (at or below the 61 baseline); full `flutter test` is 249 pass / 1 known pre-existing failure (248 baseline + this plan's 1 new test, `local_wallet_storage_test.dart` still the sole pre-existing failure). No blockers.

---
*Phase: 08-swap-bridge*
*Completed: 2026-07-25*

## Self-Check: PASSED
- FOUND: lib/components/scaffold/gw_page_header.dart
- FOUND: lib/squid_router/token_flip_button.dart
- FOUND: lib/squid_router/swap_field.dart
- FOUND: lib/squid_router/route_details_card.dart
- FOUND: lib/squid_router/token_selector_drawer.dart
- FOUND: test/squid_router/route_details_card_test.dart
- FOUND commit: f5518e9
- FOUND commit: 3170623
- FOUND commit: 08fd30f
