---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
plan: 08
subsystem: infra
tags: [github-actions, ci, codecov, flutter-test, dart-format, flutter-analyze, security-gates]

requires:
  - phase: 22-codebase-organization-standards-config-dead-code-deletion-th (plans 01-06)
    provides: "clean baseline the gates enforce -- analyzer 0/exit 0, dart format clean, brace gate 0, all three tool/*.sh security gates green, flutter test 512/0"
provides:
  - "a `quality` job in .github/workflows/build.yml -- dart format, flutter analyze, brace-style gate (+ self-test), 3 security gates, flutter test --coverage with randomized ordering"
  - "codecov.yml patch-coverage policy (project auto + 1% threshold, patch 80%)"
  - "tool/check_no_new_key_logging.sh --scan-tree mode, so the gate can actually fail in CI instead of vacuously passing"
affects: [23-design-system-consolidation-theme-tokens-shared-components]

tech-stack:
  added: [codecov/codecov-action@v5.5.5 (pinned SHA)]
  patterns:
    - "secret-presence guard via a prior step's $GITHUB_OUTPUT, checked in a later step's if: -- GitHub Actions disallows referencing secrets.* directly in if: conditionals"
    - "non-blocking gate via continue-on-error, explicitly justified in a workflow comment, reserved for known pre-existing false positives only"

key-files:
  created:
    - codecov.yml
  modified:
    - .github/workflows/build.yml
    - tool/check_no_new_key_logging.sh
    - .gitignore

key-decisions:
  - "No golden CI step added -- 22-07 was deferred (no baseline exists); a CI step running zero golden tests would pass vacuously, which is the exact anti-pattern this phase guards against."
  - "verify_additive_boundary.sh wired non-blocking (continue-on-error: true), explicitly justified in-file -- it has 2 known pre-existing false positives (6 private-class name collisions, 1 WIRE-02 prose match) from Phase 8/16, unrelated to this plan, documented across 22-03/22-04/22-06's deferred-items.md. This is a deliberate deviation from the plan's own acceptance criterion ('no continue-on-error anywhere in the file') -- see Deviations."
  - "Dropped the plan's assumed `flutter test --report-on lib` flag -- it does not exist on this SDK (checked -h -v). flutter test --coverage already scopes lcov.info to lib/ only by default; confirmed locally with zero test/ entries in the generated lcov.info."
  - "Added tool/check_no_new_key_logging.sh --scan-tree mode -- the original single-file diff-against-index mode is always empty on a fresh CI checkout (vacuous pass regardless of content); --scan-tree checks the file's current content instead, so the gate can genuinely fail."
  - "Randomized test ordering (--test-randomize-ordering-seed random) enabled in CI -- ran green locally across 3 independent seeds (multiple runs, 512/512 each time) with no inter-test leakage found."
  - "CODECOV_TOKEN not configured -- upload step guards on a prior step's computed output and skips itself with a message rather than failing the build."

requirements-completed: [ORG-01]

coverage:
  - id: D1
    description: "quality job added to build.yml with all 7 gates (format, analyze, brace self-test, brace gate, 3 security gates, test+coverage), no native toolchain, Flutter SHA/version matching the build job"
    requirement: ORG-01
    verification:
      - kind: other
        ref: "grep -qE '^  quality:' .github/workflows/build.yml; grep -q 'set-exit-if-changed'; grep -q 'check_brace_style.sh'; grep -q 'verify_additive_boundary.sh' -- all confirmed FOUND; python yaml.safe_load confirms the file parses"
        status: pass
    human_judgment: true
    rationale: "A real GitHub Actions run of this job has not been observed -- pushing to prove it was explicitly not authorized this session. Local validation (YAML parses, every command runnable from the current tree, flags verified against `flutter test -h -v`) is the strongest evidence obtainable without a push; whether the job is actually green on GitHub's runners (in particular on the CI-pinned Flutter 3.38.10, which differs from the local 3.41.9 SDK) is unproven and requires a human to trigger and observe a real run."
  - id: D2
    description: "codecov.yml patch-coverage policy (project auto + patch 80%) with upload wired non-blocking on a missing token"
    requirement: ORG-01
    verification:
      - kind: other
        ref: "test -f codecov.yml; grep -q patch; grep -q project; grep -q 'coverage-path\\|lcov.info' .github/workflows/build.yml -- confirmed"
        status: pass
    human_judgment: true
    rationale: "The token-guard logic (skip-with-message pattern) was verified by code inspection, not by an actual CI run with a genuinely absent secret in GitHub's environment. Whether the upload step behaves correctly end-to-end on real CI is unproven without a push."

duration: ~35min
completed: 2026-07-28
status: complete
---

# Phase 22 Plan 08: Wire the quality gates into CI Summary

**Added a `quality` job to `.github/workflows/build.yml` (format, analyze, brace rule + self-test, 3 security gates, test+coverage) and a `codecov.yml` patch-coverage policy -- proven locally exhaustively, but the actual GitHub Actions run is unproven because pushing was not authorized this session.**

## Performance

- **Duration:** ~35 min
- **Completed:** 2026-07-28
- **Tasks:** 3 (of the plan's 3 -- Task 2's "prove it on real CI" acceptance criterion is explicitly unmet; see below)
- **Files modified:** 4 (`.github/workflows/build.yml`, `codecov.yml` [new], `tool/check_no_new_key_logging.sh`, `.gitignore`)

## Accomplishments
- A `quality` job now exists in `build.yml`: `dart format`, `flutter analyze lib test`, `tool/check_brace_style.sh --self-test` + the gate itself, the three `tool/*.sh` security gates, and `flutter test --coverage --test-randomize-ordering-seed random`. Runs on `ubuntu-latest`, no native toolchain, `actions/checkout` and `subosito/flutter-action` pinned to the exact same SHA + `flutter-version: 3.38.10` as the `build` job.
- `codecov.yml` encodes the locked coverage policy (`project: auto` + 1% threshold, `patch: 80%`) with the "why not 100%" rationale as an in-file comment. The upload step is wired non-blocking on a missing `CODECOV_TOKEN`.
- Fixed a latent design flaw in `tool/check_no_new_key_logging.sh` discovered while wiring it: its only mode diffs the working tree against the index, which is always empty on a fresh CI checkout -- it would have passed vacuously on every CI run regardless of what the file actually contained. Added a `--scan-tree` mode that checks the file's current content instead, verified to genuinely fail against a synthetic `print()` call.
- Corrected a plan assumption: `flutter test --report-on lib` does not exist on this SDK (`flutter test -h -v` has no such flag). `flutter test --coverage` already scopes `lcov.info` to `lib/` by default -- verified locally (zero `test/` entries in the generated report).

## Task Commits

Each task was committed atomically:

1. **Task 1 + supporting fixes: quality job wired into build.yml** - `31dea02` (feat)
2. **Task 3: codecov.yml patch-coverage policy** - `3250714` (feat)

_Task 2 ("prove the job actually passes on CI's pinned SDK") produced no file changes -- it cannot be completed without a push, which was explicitly not authorized this session. See "What is UNPROVEN" below._

**Plan metadata:** (this SUMMARY's own commit, made after this file)

## Files Created/Modified
- `.github/workflows/build.yml` - new `quality` job (7 gate steps + codecov guard/upload); `build` job untouched (diff is a pure append, confirmed via `git diff` showing 0 deletions in the existing job)
- `codecov.yml` - new file: `project: auto` (1% threshold) + `patch: 80%`, rationale comment in-file
- `tool/check_no_new_key_logging.sh` - added `--scan-tree` mode (backward-compatible; the original single-file diff mode is unchanged and still used by any future plan session)
- `.gitignore` - added `/coverage/` (the new coverage step's output directory; was previously untracked-but-unignored)

## Decisions Made

1. **No golden CI step.** 22-07 was deferred at its blocking-human gate (no `alchemist`, no baseline exists). The plan referenced goldens in ~3 places; all omitted. A CI step running zero golden tests would pass every time regardless of visual regressions -- exactly the vacuous-gate anti-pattern this phase exists to prevent.

2. **`verify_additive_boundary.sh` wired non-blocking, not fixed.** Locally confirmed the exact same 2 pre-existing findings 22-03/22-04/22-06 already documented in `deferred-items.md`: 6 private (`_`-prefixed) "duplicate class name" false positives in Check 2 (Dart privacy is library-scoped -- these can never actually collide) and 1 "WIRE-02" prose false positive in Check 3 (`global_swap_fab_host.dart:21`, a work-item-ID reference, not one of Alex's Parabeac demo tags). Check 1 -- the actual shadow-import-boundary logic this phase's threat model cares about (Loading/Splash/WalletsOverview) -- passes cleanly. Considered fixing both: Check 2's regex fix (exclude `_`-prefixed names from the census) is mechanical and low-risk, but Check 3's fix requires either weakening the tripwire's matching logic or editing an unrelated file's comment, both flagged by the prior plans as needing separate review. Rather than fix one and leave the other, or touch a security-adjacent tripwire without review, the gate is wired `continue-on-error: true` with a workflow comment explaining exactly why and how to flip it hard later. **This is a deliberate deviation from the plan's own acceptance criterion** ("No `continue-on-error` appears anywhere in the file") -- the plan's automated Task 1 `<verify>` grep (`! grep -q 'continue-on-error' ... && echo GATES_WIRED`) will now report failure if re-run. That is expected and intentional; re-running it is not proof of a regression.

3. **Dropped `--report-on lib`.** Verified via `flutter test -h -v` that no such flag exists on the local 3.41.9 SDK. Confirmed `flutter test --coverage` alone already produces an `lcov.info` scoped to `lib/**` only (spot-checked: 34 `SF:` entries, all under `lib\`, zero under `test\`). No coverage-scoping mechanism was needed beyond the default.

4. **Enabled randomized test ordering.** Ran `flutter test --no-pub --test-randomize-ordering-seed random` three separate times locally (seeds observed: unlogged run #1, `791088259`, `3668381941`) -- 512/512 pass every time, no inter-test state leakage found. Added to the CI step per the plan's instruction to enable if green.

5. **Did not attempt SDK-pin alignment.** The CI-pinned `flutter-version: 3.38.10` differs from the local dev SDK (3.41.9). The plan's Task 2 called for observing a real CI run to decide whether to realign the pin; that observation requires a push, which was not authorized. The pin is unchanged. This is the single largest unproven risk in this plan -- see below.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `tool/check_no_new_key_logging.sh`'s only mode is vacuous on a fresh CI checkout**
- **Found during:** Task 1 (wiring the security gates)
- **Issue:** The script's sole mode diffs the working tree against the index with no ref arguments. On a freshly checked-out CI runner the working tree and index are identical, so the diff is always empty -- the gate would print "OK" and exit 0 regardless of what the file contains, a vacuous pass.
- **Fix:** Added a `--scan-tree [file...]` mode that checks the CURRENT content of the given file(s) (default: `lib/account/sdk_account_manager.dart`, the one file this script has ever been run against per Phase 4-06/GAP-03) for any `print`/`debugPrint`-family call, comment-lines stripped. The original single-file diff mode is untouched and still available for a developer mid-edit in a plan session.
- **Files modified:** `tool/check_no_new_key_logging.sh`
- **Verification:** `bash tool/check_no_new_key_logging.sh --scan-tree` -> `OK: no key logging in lib/account/sdk_account_manager.dart` (exit 0); regression-tested the original mode still works unchanged; sanity-tested against a synthetic file containing `print("leak");` -> correctly fails with the offending line printed (exit 1).
- **Committed in:** `31dea02`

**2. [Rule 1 - Bug] Plan assumed a `flutter test` flag that does not exist**
- **Found during:** Task 3 (patch-coverage policy)
- **Issue:** The plan specified `flutter test --coverage --report-on lib`. `flutter test -h -v` has no `--report-on` flag on the local SDK (3.41.9); running the command errors with `Could not find an option named "--report-on"`.
- **Fix:** Dropped `--report-on lib`. Verified `flutter test --coverage` alone already scopes `coverage/lcov.info` to `lib/**` (spot-checked on a subset test run: all 34 `SF:` entries under `lib\`, none under `test\`), so no replacement flag or filtering step was needed.
- **Files modified:** `.github/workflows/build.yml`
- **Verification:** Local `flutter test --no-pub --coverage test/account/sdk_row_actions_test.dart` run, inspected the generated `coverage/lcov.info` directly.
- **Committed in:** `31dea02`

**3. [Rule 2 - Missing Critical] `.gitignore` had no entry for the new coverage output**
- **Found during:** Task 3
- **Issue:** Adding `--coverage` to the test step (both locally and in CI) produces `coverage/lcov.info`, which was not gitignored -- would surface as untracked/dirty working tree for every future local run.
- **Fix:** Added `/coverage/` to `.gitignore`, matching the existing `/build/` entry's convention.
- **Files modified:** `.gitignore`
- **Verification:** `git status --short` after a coverage-generating test run shows no untracked `coverage/` entry.
- **Committed in:** `31dea02`

**4. [Rule 4-adjacent, orchestrator-authorized] `verify_additive_boundary.sh` wired non-blocking, contradicting the plan's own acceptance criterion**
- See "Decisions Made" item 2 above for the full reasoning. This is flagged separately here because it is a direct, acknowledged contradiction of a stated `<acceptance_criteria>` line in 22-08-PLAN.md ("No `continue-on-error` appears anywhere in the file"), not a silent auto-fix. The task's own instructions (outside the plan file) explicitly authorized this choice ("Decide deliberately: either wire it non-blocking with a TODO, or wire it hard and fix the 2 false positives first... State which you chose and why. Do not wire it hard and leave CI red.").
- **Committed in:** `31dea02`

---

**Total deviations:** 4 (2 Rule 1/3 auto-fixes necessary for the gates to be non-vacuous, 1 Rule 2 housekeeping fix, 1 explicit orchestrator-authorized deviation from a plan acceptance criterion).
**Impact on plan:** All four were necessary for the gates to do real work rather than decorate the workflow file. No scope creep beyond what CI-wiring correctness required.

## Issues Encountered

**Task 2's acceptance criteria cannot be met this session.** The plan requires observing a real GitHub Actions run and quoting its result. Proving that requires `git push`, which the task instructions explicitly stated was not authorized ("do not push, do not open a PR, do not touch any remote"). No commits were pushed; `git log` shows only local commits on `ui-redesign-port`.

## What is PROVEN (verified locally, exact commands run)

- `dart format --output=none --set-exit-if-changed lib test` -> exit 0 ("Formatted 305 files (0 changed)")
- `flutter analyze lib test` -> "No issues found!" (0 issues, exit 0)
- `bash tool/check_brace_style.sh --count` -> `0`
- `bash tool/check_brace_style.sh --self-test` -> all 20 PASS lines, exit 0
- `bash tool/check_no_new_key_logging.sh --scan-tree` -> `OK: no key logging in lib/account/sdk_account_manager.dart`
- `bash tool/check_onboarding_seed_safety.sh` -> "PASSED -- all six Section 3 checks hold over the finished tree"
- `bash tool/verify_additive_boundary.sh` -> FAILS with exactly the 2 documented pre-existing findings (Check 2: 6 private-class names; Check 3: 1 WIRE-02 prose match), nothing new
- `flutter test --no-pub` -> 512/512 pass
- `flutter test --no-pub --test-randomize-ordering-seed random` -> 512/512 pass, run 3 separate times with different seeds
- `.github/workflows/build.yml` and `codecov.yml` both parse as valid YAML (`yaml.safe_load`)
- `git diff` on `build.yml` is a pure append (0 deletions) -- the existing `build` job is untouched
- The Flutter action SHA (`1a449444c387b1966244ae4d4f8c696479add0b2`) and `flutter-version: 3.38.10` in the new `quality` job are copied verbatim from the `build` job's `Setup Flutter` step

## What is UNPROVEN (requires a push the operator has not authorized)

- **Whether the `quality` job actually runs green on GitHub Actions.** This is the single most important open item. In particular:
  - **SDK version skew:** CI pins Flutter 3.38.10; the local SDK used for all verification above is 3.41.9. `flutter analyze`'s diagnostic set is version-sensitive -- "0 issues on 3.41.9" does not prove "0 issues on 3.38.10." This was explicitly called out as unprovable-without-a-push in the task instructions and remains unresolved.
  - **Native-artifact risk to `flutter test`:** `packages/genius_api`'s FFI bridge (`ffi_bridge_prebuilt.dart`) falls back to `DynamicLibrary.executable()` on any non-Android/iOS/macOS platform (i.e., wraps the current process rather than opening a real `.so`/`.dll`), which is why `flutter test` succeeds locally on Windows without a native build. `ubuntu-latest` in the `quality` job hits the identical code path. This is reasoning by code-path analogy, not a real Linux CI run, and is not proof.
  - **`paths-ignore`:** `build.yml`'s `pull_request` trigger ignores `.github/**`, so a PR touching only workflow files will not fire this job -- a `workflow_dispatch` run or a trivial source-touching PR is needed to exercise it for the first time, per the plan's own `<environment>` note. Neither was done this session.
- **The Codecov upload's actual behavior on real CI.** The skip-on-missing-token guard was verified by code inspection (the `$GITHUB_OUTPUT` pattern is standard and the logic is straightforward), but a live run with a genuinely absent `CODECOV_TOKEN` secret in GitHub's own execution environment has not been observed.
- **The `codecov/codecov-action@0fb7174895f61a3b6b78fc075e0cd60383518dac` pin.** Resolved via the GitHub API (`gh api repos/codecov/codecov-action/git/refs/tags/v5.5.5` -> tag object -> commit SHA, tag itself GPG-verified per the API response) rather than a documentation reference, so the SHA is confirmed to correspond to the real, signed `v5.5.5` release tag. Whether the action itself behaves correctly when actually invoked is untested.

## User Setup Required

**External service configuration required to finish enabling Codecov gating** (per the plan's `user_setup`):
1. Enable the GeniusWallet repository on codecov.io ("Add new repository").
2. Generate a Repository Upload Token: codecov.io -> the GeniusWallet repository -> Settings -> Repository Upload Token.
3. Store it as a GitHub Actions repository secret named `CODECOV_TOKEN` (repo Settings -> Secrets and variables -> Actions).

Until this is done, the `quality` job's "Upload coverage to Codecov" step prints a skip message and exits 0 -- it does not fail the build. The `patch: 80%` / `project: auto` policy in `codecov.yml` only becomes an active PR status check once Codecov has received at least one upload.

**Also required to close the loop on this plan:** a human (not this session) needs to push this branch (or trigger `workflow_dispatch`) and confirm the `quality` job is actually green on GitHub's runners, per Task 2's unmet acceptance criteria above. If it is red, the two likely causes are analyzer diagnostics unique to Flutter 3.38.10, or a `flutter test` native-artifact failure on `ubuntu-latest` -- both documented above with the reasoning for why they were expected to be low-risk but not treated as proven.

## Next Phase Readiness

Phase 22's mechanical-hygiene half is code-complete: analyzer 0, brace rule enforced at 0, three security gates present (two hard, one deliberately non-blocking with a documented reason), dart format clean, tests 512/0, and a `quality` CI job exists wired to all of it. It is **not yet independently shippable as "gates live and proven"** -- that status requires the push-and-observe step this session could not perform. Phase 23 (which 22-07-DEFERRED.md already flagged as blocked on the golden-baseline decision, independent of this plan) should not assume the CI gates are confirmed green until a human closes that loop.

---
*Phase: 22-codebase-organization-standards-config-dead-code-deletion-th*
*Completed: 2026-07-28*
