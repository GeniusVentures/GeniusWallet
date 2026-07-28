---
phase: 09-banxa
plan: 07
subsystem: testing
tags: [flutter, flutter_test, banxa, gw_colors, regression-gate, phase-closeout]

requires:
  - phase: 09-banxa
    plan: 01
    provides: "the shared 4-bucket order-status ladder and test/banxa/ floor every prior Phase 9 plan re-skinned onto"
  - phase: 09-banxa
    plan: 02
    provides: "order_card.dart + banxa_orders_history.dart re-skinned"
  - phase: 09-banxa
    plan: 03
    provides: "banxa_buy_screen.dart + quote_card.dart re-skinned"
  - phase: 09-banxa
    plan: 04
    provides: "order_details_card.dart + order_details_page.dart re-skinned"
  - phase: 09-banxa
    plan: 05
    provides: "checkout_qr.dart + handle_banxa_drawer.dart re-skinned"
  - phase: 09-banxa
    plan: 06
    provides: "banxa_payment.dart + kyc_registration.dart re-skinned"
provides:
  - "test/banxa/banxa_reskin_literals_test.dart — a standing gate that fails if a pre-redesign colour literal reappears in any of the ten in-scope Banxa files, or if the two deliberately-preserved exceptions disappear"
  - ".planning/phases/09-banxa/09-OUTSTANDING.md — the honest ledger of what Phase 9 did and did not deliver, for /gsd-verify-work and any future reader"
affects: []

tech-stack:
  added: []
  patterns:
    - "Word-boundary regex (\\bColors\\.) over a naive substring match, so the gate does not false-positive on GWColors.dark()/GeniusWalletColors.foo while still catching bare Colors.* literals"
    - "Count-pinned allowlist entries (exactly 1, not 'at least 1') so an allowlisted literal's deletion fails the gate exactly as hard as a new literal's introduction"

key-files:
  created:
    - test/banxa/banxa_reskin_literals_test.dart
    - .planning/phases/09-banxa/09-OUTSTANDING.md
  modified: []

key-decisions:
  - "The 'no raw Material button' check carries one named exemption beyond the plan's two-entry colour allowlist: banxa_orders_history.dart's date-range OutlinedButton. 09-UI-SPEC.md's own component inventory says this control 'inherit[s] theme styling already' and needs no structural change — it is a filter control already wired to the app-wide ButtonTheme, not an un-re-skinned CTA. Recorded by file and count, same discipline as the colour allowlist, so it cannot silently absorb a real un-converted button later."
  - "No file needed a live-read exemption. The plan anticipated 'the two files whose re-skin is structural only and which genuinely need none' — inspecting all ten landed files found every one already carries the Theme.of(context).extension<GWColors>() read, so the live-read check has zero exemptions and the ladder was correctly a no-op here rather than something to invent an exemption for."
  - "GAP-05's checkbox is left unchecked, not ticked, in this plan — 09-OUTSTANDING.md states plainly that all three named files are re-skinned in place with structure unchanged (satisfying GAP-05's first clause) but that the before/after visual comparison GAP-05's own definition also asks for was never walked. The judgement is handed to phase verification with the full picture, rather than decided here."

requirements-completed: []

coverage:
  - id: D1
    description: "test/banxa/banxa_reskin_literals_test.dart — 31 tests scanning all ten in-scope files for forbidden Colors.*/GeniusWalletColors.deepBlue/lightGreenSecondary literals (outside the two count-pinned allowlist entries), a live GWColors read, and no un-exempted raw Material button"
    verification:
      - kind: unit
        ref: "test/banxa/banxa_reskin_literals_test.dart"
        status: pass
      - kind: unit
        ref: "test/banxa/ (full directory, 88 tests)"
        status: pass
    human_judgment: false
  - id: D2
    description: "The gate observed FAILING on a deliberate reintroduction of a raw Colors.grey literal into order_card.dart, and observed FAILING again on a deliberate deletion of the QR's allowlisted white backing in checkout_qr.dart — both reverted, git status confirmed clean afterward"
    verification:
      - kind: other
        ref: "manual edit/test/revert cycle, this SUMMARY's Accomplishments section carries the exact test-count evidence for both runs"
        status: pass
    human_judgment: false
  - id: D3
    description: ".planning/phases/09-banxa/09-OUTSTANDING.md records the four ROADMAP criteria honestly (1 PARTIAL, 2 and 3 NOT ADDRESSED, 4 delivered at code level), consolidates every prior plan's human-judgment item, and states SCR-05/GAP-05's requirement status without ticking either checkbox"
    verification:
      - kind: other
        ref: ".planning/phases/09-banxa/09-OUTSTANDING.md exists; grep -c 'OUTSTANDING' returns 2; SCR-05 line in REQUIREMENTS.md remains '- [ ]'"
        status: pass
    human_judgment: false
  - id: D4
    description: "Whether Phase 9's re-skin actually LOOKS right across all ten surfaces (visual fidelity walk)"
    verification: []
    human_judgment: true
    rationale: "D-03 forbids any walk this phase. This is the largest single OUTSTANDING item this phase closes with — recorded in 09-OUTSTANDING.md, never claimed as verified here."

duration: 25min
completed: 2026-07-27
status: complete
---

# Phase 9 Plan 7: Phase closeout — the standing literal gate and the honest ledger Summary

**Installed `test/banxa/banxa_reskin_literals_test.dart`, a standing gate over all ten Banxa surfaces this phase re-skinned — proven to bite twice, on a reintroduced literal and on a deleted allowlist entry, both reverted — and wrote `09-OUTSTANDING.md`, recording that three of Phase 9's four ROADMAP criteria are not met by this scope, without touching either requirement's checkbox.**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-07-27T14:15:00-03:00 (approx., first baseline check)
- **Completed:** 2026-07-27T14:22:44-03:00 (final task commit)
- **Tasks:** 2
- **Files modified:** 2 (both created — matches `files_modified`)

## Accomplishments

- `test/banxa/banxa_reskin_literals_test.dart`: 31 tests hardcoding all ten in-scope files
  (`banxa_buy_screen.dart`, `banxa_orders_history.dart`, `banxa_payment.dart`, `checkout_qr.dart`,
  `kyc_registration.dart`, `order_card.dart`, `order_details_card.dart`, `quote_card.dart`,
  `handle_banxa_drawer.dart`, `order_details_page.dart` — D-04 + D-07 + the 09-UI-SPEC addendum).
  Each file gets three checks: no forbidden `Colors.*`/`GeniusWalletColors.deepBlue`/
  `lightGreenSecondary` literal outside the count-pinned allowlist, a live
  `Theme.of(context).extension<GWColors>()` read present, and no un-exempted raw Material button.
- The colour-literal regex (`\bColors\.`) is word-bounded specifically so it does not false-positive
  on `GWColors.dark()` — a naive substring match would count the mandated live-read idiom itself as
  a violation, the exact self-tripping class 09-05-SUMMARY.md documented for its own acceptance
  criteria.
- The allowlist has exactly two entries, each pinned to a count of 1 (not "at least 1"): the QR's
  white backing (`checkout_qr.dart`) and the boot overlay's black-alpha scrim
  (`banxa_buy_screen.dart`) — so deleting either fails the gate exactly as hard as introducing a new
  literal does.
- **The gate was observed failing, twice, not merely assumed to work:**
  1. Temporarily added `final debugTripColor = Colors.grey;` to `order_card.dart`'s `build()` —
     `flutter test test/banxa/banxa_reskin_literals_test.dart` failed exactly one test
     (`order_card.dart carries no forbidden colour literal outside the allowlist`, expected 0 found
     1), all 29 others still passed. Reverted; re-ran green (31/31).
  2. Temporarily changed `checkout_qr.dart`'s QR backing from `color: Colors.white` to
     `color: gw.surfaceElevated` — `flutter test` failed exactly one test (`checkout_qr.dart carries
     no forbidden colour literal outside the allowlist`, expected 1 found 0), all others still
     passed. Reverted; re-ran green (31/31). `git status --porcelain` confirmed clean before
     committing either task.
- One raw Material button survives by design and is now a named, counted exemption:
  `banxa_orders_history.dart`'s date-range `OutlinedButton`, which 09-UI-SPEC.md's own component
  inventory explicitly says "inherit[s] theme styling already" and needs no structural change — a
  filter control, not a CTA. Every other raw `ElevatedButton`/`OutlinedButton`/`TextButton`/
  `FilledButton` across the ten files was already swapped to `GWButton` by 09-02 through 09-06;
  confirmed by running the check against the landed code before adding any exemption.
- `.planning/phases/09-banxa/09-OUTSTANDING.md`: carries forward 09-CONTEXT.md's `<scope_reduction>`
  table verbatim in substance (criterion 1 PARTIAL, criteria 2/3 NOT ADDRESSED, criterion 4
  delivered at code level), consolidates six OUTSTANDING items from the five preceding plans (the
  visual fidelity walk, the enabled Create Order CTA rung, the order-details banner's live
  appearance, `statusWarning`'s unmeasured AA contrast, `GWEmptyState`'s untested compact-threshold
  tier, and findings 6/7 by name), and states SCR-05/GAP-05's requirement status honestly without
  ticking either box.
- Re-verified the pinned baseline at both ends of this plan: `flutter analyze lib` = 59 (unchanged),
  `flutter test` = 463 pass / 1 known pre-existing failure
  (`test/local_wallet_storage_test.dart` — "Missing definition of `main` method") — 432 (09-06's
  final count) + 31 new gate tests from this plan, no regression.

## Task Commits

Each task was committed atomically:

1. **Task 1: The standing literal-and-live-read gate over all ten in-scope files** - `b97f612` (test)
2. **Task 2: Write 09-OUTSTANDING.md — what this phase did not deliver, and why** - `6c66d9d` (docs)

**Plan metadata:** (pending — final docs commit, see below)

## Files Created/Modified
- `test/banxa/banxa_reskin_literals_test.dart` - 31-test standing gate: forbidden colour literals
  (count-pinned allowlist), live `GWColors` reads, no un-exempted raw Material buttons, across all
  ten in-scope files
- `.planning/phases/09-banxa/09-OUTSTANDING.md` - the four-criterion honest status table, the
  consolidated OUTSTANDING list, and the SCR-05/GAP-05 requirement-status statement

## Decisions Made
- See `key-decisions` in frontmatter: the one named raw-button exemption
  (`banxa_orders_history.dart`'s date-range picker), the absence of any live-read exemption (all ten
  files already had one), and leaving GAP-05's checkbox for phase verification to decide rather than
  ticking it here.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] The plan's "no raw Material button" behavior needed one named exemption not spelled out in the task text**
- **Found during:** Task 1, designing the raw-button check
- **Issue:** The plan's `<behavior>` states flatly "the gate fails if any of the ten files still
  contains a raw Material button widget," but `banxa_orders_history.dart`'s date-range picker is a
  real, un-converted `OutlinedButton(...)` — and 09-UI-SPEC.md's own component inventory
  (line 224) explicitly says this control "inherit[s] theme styling already" and needs no
  structural change, since it is a filter control already wired to the app-wide `ButtonTheme`, not
  a CTA. A gate with no exemption for this control would fail against correctly-landed code from
  09-02.
- **Fix:** Added a second, separately-named allowlist (`_rawButtonExemptionCount`) with exactly one
  entry, carrying its UI-SPEC citation as the reason — same discipline as the plan's own two-entry
  colour allowlist, so this exemption is a recorded decision, not a silent carve-out.
- **Files modified:** `test/banxa/banxa_reskin_literals_test.dart`
- **Verification:** `flutter test test/banxa/banxa_reskin_literals_test.dart` — all 31 tests pass;
  confirmed via `grep` that no other raw Material button constructor exists across the ten files
  before adding this one exemption.
- **Committed in:** `b97f612` (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 — a plan-authoring gap between a blanket behavior rule
and a pre-existing, UI-SPEC-endorsed exception in already-landed code). No scope creep; no `lib/`
file touched; no architectural change.
**Impact on plan:** The fix was necessary for the gate to pass against code this phase's own
UI-SPEC already declared correct. It does not weaken the gate's substance — every other raw
Material button in these ten files still fails the check if reintroduced, and the one exemption is
named, counted, and reasoned exactly like the plan's own colour allowlist.

## Issues Encountered
None beyond the deviation above.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness

- The literal gate now runs inside the normal `flutter test` loop — any future edit to one of the
  ten Banxa files that reintroduces a raw colour literal, deletes the QR backing or the boot scrim,
  drops a live `GWColors` read, or adds a new un-themed Material button will fail `flutter test`
  immediately, without needing a dedicated walk to catch it.
- `09-OUTSTANDING.md` is the single place phase verification (or `/gsd-verify-work`) should read
  before recording Phase 9 as complete. It explicitly forbids recording criteria 1–3 as met and
  states SCR-05 cannot be closed by this phase alone.
- `flutter analyze lib` = 59 (pinned baseline held across all seven plans). `flutter test` = 463
  pass / 1 known pre-existing failure — the full-suite number every later phase should compare
  against going forward, superseding 09-01's 376 baseline.
- No `lib/` file was touched by this plan (`git status --porcelain lib/` empty throughout);
  `git status --porcelain` across the whole phase names no fenced Phase-21 drawer, cubit/service
  file, or repository-root submodule path.
- SCR-05 and GAP-05 both remain unchecked in `REQUIREMENTS.md`, unchanged by this plan (grep counts
  identical to before this plan started) — their final disposition is phase verification's call,
  informed by `09-OUTSTANDING.md`.
- Recommended follow-up, named in `09-OUTSTANDING.md`: a small behaviour-fix phase covering
  criterion 2 (KYC redirect blocker) and finding 7 (Linux fallback), starting at the two competing
  redirect definitions (`banxa_api_services.dart:17` and `:146`).

---
*Phase: 09-banxa*
*Completed: 2026-07-27*

## Self-Check: PASSED

Both files in `files_modified` found on disk (`test/banxa/banxa_reskin_literals_test.dart`,
`.planning/phases/09-banxa/09-OUTSTANDING.md`); both task commits (`b97f612`, `6c66d9d`) found in
`git log --oneline --all`.
