---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
plan: 02
subsystem: infra
tags: [awk, bash, lint-gate, ci, brace-style, editorconfig]

# Dependency graph
requires:
  - phase: 22-01
    provides: "Green baseline (512/0 tests, 300 analyze issues) this plan's verification depends on"
provides:
  - "tool/check_brace_style.sh -- a paren-aware, self-testing gate that enforces AGENTS.md's brace rule (no Dart lint can express it)"
  - "Real, measured brace-violation baseline: 192 violations across 75 files"
  - ".editorconfig at repo root for YAML/shell/Markdown and dart-format-width parity"
affects: ["22-04 (fixes the 192 violations this gate measures)", "22-08 (wires this gate into CI)"]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Depth-aware awk scanning (paren/bracket/brace counter) instead of regex-grabs-last-paren, for any future gate that needs to parse Dart structurally without a real parser"
    - "Statement-vs-collection-element disambiguation via forward depth-0-terminator scan (';' = statement, ','/negative-depth-close = list/map element) -- reusable pattern for anything that needs to tell a Dart statement from a collection-if/for element"

key-files:
  created:
    - tool/check_brace_style.sh
    - .editorconfig
  modified: []

key-decisions:
  - "Collection-if detection uses a full depth-tracked terminator scan, not a trailing-comma heuristic -- the naive comma-ending check produced 135 false positives (327 vs 192) on real code: spread collection-ifs (`if (x) ...[`) and multi-line widget-expression collection-ifs (`if (cond)\\n  Widget(...),`) don't end in a same-line comma."
  - "Generated-code exclusion is path-based (lib/hive/models/*.g.dart, lib/hive_registrar.g.dart, lib/tokeninfo/token_model.g.dart), not a blanket *.g.dart glob -- 9 hand-written production widgets under lib/components/ use that suffix and must stay in scope until 22-03 renames them."
  - "packages/genius_api/lib/{ffi,proto}/ excludes are kept for documentation parity with analysis_options.yaml even though they're unreachable today (the scan is scoped to lib/ and test/ only, per the plan)."

requirements-completed: [ORG-01]

coverage:
  - id: D1
    description: "tool/check_brace_style.sh scans lib/ and test/, paren-aware, and reports the real brace-rule violation count via --count"
    requirement: "ORG-01"
    verification:
      - kind: unit
        ref: "bash tool/check_brace_style.sh --count (prints 192)"
        status: pass
      - kind: unit
        ref: "bash tool/check_brace_style.sh (prints 192 offenders, exits 1)"
        status: pass
    human_judgment: false
  - id: D2
    description: "--self-test proves the gate can fail: 4 must-flag + 5 must-not-flag fixture cases, all correctly classified"
    requirement: "ORG-01"
    verification:
      - kind: unit
        ref: "bash tool/check_brace_style.sh --self-test (9/9 PASS, exit 0)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The gate was observed actually failing on an injected defect, not merely assumed to work (T-22-04 mitigation)"
    verification: []
    human_judgment: true
    rationale: "The demonstration (inverting one comparison, observing 2 FAIL lines and exit 1, then reverting) is a one-time manual act during execution, not a re-runnable automated check -- recorded as transcript evidence below, not as a test artifact."
  - id: D4
    description: ".editorconfig present at repo root, consistent with analysis_options.yaml's formatter.page_width (80), under 30 lines"
    verification:
      - kind: unit
        ref: "test -f .editorconfig && grep root/end_of_line/max_line_length (prints OK)"
        status: pass
    human_judgment: false

# Metrics
duration: ~35min
completed: 2026-07-28
status: complete
---

# Phase 22 Plan 02: Brace-Style Gate + .editorconfig Summary

**Paren-aware, self-testing `tool/check_brace_style.sh` gate for AGENTS.md's brace rule, measuring a real 192-violation baseline (matching the recorded census exactly) after fixing a depth-tracking bug that produced 327 false positives; plus a minimal `.editorconfig`.**

## Performance

- **Duration:** ~35 min
- **Completed:** 2026-07-28
- **Tasks:** 3
- **Files modified:** 2 created (tool/check_brace_style.sh, .editorconfig)

## Accomplishments

- Built `tool/check_brace_style.sh`: an awk-based, paren-depth-counting scanner (not a regex grabbing the last `)` on a line) that strips `//` comments, `/* */` block comments, and single/double-quoted string contents before matching any `if (`, so rule examples inside doc comments or strings can't trip it.
- Told Dart's collection-`if` (`[if (x) a, b]`, including the spread form `if (x) ...[a, b]`) apart from a real braceless statement using a **forward depth-0-terminator scan**: the first depth-0 `;` means an unbraced statement (violation); the first depth-0 `,` or a bracket-close that drives depth negative (closed the *enclosing* literal, not one the body opened) means the body was a list/map element, not a statement, so the brace rule doesn't apply to it. This correctly handles multi-line collection-if elements (`if (cond)\n  Widget(...),`) that have nothing on the `if` line itself.
- Added `--count` (bare integer, CI-friendly) and `--self-test` (9 fixture cases: 4 must-flag, 5 must-not-flag) modes to the same file, per the plan's "one file, not a second one" instruction.
- Measured the real baseline: **192 violations across 75 files**, `--count` exits 0, default mode exits 1 and lists offenders as `path:line: source`.
- Added `.editorconfig` (25 lines): `root = true`, LF/UTF-8/trim-trailing-whitespace/2-space-indent defaults, `[*.dart] max_line_length = 80` (matches `analysis_options.yaml`'s `formatter.page_width`), `[*.md]` trailing-whitespace trim disabled (hard line breaks), `[*.sh]` LF pinned (CRLF shebang breaks the Linux CI runner).
- Confirmed no `.dart` file was touched (`git diff --stat -- '*.dart'` empty since 22-01) and the green baseline is unchanged: `flutter test --no-pub` still 512/0, `flutter analyze --no-pub` still 300 issues.

## Task Commits

1. **Task 1 + Task 2: brace-style gate + self-test** - `e3298ae` (feat) -- combined into one commit because both tasks target the same single file by design (the plan states "one file, not a second one: the test ships with the thing it tests").
2. **Task 3: .editorconfig** - `add0ff1` (feat)

**Plan metadata:** (this commit, made after this SUMMARY)

## Files Created/Modified

- `tool/check_brace_style.sh` - Paren-aware brace-rule gate. `--count` prints the integer violation count; default mode prints `path:line: source` offenders and exits 1; `--self-test` runs 9 fixture cases and exits 0 only if every one classifies correctly.
- `.editorconfig` - Root-level editor defaults for the file types `dart format` doesn't own (YAML, shell, Markdown), plus a `[*.dart] max_line_length` that agrees with the formatter's configured page width.

## Decisions Made

- **Depth-tracked terminator scan over a trailing-comma heuristic for collection-if.** The plan's own acceptance range (150-230) anticipated some measurement drift from the informal 192 census, but the first working version of this scanner reported **327** -- investigated and found to be two concrete false-positive classes: (1) spread collection-ifs (`if (isWatched) ...[`, TAIL = `...[`, doesn't end in a comma) and (2) multi-line widget-expression collection-ifs where nothing follows the `if` condition on its own line (`if (wallet.walletType != WalletType.sgnus)\n  MenuItemButton(\n    ...\n  ),`) -- these fell into the same "nothing follows the closing paren" bucket as a genuine braceless statement, and the old logic only checked whether the *next line* started with `{`, which a widget constructor call never does. Rewrote the classifier to depth-track `()`/`[]`/`{}` forward from wherever the body starts to its first depth-0 terminator: `;` at depth 0 is an unbraced statement (a Dart statement body always reaches its own `;` before any enclosing `}` can close); a `,` at depth 0, or a bracket-close that drives depth negative (it closed the *enclosing* list/map, not one the body opened), is a list/map element. Re-measured: exactly **192**, matching the recorded census total precisely (see "Issues Encountered" for the 75-vs-72-file nuance).
- **Excluded paths are path-literal, not a blanket `*.g.dart` glob**, per the plan's explicit instruction -- 9 hand-written production widgets under `lib/components/` use that suffix and must stay in scope until 22-03 renames them.
- **Combined Task 1 + Task 2 into a single commit.** Both tasks declare `<files>tool/check_brace_style.sh</files>` -- the same file -- and the plan itself says the self-test "ships with the thing it tests" rather than living in a second file. Splitting the commit would have required either fabricating an artificial intermediate state (task-1-only, pre-self-test) that was never actually run/verified on its own, or reverting and re-adding code, neither of which produces an honest history. One commit documents both tasks explicitly in its body instead.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Collection-if false positives from a too-narrow Class B check**
- **Found during:** Task 1 verification (`bash tool/check_brace_style.sh --count` reported 327, outside the plan's 150-230 expected range)
- **Issue:** The first working version classified "nothing follows the closing paren" bodies as compliant only when the *very next source line* began with `{`. Multi-line collection-if elements (a widget constructor spanning many lines, or a spread `...[` list) never satisfy that, so they were misclassified as braceless statement violations -- 135 false positives.
- **Fix:** Replaced the "check next line" heuristic with `terminator_scan()`, a depth-tracked forward scan (see Decisions above) that correctly distinguishes a statement's `;` terminator from a collection element's `,`/negative-depth-close terminator, regardless of how many lines or how much nesting the body spans.
- **Files modified:** `tool/check_brace_style.sh`
- **Verification:** Re-ran `--self-test` (still 9/9 PASS) and `--count` (192, matching the census); spot-checked the previously false-flagged lines (`account_dropdown_selector.dart:260,281,327,340,409`) are no longer in the offender list.
- **Committed in:** `e3298ae` (the false-positive fix predates the commit -- the committed version is the corrected one; no separate "buggy" commit exists, consistent with the honest-history reasoning above)

---

**Total deviations:** 1 auto-fixed (Rule 1 - bug in the first implementation attempt, caught by the plan's own baseline-range acceptance criterion before anything was committed)
**Impact on plan:** The fix is exactly what the acceptance criteria's "record whatever it actually reports as the baseline" language anticipated needing -- verification caught a real detector bug before it shipped. No scope creep; no `.dart` file touched.

## Issues Encountered

- **File count (75) doesn't match the informal census's file count (72), even though the violation total (192) matches exactly.** The plan states two independent cruder measurements gave 192 and 202, and explicitly designates this paren-aware scanner as "the authority -- record whatever it actually reports." I verified there is no double-counting (zero duplicate `file:line` entries in the offender list) and that generated-path exclusions are working (no offenders under `lib/hive/models/*.g.dart`, `lib/hive_registrar.g.dart`, or `lib/tokeninfo/token_model.g.dart`). All 192 offenders are the same violation shape in this codebase -- a same-line braceless guard clause ending in `;` (e.g. `if (!mounted) return;`) -- none are the "collapsed-with-braces" or "genuinely multi-line braceless" shapes (those two paths are exercised and proven correct only via the self-test fixtures, cases 1 and 2/3, since real code apparently doesn't contain either shape). Given the total matches the census exactly and the false-positive/duplicate checks are clean, I'm treating 192 as correct; the 75-vs-72 file-count discrepancy most likely reflects how the informal census tool grouped or excluded files differently, not an error in this gate.

## Proof the gate can fail (T-22-04 demonstration)

Per the plan's Task 2 acceptance criteria, I temporarily inverted the compliant/violation return values for the "bare `{` on the condition line" case (`tool/check_brace_style.sh` line ~241, `if (tail == "{") return "compliant"` → `return "violation"`), then ran `--self-test`:

```
PASS: 1-collapsed-one-liner-with-braces
PASS: 2-braceless-body-on-next-line
PASS: 3-braceless-nested-paren-condition
PASS: 4-compliant-then-violating-in-same-file
FAIL: 5-compliant-form (expected no violation, found 1)
FAIL: 6-else-if-chain-all-compliant (expected no violation, found 2)
PASS: 7-violation-inside-line-comment
PASS: 8-violation-inside-string-literal
PASS: 9-collection-if-inside-list-literal
exit: 1
```

Then reverted the change and re-ran `--self-test`, confirming all 9 cases PASS and exit 0 again (the version now committed in `e3298ae`). The gate demonstrably fails when broken, not merely assumed to.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- 22-04 can now drive the measured 192-violation baseline to 0 using `tool/check_brace_style.sh --count` as its own success metric.
- 22-08 can wire `tool/check_brace_style.sh` into CI once 22-04 lands (this plan explicitly does not wire it in).
- `.editorconfig` is in place for any phase that touches YAML/shell/Markdown formatting.

---
*Phase: 22-codebase-organization-standards-config-dead-code-deletion-th*
*Completed: 2026-07-28*

## Self-Check: PASSED

- FOUND: tool/check_brace_style.sh
- FOUND: .editorconfig
- FOUND: e3298ae (feat: brace-style gate + self-test)
- FOUND: add0ff1 (feat: .editorconfig)
