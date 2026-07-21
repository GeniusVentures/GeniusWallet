---
phase: quick/260721-bb3
plan: 260721-bb3
subsystem: docs
tags: [ui-spec, roadmap, todos, contrast, wcag, contract-correction]

requires:
  - phase: 05-dashboard
    provides: "05-VERIFICATION.md's re-verification findings (stale UI-SPEC §3.1 pairing, Phase 7 deferral now superseded, 3 loose follow-ups)"
provides:
  - "UI-SPEC §3.1's toggle row corrected to the shipped brandPrimaryStrong/textOnBrand pairing, with both recomputed contrast ratios (2.56:1 rejected / 7.74:1 shipped) and the escape history recorded inline"
  - "ROADMAP Phase 7 inheritance note naming the chart re-skin already delivered in Phase 5 (260721-dws) and its exact 4-line residue"
  - "Three new standing todos capturing the re-verification's loose follow-ups (zoom/pan icons, dashboard-retry decision, side-by-side Release-exe walk)"
  - "Bidirectional link between the zoom/pan-icons todo and the existing timeframe-ranges todo"
affects: [05-dashboard, 07-token-screens]

tech-stack:
  added: []
  patterns: []

key-files:
  created:
    - .planning/todos/pending/2026-07-21-chart-zoom-pan-icons-still-raw-colors-white.md
    - .planning/todos/pending/2026-07-21-decision-dashboard-error-branch-retry.md
    - .planning/todos/pending/2026-07-21-side-by-side-walk-dashboard-vs-release-exe.md
  modified:
    - .planning/phases/05-dashboard/05-UI-SPEC.md
    - .planning/ROADMAP.md
    - .planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md

key-decisions:
  - "UI-SPEC §3.1's selected-label token corrected from textPrimary to textOnBrand — matches what 05-02 already shipped in code"
  - "UI-SPEC §3.1's fill token corrected from brandPrimary to brandPrimaryStrong, and both ratios re-anchored to the real shipped fill (2.56:1 rejected / 7.74:1 shipped) — brandPrimary and brandPrimaryStrong are distinct constants, and 260721-0ze's app-wide brand sweep repointed the fill after 05-02 shipped it against the original brandPrimary"
  - "Phase 7's chart-reskin deferral downgraded from 'whole file' to a named 4-line residue, inheriting Phase 5's 260721-dws work instead of re-budgeting it"
  - "Dashboard retry gap filed as a two-option DECISION todo, not resolved — the ROADMAP-vs-UI-SPEC §6 conflict needs a human ruling, not code"

requirements-completed:
  - "verification:05-VERIFICATION-new_findings-zoom-pan-icons"
  - "verification:05-VERIFICATION-gap-1-dashboard-retry-decision"
  - "verification:05-VERIFICATION-human_verification-release-exe-walk-NOW_POSSIBLE"
  - "verification:05-VERIFICATION-deferred-chart-reskin-superseded"
  - "state:open-decision-2-ui-spec-3.1-carries-the-1.96-pairing"

coverage:
  - id: D1
    description: "UI-SPEC §3.1's toggle row names brandPrimaryStrong/textOnBrand as the fill/selected-label tokens, with both ratios recomputed against the real shipped fill (2.56:1 rejected, 7.74:1 shipped) inline"
    verification:
      - kind: other
        ref: "grep -F 'GNUS/Minions toggle' .planning/phases/05-dashboard/05-UI-SPEC.md — matches textOnBrand, brandPrimaryStrong, borderSubtle, 2.56:1, 7.74:1; table row count unchanged (7 pipe-rows)"
        status: pass
    human_judgment: false
  - id: D2
    description: "ROADMAP Phase 7 carries an additive inheritance note naming 260721-dws, the superseded whole-file deferral, and the 4-line Colors.white residue"
    verification:
      - kind: other
        ref: "awk range extraction of Phase 7 section + grep for crypto_live_chart, 260721-dws, 455, 480, tracking todo path, and unchanged criterion 1 text"
        status: pass
    human_judgment: false
  - id: D3
    description: "Three new todos filed matching project convention, with bidirectional zoom/pan <-> timeframe-ranges linking and a no-code DECISION framing on the retry todo"
    verification:
      - kind: other
        ref: "frontmatter grep (created/title/area/files/## Problem/## Solution) on all 3 new files + cross-link grep both directions + git status --porcelain scope check"
        status: pass
    human_judgment: false

duration: 8min
completed: 2026-07-21
status: complete
---

# Quick Task 260721-bb3: Correct Stale Planning Assumptions Summary

**Corrected UI-SPEC §3.1's toggle contract to the shipped `brandPrimaryStrong`/`textOnBrand` pairing with recomputed WCAG ratios, added a Phase 7 ROADMAP note recording that Phase 5 already re-skinned the chart, and filed three re-verification follow-ups as todos.**

## Performance

- **Duration:** 8 min (08:14:41 → 08:22:xx, four task commits including a self-review follow-up)
- **Started:** 2026-07-21T08:14:00-03:00 (approx.)
- **Completed:** 2026-07-21T08:22:00-03:00 (approx.)
- **Tasks:** 3 plan tasks + 1 follow-up correction, all completed
- **Files modified:** 6 (`.planning/` only)

## Accomplishments
- UI-SPEC §3.1's GNUS/Minions toggle row now names `brandPrimaryStrong`/`textOnBrand` as the fill/selected-label tokens (matching shipped code exactly), with both ratios recomputed against the real fill (2.56:1 rejected / 7.74:1 shipped) and a load-bearing rule note recording the escape history — 05-02's original toggle, quick task 260721-k81's transaction badge, and 260721-0ze's silent fill repoint — inline, so the contract cannot silently regress a fourth time.
- ROADMAP Phase 7 now carries an additive "Inherits from Phase 5" note: `crypto_live_chart.dart` was already re-skinned by quick task 260721-dws inside Phase 5 (`0bcf3df`, PR #210); only 4 raw `Colors.white` values remain, all on the zoom/pan `IconButton` row (lines 455/463/471/480). Phase 7's four success criteria are byte-unchanged.
- Filed three new todos matching the project's standing convention, plus a back-link from the existing timeframe-ranges todo to the new zoom/pan-icons todo (bidirectional dependency now visible from either file).

## Task Commits

Each task was committed atomically:

1. **Task 1: Correct UI-SPEC §3.1's toggle row to the shipped, AA-passing token** - `2e62516` (fix)
2. **Task 2: Add a Phase 7 inheritance note recording the chart re-skin already delivered in Phase 5** - `00edd3a` (docs)
3. **Task 3: File the three re-verification follow-ups as todos and back-link the timeframe todo** - `0fe12bb` (docs)
4. **Follow-up: Re-anchor §3.1's fill token and ratios to `brandPrimaryStrong`** - `eaaeaa1` (fix) — coordinator-directed correction to Task 1's own deliverable, found self-inconsistent during self-review (see Deviations)

**Plan metadata:** not yet committed — per this quick task's explicit constraints, the orchestrator commits `PLAN.md`/`SUMMARY.md`/`STATE.md` afterward, not this execution.

_Note: no TDD tasks in this plan (docs-only quick task)._

## Files Created/Modified
- `.planning/phases/05-dashboard/05-UI-SPEC.md` - §3.1 toggle row selected-label token corrected + rule note added
- `.planning/ROADMAP.md` - Phase 7 "Inherits from Phase 5" note added (additive only)
- `.planning/todos/pending/2026-07-21-chart-zoom-pan-icons-still-raw-colors-white.md` - new todo
- `.planning/todos/pending/2026-07-21-decision-dashboard-error-branch-retry.md` - new todo (DECISION NEEDED)
- `.planning/todos/pending/2026-07-21-side-by-side-walk-dashboard-vs-release-exe.md` - new todo
- `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md` - step 3 extended with a back-link to the new zoom/pan-icons todo

## Decisions Made
- Task 1 as originally planned kept the fill token cell (`brandPrimary`) and border token cell (`borderSubtle`) exactly as the plan specified, moving only the selected-label token to `textOnBrand`. This was superseded by the follow-up correction below.
- The retry todo (`decision-dashboard-error-branch-retry.md`) deliberately proposes no code and picks neither of its two named options — the plan required a human ruling, not an implementation choice.
- Fill token corrected from `brandPrimary` to `brandPrimaryStrong`, with both ratios recomputed against the real shipped fill, per explicit coordinator direction after self-review surfaced the discrepancy.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] UI-SPEC §3.1's contract cell was internally self-inconsistent — corrected fill token and recomputed both ratios**
- **Found during:** Self-check after Task 3, reported to the coordinator during final review.
- **Issue:** Task 1, as originally executed, left §3.1's fill-token cell as `brandPrimary` per the plan's literal instruction. Reading `lib/components/wallet_overview.dart:140` (read-only, unmodified throughout) showed the shipped fill is actually `GeniusWalletColors.brandPrimaryStrong` — a distinct color constant (`genius_wallet_colors.dart:48-49`: `brandPrimary` = `#14C8FF`, `brandPrimaryStrong` = `#0AAEE6`), not an alias. Quick task 260721-0ze's app-wide brand-consistency sweep (2026-07-21, same day) had repointed the toggle's fill after 05-02 originally shipped it against `brandPrimary`. The result: the contract cell named one fill (`brandPrimary`) while its own inline note justified `textOnBrand`'s selection with contrast ratios (1.96:1 / 10.12:1) measured against a *different* fill — a future reader re-deriving those numbers against the real shipped fill would not reproduce them.
- **Fix:** Fill token cell corrected to `GeniusWalletColors.brandPrimaryStrong`. Both ratios recomputed against the real fill: `textPrimary` on `brandPrimaryStrong` = 2.56:1 (still a hard AA failure, conclusion unchanged), `textOnBrand` on `brandPrimaryStrong` = 7.74:1 (passes AA and AAA-normal). Rule note extended to record the 0ze fill-repoint as a second, independent drift route alongside 05-02's original selected-label substitution, and to name the distinct-constants fact as precisely why this drifted silently.
- **Files modified:** `.planning/phases/05-dashboard/05-UI-SPEC.md`
- **Verification:** Re-ran Task 1's automated verify pattern against the updated cell (`brandPrimaryStrong`, `2.56:1`, `7.74:1`, unchanged 7-pipe-row table, `**Binding rule:**` intact) — PASS. `git diff --cached --name-only` confirmed `.planning/`-only scope before commit.
- **Committed in:** `eaaeaa1`

---

**Total deviations:** 1 auto-fixed (Rule 1 — bug, contract self-inconsistency).
**Impact on plan:** Strengthens Task 1's deliverable — the contract now agrees with shipped code on both cells (fill and selected label), not just one. No scope creep: still `.planning/`-only, no `lib/` files touched, `lib/components/wallet_overview.dart` confirmed correct and left untouched.

## Issues Encountered
- Initial Edit attempt on Task 1 failed because the multi-line `old_string` spanned across an intervening table row and blank line not accounted for in the match — split into two separate `Edit` calls (row cell edit, then note insertion) and both succeeded on retry. No functional impact.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 05's re-verification blocker item ("UI-SPEC §3.1 still carries the 1.96:1 pairing") is now closed at the contract level, and the contract's fill token now agrees with shipped code too (`brandPrimaryStrong`), not just the selected-label token.
- Phase 7 planning can proceed without re-budgeting a full `crypto_live_chart.dart` re-skin; the residue is precisely scoped.
- The dashboard-retry gap remains genuinely open — it is now a well-formed, two-option decision todo awaiting a human ruling, not a Phase 05 sign-off blocker this task could resolve.
- No remaining known discrepancy in §3.1 — both the fill and selected-label cells were re-verified against `lib/components/wallet_overview.dart` at HEAD (read-only) and agree.

## Self-Check: PASSED

All 7 files (3 modified, 3 created, 1 this SUMMARY) confirmed present on disk. All 4 task commits (`2e62516`, `00edd3a`, `0fe12bb`, `eaaeaa1`) confirmed present in git log. `git status --porcelain` at completion showed only the untracked quick-task directory (SUMMARY.md, PLAN.md) — zero paths outside `.planning/`.

---
*Phase: quick/260721-bb3*
*Completed: 2026-07-21*
