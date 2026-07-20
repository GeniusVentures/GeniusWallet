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

requirements-completed: []  # SCR-01 / GAP-06 pend the Task 3 human-verify walk (blocking checkpoint, not performed)

# Coverage metadata — Task 3 (human-verify) is outstanding. The entries below
# cover the Task 1-2 static surface only; the live-flip, gate, and pull-to-refresh
# behaviors are NOT yet proven.
coverage:
  - id: D1
    description: "DashboardScrollContainer is a GWDecorations.surface Container reading its appearance-aware border via Theme.of(context).extension<GWColors>() ?? GWColors.dark(); no Card, no deepBlue*/Colors.white survives; layout arithmetic and the three behaviour sites unchanged"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "flutter analyze lib/dashboard/home/view/dashboard_screen.dart (No issues found) + grep -q 'extension<GWColors>()' + bash tool/verify_additive_boundary.sh PASSED + git diff confirming only the container hunk changed"
        status: pass
    human_judgment: true
    rationale: "Static gates prove the access path and that layout/behaviour were untouched, but whether all five areas actually render in the new surface treatment and flip LIVE on an in-place appearance toggle can only be confirmed by watching it render — that is exactly the Task 3 walk (steps 1, 5, 6)."
  - id: D2
    description: "Canonical Loading re-skinned in place (brandGreen/statusInfo dots, Wrap(space8), headlineLg) reaching all 19 importers, with the shadow left dead and no importer repointed"
    requirement: "GAP-06"
    verification:
      - kind: command
        ref: "flutter analyze lib/components/loading.dart (No issues found) + tool/verify_additive_boundary.sh Check 1 PASSED (canonical importer set still 19, shadow still un-imported) + git status confirming lib/components/loading/loading.dart unmodified"
        status: pass
    human_judgment: true
    rationale: "The importer-boundary guard proves reach mechanically, but that the re-skinned spinner actually appears on the dashboard, markets grid, and news feed while they load (§3.2's one-edit-four-surfaces claim) requires the Task 3 walk (steps 2, 4)."
  - id: D3
    description: "FutureStateWidget default chrome token-correct (Icons.error_outline + statusError, GWButton primary retry) with onRetry/error plumbing byte-identical"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "flutter analyze lib/components/custom_future_builder.dart (No issues found) + git diff showing the onRetry wiring and error-slot resolution unchanged + no Colors.red/blue survives"
        status: pass
    human_judgment: true
    rationale: "The default error branch fires only on a forced load failure; confirming the error-with-retry path renders a working GWButton and never an endless spinner is Task 3 step 2."

# Metrics
duration: ~20min
completed: 2026-07-20
status: complete
---

# Phase 05 Plan 01: Dashboard Chrome Foundation Summary

**Re-skinned the DashboardScrollContainer that wraps all five dashboard areas onto an appearance-aware `GWDecorations.surface` Container, and re-skinned the shared `Loading` widget in place so all 19 importers inherit the redesign spinner — with develop's accountStatus gate, pull-to-refresh, and guarded `getCoins()` preserved byte-identical.**

## Performance

- **Duration:** ~20 min (Tasks 1-2)
- **Completed:** 2026-07-20 (auto tasks only; Task 3 is a blocking human checkpoint)
- **Tasks:** 2 of 3
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

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`):** NOT performed — see "Outstanding" below.

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

**None of this constitutes the visual/behavioral verification Task 3 exists to provide.**

## Outstanding: Task 3 (BLOCKING-HUMAN, not performed)

Task 3 is a `checkpoint:human-verify` gate (`autonomous: false`) requiring a live run. It was intentionally **not** performed or fabricated by this executor run. Note that the plan's `<how-to-verify>` block carries a stale Windows recipe (`flutter run -d windows`, a `/c/Users/...` SDK path); the user is on macOS and runs `gmac` (macOS desktop) or `gios` (physical iPhone). The walk itself is unchanged:

1. **Criterion 1 (container):** all five dashboard areas render in the new `GWDecorations.surface` treatment — rounded `radiusLg`, hairline edge, top-lit sheen; no flat legacy Material `Card`, no hardcoded-dark fill.
2. **Criterion 3 (gate, finding 9):** while the account loads, the dashboard shows the re-skinned spinner (mint + cyan dots) and never a bare hero balance pre-load; a forced wallet/account failure shows an error with a working retry, not an endless spinner.
3. **Criterion 2 (finding 17):** single-column pull-to-refresh dispatches a reload (wallets + `getCoins`).
4. **Loading reach (§3.2):** the re-skinned spinner also appears on the markets grid and news feed while they load — one edit, four surfaces.
5. **LIVE-FLIP:** toggling appearance in place (Dev header row, `--dart-define=GW_DEV_TOOLS=true`) re-skins all five container surfaces immediately. A card that stays dark means a stale-const regression and **blocks close**.
6. **Both modes:** full walk in light and dark, WCAG AA for text-on-container in each. A light-mode regression blocks close.

`requirements-completed` is intentionally empty (`SCR-01`, `GAP-06`) until this walk passes.

## User Setup Required

None.

## Next Phase Readiness

Tasks 1-2 are committed and pass every automated gate. The shared chrome foundation is in place, so plans 05-02 through 05-05 can re-skin their areas inside an already-correct container and loading treatment. This plan cannot be marked verified — and `SCR-01`/`GAP-06` cannot be marked satisfied — until the Task 3 walk is performed on `gmac` in both appearance modes.

---
*Phase: 05-dashboard*
*Tasks 1-2 completed: 2026-07-20 — Task 3 human walk outstanding*

## Self-Check: PASSED

All 3 modified source files confirmed present on disk; both task commit hashes (`af09302`, `ee326da`) confirmed present in `git log`.
