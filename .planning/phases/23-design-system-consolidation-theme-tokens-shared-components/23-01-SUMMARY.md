---
phase: 23-design-system-consolidation-theme-tokens-shared-components
plan: 01
subsystem: theme
tags: [design-system, theme-tokens, GWColors, parity-test]
dependency-graph:
  requires: []
  provides:
    - "GWColors at full (64-field) name parity with GeniusWalletColors, seeded byte-identically"
    - "context.gw BuildContext accessor with a non-throwing fallback"
    - "test/theme/gw_colors_parity_test.dart — the value-equality proof for the whole colour workstream"
    - "23-01-TOKEN-MAP.md — the mapping 23-02's codemod drives from"
  affects:
    - "23-02 (call-site migration) — the token map is its direct input"
    - "23-04 (demote GeniusWalletColors to private primitives) — blocked on this plan closing the parity gap"
tech-stack:
  added: []
  patterns:
    - "Seed every new GWColors field by referencing the existing GeniusWalletColors const/getter directly, never a retyped hex literal"
    - "Compile-time field-count drift guard via the unnamed constructor's required-parameter list (no dart:mirrors in Flutter)"
key-files:
  created:
    - .planning/phases/23-design-system-consolidation-theme-tokens-shared-components/23-01-TOKEN-MAP.md
    - lib/theme/gw_context_extension.dart
    - test/theme/gw_colors_parity_test.dart
    - .planning/phases/23-design-system-consolidation-theme-tokens-shared-components/deferred-items.md
  modified:
    - lib/theme/gw_colors.dart
decisions:
  - "Excluded statusNeutral from GWColors parity — it carries its own pre-existing locked ponytail note (mode-invariant, fill-only, the badge glyph colour is computed from this fill) — rather than forcing blanket 100% parity over an already-reasoned exception."
  - "Gave each of the 7 legacy value-aliases (gray500, borderBrand, statusInfo, brandGreen/Strong/Muted/Subtle) their own GWColors field rather than deduplicating to their aliased field, per the plan's explicit 'name parity, not renaming' rationale for keeping 23-02's codemod mechanical."
metrics:
  duration: "~40 min"
  completed: 2026-07-29
status: complete
---

# Phase 23 Plan 01: Token parity map + GWColors full-name-parity extension + context.gw accessor Summary

Extended `GWColors` from 21 to 64 fields to reach full name parity with the legacy
`GeniusWalletColors` static palette, added a `context.gw` `BuildContext` accessor with a
non-throwing fallback, and wrote the value-equality parity test that is the substitute for a
golden baseline this phase does not have — all without touching a single call site.

## What Was Built

**Task 1 — Token parity map** (`23-01-TOKEN-MAP.md`): one row per public legacy colour member,
freshly measured rather than trusted from the plan's reference figures.

- **Public members**: measured **65** (not the objective's "~46" estimate — the gap is the 7 pure
  value-aliases plus several Vibrant-v1.2 brand additions the earlier estimate missed).
- **Raw static declarations**: measured **76** total = 65 public + 11 private primitives. The
  plan's own claim ("65 raw statics... including private pairs") does not hold arithmetically;
  recorded the correction rather than silently using the wrong number.
- **Call sites outside `lib/theme/`**: measured **277** (per-symbol `grep -c` with a word
  boundary, summed across all 65 names) vs. the reference figures of 288 (2026-07-28 context) and
  260 (a coarser plan-time grep). Explained as a methodology difference (per-symbol sum vs. a
  blanket `GeniusWalletColors\.` count) rather than papered over.
- **1 deliberate exclusion**: `statusNeutral` — see Decisions below.
- **43 new rows** need a new GWColors field; 21 rows already have one.

**Task 2 — GWColors extended to 64 fields** (`lib/theme/gw_colors.dart`):

- 43 new fields added, each spelled identically to its legacy counterpart.
- Every new field's `light()`/`dark()` seed is a direct reference to the existing
  `GeniusWalletColors.<name>` const/getter — **confirmed no new hex literal was introduced** by
  running `git diff lib/theme/gw_colors.dart | grep -E '^\+' | grep -oE '0x[0-9A-Fa-f]+'`, which
  returned nothing.
- `copyWith` and `lerp` updated to list every field (hand-counted against the 64 field
  declarations).
- Carried over the substantive doc comments: `brandPrimaryOnSurface`'s full WCAG
  measurement + `ponytail:` note, `btnFilter`'s app-wide-consumer note, `gray500`'s alias
  provenance, and the backwards-compatibility-aliases block's origin note.
- `theme.dart` untouched — no `ThemeData.copyWith` introduced.
- New `test/theme/gw_colors_parity_test.dart`: value equality for every new field in both modes
  (via a `setAppearance(mode)` helper mirroring `theme_contrast_test.dart`'s `themeFor`, with
  `addTearDown` restoring dark), explicit coverage of the two genuinely appearance-aware new
  fields (`btnFilter`, `brandPrimaryOnSurface`), explicit assertions for the pre-existing
  documented AA divergence on `textSecondary`/`statusSuccess`/`statusError`, and a compile-time
  field-count drift guard (see below).

**Task 3 — `context.gw` accessor** (`lib/theme/gw_context_extension.dart`):

- `BuildContext.gw` returns `Theme.of(this).extension<GWColors>() ?? GWColors.dark()` —
  falls back rather than null-asserting, so a bare `MaterialApp` host (several existing widget
  tests pump one without the app's theme) renders wrong instead of crashing.
- Documented against caching (must be read inside `build`).
- No existing `BuildContext` extension named `gw` — checked via `grep "extension .* on BuildContext"` — so no collision.
- Two new parity-test cases added to the same file: `context.gw` matches
  `Theme.of(context).extension<GWColors>()` under the real theme, and falls back without
  throwing under a bare `MaterialApp`.

## Field-count drift guard — how it works

Flutter has no `dart:mirrors`, so a runtime reflection-based field count is not available. The
guard instead exploits the unnamed constructor's `required` parameters: the parity test
constructs a `const GWColors(...)` literal listing exactly the 64 expected field names. If a
field is ever added to the class without updating this list (or vice versa), the call becomes a
compile error (missing required argument / undefined named parameter) — which fails
`flutter analyze` and the test file's own compilation, not just a runtime assertion. This is
stronger than a runtime count check would be.

## Deviations from Plan

### Auto-fixed / handled issues

**1. [Rule 4-adjacent judgement call] `statusNeutral` excluded from parity, not added**
- **Found during:** Task 1 (reading `genius_wallet_colors.dart` in full, per the task's own
  instruction to read comments, not just declarations).
- **Issue:** The plan's must-have says "every public colour name... also available on the theme
  extension." `statusNeutral` (line 214-228 of `genius_wallet_colors.dart`) carries its own
  pre-existing `ponytail:` note stating it is "deliberately NOT added to the GWColors extension"
  because the transaction badge's glyph colour is computed *from* this fill, and duplicating it
  as a hand-maintained appearance-aware token would fork that derivation. Its own upgrade path
  ("promote to GWColors... if a text consumer ever appears") has not triggered.
- **Resolution:** Respected the existing, reasoned exception rather than overriding it for
  blanket parity. Documented in the token map's "Excluded" section with the rationale and the 3
  call sites that stay on the legacy path. This is a considered, recorded gap, not an oversight —
  consistent with the project's own precedent of recording overrides rather than a cosmetic patch
  (PROJECT.md, Phase 5 closure).
- **Files:** `23-01-TOKEN-MAP.md` (documented, no code change).

**2. [Scope-boundary] Two pre-existing, unrelated issues logged rather than fixed**
- **Found during:** Task 2/3 final gate runs (`dart format --set-exit-if-changed`,
  `tool/verify_additive_boundary.sh`).
- **Issue:** `dart format` flags 5 files outside `lib/theme/`/`test/theme/`
  (`lib/bloc/app_state.dart`, `lib/dashboard/compute/compute_state.dart`, and 3 compute test
  files) as needing reformatting; `verify_additive_boundary.sh` reports pre-existing duplicate
  private class names (`_Section`, `_SplashState`, `_TimeframeTab`, `_TimeframeTabState`) and a
  standing `WIRE-02` marker in `global_swap_fab_host.dart`. None of these files were touched by
  this plan (confirmed via `git status --short` showing only the 4 files in scope).
- **Resolution:** Logged to `deferred-items.md` per the scope-boundary rule rather than fixed.
- **Files:** `.planning/phases/23-.../deferred-items.md` (new).

### Not performed: live appearance-toggle walk

The plan's verification list item 6 and Task 3's acceptance criteria ask for a live app launch
with a dark → light → dark toggle on the dashboard. This was **not performed** in this execution
— there is no interactive session to observe the running app during autonomous execution. In its
place, the following equivalent guarantees were established and are recorded here explicitly
rather than silently substituted:

- **Zero call sites moved** (verified: `git status --short` / `git diff --name-only` across all
  three commits touch only `lib/theme/`, `test/`, `.planning/`) — nothing in the running app
  reads any of the 43 new fields or `context.gw` yet, so there is no code path that could paint
  differently.
- `GWColors.light()`/`.dark()` — the exact factories `theme.dart#getThemeData()` calls on every
  appearance toggle — run with debug-mode asserts enabled inside `flutter test` (matching a debug
  build), and are exercised across hundreds of pre-existing widget tests
  (`theme_contrast_test.dart`, `nav_chip_style_test.dart`, `gw_card_hover_test.dart`, and others)
  in both `GWAppearanceMode` values, all passing after this change.
- The new parity test explicitly re-asserts every one of the 43 new fields' values in both modes,
  including the two genuinely appearance-aware ones.

This is recorded as a known gap, not claimed as done — per the project's stated preference for an
honest recorded gap over a cosmetically-clean but unverified claim.

## Verification

| Gate | Result |
|---|---|
| `flutter analyze --no-pub` | **No issues found! (exit 0)** |
| `bash tool/check_brace_style.sh --count` | **0** |
| `dart format --output=none --set-exit-if-changed lib test` | 5 pre-existing, out-of-scope files flagged (see Deviations); the 3 files this plan touched are clean |
| `flutter test --no-pub` | **693 pass / 0 fail** (baseline 682 + 11 new parity/accessor tests) |
| `tool/check_no_new_key_logging.sh` on touched files | OK: no new key logging |
| `bash tool/check_onboarding_seed_safety.sh` | PASSED — all six Section 3 checks hold |
| `bash tool/verify_additive_boundary.sh` | Pre-existing failures unrelated to `lib/theme/` (see Deviations) |
| `git diff --name-only` across all 3 commits | Confined to `lib/theme/`, `test/`, `.planning/` |
| No new hex literal in `gw_colors.dart` | Confirmed via `git diff \| grep 0x` — empty |
| Live appearance toggle | **Not performed** — see "Not performed" above |

## Requirements traceability note

The plan's frontmatter lists `requirements: [ORG-04]`. `.planning/REQUIREMENTS.md` has no `ORG`
category at all (checked categories: Tooling/GSD, Build & Verification/BLD, Design System/DS,
Navigation Shell/NAV, Screen Areas/SCR, Design Gaps/GAP, WIRE, Behavior Preservation/BEH). This
looks like a plan-authoring artifact from Phase 23 planning rather than something this execution
should invent a fix for — `gsd-tools query requirements.mark-complete ORG-04` correctly reported
`not_found`. Recorded here rather than silently skipped.

## Known Stubs

None. This plan adds unused capability (no call site reads it yet); that is the intended
"changes no call site" invariant, not a stub.

## Threat Flags

None. All three STRIDE items in the plan's threat model that require action in this plan
(T-23-01 seeded-value tampering, T-23-02 vacuous parity test, T-23-03 lost WCAG rationale,
T-23-04 `context.gw` DoS-by-throw, T-23-06 leaked appearance flip) were mitigated exactly as
specified — see Verification above and the parity test's coverage.

## Self-Check: PASSED

All 6 created/modified files confirmed present on disk; all 3 task commits (`916b70c`, `3390580`,
`0b21b4d`) confirmed present in `git log --oneline --all`.
