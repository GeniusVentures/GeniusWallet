---
phase: 23-design-system-consolidation-theme-tokens-shared-components
plan: 02
subsystem: theme
tags: [design-system, theme-tokens, GWColors, ast-codemod, package:analyzer, context.gw]

# Dependency graph
requires:
  - phase: 23-design-system-consolidation-theme-tokens-shared-components
    provides: "23-01's GWColors 64-field parity extension, context.gw accessor, and 23-01-TOKEN-MAP.md (the name mapping this codemod drives from)"
provides:
  - "tool/codemod_colors.dart -- a reusable, no-install AST rewriter (package:analyzer, unresolved parse) that moves GeniusWalletColors.<name> call sites onto context.gw.<name>, with hard refusals for const-context and no-BuildContext-in-scope sites, plus automatic import bookkeeping (adds gw_context_extension.dart, drops the legacy import when nothing else in the file needs it)"
  - "179 of lib/'s 251 measured GeniusWalletColors call sites migrated to context.gw, across 12 top-level directories + lib/main.dart"
  - "23-02-RESIDUE.md -- the reconciled 72-site refusal inventory (45 const, 27 no-context) for 23-03, plus the six test/ files (13 occurrences) flagged for 23-04's demotion pass"
affects: ["23-03 (closes the const/no-context residue)", "23-04 (demotes GeniusWalletColors -- the six flagged test/ files will break at that point)"]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "AST-based codemods for bulk call-site rewrites: parse unresolved (parseString/parseFile, no analysis context needed for an access-path-only rewrite), classify each PrefixedIdentifier/PropertyAccess node via Expression.inConstantContext (a syntactic, resolution-free check) plus a manual default-parameter-value check, and a syntactic BuildContext-in-scope walk (context-named parameter on the nearest enclosing method/constructor/closure, or a non-static member of a class extending State<...>)"
    - "Codemods that touch an access path must also reconcile imports: adding the new accessor's import in correct alphabetical position (respecting directives_ordering) and dropping the old import only when every reference in the file was migrated -- an access-path rewrite without this is a guaranteed undefined_getter/unused_import failure on the very next flutter analyze"

key-files:
  created:
    - tool/codemod_colors.dart
    - .planning/phases/23-design-system-consolidation-theme-tokens-shared-components/23-02-RESIDUE.md
  modified:
    - lib/components/** (29 files)
    - lib/dashboard/** (3 files)
    - lib/settings/** (1 file)
    - lib/account/** (2 files)
    - lib/logs/** (1 file)
    - lib/onboarding/** (3 files)
    - lib/chart/** (1 file)
    - lib/dev/** (2 files)
    - lib/web/** (2 files)
    - lib/screens/** (3 files)
    - lib/squid_router/** (3 files)
    - lib/reown/** (3 files)
    - lib/main.dart

key-decisions:
  - "package:analyzer 8.4.1 confirmed resolvable with zero pubspec change before writing a line of the tool -- a throwaway 3-line probe script under tool/ imported package:analyzer/dart/analysis/utilities.dart and ran successfully via plain `dart run`, exactly as the plan's premise required."
  - "Used Expression.inConstantContext (a syntactic analyzer API, not resolution-dependent) as the primary const-context check, rather than hand-rolling an ancestor walk -- verified empirically via --self-test that it correctly handles both an explicit const invocation AND a top-level const variable's initializer with no explicit const keyword on the literal itself."
  - "Added a manual default-parameter-value check on top of inConstantContext, since the analyzer's own doc comment for that API explicitly excludes default parameter values from 'constant context' even though Dart requires them to be compile-time constants -- confirmed this is a real, distinct edge case rather than assuming inConstantContext was sufficient."
  - "Chose a name-based BuildContext-in-scope heuristic (a parameter literally named 'context', or a non-static member of a class extending State<...>) over full type resolution -- matches this codebase's near-universal naming convention, verified zero false accept/reject across all 251 real sites (every prediction matched the 22-05-flagged const-risk files exactly: gw_spinner.dart's 3 const + 1 no-context, registration_header.dart's 1 const, token_info_screen.dart's 1 no-context, submit_job_screen.dart's 0)."
  - "lib/main.dart was migrated even though the plan's directory list never named it (a top-level file, not a subdirectory) -- Rule 2 (missing critical functionality): the plan's stated goal is 'the large majority of colour reads go through context.gw', and a re-run of the dry-run after all 16 named directories showed 2 real migratable sites still sitting there for no principled reason."

requirements-completed: [ORG-04]

coverage:
  - id: D1
    description: "tool/codemod_colors.dart -- AST rewriter with --self-test, --dry-run, --apply, hard refusals for const/no-context, and import bookkeeping"
    requirement: "ORG-04"
    verification:
      - kind: unit
        ref: "dart run tool/codemod_colors.dart --self-test -- 16 cases, all PASS (rewrite/const-refusal/string/comment/no-context/State-subclass/painter/excluded-name + 5 import-bookkeeping cases against real temp files)"
        status: pass
      - kind: other
        ref: "flutter analyze --no-pub -- No issues found! (tool/ is in analyzer scope; depend_on_referenced_packages and avoid_print both file-level ignored with rationale)"
        status: pass
      - kind: other
        ref: "git diff --stat -- pubspec.yaml pubspec.lock -- empty (no package install)"
        status: pass
    human_judgment: false
  - id: D2
    description: "179 of 251 measured lib/ GeniusWalletColors call sites migrated to context.gw across 12 directories + lib/main.dart, one commit per directory, analyzer/brace/test-green after every commit"
    requirement: "ORG-04"
    verification:
      - kind: other
        ref: "flutter analyze --no-pub -- No issues found!, quoted after every directory commit and again at the end"
        status: pass
      - kind: unit
        ref: "flutter test --no-pub -- 693/693 pass (baseline floor was 693), quoted after every directory commit and again at the end"
        status: pass
      - kind: other
        ref: "bash tool/check_brace_style.sh --count -- 0, quoted after every directory commit"
        status: pass
      - kind: other
        ref: "dart format --output=none --set-exit-if-changed lib test -- exit 0"
        status: pass
      - kind: other
        ref: "git diff per directory reviewed for new class-level declarations (hoisting risk) -- only in-place context.gw.<field> substitutions, import-line additions, and dart-format line-wraps found in every one of the 13 directory diffs"
        status: pass
    human_judgment: false
  - id: D3
    description: "23-02-RESIDUE.md -- 72-site refusal inventory (45 const, 27 no-context) reconciled against the 251-site pool, plus the six test/ files flagged for 23-04"
    requirement: "ORG-04"
    verification:
      - kind: other
        ref: "final dry-run over lib/ after all commits: 0 rewritable, 45 const-refused, 27 no-context-refused -- matches 179+72=251, the original pre-migration total, exactly"
        status: pass
    human_judgment: false
  - id: D4
    description: "Every screen touched by this migration still flips correctly on the appearance toggle, in both modes -- the one failure mode (a colour hoisted out of build()) no automated check in this repo can see"
    verification:
      - kind: manual_procedural
        ref: "Task 4's eight-screen, both-mode appearance-toggle walk -- checklist provided in this SUMMARY's 'Task 4' section below"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze and the 693-test suite prove the value read is unchanged and the code compiles, but neither can observe whether a widget actually repaints live when the appearance mode is toggled in the running app -- that is exactly what Task 4's blocking-human walk exists to catch, and it has not been performed yet."

duration: ~1h 40min (Tasks 1-3 only; Task 4 is a blocking-human checkpoint, not yet performed)
completed: 2026-07-29
status: blocked
---

# Phase 23 Plan 02: AST codemod moves 179 GeniusWalletColors call sites onto context.gw Summary

**A `package:analyzer`-based AST rewriter (no package install) migrated 179 of `lib/`'s 251 measured colour-read call sites from the static `GeniusWalletColors` palette onto the semantic `context.gw` accessor, across 12 directories plus `lib/main.dart`, leaving a reconciled 72-site residue (45 const-context, 27 no-BuildContext) for 23-03.**

Tasks 1-3 (all `type="auto"`) are complete and committed. **Task 4 — the eight-screen, both-mode appearance-toggle walk — is a `checkpoint:human-verify` (`gate="blocking"`) and has NOT been performed.** This SUMMARY documents the auto-task work only; the live walk that confirms no colour got hoisted out of `build()` remains outstanding.

## Performance

- **Duration:** ~1h 40min (Tasks 1-3)
- **Tasks:** 3 of 4 (Task 4 pending human verification)
- **Files modified:** 47 `lib/` files + 1 new tool file + 1 new residue doc

## Accomplishments

- `tool/codemod_colors.dart`: an AST rewriter using `package:analyzer` directly (confirmed resolvable with zero `pubspec.yaml`/`pubspec.lock` change before writing any code — a throwaway probe script proved the premise). Parses unresolved (no analysis-context setup needed for an access-path-only rewrite), matches `PrefixedIdentifier`/`PropertyAccess` nodes whose prefix is `GeniusWalletColors` and whose member is one of the 64 `GWColors` field names, and classifies each as a rewrite or one of two hard refusals: `const` (via `Expression.inConstantContext` plus a manual default-parameter-value check) or `no-context` (a syntactic `BuildContext`-in-scope walk).
- `--self-test`: 16 cases, all passing — a plain access rewritten, an explicit-`const`-invocation refusal, a top-level-`const`-variable refusal (no explicit `const` on the list literal itself), a string-literal non-match, a comment non-match, a top-level no-context refusal, a static-member no-context refusal, a `State`-subclass implicit-context rewrite, a `CustomPainter` no-context refusal, an excluded-name (`statusNeutral`) pass-through, plus 5 real-file `--apply` cases proving the import bookkeeping (adds `gw_context_extension.dart`, drops the now-dead `genius_wallet_colors.dart` import, or keeps it when something else in the file still needs it).
- Directory-by-directory application (`lib/components/`, `lib/dashboard/`, `lib/settings/`, `lib/account/`, `lib/logs/`, `lib/onboarding/`, `lib/chart/`, `lib/dev/`, `lib/web/`, `lib/screens/`, `lib/squid_router/`, `lib/reown/`, plus `lib/main.dart`), each gated by `flutter analyze --no-pub` (0 issues), `flutter test --no-pub` (693/693), `bash tool/check_brace_style.sh --count` (0), and `dart format` before committing.
- `179 sites rewritten`, `72 refused` (45 const, 27 no-context) — reconciles exactly against the 251-site pool measured before any directory was touched (179 + 72 = 251, both before and after the migration).
- `23-02-RESIDUE.md`: every refusal grouped by reason with per-file line/symbol detail and a closing note, plus the six `test/` files (13 occurrences) that will break when 23-04 demotes `GeniusWalletColors`'s public members to private.

## Task Commits

1. **Task 1: Write the AST rewriter and dry-run it** - `553fecc` (feat)
   - **Bug found starting Task 2, fixed same session:** `352ad07` (fix) — the codemod rewrote the access path but never managed the two imports every rewrite depends on (add `gw_context_extension.dart`, drop the dead `genius_wallet_colors.dart`). Surfaced immediately as `undefined_getter`/`unused_import` on `lib/components`'s first apply run. Fixed with offset-safe back-to-front import edits plus 5 new self-test cases proving it via real temp-file applies.
2. **Task 2: Apply directory by directory** - one commit per directory (see list below), plus `984443e` for `lib/main.dart` (deviation, see below)
3. **Task 3: Write the residue inventory for 23-03** - `102543e` (docs)

**Task 4: the eight-screen appearance-toggle walk — NOT YET PERFORMED** (`checkpoint:human-verify`, `gate="blocking"`). No plan-metadata commit has been made yet; STATE.md/ROADMAP.md are owned by the orchestrator.

### Per-directory commits (Task 2)

| Directory | Commit | Rewritten | Refused (const) | Refused (no-context) |
|---|---|---|---|---|
| `lib/components/` | `450de88` | 78 | 18 | 15 |
| `lib/dashboard/` | `b1aa775` | 4 | 3 | 6 |
| `lib/tokens/` | *(no commit — 0 rewrites, 1 no-context refusal, nothing changed)* | 0 | 0 | 1 |
| `lib/settings/` | `59b06df` | 2 | 0 | 0 |
| `lib/account/` | `6a71cec` | 3 | 3 | 1 |
| `lib/network/` | *(no commit — 0 sites)* | 0 | 0 | 0 |
| `lib/logs/` | `7083654` | 3 | 1 | 0 |
| `lib/submit_job/` | *(no commit — 0 rewrites, 2 refusals across two files, nothing changed)* | 0 | 1 | 1 |
| `lib/onboarding/` | `471a7c7` | 5 | 0 | 0 |
| `lib/chart/` | `78079e1` | 1 | 0 | 0 |
| `lib/dev/` | `2bc9e5c` | 13 | 10 | 0 |
| `lib/web/` | `9b75952` | 44 | 2 | 0 |
| `lib/screens/` | `1663c86` | 6 | 2 | 0 |
| `lib/banxa/` | *(no commit — 0 rewrites, 2 no-context refusals, nothing changed)* | 0 | 0 | 2 |
| `lib/squid_router/` | `c1e98a7` | 9 | 1 | 0 |
| `lib/reown/` | `dc8b2cd` | 9 | 3 | 1 |
| `lib/main.dart` (deviation — see below) | `984443e` | 2 | 1 | 0 |
| **Total** | | **179** | **45** | **27** |

`git log --oneline` (Task 1 through Task 3, in order):
`553fecc` → `352ad07` → `450de88` → `b1aa775` → `59b06df` → `6a71cec` → `7083654` → `471a7c7` → `78079e1` → `2bc9e5c` → `9b75952` → `1663c86` → `c1e98a7` → `dc8b2cd` → `984443e` → `102543e`

Four directories produced zero file changes (`lib/tokens/`, `lib/network/`, `lib/submit_job/`, `lib/banxa/`) — every `GeniusWalletColors` reference found there was a hard refusal, so no commit was made for them (an empty commit would be noise; their refusals are still fully accounted for in the totals above and in `23-02-RESIDUE.md`).

## Files Created/Modified

- `tool/codemod_colors.dart` (new) — the AST rewriter; see Task 1 commit and the follow-up fix for what it does.
- `.planning/phases/23-.../23-02-RESIDUE.md` (new) — the 72-site refusal inventory for 23-03, plus the six flagged `test/` files.
- 47 files under `lib/` across 13 directories (see per-directory commit table above) — every change is an in-place `GeniusWalletColors.<name>` → `context.gw.<name>` substitution at an existing expression, plus the corresponding import add/drop. No file gained a new class-level field, constructor parameter, or method as a side effect of this migration.

## Const Sites Dropped

**None.** No `const` keyword was removed from any widget in this plan. Every site the codemod found sitting inside a `const` context was a **hard refusal** — left exactly as-is on `GeniusWalletColors.<name>`, not rewritten and not de-consted. This differs from the plan's anticipated failure mode ("the fix is to drop that `const`, not to revert the token migration") because the codemod's design choice was: refuse and report rather than auto-decide whether a given `const` was load-bearing. That decision explicitly belongs to 23-03 (see `23-02-RESIDUE.md`'s `const` table — 45 sites, including the 4 files 22-05 flagged in advance: `gw_spinner.dart`'s 3, `registration_header.dart`'s 1, `token_info_screen.dart`'s no-context refusal, and `submit_job_screen.dart`'s confirmed-clean 0).

## How Hoisting Was Checked

Per directory, after applying and before committing: `git diff -- <dir> | grep -E '^\+' | grep -viE "^\+\+\+|import '...gw_context_extension|context\.gw\."` — i.e., every added line that was NOT an import statement and NOT a direct `context.gw.<field>` substitution. Across all 13 directories with real changes, this surfaced only `dart format` line-wrap continuations (e.g. `context\n    .gw` or `color:\n    context.gw.X` split across lines) — zero new field declarations, zero new constructor parameters, zero new class members. This is also true by construction: the codemod's `applyReport` only ever calls `content.replaceRange` at pre-existing expression offsets (for the rewrite) and at import-directive boundaries (for the two import edits) — it has no code path that could introduce a new declaration.

## Decisions Made

See `key-decisions` in the frontmatter above — summarized: `package:analyzer` premise confirmed before writing code; `Expression.inConstantContext` (syntactic, no resolution needed) used as the const check, hardened with a manual default-parameter-value check the API's own doc says it excludes; a name-based `BuildContext`-in-scope heuristic chosen over full type resolution and empirically validated against all 4 files 22-05 flagged in advance; `lib/main.dart` migrated as a Rule 2 deviation even though the plan's directory list never named it.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Codemod didn't manage imports, only the access path**
- **Found during:** Task 2, first apply run (`lib/components`)
- **Issue:** Rewriting `GeniusWalletColors.x` → `context.gw.x` without importing `gw_context_extension.dart` is `undefined_getter`; leaving `genius_wallet_colors.dart` imported after every reference in a file was migrated is `unused_import`. `flutter analyze` immediately reported both across the first directory (95 issues).
- **Fix:** `applyReport` now inserts the `gw_context_extension.dart` import (in correct alphabetical position, respecting `directives_ordering`) when at least one rewrite happened and it isn't already imported, and drops the legacy import when `totalLegacyRefs == rewrites.length` (nothing left in the file still needs it — tracked separately from the 64-name token set so an untouched name like `statusNeutral` correctly keeps the import alive).
- **Files modified:** `tool/codemod_colors.dart` (+ 5 new `--self-test` cases against real temp files).
- **Commit:** `352ad07`

**2. [Rule 2 - Missing coverage] `lib/main.dart` migrated even though the plan's directory list never named it**
- **Found during:** Task 3's residue re-check (a post-migration full-tree dry-run still showed 2 rewritable sites)
- **Issue:** `lib/main.dart` is a top-level file, not a subdirectory, so the plan's `Suggested order` list (`lib/components/` … `lib/reown/`) never named it. It had 2 real, migratable sites (`surfaceBase`, `textPrimary`) plus 1 const refusal (`statusError`).
- **Fix:** Applied the codemod to `lib/main.dart` directly, same verification gates, own commit.
- **Files modified:** `lib/main.dart`
- **Commit:** `984443e`

**3. [Scope-boundary] Pre-existing `verify_additive_boundary.sh` failures, unrelated to this plan**
- **Found during:** final gate run
- **Issue:** `verify_additive_boundary.sh` reports the same duplicate-private-class-name census failures (`_Section`, `_SplashState`, `_TimeframeTab`, `_TimeframeTabState`) and the standing `WIRE-02` marker in `global_swap_fab_host.dart` that 23-01-SUMMARY.md already documented as pre-existing and unrelated to `lib/theme/`.
- **Resolution:** Confirmed via `git status --short` and directory scope that none of this plan's 13 directories touch those files. Logged here, not fixed — out of scope per the deviation-rules scope boundary.

---

**Total deviations:** 2 auto-fixed (1 bug, 1 missing-coverage), 1 logged-not-fixed (pre-existing, out of scope).
**Impact on plan:** Both auto-fixes were necessary for the migration to compile at all / to be complete; no scope creep beyond `lib/main.dart`'s 3 sites.

## Issues Encountered

None beyond the deviations above. Every directory's `flutter analyze --no-pub` was 0 issues on the first apply attempt after Task 1's import-management fix landed; no fix-attempt iterations were needed per directory.

## Verification Results (final, whole-tree, after all commits)

```
flutter analyze --no-pub                                   -> No issues found! (exit 0)
bash tool/check_brace_style.sh --count                      -> 0
dart format --output=none --set-exit-if-changed lib test    -> exit 0
flutter test --no-pub                                       -> 693/693 pass (>= 693 floor)
git diff --stat -- pubspec.yaml pubspec.lock                -> (empty -- unchanged)
bash tool/check_onboarding_seed_safety.sh                    -> PASSED (all six Section 3 checks)
bash tool/check_no_new_key_logging.sh --scan-tree            -> OK (no new key logging)
dart run tool/codemod_colors.dart --dry-run (final)          -> 0 rewritten, 45 const-refused, 27 no-context-refused
```

`verify_additive_boundary.sh` still fails on the two pre-existing, unrelated findings documented in 23-01-SUMMARY.md's Deviations (duplicate private class census, standing `WIRE-02` marker) — confirmed not touched by this plan.

## Known Stubs

None. This plan is a mechanical access-path rewrite; no new capability, no unwired data source.

## Threat Flags

None beyond the plan's own `<threat_model>` (T-23-07 through T-23-12), all mitigated exactly as specified: per-directory commits with money paths (`lib/banxa/`, `lib/squid_router/`, `lib/reown/`) last, hard refusals proven by `--self-test` for const/no-context sites, `Expression.inConstantContext`'s syntactic nature confirmed via self-test rather than assumed, AST node matching structurally prevents string/comment false-matches (proven, not assumed), and `analyzer`'s undeclared-transitive-dependency risk (T-23-11) is accepted per the plan and unchanged.

## User Setup Required

None — no external service configuration required.

## Task 4: Eight-Screen Appearance-Toggle Walk — OUTSTANDING (blocking-human checkpoint)

**Not performed.** This requires building and running the app interactively, which an autonomous execution session cannot do. The walk script below is exactly what the plan specifies — hand this to the developer:

Start in **dark** mode. On each screen, note what it looks like. Then go to Settings and toggle appearance to **light**. Return to each screen and confirm it changed. Then toggle back to dark and confirm it changed back. A screen that looks correct in dark and correct in light is fine; a screen that looks correct in dark and is STILL DARK after the toggle is the bug (a frozen colour, hoisted out of `build()`).

1. **Dashboard** — balance header, holdings list, transactions list, markets table (check the coloured percentage cells specifically), news cards.
2. **A token detail screen** — chart, price header, address row, stat rows.
3. **Settings** — the screen you toggle from; confirm it repaints under you, not just on re-entry.
4. **Swap** — the two amount fields, token selectors, and the settings drawer.
5. **One onboarding screen** — recovery-phrase or verify-recovery-phrase screen.
6. **Submit logs** (Settings → logs) — monospace family + a status colour.
7. **A toast** — trigger any success or error toast. (Expected to look WRONG in light mode — `toast_widget.dart` has an inverted light palette, 23-03 fixes it. Just confirm it *changes*.)
8. **A dApp connect prompt**, if reachable — `lib/reown/` was the last money-path directory migrated.

Also confirm any hover effect (dashboard cards, markets rows) still changes the row on hover — a frozen hover colour is the same bug wearing a different hat.

**Resume signal:** "approved", or list the screen numbers that did not change with the toggle.

## Next Phase Readiness

Tasks 1-3 are complete: the codemod exists and is proven correct (`--self-test`, empirically validated against every file 22-05 flagged in advance), 179 sites are migrated across 13 directories with analyzer/brace/format/test gates green after every commit, and the 72-site residue is precisely enumerated and reconciled for 23-03 to consume directly (grouped by reason, per-file, with closing notes). The six `test/` files 23-04 will break are flagged with their exact member reads.

**Blocker:** Task 4 (the eight-screen appearance-toggle walk) has not been performed and must complete before this plan can be considered fully closed. Recorded as an honest outstanding gap, not assumed passing — consistent with this project's standing practice (see PROJECT.md's Phase 5 closure precedent and 04-02-SUMMARY.md's own `status: blocked` precedent for the same checkpoint type).

---
*Phase: 23-design-system-consolidation-theme-tokens-shared-components*
*Completed: 2026-07-29 (Tasks 1-3; Task 4 outstanding)*

## Self-Check: PASSED

- FOUND: `tool/codemod_colors.dart`
- FOUND: `.planning/phases/23-.../23-02-RESIDUE.md`
- FOUND: `.planning/phases/23-.../23-02-SUMMARY.md` (this file)
- FOUND all 16 commits in `git log --oneline --all`: `553fecc`, `352ad07`, `450de88`, `b1aa775`, `59b06df`, `6a71cec`, `7083654`, `471a7c7`, `78079e1`, `2bc9e5c`, `9b75952`, `1663c86`, `c1e98a7`, `dc8b2cd`, `984443e`, `102543e`
