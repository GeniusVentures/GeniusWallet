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
  walk-time-addition:
    - "lib/dev/dev_fault_injector.dart, lib/dashboard/chart/dashboard_markets_util.dart, lib/dashboard/home/view/dashboard_screen.dart, lib/dev/dev_tools_bubble.dart — a NEW dev fixture (Mkt error / Mkt empty bubble buttons, commit 3364259) built DURING Task 4's walk, not part of this plan's original files_modified list. CoinGecko 429 rate-limiting meant the app kept falling back to cached data, so neither Markets non-success branch (Task 3's own deliverable) could otherwise be reached at all — the walk needed a fixture to verify its own fix. Sticky ValueNotifier override at DevFaultInjector.marketsFault, hooked at getDashboardMarketCoins() (the one function both initState and _retry call), so the fault flows through the genuine FutureStateWidget branches rather than bypassing them."

key-decisions:
  - "Task 1 (the fixture) shipped before Task 2 (the layout fix), per the plan. The pre-fix overflow was not measured against the disputed 26px/55px audit figures before the fix landed (no flutter run between the two tasks in this session) — that comparison is not established by this SUMMARY and was superseded by Task 4's walk, which confirmed the POST-fix state is clean rather than re-deriving the pre-fix deficit."
  - "B1 took the LayoutBuilder/scroll idiom, not GWEmptyState's compact-tier pattern, because WalletsOverview's intrinsic height is not derivable from constants (FFI-polled AutoSizeText, three connection animations, a conditional 48px CTA) and two auditing agents already disagreed by ~29px on what that height even is. Task 4 walked both idle and processing states, at multiple slot heights, with zero WalletsOverview overflow — the structural choice held."
  - "FutureStateWidget's onRetry was deliberately removed from the top-level call and moved inside GWErrorState (Task 3 Edit C) — a required structural deviation, not a pure container swap. FutureStateWidget appends its own Retry as a SIBLING of `error:`; leaving both would have produced a card containing only the message with a second, naked Retry underneath it. Task 4 confirmed exactly one Retry, inside the card."
  - "GWEmptyState in the Markets empty branch is deliberately NOT wrapped in the new scroll-safe helper, unlike the error branch. GWEmptyState (2e82ec2/260721-e3r) is already adaptive and selects its compact tier from a FINITE constraints.maxHeight; wrapping it in a scroll view would hand its LayoutBuilder an infinite maxHeight and silently disable that compact tier."
  - "The scroll-safe wrapper is duplicated in wallet_overview.dart and dashboard_screen.dart rather than promoted to a shared GW* primitive — two call sites do not justify a new public component. Upgrade path (promote if a third site needs it) is recorded in both files' comments."
  - "WalletDetailsState.copyWith is hand-written x ?? this.x, so a null stash cannot restore selectedWallet to null. On a machine with no wallet selected before injectMockWallet, Clear leaves the fixture wallet in place until the app restarts. Documented as a ceiling, not fixed — copyWith is a shared state class and restructuring it is out of scope for this gap."
  - "260721-e3r's outstanding walk (GWEmptyState adaptivity, landed in 2e82ec2, never walked) was folded into this plan's Task 4 checklist (Part D) rather than left as a second, competing checklist. Executed 2026-07-21 as part of THIS walk: Part D closed e3r's outstanding item — no second checklist survives it."
  - "Task 4's walk surfaced a THIRD, distinct RenderFlex overflow — crypto_live_chart.dart:315, the zoom/pan IconButton row, 34px — on the plain dashboard with no fixture armed. It is not a regression of this plan's work (WalletsOverview and GWEmptyState both produced zero overflow lines all session) and not a re-appearance of the already-fixed 6.3px/19px sites; it is a genuinely new site, filed as .planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md. ROADMAP criterion 5 ('no RenderFlex overflow') therefore stays FAILED — now on a different, out-of-scope-for-this-plan site — rather than being marked closed. Recording this honestly, not closing the criterion just because this plan's own two overflow gaps (B1, and the e3r GWEmptyState re-walk) are resolved, is the explicit point of the walk protocol lesson this milestone has already learned twice today."

requirements-completed: [SCR-01, GAP-06]  # Task 4 walked and APPROVED 2026-07-21. B1 and B2 are closed. NOTE: Phase 5 ROADMAP criterion 5 ("no RenderFlex overflow") does NOT close on this plan alone — the walk surfaced a THIRD, distinct overflow (crypto_live_chart.dart:315, the zoom/pan row, 34px) that this plan neither introduced nor fixed. See "Criterion 5 status" below.

# Coverage metadata — Task 4 is the human-judgment gate for every deliverable below. All observed and approved 2026-07-21.
coverage:
  - id: D1
    description: "DevMockSgnus dev-bubble fixture makes WalletsOverview's SGNUS idle/processing states reachable from the dev bubble"
    requirement: "GAP-06"
    verification:
      - kind: manual_procedural
        ref: "05-08-PLAN.md Task 4 Part A (steps 1-7)"
        status: pass
    human_judgment: true
    rationale: "Walked 2026-07-21 on a Windows debug build (--dart-define=GW_DEV_TOOLS=true, Flutter 3.41.9), console log monitored throughout. Both 'SGNUS idle' and 'SGNUS busy' buttons reached the branch; the CTA rendered; window resizing exercised. APPROVED. This state had never been reachable in this project's history before Task 1's fixture."
  - id: D2
    description: "WalletsOverview no longer RenderFlex-overflows at any slot height, in either wallet branch, idle or processing, and renders identically where it has room"
    requirement: "SCR-01"
    verification:
      - kind: manual_procedural
        ref: "05-08-PLAN.md Task 4 Part A (steps 2-6) and Part B"
        status: pass
    human_judgment: true
    rationale: "Walked 2026-07-21, both appearance modes, multiple window sizes. Zero RenderFlex overflow lines attributable to WalletsOverview in the console across the whole session (the only overflow line logged all session was the new 34px chart finding below, a different widget). APPROVED — the scroll idiom holds at every slot height tried, and the panel is visually unchanged where it has room."
  - id: D3
    description: "Markets tile keeps its card/border/padding in error and empty branches, develop's strings unchanged, exactly one Retry inside the card, no new overflow in the two-column short-window shape"
    requirement: "SCR-01"
    verification:
      - kind: manual_procedural
        ref: "05-08-PLAN.md Task 4 Part C (steps 8-11)"
        status: pass
    human_judgment: true
    rationale: "Walked 2026-07-21 via the NEW dev fixture built during the walk itself (Mkt error / Mkt empty, commit 3364259) — CoinGecko 429 rate-limiting meant cached data kept masking both branches until that fixture existed. Both branches confirmed inside DashboardScrollContainer, card/border/padding matching the four sibling panels, strings byte-exact, exactly one Retry inside the card, no overflow at a short two-column window. APPROVED."

# Metrics
duration: unspecified — single continuous session, start time not separately instrumented
completed: 2026-07-21
status: complete
---

# Phase 5 Plan 08: WalletsOverview overflow + Markets error/empty skin Summary

**Dev-bubble SGNUS fixture plus a LayoutBuilder/SingleChildScrollView/ConstrainedBox overflow fix for WalletsOverview, GWErrorState/GWEmptyState routed into the Markets error/empty branches, and the consolidated human walk (Task 4) — WALKED AND APPROVED 2026-07-21.**

## Plan status: COMPLETE — with an honest caveat on criterion 5

Task 4 (the blocking `checkpoint:human-verify` walk) has been **performed and approved by the
user** on a Windows debug build. `05-VERIFICATION.md` gaps **B1 and B2 are resolved**, and the
outstanding `260721-e3r` (`GWEmptyState`) walk is closed against this same walk rather than left as
a second checklist.

**But this plan does not single-handedly close Phase 5's ROADMAP criterion 5** ("no RenderFlex
overflow"). The walk surfaced a **third, distinct** overflow — `crypto_live_chart.dart:315`, the
chart's zoom/pan `IconButton` row, 34px — on the plain dashboard with no fixture armed. It is not a
regression of anything this plan touched (WalletsOverview and the `GWEmptyState`/Transactions site
both produced zero overflow lines across the whole walk) and not a re-appearance of either
already-fixed site (the old 6.3px chart overflow and the 19px `GWEmptyState` overflow are both
genuinely gone). It is filed as
`.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md` and left **open** against
criterion 5. See "Criterion-by-criterion verdict" below.

## Performance

- **Duration:** not separately instrumented (single continuous session, spanning the code tasks and
  the later walk)
- **Completed:** 2026-07-21
- **Tasks:** 4 of 4 — Task 4 walked and approved
- **Files modified:** 5 modified + 1 new = 6 (exactly the plan's `files_modified` list), plus a
  walk-time dev-fixture addition (4 files, see "walk-time-addition" in frontmatter) built during
  Task 4 itself so the Markets branches could be reached at all under live CoinGecko rate-limiting

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
- **Task 4 — the consolidated walk, performed and APPROVED.** Windows debug build
  (`--dart-define=GW_DEV_TOOLS=true`, Flutter 3.41.9), console log monitored throughout.
  - **Part D (GWEmptyState, quick `260721-e3r`, `2e82ec2`): APPROVED.** Transactions empty state
    renders correctly; the Assets empty state is visually unchanged (the regression gate). Zero
    overflow lines on boot, where the pre-fix 2026-07-20 run logged 19px within seconds under
    identical conditions.
  - **Parts A + B (B1 — SGNUS): APPROVED.** Both `SGNUS idle` and `SGNUS busy` walked via the new
    fixture, plus window resizing. No overflow, nothing clipped. This state had never been reachable
    in this project's history before Task 1. `SubmitJobDashboardButton` and the processing indicator
    confirmed as real shipped product features (not dev-only), so this walked genuine shipped UI.
  - **Part C (B2 — Markets): APPROVED.** Both the error branch ("Failed to load market coins" +
    exactly one Retry) and the empty branch ("No market data available") render inside
    `DashboardScrollContainer`, keeping the card/border/padding of the four sibling panels. Reached
    via a **new dev fixture** (`Mkt error` / `Mkt empty`, commit `3364259`) built during the walk,
    because CoinGecko 429 rate-limiting meant the app kept falling back to cached data and neither
    branch was otherwise reachable.
  - **Part F (light mode): APPROVED as walked** (not fixed) — the first light-mode walk in the
    project's history. Quick `260721-fa7`'s token work is visible and correct.
  - Console evidence across the whole walk: the only `RenderFlex overflowed` line was the 34px chart
    overflow described above. B1's and B2's states produced none.

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

**Walk-time addition (commit `3364259`, not in this plan's original `files_modified`):**
- `lib/dev/dev_fault_injector.dart` — new sticky `ValueNotifier<DevMarketsFault?> marketsFault` +
  `armMarketsFault`/`disarmMarketsFault`, alongside the existing one-shot account-load fault.
- `lib/dashboard/chart/dashboard_markets_util.dart` — `getDashboardMarketCoins()` (the single
  function both `initState` and `_retry` call) now honours the override, throwing or returning empty
  before the real fetch.
- `lib/dashboard/home/view/dashboard_screen.dart` — `_MarketsDashboardViewState` listens for the
  override and re-triggers a fetch immediately on arm/disarm.
- `lib/dev/dev_tools_bubble.dart` — two more MOCK buttons ("Mkt error" / "Mkt empty").

Built because Task 3's own two branches — the deliverable this plan exists to verify — were
otherwise unreachable: CoinGecko was 429-rate-limited for the whole session, so the app's fallback
to cached data meant the grid always rendered coins. Same lesson as B1's fixture, applied a second
time in the same plan.

## Decisions Made

See `key-decisions` in frontmatter. Restated in prose:

1. **Fixture-before-fix ordering was followed.** The pre-fix overflow was not measured against the
   disputed 26px-idle/55px-processing audit figures before the layout fix landed (no `flutter run`
   between Task 1 and Task 2 in this session). This was superseded by Task 4's walk, which confirmed
   the POST-fix state is clean at every tried slot height rather than re-deriving the pre-fix number
   — that comparison is deliberately left unresolved rather than guessed at.
2. **Scroll idiom over compact tier for B1**, because `WalletsOverview`'s height is not derivable
   from constants the way `GWEmptyState`'s was, and two auditing agents already disagreed by ~29px.
   Walked and approved.
3. **`FutureStateWidget`'s `onRetry:` moved inside `GWErrorState`** — a deliberate, plan-mandated
   structural deviation from a pure container swap, to avoid a second naked Retry button. Walked and
   confirmed: exactly one Retry, inside the card.
4. **`GWEmptyState` is NOT wrapped** in the new scroll-safe helper (asymmetric with the error branch,
   by design) — wrapping it would blind its adaptive `LayoutBuilder` and undo 2e82ec2/260721-e3r.
5. **Scroll-safe wrapper duplicated, not promoted** — two call sites (`wallet_overview.dart`,
   `dashboard_screen.dart`) do not justify a new shared `GW*` primitive. Upgrade path recorded in
   both files.
6. **`copyWith`'s null-restore ceiling is documented, not fixed** — on a machine with no wallet
   selected before `injectMockWallet`, `Clear` cannot restore `selectedWallet` to null; the fixture
   persists until app restart. `copyWith` is a shared state class; restructuring it is out of scope.
7. **260721-e3r's outstanding walk was folded into this plan's Task 4 (Part D) and executed as part
   of it, 2026-07-21.** APPROVED — no second checklist survives it.
8. **A NEW dev fixture (`Mkt error`/`Mkt empty`, commit `3364259`) was built during Task 4 itself**,
   not planned in advance, because CoinGecko's 429 rate-limiting made Task 3's own two Markets
   branches unreachable through the real network path. Same shape as Task 1's fixture, same
   motivation: an unreachable state is a state nobody checks.
9. **Criterion 5 is NOT marked closed**, despite this plan resolving both of its own overflow gaps
   (B1 and the e3r/GWEmptyState re-walk). The walk surfaced a third, distinct 34px overflow at
   `crypto_live_chart.dart:315` (the zoom/pan row) that this plan neither introduced nor is
   accountable for fixing. Recording the honest state — FAILED, on a different site — rather than an
   unearned PASS, per this project's standing rule against exactly that failure mode.

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

**Plan-mandated deviations** (Task 3 Edit C's `FutureStateWidget` retry relocation, and Task 3's
deliberate empty-state/error-state wrapping asymmetry) — both recorded above under Decisions Made,
not discovered mid-execution.

**One deviation discovered during Task 4 itself — [Rule 3 - blocking issue] the Markets error/empty
branches could not be reached to walk them.** Found during Task 4, Part C. CoinGecko was
429-rate-limited for the entire session, so `getDashboardMarketCoins()` always fell back to cached
data and the grid always rendered coins — Task 3's own two branches, the deliverable this walk
exists to verify, were unreachable. Fix: a new sticky dev-fixture override (`DevFaultInjector.
marketsFault`, two new bubble buttons) hooked at the one function both `initState` and `_retry` call,
so the forced fault flows through the real `FutureStateWidget` branches rather than bypassing them.
Files: `lib/dev/dev_fault_injector.dart`, `lib/dashboard/chart/dashboard_markets_util.dart`,
`lib/dashboard/home/view/dashboard_screen.dart`, `lib/dev/dev_tools_bubble.dart`. Commit: `3364259`.

No architectural questions arose (Rule 4). No auth gates were hit.

## Issues Encountered

All Task 1-3 automated verification gates pass:

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

## Criterion-by-criterion verdict (re-derived honestly, not inherited from the plan's optimism)

- **B1 (WalletsOverview overflow, ROADMAP criterion 5's WalletsOverview clause):** RESOLVED. Walked
  idle + processing, both appearance modes, multiple window sizes. Zero overflow.
- **B2 (Markets error/empty skin, ROADMAP criterion 1):** RESOLVED. Walked via the new fixture. Card
  kept, strings byte-exact, exactly one Retry, no overflow at a short two-column window.
- **`260721-e3r` / GWEmptyState (the prior open criterion-5 item):** RESOLVED. Walked; regression
  gate on Assets' empty state held.
- **ROADMAP criterion 5 overall ("no RenderFlex overflow"):** **STILL FAILED.** This plan closed two
  of its sites; a third, independent site (`crypto_live_chart.dart:315`, zoom/pan row, 34px) is open,
  filed, and out of this plan's scope. Phase 5 sign-off remains blocked on that todo.
- **Light mode (Part F):** walked, not fixed — dark-first deferral to the audit's Q3/Q4 stands, no
  new light-mode finding beyond what was already tracked.

## Threat Flags

| Flag | File | Description |
|------|------|--------------|
| threat_flag: dev-fixture-surface | lib/dev/dev_fault_injector.dart, lib/dev/dev_tools_bubble.dart | The walk-time Markets fault injector (`marketsFault`, commit `3364259`) is new dev-only surface not named in this plan's original threat_model. Same disposition as T-05-08-01/02 already in the register: gated `kDebugMode && kShowDevTools` with the compile-time consts leading the chain, so it constant-folds out of release; forces only a UI-visible fault state, no external input, no new network/storage surface. Low severity, accept — mirrors an already-assessed pattern rather than introducing a new class of exposure. |

## Next Phase Readiness

**`05-VERIFICATION.md` gaps B1 and B2 are now resolved and walked**, and the outstanding
`260721-e3r` walk is closed against this same session. **Phase 5 is still not ready to sign off**:
ROADMAP criterion 5 has a live, open, third-site RenderFlex overflow
(`.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md`) that this plan does not
fix. Recommended next action: decide whether the chart's zoom/pan row survives (per the todo's own
framing, tied to the "wire real timeframe ranges" decision), then plan and execute whichever fix
follows from that decision, then re-verify Phase 5 against HEAD.

---
*Phase: 05-dashboard*
*Plan: 08 (4 of 4 tasks — Task 4 walked and approved 2026-07-21)*
*Completed: 2026-07-21*
