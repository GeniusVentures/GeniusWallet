---
phase: 05-dashboard
plan: 01
subsystem: ui
tags: [flutter, dashboard, gwcolors, gwdecorations, loading, future-builder, appearance]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome (04-02, 04-04)
    provides: "GWColors ThemeExtension + the fail-soft Theme.of(context).extension<GWColors>() ?? GWColors.dark() access path, and the 04-04 mechanism whereby registering a Theme dependency in a const-instanced widget's build() also freshens GWDecorations reads"
  - phase: 03-gw-component-library
    provides: "GWButton, GWDecorations.surface, and 03-SHADOW-NAMES.md's canonical-path-wins binding rule for the Loading/WalletsOverview shadow pairs"
provides:
  - "DashboardScrollContainer re-skinned to an appearance-aware GWDecorations.surface Container — the shared chrome all five dashboard areas mount into, and the container the four following 05-* area plans render through"
  - "Canonical lib/components/loading.dart re-skinned in place, so all 19 importers (dashboard, markets, news, loading screen) inherit the redesign spinner with zero call-site changes"
  - "FutureStateWidget default error/retry chrome on tokens (error_outline + statusError, GWButton primary retry)"
affects: [05-02, 05-03, 05-04, 05-05, and any surface rendering Loading or FutureStateWidget's default chrome]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Threading an appearance-aware value into GWDecorations.surface's `border:` parameter gives the mandatory GWColors read a real consumer instead of an unused local — the Theme dependency is registered AND the hairline edge becomes appearance-aware, rather than falling back to the static GeniusWalletColors.borderSubtle getter"

key-files:
  created: []
  modified:
    - lib/dashboard/home/view/dashboard_screen.dart
    - lib/components/loading.dart
    - lib/components/custom_future_builder.dart

key-decisions:
  - "GWDecorations.surface takes no surface-color argument (it derives its fill from the appearance-aware surfaceSheen getter), so the required GWColors read was bound to the `border:` parameter — a genuine appearance-aware consumer, not a discard."
  - "loading.dart keeps develop's `if (text != null)` guard rather than adopting the shadow's `AutoSizeText(text ?? \"\")` — the shadow would render an empty text box on every text-less call site (the majority of the 19). Token choices ported; the null-guard structure preserved."
  - "custom_future_builder.dart's retry GWButton is non-const because `onRetry` is a runtime field; the `leading:` Icon stays const."

requirements-completed: [SCR-01, GAP-06]  # Task 3 walk PASSED 2026-07-20; one must_have clause (in-place live-flip) recorded as an outstanding gap, see below

# Coverage metadata — Task 3 (human-verify) PASSED 2026-07-20. One clause of the
# plan's live-flip must_have is UNVERIFIABLE in the app's current state and is
# recorded as an explicit outstanding item rather than passed.
coverage:
  - id: D1
    description: "DashboardScrollContainer is a GWDecorations.surface Container reading its appearance-aware border via Theme.of(context).extension<GWColors>() ?? GWColors.dark(); no Card, no deepBlue*/Colors.white survives; layout arithmetic and the three behaviour sites unchanged"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "flutter analyze lib/dashboard/home/view/dashboard_screen.dart (No issues found) + grep -q 'extension<GWColors>()' + bash tool/verify_additive_boundary.sh PASSED + git diff confirming only the container hunk changed"
        status: pass
      - kind: manual
        ref: "Task 3 walk 2026-07-20 steps 1+2 — all five areas render consistently in BOTH light and dark ('wszystkie mają faktycznie taki sam kolor'); after an appearance change every container shows correct colors for the new mode, both directions"
        status: pass
    human_judgment: true
    rationale: "Container treatment and both-mode correctness are confirmed by the walk. NOT confirmed: that the container flips LIVE on an IN-PLACE toggle. The only setMode() call sites are dev screens, so toggling requires navigating away and back — and that navigation forces a rebuild which masks the const-staleness the clause guards against. See 'Outstanding' below."
  - id: D2
    description: "Canonical Loading re-skinned in place (brandGreen/statusInfo dots, Wrap(space8), headlineLg) reaching all 19 importers, with the shadow left dead and no importer repointed"
    requirement: "GAP-06"
    verification:
      - kind: command
        ref: "flutter analyze lib/components/loading.dart (No issues found) + tool/verify_additive_boundary.sh Check 1 PASSED (canonical importer set still 19, shadow still un-imported) + git status confirming lib/components/loading/loading.dart unmodified"
        status: pass
      - kind: manual
        ref: "Task 3 walk 2026-07-20 steps 3+4 — re-skinned spinner appears and animates (confirmed on navigation); the SAME spinner confirmed on the news surface and elsewhere, behaviourally confirming the one-edit-many-surfaces reach"
        status: pass
    human_judgment: false
  - id: D3
    description: "FutureStateWidget default chrome token-correct (Icons.error_outline + statusError, GWButton primary retry) with onRetry/error plumbing byte-identical"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "flutter analyze lib/components/custom_future_builder.dart (No issues found) + git diff showing the onRetry wiring and error-slot resolution unchanged + no Colors.red/blue survives"
        status: pass
    human_judgment: true
    rationale: "The default error branch fires only on a forced load failure, which the walk did not force. Incidentally exercised: the multi-instance CoinGecko 429 degraded to cached data correctly, but that is the cached-data path, not the default error+retry chrome."
  - id: D4
    description: "develop's dashboard pull-to-refresh (finding 17) preserved unregressed through the re-skin"
    requirement: "SCR-01"
    verification:
      - kind: manual
        ref: "Task 3 walk 2026-07-20 step 5 — pull-to-refresh WORKS, fired via two-finger trackpad; git diff confirms the RefreshIndicator hunk is byte-identical"
        status: pass
    human_judgment: false

# Metrics
duration: ~20min
completed: 2026-07-20
status: complete
---

# Phase 05 Plan 01: Dashboard Chrome Foundation Summary

**Re-skinned the DashboardScrollContainer that wraps all five dashboard areas onto an appearance-aware `GWDecorations.surface` Container, and re-skinned the shared `Loading` widget in place so all 19 importers inherit the redesign spinner — with develop's accountStatus gate, pull-to-refresh, and guarded `getCoins()` preserved byte-identical. Task 3's human walk PASSED on `gmac` (2026-07-20) with one must_have clause honestly recorded as unverifiable rather than passed.**

## Task 3: Dashboard Foundation Walk — PASSED (2026-07-20, on `gmac`, with one recorded gap)

- **Containers (criterion 1):** PASS — all five dashboard areas render consistently in BOTH light and dark; no card stuck in the wrong mode. User's words: *"wszystkie mają faktycznie taki sam kolor"*.
- **Appearance change (criterion 1, both modes):** PASS — after toggling in the Tokens screen and returning to /dashboard, every container shows correct colors for the new mode, in both directions.
- **Loading widget (§3.2):** PASS — the re-skinned spinner appears and animates. Not caught at app start (the account loads too fast to see it), confirmed on navigation.
- **Loading reach (§3.2):** PASS — the SAME spinner confirmed on the news surface and elsewhere. The 19-importer claim is now behaviourally confirmed, not just mechanically.
- **Pull-to-refresh (criterion 2, finding 17):** PASS — fired via two-finger trackpad. **Note for future walks:** mouse click-drag does nothing because `lib/` sets no `dragDevices` anywhere, so Flutter's desktop default excludes mouse — this is a walk-technique gotcha, not a defect. The indicator itself is Material's stock circle+arrow (`brandPrimary` via `progressIndicatorTheme`), NOT the flickr dots — a different widget, out of this plan's scope.
- **In-place LIVE flip:** **NOT VERIFIED — see "Outstanding" below.** Recorded as an honest gap, not a pass.

**Gate outcome: Task 3 PASSED.** `SCR-01` and `GAP-06` are marked complete; the unverified live-flip clause is carried as an explicit outstanding item against the appearance-toggle blocker, per the 03-09 / 02-VERIFICATION precedent for unearned passes.

## Performance

- **Duration:** ~20 min (Tasks 1-2) + human walk
- **Completed:** 2026-07-20 (all 3 tasks)
- **Tasks:** 3 of 3
- **Files modified:** 3

## Accomplishments

- **`DashboardScrollContainer` is now the re-skinned shell all five areas mount into** — the single highest-leverage change in this phase (UI-SPEC §5, Dimension 5's named check). The plain Material `Card` became `Container(decoration: GWDecorations.surface(radius: radiusLg, border: gw.borderSubtle))`, keeping the existing `Padding(EdgeInsets.all(gridSpacing))` untouched. Every subsequent 05-* area re-skin now lands inside an already-correct container.
- **Live-flip correctness wired the 04-04 way.** `DashboardScrollContainer` is const-constructed at all five call sites, so without a Theme dependency `Element.updateChild` short-circuits on the identical const child and the surface would render stale after an in-place appearance toggle. The fail-soft `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` read registers that dependency; `GWDecorations.surface` then recomputes its appearance-aware sheen on the forced rebuild.
- **One edit, four surfaces.** The canonical `lib/components/loading.dart` was re-skinned in place — `brandGreen`/`statusInfo` dots, `Wrap(spacing: space8)`, `headlineLg` text — so the dashboard, markets grid, news feed, and the `LoadingScreen` the accountStatus gate falls back to all inherit the redesign with zero call-site changes. The same-named shadow at `lib/components/loading/loading.dart` stays dead code; no importer was repointed.
- **`FutureStateWidget`'s default chrome is token-correct** (`Icons.error_outline` + `statusError`, `GWButton` primary retry with a refresh icon) while its `onRetry`/`error` slot resolution — finding 8's plumbing — is byte-identical.
- **Findings 9, 17, and 29 re-read and confirmed unregressed** after the edit, per UI-SPEC §2.1's standing discipline.

## Task Commits

1. **Task 1: Re-skin DashboardScrollContainer (§5)** — `af09302` (feat)
2. **Task 2: Re-skin shared Loading (§3.2, GAP-06) + FutureStateWidget default chrome (§4.6)** — `ee326da` (feat)

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`):** performed by the user on `gmac`, 2026-07-20 — **PASSED**, results recorded at the top. No code changes resulted from the walk.

_Note: the plan's `<how-to-verify>` carried a stale Windows recipe (`flutter run -d windows`, a `/c/Users/...` SDK path). The user is on macOS; the walk was run via `gmac`._

## Files Created/Modified

- `lib/dashboard/home/view/dashboard_screen.dart` — `DashboardScrollContainer.build()` only: `Card` → `Container` with `GWDecorations.surface(radius: GeniusWalletConsts.radiusLg, border: gw.borderSubtle)`; three theme imports added. `gridSpacing` (:21) and every `ConstrainedBox`/`Expanded`/`flex` value in `ResponsiveDashboardView`/`OneColumnDashBoardView` untouched. The `wallet_overview.dart` import was **not** repointed to the `wallets_overview.g.dart` shadow.
- `lib/components/loading.dart` — dots `lightGreenPrimary`/`Colors.blue` → `brandGreen`/`statusInfo`; `Row(spacing: 16, mainAxisSize: min)` → `Wrap(spacing: space8, crossAxisAlignment: center)`; text style → `headlineLg`. Public API (`{String? text}`) unchanged, so all 19 importers compile untouched.
- `lib/components/custom_future_builder.dart` — default error `Icon(Icons.error, Colors.red, 48)` → `Icon(Icons.error_outline, statusError, 48)`; default retry `ElevatedButton` → `GWButton(primary, leading: Icon(Icons.refresh))`. Default `loading` slot left as `Center(Loading())`.

## Decisions Made

- **The GWColors read is bound to `border:`, not discarded.** `GWDecorations.surface` exposes `radius`/`elevated`/`border` — it derives its fill from the appearance-aware `surfaceSheen` getter and takes no surface-color argument, so the plan's "feed it a `gw.*` surface field if needed" clause did not apply as written. Rather than leave `gw` as an unused local (a lint, and a read that looks vestigial to the next reader), it is threaded into `border:`. This satisfies the live-flip requirement *and* upgrades the hairline edge from the static `GeniusWalletColors.borderSubtle` getter to the appearance-aware extension value.
- **develop's `if (text != null)` guard preserved over the shadow's `text ?? ""`.** The shadow renders an unconditional `AutoSizeText`, which would paint an empty text box on every text-less call site — the majority of the 19. Token choices were ported; the null-guard structure was not. Re-skin, not restructure.
- **Findings 9/17/29 verified by diff, not just by reading.** `git diff` on `dashboard_screen.dart` shows exactly two hunks (the import block and the container's `build()`), which proves the gate (:57-69), `RefreshIndicator` (:221-223), and `getCoins()` guard (:38-43) are byte-identical — a stronger check than re-reading the shifted line ranges by eye. The ranges were re-read as well.

## Deviations from Plan

**1. [Rule 3 — Blocking] `GWDecorations.surface` has no surface-color parameter**
- **Found during:** Task 1
- **Issue:** The plan's action text anticipated possibly passing an appearance-aware `gw.*` surface field to `GWDecorations.surface`. Its actual signature is `surface({double radius, bool elevated, Color? border})` — the fill comes from the appearance-aware `surfaceSheen` getter internally. Taken literally, the `gw` local would have had no consumer and become an unused-variable lint.
- **Fix:** Threaded `gw.borderSubtle` into the `border:` parameter — a real appearance-aware consumer that preserves the required Theme dependency and makes the hairline edge appearance-aware too.
- **Files modified:** `lib/dashboard/home/view/dashboard_screen.dart`
- **Verification:** `flutter analyze` clean; `grep -q 'extension<GWColors>()'` gate passes.
- **Commit:** `af09302`

**Total deviations:** 1 auto-fixed (1 × Rule 3). **Impact:** none on the plan's intent — the live-flip mechanism and token discipline land exactly as specified; only the binding site for the `gw` read differs from the plan's anticipated one.

## Issues Encountered

None. No Rule 1/2 fixes were needed and no Rule 4 escalation occurred.

## Verification Results (Tasks 1-2, automated only)

- `flutter analyze lib/dashboard/home/view/dashboard_screen.dart` — **No issues found**.
- `flutter analyze lib/components/loading.dart lib/components/custom_future_builder.dart` — **No issues found**.
- `flutter analyze lib` (whole project) — **0 errors**, 61 issues total, all pre-existing `info`/`warning` lints in untouched files (`web_view_mobile.dart` etc.). No new issue introduced by this plan.
- `bash tool/verify_additive_boundary.sh` — **PASSED** after every task. Check 1 confirms the `Loading` canonical importer set still matches its 19-file baseline and the shadow path still has zero un-allowlisted importers; `WalletsOverview` likewise unchanged (the `wallet_overview.dart` import was not repointed). Checks 2 and 3 clean.
- Task 1 grep gate: `extension<GWColors>()` present in `dashboard_screen.dart` — confirmed.
- Raw-value discipline: no `Colors.red`/`Colors.blue`/`Colors.white`/`Colors.grey[N]` survives in any of the three files; no raw hex, no raw px introduced.
- `git status` confirms the shadow `lib/components/loading/loading.dart` is unmodified.

**None of this constitutes the visual/behavioral verification Task 3 provided — see the walk results at the top.**

## Outstanding: the in-place LIVE-FLIP clause is UNVERIFIED (not a pass)

The plan's must_have states the container "flips LIVE on an in-place appearance toggle **rather than rendering stale**". **This was not verified and cannot be verified in the app's current state.** Recording it as passed would be an unearned pass, so it is carried here instead (03-09 / 02-VERIFICATION precedent).

**Why it is unverifiable, structurally:** `setMode()` is called from exactly two places — `lib/dev/token_probe_screen.dart:103` and `lib/dev/design_gallery_screen.dart:124`. There is **no toggle reachable from the dashboard**. Toggling therefore requires navigating away to a dev screen and back, and **that navigation forces a rebuild which masks exactly the const-staleness the clause guards against**. What the walk proved is *"correct AFTER an appearance change"* — a genuinely useful result, and the one recorded as passed above — but it is strictly weaker than *"flips live in place"*.

**Escalation:** the existing todo `.planning/todos/pending/2026-07-18-no-user-facing-appearance-toggle.md` is now a **verification blocker**, not just a UX nicety. It has been updated with `severity: verification-blocker`, a `blocks:` entry naming this must_have, and the reasoning above. The same clause appears in 04-02 and 04-04, so this blocks re-verification of those too.

**Recipe to close once a user-facing toggle ships:** with the dashboard on screen and **not navigated away from**, flip appearance and confirm all five container surfaces re-skin immediately. A card that stays in the old mode is the const-staleness regression this plan's `GWColors` read exists to prevent.

**What partially de-risks it in the meantime:** the `grep` gate confirms the `Theme.of(context).extension<GWColors>()` read is present, which is the documented 04-04 mechanism for forcing a const subtree to rebuild. The mechanism is wired correctly; only its live effect is unproven.

## Environment Finding (not a code defect)

The walk was initially blocked by a **fully black window** — no error, no log, no paint. Root cause: **three concurrent app instances** (two debug builds plus one auto-started from macOS login items) contending on the shared Hive container at `~/Library/Containers/ai.gnus.GeniusWallet.jakub/`. Hive grants the lock to one process; the others hang *before painting*, silently. Resolved by killing all instances and removing Genius Wallet from macOS login items.

The same multi-instance condition also tripped **CoinGecko HTTP 429** — each instance polls on the finding-14 60s timer, so three instances tripled the request rate. The app degraded to cached data correctly, which is the intended behavior.

**Worth knowing for every future walk on this project:** a black window at startup is far more likely to be a stale second instance holding the Hive lock than a rendering bug in the code under test. Check for running instances and login items before debugging the UI.

## User Setup Required

None.

## Next Phase Readiness

All three tasks are complete and the walk passed. The shared chrome foundation is in place, so plans 05-02 through 05-05 can re-skin their areas inside an already-correct container and loading treatment. `SCR-01` and `GAP-06` are satisfied. The one carried item — in-place live-flip verification — is blocked on a user-facing appearance toggle existing at all, and is tracked as a verification blocker rather than as work for this phase.

---
*Phase: 05-dashboard*
*Tasks 1-3 completed (walk PASSED with one recorded gap): 2026-07-20*

## Self-Check: PASSED

All 3 modified source files confirmed present on disk; both task commit hashes (`af09302`, `ee326da`) confirmed present in `git log`.
