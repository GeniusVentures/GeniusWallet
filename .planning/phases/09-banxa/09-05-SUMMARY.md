---
phase: 09-banxa
plan: 05
subsystem: ui
tags: [flutter, banxa, gw_colors, gw_button, checkout, bottom-sheet]

requires:
  - phase: 09-banxa
    plan: 01
    provides: "test/banxa/'s gwHost()/gwBothModes pump helper this plan's two new test files both import"

provides:
  - "checkout_qr.dart re-skinned onto the shared back-arrow AppBar recipe, GWButton gradient Copy Link CTA and token typography, with the QR's white backing pinned mode-invariant by test"
  - "handle_banxa_drawer.dart (D-07) re-skinned — the ONE sheet every Banxa buy/order flow hands off to, no longer three unthemed Material buttons"
  - "test/banxa/checkout_qr_test.dart and test/banxa/checkout_options_sheet_test.dart — 8 new widget tests"
  - "the filed todo recording that handle_banxa_drawer.dart's visual contract was DERIVED, not specified"
affects: []

tech-stack:
  added: []
  patterns:
    - "Hand-rolled PollingCubit subclass (_FakePollingCubit) that emits a fixed PollingState on construction, never a live poll — the compliant substitute for a widget that reads a live Cubit from the tree (D-03)"
    - "A two-route GoRouter test host (real launch point + a stub /checkoutQR destination) so a sheet's real GoRouter.of(parentContext).push call has somewhere to land in a widget test, instead of mocking the router away"

key-files:
  created:
    - test/banxa/checkout_qr_test.dart
    - test/banxa/checkout_options_sheet_test.dart
    - .planning/todos/pending/2026-07-27-checkout-options-sheet-visual-contract-was-derived-not-specified.md
  modified:
    - lib/banxa/checkout_qr.dart
    - lib/banxa/handle_banxa_drawer.dart

key-decisions:
  - "handle_banxa_drawer.dart's visual contract is DERIVED, not specified: 09-CONTEXT.md D-07 brought this file into Phase 9 scope AFTER 09-UI-SPEC.md was finalised and had already fenced it out (Boundary Note). D-07 wins as the later decision, but no per-file Component Inventory row exists for it — this plan applied the app-wide token rules and the shell archetype's visual language by analogy, and filed a todo recording the extrapolation for a future reviewer."
  - "handle_banxa_drawer.dart's showModalBottomSheet is explicitly NOT migrated to ResponsiveDrawer.show, even though it is the strongest structural analog (swap_settings_drawer.dart / showTransactionDetails). ResponsiveDrawer switches to a centred showDialog at/above GeniusBreakpoints.medium, so migrating would silently change this sheet's desktop presentation — restructuring under PROJECT.md §65, not a re-skin, and Phase 21's call."
  - "An explicit backgroundColor: gw.surfaceElevated was added to the showModalBottomSheet call, after checking (not assuming) that Material's default modal-sheet surface is a computed tonal container derived from ColorScheme.surface, not literally the same token."

requirements-completed: [SCR-05]

coverage:
  - id: D1
    description: "checkout_qr.dart re-skinned: back-arrow AppBar (shared recipe, 'Scan to Continue' title), GWButton(gradient) Copy Link CTA replacing ElevatedButton.icon, instruction/URL/status text retyped to GeniusWalletTypography tokens on gw.textSecondary, spacing literals rounded to GeniusWalletConsts tokens"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/checkout_qr_test.dart#renders the instruction copy, the QR, the truncated URL and the Copy Link action"
        status: pass
    human_judgment: false
  - id: D2
    description: "The QR's white backing container preserved unconditionally (Colors.white, not appearance-aware) — the shipped mode-invariant QR convention, pinned by an automated cross-appearance assertion so a future consistency pass cannot theme it away"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/checkout_qr_test.dart#the QR's white backing is the SAME colour across a dark host and a light host"
        status: pass
    human_judgment: false
  - id: D3
    description: "The waiting copy renders when the polling state carries no message, and the polling state's own message renders in its place when non-empty — both via a hand-rolled fake PollingCubit, never a live poll (D-03)"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/checkout_qr_test.dart#the waiting copy renders when the polling state has no message + #the polling state's own message renders in place of the waiting copy when non-empty"
        status: pass
    human_judgment: false
  - id: D4
    description: "checkout_qr.dart's structure, post-frame navigation/snackbar side effects, cubit.hasNavigated and the /orderDetails push payload are byte-identical to before the re-skin (D-01)"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "git diff lib/banxa/checkout_qr.dart — only indentation changed on the preserved lines; flutter analyze lib holds at the pinned baseline (59)"
        status: pass
    human_judgment: false
  - id: D5
    description: "handle_banxa_drawer.dart (D-07) re-skinned: title retyped to titleLg/textPrimary, all three ElevatedButtons swapped to GWButton (secondary/secondary/tertiary), spacing tokens applied, sheet background made appearance-aware — no raw Material button remains"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/checkout_options_sheet_test.dart#renders the title and all three action labels, with no raw Material button in the tree"
        status: pass
    human_judgment: false
  - id: D6
    description: "The Copy checkout link action still puts the checkout URL on the clipboard, and every one of the sheet's three actions still closes the sheet (pop) as part of its handler — the pre-existing pop-then-act / act-then-pop ordering per handler and the parentContext.mounted guard are all preserved byte-identical (D-01)"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "test/banxa/checkout_options_sheet_test.dart#tapping the copy action puts the checkout URL on the clipboard, then closes the sheet + #tapping Show QR closes the sheet before it navigates to the QR route + #tapping Open in Browser closes the sheet and its unavailable-launcher catch does not crash"
        status: pass
    human_judgment: false
  - id: D7
    description: "showCheckoutOptionsSheet's function signature and its four named parameters (context, checkoutUrl, orderId, redirectUrl) are unchanged — 4 call sites across 3 other in-scope files depend on it"
    requirement: SCR-05
    verification:
      - kind: unit
        ref: "git diff lib/banxa/handle_banxa_drawer.dart — only indentation changed on the signature/parameter lines"
        status: pass
    human_judgment: false
  - id: D8
    description: "Finding 6 (checkout QR scans in both light and dark appearances) — this plan satisfies the visual half by construction (the white backing is preserved and now test-pinned), but whether the code actually SCANS needs a phone camera against a rendered QR and a light-mode pass, neither authorised this phase (D-03, light mode deferred project-wide)"
    verification: []
    human_judgment: true
    rationale: "No light-mode walk is authorised this phase and no camera/device verification can be automated. Finding 6 stays OUTSTANDING — this SUMMARY does not and must not record it as resolved (09-CONTEXT.md <scope_reduction>)."

duration: 25min
completed: 2026-07-27
status: complete
---

# Phase 9 Plan 5: Checkout QR + checkout options sheet re-skin Summary

**`checkout_qr.dart` gets the shared back-arrow AppBar, a `GWButton(gradient)` Copy Link CTA and token typography with its white QR backing pinned mode-invariant by test; `handle_banxa_drawer.dart` (D-07) — the one sheet every Banxa buy/order flow hands off to — sheds its three unthemed `ElevatedButton`s for the `GWButton` ladder, and its visual contract's DERIVED-not-specified nature is now on the record via a filed todo.**

## Performance

- **Duration:** 25 min
- **Started:** 2026-07-27T16:05:00Z
- **Completed:** 2026-07-27T16:30:00Z
- **Tasks:** 2
- **Files modified:** 5 (2 lib, 2 test, 1 todo — matches `files_modified`)

## Accomplishments
- `checkout_qr.dart`: swapped the plain `AppBar` for the shared sketch-152 back-arrow recipe (title "Scan to Continue"), replaced the `ElevatedButton.icon` Copy Link with `GWButton(variant: gradient, leading: Icon(Icons.content_copy), expand: true)` — the screen's one money-moving action — and retyped the instruction/URL/status text to `GeniusWalletTypography` tokens on `gw.textSecondary`.
- The QR's white backing `Container` is untouched and unconditional — the shipped mode-invariant convention, now pinned by a cross-appearance test assertion so a future "no hardcoded colours" pass cannot theme it away (T-09-17).
- Structure, post-frame navigation/snackbar side effects, `cubit.hasNavigated` and the `/orderDetails` push payload are byte-identical (`git diff` confirms only indentation moved on those lines).
- `handle_banxa_drawer.dart`: the ad-hoc 16px/w600 title became `GeniusWalletTypography.titleLg`/`gw.textPrimary`; all three raw `ElevatedButton`s became `GWButton`s — "Open in Browser"/"Show QR" take `secondary` (neither is the singular money-moving action), "Copy checkout link" takes `tertiary` with its existing copy icon as `leading`.
- Added an explicit `backgroundColor: gw.surfaceElevated` to the `showModalBottomSheet` call after confirming Material's default (a computed tonal container derived from `ColorScheme.surface`) does not literally resolve to that token.
- `showModalBottomSheet`, `showDragHandle: true`, the builder shape and the `parentContext` plumbing are all kept byte-identical — **deliberately NOT migrated to `ResponsiveDrawer.show`**, which switches to a centred `showDialog` at/above `GeniusBreakpoints.medium` and would silently change this sheet's desktop presentation (restructuring under `PROJECT.md` §65 — Phase 21's call, not this re-skin phase's).
- `showCheckoutOptionsSheet`'s signature and its four named parameters are unchanged (verified via `git diff` — only indentation moved) — the 4 call sites across `banxa_buy_screen.dart` (×2), `banxa_orders_history.dart` and `order_details_page.dart` are unaffected.
- Pop-then-act ordering (Open in Browser / Show QR: pop first, then act) and act-then-pop ordering (Copy: clipboard write first, then pop, per the ORIGINAL code — preserved, not "corrected") plus the `parentContext.mounted` guard and the browser handler's catch→snackbar fallback are all byte-identical (D-01).
- Filed `.planning/todos/pending/2026-07-27-checkout-options-sheet-visual-contract-was-derived-not-specified.md`, recording that D-07 brought this file into scope after 09-UI-SPEC was finalised, that its treatment here was derived by analogy rather than built against an approved per-file contract, and that Phase 21 should claim it if it wants the sheet on the real `ResponsiveDrawer` archetype.
- New `test/banxa/checkout_qr_test.dart` (4 tests) and `test/banxa/checkout_options_sheet_test.dart` (4 tests) — all green, none touching the network or a live poll (D-03).

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-skin the checkout QR screen** - `dc7421d` (feat)
2. **Task 2: Re-skin the checkout options sheet (D-07)** - `3536bbe` (feat)

**Plan metadata:** (pending — final docs commit, see below)

## Files Created/Modified
- `lib/banxa/checkout_qr.dart` - back-arrow AppBar, `GWButton(gradient)` Copy Link, retyped text, preserved white QR backing
- `lib/banxa/handle_banxa_drawer.dart` - retyped title, `GWButton` ladder (secondary/secondary/tertiary), appearance-aware sheet background, presentation mechanism unchanged
- `test/banxa/checkout_qr_test.dart` - instruction/QR/URL/CTA render, waiting-copy vs. polling-message swap, cross-appearance QR-backing assertion, via a hand-rolled fake `PollingCubit`
- `test/banxa/checkout_options_sheet_test.dart` - title/labels render with no raw Material button, the copy action's clipboard write (mocked platform channel), Show QR and Open in Browser both closing the sheet, via a two-route `GoRouter` test host
- `.planning/todos/pending/2026-07-27-checkout-options-sheet-visual-contract-was-derived-not-specified.md` - records the derived-not-specified nature of this file's treatment and the deliberate non-migration to `ResponsiveDrawer`, for Phase 21 to claim later

## Decisions Made
- See `key-decisions` in frontmatter: the derived-contract nature of `handle_banxa_drawer.dart`'s re-skin, the deliberate non-migration to `ResponsiveDrawer.show`, and the explicit `gw.surfaceElevated` sheet background (checked, not assumed).
- Spacing literals in both files rounded to `GeniusWalletConsts` tokens of the same value (`checkout_qr.dart`'s `EdgeInsets.all(24)`→`space12`, `EdgeInsets.all(8)`→`space4`, `SizedBox(height: 16)`→`space8`, `SizedBox(height: 12)`→`space6`; `handle_banxa_drawer.dart`'s `EdgeInsets.all(16)`→`space8`, `SizedBox(height: 12)`→`space6`, `SizedBox(height: 8)`→`space4`) — no on-screen change, per 09-UI-SPEC's Spacing Scale ("Exceptions: none").

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Task 1's own acceptance-criteria grep collides with the mandated live-GWColors-read idiom**
- **Found during:** Task 1 verification
- **Issue:** The acceptance criterion `grep -vE '^\s*//' lib/banxa/checkout_qr.dart | grep -c 'Colors\.'` expects exactly 1 match (the preserved QR backing), but the SAME task's action text mandates `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` — and the substring `Colors.` appears inside `GWColors.dark()` regardless of intent, since the grep pattern is a plain substring match, not word-bounded. This produces 2 matches, not 1, with no way to satisfy both the mandated idiom and the literal grep count.
- **Fix:** None applied — this is a plan-authoring collision, not a code defect. The mandated live-read idiom was kept as written (removing it would violate the phase's hard "live appearance reads" rule); the acceptance criterion's literal count is documented here as unsatisfiable-as-written rather than silently claimed as met. The substantive intent of the criterion — "no NEW hardcoded colour literal beyond the preserved QR backing" — holds: the only actual `Color` literal in the file is `Colors.white` on the QR backing container.
- **Files modified:** none (documentation only)
- **Verification:** `grep -vE '^\s*//' lib/banxa/checkout_qr.dart | grep -n 'Colors\.'` shows line 37 (`GWColors.dark()`, the mandated fail-soft idiom, not a colour literal) and line 126 (`Colors.white`, the one preserved literal).
- **Committed in:** `dc7421d` (Task 1 commit) — no separate fix commit, since no code changed.

**2. [Rule 1 - Bug] Reworded Task 2's own doc comment to avoid tripping its own acceptance-criteria greps**
- **Found during:** Task 2, first draft
- **Issue:** The file's own header comment, drafted to explain why `handle_banxa_drawer.dart` is NOT migrated to the shared drawer helper, originally used the literal strings `showModalBottomSheet` and `ResponsiveDrawer` in prose — both substrings the plan's own acceptance criteria grep for with an expected count of exactly 1 (the real API call) and exactly 0, respectively. The prose usage pushed both counts over their expected values (`showModalBottomSheet` → 2, `ResponsiveDrawer` → 2), mirroring 09-01-SUMMARY.md's precedent for this same class of self-tripping doc comment.
- **Fix:** Reworded the comment to describe the same reasoning ("the shared drawer helper's dialog-capable shell", "that helper switches to a centred dialog…") without repeating the literal API-name substrings.
- **Files modified:** `lib/banxa/handle_banxa_drawer.dart`
- **Verification:** `grep -c 'showModalBottomSheet' lib/banxa/handle_banxa_drawer.dart` → 1; `grep -c 'ResponsiveDrawer' lib/banxa/handle_banxa_drawer.dart` → 0.
- **Committed in:** `3536bbe` (Task 2 commit)

---

**Total deviations:** 2 (1 Rule 1 — documented-unsatisfiable acceptance criterion, no code change; 1 Rule 1 — doc-comment reword to satisfy the plan's own literal greps). No scope creep; no architectural changes; no behavior changes.
**Impact on plan:** Neither deviation touched runtime behavior or the re-skin's substance. Both are documentation-level reconciliations between the plan's literal acceptance-criteria wording and either a phase-wide hard rule (live `GWColors` reads) or the plan's own self-referential grep targets.

## Issues Encountered
None beyond the two deviations above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `flutter analyze lib` = 59 (pinned baseline held), `flutter test` = 428 pass / 1 known pre-existing failure (`test/local_wallet_storage_test.dart`) — re-verified after this plan's final commit (420 baseline + 8 new tests from this plan).
- Finding 6 (QR scans in both appearances) stays OUTSTANDING — this plan satisfies its visual half by construction (white backing preserved, now test-pinned) but performs no light-mode walk and no camera verification (D-03/09-CONTEXT.md `<scope_reduction>`). **Never record it as resolved.**
- `handle_banxa_drawer.dart`'s visual contract was DERIVED, not specified — the filed todo carries this forward for Phase 21, which should claim the file explicitly if it wants the sheet migrated onto the real `ResponsiveDrawer` archetype.
- `lib/banxa/banxa_order/*`, `banxa_api_services.dart`, `banxa_model.dart`, `banxa_helpers/*`, the four D-05 drawers (`buy_success_drawer.dart`, `buy_cancelled_drawer.dart`, their two `_content` files) and the repository-root `banxa/` submodule are all untouched, confirmed via `git status --porcelain`.
- This was the last plan in Phase 9's Wave 2 per 09-05-PLAN.md's `depends_on: ["09-01"]` — no blockers recorded for any later Phase 9 plan.

---
*Phase: 09-banxa*
*Completed: 2026-07-27*
