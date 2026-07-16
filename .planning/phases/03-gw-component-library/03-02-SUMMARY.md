---
phase: 03-gw-component-library
plan: 02
subsystem: ui
tags: [flutter, gw-components, port, icon, buttons, cards, inputs, animated-number]

# Dependency graph
requires:
  - phase: 03-01
    provides: mobile_scanner/shimmer dependencies, noise.png asset, tool/verify_additive_boundary.sh guard + tool/shadow-baseline.txt
provides:
  - "GWIcon — unified icon API (material/svg/png named constructors)"
  - "GWButton — 6 variants, .icon constructor, 3 sizes, full state set"
  - "GWSwapFab — standalone circular FAB, unwired"
  - "GWCard, GWGradientBorderCard, GWTokenRow, GWWalletCard — the four card primitives"
  - "GWTextField, GWPasswordField, GWSearchField (one file), GWSelect, GWCheckbox, GWSwitch — the four input primitives"
  - "GWAnimatedNumber — tabular-figure balance counter"
affects: [03-07, 03-09, 03-10]

tech-stack:
  added: []
  patterns:
    - "Standing port protocol (verbatim copy, cmp-verified byte-identical, no improvement/consolidation/renaming) applied per-file across all 12"

key-files:
  created:
    - lib/components/gw_icon.dart
    - lib/components/buttons/gw_button.dart
    - lib/components/buttons/gw_swap_fab.dart
    - lib/components/cards/gw_card.dart
    - lib/components/cards/gw_gradient_border_card.dart
    - lib/components/cards/gw_token_row.dart
    - lib/components/cards/gw_wallet_card.dart
    - lib/components/inputs/gw_text_field.dart
    - lib/components/inputs/gw_select.dart
    - lib/components/inputs/gw_checkbox.dart
    - lib/components/inputs/gw_switch.dart
    - lib/components/data/gw_animated_number.dart
  modified: []

key-decisions:
  - "gw_token_row.dart ported to cards/, not data/ — DESIGN_SYSTEM.md §5.2's table is stale; the verified source path (and this plan's own instruction) is cards/gw_token_row.dart"
  - "gw_ai_fab.dart excluded per plan — imports lib/ai/ which is WIRE-02 out of scope for this milestone"

requirements-completed: [DS-02]

coverage:
  - id: D1
    description: "All 12 core primitive files ported byte-identical (cmp-verified) from the reference worktree to their verified paths"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "cmp against reference worktree for all 12 files — all IDENTICAL"
        status: pass
    human_judgment: false
  - id: D2
    description: "flutter analyze reports 0 errors across all three task commits (34 pre-existing info/warnings baseline preserved, +5 new info-level lints from the ported files themselves — no errors introduced)"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "flutter analyze lib — 0 errors after Task 1 (34 issues), Task 2 (36 issues), Task 3 (39 issues); explicit grep for '^ *error' returned none each time"
        status: pass
    human_judgment: false
  - id: D3
    description: "tool/verify_additive_boundary.sh exits 0 after every task commit — no shadow-name collision, no new unjustified duplicate class, no WIRE- marker"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh — PASSED (exit 0) after Task 1, Task 2, and Task 3"
        status: pass
    human_judgment: false
  - id: D4
    description: "Port is purely additive — git diff across the plan's 3 commits shows 12 files created, 1518 insertions, 0 modifications, 0 deletions; no collision file touched"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "git diff --diff-filter=M and --diff-filter=D against lib/ across the plan's commit range — both empty"
        status: pass
    human_judgment: false
  - id: D5
    description: "Nothing reachable from main.dart imports any of the 12 files — the only cross-reference is GWWalletCard's internal import of GWCard, both within this same plan's set"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "grep -rl for all 12 files' import paths across lib/ — only lib/components/cards/gw_wallet_card.dart (importing gw_card.dart) matched"
        status: pass
    human_judgment: false
  - id: D6
    description: "Visual/functional walk through the running app confirming zero regression and (once consumed) correct rendering"
    human_judgment: true
    rationale: "No way to observe a native Windows window from this agent. Nothing imports the 12 files yet, so there is nothing to visually verify this plan — deferred to plan 03-09's gallery walk per the plan's own <verify> human-check note on every task, and to 03-10's phase walk for the negative (nothing-changed) observation."
---

# Phase 3 Plan 02: Core Primitives Summary

**Ported all 12 core `gw_*` primitives — icon API, buttons, cards, inputs, animated number — byte-identical from the design branch, purely additive, analyze-clean, guard-clean, and unconsumed by any reachable code path.**

## Performance

- **Duration:** 3 min
- **Started:** 2026-07-16T20:36:18Z
- **Completed:** 2026-07-16T20:39:31Z
- **Tasks:** 3/3
- **Files modified:** 12 (12 created, 0 modified)

## Accomplishments
- `lib/components/gw_icon.dart` — `GWIcon`, unified icon API with `.material`/`.svg`/`.png` named constructors, cmp-verified byte-identical to source
- `lib/components/buttons/gw_button.dart` — `GWButton`, 6 variants + `.icon` constructor, 3 sizes, full state set, cmp-verified byte-identical
- `lib/components/buttons/gw_swap_fab.dart` — `GWSwapFab`, ported standalone and unwired per plan (its only source-branch caller, `global_swap_fab_host.dart`, is Phase-4 scope)
- `gw_ai_fab.dart` correctly excluded — confirmed absent, per plan's WIRE-02 exclusion
- `lib/components/cards/gw_card.dart`, `gw_gradient_border_card.dart`, `gw_token_row.dart`, `gw_wallet_card.dart` — all four cards ported byte-identical; `gw_token_row.dart` landed at the verified `cards/` path (not the doc-drifted `data/` path); `gw_wallet_card.dart`'s import of `gw_card.dart` resolves within this plan
- `lib/components/inputs/gw_text_field.dart` (three classes: `GWTextField`, `GWPasswordField`, `GWSearchField`), `gw_select.dart`, `gw_checkbox.dart`, `gw_switch.dart` — all four inputs ported byte-identical, all three text-field classes confirmed present
- `lib/components/data/gw_animated_number.dart` — `GWAnimatedNumber`, ported byte-identical
- `flutter analyze lib` reported 0 errors after every task commit (34 → 36 → 39 total issues, all info/warning-level; the +5 delta across the three commits comes from the newly-landed files' own lint surface — e.g. an `unnecessary_underscores` info in `gw_token_row.dart` — not touched, per the "do not improve" port protocol)
- `bash tool/verify_additive_boundary.sh` exited 0 after every task commit
- Confirmed via `git diff --diff-filter=M/D` across the plan's full commit range: 0 modified files, 0 deleted files, 12 created files, 1518 insertions — purely additive
- Confirmed via `grep -rl` across all of `lib/` that nothing outside this plan's own 12 files imports any of them (the sole cross-reference, `gw_wallet_card.dart` → `gw_card.dart`, is internal to this plan's set) — the primitives remain fully unconsumed as required

## Task Commits

Each task was committed atomically:

1. **Task 1: Port the icon API and the two buttons** - `de7795c` (feat)
2. **Task 2: Port the four cards** - `7bb83ae` (feat)
3. **Task 3: Port the four inputs and the animated number** - `5415a45` (feat)

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Created/Modified
- `lib/components/gw_icon.dart` - unified icon API (material/svg/png constructors)
- `lib/components/buttons/gw_button.dart` - GWButton, 6 variants + icon constructor
- `lib/components/buttons/gw_swap_fab.dart` - GWSwapFab, standalone unwired circular FAB
- `lib/components/cards/gw_card.dart` - GWCard default container
- `lib/components/cards/gw_gradient_border_card.dart` - GWGradientBorderCard hero card
- `lib/components/cards/gw_token_row.dart` - GWTokenRow token list row (landed at cards/, correcting doc drift)
- `lib/components/cards/gw_wallet_card.dart` - GWWalletCard wallet summary row, builds on GWCard
- `lib/components/inputs/gw_text_field.dart` - GWTextField/GWPasswordField/GWSearchField (3 classes, 1 file)
- `lib/components/inputs/gw_select.dart` - GWSelect<T> dropdown
- `lib/components/inputs/gw_checkbox.dart` - GWCheckbox with tristate support
- `lib/components/inputs/gw_switch.dart` - GWSwitch
- `lib/components/data/gw_animated_number.dart` - GWAnimatedNumber balance counter

## Decisions Made
- `gw_token_row.dart` ported to `cards/gw_token_row.dart`, not `data/gw_token_row.dart` — following the plan's explicit correction of `DESIGN_SYSTEM.md` §5.2's stale doc table, and verified against the actual reference worktree source path
- `gw_ai_fab.dart` deliberately not ported (plan-directed exclusion, WIRE-02 — `lib/ai/` out of scope for this milestone)

## Deviations from Plan

None - plan executed exactly as written. All 12 files ported byte-identical (cmp-verified against the reference worktree, not just "looks right"). No hive/hive_ce adaptation needed (verified: none of the 12 files imports storage). No WIRE- markers found in any of the 12 files. Every import resolves either to a Phase 2 token file already on develop or to another file landed within this same plan (`gw_wallet_card.dart` → `gw_card.dart`).

## Issues Encountered

None.

## User Setup Required

None for immediate action. These are Dart-only additions with no `pubspec.yaml` change, so the user's running debug session **can** pick them up with hot reload (`r`) — but there is nothing to see, because nothing in the app imports any of the 12 files yet (verified above: the only importer is `gw_wallet_card.dart` importing `gw_card.dart`, both new, both unconsumed by anything else). The user does not need to do anything for this plan specifically; the first observable proof of these primitives is plan 03-09's gallery walk, and the negative "nothing changed" observation is folded into plan 03-10's phase walk (per this plan's own `<verification>` section).

## Next Phase Readiness
- 12/12 of this plan's files landed: `flutter analyze` 0 errors, additive-boundary guard green, purely additive diff (0 modified/deleted), zero consumers outside the set itself.
- Combined with 03-01, 14 of the phase's 50 in-scope files are now on develop.
- No blockers. Plan 03-03 through 03-06 continue the same standing port protocol for the remaining 38 files (feedback/state, layout, effects, specialist/QR, and the 9 Parabeac-generated `.g.dart` files + `custom/` siblings).
- Outstanding for the human: nothing plan-specific. The visual proof of these 12 primitives is deferred to plan 03-09's gallery walk (§5 of the UI-SPEC), where `design_gallery_screen.dart` gets extended with sections for `GWTokenRow`, `GWWalletCard`, and the rest.

---
*Phase: 03-gw-component-library*
*Completed: 2026-07-16*

## Self-Check: PASSED

All 12 created files confirmed present on disk. All 3 task commits (`de7795c`, `7bb83ae`, `5415a45`) confirmed present in `git log --oneline --all`.
