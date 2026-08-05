# Phase 22: Codebase organization — Context

**Gathered:** 2026-07-28
**Status:** Ready for planning
**Source:** Interactive session (6 parallel audit agents + 6 parallel research agents), decisions
locked via checkpoint questions with the user.

<domain>
## Phase Boundary

Make the codebase's own rules mechanically enforceable, then use that enforcement to collapse
duplication — **without changing behaviour anywhere**.

**In scope:** analyzer/lint config, CI quality gates, brace-style enforcement, dead code deletion,
golden-test baseline, colour token consolidation, shared component extraction.

**Explicitly OUT of scope — belongs to Phase 23:** state ownership (`setState` → cubit), layering
violations, routing changes, the `genius_api` god-class split, error-handling redesign. Anything
touching swap/bridge/transaction-approval behaviour. If a task in this phase starts changing what
the app *does* rather than how the code is *organised*, it belongs in 23.

**Non-negotiable:** every change in this phase is behaviour-preserving. The test suite and the
golden baseline are the evidence.
</domain>

<decisions>
## Implementation Decisions

### Coding standards basis
- Base is **Effective Dart + `flutter_lints`**, NOT the GNUS C++ handbook. The user stated plainly:
  *"we dont need to follow c++ standards if on dart we have others."*
- Carried over from the handbook: the brace rule (below), plus language-agnostic parts — feature
  branch → PR to `develop`, rebase over merge, analyzer-clean + tests-green before commit.
- Dropped, and **inverted in Dart** (a naive "follow the handbook" instruction produces wrong code):
  PascalCase functions, `m_` member prefix, `k` constant prefix, 4-space indent, 120 columns,
  `Get`/`Set` accessor prefixes, Allman braces, all memory/pointer/header rules.

### The brace rule (hard team requirement, from another developer)
- Every `if` gets braces AND the body on its own line. `if (x) { return; }` collapsed on one line is
  NOT acceptable. Same-line `{` is fine — Allman explicitly waived.
- Rationale given: you cannot set a breakpoint on the true-branch otherwise, and a `log()` almost
  always ends up in there later.
- **Enforcement decision: CI gate + one-time auto-fix script.** `custom_lint` was offered and
  declined; it is also retired as of early 2026 (superseded by first-party
  `analysis_server_plugin`). No built-in lint can express this rule — see RESEARCH.md.

### Lint ruleset
- **Decision: stay on `flutter_lints`, add ~14 targeted rules**, each justified by a real audit
  finding. `very_good_analysis` (206 rules) was presented and declined as too large a backlog for
  this phase.
- Already applied this session in `analysis_options.yaml`. Three rules explicitly declined with
  reasons recorded in-file: `public_member_api_docs`, `prefer_single_quotes`,
  `avoid_catches_without_on_clauses` (measured at 64 sites, none auto-fixable, most broad catches at
  a boundary are legitimate).

### CI rollout
- **Decision: exclude generated code → fix the remainder → turn the gate on last.** Nothing is
  blocked while cleaning. Rejected: gating immediately with a baseline file (leaves the backlog
  permanently invisible), and gating with `--no-fatal-infos` (conflicts with the planned
  `@Deprecated` migration path — see flutter#154922).

### Colours
- **Do NOT delete `GeniusWalletColors`.** Demote it to the private primitive layer; keep `GWColors`
  as the semantic layer. This is the Material 3 primitive→semantic→component model.
- Migration is a mechanical prefix rewrite with field-for-field parity, so every commit ships.
- Use `Workiva/dart_codemod` (AST-based) for bulk call-site rewrites, not regex.

### Component extraction
- **Rule of Three: only extract at 3+ call sites.** `GWPriceBlock` and `GWStatRail` are DEFERRED
  (2 sites each). `GWTimeframeSegment` is extracted as a named exception — it is a
  character-identical 150-line duplicate, so there is no abstraction to guess at.
- Extract as real `StatelessWidget`s, never `_buildFoo()` helper methods.

### Ordering (changed after research)
Theme consolidation comes **before** component extraction, so extracted components are born on
tokens instead of needing a second pass. Golden tests come before both, as the safety net.

### Coverage
Patch-coverage gating (`project: auto` + `patch: 80%`), not VGV's 100%. A 100% gate on an existing
40k-LOC app is a big-bang backfill.

### Claude's Discretion
- Exact plan/task decomposition and wave assignment.
- Which of the 85 pre-existing analyzer issues to fix by hand vs `dart fix`.
- Golden-test file organisation and which primitives get goldens first.
- Whether `.editorconfig` and lefthook hooks land in this phase or are deferred.
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project standards
- `AGENTS.md` — the lazy-senior-developer ladder, the parallel-session rules, and the new
  `## Dart coding standards` section added this session. **`CLAUDE.md` now imports it via
  `@AGENTS.md`** (it previously held the bare text `AGENTS.md`, which is not an import and loaded
  nothing).
- `analysis_options.yaml` — the 14 targeted rules and the three declined ones, with rationale.
- `packages/genius_api/analysis_options.yaml` — FFI/proto excludes. **These MUST live here, not in
  the root file**: the analyzer resolves the nearest options file per source file.

### Phase artifacts
- `.planning/ROADMAP.md` § Phase 22 — the five workstreams, measured baseline table, locked decisions.
- `.planning/phases/22-.../22-RESEARCH.md` — external research backing every decision above.

### Existing design system (do not re-derive)
- `lib/theme/` — 13 files. `GWColors` (ThemeExtension, 21 fields), `GeniusWalletColors` (~60 static
  members), `GeniusWalletConsts` (spacing/radii), `GeniusWalletTypography`, `GWDecorations`,
  `GWAppearance`.
- `lib/components/` — the healthy reused core: `GWEmptyState` (12 uses), `GWSelectRow` (10),
  `GWKicker` (10), `GWSectionTitle` (10), `GWPageHeader` (9), `GWErrorState` (8), `GWFocusRing` (7).
- `tool/` — three existing security gates not yet wired into CI:
  `check_no_new_key_logging.sh`, `check_onboarding_seed_safety.sh`, `verify_additive_boundary.sh`.
</canonical_refs>

<specifics>
## Specific Ideas

**Measured baseline, 2026-07-28 — verified by running the commands, not estimated:**

| Metric | Value |
|--------|-------|
| `flutter test --no-pub` | 512 pass / 1 fail |
| `flutter analyze --no-pub` at session start | **exit 1**, 408 issues |
| after FFI/proto exclude fix (applied this session) | **85** |
| after adding 14 targeted rules (applied this session) | **319** |
| of which auto-fixable by `dart fix --apply` | **181** |
| Brace-less `if` | 192 across 72 files (`else`/`for`/`while` = 0) |
| Dead code | ~1,400 LOC, 13–14 never-imported files |
| Mode-breaking `Colors.white/black/grey` | 114 sites, ~50 files |
| `Theme.of(context).extension<GWColors>()` lookups | 128 sites, 81 files |

**Environment gotchas the executor will hit:**
- The Flutter SDK is **off `PATH`**. It lives at
  `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin`. This is the origin of a long-standing
  false belief that `flutter test` does not compile.
- `flutter analyze` exits non-zero on *infos* (`fatal-infos` and `fatal-warnings` both
  `defaultsTo: true` in flutter_tools) — unlike `dart analyze`. Do not expect it to pass.
- A running `genius_wallet.exe` locks the DLL and fails the next build; kill it first.

**Named targets:**
- The single failing test is `test/local_wallet_storage_test.dart` — 240 lines fully commented out,
  so it has no `main`. Deleting the file makes the suite green.
- 9 hand-written production widgets are named `*.g.dart` and are therefore excluded from the
  analyzer entirely: `wallets_overview`, `wallet_information`, `wallet_preview`,
  `registration_header`, `incorrect_pin`, `recoveryword`, `genius_back_button`, and both
  `continue_button/isactive_*`. Any lint config is blind to them until renamed.
- `google_fonts` is a dead dependency — Inter is bundled; the only reference in `lib/` is
  `main.dart:139` disabling runtime fetching.
- `toast_widget.dart` is a fully inverted light-mode palette. `gw_button.dart` is a design-system
  component that hardcodes `Colors.white`. `lib/reown/` has 74 violations across 6 files.
- `swap_settings_drawer.dart:286` forks `GWWarningNote` as a private `_Message`, losing the
  documented light-mode amber contrast fix at `gw_warning_note.dart:17-21` — an a11y regression.
- `lib/dev/design_gallery_screen.dart` is the ONLY consumer of `GWTokenRow`,
  `GWGradientBorderCard`, and `GWLoadingState`. Exclude the gallery when judging component liveness
  or it masks dead code.

**Extraction targets (call-site counts):** `GWAppBar` 7 · `GWChangePill` 7 · `GWCopyRow` 3 forks +
8 raw `Clipboard.setData` · `GWHoverable` 9 · `GWTimeframeSegment` 2 (named exception).
`GWScreen` already exists and is used exactly once while 20+ screens hand-roll `Scaffold`.
</specifics>

<deferred>
## Deferred Ideas

- `GWPriceBlock` and `GWStatRail` — 2 call sites each, below the Rule of Three threshold.
- `very_good_analysis` adoption — revisit once the current backlog is at zero.
- `analysis_server_plugin` custom rule for the brace rule and for banned raw colours — the CI gate
  covers it for now; revisit if editor feedback becomes worth the maintenance.
- Widgetbook — the repo already has `lib/dev/design_gallery_screen.dart`, which is the documented
  "cheaper 80%" option. No new dependency needed.
- Migrating `mockito` → `mocktail`. Current stack works; not worth the churn this phase.
- `bloc_lint` — its `avoid_flutter_imports` rule would catch `pin_cubit.dart:3`, but `bloc_tools` is
  still pre-release (`0.1.0-dev.24`).
- **Two live findings deliberately NOT scoped here** (raised to the user, awaiting their call):
  the unguarded dev routes at `router.dart:199,203`, and the no-op swap at `swap_screen.dart:293`
  that still writes a completed transaction to Hive. Both are Phase 23 or a hotfix, not this phase.
</deferred>

---

*Phase: 22-codebase-organization*
*Context gathered: 2026-07-28*
