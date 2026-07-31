---
phase: 09-banxa
plan: 08
subsystem: ui
tags: [flutter, banxa, buy-flow, gw-components, go_router, bloc]

requires:
  - phase: 09-banxa (09-01 through 09-07)
    provides: the re-skinned Banxa surfaces, the OrderStatusTone ladder, the GW component set (GWCard/GWSelect/GWTextField/GWDetailGrid/GWKicker/GWEmptyState/GWErrorState), and test/banxa/ fixture helpers (fixtures.dart, gw_pump.dart)
provides:
  - "/buy" mapped to the buy FORM (BanxaBuyScreen), not the orders list
  - a two-column buy page (form + orders rail) on the app's shared page frame
  - per-status order counts (OrdersState.statusCounts / totalOrderCount), derived from the full order list
  - a one-CTA, two-rung buy flow (Get quote -> Buy GNUS) reading canGetQuote/canCreateOrder from state
  - "/buy/orders" as the orders history's own route
  - deletion of the dead, unused QuoteCard widget
affects: [09-banxa closeout, any future phase touching lib/screens/banxa_buy_screen.dart or lib/navigation/router.dart's /buy routes]

tech-stack:
  added: []
  patterns:
    - "One CTA, two rungs: a single GWButton whose label/guard/action are read from state.hasQuote (canGetQuote -> getQuote(); canCreateOrder -> createOrder()), never re-derived locally."
    - "Height-invariant state cards: content that changes across two UI states is rendered UNCONDITIONALLY in both (empty string / '-' placeholder vs a real value), each pinned to maxLines:1, so a container's height cannot drift when the state changes."
    - "Local, private StatelessWidgets (rail, count chip, row) for a single-consumer screen surface, per the Rule of Three - no promotion to lib/components/."

key-files:
  created:
    - test/banxa/order_status_counts_test.dart
    - test/banxa/buy_page_layout_test.dart
  modified:
    - lib/banxa/banxa_order/banxa_order_state.dart
    - lib/screens/banxa_buy_screen.dart
    - lib/navigation/router.dart
    - lib/screens/order_details_page.dart
    - test/banxa/banxa_buy_screen_test.dart
    - test/banxa/banxa_reskin_literals_test.dart
  deleted:
    - lib/banxa/banxa_components/quote_card.dart
    - test/banxa/quote_card_test.dart

key-decisions:
  - "The 'You will finish payment on Banxa.' helper line is rendered UNCONDITIONALLY (empty string when no quote) rather than only `if (state.hasQuote)`, because the latter would grow the form card's height the moment a quote lands - directly violating the plan's own height-invariance requirement."
  - "Quote-grid row values and the payment-finish line are pinned to maxLines:1/ellipsis, so a long real value can never wrap to a second line where the '-' placeholder never would - the latent way the height-invariance claim could silently break."
  - "/buy is pushed OUTSIDE the app's ShellRoute (unlike Transactions/Markets/News), so it needs its own way back; the plan's GWPageHeader spec carries no leading slot for this. Restored the pre-existing back chevron via GWPageHeader's own `leading` param (Rule 2 - missing critical navigation, not a redesign of the header's contracted content)."
  - "order_details_page.dart's root-fallback back arrow (no back stack, e.g. from a checkout redirect) now points at /buy/orders instead of /buy, since /buy no longer means 'orders' (Rule 1 - directly caused by Task 4's route repurposing)."
  - "banxa_reskin_literals_test.dart's forbidden-colour regex now excludes Colors.transparent, matching tool/check_raw_colors.sh's own documented, unconditional exemption for that literal (Rule 1/3 - the new Material(color: Colors.transparent) idiom in the rail/chip rows is standard, appearance-neutral usage, and the Phase-9 test's regex was stricter than the project's authoritative rule)."
  - "The height-invariance and both-states quote-grid claims are pinned via a design-contract reconstruction (public GWCard/GWDetailGrid fed by MakeOrderState.initial()/testQuoteState()), not the live BanxaBuyScreen: its MakeOrderCubit is created internally with no injection seam, and the Banxa sandbox is unreachable under flutter_test (D-03), so 'quote present' is unreachable through the real widget in an automated test - the same constraint 09-OUTSTANDING.md already names for the enabled Create Order rung."

requirements-completed: [GAP-05]

coverage:
  - id: D1
    description: "Per-status order counts (OrdersState.statusCounts/totalOrderCount), a pure derivation over the full order list that always sums to the total, with unrecognised statuses falling in the neutral bucket"
    requirement: "GAP-05"
    verification:
      - kind: unit
        ref: "test/banxa/order_status_counts_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "The buy screen adopts the shared page frame, GWSelect/GWTextField (no DropdownMenu/bare TextField), the breakpoint-driven form+rail layout, and the height-invariant quote grid with a single two-rung CTA"
    requirement: "GAP-05"
    verification:
      - kind: automated_ui
        ref: "test/banxa/buy_page_layout_test.dart"
        status: pass
      - kind: automated_ui
        ref: "test/banxa/banxa_buy_screen_test.dart"
        status: pass
    human_judgment: true
    rationale: "The ENABLED Buy GNUS CTA rung (a real quote/order) is unreachable without a live Banxa sandbox, which D-03 forbids under automated test - the same accepted gap 09-OUTSTANDING.md already records for this exact class of claim. A human walk is needed to confirm the enabled state and overall visual composition."
  - id: D3
    description: "The orders rail beside the form: four most recent orders, status/date/paid->received rows, tappable to order details, count chips that filter the rail, and a bounded empty state"
    requirement: "GAP-05"
    verification:
      - kind: automated_ui
        ref: "test/banxa/buy_page_layout_test.dart"
        status: pass
    human_judgment: true
    rationale: "The rail's loading/success states (a populated order list) are unreachable without a live sandbox (D-03); only the deterministic offline error state is exercised by automated test. A human walk with dev-fixture seeded orders is needed to see the populated rail, its filter chips, and row taps."
  - id: D4
    description: "/buy routes to the buy form; the orders history moves to /buy/orders; /createOrder stays mounted; the dead QuoteCard widget is deleted"
    requirement: "GAP-05"
    verification:
      - kind: unit
        ref: "flutter analyze (whole project) — pass, 0 issues"
        status: pass
    human_judgment: true
    rationale: "Route wiring is confirmed by static analysis and by exhaustively grepping every call site of '/buy' in the repo, but no automated router test exercises navigation end to end; a manual click-through (Buy GNUS button -> /buy -> View all -> /buy/orders -> back) is the honest way to confirm it."

duration: ~2h
completed: 2026-07-31
status: complete
---

# Phase 9 Plan 08: Buy GNUS becomes the buy page Summary

**`/buy` now opens the Banxa buy FORM on the app's shared page frame with a live orders rail beside it, replacing the old redirect straight to the order history, and closes out the last DropdownMenu/bare-TextField surface in the app.**

## Performance

- **Duration:** ~2h
- **Started:** 2026-07-30 (session)
- **Completed:** 2026-07-31T05:20:00Z (session, UTC)
- **Tasks:** 5/5 completed
- **Files modified:** 6 modified, 2 created, 2 deleted

## Accomplishments

- `OrdersState` gained `statusCounts`/`totalOrderCount`, a pure derivation over the full order list keyed through the existing `orderStatusTone` ladder - the four bucket counts always sum to the total, and unrecognised statuses land in `neutral` rather than being dropped.
- `banxa_buy_screen.dart` was rebuilt on the app's shared page frame (`Align` -> `Padding` -> `ConstrainedBox` -> `Column`, matching Transactions/Markets/News), replacing all three `DropdownMenu`s with `GWSelect` and both `TextField`s with `GWTextField` - the last surface in the app on bare Material inputs.
- The buy form and a new private orders rail sit side by side at >=1024px and stack (form first) below it; the rail shows the four most recent orders with status pill/date/paid->received, three count chips (All/Pending/Done) that filter it, and a bounded empty/error state.
- One `GWButton` now carries both `getQuote()`/`canGetQuote` and `createOrder()`/`canCreateOrder` as two rungs of a single CTA ("Get quote" -> "Buy GNUS"), reading state directly rather than re-deriving the guards.
- The quote grid (`You get`/`Rate`/`Banxa fee`) and the "You will finish payment on Banxa." line render unconditionally in both states (placeholder vs value), each pinned to one line, so the form card's height cannot change when a quote arrives.
- `router.dart`'s `/buy` now returns `BanxaBuyScreen`; the orders history moved to a new `/buy/orders` route; `/createOrder` stays mounted for existing deep links; the dead, zero-caller `QuoteCard` widget (and its now-orphaned test) were deleted.
- `test/banxa/order_status_counts_test.dart` and `test/banxa/buy_page_layout_test.dart` pin the new counts derivation and the buy screen's layout/copy contract; the pre-existing `banxa_buy_screen_test.dart` and `banxa_reskin_literals_test.dart` were updated to match.

## Task Commits

**No commits were made.** `AGENTS.md` states "Do not create commits" for this project, and the plan's own `<constraints>` repeats it as its first line. All changes described here are uncommitted in the working tree; the project owner reviews the tree and opens a PR himself.

## Files Created/Modified

- `lib/banxa/banxa_order/banxa_order_state.dart` - Added `statusCounts`/`totalOrderCount` getters (Task 1)
- `lib/screens/banxa_buy_screen.dart` - Rebuilt on the shared page frame, GWSelect/GWTextField, two-column layout, height-invariant quote grid, one-CTA-two-rungs, private orders rail/count-chip/row widgets (Tasks 2-3)
- `lib/navigation/router.dart` - `/buy` -> `BanxaBuyScreen`, new `/buy/orders` -> `OrdersPage` (Task 4)
- `lib/screens/order_details_page.dart` - Root-fallback back arrow now targets `/buy/orders` (deviation, see below)
- `test/banxa/banxa_buy_screen_test.dart` - Updated for the new CTA label/structure and the `OrdersCubit` dependency (deviation, see below)
- `test/banxa/banxa_reskin_literals_test.dart` - Dropped the deleted `quote_card.dart` from its file list; excluded `Colors.transparent` from its forbidden-colour regex (deviation, see below)
- `test/banxa/order_status_counts_test.dart` - New (Task 1)
- `test/banxa/buy_page_layout_test.dart` - New (Task 5)
- `lib/banxa/banxa_components/quote_card.dart` - Deleted, zero callers (Task 4)
- `test/banxa/quote_card_test.dart` - Deleted, its only subject was removed (deviation, see below)

## Decisions Made

See `key-decisions` in the frontmatter. In short: two real bugs were caught and fixed before they shipped (the "finish payment" line breaking height-invariance; unbounded row text risking the same via wrapping), one navigation gap was restored (the back chevron on a page the plan's header spec didn't give one to, but which needs it since `/buy` sits outside the app's shell), one stale route reference was corrected (`order_details_page.dart`), and one pre-existing test's colour gate was aligned with the project's own authoritative rule.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed the "You will finish payment on Banxa." line breaking the form card's own height-invariance requirement**
- **Found during:** Task 2/5 (writing the height-stability test)
- **Issue:** The line was rendered only `if (state.hasQuote)`, so the card grew ~24px taller the moment a quote arrived - directly contradicting the plan's own stated invariant ("the form card's height does not change when a quote arrives").
- **Fix:** Render the line unconditionally, with an empty string when no quote exists; an empty `Text` still reserves its line-height, so the row's space is constant.
- **Files modified:** `lib/screens/banxa_buy_screen.dart`
- **Verification:** `test/banxa/buy_page_layout_test.dart`'s height-invariance test (reconstruction, see D2's rationale for why it's a reconstruction, not the live widget).

**2. [Rule 2 - Missing Critical] Pinned quote-grid row values and the payment-finish line to one line**
- **Found during:** Task 2/5 (same investigation as #1)
- **Issue:** Row/line `Text` widgets had no `maxLines`, so a long real value (e.g. a verbose rate string) could wrap to a second line where the `-` placeholder never would - a latent way the height-invariance claim could silently break for a real (if unlikely) quote value.
- **Fix:** Added `maxLines: 1, overflow: TextOverflow.ellipsis` to the quote-grid row values and the payment-finish line.
- **Files modified:** `lib/screens/banxa_buy_screen.dart`
- **Verification:** `flutter analyze`, `dart format`, `test/banxa/buy_page_layout_test.dart`.

**3. [Rule 2 - Missing Critical] Restored a back affordance on `/buy`**
- **Found during:** Task 2 (building the header)
- **Issue:** `/buy` is pushed OUTSIDE the app's `ShellRoute` (unlike Transactions/Markets/News, which live inside it with persistent nav chrome) - confirmed by reading `router.dart`. The plan's `GWPageHeader` spec carries only `subtitle`/`trailing`, no `leading`, so a literal implementation would strand a user who pushed into `/buy` (e.g. via the "Buy GNUS" button on the wallet/coin pages) with no way back on a platform with no back gesture (macOS, this project's primary dev target).
- **Fix:** Reused the exact back-chevron recipe the file already carried in its old AppBar, placed in `GWPageHeader`'s own `leading` slot, shown only when `Navigator.canPop()`. The header's contracted title/subtitle/trailing content is unchanged.
- **Files modified:** `lib/screens/banxa_buy_screen.dart`
- **Verification:** `flutter analyze`; visually reachable via `Navigator.of(context).canPop()` - not separately unit-tested (a router-level concern).

**4. [Rule 1 - Bug] Corrected `order_details_page.dart`'s root-fallback route**
- **Found during:** Task 4 (repurposing `/buy`)
- **Issue:** `order_details_page.dart`'s back-arrow fallback (shown only when there is no back stack, e.g. reached from a checkout redirect) pushed `context.go('/buy')`, which used to land on the orders list. After Task 4, `/buy` is the buy form - this fallback would silently strand the user on the buy form instead of their orders.
- **Fix:** Changed the fallback to `context.go('/buy/orders')`.
- **Files modified:** `lib/screens/order_details_page.dart`
- **Verification:** `flutter analyze`; confirmed via an exhaustive grep of every `'/buy'` reference in the repo (only this one needed the fix; the two "Buy GNUS" buttons in `wallet_information.dart`/`coins_screen.dart` correctly keep targeting `/buy` as the buy form - that is the objective this plan exists to fix).

**5. [Rule 3 - Blocking] Deleted `test/banxa/quote_card_test.dart` alongside `quote_card.dart`**
- **Found during:** Task 4 (deleting the dead `QuoteCard` widget)
- **Issue:** The plan's own "confirm zero references before deleting" check found a reference outside `lib/` - `test/banxa/quote_card_test.dart` exclusively exercised the widget being deleted. Deleting only the source file would leave a test that fails to compile.
- **Fix:** Deleted the test file too; it had no other purpose.
- **Files modified:** `test/banxa/quote_card_test.dart` (deleted)
- **Verification:** `flutter test test/banxa/` passes with no compile errors.

**6. [Rule 3 - Blocking] Updated `test/banxa/banxa_buy_screen_test.dart` for the new CTA/structure**
- **Found during:** Task 2 (rebuilding the screen)
- **Issue:** The pre-existing test asserted the OLD CTA labels ("Create Order"/"Get Quote") and pumped `BanxaBuyScreen` without an `OrdersCubit` ancestor - both now stale: the labels changed (Task 2) and the screen now reads the ambient `OrdersCubit` for its rail (Task 3), which the test's bare `MaterialApp` host doesn't provide.
- **Fix:** Updated the assertions to the new labels ("Get quote"/disabled) and wrapped the pumped widget with a local `BlocProvider<OrdersCubit>`; disambiguated the retry-icon assertion (`find.byTooltip('Retry')` + descendant icon) since the rail's own offline `GWErrorState` also carries a refresh glyph with no tooltip.
- **Files modified:** `test/banxa/banxa_buy_screen_test.dart`
- **Verification:** `flutter test test/banxa/banxa_buy_screen_test.dart` - 4/4 pass.

**7. [Rule 3 - Blocking] Fixed `test/banxa/banxa_reskin_literals_test.dart` for the deleted file and a new standard idiom**
- **Found during:** Task 4 (deleting `quote_card.dart`)
- **Issue:** This pre-existing 09-07 gate test (a) listed `quote_card.dart` in its fixed 10-file scope, so `File(path).existsSync()` started failing once the file was deleted; and (b) its forbidden-colour regex (`\bColors\.`) flagged the new `Material(color: Colors.transparent)` idiom used in the rail/chip rows - the standard way to let an `InkWell`'s ripple show through a `Material` ancestor, and already used elsewhere in this app's own `GWCard`/`GWButton`. `tool/check_raw_colors.sh` (the project's authoritative colour gate) already exempts `Colors.transparent` unconditionally by design; this older, narrower test's regex did not.
- **Fix:** Removed `quote_card.dart` from the file list (10 -> 9 files); updated the regex to `\bColors\.(?!transparent\b)`, matching the authoritative script's own documented exemption.
- **Files modified:** `test/banxa/banxa_reskin_literals_test.dart`
- **Verification:** `flutter test test/banxa/banxa_reskin_literals_test.dart` - 28/28 pass.

---

**Total deviations:** 7 auto-fixed (2 Rule 1 bugs, 2 Rule 2 missing-critical, 3 Rule 3 blocking).
**Impact on plan:** All seven were necessary for correctness (two were real height-invariance/navigation bugs the plan's own must-haves would otherwise be violated by) or were required to keep the test suite compiling/green after Task 4's deletion and Task 2/3's new code. No scope creep beyond what each fix required.

## Known Stubs

None. Every value rendered is either always-present app furniture or a real field from `MakeOrderState`/`Order` - no hardcoded empty placeholder stands in for unwired data.

## Threat Flags

None. This plan re-arranges existing, already-reviewed surfaces (form fields, an orders list) behind an existing route; it introduces no new network endpoint, auth path, or schema change at a trust boundary.

## Issues Encountered

- **The plan's Task 5 instruction to "drive `MakeOrderCubit` with the existing fake service" assumes a test seam that does not exist.** `BanxaBuyScreen` constructs its own `MakeOrderCubit(BanxaApiService())` internally with no way to inject a substitute, and no fake `BanxaApiService`/`MakeOrderCubit` exists anywhere in the repo (confirmed by search). This is the same constraint `09-OUTSTANDING.md` already names and accepts for the enabled Create Order/Buy GNUS rung. Resolved by pinning the OFFLINE-reachable claims (routing, absent widgets/copy, breakpoint layout, the no-quote CTA label) against the real `BanxaBuyScreen`, and pinning the height-invariance/both-states claim against a design-contract reconstruction fed by 09-01's `testQuoteState()` fixture - documented plainly in the test file's own doc comment rather than silently overclaimed. See D2/D3's `rationale` above for the exact residual gap (a human walk is still needed to see the ENABLED CTA and a populated rail).
- **`banxa_reskin_literals_test.dart` and `banxa_buy_screen_test.dart` both required updates that were not in the plan's `files_modified` list.** Both were necessary consequences of Tasks 2-4 (see deviations #5-7) and are documented above rather than silently absorbed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- **Ready:** All 5 tasks complete, full verification suite green (see below). `/buy` correctly opens the buy form app-wide; `/buy/orders` is the orders history's own route; `/createOrder` remains mounted for existing deep links.
- **Not closed by this plan (unchanged from `09-OUTSTANDING.md`):** the KYC redirect blocker, the unscanned checkout QR, the order-details banner never seen from a real redirect, and - specific to this plan - the ENABLED Buy GNUS CTA rung and a populated orders rail, both of which need a live Banxa sandbox walk (D-03) to observe, not just code.
- **Recommended before calling this surface "done":** a manual walk at 1400px/800px in the running app (not just the automated width test) to see the two-column layout and the orders rail with real dev-fixture data (`--dart-define=GW_DEV_TOOLS=true`), and a click-through of Buy GNUS -> /buy -> View all -> /buy/orders -> back.

---
*Phase: 09-banxa*
*Completed: 2026-07-31*
