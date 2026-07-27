---
phase: 09-banxa
plan: 04
subsystem: ui
tags: [flutter, banxa, gw_colors, gw_button, gw_error_state, order-status-ladder, order-status-banner]

requires:
  - phase: 09-banxa
    plan: 01
    provides: "order_status_style.dart's shared 4-bucket orderStatusTone()/orderStatusPaint() ladder and 3-severity bannerTone()/OrderStatusBanner, plus test/banxa/'s gwHost()/gwBothModes/testOrder() floor"
  - phase: 09-banxa
    plan: 02
    provides: "OrderCard's GWButton twin-button treatment (gradient/secondary) this plan's page mirrors one for one"
provides:
  - "order_details_card.dart re-skinned onto the shared 4-bucket status ladder and OrderStatusBanner — the only file in the phase that had a genuine paint DEFECT (a 2-way ternary with no error branch), now closed"
  - "order_details_page.dart's AppBar, banner-tone plumbing, twin GWButtons and FutureStateWidget error slot re-skinned — the sole instantiation site of OrderDetailCard, updated in the same commit pair as the card's signature change"
  - "test/banxa/order_details_card_test.dart — 13 widget tests pinning all four status buckets, all three banner tones, the no-banner case, and both wallet-masking states"
affects: []

tech-stack:
  added: []
  patterns:
    - "OrderStatusTone? bannerTone parameter on OrderDetailCard, computed in the host page from the same initialStatus string BanxaHelpers.getBannerInfo() already classifies, rather than re-deriving tone inside the card"
    - "Banner renders only when both bannerText and bannerTone are non-null — the two are always in sync because both come from the same three-string classification, but the card itself stays defensive rather than assuming the caller's invariant"

key-files:
  created:
    - test/banxa/order_details_card_test.dart
  modified:
    - lib/banxa/banxa_components/order_details_card.dart
    - lib/screens/order_details_page.dart

key-decisions:
  - "bannerColor (Color?) was removed from OrderDetailCard's constructor entirely rather than kept dead, per the plan's own instruction — its only remaining reference (order_details_page.dart's field and call site) had no other consumer after the tone-based banner replaced it."
  - "The banner guard is `bannerText != null && bannerTone != null` (not bannerText alone) — defensive against a future caller passing text without a tone, at zero behavioral cost today since order_details_page.dart's bannerTone()/getBannerInfo() calls are driven by the identical widget.initialStatus string and return null on the same branches."
  - "order_details_page.dart's AppBar keeps the exact `canGoBack ? null : IconButton(...)` two-case shape from before the re-skin (not collapsed into token_info_screen.dart's single shared-InkWell recipe used by banxa_orders_history.dart in 09-02) — 09-UI-SPEC and this plan's action block are explicit that this page's fallback is preserved and restyled, not replaced by a different mechanism."

requirements-completed: [SCR-05]

coverage:
  - id: D1
    description: "OrderDetailCard's status paint extended from a 2-way completed/else ternary to the full 4-bucket ladder (success/warning/error/neutral), closing the missing declined/expired/failed error branch"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/order_details_card_test.dart#completed/pendingpayment/declined/expired/failed/onhold status groups"
        status: pass
    human_judgment: false
  - id: D2
    description: "The opaque pastel banner Container replaced by OrderStatusBanner (tinted, non-opaque background, defined foreground text colour), driven by a new bannerTone parameter plumbed from order_details_page.dart's initialStatus"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/order_details_card_test.dart#warning/error/success tone banner groups + 'with no banner text, no banner renders at all'"
        status: pass
    human_judgment: false
  - id: D3
    description: "Detail rows retyped to labelMd/textSecondary + bodyLg/textPrimary so the card's rows match OrderCard's typography, with row labels/values byte-identical to the pre-re-skin card"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/order_details_card_test.dart#row labels and formatted values are byte-identical to the pre-re-skin card"
        status: pass
    human_judgment: false
  - id: D4
    description: "Wallet address masking (_maskWallet, 10-char threshold, _showFullWallet default false) survives byte-identical through the re-skin"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/order_details_card_test.dart#the wallet address renders masked by default, reveals on toggle, and re-masks on toggle again"
        status: pass
    human_judgment: false
  - id: D5
    description: "order_details_page.dart's back-arrow AppBar chrome, banner-tone plumbing (bannerTone() replacing bannerColor), twin GWButtons matching OrderCard's (gradient/secondary), and FutureStateWidget's error slot filled with GWErrorState"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "flutter analyze lib (baseline hold at 59) + flutter test test/banxa/ green — no dedicated widget test for the page's chrome; git diff confirms _effectiveCheckoutUrl, both getOrderById calls, the /createOrder push payload and the post-frame snackbar are byte-identical"
        status: pass
    human_judgment: false
  - id: D6
    description: "The banner's live appearance when reached via a real redirect round trip"
    verification: []
    human_judgment: true
    rationale: "D-03 forbids the sandbox network. Reaching this banner needs a real checkout redirect with an initialStatus, which cannot be automated or faked without contacting Banxa's sandbox. Recorded as OUTSTANDING, matching 09-02's precedent for visual-fidelity judgments this phase."

duration: 20min
completed: 2026-07-27
status: complete
---

# Phase 9 Plan 4: Order details card + page re-skin Summary

**`order_details_card.dart` gains the four-bucket status ladder it never had (closing a genuine paint defect where declined/expired/failed orders read identically to pending ones), plus the shipped `OrderStatusBanner` recipe; `order_details_page.dart` — its sole host — gets the matching back-arrow AppBar, `bannerTone` plumbing, twin `GWButton`s, and a filled `FutureStateWidget` error slot.**

## Performance

- **Duration:** 20 min
- **Started:** 2026-07-27T13:28:00-03:00
- **Completed:** 2026-07-27T13:31:29-03:00
- **Tasks:** 2
- **Files modified:** 3 (2 lib, 1 test — matches `files_modified`)

## Accomplishments
- `order_details_card.dart`: deleted the two-way `Colors.green : Colors.orange` status ternary and replaced it with 09-01's `orderStatusTone()`/`orderStatusPaint()` ladder — the card now paints all four buckets, closing the finding-4 gap where a declined/expired/failed order rendered the same amber as a merely-pending one.
- Replaced the opaque pastel banner `Container` with `OrderStatusBanner`, driven by a new `OrderStatusTone? bannerTone` constructor parameter; the `bannerColor` parameter it replaced is gone entirely (no remaining consumer).
- All six `ListTile` rows retyped to `GeniusWalletTypography.labelMd` (`gw.textSecondary` titles) and `bodyLg` (`gw.textPrimary` trailing values), matching `OrderCard`'s row typography; row labels and formatted values are pinned byte-identical to the pre-re-skin card by test.
- Wallet-address masking (`_maskWallet`, the 10-character threshold, `_showFullWallet` default `false`) survives untouched; the visibility toggle icon now reads `gw.textSecondary`.
- `order_details_page.dart`: applied the shared 48px `surfaceSunken` AppBar chrome with `titleMd` title text, while preserving the exact `canGoBack ? null : IconButton(...)` two-case fallback to `/buy` — restyled (icon now `gw.textSecondary`), not collapsed into a single mechanism.
- `_bannerColor` (a raw `Color?`) replaced by `_bannerTone` (`OrderStatusTone?`), computed via `bannerTone(widget.initialStatus)` beside the existing `BanxaHelpers.getBannerInfo()` call — same string, no new trust boundary (T-09-14).
- Both twin action buttons swapped to `GWButton`: Complete Payment → `GWButtonVariant.gradient` (the money-moving CTA), Retry Order → `GWButtonVariant.secondary` (no longer painted as if retrying were destructive) — matching `OrderCard`'s (09-02) buttons one for one.
- `FutureStateWidget`'s previously-unset `error:` parameter now renders `GWErrorState(title: "Couldn't load this order")`, so a fetch failure here reads consistently with the orders list's error state (09-02).
- New `test/banxa/order_details_card_test.dart` — 13 widget tests, all green, none touching the network (D-03).

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-skin OrderDetailCard — four-bucket status, tinted banner, sibling row typography** - `61143aa` (feat)
2. **Task 2: Re-skin the order-details page — AppBar, banner tone plumbing, twin GWButton swap, error slot** - `3a5a2ef` (feat)

**Plan metadata:** (pending — final docs commit, see below)

## Files Created/Modified
- `lib/banxa/banxa_components/order_details_card.dart` - 4-bucket status ladder, `OrderStatusBanner` replacing the opaque `Container`, `bannerTone` parameter replacing `bannerColor`, rows retyped to `labelMd`/`bodyLg`
- `lib/screens/order_details_page.dart` - back-arrow AppBar chrome, `_bannerTone` field replacing `_bannerColor`, twin `GWButton`s (gradient/secondary), `GWErrorState` in `FutureStateWidget`'s `error:` slot
- `test/banxa/order_details_card_test.dart` - all four status buckets, all three banner tones + no-banner case, wallet masking toggle, byte-identical row values, dark/light status-colour divergence

## Decisions Made
- `bannerColor` removed from `OrderDetailCard`'s constructor entirely (not kept dead) — its sole call site (`order_details_page.dart`) has no other use for it once `bannerTone` replaces it, and the plan explicitly asked to drop a parameter with no remaining consumer.
- The card's banner guard is `bannerText != null && bannerTone != null`, not `bannerText` alone — a small defensive choice with no behavioral difference today since both fields are always set together from the same three-string classification in `initState`.
- `order_details_page.dart`'s AppBar keeps its original `canGoBack ? null : IconButton(...)` structural shape rather than adopting `banxa_orders_history.dart`'s two-full-AppBar-builder pattern from 09-02 — this plan's action block and 09-UI-SPEC are explicit that the fallback is preserved and restyled, not replaced by a different mechanism.

## Deviations from Plan

None - plan executed exactly as written. Between Task 1 and Task 2, `flutter analyze lib` read 60 (one `undefined_named_parameter` error) because Task 1 removed `OrderDetailCard`'s `bannerColor` parameter while `order_details_page.dart`'s call site still referenced it — expected per the plan's own `<artifacts_this_phase_produces>` note that the signature change spans both files and must land together. Task 2 resolved it; the baseline held at 59 once the full plan completed.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All three genuinely-Banxa-owned surfaces re-skinned this phase (`order_card.dart`/`banxa_orders_history.dart` in 09-02, `order_details_card.dart`/`order_details_page.dart` here) now share one status ladder, one banner recipe, and one button-variant vocabulary — no divergent copies remain.
- `flutter analyze lib` = 59 (pinned baseline held), `flutter test` = 420 pass / 1 known pre-existing failure (`test/local_wallet_storage_test.dart`) — both re-verified after this plan's final commit.
- The banner's live appearance via a real checkout redirect round trip remains OUTSTANDING (D-03) — the tone mapping is proven by test, not by a live walk.
- `lib/banxa/banxa_helpers/banxa_helpers.dart`, `lib/banxa/banxa_order/*`, `banxa_api_services.dart`, `banxa_model.dart`, and the repository-root `banxa/` submodule are all untouched (D-06/AGENTS.md), confirmed via `git status --porcelain`.
- No blockers for any later Phase 9 plan; this was the phase's last two-file pair per 09-RESEARCH.

---
*Phase: 09-banxa*
*Completed: 2026-07-27*
