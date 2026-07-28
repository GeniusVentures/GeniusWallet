# Handoff — 2026-07-28 — codebase hygiene, coding standards, and the Phase 22/23/24 re-cut

**Role this session:** EXECUTOR (per AGENTS.md). Branch `ui-redesign-port`, HEAD `73160a2`,
working tree clean, **66 commits**.

**Detailed state lives in**
`.planning/phases/23-design-system-consolidation-theme-tokens-shared-components/.continue-here.md`
— read that to resume. This file is the day summary AGENTS.md requires.

> **`.planning/HANDOFF.json` was deliberately NOT written.** AGENTS.md records it as a one-slot
> shared file that collided between parallel sessions on 2026-07-22. One file per session is safe;
> a shared slot is not. This file and the phase `.continue-here.md` are the handoff.

---

## What the session was asked for

Organise the codebase for reusable components and less local code, with the best architecture
available, respecting existing logic and breaking nothing — then add a config so AI models working
in this repo follow the team's coding standards. A developer's specific requirement came with it:
**every `if` gets braces, body on its own line**, because you can't breakpoint a same-line `return;`
and a `log()` usually ends up in there later.

## What was done

**Audit — 6 parallel agents:** component reuse, architecture, design system, standards compliance,
the GNUS handbook, tests/build/config.

**Research — 6 parallel agents:** Flutter's official architecture guidance, Dart lint rulesets,
design-token practice, CI/testing discipline, AI-agent config formats, and safe refactoring of large
Flutter codebases. All cited, with unverified claims flagged rather than smoothed over.

**Phases re-cut** from one 15-plan phase into: **22** hygiene (shipped), **23** design-system
consolidation (planned, 6 plans), **24** architecture (roadmap only). The split cost ~140
cross-reference rewrites; both `depends_on` chains were re-validated afterwards.

**Phase 22 executed** — 7 of 8 plans:

| | Before | After |
|---|---|---|
| `flutter analyze` | 408 issues, exit 1 | **0, exit 0** |
| `flutter test` | 512 pass / **1 fail** | **512 / 0** |
| Brace-less `if` | 192 across 72 files | **0**, gated with self-test |
| Dead code | — | **−1,744 LOC** |
| CI quality gates | **zero** | 7 wired |

**Standards config landed:** `analysis_options.yaml` (14 targeted rules, 3 declined with written
reasons), `packages/genius_api/analysis_options.yaml` (FFI/proto excludes), an `AGENTS.md`
Dart-standards section, and a one-character fix to `CLAUDE.md`.

## Five things worth knowing

1. **`CLAUDE.md` contained the bare text `AGENTS.md`** — not an import. Project instructions had
   never been loading. Now `@AGENTS.md`.
2. **The analyzer resolves the *nearest* `analysis_options.yaml`.** The root's
   `packages/genius_api/lib/proto` exclude had never applied to anything. Fixing it alone took
   analyze 408 → 85.
3. **No Dart lint can express the brace rule.** `curly_braces_in_flow_control_structures` is already
   enabled and reports 0 — it permits omitting braces when the statement fits one line with no
   `else`, and all 192 violations sat in that carve-out. Hence `tool/check_brace_style.sh`.
4. **Two security gates were passing vacuously.** `check_no_new_key_logging.sh` only diffed working
   tree against index — always empty on a fresh CI checkout. `check_onboarding_seed_safety.sh`
   CHECK 4 text-matched the unbraced `if` form and broke when 22-04 braced it. Both fixed and
   re-proven against injected violations.
5. **Three of the audit's own findings were wrong**, caught only because the planner re-measured:
   `GWTimeframeSegment` is not character-identical, `GWCopyRow` has 2 forks not 3, and raw colour
   references are 525 not 114. Treat counts in planning docs as hypotheses.

## Decisions taken by Braian

- Lint ruleset: `flutter_lints` + ~14 targeted rules. `very_good_analysis` (206 rules) declined.
- Brace enforcement: CI gate + auto-fix script. `custom_lint` declined — and it is retired anyway.
- CI rollout: exclude generated code → fix the rest → gate last. Nothing blocked while cleaning.
- Phase split at the mechanical/consolidation boundary.
- **Golden tests: cancelled outright**, twice. No replacement test infrastructure for now. Functional
  E2E ("playwright or the equivalent") is a later topic — note the Flutter-native answer is
  `integration_test`/`patrol`, since Flutter renders to one `<canvas>` with no DOM to select.

Phase 23 was **re-planned from scratch** without goldens rather than patched around 104 void
references, and it **cut extraction work it could not honestly verify** — `GWChangePill` cut,
`GWCopyRow` and `GWTimeframeSegment` refused, `GWAppBar` and the `GWScreen` sweep deferred. Only
`GWHoverable` survived. `ORG-05` will land PARTIAL by design.

## Open for the next session

- **Push to prove CI** — the `quality` job has never run; CI pins Flutter 3.38.10 vs local 3.41.9.
- **Live smoke test** — dApp connect + market data, before merge.
- **Two unscoped findings:** unguarded dev routes at `router.dart:199,203` (reachable in release),
  and `swap_screen.dart:293` where the swap makes no API call but still writes a completed
  transaction to Hive.
