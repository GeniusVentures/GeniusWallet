---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
plan: 04
subsystem: infra
tags: [awk, bash, lint-gate, dart-format, brace-style, codemod]

# Dependency graph
requires:
  - phase: 22-02
    provides: "tool/check_brace_style.sh, the paren-aware detector this plan's --fix mode reuses, and the measured 192-violation baseline"
  - phase: 22-03
    provides: "Green baseline this plan must not regress: 512/0 tests, 344 analyze issues (the ceiling)"
provides:
  - "tool/check_brace_style.sh --fix -- a rewriter sharing the gate's own classify_if/terminator_scan detector, refusing everything outside one proven-safe shape"
  - "A repo where tool/check_brace_style.sh --count reports 0 -- every if in lib/ and test/ is braced per AGENTS.md"
  - "22-04-SEMANTIC-DELTAS.md -- an individually-recorded audit of all 35 mounted-guard sites the sweep touched, with direct analyzer proof that bracing them introduces no diagnostic delta"
  - "A fixed tool/check_onboarding_seed_safety.sh CHECK 4 that recognizes the now-universal braced mounted-guard form"
affects: ["22-05 (any further lib/test cleanup builds on this now-braced tree)", "22-08 (wires check_brace_style.sh into CI, now that --count is 0)"]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Codemod/gate detector sharing: a rewriter and its verifying gate call the SAME classification function (classify_if -> terminator_scan -> terminator_scan_pos) so the two can never quietly disagree about what a violation is."
    - "Refuse-by-default codemod scope: --fix only rewrites the one syntactic shape it can prove safe (condition+body+terminator on one physical line, no else) and reports everything else as a named refusal rather than guessing."
    - "Token-stream diff proof: stripping whitespace/braces/commas from before/after content and asserting byte-equality is a cheap, systematic way to prove a mechanical sweep moved no statement, across many files, instead of eyeballing every diff."

key-files:
  created:
    - .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-04-SEMANTIC-DELTAS.md
  modified:
    - tool/check_brace_style.sh
    - tool/check_onboarding_seed_safety.sh
    - .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/deferred-items.md
    - "75 lib/ and test/ files (brace violations fixed)"
    - "89 further lib/ and test/ files (dart-format-only reflow, no violations of their own)"

key-decisions:
  - "--fix refactors terminator_scan into a thin wrapper over a new position-returning terminator_scan_pos, so the gate's classification and the fixer's 'where does this statement end' logic are the literal same code path, not two implementations that could drift."
  - "--fix's in-scope shape is narrow by design: condition+body+terminating ; all on one physical line, nothing but the statement following the ;. Everything else (else on the same line, body starting on a later line, body spanning multiple lines, an already-braced-but-collapsed one-liner) is refused and reported, never guessed at. All 192 real violations happened to fall inside this narrow shape, so zero manual hand-closing was needed."
  - "Verified the mounted-guard semantic hazard directly rather than asserting it away: reverted one braced mounted-guard back to its unbraced form in isolation and re-ran flutter analyze on that single file -- the same use_build_context_synchronously diagnostic appears either way, just at a 2-line-shifted position. No analyzer delta from bracing; 22-04-SEMANTIC-DELTAS.md is the individually-recorded proof the plan required, not a list of behaviour changes."
  - "check_onboarding_seed_safety.sh's CHECK 4 text-matched the single-line if (!mounted) return; shape only, so it broke the instant this plan braced that exact guard in recovery_phrase_screen.dart. Fixed the gate's regex (collapse its adjacency window to one line, allow an optional { between the condition and return;) rather than treat this as a pre-existing/out-of-scope finding, since the breakage was directly caused by this plan's own rewrite (Rule 1)."
  - "tool/verify_additive_boundary.sh's Check 2 (6 duplicate private-class names) and Check 3 (one WIRE-02 comment) still fail -- confirmed via commit 8b53828 (right after Task 1, before any lib/test edit) that both predate this plan entirely and are unrelated to bracing. Not fixed here, per the Scope Boundary rule and consistent with 22-03's identical prior finding; re-logged in deferred-items.md rather than silently ignored."
  - "tool/check_no_new_key_logging.sh requires a <file-path> argument (has since Phase 4-06); the plan's own verify command omits it. This is a plan-authoring gap predating 22-04, not a regression. Ran it correctly against lib/account/sdk_account_manager.dart -- the one file in this plan's diff with key-material-adjacent code -- and confirmed no new logging call was introduced."

requirements-completed: [ORG-01]

coverage:
  - id: D1
    description: "tool/check_brace_style.sh gains a --fix mode sharing the gate's classify_if/terminator_scan detector, rewriting only the proven-safe shape and refusing (never guessing at) everything else"
    requirement: "ORG-01"
    verification:
      - kind: unit
        ref: "bash tool/check_brace_style.sh --self-test (23/23 PASS, exit 0 -- 9 original gate cases + 14 new --fix cases covering 2 in-scope rewrites with idempotence, 4 refusal categories, and collection-if non-interference)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every if in lib/ and test/ is braced per AGENTS.md -- tool/check_brace_style.sh --count reports 0"
    requirement: "ORG-01"
    verification:
      - kind: unit
        ref: "bash tool/check_brace_style.sh --count (prints 0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The sweep is behaviour-preserving: 512/0 tests unchanged, analyzer count unchanged at the 344 ceiling, dart format clean, token stream (minus whitespace/braces/commas) identical to pre-change across all 164 touched files"
    requirement: "ORG-01"
    verification:
      - kind: unit
        ref: "flutter test --no-pub (512 passing, 0 failing -- identical to 22-03)"
        status: pass
      - kind: unit
        ref: "flutter analyze --no-pub (344 issues, 0 errors -- exact match to the 22-03 ceiling)"
        status: pass
      - kind: unit
        ref: "dart format --output=none --set-exit-if-changed lib test (exit 0)"
        status: pass
    human_judgment: false
  - id: D4
    description: "The mounted-guard semantic hazard is individually recorded and proven, not silently absorbed"
    requirement: "ORG-01"
    verification:
      - kind: manual_procedural
        ref: "22-04-SEMANTIC-DELTAS.md -- lists all 35 mounted-guard sites; documents a direct before/after flutter analyze test on one representative site proving no diagnostic delta from bracing"
        status: pass
    human_judgment: false
  - id: D5
    description: "Windows debug build succeeds and the app launches without crashing"
    verification:
      - kind: manual_procedural
        ref: "flutter build windows --debug (exit 0, genius_wallet.exe built); launched, ran 10s under Sentry init without crash, cleanly terminated"
        status: pass
    human_judgment: true
    rationale: "Confirmed process launches and survives 10s without crashing or generating a Sentry crash event, but reaching the actual dashboard screen depends on local wallet/onboarding state this session did not set up -- a human running the app with real data is the authoritative check for 'launches to the dashboard.'"

# Metrics
duration: ~35min
completed: 2026-07-28
status: complete
---

# Phase 22 Plan 04: Brace Every `if` Summary

**`tool/check_brace_style.sh --fix` rewrote all 192 braceless-if violations across 75 files in one pass (zero manual hand-closing needed), `dart format` reflowed 89 more files the bracing's line-length shifts touched, and the sweep is proven behaviour-preserving by an exact 512/0 test match, an unchanged 344-issue analyzer ceiling, and a whitespace/brace/comma-stripped token-stream equality check across all 164 changed files.**

## Performance

- **Duration:** ~35 min
- **Started:** 2026-07-28T14:40:32Z
- **Completed:** 2026-07-28T15:09:39Z
- **Tasks:** 3
- **Files modified:** 168 (tool/check_brace_style.sh, tool/check_onboarding_seed_safety.sh, 164 lib/test files, 22-04-SEMANTIC-DELTAS.md created, deferred-items.md updated)

## Accomplishments

- Added `--fix` to `tool/check_brace_style.sh` by refactoring its `terminator_scan` into a thin wrapper over a new position-returning `terminator_scan_pos`, so the gate's violation classification and the fixer's "where does this statement end" logic are the literal same code path. `--fix` rewrites only `if (cond) stmt;` where the condition, body, and terminating `;` all sit on one physical line with no `else` -- everything else (else on the same line, body starting on a later line, body spanning multiple lines, an already-braced-but-collapsed one-liner) is refused and reported by name, never guessed at.
- Grew `--self-test` from 9 to 23 fixture cases: 2 in-scope rewrites (each proving idempotence -- running `--fix` twice produces the same output as running it once), 4 out-of-scope refusal categories (byte-identical output + reason reported), and a collection-if case proving `--fix` never touches or refuses list/map elements.
- `--fix --dry-run` against the real repo reported 192 sites fixable and **0 refusals** -- confirming 22-02's finding that every real violation is the same "braceless guard clause ending in `;`" shape. Ran `--fix` for real: 192 sites rewritten across 75 files, zero manual hand-closing needed.
- `dart format lib test` reflowed 118 files (75 fixed + additional line-wrap ripples elsewhere) touching 89 files beyond the 75 that had actual brace violations -- this is the first repo-wide format pass in Phase 22, entirely whitespace/trailing-comma reflow, never a logic change (proven, see Verification below).
- Committed the sweep in 10 reviewable per-directory slices (`lib/components`, `lib/banxa`, `lib/dashboard`, `lib/theme`, `lib/squid_router`, `lib/dev`, remaining `lib/*`, `test/banxa`, `test/dashboard`, remaining `test/*`) instead of one 164-file commit.
- Wrote `22-04-SEMANTIC-DELTAS.md`, individually recording all 35 `mounted`/`context.mounted` guard sites the sweep touched (the plan's named "one sanctioned semantic delta" category), and directly tested the specific hazard: reverted one braced guard back to unbraced in isolation and re-ran `flutter analyze` on that file alone -- the same `use_build_context_synchronously` diagnostic fires either way, just 2 lines apart. No analyzer delta from bracing.
- Found and fixed a real regression the sweep caused: `tool/check_onboarding_seed_safety.sh`'s CHECK 4 text-matched the single-line `if (!mounted) return;` shape only, so it broke the moment this plan braced that exact guard in `recovery_phrase_screen.dart`. Fixed the regex to accept the braced form too (verified the negative case -- guard genuinely missing -- still fails correctly).
- Re-confirmed (and re-logged, per 22-03's precedent) that `tool/verify_additive_boundary.sh`'s Check 2/Check 3 failures and `tool/check_no_new_key_logging.sh`'s argument requirement all predate this plan and are unrelated to bracing.

## Task Commits

1. **Task 1: Add a --fix mode that shares the gate's detector** - `8b53828` (feat)
2. **Task 2: Run the fix, format, and hand-close the refusals** - split into 10 per-directory commits:
   - `34a0894` style: brace every if in lib/components
   - `9e36455` style: brace every if in lib/banxa
   - `6f39bec` style: brace every if in lib/dashboard
   - `f4516e6` style: brace every if in lib/theme
   - `5a39c31` style: brace every if in lib/squid_router
   - `7565901` style: brace every if in lib/dev
   - `e59de0f` style: brace every if in the remaining lib/ directories
   - `6c56b8d` style: dart format test/banxa (no brace violations)
   - `e9d8f1c` style: brace every if in test/dashboard
   - `af79dc6` style: brace every if in the remaining test/ directories
   - `2983689` docs: record the mounted-guard semantic-delta audit
3. **Task 3: Prove behaviour preservation** - `d202856` (fix: seed-safety gate regex), `ed6404f` (docs: re-log pre-existing findings)

**Plan metadata:** (this commit, made after this SUMMARY)

## Files Created/Modified

- `tool/check_brace_style.sh` - Gains `--fix`/`--fix --dry-run`, `terminator_scan_pos`, `try_fix`, `fix_scan`, `emit_fixed`, `apply_fix`, and 14 new self-test cases.
- `tool/check_onboarding_seed_safety.sh` - CHECK 4's adjacency regex now accepts both the historical unbraced `if (!mounted) return;` and the now-universal braced form.
- `.planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-04-SEMANTIC-DELTAS.md` - New. Individual audit of all 35 mounted-guard sites, with the direct analyzer-diagnostic proof.
- `.planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/deferred-items.md` - Appended a "From 22-04" section re-confirming 22-03's pre-existing `verify_additive_boundary.sh` findings still hold unchanged, plus the `check_no_new_key_logging.sh` argument-requirement note.
- 75 `lib/` and `test/` files - Braceless `if` violations rewritten to the braced form (192 sites total).
- 89 further `lib/` and `test/` files - `dart format`-only reflow triggered by line-length shifts elsewhere in the sweep; zero brace violations of their own.

## Decisions Made

See `key-decisions` in the frontmatter above for the full list with rationale. Highlights: sharing one detector function between gate and fixer (no risk of drift), a deliberately narrow --fix scope that refuses rather than guesses, direct experimental verification of the mounted-guard hazard instead of asserting it away, and fixing the one gate regression this plan actually caused while leaving genuinely pre-existing, unrelated gate failures documented but untouched.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `check_onboarding_seed_safety.sh` CHECK 4 broke on the exact guard this plan braced**
- **Found during:** Task 3 (running all three `tool/*.sh` security gates)
- **Issue:** CHECK 4 text-matched `if (!mounted) return;` as a single line. This plan's own sweep braced that exact guard in `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart`, so the regex no longer matched anything -- the gate started failing because of this plan's own diff, not a pre-existing issue.
- **Fix:** Collapsed CHECK 4's `-A2` adjacency window into one space-joined line and added an optional `\{?` between the condition and `return;`, so one regex accepts both the historical and the now-universal braced form. Verified the negative case (guard removed entirely) still correctly fails before restoring the guard.
- **Files modified:** `tool/check_onboarding_seed_safety.sh`
- **Verification:** `bash tool/check_onboarding_seed_safety.sh` -- all 6 checks PASS, exit 0. Negative-case test confirmed the check still catches a genuinely missing guard.
- **Committed in:** `d202856`

---

**Total deviations:** 1 auto-fixed (Rule 1 - bug the sweep itself introduced in a security gate's own detection logic)
**Impact on plan:** Necessary for correctness of Task 3's acceptance criteria; the fix only widens the gate's pattern to also recognize the codebase's own mandated style, it does not weaken what the gate checks (adjacency + presence of the guard are both still enforced, proven by the negative-case test).

## Issues Encountered

- **`tool/verify_additive_boundary.sh` fails its Check 2 (6 duplicate private-class names: `_Section`, `_SplashState`, `_TimeframeSegment`, `_TimeframeSegmentState`, `_TimeframeTab`, `_TimeframeTabState`) and Check 3 (one `WIRE-02` comment in `global_swap_fab_host.dart`).** Confirmed via commit `8b53828` (right after Task 1, before any `lib/`/`test/` file this plan touched was edited) that both findings already existed identically -- same files, same line numbers -- before this plan started its file sweep. This is the exact same finding 22-03 already documented and left unfixed for the same reason (Check 2's regex doesn't exclude `_`-prefixed private classes; Check 3 has no allowlist mechanism). Not fixed here, per the Scope Boundary rule (pre-existing, unrelated to bracing); re-logged in `deferred-items.md` with a pointer back to 22-03's original entry and recommendations for a future plan.
- **`tool/check_no_new_key_logging.sh` requires a `<file-path>` argument the plan's own `<verify>` block omits.** The script has required this argument since it was created in Phase 4-06 (`ac425c1`), predating this plan entirely -- running it bare always prints usage and exits 1, regardless of what this plan did. Ran it correctly against `lib/account/sdk_account_manager.dart` (the one file in this plan's diff with key-material-adjacent code, 8 brace fixes across its SDK dialog guard clauses): `OK: no new key logging (no diff for lib/account/sdk_account_manager.dart)`, exit 0. Documented the plan-authoring gap in `deferred-items.md` with a recommendation for 22-08 (which wires these gates into CI) to fix the verify command or give the script an argument-less mode.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `tool/check_brace_style.sh --count` reports 0 across the whole repo -- 22-08 can wire it into CI as a hard gate with no existing-violation carve-out needed.
- The codebase now uniformly satisfies AGENTS.md's brace rule; any future plan touching `lib/` or `test/` inherits a clean baseline.
- `verify_additive_boundary.sh` still needs a future plan (22-08 is the natural owner, per 22-03's original recommendation) to either baseline the 6 private-class collisions or fix Check 2's regex, and to decide how to close Check 3's WIRE-02 finding.
- `check_no_new_key_logging.sh`'s no-argument invocation gap should be resolved before it's wired into CI unconditionally.

---
*Phase: 22-codebase-organization-standards-config-dead-code-deletion-th*
*Completed: 2026-07-28*

## Self-Check: PASSED

- FOUND: tool/check_brace_style.sh
- FOUND: tool/check_onboarding_seed_safety.sh
- FOUND: .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-04-SEMANTIC-DELTAS.md
- FOUND: .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/deferred-items.md
- FOUND commits: 8b53828, 34a0894, 9e36455, 6f39bec, f4516e6, 5a39c31, 7565901, e59de0f, 6c56b8d, e9d8f1c, af79dc6, 2983689, d202856, ed6404f (all 14 present in git log)
