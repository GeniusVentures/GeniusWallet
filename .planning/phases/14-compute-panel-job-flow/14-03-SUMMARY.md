---
phase: 14-compute-panel-job-flow
plan: 03
subsystem: ui
tags: [dart, flutter, dashboard, clipboard, status-dot, component-extraction]

# Dependency graph
requires:
  - phase: 14-compute-panel-job-flow
    provides: "14-01's ComputeDotRole enum and ComputeStatusView view model, which plan 07's call site maps onto GWStatusDot"
provides:
  - "GWStatusDot (lib/components/data/gw_status_dot.dart) - dot + label status row, 6px dot / 5px gap / labelMd w600, min or fill-and-space main-axis sizing, tabular-figure trailing value, 18px line box"
  - "GWCopyRow (lib/components/data/gw_copy_row.dart) - truncated-display / full-clipboard copy row for public on-chain identifiers, whole-cell tap target, promoted per the Phase 23 reversal recorded below"
  - "The Phase 23 GWCopyRow-promotion reversal, recorded with cause, for the Phase 23 executor to read"
affects: [14-04, 14-05, 14-06, 14-07, 14-08, 23]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Component-owns-shape / call-site-owns-semantics split for GWStatusDot: the widget owns geometry and type, the call site owns the dot's colour token and any pill wash - this is what lets one widget serve a coloured pill and a neutral status row"
    - "Display-truncation vs clipboard-content separation pinned by a test comparing against the untruncated INPUT, not the rendered string (T-14-09's mitigation)"
    - "House-style class doc comment (gw_kicker.dart/gw_warning_note.dart pattern): name the forks a component was extracted from with file:line, state which phase owns each un-migrated fork, and (for GWCopyRow) record the cross-phase promotion reversal inline as well as in this SUMMARY"

key-files:
  created:
    - lib/components/data/gw_status_dot.dart
    - lib/components/data/gw_copy_row.dart
    - test/components/gw_status_dot_test.dart
    - test/components/gw_copy_row_test.dart
    - .planning/phases/14-compute-panel-job-flow/14-03-SUMMARY.md
  modified: []

key-decisions:
  - "GWStatusDot's trailing-value main-axis fill uses Expanded(label) + a fixed trailing Text rather than a literal mainAxisAlignment.spaceBetween on two grouped children. Both produce the same visual result (label fills, trailing sits flush at the far end), but Expanded also lets the label ellipsis-truncate under width pressure, which a bare spaceBetween Row would not do without the same Expanded/Flexible wrapper anyway. Chosen for correctness under the 'single line, ellipsis overflow' height-budget rule (14-UI-SPEC.md 1.5.1), not as a deviation from the plan's intent."
  - "GWCopyRow's truncation rule and clipboard behaviour were copied verbatim from token_info_screen.dart's _CopyAddressRowState (re-read at execution time per the plan's own warning that the file has uncommitted modifications and line numbers may have drifted) rather than from transaction_displays.dart's _CopyRow, because the plan named _CopyAddressRow's rule explicitly (first-6/last-6, '...' separator, full value on tap) as the one to preserve."
  - "GWCopyRow's mono style is built inline (bodySm.copyWith(fontFamily: 'JetBrainsMono')) rather than exposed as a shared constant, matching both existing forks - the plan explicitly says 'do not invent a token,' only reuse the value."

patterns-established:
  - "A component doc comment for an approved cross-phase promotion reversal states three things in order: the refusal (with its file:line), why the refusal was correct on the evidence it had, and what changed the answer - so a later reader meets a decision with its reasoning attached rather than an apparent contradiction between two planning documents."

requirements-completed: [CMP-07, CMP-04, CMP-10]

coverage:
  - id: D1
    description: "GWStatusDot renders a 6px dot, 5px gap and labelMd w600 label; sizes to minimum width with no trailing value and fills-and-spaces with one; an absent labelColor yields gw.textPrimary rather than the dot's colour; the row measures exactly 18 logical pixels tall; a trailing value carries FontFeature.tabularFigures()."
    requirement: "CMP-07"
    verification:
      - kind: unit
        ref: "test/components/gw_status_dot_test.dart - all 6 tests"
        status: pass
    human_judgment: false
  - id: D2
    description: "GWCopyRow truncates display to first-6...last-6 only above 12 characters, renders short values whole, always copies the FULL untruncated value to the clipboard on tap, raises a showAppSnackBar confirmation naming the row's own label, and the whole row (not just the glyph) is the tap target."
    requirement: "CMP-04"
    verification:
      - kind: unit
        ref: "test/components/gw_copy_row_test.dart - all 5 tests, including the clipboard-vs-untruncated-input assertion"
        status: pass
    human_judgment: false
  - id: D3
    description: "The GWCopyRow promotion decision (reversing Phase 23's refusal) is recorded both in the component's class doc comment and in this SUMMARY, naming the refusal, why it was correct at the time, and what changed (the bridge-hash row in plan 06 is the third consumer)."
    requirement: "CMP-10"
    verification:
      - kind: other
        ref: "lib/components/data/gw_copy_row.dart class doc comment + '## Cross-phase decision: the GWCopyRow promotion reversal' section below"
        status: pass
    human_judgment: false

duration: ~50min (not machine-timed at task granularity; only the completion timestamp below is a real capture)
completed: 2026-07-29
status: complete
---

# Phase 14 Plan 03: Compute panel shared components (GWStatusDot, GWCopyRow) Summary

**Two components: `GWStatusDot` (18px dot+label status row, the third consumer of a shape shipped twice) and `GWCopyRow` (truncated-display/full-clipboard copy row), the latter promoted on a reversal of Phase 23's earlier refusal, both under `lib/components/data/`.**

## Performance

- **Completed:** 2026-07-29T00:00:00Z (session-local; not independently machine-timed per-task)
- **Tasks:** 2/2 complete
- **Files created:** 5 (2 components, 2 test files, this SUMMARY)
- **Files modified:** 0

**No commits were created.** `AGENTS.md` line 23 ("Do not create commits") is an absolute project rule for this session, and the prompt's own hard constraint 1 repeats it. All work is left staged only in the working tree - see `git status --short` excerpt below.

## Accomplishments

- **`GWStatusDot`** (`lib/components/data/gw_status_dot.dart`): a stateless dot+label row. Adopts the shipped geometry verbatim from the two existing forks - 6px circle, 5px gap, `labelMd` weight 600 - so the widget is a genuine extraction rather than a new invention, and so the row lands at exactly the 18px line box the height budget (14-UI-SPEC.md §1.5.4) depends on. `color` paints only the dot; `labelColor` defaults to `null`, which renders the label in `gw.textPrimary` rather than the dot's hue - the one parameter that lets the same widget serve a coloured-label pill (both existing forks, wrapped in their own wash `Container`) and a neutral-label status row (the compute panel, used bare). `trailingValue` presence switches `mainAxisSize` between `min` (the two pill forks' need) and `max` with the label `Expanded` so it fills and pushes the trailing value flush to the far end (the compute tile's need); the trailing value renders at the same `labelMd` w600 metric with `FontFeature.tabularFigures()` so a ticking percentage does not jitter the label sideways. The label is single-line with ellipsis overflow, matching the "a wrap silently costs 18px" rule.
- **`GWCopyRow`** (`lib/components/data/gw_copy_row.dart`): a stateful label/value row that truncates for display and always copies the full value. Truncation rule copied verbatim from `token_info_screen.dart`'s `_CopyAddressRowState` (re-read at execution time, not trusted from stale line numbers, per the plan's own warning): only above 12 characters, first 6 + `...` + last 6. `shorten` defaults to `true` and only affects display - the clipboard write on tap always uses the full, untruncated `value`, which is the audited security property from Phase 23 (`token_info_screen.dart:993`). Confirmation via `showAppSnackBar(context, '${label} copied')`. Hover rolled with a bare `MouseRegion` + click cursor (no `GWHoverable` import - confirmed absent from the tree per the plan's constraint). `kGWDetailRowPadding` sits inside the `GestureDetector` so the whole grid cell is the tap target, matching `gw_detail_grid.dart:5-15`'s documented reason the grid itself does not pad its rows. Mono treatment is `bodySm.copyWith(fontFamily: 'JetBrainsMono')`, matching both existing forks - no new token invented.
- Both class doc comments follow the house style at `gw_kicker.dart:6-13` / `gw_warning_note.dart:10-13`: naming the forks extracted from with file paths, stating that migrating those forks is deliberately out of this phase's fence and which phases own them, and noting the geometry/behaviour was copied rather than chosen so those future migrations are zero-repaint changes.
- `GWCopyRow`'s class doc comment additionally carries the Phase 23 promotion-reversal record (see the dedicated section below), and the threat-model constraint from T-14-08 (public identifiers only, never key material) is stated explicitly in the doc so a future caller cannot miss it.

## Cross-phase decision: the GWCopyRow promotion reversal

**This reverses Phase 23's refusal, with cause, per the plan's explicit instruction.**

- **The refusal:** Phase 23 re-measured an audit that claimed `GWCopyRow` had three consumers and found only two - `transaction_displays.dart`'s `_CopyRow` and `token_info_screen.dart`'s `_CopyAddressRow` (`23-05-PLAN.md:155-166`). Two occurrences is below this repo's Rule of Three floor (`CLAUDE.md`/`AGENTS.md`: "Two occurrences do not justify a shared component; three do"), so Phase 23 correctly declined the promotion on the evidence it had at the time.
- **Why it was right then:** the floor exists precisely to stop premature abstraction from a boolean-flag-laden shared widget serving two callers that might not actually need to share. At two forks, that risk was real and the refusal was the correct call.
- **What changed:** the bridge-hash row this phase's plan 06 builds (Step 5's terminal state T2, "bridged, not processed") is genuinely the same shape - label, truncated mono value, copy glyph, hover, a `showAppSnackBar` confirmation - which makes it the third occurrence. The floor is now cleared on its own terms, not overridden.
- **Scope of the reversal:** promotion only. This plan does **not** migrate the two existing forks (`_CopyRow` in `transaction_displays.dart`, Phase 12/15's file; `_CopyAddressRow` in `token_info_screen.dart`, Phase 23's own file) onto `GWCopyRow`. Both migrations are filed as pending follow-ups below, and each is a zero-repaint change once undertaken, because `GWCopyRow`'s truncation rule and clipboard behaviour were lifted from those forks verbatim rather than re-derived.
- **Where this is recorded:** in `GWCopyRow`'s class doc comment (so it travels with the code) and here (so the Phase 23 executor, reading this SUMMARY before touching `token_info_screen.dart` again, meets a decision with its reasoning attached rather than an apparent contradiction between two planning documents).

**Pending follow-up filed (not queued to `.planning/todos/pending/` by this agent - migration of the two forks is out of this plan's fence and file-write scope; noting it here per the plan's explicit instruction to "file a pending todo... so the follow-up is queued rather than remembered"):**
- Migrate `transaction_displays.dart`'s `_CopyRow` onto `GWCopyRow` (Phase 12/15's file).
- Migrate `token_info_screen.dart`'s `_CopyAddressRow` onto `GWCopyRow`, including its leading glyph slot, which `GWCopyRow` does not currently expose as a parameter (Phase 23's own file - would need a small API addition, an optional leading-icon slot, since `_CopyAddressRow` carries one and `_CopyRow`/`GWCopyRow` do not).

## Task Commits

**None.** Per `AGENTS.md` line 23 and this session's hard constraint 1, no commits, staging, or any git-state mutation was performed. All four created source/test files remain as untracked, uncommitted changes in the working tree for the orchestrator/user to commit.

## Files Created

- `lib/components/data/gw_status_dot.dart` - `GWStatusDot`, the dot+label status row
- `lib/components/data/gw_copy_row.dart` - `GWCopyRow`, the truncated-display/full-clipboard copy row
- `test/components/gw_status_dot_test.dart` - 6 tests: min-width sizing, fill-and-space sizing, absent-labelColor→textPrimary, 18px height, tabular-figures trailing, default 6px/5px geometry
- `test/components/gw_copy_row_test.dart` - 5 tests: long-value truncation, short-value-whole, full-value-to-clipboard (compared against the untruncated input), label-named confirmation, whole-row tap target
- `.planning/phases/14-compute-panel-job-flow/14-03-SUMMARY.md` - this file

## Decisions Made

See `key-decisions` in the frontmatter for the two implementation-level choices (the `Expanded`-based fill-and-space layout, and re-reading `token_info_screen.dart` live rather than trusting stale line numbers). The one decision with cross-phase weight - the `GWCopyRow` promotion reversal - has its own section above rather than being folded into the frontmatter list, per the plan's explicit instruction to make it discoverable.

## Deviations from Plan

None - Rules 1-4 were never triggered. Both components were built exactly to the plan's `<action>` specification; the only choices made were the ones the plan explicitly delegated (see `key-decisions`), not fixes to something broken or missing.

## Known Stubs

None. Both components are fully wired to real behaviour (real clipboard writes, real hover state, real geometry) with no hardcoded placeholder values. Neither has a call site yet - wiring `GWStatusDot` into the compute panel is plan 07's job and wiring `GWCopyRow` into the job-result terminal states is plan 06's - so there is nothing here that could currently render an empty/mock value to a user.

## Threat Flags

None beyond what the plan's own `<threat_model>` already names. Verified against the register:

- **T-14-08** (clipboard info disclosure) - `GWCopyRow`'s class doc comment states the public-identifiers-only scope constraint explicitly, so a future caller reaching for a clipboard widget for key material will read the warning before misusing this one.
- **T-14-09** (truncation/tampering) - pinned by the test `tapping the row places the FULL value on the clipboard, never the truncated form`, which asserts against `_longValue` (the untruncated input), not against the rendered `0xabcd...cdef01` string - exactly the assertion shape the threat register calls for.
- **T-14-10** (clipboard persistence) - accepted per the threat model; no code change required here.
- **T-14-SC** (package installs) - no packages installed; both components use only Dart/Flutter stdlib (`dart:ui`'s `FontFeature` via `package:flutter/material.dart`, `Clipboard`/`ClipboardData` via `package:flutter/services.dart`) and existing in-repo theme/typography/detail-grid/snackbar helpers.

## Issues Encountered

- **`flutter analyze` baseline moved under this plan, as the prompt warned it would.** At the moment this plan finished, `flutter analyze` reported 1 issue: `The method '_buildAvatar' isn't defined for the type '_AccountDropdownSelectorState' • lib/account/account_dropdown_selector.dart:90` - inside `lib/account/`, which is plan 14-04's exclusive file territory per this session's hard constraint 2, and clearly a mid-edit state from that concurrently-running agent. An earlier measurement during this same session also showed transient errors in `lib/bloc/app_state.dart` (plan 14-02's file) and unused-import warnings in `lib/dashboard/home/view/dashboard_screen.dart` (the chart agent's file) that had already cleared by the next measurement - confirming these are genuinely other agents' in-flight work, not a regression this plan caused. **Neither `gw_status_dot.dart` nor `gw_copy_row.dart` appears in any `flutter analyze` output at any point** - confirmed by grepping the tool's output for both filenames (no matches) at three separate points during execution.
- No issues originating from this plan's own two files or two test files.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `GWStatusDot` and `GWCopyRow` are complete, tested, and ready for plan 07 (the compute panel itself) and plan 06 (the job-result terminal states) to consume directly.
- `GWStatusDot`'s API matches `14-UI-SPEC.md §4.1` exactly: `color`, `label`, `labelColor`, `trailingValue`, `size`, `gap`. Plan 07's call site can map `ComputeDotRole` (from 14-01) to a `Color` at the call site and pass no `labelColor` to get the neutral status-row treatment §2.2's state table specifies.
- `GWCopyRow`'s API matches `14-UI-SPEC.md §4.3` exactly (`label`, `value`, `shorten`), under its promoted public name rather than the spec's originally-proposed private `_JobCopyRow` - the promotion was approved per the reversal recorded above, so plan 06 should import `GWCopyRow` from `lib/components/data/gw_copy_row.dart` rather than building a feature-local widget.
- The two migration follow-ups (transactions' `_CopyRow`, tokens' `_CopyAddressRow`) are named above and NOT queued as files in `.planning/todos/pending/` by this agent, since writing to that directory is outside this plan's declared `files_modified` scope and this session's hard constraints did not grant todo-file write access. Whoever next has write access to `.planning/todos/pending/` should file them from this SUMMARY's "Pending follow-up filed" section.
- **Neither fenced file was touched.** Confirmed via `git status --porcelain` immediately before writing this SUMMARY: `lib/dashboard/home/widgets/transaction_displays.dart`, `lib/banxa/`, and `lib/components/cards/gw_detail_grid.dart` show no changes at all; `lib/tokens/token_info_screen.dart` shows only its pre-existing dirt from before this plan started (recorded in 14-01's SUMMARY as already dirty at phase baseline), not any edit made here.
- No blockers.

## Gate Results (measured by this agent)

- **`flutter analyze`** (full run, this plan's own files only relevant): 0 issues attributable to `lib/components/data/gw_status_dot.dart` or `lib/components/data/gw_copy_row.dart`, confirmed by direct grep for both filenames in the tool's output at three points during execution. The tool's overall issue count fluctuated between 0 and 12 across measurements solely due to concurrent agents' in-flight edits in `lib/bloc/`, `lib/account/`, and `lib/dashboard/home/view/dashboard_screen.dart` - none of which this plan touched or is responsible for.
- **`bash tool/check_brace_style.sh --count`** → `0`, measured after both tasks and again after `dart format`.
- **`flutter test test/components/gw_status_dot_test.dart`** → 6/6 passed.
- **`flutter test test/components/gw_copy_row_test.dart`** → 5/5 passed.
- **`flutter test test/components/`** (this plan's own `<verification>` scope) → 43/43 passed, including all 11 of this plan's new tests alongside every pre-existing test in that directory. No failures, no skips.
- **`git status --porcelain lib/dashboard/home/widgets/transaction_displays.dart lib/banxa/ lib/tokens/token_info_screen.dart lib/components/cards/gw_detail_grid.dart`** → only `lib/tokens/token_info_screen.dart` shows as modified, and that modification pre-dates this plan (14-01's SUMMARY records it as already dirty at phase baseline). No file this plan touched appears in that list.
- **`dart format`** applied to all 4 new files; 2 test files needed reformatting (component files were already correctly formatted on first write), re-verified green after formatting.

## Self-Check

- `[ -f lib/components/data/gw_status_dot.dart ]` → FOUND
- `[ -f lib/components/data/gw_copy_row.dart ]` → FOUND
- `[ -f test/components/gw_status_dot_test.dart ]` → FOUND
- `[ -f test/components/gw_copy_row_test.dart ]` → FOUND
- `flutter test test/components/gw_status_dot_test.dart test/components/gw_copy_row_test.dart` → 11/11 passed (re-confirmed after `dart format`)
- `grep -c "gw_status_dot\|gw_copy_row" <flutter analyze output>` → `0` (confirmed neither file appears in any analyzer issue)

## Self-Check: PASSED

---
*Phase: 14-compute-panel-job-flow*
*Plan: 03*
*Completed: 2026-07-29*
