---
phase: 09-banxa
plan: 03
subsystem: ui
tags: [flutter, banxa, gw_button, gw_card, create-order-cta]

requires:
  - phase: 09-banxa
    plan: 01
    provides: "test/banxa/'s gwHost()/gwBothModes/testQuoteState() floor"
provides:
  - "banxa_buy_screen.dart re-skinned onto GWButton (Create Order gradient CTA, Get Quote secondary) and GWCard (inline quote block) — zero raw color literals except the deliberately-preserved boot scrim"
  - "quote_card.dart re-skinned onto GWCard/token typography — still zero callers in lib/, exactly as D-08 specifies"
  - "test/banxa/banxa_buy_screen_test.dart and test/banxa/quote_card_test.dart"
affects: []

tech-stack:
  added: []
  patterns:
    - "Back-arrow AppBar applied unconditionally (no canGoBack branch) on a screen that is always pushed — token_info_screen.dart's recipe reused verbatim, simplified from 09-02's conditional version since this screen has only one entry path"
    - "GWButton(onPressed: state.<gate> ? <verbatim async body> : null) as the disabled-rung idiom — moving an existing async closure across unchanged rather than re-deriving it"

key-files:
  created:
    - test/banxa/banxa_buy_screen_test.dart
    - test/banxa/quote_card_test.dart
    - .planning/todos/pending/2026-07-27-quote-card-duplicated-by-the-buy-screens-inline-block.md
  modified:
    - lib/screens/banxa_buy_screen.dart
    - lib/banxa/banxa_components/quote_card.dart

key-decisions:
  - "The plan's <behavior> line for quote_card_test.dart asked to assert that 'its primary text colour differs between a dark host and a light host.' Empirically, GWColors.dark() and GWColors.light() both derive textPrimary from the same GeniusWalletColors.textPrimary getter, which reads a single app-wide GWAppearance.isLight flag rather than varying per constructed instance — so dark() and light() instances are byte-identical for textPrimary specifically (same root cause class as 09-01's statusWarning finding: a mode-invariant token, not a defect in this widget's live GWColors read). Re-pointed the dark/light divergence assertion at the fee line's gw.textSecondary instead, which genuinely differs between the two factories (light's value is an explicit AA-fix override, not a re-derivation of the same global getter). No production code was changed because of this."

requirements-completed: [SCR-05, GAP-05]

coverage:
  - id: D1
    description: "banxa_buy_screen.dart's Create Order CTA replaced with GWButton(variant: gradient, size: lg, expand: true); disabled rung driven by the same state.canCreateOrder null-onPressed idiom; Get Quote replaced with GWButton(variant: secondary); back-arrow AppBar; inline quote block wrapped in GWCard with typography tokens; snackbar and disclaimer literals swapped for theme tokens"
    requirement: GAP-05
    verification:
      - kind: unit
        ref: "test/banxa/banxa_buy_screen_test.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "quote_card.dart re-skinned onto GWCard/token typography with a live GWColors read, per D-08 left with zero callers in lib/"
    requirement: GAP-05
    verification:
      - kind: unit
        ref: "test/banxa/quote_card_test.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Whether the re-skinned buy form reads as a sibling of the Swap tab (visual fidelity)"
    verification: []
    human_judgment: true
    rationale: "D-03 forbids any walk this phase. The ENABLED Create Order rung additionally cannot be reached in an automated test without a live sandbox quote, which D-03 also forbids. Both recorded as OUTSTANDING, never as met."

duration: 15min
completed: 2026-07-27
status: complete
---

# Phase 9 Plan 3: Buy screen + quote_card re-skin Summary

**`banxa_buy_screen.dart`'s hand-rolled InkWell/Ink/BoxDecoration Create Order CTA is now a real `GWButton` gradient (disabled rung unchanged, driven by `state.canCreateOrder`), and `quote_card.dart` wears the same re-skin while remaining knowingly dead code per D-08.**

## Pinned baseline comparison

Per 09-01-SUMMARY.md's pinned numbers, re-verified after this plan's two commits:

- `flutter analyze lib` = **59 issues** (unchanged from the pinned baseline)
- `flutter test` = **405 pass / 1 known pre-existing failure**
  (`test/local_wallet_storage_test.dart` — "Missing definition of `main`" — not this plan's)

No regression against the floor.

## Performance

- **Duration:** ~15 min
- **Started:** 2026-07-27T13:17:00-03:00 (Task 1 commit)
- **Completed:** 2026-07-27T13:20:22-03:00 (Task 2 commit)
- **Tasks:** 2
- **Files modified:** 5 (2 `lib/`, 2 `test/`, 1 pending todo — matches `files_modified`)

## Accomplishments

- `banxa_buy_screen.dart`: the entire `InkWell`/`Ink`/`BoxDecoration`/`Container` Create Order CTA
  tree is gone, replaced by a single `GWButton(variant: gradient, size: lg, expand: true)` whose
  `onPressed` is the exact async body (disclaimer, not-accepted snackbar short-circuit,
  checkout-sheet-or-createOrder branch) moved across unchanged. The four literals that tree carried
  — the grey-shade disabled gradient, the enabled deep-blue label, the black-alpha disabled label,
  and the brand gradient itself — are gone with it, all now owned by `GWButton`.
- The Get Quote `ElevatedButton` is now `GWButton(variant: secondary, expand: true)`, reading as the
  secondary step it is, beside the unchanged retry `IconButton`.
- The screen's plain `AppBar` is now the back-arrow recipe from `token_info_screen.dart`, applied
  unconditionally — this screen is always pushed at `/createOrder`, so no `canGoBack` branch was
  needed (a simplification versus 09-02's conditional version, since there is only one entry path
  here).
- The inline quote `Card` is now `GWCard`, its receive line `bodyLg`/`textPrimary`, its two fee lines
  `bodySm`/`textSecondary`. The three interpolated strings are byte-identical.
- The error snackbar's background is `GeniusWalletColors.statusError`; the disclaimer's active
  checkbox colour is `GeniusWalletColors.brandPrimaryOnSurface`. The disclaimer's third-party copy
  is untouched.
- `quote_card.dart` — still confirmed dead (`QuoteCard(` matches only its own constructor in all of
  `lib/`) — now renders through `GWCard`/token typography with a live `GWColors` read. **This
  produces zero user-visible change, by design (D-08).** A comment at the top of the file records,
  in prose, that it has no callers, that the buy screen renders an equivalent block inline, and that
  this re-skin was deliberate.
- Filed `.planning/todos/pending/2026-07-27-quote-card-duplicated-by-the-buy-screens-inline-block.md`
  naming both copies and framing the resolution (consolidate onto `QuoteCard`, or delete it) as a
  product decision, not a re-skin decision.
- Two new test files, 9 new widget tests, all green, none touching the network (D-03): the offline
  disabled Create Order rung, the Get Quote disabled state, the retry affordance, a structural
  (`Material`-wrapped `InkWell`) fingerprint proving the hand-rolled CTA is gone, and `quote_card.dart`'s
  full/compact/no-quote/dark-vs-light-fee-colour behavior.

## Task Commits

Each task was committed atomically:

1. **Task 1: Re-skin the buy screen — back-arrow AppBar, the GWButton CTA ladder, the quote card wrap** - `e16b9de` (feat)
2. **Task 2: Re-skin quote_card.dart under D-08 — knowingly invisible, and file the todo that owns the duplication** - `bea34fe` (feat)

**Plan metadata:** (pending — final docs commit, see below)

## Files Created/Modified

- `lib/screens/banxa_buy_screen.dart` - `GWButton` CTA ladder (gradient/secondary), back-arrow
  `AppBar`, `GWCard`-wrapped inline quote block, `GeniusWalletColors.statusError`/
  `brandPrimaryOnSurface` for the two remaining literals
- `lib/banxa/banxa_components/quote_card.dart` - `GWCard`/token typography re-skin, live `GWColors`
  read added, still zero callers
- `test/banxa/banxa_buy_screen_test.dart` - offline-state Create Order/Get Quote disabled assertions,
  retry affordance, no-hand-rolled-gradient structural check
- `test/banxa/quote_card_test.dart` - full/compact receive wording, no-quote short-circuit,
  dark/light fee-line colour divergence
- `.planning/todos/pending/2026-07-27-quote-card-duplicated-by-the-buy-screens-inline-block.md` -
  owns the accepted duplication D-08 leaves behind

## Decisions Made

- See `key-decisions` above: the dark/light colour-divergence assertion in `quote_card_test.dart`
  reads `gw.textSecondary` (the fee line) rather than `gw.textPrimary` (the receive line), because
  `textPrimary` is mode-invariant across `GWColors.dark()`/`.light()` by construction — both factories
  derive it from the same `GeniusWalletColors.textPrimary` getter, which reads a single app-wide
  `GWAppearance.isLight` flag rather than varying per constructed instance. This is the same class of
  surprise 09-01 recorded for `gw.statusWarning`: a fact about the token, not a defect in this
  widget's re-skin. No production code changed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `quote_card_test.dart`'s dark/light divergence assertion targeted a
mode-invariant field**
- **Found during:** Task 2, first test run
- **Issue:** The plan's `<behavior>` line asked to assert the receive line's primary text colour
  differs between a dark host and a light host. `gw.textPrimary` is byte-identical across
  `GWColors.dark()`/`.light()` (see Decisions Made) — the test failed comparing white to white, not
  because the widget lacks a live appearance read, but because that specific token doesn't vary
  between the two test factories.
- **Fix:** Re-pointed the assertion at the fee line's `gw.textSecondary`, which genuinely diverges
  between `dark()` and `light()` (light carries an explicit AA-fix override). The widget's live
  `GWColors` read (added this task) is unchanged; only which rendered colour the test compares was
  adjusted.
- **Files modified:** `test/banxa/quote_card_test.dart`
- **Verification:** `flutter test test/banxa/quote_card_test.dart` — all 4 assertions pass.
- **Committed in:** `bea34fe` (Task 2 commit)

**2. [Rule 3 - Blocking] `quote_card.dart`'s doc comment reworded to avoid a literal-substring
self-trip**
- **Found during:** Task 2
- **Issue:** The plan explicitly warned against pasting a constructor-call sample into the file's
  new doc comment, since 09-07's later literal gate scans this file's source. A first draft included
  the literal backtick-quoted substring `` `QuoteCard(` `` in prose, which is exactly that pattern.
- **Fix:** Reworded to "a repo-wide search for an instantiation of this class turns up nothing
  outside this file's own declaration" — same meaning, no literal constructor-call substring.
- **Files modified:** `lib/banxa/banxa_components/quote_card.dart`
- **Verification:** `grep -rc 'QuoteCard(' lib/ --include=*.dart | grep -v ':0' | wc -l` → 1 (only
  the file's own constructor declaration).
- **Committed in:** `bea34fe` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 Rule 1 test-assertion fix, 1 Rule 3 comment reword). No scope
creep; no architectural changes; no production behavior changed by either fix.
**Impact on plan:** Both fixes were necessary for the plan's own tests/acceptance criteria to pass.
Neither changes `banxa_buy_screen.dart`'s or `quote_card.dart`'s public shape.

## Issues Encountered

- Same class of surprise as 09-01's `gw.statusWarning` finding, this time for `gw.textPrimary`: the
  token is mode-invariant across `GWColors.dark()`/`.light()` because both factories derive it from
  a getter that reads a single global appearance flag rather than an explicit per-mode override. No
  production code was changed — see Deviations 1 and Decisions Made.

## User Setup Required

None - no external service configuration required.

## Outstanding (recorded per 09-CONTEXT.md D-03, never claimed as met)

- **The ENABLED Create Order rung's paint.** Cannot be reached in an automated test without a live
  quote from the sandbox, which D-03 forbids. Only the disabled rung and the retry affordance are
  pinned by `banxa_buy_screen_test.dart`.
- **Whether the re-skinned buy form reads as a sibling of the Swap tab.** A walk judgement; no walk
  is authorised this phase (D-03).

## Next Phase Readiness

- `banxa_buy_screen.dart`'s share of GAP-05 is closed: `GWButton`/`GWCard` throughout, no raw colour
  literal except the deliberately-preserved boot-overlay scrim (`Colors.black45`, still present,
  still mode-invariant by construction).
- `quote_card.dart` wears the redesign and is still confirmed dead — D-08 held. Its duplication has
  a named owner in `.planning/todos/pending/`.
- No blockers for 09-04.

---
*Phase: 09-banxa*
*Completed: 2026-07-27*

## Self-Check: PASSED

All 5 files in `files_modified` found on disk; both task commits (`e16b9de`, `bea34fe`) found in
`git log --oneline --all`.
