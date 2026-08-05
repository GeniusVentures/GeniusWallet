---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
plan: 05
subsystem: infra
tags: [dart-fix, lint-gate, analyzer, codemod, const-correctness, directives-ordering]

# Dependency graph
requires:
  - phase: 22-04
    provides: "Green baseline this plan must not regress: 512/0 tests, 344 analyze issues, 0 brace violations"
provides:
  - "Every analyzer issue with an associated dart fix applied, one rule per commit, in both the root package and packages/genius_api"
  - "22-05-RESIDUE.md -- a per-rule, per-file inventory of the 101-issue non-automatable tail, each rule tagged mechanical or judgement, that 22-06 consumes directly"
  - "A repo where dart fix --dry-run reports 'Nothing to fix!' in both packages"
affects: ["22-06 (hand-fixes the residue using 22-05-RESIDUE.md as its input)", "23-02 (theme migration -- 4 files flagged where a new const now binds a GeniusWalletColors constant)"]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "One dart fix rule per commit: dart fix --apply --code=<rule>, then dart format, then flutter analyze/test/brace-check, then commit -- makes 14 rule-scale diffs individually revertable instead of one opaque sweep"
    - "Trust the live dry-run over a plan's reference numbers: dart fix --dry-run counts shifted between the plan's 2026-07-28 reference figures and the actual run (e.g. prefer_const_literals_to_create_immutables went from a reference 1 to a live 7 once earlier rules had already landed), confirming the plan's own instruction to re-measure rather than trust stale estimates"
    - "Two-package dart fix: analyzer resolves the nearest analysis_options.yaml per source file, so packages/genius_api (its own excludes for lib/ffi and lib/proto) needs its own dart fix invocation from its own directory -- a root-only run silently skips it"

key-files:
  created:
    - .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-05-RESIDUE.md
  modified:
    - "90 lib/ and test/ files across 14 rule-commits (dart fix mechanical rewrites)"
    - "3 packages/genius_api files (unnecessary_library_name, dead format-reflow revert)"

key-decisions:
  - "Reverted an accidental dart format pass over packages/genius_api/lib/ffi/trust_wallet_api_ffi.dart (6325 lines) after the unnecessary_library_name commit's format step swept it up. That file is machine-generated FFI bindings excluded from analysis by packages/genius_api/analysis_options.yaml's own comment ('These are not hand-edited'); dart format doesn't respect analyzer excludes the same way, so it reformatted the whole file. git checkout -- reverted only that one file before committing, keeping the generated-file boundary the codebase's own analysis_options.yaml documents."
  - "Manually reviewed the 3 unnecessary_non_null_assertion removals in lib/web/web_view_mobile.dart before applying, per the plan's threat-model requirement (T-22-16). All 3 are inside the onPageFinished navigation-delegate closure, on a local WebViewController? assigned exactly once and never reassigned; the first controller! on line 171 (kept, still required) proves non-null for the remainder of that closure's flow, making the 3 later assertions genuinely redundant rather than a nullability risk. Not wallet/key material -- a webview navigation controller."
  - "Applied 2 rules beyond the plan's named 12 (deprecated_member_use, sized_box_for_whitespace) because Task 3 explicitly requires dart fix --dry-run to report zero available fixes before writing the residue, and both still had live fixers after the planned 12 rules landed. Same one-rule-per-commit discipline applied to these."
  - "Left one anomaly undiagnosed rather than hand-editing around it: lib/hive_registrar.g.dart (a build_runner-generated file matching the lib/**/*.g.dart analyzer exclude) still reports one directives_ordering diagnostic in the live flutter analyze output, despite dart fix --dry-run correctly declining to offer a fix for it. Documented in the residue as an exclude-glob/generated-file anomaly for a future plan to investigate at the generator or exclude-glob level, not something to hand-edit into a regenerable file."

requirements-completed: [ORG-03]

coverage:
  - id: D1
    description: "Every analyzer issue with an associated dart fix is applied, one rule per commit, across both packages"
    requirement: "ORG-03"
    verification:
      - kind: unit
        ref: "dart fix --dry-run (repo root): 'Nothing to fix!'"
        status: pass
      - kind: unit
        ref: "dart fix --dry-run (packages/genius_api): 'Nothing to fix!'"
        status: pass
    human_judgment: false
  - id: D2
    description: "flutter analyze issue count drops from the 22-04 baseline (344) to the non-automatable tail (~100 or fewer), with zero errors"
    requirement: "ORG-03"
    verification:
      - kind: unit
        ref: "flutter analyze --no-pub: 101 issues found, 0 errors (down from 344)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Applying automated fixes changes no test result -- 512/0 unchanged throughout all 14 rule-commits"
    requirement: "ORG-03"
    verification:
      - kind: unit
        ref: "flutter test --no-pub run after every one of the 14 commits: All tests passed! (512/0) every time"
        status: pass
    human_judgment: false
  - id: D4
    description: "The brace-every-if gate (22-04's deliverable) is not regressed by any dart fix reflow"
    requirement: "ORG-03"
    verification:
      - kind: unit
        ref: "bash tool/check_brace_style.sh --count: 0, checked after every commit"
        status: pass
    human_judgment: false
  - id: D5
    description: "The remaining 101-issue tail is documented per rule, per file, with a mechanical-vs-judgement note, ready for 22-06 to execute from directly"
    requirement: "ORG-03"
    verification:
      - kind: manual_procedural
        ref: "22-05-RESIDUE.md -- 15 rule groups, every one with a per-file count table and a mechanical/judgement classification; rule-count sanity check sums to exactly 101"
        status: pass
    human_judgment: true
    rationale: "The mechanical-vs-judgement classification and the per-rule remediation notes are qualitative editorial calls about how 22-06 should approach each rule group -- not something a test asserts. A human reviewing 22-06's plan against this document is the correct verification path."

# Metrics
duration: ~21min (commit span; includes analysis, review, and writing 22-05-RESIDUE.md)
completed: 2026-07-28
status: complete
---

# Phase 22 Plan 05: Burn Down the Mechanical Analyzer Backlog Summary

**`dart fix --apply --code=<rule>` run one rule at a time across 14 rules (12 planned + 2 more surfaced by the plan's own zero-tolerance Task 3 check) drops `flutter analyze` from 344 to 101 issues with zero test or brace-style regressions, and `22-05-RESIDUE.md` hands the remaining 101-issue tail to 22-06 fully classified by rule.**

## Performance

- **Duration:** ~21 min (commit-timestamp span; total session time including reading, review, and residue authoring was longer)
- **Started:** 2026-07-28T12:18:22-03:00 (first rule commit)
- **Completed:** 2026-07-28T12:38:53-03:00 (residue-doc commit)
- **Tasks:** 3
- **Files modified:** 92 (90 lib/test files across 14 rule-commits, 2 more in packages/genius_api, plus 22-05-RESIDUE.md created)

## Accomplishments

- Ran `dart fix --dry-run` fresh in both the repo root and `packages/genius_api` before touching anything, rather than trusting the plan's 2026-07-28-reference counts -- and confirmed the plan's own warning that these drift: several rules' live counts differed from the plan's estimate (`prefer_const_literals_to_create_immutables` went from a reference 1 to a live 7 once earlier rules had already landed and surfaced more opportunities).
- Applied all 7 Task 1 rules (`unnecessary_library_name`, `unnecessary_underscores`, `unnecessary_non_null_assertion`, `use_super_parameters`, `prefer_final_locals`, `directives_ordering`) plus confirmed `use_null_aware_elements` had zero live occurrences (already resolved by prior tree state) -- one commit per rule, `flutter analyze`/`flutter test`/brace-check verified after each. Analyzer dropped 344 → 185 (−159, exceeding the plan's ≥140 acceptance bar).
- Manually reviewed the 3 `unnecessary_non_null_assertion` removals in `lib/web/web_view_mobile.dart` per the plan's T-22-16 threat-model requirement, confirming the analyzer's non-null proof was sound (Dart flow-promotes a never-reassigned local across a closure's flow after its first successful `!` unwrap) before applying.
- Applied all 5 Task 2 rules (`unnecessary_const`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`, `prefer_const_constructors`, `use_colored_box`), running the full `flutter test` suite before committing `prefer_const_constructors` specifically as the plan required. Analyzer dropped 185 → 103 (−82, exceeding the plan's ≥60 acceptance bar).
- Identified and documented 4 files where the new `prefer_const_constructors` const now binds directly to a `GeniusWalletColors`/`Colors.*` constant -- the 23-02 forward-flag the plan asked for, so that theme-migration plan isn't surprised by "invalid constant value" errors when it removes the const.
- Task 3's `dart fix --dry-run` re-check found 2 more live-fixable rules the plan hadn't named (`deprecated_member_use`, `sized_box_for_whitespace`); applied both under the same one-rule-per-commit discipline per the plan's explicit "if it does report something, apply it" instruction. Analyzer dropped 103 → 101.
- Wrote `22-05-RESIDUE.md`: all 101 remaining issues grouped into 15 rule groups, each with a per-file count table and a one-line mechanical-vs-judgement classification, plus a cross-cutting note flagging that 20 of the 101 issues sit entirely inside `packages/genius_api` and need that package's own `pubspec.yaml` dependency edit.
- Caught and reverted one out-of-scope side effect before it landed: the first `dart format` pass (part of the `unnecessary_library_name` commit's own verify step) swept up `packages/genius_api/lib/ffi/trust_wallet_api_ffi.dart`, a 6325-line machine-generated FFI binding file that `analysis_options.yaml`'s own comment says is "not hand-edited." Reverted with `git checkout --` before staging, keeping the generated-file boundary intact.
- `dart fix --dry-run` reports "Nothing to fix!" in both packages at the end of this plan -- confirmed, not assumed.

## Task Commits

1. **Task 1: Inventory, then apply the syntax and ordering rules** - 7 commits:
   - `533c459` refactor: apply unnecessary_library_name
   - `4b87247` refactor: apply unnecessary_underscores
   - `bca08c8` refactor: apply unnecessary_non_null_assertion
   - `b360da7` refactor: apply use_super_parameters
   - `9c18cac` refactor: apply prefer_final_locals
   - `5d56dfd` refactor: apply directives_ordering
   - (`use_null_aware_elements` -- confirmed 0 live fixes, no commit needed)
2. **Task 2: Apply the const and paint rules** - 5 commits:
   - `e7e183b` refactor: apply unnecessary_const
   - `1cb5a1f` refactor: apply prefer_const_declarations
   - `d6524d2` refactor: apply prefer_const_literals_to_create_immutables
   - `71de065` refactor: apply prefer_const_constructors
   - `3c5e4d4` refactor: apply use_colored_box
3. **Task 3: Write the residue inventory for 22-06** - 3 commits:
   - `fadf7a8` refactor: apply deprecated_member_use (surfaced by the residual dry-run check)
   - `4dea97b` refactor: apply sized_box_for_whitespace (surfaced by the residual dry-run check)
   - `ee2f34e` docs: write the residue inventory for 22-06

**Plan metadata:** (this commit, made after this SUMMARY)

## Files Created/Modified

- `.planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-05-RESIDUE.md` - New. 101-issue tail grouped by rule, per-file counts, mechanical-vs-judgement classification.
- 90 `lib/` and `test/` files - Mechanical rewrites from the 14 `dart fix` rules, one rule per commit (see Task Commits above for the rule-to-commit mapping).
- `packages/genius_api/lib/genius_api.dart`, `packages/genius_api/lib/controllers/sgnus_connection_controller.dart` - `unnecessary_library_name` fix and its incidental format reflow.

## Decisions Made

See `key-decisions` in the frontmatter for the full list with rationale. Highlights: reverting the accidental generated-FFI-file format sweep to preserve the codebase's own generated-file boundary; a real manual review of the 3 `unnecessary_non_null_assertion` removals against the plan's wallet/transaction-data threat-model caveat, concluding they're safe (webview controller, not key material, and the analyzer's flow-promotion reasoning checks out); applying 2 unplanned-but-live-fixable rules because Task 3's acceptance criteria required a genuinely empty `dart fix --dry-run`; and documenting rather than hand-fixing one generated-file analyzer anomaly (`lib/hive_registrar.g.dart`'s stray `directives_ordering` diagnostic).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Reverted an accidental generated-file format sweep**
- **Found during:** Task 1, first commit (`unnecessary_library_name`)
- **Issue:** `dart format packages/genius_api/lib packages/genius_api/test` (run as this rule's own verify step) reformatted `packages/genius_api/lib/ffi/trust_wallet_api_ffi.dart` -- a 6325-line machine-generated FFI binding file that `packages/genius_api/analysis_options.yaml`'s own comment explicitly calls out as "not hand-edited" and excludes from analysis (though not, it turns out, from `dart format`'s scope).
- **Fix:** `git checkout -- packages/genius_api/lib/ffi/trust_wallet_api_ffi.dart` before staging, keeping the file at its pre-format state. Confirmed via `git status --short` that only the two genuinely intended files (`genius_api.dart`, `sgnus_connection_controller.dart`) remained staged.
- **Files modified:** none beyond the revert itself (the file was restored, not further modified)
- **Verification:** `flutter analyze --no-pub` recount (344 → 343, exactly the expected 1-issue drop for `unnecessary_library_name` alone) confirmed no stray change leaked in; `flutter test --no-pub` 512/0.
- **Committed in:** `533c459` (the revert happened before this commit was made, so the commit never contains the generated-file diff)

**2. [Rule 2 - Missing critical functionality, applied per plan's own Task 3 mandate] Applied 2 rules beyond the plan's named 12**
- **Found during:** Task 3's `dart fix --dry-run` residual check
- **Issue:** After all 12 plan-named rules were applied, `dart fix --dry-run` still reported 2 live-fixable issues (`deprecated_member_use` in `lib/components/inputs/gw_select.dart`, `sized_box_for_whitespace` in `lib/components/registration_header.dart`) that the plan's rule list hadn't named.
- **Fix:** Applied both via the same `dart fix --apply --code=<rule>` / format / analyze / test / brace-check / commit pattern used for every other rule, per Task 3's explicit instruction: "Confirm `dart fix --dry-run` reports nothing left to apply in either package. If it does report something, apply it and update the document."
- **Files modified:** `lib/components/inputs/gw_select.dart`, `lib/components/registration_header.dart`
- **Verification:** `flutter analyze --no-pub` 103 → 102 → 101; `flutter test --no-pub` 512/0 after each; `bash tool/check_brace_style.sh --count` 0 after each.
- **Committed in:** `fadf7a8`, `4dea97b`

---

**Total deviations:** 2 auto-fixed (1 Rule 1 bug -- an accidental format sweep of a generated file, caught and reverted before commit; 1 Rule 2 -- 2 additional rules applied per the plan's own explicit Task 3 mandate to leave nothing automatable unfixed)
**Impact on plan:** Both deviations strengthen the plan's own guarantees rather than diverging from them -- the revert protects the generated-file boundary the codebase already documents, and the 2 extra rules are exactly what Task 3 asked for when it said "confirm zero, and if not, fix it." No scope creep beyond what the plan itself required.

## Issues Encountered

- **One analyzer anomaly left undiagnosed by design:** `lib/hive_registrar.g.dart` (a `build_runner`-generated file matching the root `analysis_options.yaml`'s `lib/**/*.g.dart` exclude glob) still surfaces one `directives_ordering` diagnostic in the live `flutter analyze --no-pub` output, even though `dart fix --dry-run` correctly declines to offer a fixer for it (the exclude glob does suppress the *fixer*, just not this one diagnostic). Not hand-edited, since the file is regenerated by `build_runner` and any hand edit would be silently overwritten on the next `build_runner build`. Documented in `22-05-RESIDUE.md` under `directives_ordering` as "out of scope, generated file" with a pointer for 22-06 (or a later plan) to investigate at the generator-invocation or exclude-glob level rather than the generated output itself.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `dart fix --dry-run` reports "Nothing to fix!" in both `geniuswallet` and `packages/genius_api` -- confirmed at the end of this plan, so 22-06 starts from a tree where every mechanical lint opportunity is already exhausted.
- `22-05-RESIDUE.md` is 22-06's direct input: 101 issues across 15 rule groups, each with per-file counts and a mechanical-vs-judgement note, plus a cross-cutting call-out that 20 of the 101 sit entirely inside `packages/genius_api` (needs its own `pubspec.yaml` dependency edit before any of that package's `strict_top_level_inference`/`depend_on_referenced_packages` sites can be addressed).
- 4 files are flagged for 23-02 (the theme migration): `lib/components/loading/gw_spinner.dart`, `lib/components/registration_header.dart`, `lib/submit_job/view/submit_job_screen.dart`, `lib/tokens/token_info_screen.dart` -- each now has a `const` bound to a colour constant that will need the `const` removed again when that site moves to the appearance-aware `context.gw` accessor.
- `tool/check_brace_style.sh --count` remains 0 throughout -- 22-04's gate held under all 14 rule-commits' worth of mechanical reflow.

---
*Phase: 22-codebase-organization-standards-config-dead-code-deletion-th*
*Completed: 2026-07-28*

## Self-Check: PASSED

- FOUND: .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-05-RESIDUE.md
- FOUND: .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-05-SUMMARY.md
- FOUND: lib/web/web_view_mobile.dart
- FOUND: lib/components/loading/gw_spinner.dart
- FOUND commits: 533c459, 4b87247, bca08c8, b360da7, 9c18cac, 5d56dfd, e7e183b, 1cb5a1f, d6524d2, 71de065, 3c5e4d4, fadf7a8, 4dea97b, ee2f34e (all 14 present in git log)
