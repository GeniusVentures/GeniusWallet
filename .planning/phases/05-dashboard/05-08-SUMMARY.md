---
phase: 05-dashboard
plan: 08
subsystem: ui
tags: [flutter, layoutbuilder, renderflex, dashboard, dev-tooling, gwerrorstate, gwemptystate]

# Dependency graph
requires:
  - phase: 05-dashboard
    provides: 05-07's dashboard failure-branch Retry, and quick 260721-e3r's adaptive GWEmptyState (2e82ec2), both re-used unchanged here
provides:
  - A dev-bubble fixture (DevMockSgnus) that makes WalletsOverview's SGNUS-wallet branch reachable in a walk for the first time
  - A structural, threshold-free overflow fix for WalletsOverview (LayoutBuilder -> SingleChildScrollView -> ConstrainedBox)
  - Markets error/empty branches routed through GWErrorState/GWEmptyState inside DashboardScrollContainer, matching sibling panels
affects: [05-VERIFICATION.md gaps B1/B2, phase-5 sign-off]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "LayoutBuilder -> SingleChildScrollView -> ConstrainedBox(minHeight: incoming bound) idiom for widgets whose intrinsic height cannot be derived from constants — pixel-identical where there is room, scrolls instead of overflowing where there is not"
    - "Sticky (non-one-shot) dev-fixture override, distinct from DevFaultInjector's one-shot spend, for state a walker needs to hold across resizes/appearance toggles"

key-files:
  created:
    - lib/dev/dev_mock_sgnus.dart
  modified:
    - lib/bloc/app_bloc.dart
    - lib/wallets/cubit/wallet_details_cubit.dart
    - lib/components/wallet_overview.dart
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/dev/dev_tools_bubble.dart

key-decisions:
  - "Task 1 (the fixture) shipped before Task 2 (the layout fix), per the plan, so the pre-fix overflow could in principle be observed rather than inferred — but this executor did not run the app between the two tasks (flutter run/build is out of scope for this session; MISSING for behavior per the plan's own verify blocks), so the measured pre-fix deficit against the disputed 26px/55px figures is NOT established by this SUMMARY and remains for Task 4's human walk."
  - "B1 took the LayoutBuilder/scroll idiom, not GWEmptyState's compact-tier pattern, because WalletsOverview's intrinsic height is not derivable from constants (FFI-polled AutoSizeText, three connection animations, a conditional 48px CTA) and two auditing agents already disagreed by ~29px on what that height even is."
  - "FutureStateWidget's onRetry was deliberately removed from the top-level call and moved inside GWErrorState (Task 3 Edit C) — a required structural deviation, not a pure container swap. FutureStateWidget appends its own Retry as a SIBLING of `error:`; leaving both would have produced a card containing only the message with a second, naked Retry underneath it."
  - "GWEmptyState in the Markets empty branch is deliberately NOT wrapped in the new scroll-safe helper, unlike the error branch. GWEmptyState (2e82ec2/260721-e3r) is already adaptive and selects its compact tier from a FINITE constraints.maxHeight; wrapping it in a scroll view would hand its LayoutBuilder an infinite maxHeight and silently disable that compact tier."
  - "The scroll-safe wrapper is duplicated in wallet_overview.dart and dashboard_screen.dart rather than promoted to a shared GW* primitive — two call sites do not justify a new public component. Upgrade path (promote if a third site needs it) is recorded in both files' comments."
  - "WalletDetailsState.copyWith is hand-written x ?? this.x, so a null stash cannot restore selectedWallet to null. On a machine with no wallet selected before injectMockWallet, Clear leaves the fixture wallet in place until the app restarts. Documented as a ceiling, not fixed — copyWith is a shared state class and restructuring it is out of scope for this gap."
  - "260721-e3r's outstanding walk (GWEmptyState adaptivity, landed in 2e82ec2, never walked) is folded into this plan's Task 4 checklist (Part D) rather than left as a second, competing checklist. Not yet executed — Task 4 has not run in this session."

requirements-completed: []  # SCR-01 and GAP-06 are NOT marked complete — Task 4 (the blocking human walk) has not run. Do not mark complete until Task 4 is approved.

# Coverage metadata — Task 4 is the human-judgment gate for every deliverable below; none can auto-pass.
coverage:
  - id: D1
    description: "DevMockSgnus dev-bubble fixture makes WalletsOverview's SGNUS idle/processing states reachable from the dev bubble"
    requirement: "GAP-06"
    verification:
      - kind: manual_procedural
        ref: "05-08-PLAN.md Task 4 Part A (steps 1-7)"
        status: unknown
    human_judgment: true
    rationale: "Whether the buttons actually produce the SGNUS/processing state on screen is a state transition; flutter test does not compile on this branch and flutter run was out of scope for this session. Code-reading gates (Task 1 verify block) are all green; visual confirmation is Task 4's job, not yet run."
  - id: D2
    description: "WalletsOverview no longer RenderFlex-overflows at any slot height, in either wallet branch, idle or processing, and renders identically where it has room"
    requirement: "SCR-01"
    verification:
      - kind: manual_procedural
        ref: "05-08-PLAN.md Task 4 Part A (steps 2-6) and Part B"
        status: unknown
    human_judgment: true
    rationale: "Proving stripes are gone is a render-time observation. Task 2's code-reading gates (structure, appearance-dependency placement, unchanged children/strings, no Expanded/Flexible, no raw colors) are all green; the overflow claim itself is unverified until Task 4."
  - id: D3
    description: "Markets tile keeps its card/border/padding in error and empty branches, develop's strings unchanged, exactly one Retry inside the card, no new overflow in the two-column short-window shape"
    requirement: "SCR-01"
    verification:
      - kind: manual_procedural
        ref: "05-08-PLAN.md Task 4 Part C (steps 8-11)"
        status: unknown
    human_judgment: true
    rationale: "Forcing a market-data failure and inspecting the tile's chrome is a human observation. Task 3's code-reading gates (string preservation, wrapper count, single onRetry, import/scope census) are all green; the chrome claim itself is unverified until Task 4."

# Metrics
duration: unspecified — single continuous session, start time not separately instrumented
completed: 2026-07-21
status: awaiting-task-4-verification
---

# Phase 5 Plan 08: WalletsOverview overflow + Markets error/empty skin (Tasks 1-3 of 4) Summary

**Dev-bubble SGNUS fixture plus a LayoutBuilder/SingleChildScrollView/ConstrainedBox overflow fix for WalletsOverview, and GWErrorState/GWEmptyState routed into the Markets error/empty branches — code complete, human walk (Task 4) not yet run.**

## IMPORTANT: This plan is NOT complete

Per explicit instruction, this execution covers **Tasks 1-3 only**. **Task 4 — the blocking
`checkpoint:human-verify` walk — has not been attempted, self-approved, or inferred from code.**
`05-VERIFICATION.md` gaps B1 and B2 remain `failed` until a human completes Task 4's walk and types
"approved". This SUMMARY documents Tasks 1-3's code and the code-reading verification gates that
pass; it does **not** claim the RenderFlex overflow is gone or that the Markets tile visually keeps
its card. Those are exactly what Task 4 exists to establish.

No commit was made. Per this session's `COMMIT_POLICY`, all six files below are left staged-free in
the working tree for the orchestrator to batch-commit atomically. `STATE.md`, `ROADMAP.md` and
`REQUIREMENTS.md` were intentionally **not** touched — advancing plan/requirement state belongs after
Task 4 passes, not now.

## Performance

- **Duration:** not separately instrumented (single continuous session)
- **Completed:** 2026-07-21 (Tasks 1-3 only)
- **Tasks:** 3 of 4 (Task 4 outstanding, blocking, not attempted)
- **Files modified:** 5 modified + 1 new = 6 (exactly the plan's `files_modified` list)

## Accomplishments

- **Task 1 — SGNUS + processing walk fixture.** New `lib/dev/dev_mock_sgnus.dart` singleton
  (synthetic `DEV`-legible address, const `Wallet`/`SGNUSConnection` fixture pair with matching
  addresses, sticky tri-state `processingOverride`). `app_bloc.dart`'s `_onProcessingStatusTicked`
  gained one gated short-circuit ahead of its `try`, mirroring the existing fault-injector guard.
  `wallet_details_cubit.dart` gained `injectMockWallet` plus stash/restore in `clearMock`. The dev
  bubble gained two MOCK buttons ("SGNUS idle" / "SGNUS busy") and an extended `Clear`.
- **Task 2 — WalletsOverview structural overflow fix.** `wallet_overview.dart`'s `build()` now wraps
  the unchanged six-child `Column` in `LayoutBuilder -> SingleChildScrollView ->
  ConstrainedBox(minHeight: incoming bounded slot, else 0)`. No threshold constant introduced. The
  `GWColors` appearance read stays above the `LayoutBuilder`, per 260721-e3r's precedent.
- **Task 3 — Markets error/empty branches back inside the card.** `dashboard_screen.dart`'s
  `_MarketsDashboardViewState.build` now routes the error branch through a new private
  `_MarketsErrorScrollSafe` wrapper + `GWErrorState(title: "Failed to load market coins", onRetry:
  _retry)` inside `DashboardScrollContainer`, and the empty branch through
  `GWEmptyState(title: "No market data available")` inside `DashboardScrollContainer` — deliberately
  NOT wrapped in the scroll-safe helper. `FutureStateWidget`'s top-level `onRetry:` argument was
  removed so exactly one Retry exists (inside the card).

## Files Created/Modified

- `lib/dev/dev_mock_sgnus.dart` (new) — DEV-ONLY singleton: synthetic address, const SGNUS `Wallet` +
  connected `SGNUSConnection` (matching addresses), sticky tri-state `processingOverride`,
  `arm`/`clear`.
- `lib/bloc/app_bloc.dart` — one gated short-circuit at the top of `_onProcessingStatusTicked`, ahead
  of the `try`, with `kDebugMode && kShowDevTools` leading the chain.
- `lib/wallets/cubit/wallet_details_cubit.dart` — `injectMockWallet(Wallet)` plus stash/restore
  wired into the existing `clearMock()`.
- `lib/components/wallet_overview.dart` — `LayoutBuilder -> SingleChildScrollView -> ConstrainedBox`
  wrapping the existing, textually-unchanged `Column` (extracted into a private `_buildColumn(gw)`
  helper so the wrapping stays a thin `build()` change).
- `lib/dashboard/home/view/dashboard_screen.dart` — Markets error/empty branches re-skinned; new
  private `_MarketsErrorScrollSafe` widget; two new imports
  (`components/feedback/gw_error_state.dart`, `components/feedback/gw_empty_state.dart`).
- `lib/dev/dev_tools_bubble.dart` — two new MOCK buttons ("SGNUS idle" / "SGNUS busy"), extended
  `Clear` teardown, one new import.

## Decisions Made

See `key-decisions` in frontmatter. Restated in prose:

1. **Fixture-before-fix ordering was followed, but this executor did not visually confirm the
   pre-fix overflow.** The plan's own Task 1/2 verify blocks mark behavioral confirmation "MISSING —
   `flutter test` does not compile on this branch" and defer it to Task 4; this session additionally
   had a standing constraint against running `flutter run`/`flutter build`. So the disputed
   26px-idle/55px-processing figure from the audit is **still unresolved** by this plan's execution —
   it will be resolved (or not) only when a human runs Task 4. This is recorded honestly rather than
   inferred.
2. **Scroll idiom over compact tier for B1**, because `WalletsOverview`'s height is not derivable
   from constants the way `GWEmptyState`'s was, and two auditing agents already disagreed by ~29px.
3. **`FutureStateWidget`'s `onRetry:` moved inside `GWErrorState`** — a deliberate, plan-mandated
   structural deviation from a pure container swap, to avoid a second naked Retry button.
4. **`GWEmptyState` is NOT wrapped** in the new scroll-safe helper (asymmetric with the error branch,
   by design) — wrapping it would blind its adaptive `LayoutBuilder` and undo 2e82ec2/260721-e3r.
5. **Scroll-safe wrapper duplicated, not promoted** — two call sites (`wallet_overview.dart`,
   `dashboard_screen.dart`) do not justify a new shared `GW*` primitive. Upgrade path recorded in
   both files.
6. **`copyWith`'s null-restore ceiling is documented, not fixed** — on a machine with no wallet
   selected before `injectMockWallet`, `Clear` cannot restore `selectedWallet` to null; the fixture
   persists until app restart. `copyWith` is a shared state class; restructuring it is out of scope.
7. **260721-e3r's outstanding walk is folded into this plan's Task 4 (Part D)**, not run yet.

## Verification-gate arithmetic notes (not code defects)

Two of the plan's exact-count `grep` gates undercounted by one, because the stated target patterns
also match a pre-existing definition line the plan's prose didn't account for. Both were confirmed
against `git show HEAD` to be pre-existing, unchanged by this diff:

- **`grep -c 'DashboardScrollContainer(' dashboard_screen.dart`** — plan says "must now be 7"; actual
  is **8**. The pattern also matches `DashboardScrollContainer`'s own constructor definition
  (`const DashboardScrollContainer({super.key, ...})`), which was already present at HEAD (making the
  HEAD baseline 6, not the plan's stated 5). Semantic check confirmed independently: exactly 2 new
  usages were added (error branch, empty branch), matching the four sibling panels' existing
  treatment — the actual requirement this gate exists to verify.
- **`grep -c 'maxHeight: 300' dashboard_screen.dart`** — plan says "exactly 2 (the two overview
  slots)"; actual is **3**, unchanged from HEAD. The third site is `OneColumnDashBoardView`'s
  Contributions slot (`:278`), which also happens to use 300 and was never touched by this plan (Task
  2 fixed the widget, not any slot). Confirmed identical to HEAD via `git show HEAD -- ... | grep`.

Every other automated gate in Tasks 1-3 (compile/analyze, string preservation, retry count, import
census, scope `git diff --stat`, threat-model coverage) matched the plan's stated numbers exactly.

## Deviations from Plan

**None beyond the plan's own explicitly-labeled deviations** (Task 3 Edit C's `FutureStateWidget`
retry relocation, and Task 3's deliberate empty-state/error-state wrapping asymmetry) — both are
plan-mandated, not discovered mid-execution, and are recorded above under Decisions Made rather than
as Rule 1-4 auto-fixes.

No Rule 1-4 auto-fixes were needed. No architectural questions arose. No auth gates were hit.

## Issues Encountered

None. All Task 1-3 automated verification gates pass:

- `flutter analyze lib` → **61 issues, 0 errors, 0 new** (checked after each task and again at the
  end).
- Task 1 gates 2-7: fixture shape, release-safety file census (exactly 3 files mention
  `DevMockSgnus`, the cubit is NOT among them), short-circuit placement ahead of the `try`, cubit
  injector shape, bubble wiring counts, scope (`git diff --stat`) — all match.
- Task 2 gates 2-8: structural nesting order, `isFinite` check, appearance-dependency placement above
  `LayoutBuilder`, unchanged children/strings/toggle, no `Expanded`/`Flexible` introduced, no raw
  `Colors.*`, `ponytail:` note present, scope — all match.
- Task 3 gates 2-9: string preservation (`Failed to load market coins` / `No market data available`,
  each exactly once), wrapper count (8, see arithmetic note above — semantically correct), exactly
  one `onRetry:`/one `_retry()`, correct component-per-branch with the empty branch NOT scroll-wrapped
  (exactly 1 `SingleChildScrollView` in the file), 05-07's retry branch and raw-color census
  untouched, imports added, slot constants unchanged (see arithmetic note above), scope
  (`lib/theme/theme.dart` does NOT appear in this plan's diff — confirmed; it belongs to a concurrent
  executor working on the theme audit and was correctly left untouched throughout).

**Scope fence honored throughout:** `lib/theme/theme.dart`, `lib/theme/genius_wallet_colors.dart`,
`lib/theme/nav_chip_style.dart`, `lib/components/buttons/gw_button.dart`, and `test/theme/` were all
visible as modified/untracked in `git status` at multiple points during this session (a concurrent
executor's work landing in the shared working tree) and were never touched by this execution.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

**Not ready to close 05-VERIFICATION.md's gaps B1/B2 yet.** Tasks 1-3 are code-complete and every
automated gate passes, but per the plan's own design the RenderFlex-overflow and Markets-chrome
claims are unverifiable by grep alone — Task 4 (blocking human walk, Parts A/B/C/D/E/F) is the only
remaining step and has not been run. Recommended next action: a human runs the app with
`--dart-define=GW_DEV_TOOLS=true` and works through Task 4's checklist exactly as written in
`05-08-PLAN.md`, then a fresh execution continues from Task 4 to write the final SUMMARY, update
`STATE.md`/`ROADMAP.md`/`REQUIREMENTS.md`, and close `05-VERIFICATION.md`'s gaps.

---
*Phase: 05-dashboard*
*Plan: 08 (Tasks 1-3 of 4 — Task 4 outstanding)*
*Completed: 2026-07-21*
