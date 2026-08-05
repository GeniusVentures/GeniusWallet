---
phase: 03-gw-component-library
plan: 01
subsystem: infra
tags: [flutter, pubspec, dependencies, mobile_scanner, shimmer, assets, shadow-name-guard, bash]

# Dependency graph
requires:
  - phase: 02-design-tokens-verification-loop
    provides: Phase 2 token vocabulary (GeniusWalletColors/Consts/Typography/etc), google_fonts, kShowDevTools dev-gating pattern, DevToolsWidget with a Tokens button, /dev/token-probe route pattern
provides:
  - assets/images/textures/noise.png bundled in-repo and declared in pubspec (DS-04, both halves)
  - mobile_scanner ^5.2.3 and shimmer ^3.0.0 resolved as pubspec dependencies (DS-02 prerequisite for gw_qr_scanner.dart and gw_loading_state.dart)
  - tool/verify_additive_boundary.sh — the mechanical shadow-name guard every later plan in Phase 3 runs
  - tool/shadow-baseline.txt — captured, justified baseline for the guard's duplicate-class census
  - .planning/phases/03-gw-component-library/03-SHADOW-NAMES.md — full writeup of all 3 shadow pairs
affects: [03-02, 03-03, 03-04, 03-05, 03-06, 03-07, 03-08, 03-09, 03-10]

tech-stack:
  added: [mobile_scanner ^5.2.3, shimmer ^3.0.0]
  patterns:
    - "Captured-baseline subset-check guard (tool/shadow-baseline.txt + tool/verify_additive_boundary.sh) — proven to pass on a clean tree AND trip on a real violation, both directions verified before commit"

key-files:
  created:
    - assets/images/textures/noise.png
    - tool/verify_additive_boundary.sh
    - tool/shadow-baseline.txt
    - .planning/phases/03-gw-component-library/03-SHADOW-NAMES.md
  modified:
    - pubspec.yaml
    - pubspec.lock
    - macos/Flutter/GeneratedPluginRegistrant.swift

key-decisions:
  - "mobile_scanner inserted immediately after qr_flutter in pubspec.yaml's dependencies block (matches the reference worktree's relative ordering exactly); shimmer inserted immediately after app_links (closest analogous position — the reference worktree's own ordering differs from this repo's from that point on, since this repo already carries google_fonts earlier in the list)"
  - "Guard's Check 2 census pattern uses `^(abstract )?class` (not just `^class`) to also catch abstract-class name collisions; verified this returns the identical 4-name set as the plan's plain `^class` example on the current tree, so no behavior gap"
  - "Shadow-path import matching uses full `package:genius_wallet/...` strings (not bare filename substrings) because this codebase has zero relative imports anywhere in lib/ (verified: `grep -rl \"^import '\\.\\./\" lib/` returns 0 files) — the more specific pattern is strictly safer with no coverage loss"

requirements-completed: [DS-04, DS-02]

coverage:
  - id: D1
    description: "assets/images/textures/noise.png exists in-repo (16580 bytes, binary-identical to the reference worktree copy) and is declared in pubspec.yaml's assets block via the exact d8db88c hunk"
    requirement: "DS-04"
    verification:
      - kind: other
        ref: "wc -c assets/images/textures/noise.png == 16580; cmp against reference worktree copy returned identical; grep -qE '^\\s*- assets/images/textures/\\s*$' pubspec.yaml"
        status: pass
    human_judgment: false
  - id: D2
    description: "mobile_scanner ^5.2.3 and shimmer ^3.0.0 added to pubspec.yaml dependencies and resolve cleanly via flutter pub get with no version conflict against develop's existing constraint set"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "flutter pub get — exit 0, 'Changed 2 dependencies!', + mobile_scanner 5.2.3, + shimmer 3.0.0, no conflict reported"
        status: pass
    human_judgment: false
  - id: D3
    description: "Both new packages verified legitimate on pub.dev before install (not lookalikes) — publisher and pinned-version existence confirmed via the pub.dev API, per threat T-03-SC"
    verification:
      - kind: other
        ref: "curl https://pub.dev/api/packages/mobile_scanner (publisher juliansteenbakker, github.com/juliansteenbakker/mobile_scanner, version 5.2.3 present in version history) and https://pub.dev/api/packages/shimmer (publisher hnvn, github.com/hnvn/flutter_shimmer, version 3.0.0 present, published 2023-05-21)"
        status: pass
    human_judgment: false
  - id: D4
    description: "tool/verify_additive_boundary.sh exists, exits 0 on the tree as it stands today (before any of Phase 3's 50 component files land), and demonstrably trips non-zero both when a canonical import is repointed to a shadow path and when a 5th unforeseen duplicate class name is introduced in a .g.dart file the analyzer is blind to"
    requirement: "DS-04"
    verification:
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh (clean tree, exit 0); router.dart splash-import repoint probe (exit 1, then git checkout -- lib/navigation/router.dart to restore); canary_dup_probe.g.dart + canary_dup_probe2.dart duplicate-class probe (exit 1, then rm -f to remove); final re-run after removal (exit 0); git status --porcelain lib/ empty"
        status: pass
    human_judgment: false
  - id: D5
    description: "tool/shadow-baseline.txt holds exactly 8 justified data lines (4 pre-existing legitimate bloc-event duplicates, 4 phase-03-shadow entries), each independently re-verified against the working tree, not copied from the plan's prose on trust"
    verification:
      - kind: other
        ref: "grep -v '^#' tool/shadow-baseline.txt | grep -cE '^[A-Za-z_]' == 8; per-entry category/justification grep assertions from the plan's own verify block all passed"
        status: pass
    human_judgment: false
  - id: D6
    description: ".planning/phases/03-gw-component-library/03-SHADOW-NAMES.md records all 3 shadow pairs with verified canonical importer sets/counts, the derivation command, the binding rule, the 4 pre-existing duplicates with their non-hazard reasoning, and the honest run-on-demand (not CI-enforced) scope statement"
    verification:
      - kind: other
        ref: "manual read-back against independently re-derived facts (git show develop:..., grep -rl counts) for all 3 pairs; grep for all 6 required class names in the doc all matched"
        status: pass
    human_judgment: false
  - id: D7
    description: "Nothing visually changed — no .dart source file under lib/ was touched by this plan; both new packages are unimported and noise.png is unreferenced by any reachable code path"
    human_judgment: true
    rationale: "Deferred by the plan itself to 03-10's phase walk (this plan changes pubspec.yaml, requiring a full app restart rather than hot reload — human must fully stop and re-run their debug session before there is anything to observe). Not exercised in this plan by design."

# Metrics
duration: 10min
completed: 2026-07-16
status: complete
---

# Phase 3 Plan 01: Dependencies, Texture Asset, and Shadow-Name Guard Summary

**Landed `mobile_scanner ^5.2.3` + `shimmer ^3.0.0` as resolved pubspec dependencies, bundled the missing `noise.png` binary with its non-recursive asset-dir declaration (DS-04 both halves), and built `tool/verify_additive_boundary.sh` — a captured-baseline guard proven in both directions to catch the phase's central shadow-name hazard.**

## Performance

- **Duration:** 10 min
- **Started:** 2026-07-16T19:53:30Z
- **Completed:** 2026-07-16T20:03:28Z
- **Tasks:** 2/2
- **Files modified:** 7 (4 created, 3 modified)

## Accomplishments
- `assets/images/textures/noise.png` copied from the read-only reference worktree, verified 16580 bytes and byte-identical (`cmp`) to the source — the binary half of DS-04
- `d8db88c`'s pubspec declaration (`- assets/images/textures/`) carried verbatim, including its comment — `d8db88c` is not an ancestor of this branch (`git merge-base --is-ancestor` confirmed), so it needed manual re-application, not a cherry-pick
- `mobile_scanner ^5.2.3` and `shimmer ^3.0.0` added to `pubspec.yaml`; both verified legitimate via the live pub.dev API (publisher + pinned-version existence) before install, per threat T-03-SC
- `flutter pub get` resolved cleanly — `+ mobile_scanner 5.2.3`, `+ shimmer 3.0.0`, "Changed 2 dependencies!", no version conflict against develop's constraint set
- `flutter analyze` gate: **0 errors** (382 pre-existing info/warning-level issues, all outside this plan's scope — none introduced by this plan, since no `.dart` file under `lib/` was touched)
- Derived the shadow-name census independently from the working tree (not copied from the plan's prose): confirmed all 3 pairs' facts (class definitions, exact importer counts — 18 for `Loading`, 1 each for `Splash`/`WalletsOverview`) via direct `git show`/`grep` against both `develop` and `origin/ui-redesign-3.514`
- Built `tool/verify_additive_boundary.sh` (3 checks: shadow import boundary per pair, generic duplicate-class census vs captured baseline including `.g.dart`, WIRE- standing tripwire) and `tool/shadow-baseline.txt` (8 justified entries)
- **Proved both directions on the real tree, in order, before committing:** guard exits 0 on the untouched tree (develop's 4 pre-existing bloc-event duplicates present, no Phase 3 component files landed yet) → guard exits 1 when `router.dart`'s canonical `splash.dart` import is repointed to the shadow path (then restored via `git checkout -- lib/navigation/router.dart`) → guard exits 1 when a 5th unforeseen duplicate (`CanaryDup`) is planted in a `.g.dart` probe file, the one case the analyzer cannot see (then probes removed via `rm -f`) → guard exits 0 again on the restored clean tree, `git status --porcelain lib/` confirmed empty
- Wrote `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md`, extending the UI-SPEC's coverage of `Loading` with the two pairs (`Splash`, `WalletsOverview`/`WalletsOverviewState`) not documented there

## Task Commits

Each task was committed atomically:

1. **Task 1: Carry d8db88c's pubspec declaration, copy the noise.png binary, and add the two new packages** - `8fb5d25` (feat)
2. **Task 2: Record the shadow-name baseline and build the mechanical additive-boundary guard** - `2c3199e` (feat)

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Created/Modified
- `assets/images/textures/noise.png` - the DS-04 binary asset (16580 bytes), previously missing from this repo entirely
- `pubspec.yaml` - added `- assets/images/textures/` asset declaration (carrying `d8db88c`), `mobile_scanner: ^5.2.3`, `shimmer: ^3.0.0`; zero other lines touched, zero deletions
- `pubspec.lock` - regenerated by `flutter pub get`
- `macos/Flutter/GeneratedPluginRegistrant.swift` - regenerated by `flutter pub get` to register `mobile_scanner`'s macOS plugin (automatic side effect of adding a plugin package, not a manual edit)
- `tool/verify_additive_boundary.sh` - the mechanical shadow-name guard (bash, 3 checks, no arguments, prints per-check PASS/FAIL, exits 1 on any violation)
- `tool/shadow-baseline.txt` - captured baseline, 8 data lines (4 `pre-existing`, 4 `phase-03-shadow`), each with a written justification
- `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md` - full writeup: all 3 shadow pairs, derivation command, binding rule, the 4 pre-existing duplicates and why they're not hazards, run-on-demand scope statement

## Decisions Made
- Pubspec dependency insertion points chosen to mirror the reference worktree's relative ordering where the surrounding lines still match (`mobile_scanner` after `qr_flutter`); where this repo's list has already diverged from the reference's ordering (this repo carries `google_fonts` much earlier than the reference does), `shimmer` was placed at the closest analogous position (`app_links`'s neighboring line) rather than forcing an exact but meaningless positional match
- Guard's Check 2 census regex extended to `^(abstract )?class` rather than the plan's literal `^class` example, to also catch abstract-class name collisions generically — verified this produces the identical 4-name result on the current tree, so it's a strict superset of coverage with no behavior change today
- Shadow-path/canonical-path import matching in the guard uses full `package:genius_wallet/...` import strings rather than bare filename substrings, since this codebase has zero relative imports anywhere under `lib/` (independently verified) — this is the more precise match with no coverage gap

## Deviations from Plan

None - plan executed exactly as written. Every fact in the plan's prose (importer counts, class definitions, `d8db88c`'s non-ancestor status, the 4 pre-existing duplicate names) was independently re-verified against the working tree during execution and matched exactly; nothing required correction.

## Issues Encountered
- During the Direction 2a probe (repointing `router.dart`'s import to trip the guard), the scratchpad-fallback backup path in the verify script's shell command silently failed to be created (the primary `/tmp` path had already succeeded, so the `||` fallback never ran, leaving the intended restore variable pointing at a nonexistent file). Recovered immediately using the sanctioned single-file `git checkout -- lib/navigation/router.dart` (this file had no staged/uncommitted changes from Task 1, so this was a safe, targeted restore, not a blanket reset). Confirmed clean via `git status --porcelain lib/navigation/router.dart` before proceeding. No lasting effect — this was a shell-scripting slip during a deliberate probe-and-revert cycle within Task 2's own verification, not a change to any committed file.

## User Setup Required

**This plan changed `pubspec.yaml` — the user's running debug session cannot pick this up via hot reload and must be fully stopped and re-run.** No screen depends on either new package or the new asset yet (both are unimported/unreferenced by construction, per the plan), so there is nothing to visually verify from this plan alone — that observation is deferred to plan 03-10's phase walk, per the plan's own `<verification>` section. When the user next restarts:
1. Close the reference Release exe first if running (shared Hive lock, per `02-VERIFICATION.md`'s standing environment facts).
2. Fully stop the current debug session (hot reload/restart cannot add a pubspec change to an already-running process).
3. Re-run the standing recipe:
   `CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter build windows --debug` (or `flutter run -d windows --debug`, per the user's normal workflow).
4. No specific new behavior to check yet — confirming the app still boots and reaches the dashboard with no startup exception is sufficient for this plan; the asset and packages become observable starting with plan 03-07 (asset) and 03-03/03-06 (packages).

## Next Phase Readiness
- Every later plan in this phase can now: (a) import `mobile_scanner` and `shimmer` without a pubspec change of their own, (b) reference `assets/images/textures/noise.png` from `GWCanvasBackground` once a later plan instantiates it, and (c) run `bash tool/verify_additive_boundary.sh` in their own `<verify>` block as a standing gate against the shadow-name hazard before landing any of the 50 in-scope component files.
- No blockers. The guard's `WalletsOverview` allowlist already anticipates plan 03-04's `lib/dev/generated_closure_canary.dart` — if that plan lands the canary at a different path, `tool/verify_additive_boundary.sh` must be updated in the same commit (documented in both the script's own header and `03-SHADOW-NAMES.md`).
- Outstanding for the human: full session restart (pubspec change) before any later plan's work can be hot-reloaded on top of this one; no visual verification is being requested for this plan specifically (deferred to 03-10 per the plan's own `<verification>` scope).

---
*Phase: 03-gw-component-library*
*Completed: 2026-07-16*

## Self-Check: PASSED

All created files confirmed present on disk (`assets/images/textures/noise.png`, `tool/verify_additive_boundary.sh`, `tool/shadow-baseline.txt`, `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md`, this SUMMARY). Both task commits (`8fb5d25`, `2c3199e`) confirmed present in `git log --oneline --all`.
