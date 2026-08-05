---
phase: 02-design-tokens-verification-loop
plan: 02
subsystem: infra
tags: [flutter, dev-tooling, feature-flags, kDebugMode]

requires:
  - phase: 01-adopt-gsd
    provides: A Windows debug build that links and runs
provides:
  - "lib/dev/dev_flags.dart with kShowDevTools, the single dev-tools flag for the rest of the milestone"
  - "responsive_overlay.dart's DevToolsWidget gated behind kDebugMode && kShowDevTools"
affects: [phase-2-plan-5-token-probe-entry-point, phase-6-onboarding-mock-button]

tech-stack:
  added: []
  patterns: ["kDebugMode && kShowDevTools conjunction as the required guard shape for every dev-only call site — kShowDevTools alone is never a release guard"]

key-files:
  created:
    - lib/dev/dev_flags.dart
  modified:
    - lib/components/overlay/responsive_overlay.dart

key-decisions:
  - "Ported f3fd16f's dev_flags.dart byte-for-byte, including its docstring, per UI-SPEC guidance to reuse rather than rewrite."
  - "Only responsive_overlay.dart's Dev row is gated this phase. wallet_creation_screen.dart's onboarding Design-gallery/Mock buttons do not exist on develop today and remain deferred to Phase 6, which ports that file and lib/dev/mock_mode.dart together — confirmed by zero-diff check on both wallet_creation_screen.dart and dev_tools_widget.dart."

patterns-established:
  - "Pattern: kShowDevTools is the single flag for all dev-only affordances across the milestone; new call sites AND it with kDebugMode rather than introducing a second flag."

requirements-completed: [BLD-03]

coverage:
  - id: D1
    description: "lib/dev/dev_flags.dart ported byte-identical from f3fd16f, declaring kShowDevTools read from bool.fromEnvironment('GW_DEV_TOOLS')"
    requirement: "BLD-03"
    verification:
      - kind: automated_ui
        ref: "git show f3fd16f:lib/dev/dev_flags.dart | diff -q - lib/dev/dev_flags.dart; flutter analyze lib/dev"
        status: pass
    human_judgment: false
  - id: D2
    description: "responsive_overlay.dart's DevToolsWidget (the header 'Dev' row: test transaction / swap / buy buttons) is gated behind kDebugMode && kShowDevTools instead of bare kDebugMode; sibling files (wallet_creation_screen.dart, dev_tools_widget.dart) untouched"
    requirement: "BLD-03"
    verification:
      - kind: automated_ui
        ref: "grep -c 'kDebugMode && kShowDevTools' responsive_overlay.dart; grep -c 'if (kDebugMode) const DevToolsWidget()' responsive_overlay.dart (expect 0); git diff --numstat wallet_creation_screen.dart dev_tools_widget.dart (expect 0); flutter analyze lib"
        status: pass
    human_judgment: true
    rationale: "Static checks confirm the conjunction is present and the bare guard is gone, but ROADMAP criterion 4 requires observing BOTH runtime directions (Dev row absent by default, present with --dart-define=GW_DEV_TOOLS=true) in a running Windows debug build. This environment has no GUI screenshot/computer-use capability to observe a native window's rendered content, so the visual confirmation could not be captured by the agent and remains outstanding for a human."

duration: ~15min
completed: 2026-07-16
status: complete
---

# Phase 2 Plan 2: Dev-tools gating (BLD-03) Summary

**Ported `f3fd16f`'s `kShowDevTools` flag and gated `responsive_overlay.dart`'s Dev-tools header row behind `kDebugMode && kShowDevTools`; the onboarding Mock button stays out of scope until Phase 6 since it doesn't exist on develop today.**

## Performance

- **Duration:** ~15 min
- **Completed:** 2026-07-16
- **Tasks:** 2/2 completed
- **Files modified:** 2 (1 created, 1 modified)

## Accomplishments
- `lib/dev/dev_flags.dart` created, byte-identical to `f3fd16f`'s version (verified via `diff -q` against `git show f3fd16f:lib/dev/dev_flags.dart`), declaring `const bool kShowDevTools = bool.fromEnvironment('GW_DEV_TOOLS')`.
- `lib/components/overlay/responsive_overlay.dart`'s only live dev-tools call site changed from `if (kDebugMode) const DevToolsWidget(),` to `if (kDebugMode && kShowDevTools) const DevToolsWidget(),`, carrying the two explanatory comment lines from `f3fd16f` verbatim, plus the `dev_flags.dart` import placed in correct alphabetical position among the file's `genius_wallet/*` imports (between `dashboard/transactions/cubit/transactions_cubit.dart` and `network/network_dropdown_selector.dart` — `f3fd16f`'s own diff placed it earlier only because develop's `font_awesome_flutter` import didn't exist in the redesign branch's base version).
- `flutter analyze lib` reports **0 errors** (34 pre-existing info/warning issues unrelated to these two files, confirmed by name — no new issues in `lib/dev/` or `responsive_overlay.dart`).
- Confirmed `lib/onboarding/view/wallet_creation_screen.dart` and `lib/test/dev_tools_widget.dart` have zero diff — the onboarding Mock/Design-gallery gating (the other half of `f3fd16f`) is correctly deferred to Phase 6, since develop's current `wallet_creation_screen.dart` has no dev buttons to gate.

## Task Commits

Each task was committed atomically:

1. **Task 1: Port lib/dev/dev_flags.dart from f3fd16f** - `5d2e8de` (feat)
2. **Task 2: Gate the responsive_overlay dev-tools call site** - `ca556e4` (feat)

_Note: an interim commit `76c2e0c` (later rewritten to `67e4eed` by the concurrently-running 02-01 agent) briefly and unintentionally absorbed the staged `lib/dev/dev_flags.dart` file — see Deviations below. The file's final, correctly-attributed commit is `5d2e8de`._

## Files Created/Modified
- `lib/dev/dev_flags.dart` - New file. Declares `kShowDevTools`, the single dev-tools flag for the milestone.
- `lib/components/overlay/responsive_overlay.dart` - Import added; `DevToolsWidget` guard changed from bare `kDebugMode` to `kDebugMode && kShowDevTools`.

## Decisions Made
- Ported `dev_flags.dart` byte-for-byte including its docstring, per UI-SPEC §6/§8's explicit instruction to reuse the wording rather than rewrite it.
- Placed the new import in correct Dart alphabetical-sort position for develop's current file (which has an extra `font_awesome_flutter` import not present in `f3fd16f`'s base), rather than mechanically copying the exact diff hunk position — preserves import-sort convention without altering behavior.
- Did not port or touch `wallet_creation_screen.dart` or `lib/dev/mock_mode.dart` — confirmed via UI-SPEC §8 and the plan that this half of `f3fd16f` is Phase 6 scope, and confirmed via zero-diff check that nothing was inadvertently touched.

## Deviations from Plan

### Process note (not a Rule 1-4 deviation — no code changed as a result)

**Concurrent-agent git index collision on the shared working directory.** This plan's Wave 1 companion, plan 02-01, executes concurrently in the *same* working directory (not an isolated worktree — `branching_strategy: none`, single shared checkout). After staging `lib/dev/dev_flags.dart` for Task 1's commit, a `git commit` invoked by the concurrently-running 02-01 agent swept the staged file into its own commit (`76c2e0c`, message `feat(02-01): declare google_fonts dependency`) because both agents share one git index. That commit was subsequently rewritten by the 02-01 agent (new hash `67e4eed`, same message) without `dev_flags.dart`, which returned the file to the working tree as untracked with its content intact and unchanged. This plan then re-staged and committed it cleanly and correctly-attributed as `5d2e8de`. No code was lost, no content was altered, and the final state — one file per intended task commit, correctly attributed — matches what the plan specifies. Flagging this here because it reflects a genuine race-condition risk in the current wave's execution model, not because it affected the delivered code.

**No other deviations.** Plan executed exactly as written otherwise.

## Issues Encountered
None beyond the process note above.

## Verification Status — read carefully

**Automated (all passed):**
- `git show f3fd16f:lib/dev/dev_flags.dart | diff -q - lib/dev/dev_flags.dart` → identical
- `grep -c "bool.fromEnvironment('GW_DEV_TOOLS')" lib/dev/dev_flags.dart` → 1
- `flutter analyze lib/dev` → 0 issues
- `grep -c 'kDebugMode && kShowDevTools' lib/components/overlay/responsive_overlay.dart` → 1
- `grep -c 'if (kDebugMode) const DevToolsWidget()' lib/components/overlay/responsive_overlay.dart` → 0 (bare guard confirmed gone)
- `git diff --numstat -- lib/onboarding/view/wallet_creation_screen.dart lib/test/dev_tools_widget.dart` → 0 lines (untouched, confirmed)
- `flutter analyze lib` → 0 errors (34 pre-existing info/warnings in unrelated files; none in the two files this plan touched)

**OUTSTANDING for the human — not verified by this agent:** the plan's `human-check` for Task 2 requires *running the app* and visually confirming both directions:
1. Default `flutter run -d windows --debug` (no define) → the `Dev` header row and its test transaction/swap/buy buttons are **absent**, and Preferences/Network/SDK Account Manager buttons still render and work.
2. Same recipe with `--dart-define=GW_DEV_TOOLS=true` → the `Dev` row **reappears** with all three test buttons functional.

This agent's environment has no screenshot/computer-use capability for a native Windows GUI window, so the actual rendered output of a running build could not be observed by the agent, regardless of build time invested — building without a way to view the result would not have produced the required evidence. Per the plan's explicit fallback instruction, this is recorded honestly as **outstanding** rather than claimed as verified. The static evidence (byte-identical flag file, correct conjunction present, bare guard absent, zero diff on sibling files, 0 analyze errors) is strong circumstantial confidence that the mechanism is correct, but it is not a substitute for the two-direction visual check.

**Also outstanding, and explicitly out of scope per the plan:** ROADMAP criterion 4 also names the onboarding `Mock` button. It does not exist on develop today (confirmed via zero-diff on `wallet_creation_screen.dart`) and is Phase 6 scope per UI-SPEC §8 — not claimed as verified here, by design.

**Recommended human verification steps** (from the plan's `<human-check>`):
1. Close the reference Release exe at `GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe` if running (shared Hive data dir).
2. Run `CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug`. Reach the dashboard. Confirm the `Dev` row is absent; other action-row buttons still work.
3. Stop, re-run with `--dart-define=GW_DEV_TOOLS=true` appended. Confirm the `Dev` row is back with all three test buttons functional.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `kShowDevTools` exists and is ready for plan 02-05 to reuse for the token-probe entry point (per its own plan's `key_links`).
- The mechanism (flag file + conjunction pattern) is ready for Phase 6 to extend to `wallet_creation_screen.dart`.
- **Blocker for full sign-off:** the two-direction runtime visual check above is outstanding and should be performed by a human before ROADMAP Phase 2 criterion 4 is marked fully satisfied.

---
*Phase: 02-design-tokens-verification-loop*
*Completed: 2026-07-16*

## Self-Check: PASSED

- FOUND: lib/dev/dev_flags.dart
- FOUND: lib/components/overlay/responsive_overlay.dart
- FOUND: commit 5d2e8de
- FOUND: commit ca556e4
