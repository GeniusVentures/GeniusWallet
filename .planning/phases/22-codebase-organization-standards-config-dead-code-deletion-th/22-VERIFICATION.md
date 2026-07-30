---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
verified: 2026-07-30T12:21:22Z
status: human_needed
score: 6/7 truths verified (1 present, behavior-unverified)
behavior_unverified: 1
overrides_applied: 0
behavior_unverified_items:
  - truth: "CI actually enforces the codebase's own rules (ORG-01): a PR that breaks format/analyze/brace-rule/a security gate/tests cannot merge green."
    test: "Trigger the `quality` job in `.github/workflows/build.yml` for real — e.g. open a PR against `develop`/`main`, or temporarily add a `workflow_dispatch`/push trigger for this branch — and observe a real GitHub Actions run."
    expected: "All non-`continue-on-error` steps pass on CI's pinned Flutter 3.38.10 (not just the local 3.41.9 SDK used for every verification quoted in 22-05/22-06/22-08); the `verify_additive_boundary.sh` step is allowed to report its 2 documented pre-existing false positives without failing the job (it is deliberately `continue-on-error: true`)."
    why_human: "The job has never executed — `gh run list --branch ui-redesign-port` and `gh run list --workflow=build.yml` show no run after 2026-07-27 (the day before the `quality` job was added in commit `31dea02`, 2026-07-28). `build.yml` only triggers on push/PR to `develop`/`main`, which this branch has never touched, and pushing was explicitly not authorized during 22-08's own execution. Whether the analyzer is genuinely 0 on Flutter 3.38.10, whether the FFI-adjacent test suite runs cleanly on `ubuntu-latest`, and whether the YAML actually schedules and runs as written are all state-transition facts a grep/presence check cannot see — they require one real execution."
---

# Phase 22: Codebase hygiene — standards config, dead code deletion, analyzer to zero, CI gates — Verification Report

**Phase Goal:** Make the codebase's own rules mechanically enforceable and get the tree clean under
them — without changing behaviour anywhere. Ends with analyzer at zero, a green test suite, and CI
actually enforcing.
**Verified:** 2026-07-30T12:21:22Z
**Status:** human_needed
**Re-verification:** No — initial verification (phase shipped 2026-07-28; `verify` step never ran until now)

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Every never-imported `lib/` file, the dead test, and the dead `google_fonts` dependency are gone; the duplicate radius alias is collapsed | ✓ VERIFIED | All 17 files from `22-01-DELETIONS.md` confirmed absent on disk today; `pubspec.yaml`/`pubspec.lock` case-insensitive `grep -i google_fonts` = 0 hits; `grep -rn radius3xl lib test` = 0 hits |
| 2 | The brace rule (every `if` braced, body on its own line) has a working, self-testing CI gate | ✓ VERIFIED | `tool/check_brace_style.sh` present, executable, self-test proven to fail on an injected defect and pass clean (22-02-SUMMARY.md quotes both runs); orchestrator's clean-tree re-run today: `--count` = 0 |
| 3 | Every `if` in `lib/`/`test/` is actually braced (not just gate-able) | ✓ VERIFIED | Orchestrator's clean-tree re-run today: `tool/check_brace_style.sh --count` = 0 |
| 4 | The 9 hand-written widgets wearing a `.g.dart` filename are renamed and stay renamed; no hand-written file wears a generated-code filename | ✓ VERIFIED | `find lib -name '*.g.dart'` today returns only `lib/hive/models/*.g.dart`, `lib/hive_registrar.g.dart`, `lib/tokeninfo/token_model.g.dart` — all genuinely generated; the 9 renamed files (`isactive_false.dart`, `isactive_true.dart`, `genius_back_button.dart`, `incorrect_pin.dart`, `recoveryword.dart`, `registration_header.dart`, `wallet_information.dart`, `wallet_preview.dart`, `wallets_overview.dart`) all exist under their plain-`.dart` names |
| 5 | `flutter analyze` reports 0 and exits 0, in both `geniuswallet` and `packages/genius_api`, without widening the generated-code exclusion beyond what was measured | ✓ VERIFIED | Orchestrator's clean-tree re-run today: root and `packages/genius_api` both "No issues found!" exit 0; `analysis_options.yaml` exclude list is exactly `lib/**/*.g.dart`, `lib/*.g.dart`, `lib/**/*.freezed.dart`, `banxa`, `squidrouter` (unchanged from 22-06); `packages/genius_api/analysis_options.yaml` excludes only `lib/ffi/**`, `lib/proto/**` (unchanged from 22-05) |
| 6 | The phase changed no behaviour: every non-identity edit (5 `mounted`/`context.mounted` guards, 20 `avoid_dynamic_calls` retypes, 17 `unawaited()` wraps) is individually recorded and justified | ✓ VERIFIED | `22-04-SEMANTIC-DELTAS.md` and `22-06-SEMANTIC-DELTAS.md` read in full; spot-checked 3 sites against the current tree (`banxa_api_services.dart:240` still `unawaited(checkStatus())`, `network_dropdown_selector.dart` still bare `mounted` guards, `recovery_phrase_screen.dart:195` still `context.mounted`) — all match the recorded deltas exactly; 22-07 (goldens) is recorded as CANCELLED, not silently dropped, and no artifact in the phase claims golden coverage |
| 7 | CI actually enforces the codebase's own rules on a real GitHub run | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `quality` job exists in `build.yml`, is syntactically valid YAML, matches the `build` job's Flutter action SHA (`1a449444c387b1966244ae4d4f8c696479add0b2`) and version (`3.38.10`) exactly, and every referenced script (`check_brace_style.sh`, `check_no_new_key_logging.sh`, `check_onboarding_seed_safety.sh`, `verify_additive_boundary.sh`, `check_raw_colors.sh`) exists and is executable — but it has **never run once**. See below. |

**Score:** 6/7 truths verified (1 present + wired, behavior-unverified)

### Why truth #7 is not VERIFIED

This is the phase's hardest requirement (ORG-01) and the task explicitly asked for an honest ruling
rather than a rubber stamp.

- `gh run list --workflow=build.yml --limit 30` shows no run after **2026-07-27T07:34:39Z**. The
  `quality` job was added in commit `31dea02` on **2026-07-28**. There is no run of `build.yml` on
  or after that date, on any branch — the job has not executed once, not even accidentally.
- `gh run list --branch ui-redesign-port` is empty. `build.yml`'s triggers are `push`/`pull_request`
  scoped to `develop`/`main` only; this branch has never touched either, so nothing here has ever
  fired the workflow.
- 22-08-SUMMARY.md itself is honest about this: it lists "Whether the `quality` job actually runs
  green on GitHub Actions" as the single most important unproven item, names SDK version skew
  (CI pins Flutter 3.38.10, all local verification was on 3.41.9) and FFI native-artifact risk on
  `ubuntu-latest` as the two live risks, and explicitly states Task 2's own acceptance criterion
  ("the quality job has been executed at least once on GitHub … not inferred from a local run") was
  **not met**, because pushing was not authorized in that session.
- ROADMAP.md's own Phase 22 entry already carries this caveat in its own words: *"CI `quality` job
  wired and blocking. One caveat: the CI job has never actually run — it needs a push, which was not
  authorised."* This verification confirms that caveat still holds, unchanged, two days later.
- The config is not empty theatre — it is a real, syntactically valid job with the right steps, the
  right Flutter pin, and a deliberately-scoped single non-blocking step (documented, not hidden).
  But "wired and blocking" is not the same claim as "mechanically enforced," and the difference is
  exactly the gap between a config file that looks right and a gate that has been observed to
  actually fire. A syntax error, a wrong working directory, or a step that silently no-ops (as
  `check_no_new_key_logging.sh`'s original diff-mode did, before 22-08 caught and fixed that exact
  failure mode by inspection) would not be visible from the file alone — that is precisely why 22-08's
  own Task 2 demanded a real run and did not get one.

**Ruling:** ORG-01 is **not fully earned**. The mechanism is present, well-documented, and plausible,
but "mechanically enforced" is a claim about observed behaviour, and no observation exists. This is
recorded as `PRESENT_BEHAVIOR_UNVERIFIED`, not `FAILED` — there is no evidence anything is broken,
only an absence of evidence that it works. It routes to human verification below.

**Consequence for REQUIREMENTS.md:** `.planning/REQUIREMENTS.md` currently marks ORG-01 `[x]` complete
with the description "(format, analyze, brace rule, raw colours, the three existing security gates,
tests, patch coverage)". Two problems with that row, found while verifying it:
1. The `[x]` claims a state (CI enforcing) that has never been observed, for the reasons above.
2. **"Patch coverage" is factually wrong today.** `codecov.yml` and the Codecov upload step were
   removed entirely on 2026-07-28 in commit `0212e3c` ("ci: drop Codecov upload and coverage
   generation" — Braian's explicit call, made the same day as 22-08). `codecov.yml` does not exist
   in the tree. The `quality` job's test step no longer even passes `--coverage`. REQUIREMENTS.md's
   ORG-01 row was written retroactively by Phase 23's closeout and did not catch that this specific
   piece of Phase 22's own deliverable had already been reverted before Phase 23 started.

This is a documentation-accuracy finding, not a Phase 22 code defect (Phase 22's own commits are
internally consistent — 22-08 added coverage, `0212e3c` removed it the same day, both are in the
git log). It is flagged here because the task instructions asked to check whether REQUIREMENTS.md
overclaims and this project has a standing no-unearned-PASS rule.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `22-01-DELETIONS.md` | per-file deletion evidence | ✓ VERIFIED | Exists, lists all 17 files with LOC + reference counts + adjudication |
| `tool/check_brace_style.sh` | brace-rule gate with `--count`/`--self-test`/`--fix` | ✓ VERIFIED | Exists, executable, `--count` = 0 on clean tree today |
| `.editorconfig` | editor defaults for non-Dart file types | ✓ VERIFIED | Exists at repo root |
| `22-04-SEMANTIC-DELTAS.md` | 35 `mounted`-guard sites individually recorded | ✓ VERIFIED | Exists; all 35 sites listed with before/after and an analyzer-diagnostic proof |
| `22-05-RESIDUE.md` | 101-issue non-automatable tail, classified per rule | ✓ VERIFIED | Exists; rule-count sanity check sums to 101 |
| `22-06-SEMANTIC-DELTAS.md` | every non-identity 22-06 change recorded | ✓ VERIFIED | Exists; 5 guards + 20 retypes + 17 `unawaited()` sites all individually justified |
| `deferred-items.md` | pre-existing, out-of-scope findings logged not silently fixed | ✓ VERIFIED | Exists; tracks the 2 `verify_additive_boundary.sh` false positives across 22-03/22-04/22-06 consistently |
| `cancelled/22-07-CANCELLED.md` | golden-test cancellation record | ✓ VERIFIED | Exists; records Braian's decision twice, and the effect on Phase 22's exit criteria (none) |
| `.github/workflows/build.yml` `quality` job | CI gate wiring | ⚠️ PRESENT, UNVERIFIED BEHAVIOR | Exists, valid YAML, matches `build` job's SHA/version, all referenced tool scripts present on disk — never executed |
| `codecov.yml` | patch-coverage policy | ✗ REMOVED (post-phase, sanctioned) | Deleted same-day by commit `0212e3c`, superseding 22-08's own deliverable; not a phase-22 defect, but REQUIREMENTS.md's ORG-01 description was not updated to match |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `tool/check_brace_style.sh --self-test` | brace-rule enforcement | proof the gate can fail | ✓ WIRED | 22-02-SUMMARY.md quotes a deliberately-broken run producing 2 FAIL lines, then a clean revert to 9/9 PASS |
| `tool/check_brace_style.sh --fix` classifier | `tool/check_brace_style.sh` (gate) classifier | shared `classify_if`/`terminator_scan` function | ✓ WIRED | Same code path confirmed by reading 22-04-SUMMARY.md's description and the file itself; no drift risk by construction |
| `tool/verify_additive_boundary.sh` | `WalletsOverview` shadow-import boundary | pinned path + injected-probe proof | ✓ WIRED | 22-03 injected a second importer, confirmed the script FAILs and names the offender, then reverted — a real negative-case proof, not an assumption |
| `.github/workflows/build.yml` `quality` job | the 5 `tool/*.sh` gates + `dart format`/`flutter analyze`/`flutter test` | `run:` steps invoking each script/command | ⚠️ WIRED, NEVER EXECUTED | Every step present with the right invocation; `verify_additive_boundary.sh` deliberately `continue-on-error: true` with an in-file rationale comment (2 documented pre-existing false positives, Check 1 — the logic that matters — passes clean) |
| `.github/workflows/build.yml` `quality` job | `build` job's Flutter SDK pin | byte-identical action SHA + version | ✓ VERIFIED | Both jobs pin `subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2` at `flutter-version: 3.38.10` |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| ORG-01 | 22-02, 22-08 | Codebase's own rules mechanically enforced in CI | ⚠️ PRESENT, BEHAVIOR UNVERIFIED | See "Why truth #7 is not VERIFIED" above. REQUIREMENTS.md's `[x]` and "patch coverage" clause are both currently inaccurate given the same-day coverage removal and the never-executed job. |
| ORG-02 | 22-01, 22-03 | Dead code removed (files, dependency, misleading filenames) | ✓ SATISFIED | All deletions/renames confirmed still in effect on today's tree |
| ORG-03 | 22-05, 22-06 | `flutter analyze` reports 0, exits 0, both packages | ✓ SATISFIED | Confirmed by orchestrator's clean-tree re-run; exclusion scope unchanged from what 22-05/22-06 measured and justified |

No orphaned requirements found — REQUIREMENTS.md maps exactly ORG-01..03 to Phase 22, matching the
phase's own declared `requirements:` field across all 8 plans.

### Anti-Patterns Found

No `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER` markers found in the phase's key deliverable files
(`tool/check_brace_style.sh`, `22-*-SEMANTIC-DELTAS.md`, `22-*-RESIDUE.md`, `deferred-items.md`,
`build.yml`'s `quality` job). The one `continue-on-error: true` line in `build.yml` is not a debt
marker — it carries an in-file rationale comment naming the exact 2 pre-existing findings and the
condition for flipping it hard, which is the project's own documented pattern for a deliberate,
reviewed deviation, not an unresolved shortcut.

The `lib/hive_registrar.g.dart` `directives_ordering` glob-matching gap (found in 22-05, fixed in
22-06 by widening the exclude glob to `lib/*.g.dart` + `lib/**/*.g.dart`) was a real, if minor, gate
bug caught and fixed within the phase itself — not left as residue.

### Human Verification Required

### 1. Confirm the `quality` job actually runs green on GitHub Actions

**Test:** Trigger a real execution of `.github/workflows/build.yml`'s `quality` job — the simplest
path is a PR from this branch (or its eventual merge target) into `develop`, since that is the
trigger the workflow already has. `workflow_dispatch` on `build.yml` does not currently expose the
`quality` job as a standalone target (the `inputs:` are release-build inputs), so a full PR/push
against `develop`/`main` is the realistic path.
**Expected:** `dart format`, `flutter analyze lib test`, the brace self-test + gate, the raw-colour
self-test + gate, and both hard security gates (`check_no_new_key_logging.sh`, `check_onboarding_
seed_safety.sh`) all pass on CI's pinned Flutter 3.38.10. `flutter test --test-randomize-ordering-
seed random` passes. `verify_additive_boundary.sh` is allowed to report its 2 documented pre-existing
false positives without failing the job (`continue-on-error: true`).
**Why human:** This is a real-infrastructure execution outcome (SDK version skew, native-artifact
availability on `ubuntu-latest`, and the workflow scheduler actually picking up the job) that no
static check performed by this verifier — or by 22-08's own execution — can substitute for. It also
requires a `git push`, which per the project's own memory ("No PR without authorization") and 22-08's
explicit instruction is not something an autonomous session should do unprompted.

### Gaps Summary

No hard blockers were found: every file-existence, deletion, rename, and analyzer/brace-count claim
re-checked against the current clean tree holds exactly as the SUMMARYs describe, and nothing has
regressed under the two later phases (23, and the closeout commits) that have since landed on top of
this one. The dead-code deletions (ORG-02) and the zero-analyzer state (ORG-03) are fully earned and
verified.

The one open item is ORG-01: the CI enforcement mechanism is real, well-built, and internally
consistent, but it has never been observed to actually run, and that gap is not closeable by further
reading of the repository — it requires triggering GitHub Actions for real, which is a decision for
a human (it needs a push/PR the project's own rules reserve for explicit authorization). Until that
observation exists, "CI actually enforcing" is a claim resting on configuration correctness alone,
which is exactly the category of claim this project's own no-unearned-PASS rule exists to catch
before it is called complete.

Two secondary, low-severity documentation findings are noted for the record (not gaps against Phase
22's own deliverables, since both post-date it by same-day or later decisions):
- REQUIREMENTS.md's ORG-01 row still lists "patch coverage" as enforced; it was removed the same day
  (commit `0212e3c`) and no longer exists in the tree.
- ROADMAP.md line 1116 carries an orphan `- [ ] 22-07-PLAN.md` duplicating the correct `- [-]
  22-07-PLAN.md` (cancelled) entry at line 1137. Already spotted by the orchestrator; recorded here
  per instruction, not fixed.

---

_Verified: 2026-07-30T12:21:22Z_
_Verifier: Claude (gsd-verifier)_
