---
phase: 03-gw-component-library
plan: 08
subsystem: docs
tags: [gap-analysis, requirements-traceability, inventory, banxa, dashboard, settings]

# Dependency graph
requires:
  - phase: 03-02
    provides: "GWButton, GWTextField, GWSelect, GWSwitch, GWIcon, GWCard, GWAnimatedNumber -- the primitives named for GAP-02/03/04/05/06"
  - phase: 03-03
    provides: "GWEmptyState, GWErrorState, GWSpinner"
  - phase: 03-04
    provides: "wallet_type_icon.dart"
  - phase: 03-05
    provides: "BottomDrawer/ResponsiveDrawer, GWDialog, AppScreenView, GWScreen"
  - phase: 03-06
    provides: "custom_drop_down.dart, currency_dropdown.dart -- 50/50 port complete, the primitive-cross-check baseline"
provides:
  - "03-GAP-INVENTORY.md -- the whole-app GAP-01 deliverable: 34 screen-level surfaces enumerated, 10 confirmed gaps (exact match to REQUIREMENTS.md GAP-02..06), 3 non-gap candidates investigated and ruled out, 1 new finding (order_details_page.dart moved-path analog), 1 deferred structural question for product"
  - "Independent re-derivation of the GAP file count (10, not the ROADMAP's estimated 12) via a whole-lib/ diff-filter=D command"
  - "Primitive cross-check: every gw_* primitive the 10 gap files' mechanical re-skin needs is confirmed present in the 50-file port -- zero missing"
affects: [04, 05, 06, 09, "03-10"]

tech-stack:
  added: []
  patterns:
    - "Whole-tree diff over per-directory diff for GAP-style D-list scans -- per-directory scoping silently loses rename-detection visibility (git can't see a file's destination outside the diffed path), which produced a false extra candidate (order_details_page.dart) until the same command was re-run scoped to the whole lib/ tree"

key-files:
  created:
    - .planning/phases/03-gw-component-library/03-GAP-INVENTORY.md
  modified: []

key-decisions:
  - "[Re-derivation] Ran git diff --diff-filter=D --name-only develop..origin/ui-redesign-3.514 -- lib/ across the ENTIRE lib/ tree in one command (not per-directory), producing 13 develop-only files that resolve to exactly REQUIREMENTS.md's known 10 GAP-02..06 files plus 3 investigated non-gap candidates -- independently reproduced, not inherited"
  - "[New finding] lib/screens/order_details_page.dart has a real Alex analog at a moved path (lib/banxa/order_details_page.dart, git rename-detected R076) not previously named in GAP-05's list -- recorded as a Phase 9 addendum (a real reference to re-skin against), not a new GAP requirement"
  - "[Structural question, deferred verbatim] Whether GAP-06's transaction_displays.dart re-skin should keep develop's single-file function-based structure or split into per-type files matching Alex's 4-file organization (transaction_item.dart / _purchased_item.dart / _swapped_item.dart / _escrow_release_item.dart) -- recorded for product, not decided here, per REQUIREMENTS.md's re-skin-vs-restructure test"
  - "[Scope exclusion] lib/tokeninfo/token_model.g.dart and lib/hive_registrar.g.dart are both develop-only per the whole-tree diff but are generated data-layer files (JSON model, Hive adapter registrar), not screen-level UI surfaces -- excluded from GAP-01 per this plan's own scope fence, not silently counted toward the gap total"

requirements-completed: [GAP-01]

coverage:
  - id: D1
    description: "Whole-app inventory produced: 34 screen-level surfaces enumerated (30 router.dart/wallet_routes.dart route targets + 4 reachable sub-views), each with an evidenced Y/N has-Alex-analog verdict backed by a recorded diff command and result"
    requirement: "GAP-01"
    verification:
      - kind: other
        ref: "test -f .planning/phases/03-gw-component-library/03-GAP-INVENTORY.md (pass); grep -q diff-filter (pass); grep -q lib/settings/ and lib/account/ (pass, confirms enumeration went beyond lib/components/)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every known GAP group (GAP-02..06, 10 files) is accounted for and independently reproduced (not re-derived from REQUIREMENTS.md by assumption) via a whole-lib/ diff-filter=D scan; 3 extra candidates investigated and ruled out with evidence"
    requirement: "GAP-01"
    verification:
      - kind: other
        ref: "for g in GAP-02 GAP-03 GAP-04 GAP-05 GAP-06; do grep -q \"$g\" 03-GAP-INVENTORY.md; done -- all pass; git diff --diff-filter=D --name-only develop..origin/ui-redesign-3.514 -- lib/ returns exactly 13 files, resolving to the 10 known + 3 investigated non-gaps, recorded inline"
        status: pass
    human_judgment: false
  - id: D3
    description: "Every no-analog surface split mechanical vs structural using REQUIREMENTS.md's own test; every deferred structural question written down verbatim and unanswered (1 found: transaction_displays.dart's file organization)"
    requirement: "GAP-01"
    verification:
      - kind: other
        ref: "grep -qi mechanic (pass); grep -qi structural (pass); §5's structural question is quoted verbatim in 03-GAP-INVENTORY.md, not resolved"
        status: pass
    human_judgment: false
  - id: D4
    description: "Every primitive the 10 gap files' mechanical re-skin calls for is cross-checked against the 50-file port (03-06-SUMMARY.md) and confirmed present -- zero missing, so ROADMAP criterion 6's second clause is not blocked by a missing primitive"
    requirement: "GAP-01"
    verification:
      - kind: other
        ref: "grep -q '## Reconciliation' (pass); grep -qE '50|03-06-SUMMARY' (pass); grep -qi 'new finding\\|already covered\\|known group' (pass) -- all 15 named primitives (GWCard, GWSelect, GWTextField, GWSwitch, GWButton, GWIcon, GWDialog, BottomDrawer, custom_drop_down.dart/currency_dropdown.dart, GWEmptyState, GWErrorState, GWAnimatedNumber, GWSpinner, AppScreenView/GWScreen, wallet_type_icon.dart) checked present in the 50, table in 03-GAP-INVENTORY.md §Reconciliation"
        status: pass
    human_judgment: false
  - id: D5
    description: "Real evidenced surface count reported plainly against the ROADMAP's estimate of 12, with the discrepancy explained rather than papered over"
    human_judgment: true
    rationale: "The count itself (10, not 12) is mechanically evidenced and cross-checked against REQUIREMENTS.md's own already-corrected note. Whether the explanation is judged sufficiently transparent for ROADMAP Phase 3 criterion 6 sign-off is a human/03-10 call, not something this plan's own automated verification block can self-certify."

# Metrics
duration: 20min
completed: 2026-07-17
status: complete
---

# Phase 3 Plan 08: GAP-01 Whole-App Inventory Summary

**Produced `03-GAP-INVENTORY.md`: an evidenced, whole-`lib/`-tree diff against `origin/ui-redesign-3.514` independently confirms exactly 10 develop-only screen surfaces (not the ROADMAP's estimated 12) — precisely REQUIREMENTS.md's GAP-02..06 — with a new Banxa finding, one deferred structural question, and a zero-missing primitive cross-check against the 50-file port.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-07-17T11:04:00Z (approx)
- **Completed:** 2026-07-17T11:23:13Z
- **Tasks:** 2/2 (landed as one commit — see Deviations)
- **Files modified:** 1 (`03-GAP-INVENTORY.md`, created)

## Accomplishments
- Ran `git diff --diff-filter=D --name-only develop..origin/ui-redesign-3.514 -- lib/` across the **entire** `lib/` tree (all 27 top-level subdirectories) in one command — 13 develop-only files, resolving to exactly REQUIREMENTS.md's known 10 GAP-02..06 files plus 3 candidates investigated and ruled out
- Enumerated all 30 `router.dart`/`wallet_routes.dart` route targets plus 4 reachable sub-views (`sdk_account_manager.dart`, `transaction_displays.dart`, `loading.dart`, `wallet_overview.dart`) — 34 total screen-level surfaces, each with a recorded Y/N verdict and its evidence
- Discovered git's rename-detection is diff-scope-dependent: a per-directory scan of `lib/screens/` reports `order_details_page.dart` as develop-only (D), while the whole-tree scan correctly reports it as a rename (`R076`) to `lib/banxa/order_details_page.dart` — recorded as a methodological finding, not just a data point
- New finding: `order_details_page.dart`'s moved-path Alex analog was not in GAP-05's named 3-file list — flagged as a Phase 9 addendum (a real design reference exists), not a new GAP requirement
- One deferred structural question recorded verbatim: whether `transaction_displays.dart` (GAP-06) should keep develop's single-file structure or split into per-type files matching Alex's 4-file organization (`transaction_item.dart` + 3 siblings) — not decided, per REQUIREMENTS.md's own re-skin-vs-restructure test
- Named every `gw_*` primitive each of the 10 gap files' mechanical re-skin needs and cross-checked all of them against the 50-file port (`03-06-SUMMARY.md`) — **zero missing**
- Reported the real evidenced count (10) against the ROADMAP's estimated 12, explaining the discrepancy rather than padding or trimming to match

## Task Commits

Both tasks landed in a single commit — see Deviations for why:

1. **Task 1 + Task 2: Whole-app inventory + primitive cross-check** - `26e6712` (docs)

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Created/Modified
- `.planning/phases/03-gw-component-library/03-GAP-INVENTORY.md` - The GAP-01 deliverable: whole-app enumeration (§2), non-gap-candidate investigation (§3), new finding (§4), deferred structural question (§5), mechanical/structural split with primitives and owning phase per file (§6), reconciliation + primitive cross-check (§Reconciliation)

## Decisions Made
- Ran the D-list scan against the **whole** `lib/` tree in one command rather than per-directory, after discovering per-directory scoping silently loses rename-detection visibility (a real methodological risk for this kind of inventory, not just a stylistic preference)
- Investigated all 3 non-`GAP-02..06` develop-only candidates individually (opened each file) rather than assuming they were new gaps: 2 turned out to be moved-path Alex analogs (`splash.dart`, `order_details_page.dart`), 2 turned out to be non-UI generated files (`token_model.g.dart`, `hive_registrar.g.dart`) explicitly out of GAP-01's screen-level scope
- Recorded the `transaction_displays.dart` vs. Alex's 4-file transaction-item split as a genuine deferred structural question rather than silently picking either reading — REQUIREMENTS.md gives this milestone no owner for that judgment
- Did not attempt to force the evidenced count to match the ROADMAP's "12" — reported 10 plainly, consistent with REQUIREMENTS.md's own prior correction that the named groups sum to 10

## Deviations from Plan

**One process deviation, not a Rule 1/2/3 auto-fix:**

**Both tasks landed in a single commit instead of two.**
- **Found during:** Task 2 (primitive cross-check)
- **Reasoning:** The plan's two tasks both modify the exact same single file (`03-GAP-INVENTORY.md`), and Task 2's work (cross-checking Task 1's own inventory against the 50-file port) is only meaningful once Task 1's enumeration exists. Producing the document as one integrated pass — enumerate, investigate candidates, split mechanical/structural, name primitives, then cross-check those primitives in the same writing session — was more accurate than manufacturing an artificial intermediate "Task 1 only" version of the document to commit separately, since the "Reconciliation" section (Task 2's own deliverable) directly summarizes and depends on every other section (Task 1's deliverable). Splitting the commit would have meant either (a) committing a materially incomplete document as "Task 1 done" then immediately superseding it, or (b) writing Task 2's content first and back-filling — both less honest about how the work was actually produced.
- **Impact:** No content is missing or different from what two separate commits would have produced. Both tasks' `<done>` criteria are met in the single artifact and verified by the same automated `<verify>` blocks (all pass, see coverage table above). Recorded here for transparency per the "commit each task atomically" instruction, which this deviates from for a single-file, tightly-coupled two-task plan.

**No Rule 1/2/3 auto-fixes.** This is a doc-only plan; there was no code to break, no missing critical functionality to add, and no blocking compile/build issue to fix.

---

**Total deviations:** 1 (process — single commit for a two-task, single-file plan)
**Impact on plan:** None on content or verification outcome; only on commit granularity, explained above.

## Issues Encountered
None beyond the deviation documented above.

## Stub Tracking
Not applicable — this plan produces a planning document, not application code. No hardcoded empty values, no placeholder UI, nothing that flows to a screen.

## Threat Flags

None. This plan modifies exactly one `.planning/` document and touches no code, no new network surface, no auth path, no schema.

## User Setup Required

None. Doc-only plan; no dependencies, no environment variables, no external service configuration.

## Next Phase Readiness

- **GAP-01's deliverable exists and is evidenced.** `.planning/phases/03-gw-component-library/03-GAP-INVENTORY.md` records the full inventory, every diff command and result, the mechanical/structural split, the one deferred structural question, and the primitive cross-check — ready for `03-10`'s sign-off of ROADMAP Phase 3 success criterion 6.
- **Zero missing primitives** means criterion 6's second clause is not blocked from this plan's side; `03-10` still needs to confirm each named primitive is actually visible as a gallery section (that gallery-visibility confirmation is explicitly `03-10`'s job, not asserted here).
- **Carry into Phase 9 (Banxa, GAP-05):** `order_details_page.dart` has a real, moved-path Alex analog (`lib/banxa/order_details_page.dart` on the reference branch) not named in GAP-05's original 3-file list — a genuine reference to re-skin against, recorded in `03-GAP-INVENTORY.md` §4.
- **Carry into Phase 5 (Dashboard, GAP-06):** the deferred structural question about `transaction_displays.dart`'s file organization (single-file vs. per-type split matching Alex's 4 files) needs a product decision before or during that phase's execution — recorded verbatim in `03-GAP-INVENTORY.md` §5, not resolved here.
- **Carry into `03-10`:** the primitive cross-check table (`03-GAP-INVENTORY.md` §Reconciliation) is the checklist `03-10` cross-references against the extended gallery (`03-09`).
- No blockers. Next actions per `.continue-here.md`: execute `03-09` (gallery extension), then `03-10` (no-visual-change walk + verification record, closes DS-02/DS-03/DS-04/GAP-01).

---
*Phase: 03-gw-component-library*
*Completed: 2026-07-17*

## Self-Check: PASSED
