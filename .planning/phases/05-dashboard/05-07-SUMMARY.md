---
phase: 05-dashboard
plan: 07
subsystem: ui
tags: [flutter, bloc, dashboard, error-state, retry, gw_button]

# Dependency graph
requires:
  - phase: 05-dashboard (05-06)
    provides: transactions walk approval, Phase 05 implementation-complete baseline
provides:
  - A working Retry affordance on the dashboard's failure branch, re-driving both AppBloc gating statuses (accountStatus via FetchAccount(), subscribeToWalletStatus via the shared reload helper)
affects: [05-dashboard, phase-05-signoff]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "File-scope (library-private) helper functions shared across sibling widgets in one Dart file, instead of duplicating dispatch logic or instantiating a widget just to call an instance method"

key-files:
  created: []
  modified:
    - lib/dashboard/home/view/dashboard_screen.dart

key-decisions:
  - "Task 1 (code) is complete and committed (64fa92d). Task 2 (blocking human-verify checkpoint — forced-failure walk) has NOT been performed. This SUMMARY is written now per explicit executor instruction so the completed code work is recorded before handing off; status below reflects the plan as NOT complete."
  - "UI-SPEC §6 re-read and confirmed to govern copy only ('do not reconcile these' — i.e. do not reword the string to match GWErrorState's default wording). It says nothing against placing a retry affordance beside the preserved Text. No override recorded; ROADMAP criterion 3 not reworded."
  - "Retry dispatches FetchAccount() in addition to the shared _onRefresh reload (LoadWallets() + walletCubit.getCoins()) because accountStatus is written ONLY by _onFetchAccount (app_bloc.dart:164,168,170, all inside that handler); _onLoadWallets writes only subscribeToWalletStatus and never touches accountStatus. Verified independently by a repo-wide grep for `accountStatus` (lib/bloc/app_state.dart declaration/copyWith aside, the only writers are those three lines) before writing code."
  - "subscribeToWalletStatus never emits AppStatus.error anywhere in app_bloc.dart — _onLoadWallets has no try/catch, so a throw from api.getWallets() escapes to the bloc's error sink and leaves the status at loading. The wallet leg of the error branch is therefore currently UNREACHABLE in shipped code. Deliberately not fixed in this plan (that would be an app_bloc.dart behavior change, out of scope); flagged here for a future decision. The retry still dispatches LoadWallets() so it stays correct if this leg is ever made reachable."
  - "Corrected the planning briefing's claim that _onRefresh was a DashboardScreenState instance method: it is actually inside OneColumnDashBoardView (StatelessWidget), a sibling class ending well after DashboardScreenState. Hoisted it to file scope (Dart's privacy unit is the library) rather than duplicating its two dispatches, honoring the reuse intent without the incorrect premise."

patterns-established: []

requirements-completed: []  # Not marked complete yet — plan is not done (Task 2 pending). Mark on plan completion after the human walk.

coverage:
  - id: D1
    description: "Dashboard failure branch renders a GWButton 'Retry' beside develop's unchanged 'Something went wrong!' text, wired to a retry helper that dispatches both FetchAccount() and LoadWallets()"
    requirement: "SCR-01"
    verification:
      - kind: manual_procedural
        ref: "05-07-PLAN.md Task 2 (forced-failure walk, Part A) — NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "A press -> re-fetch -> re-render is a runtime state transition; flutter test does not compile on this branch and the Flutter toolchain is unreachable from this session, so no automated command can substitute for the human walk in 05-07-PLAN.md Task 2."
  - id: D2
    description: "All 11 code-reading verification gates (string preservation, retry affordance presence, FetchAccount dispatch location, LoadWallets non-duplication, success-branch untouched, file-scope hoisting, no GWErrorState substitution, raw-color census unchanged, spacing-token discipline, import added, conditions untouched) pass against HEAD"
    requirement: "GAP-06"
    verification:
      - kind: other
        ref: "grep gates run inline against lib/dashboard/home/view/dashboard_screen.dart, see this SUMMARY's Task Commits section for the full command list and results"
        status: pass
    human_judgment: false

# Metrics
duration: ~15min (Task 1 only; Task 2 pending)
completed: 2026-07-21
status: complete
walk: APPROVED 2026-07-21 (both appearance modes) — Task 2 Part A observed: "Fail acct" armed the
  one-shot fault, the dashboard rendered 'Something went wrong!' with the Retry button, and pressing
  Retry recovered the app to a fully rendered dashboard. Part B (markets retry, finding 8) also
  approved. Criterion 3 is satisfied by observation, not by wiring inspection.
---

# Phase 05 Plan 07: Dashboard Error-Branch Retry Summary

**Dashboard failure branch gains a working Retry (GWButton, primary variant) that dispatches both `FetchAccount()` and the shared reload helper — Task 1 complete and committed; Task 2's forced-failure human walk is outstanding.**

## Performance

- **Duration:** ~15 min (Task 1 only)
- **Started:** 2026-07-21
- **Task 1 completed:** 2026-07-21
- **Tasks:** 1 of 2 (Task 2 is a blocking human-verify checkpoint, not performed by this executor)
- **Files modified:** 1

## Accomplishments

- Hoisted `_onRefresh(BuildContext)` from `OneColumnDashBoardView` to file scope, body byte-for-byte unchanged, so `OneColumnDashBoardView`'s `RefreshIndicator` and the new retry helper share exactly one reload definition.
- Added file-scope `_onRetry(BuildContext)`: dispatches `FetchAccount()` on `AppBloc`, then awaits `_onRefresh(context)` — recovers the account leg (the only leg reachable in shipped code) as well as the wallet leg.
- Rebuilt the dashboard's failure branch: `Center` > `Column(mainAxisSize: min)` > [preserved `Text('Something went wrong!')`, `SizedBox(height: GeniusWalletConsts.space6)`, `GWButton(onPressed: () => _onRetry(context), label: 'Retry', variant: GWButtonVariant.primary, leading: const Icon(Icons.refresh))`].
- Added the missing `package:genius_wallet/components/buttons/gw_button.dart` import.
- All 11 automated code-reading gates specified in `05-07-PLAN.md` Task 1 pass (see below).

## Task Commits

Each task was committed atomically:

1. **Task 1: Add a working Retry to the dashboard failure branch, re-driving both gating statuses** - `64fa92d` (feat)

**Task 2 (checkpoint:human-verify, gate="blocking"): Forced-failure walk** — NOT performed. Awaiting human. See "Next Phase Readiness" below for the exact recipe.

_No plan-metadata commit yet — deferred until Task 2 is approved and the plan is fully complete._

## Files Created/Modified

- `lib/dashboard/home/view/dashboard_screen.dart` — import added; error branch rebuilt with a Retry `GWButton`; `_onRefresh` hoisted to file scope; new file-scope `_onRetry` helper added.

## Automated Gate Results (Task 1, run against HEAD after the edit)

| # | Gate | Expected | Result |
|---|------|----------|--------|
| 1 | `grep -c "Text('Something went wrong!')"` | exactly 1 | 1 |
| 2 | `grep -c "label: 'Retry'"` / `GWButtonVariant.primary` / `Icons.refresh` | exactly 1 each | 1 / 1 / 1 |
| 3 | `FetchAccount()` count (comments filtered) | exactly 1, inside `_onRetry` | 1, confirmed inside `_onRetry`, not `_onRefresh` |
| 4 | `add(LoadWallets())` count / `getCoins();` count | exactly 1 / exactly 2 | 1 / 2 |
| 5 | `onRefresh: () => _onRefresh(context)` | exactly 1 | 1 |
| 6 | `_onRefresh` definition at column 0, outside any class body | true | true — defined between `DashboardScreenState` and `ResponsiveDashboardView` |
| 7 | `GWErrorState` | exactly 0 | 0 |
| 8 | `Colors.white` (comments filtered) / `Colors.(red\|grey\|black\|blue\|green\|amber\|orange)` | exactly 1 / exactly 0 | 1 (the ₿ glyph) / 0 |
| 9 | `GeniusWalletConsts.space6` | at least 1 | 2 |
| 10 | `components/buttons/gw_button.dart` import | exactly 1 | 1 |
| 11 | Both `AppStatus.error` conditions | exactly 1 each | 1 / 1 |

`git status --porcelain lib/` after the edit shows only `M lib/dashboard/home/view/dashboard_screen.dart` — no fault-injection harness was applied during Task 1 (that only happens during Task 2's walk), so there is nothing to revert yet.

## Decisions Made

See `key-decisions` in the frontmatter — summarized:
1. The `accountStatus` finding: `_onFetchAccount` (app_bloc.dart:164/168/170) is the sole writer; `_onLoadWallets` writes only `subscribeToWalletStatus`. This is why the retry cannot be a one-line reuse of the pull-to-refresh dispatches — verified independently before implementing.
2. `subscribeToWalletStatus` never emits `AppStatus.error` anywhere in `app_bloc.dart` today — the wallet leg of the failure branch is currently unreachable in shipped code. Not fixed here (out of scope, an `app_bloc.dart` behavior change); flagged for a future decision.
3. UI-SPEC §6 re-read: it locks the copy, not the presence of an affordance. No document-conflict override needed; ROADMAP criterion 3 unchanged.
4. Corrected the planning briefing: `_onRefresh` was never a `DashboardScreenState` instance method — it lived in `OneColumnDashBoardView`, a sibling `StatelessWidget`. Hoisted to file scope rather than duplicated.

## Deviations from Plan

None - plan executed exactly as written for Task 1. The central technical claim (retry must dispatch both `FetchAccount()` and the wallet reload because `accountStatus` is written only by `_onFetchAccount`) was independently re-verified against HEAD before writing any code and found to hold exactly as the plan described — no deviation-rule trigger.

## Issues Encountered

None for Task 1. Task 2 could not be attempted by this executor — it is a `checkpoint:human-verify` with `gate="blocking"` requiring a human to run the app, forced-fail the account fetch via a temporary harness edit, and observe the recovery in both appearance modes.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

**This plan is NOT complete.** Task 2 (forced-failure walk) is outstanding and is the sole remaining item blocking Phase 05 sign-off (ROADMAP criterion 3). STATE.md has not yet been updated to reflect this plan, and no `docs(05-07): complete...` metadata commit has been made — both are deferred until Task 2 is approved.

> **Updated 2026-07-21 by quick task `260721-d5s`.** The recipe below is a historical record of how
> Task 2 was originally planned to be walked — by hand-editing `app_bloc.dart` with a temporary,
> uncommitted one-shot fault, then reverting it. That recipe has been repointed: `260721-d5s` shipped
> a dev-only, one-shot account-load fault injector (`lib/dev/dev_fault_injector.dart`, a gated hook in
> `app_bloc.dart`'s `_onFetchAccount`, and a MOCK-section 'Fail acct' button in
> `lib/dev/dev_tools_bubble.dart`) so the same walk now needs **zero source edits and nothing to
> revert** — press 'Fail acct' instead of step 1 below. `05-07-PLAN.md` Task 2 has been rewritten to
> match; this block is left as-is per the SUMMARY-is-a-record convention rather than silently
> rewritten. See `05-07-PLAN.md` Task 2 for the current, authoritative recipe.

**Recipe for Task 2 (copied from `05-07-PLAN.md`, corrects the recipe in `05-VERIFICATION.md` which targeted the markets leg, not the dashboard leg):**

Part A — the dashboard retry (load-bearing):
1. In `lib/bloc/app_bloc.dart`, inside `_onFetchAccount`, add a TEMPORARY one-shot fault: a file-local counter initialized to 1; at the top of the `try` block, if the counter is above zero, decrement it and throw. This is a walk harness only — never committed, reverted in step 6.
2. Run the app and land on the dashboard (startup dispatches `FetchAccount` via `router.dart:63-64`, so the injected failure fires immediately).
3. Expected: "Something went wrong!" (trailing `!` present) with a gradient-filled Retry button + refresh icon beneath it.
4. Press Retry. Expected: screen flips to `LoadingScreen()`, then the full dashboard renders. If the button does nothing or the error persists, STOP and report.
5. Repeat steps 2-4 in light mode (dev bubble -> Appearance). Confirm legibility.
6. Revert the harness edit in `app_bloc.dart`; confirm `git status` shows `dashboard_screen.dart` as the only modified file.

Part B — the markets retry (pre-existing outstanding item, finding 8): block `api.coingecko.com` or go offline, open the dashboard, press the `FutureStateWidget` Retry button on the Markets panel. Expected: fetch re-issues and the grid populates on reconnect.

Part C — the wallet leg: optional, expected unreachable (see Decision 2 above). Skip unless confirmation is wanted.

Once Task 2 is approved: move `.planning/todos/pending/2026-07-21-decision-dashboard-error-branch-retry.md` to `.planning/todos/completed/` with the resolution note specified in `05-07-PLAN.md`'s `<verification>` section, strike through STATE.md's "Open decisions carried in" item 1, and update this SUMMARY's `status:` to `complete`.

---
*Phase: 05-dashboard*
*Task 1 completed: 2026-07-21 (commit 64fa92d)*
*Task 2 (checkpoint): outstanding*
