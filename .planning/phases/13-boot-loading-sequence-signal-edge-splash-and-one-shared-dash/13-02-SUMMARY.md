---
phase: 13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash
plan: 02
subsystem: boot-sequence
tags: [flutter, dart, http-timeout, coingecko, boot-splash, plain-dart-engine]

# Dependency graph
requires:
  - phase: 13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash
    provides: 13-CONTEXT.md D5/D6/D7 timing spec, M5 network-down constraint, 13-RESEARCH.md Pattern 2/4
provides:
  - "A single 3-second `requestTimeout` constant bounding all three shared CoinGecko fetch functions"
  - "`BootSequence` — a plain-Dart closing-run timing engine (no Flutter import) implementing D5/D6/D7"
  - "`tool/boot_sequence_check.dart` — a runnable, throwing (non-assert) check covering the engine's race logic"
affects: [13-03 (splash sequencer consumes BootSequence + the bounded fetches), 13-05 (network-down walk revisits requestTimeout)]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Shared-function timeout: bound the network call inside the shared fetch function once, not per call site, so every current and future caller inherits it"
    - "Plain-Dart extraction of branching logic (no Flutter import) so it is exercisable by `dart run` on a repo whose `flutter test` does not compile"
    - "Throwing check helper instead of bare `assert` — measured on this toolchain that `dart run` does not enable asserts by default"

key-files:
  created:
    - lib/screens/boot_sequence.dart
    - tool/boot_sequence_check.dart
  modified:
    - lib/services/coin_gecko/coin_gecko_api.dart

key-decisions:
  - "Timeout constant named `requestTimeout`, value `Duration(seconds: 3)`, declared beside the existing `cacheDuration` at coin_gecko_api.dart:13-20. Justification restated: healthy CoinGecko round trips are sub-second so 3s does not fire on a merely slow-but-alive link; a black-holed socket is instead capped at roughly double the boot sequence's 1.5s minimum hold rather than hanging forever. This is a judgement call (13-CONTEXT Claude's Discretion, 13-RESEARCH A1), not a measurement — 13-05's network-down walk is what revisits it if it fires too eagerly or too late."
  - "`.timeout(requestTimeout)` chained directly onto the three existing `http.get(...)` expressions (fetchHistoricalPrices :47, fetchCoinsMarketData :143, fetchAllCoinGeckoCoins :203 post-edit line numbers). No new try/catch/return — the TimeoutException lands in each function's pre-existing broad `catch (e)` block, which already falls back to Hive cache."
  - "BootSequence.run()'s combined await (`Future.wait([Future.delayed(finalHold), guardedWork])`) swallows a rejecting `work` future INSIDE run() via a wrapping try/catch, never at the call site — this is the belt for the day one of the (already-safe) CoinGecko functions stops falling back to cache."
  - "First attempt at the runnable check's Case 5 (rejecting work) crashed the check itself with an 'Unhandled exception' at the Dart zone level, independent of BootSequence's own swallowing — a Future that completes with an error before anything has attached a listener is reported unhandled by the root zone even if a later `await` would have caught it. Fixed by priming a second, immediate no-op `.catchError` on the test's rejecting future (Futures support multiple independent listeners), which does not interfere with `run()`'s own separate await/catch of the same future."

requirements-completed: [BEH]

coverage:
  - id: D1
    description: "Every CoinGecko request (historical prices, market data, coin list) is bounded by one named, justified 3-second timeout that falls into the existing Hive-cache fallback"
    requirement: BEH
    verification:
      - kind: unit
        ref: "flutter analyze lib/services/coin_gecko/coin_gecko_api.dart — clean; grep-based structural checks (3x .timeout(, 2x const Duration, 1x seconds: literal, 3x http.get, 3x catch (e)) — all pass"
        status: pass
    human_judgment: false
  - id: D2
    description: "BootSequence: plain-Dart closing-run engine implementing D5's three staged confirmations plus D7's minimum-hold-vs-work race, with a clamped finalHold and a swallowed rejecting work leg"
    requirement: BEH
    verification:
      - kind: unit
        ref: "dart run tool/boot_sequence_check.dart — 6/6 cases pass (finalHold value+clamp, hold-as-floor vs instant work, hold-stretches vs slow work, terminates on a bounded-timeout hang, swallows a rejecting work future, stage order/targets/ramp-durations)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The runnable check genuinely fails (non-zero exit) when the logic it covers is broken, not just when it is intact — spot-checked by deliberately breaking the error-swallow and restoring it"
    requirement: BEH
    verification:
      - kind: manual_procedural
        ref: "Removed the try/catch around `await work` in BootSequence.run(), re-ran `dart run tool/boot_sequence_check.dart`, observed exit code 255 and the exact failure message ('run() must swallow a rejecting work future, not propagate it'), then restored the original file and re-verified `dart run tool/boot_sequence_check.dart` passes 6/6 and `flutter analyze` is clean again"
        status: pass
    human_judgment: false

duration: 35min
completed: 2026-07-22
status: complete
---

# Phase 13 Plan 02: CoinGecko timeout bound + BootSequence closing-run engine Summary

**One named 3-second `requestTimeout` now bounds all three shared CoinGecko fetch functions' `http.get` calls, and a new plain-Dart `BootSequence` class implements the D5/D6/D7 closing-run stage timing with a runnable, throwing (non-assert) check that was seen to fail when deliberately broken.**

## Performance

- **Duration:** ~35 min
- **Completed:** 2026-07-22
- **Tasks:** 2/2
- **Files modified:** 3 (1 modified, 2 created)

## Accomplishments
- `lib/services/coin_gecko/coin_gecko_api.dart` now bounds every outbound CoinGecko request with one named `requestTimeout` constant (3s), chained onto the three `http.get()` call sites; the pre-existing broad `catch (e)` blocks and their Hive-cache fallbacks are untouched, so a hang now falls into the same safe path a fast failure already did.
- `lib/screens/boot_sequence.dart` is a new plain-Dart (single `dart:async` import, no Flutter dependency) `BootSequence` class exposing `stageGap`, `minimumHold`, a derived and clamped `finalHold`, and `run({onStage, work, isLive})` — driving D5's three confirmation stages (walletsReady 1/3, balancesReady 2/3, marketsReady 1.0) and then racing `finalHold` against the caller's real boot work, swallowing a rejecting work future inside `run()` itself.
- `tool/boot_sequence_check.dart` is a new runnable check (`dart run tool/boot_sequence_check.dart`) using a throwing `_check` helper (never bare `assert`, since this toolchain's `dart run` does not enable asserts by default) covering all six required cases with lower-bound-only timing assertions. It was seen to both PASS (6/6) and, when the swallow logic was deliberately removed, FAIL loudly with exit code 255 and a precise message — then the fix was restored and re-verified green.

## Task Commits

No commits were created for this plan. Per `CLAUDE.md` ("Do not create commits") and standing project policy, all changes were left in the working tree uncommitted. The three files below are the complete diff for this plan.

## Files Created/Modified
- `lib/services/coin_gecko/coin_gecko_api.dart` — added `const Duration requestTimeout = Duration(seconds: 3)` beside `cacheDuration`, with its justification comment; chained `.timeout(requestTimeout)` onto the three `http.get(...)` call sites (fetchHistoricalPrices, fetchCoinsMarketData, fetchAllCoinGeckoCoins). No other lines changed.
- `lib/screens/boot_sequence.dart` — NEW. `enum BootStage { preparing, walletsReady, balancesReady, marketsReady }` + `class BootSequence` with `stageGap` (default 450ms), `minimumHold` (default 1500ms), derived clamped `finalHold`, and `run({required onStage, required work, isLive})`.
- `tool/boot_sequence_check.dart` — NEW. Runnable via `dart run tool/boot_sequence_check.dart`; imports `package:genius_wallet/screens/boot_sequence.dart` and `dart:async` only; throws via `_check()` on any failed condition; prints `boot_sequence_check: PASS (6/6)` on success.

## BootSequence public API (for 13-03's splash sequencer to consume)

```dart
enum BootStage { preparing, walletsReady, balancesReady, marketsReady }

class BootSequence {
  BootSequence({
    this.stageGap = const Duration(milliseconds: 450),
    this.minimumHold = const Duration(milliseconds: 1500),
  });

  final Duration stageGap;      // gap between staged confirmations
  final Duration minimumHold;   // total floor from first stage to handover
  Duration get finalHold;       // minimumHold - stageGap*2, clamped to >= 0

  Future<void> run({
    required void Function(BootStage stage, double railTarget, Duration railDuration) onStage,
    required Future<void> work,      // the real boot work already in flight (markets/chart/etc.)
    bool Function()? isLive,         // optional liveness check, consulted after each delay
  });
}
```

`onStage` fires exactly three times, in this order and with these exact argument values at the D5 defaults:
1. `(BootStage.walletsReady, 1/3, stageGap)`
2. `(BootStage.balancesReady, 2/3, stageGap)`
3. `(BootStage.marketsReady, 1.0, finalHold)`

13-03 is expected to call `run()` with `work` set to the already-in-flight `Future.wait([getDashboardMarketCoins(), fetchHistoricalPrices('bitcoin')])` (or similar), and to drive its `_StatusBlock` text and `_ClosingRail` tween target/duration entirely from the `onStage` callback's three arguments — no other coupling to `BootSequence` is required.

## Decisions Made
- Timeout constant named `requestTimeout` (not `httpTimeout` or `networkTimeout`) to name what it bounds — a single outbound request — matching the plan's naming guidance.
- The check's Case 5 test fixture needed a "priming" second listener (`rejecting.catchError((_) {})`) attached immediately after creating the deliberately-rejecting `work` future, discovered only by running the check and observing a Dart-zone-level "Unhandled exception" independent of `BootSequence`'s own (correct) swallowing. This is a test-harness detail, not a change to `BootSequence` itself, and is documented inline in the check file.
- Fixed four instances of `(_, __, ___)` unused-parameter naming in the check to `(_, _, _)` to clear a trivial `unnecessary_underscores` info lint (Dart 3 wildcard parameters) — zero-cost cleanup, no behavior change.

## Deviations from Plan

None — plan executed exactly as written. The one operational adjustment (priming the rejecting-future test fixture with a second listener) was a fix to make the *check itself* correctly exercise the already-correctly-written swallow logic in `BootSequence.run()`; it did not require any change to `lib/screens/boot_sequence.dart`'s behavior, so it is not tracked as a Rule 1/2/3 deviation against production code — it is scoped entirely to the test-only file.

## Issues Encountered
- `flutter analyze` (whole-repo) moved from the 409-issue baseline to 410 — the single new issue is an `avoid_print` info lint on `tool/boot_sequence_check.dart`'s required final "PASS" print line (the plan explicitly calls for this print so a passing run is visibly a pass, not a silent no-op). `lib`'s 61-issue baseline is unchanged, and both target files (`coin_gecko_api.dart`, `boot_sequence.dart`) analyze clean with zero issues.
- `tool/verify_additive_boundary.sh` Check 2 fails on this branch for the pre-existing, out-of-scope `_Section` duplicate (`lib/dev/design_gallery_screen.dart:953` vs `lib/dev/dev_tools_bubble.dart:726`) — inherited, not introduced by this plan. Check 1 (the shadow-import boundary this phase can actually break) reports zero `FAIL [` lines.
- `dart format` was tried on all three touched files as a style pass; it reflowed the two multi-line `http.get(...).timeout(...)` call sites onto three lines each, which broke the verify gate's literal `grep -c 'http.get'` (contiguous substring) count. Reverted those two call sites to the original single-line form (already under the repo's un-enforced 80-col convention — no `lines_longer_than_80_chars` lint is configured, and the file already had longer pre-existing lines) and re-ran the full verify chain clean.
- The GSD standard `state_updates`/`final_commit` steps (STATE.md/ROADMAP.md/REQUIREMENTS.md advancement via `gsd-tools query`, plus a metadata commit) were deliberately SKIPPED for this plan. `STATE.md`'s `current_phase` is 06 (Onboarding) — Phase 13 is being worked as a separate, parallel workstream, not the sequential "current phase." Running the standard advance/record commands would have overwritten that in-progress tracking, and a parallel session is actively editing other files in this same working tree. Per this plan's explicit instructions, no commits were made at all, and STATE.md/ROADMAP.md/REQUIREMENTS.md were left untouched.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- 13-03 (splash sequencer) can now import both `BootSequence` and the bounded `coin_gecko_api.dart` fetch functions directly; the closing-run timing, rail targets, and stage naming are fully specified above and match D5/D6 exactly.
- 13-05's network-down walk has one clearly named value to revisit if needed: `requestTimeout` in `lib/services/coin_gecko/coin_gecko_api.dart`.
- No blockers.

---
*Phase: 13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash*
*Completed: 2026-07-22*

## Self-Check: PASSED

- FOUND: `lib/services/coin_gecko/coin_gecko_api.dart`
- FOUND: `lib/screens/boot_sequence.dart`
- FOUND: `tool/boot_sequence_check.dart`
- FOUND: `.planning/phases/13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash/13-02-SUMMARY.md`
- No commit hashes to verify — no commits were created for this plan, per `CLAUDE.md` ("Do not create commits") and standing project policy.
