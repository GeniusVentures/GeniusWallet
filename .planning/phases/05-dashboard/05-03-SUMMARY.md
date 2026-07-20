---
phase: 05-dashboard
plan: 03
subsystem: ui
tags: [flutter, dashboard, coins, gwcolors, gwemptystate, gwdecorations, appearance]

# Dependency graph
requires:
  - phase: 05-dashboard (05-01)
    provides: "Re-skinned canonical Loading (coins_screen is one of its 19 importers) and the GWDecorations.surface pattern this plan applies to the loading-state container"
  - phase: 05-dashboard (05-02)
    provides: "The textOnBrand-over-brand-fill WCAG precedent (not consumed directly here, but the gw.textPrimary access-path discipline this plan follows)"
  - phase: 04-navigation-shell-chrome (04-02, 04-04)
    provides: "GWColors ThemeExtension + the fail-soft Theme.of(context).extension<GWColors>() ?? GWColors.dark() access path"
  - phase: 03-gw-component-library
    provides: "GWEmptyState, GWDecorations.surface"
provides:
  - "Re-skinned holdings list (CoinsScreen loading/empty states, CoinCardRow value text) with develop's ListTile structure, gain/loss logic, buildTokenIcon fallback, and the finding-14 1-minute refresh cadence unchanged"
  - "The deliberate 'No Coins Detected' -> 'No coins yet' copy change (§6 recorded substitution)"
affects: [05-04, 05-05, 05-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "coins_screen.dart's loading-state gw read is threaded into GWDecorations.surface's border: parameter (same pattern 05-01 established for DashboardScrollContainer) so the Theme dependency has a real appearance-aware consumer instead of an unused local"
    - "GWEmptyState does its own internal fail-soft GWColors read, so the empty-state branch needed no separate gw consumer of its own"

key-files:
  created: []
  modified:
    - lib/components/coins/view/coins_screen.dart
    - lib/components/coins/view/coin_card_row.dart

key-decisions:
  - "The empty state's GWEmptyState instance is const-constructed (title/message/icon are all compile-time literals) — GWEmptyState internally performs its own Theme.of(context).extension<GWColors>() read at build time, so const-ness here does not reintroduce the live-flip staleness risk 04-04 identified; that risk applies to widgets that capture a color value at construction time, not to ones that read Theme inside their own build()."
  - "coins_screen.dart's loading-state gw read is bound to GWDecorations.surface's border: parameter, mirroring 05-01's exact resolution for DashboardScrollContainer (GWDecorations.surface has no surface-color parameter — its fill derives internally from the appearance-aware surfaceSheen getter)."

requirements-completed: []  # SCR-01 NOT yet claimed complete — Task 2's blocking walk has not been performed

# Coverage metadata — Task 1 automated gates only. Task 2 (checkpoint:human-verify,
# gate="blocking") is NOT YET PERFORMED; every visual/behavioural claim below is
# recorded as pending, never as passed. Per the LIVE-FLIP clause instruction, the
# live-reskin claim for coin_card_row's value text is explicitly NOT claimed passed.
coverage:
  - id: D1
    description: "coins_screen.dart loading state is a GWDecorations.surface Container (not a hardcoded-color Card) wrapping the re-skinned Loading; empty state is a GWEmptyState reading 'No coins yet'"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "flutter analyze lib/components/coins/view/coins_screen.dart lib/components/coins/view/coin_card_row.dart (No issues found) + bash tool/verify_additive_boundary.sh PASSED + grep -q 'Duration(minutes: 1)' PRESENT + git diff confirming only the intended hunks changed"
        status: pass
      - kind: manual
        ref: "Task 2 walk — NOT YET PERFORMED"
        status: pending
    human_judgment: true
    rationale: "Token wiring and the grep/analyze gates are proven statically. That the holdings list actually reads as the redesign, matches the Release exe reference, and the empty state renders correctly are visual facts only the walk can establish."
  - id: D2
    description: "coin_card_row.dart's one hardcoded Colors.white value text now reads gw.textPrimary via the fail-soft GWColors extension read, so it re-skins on an in-place appearance toggle"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "grep -q 'extension<GWColors>()' PRESENT in coin_card_row.dart; grep confirms no Colors.white/Colors.red/deepBlueCardColor survives in either file"
        status: pass
      - kind: manual
        ref: "Task 2 walk step 5 (LIVE-FLIP) — NOT YET PERFORMED. Per the plan's live-flip clause, this executor does NOT claim this criterion passed; the gw.textPrimary migration is implemented and the mechanism is wired identically to 05-02's proven-live pattern, but the observation itself is the human walk's job."
        status: pending
    human_judgment: true
    rationale: "The migration is code-complete and follows the same access-path mechanism 05-02 verified live via the dev-tools bubble toggle. This executor records the migration as done, not the live-flip observation as passed — an unearned pass is exactly what this clause forbids."
  - id: D3
    description: "develop's behaviour preserved: ListTile row structure kept (no GWTokenRow swap), gain/loss cs.primary/cs.error logic unchanged, pull-to-refresh/getCoins wiring untouched, market-data Timer.periodic still Duration(minutes: 1) (finding 14)"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "git diff shows the ListTile structure, cs.primary/cs.error gain/loss branch, pull-to-refresh/getCoins wiring, and Timer.periodic(const Duration(minutes: 1)) at :44 are byte-identical; grep -q 'Duration(minutes: 1)' gate PASSED"
        status: pass
      - kind: manual
        ref: "Task 2 walk step 3 (criterion 4, finding 14) — NOT YET PERFORMED"
        status: pending
    human_judgment: false
  - id: D4
    description: "No overflow/crash on long balance values: every AutoSizeText/overflow guard survives unchanged; buildTokenIcon -> Icons.image_not_supported fallback preserved; no Alex letter-avatar introduced (finding 30)"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "git diff shows both AutoSizeText widgets (name/balance subtitle, value text, gain/loss text) unchanged except the one color-token substitution; buildTokenIcon() call site untouched; no new avatar/letter-fallback code added anywhere in the diff"
        status: pass
      - kind: manual
        ref: "Task 2 walk step 4 (criterion 5) — NOT YET PERFORMED"
        status: pending
    human_judgment: false

# Metrics
duration: ~10min (Task 1)
completed: 2026-07-20
status: in-progress
---

# Phase 05 Plan 03: Holdings List Re-skin Summary

**Re-skinned develop's holdings list in place — `coins_screen.dart`'s loading state onto a `GWDecorations.surface` Container, its empty state onto `GWEmptyState` with the deliberate "No coins yet" copy change, and `coin_card_row.dart`'s one hardcoded `Colors.white` value text onto `gw.textPrimary` — while verifying the finding-14 market-data refresh Timer stays at exactly `Duration(minutes: 1)` and preserving develop's `ListTile` structure, gain/loss color logic, `buildTokenIcon` null-safe fallback, and pull-to-refresh wiring byte-identical. Task 1 (re-skin) is committed. Task 2's blocking `checkpoint:human-verify` walk has NOT been performed — no visual/behavioral criterion is claimed as passed.**

## Status: Task 1 COMPLETE — Task 2 walk PENDING

Task 1 committed as `1400128`. **Task 2's blocking `checkpoint:human-verify` has not been run.** Per this plan's explicit constraints, this executor does not perform the walk and does not claim the live-flip criterion (or any other visual criterion) as passed.

## Task Commits

1. **Task 1: Re-skin coins_screen.dart + coin_card_row.dart (§4.2); verify the 1-minute refresh** — `1400128` (feat)

**Task 2 (`checkpoint:human-verify`, `gate="blocking"`):** PENDING. Not performed by this executor.

## Files Modified

- `lib/components/coins/view/coins_screen.dart` (21 insertions / 18 deletions):
  - Imports: removed `auto_size_text` (no longer used after the empty-state swap) and `theme/genius_wallet_colors.dart` (no more `deepBlueCardColor`/`btnTextDisabled` raw references); added `components/feedback/gw_empty_state.dart`, `theme/genius_wallet_decorations.dart`, `theme/gw_colors.dart`.
  - Loading state: `Card(color: deepBlueCardColor, shadowColor: transparent, child: Center(child: Loading()))` → `Container(decoration: GWDecorations.surface(border: gw.borderSubtle), child: const Center(child: Loading()))`. The `Loading()` call itself is untouched — it inherits 05-01's re-skin automatically.
  - Empty state: `Card(color: deepBlueCardColor) + AutoSizeText('No Coins Detected', color: btnTextDisabled)` → `GWEmptyState(icon: Icons.account_balance_wallet_outlined, title: 'No coins yet', message: 'Your holdings will appear here once you receive a token.')`.
  - Added `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` inside the `BlocBuilder`'s `builder`, consumed by the loading state's `border:` parameter.
  - **Verified unchanged:** `Timer.periodic(const Duration(minutes: 1), ...)` at line 44 (finding 14) — confirmed present via `grep` gate and by direct re-read. **Also unchanged:** `_fetchMarketData`, `_calculateTotalValue`, the `BlocListener`'s `getCoins()`/`_fetchMarketData` dispatch, and the `CoinCardRow` construction loop with its divider logic.
- `lib/components/coins/view/coin_card_row.dart` (7 insertions / 3 deletions):
  - Import added: `theme/gw_colors.dart`.
  - Added `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` at the top of `build()`.
  - The value-text `TextStyle`'s `color: Colors.white` → `color: gw.textPrimary`; the enclosing `const TextStyle(...)` had to drop its `const` (the value now depends on a runtime `Theme.of(context)` read).
  - **Unchanged:** `ListTile` structure, `buildTokenIcon(iconPath: iconPath, size: 38)` call, both `AutoSizeText` widgets (name/balance subtitle, gain/loss trailing text) and their overflow guards, `changeColor` computation using `cs.primary`/`cs.error`/`cs.onSurfaceVariant`, `currencyFormatter`, `noBalance` logic.

## Element-by-Element (per UI-SPEC §4.2)

| Element | Before | After |
|---|---|---|
| Loading state | `Card(color: deepBlueCardColor, shadowColor: transparent)` | `Container(decoration: GWDecorations.surface(border: gw.borderSubtle))` |
| Empty state | `Card(color: deepBlueCardColor)` + `AutoSizeText('No Coins Detected', color: btnTextDisabled)` | `GWEmptyState(icon: account_balance_wallet_outlined, title: 'No coins yet', message: '...')` |
| Row value text | `Colors.white` | `gw.textPrimary` |
| Divider | `const Divider()` | unchanged (Material default already resolves through the wired theme, per UI-SPEC §4.2) |

## The ONE Deliberate Copy Change

**"No Coins Detected" → "No coins yet"** (with the new explanatory body "Your holdings will appear here once you receive a token."), following UI-SPEC §6's recorded "No `<thing>` yet" empty-state pattern. This is the only copy change this plan makes — no other user-facing string was touched.

## Plan-Mandated Confirmations

- **`Timer.periodic(const Duration(minutes: 1), ...)` (finding 14) is unchanged.** Re-read at line 44 post-edit; `grep -q 'Duration(minutes: 1)'` gate passes. No regression to a 20-second interval was introduced.
- **No Alex letter-avatar was introduced.** `buildTokenIcon()` call site is byte-identical; no new icon-fallback code was added anywhere in the diff. Finding 30's `Icons.image_not_supported` null-safe path (in `image_utils.dart`, untouched by this plan) remains the sole fallback.
- **The `ListTile` structure was kept — no `GWTokenRow` swap.** This was a mechanical color-token translation, not a component migration, per the plan's explicit instruction.
- **Gain/loss color logic (`cs.primary`/`cs.error`/`cs.onSurfaceVariant`) is untouched** — it already flips correctly post-Phase-4 theme wiring and needed no change.
- **Pull-to-refresh / `getCoins()` wiring is untouched** — the `BlocListener`'s dispatch logic was not touched by this diff.
- **Every `AutoSizeText`/overflow guard survives unchanged** — only the one `TextStyle.color` value changed on the trailing value text; the `minFontSize`/`maxLines`/`overflow: TextOverflow.ellipsis` parameters on all three `AutoSizeText` instances (name/balance subtitle, value, gain/loss) are byte-identical.

## LIVE-FLIP Clause — Explicitly NOT Claimed Passed

Per this plan's binding constraint, the `gw.textPrimary` migration on `coin_card_row.dart`'s value text is **implemented**, not **observed live**. The access-path mechanism (`Theme.of(context).extension<GWColors>() ?? GWColors.dark()`) is identical to the one 05-02 verified live via the dev-tools bubble appearance toggle on `wallet_overview.dart`, so the mechanism itself is de-risked by precedent — but this executor did not run the app and did not observe the flip. This criterion is recorded as **pending-walk**, matching the plan's LIVE-FLIP anti-pattern instruction exactly. The dev-tools bubble toggle (`GW_DEV_TOOLS=true`) now exists, so the walk can genuinely verify this — unlike the earlier 05-01/05-02 pre-bubble state.

## Deviations from Plan

None — plan executed exactly as written. No Rule 1-4 auto-fixes were needed; the `GWDecorations.surface` border-parameter binding follows the exact precedent 05-01 already established (see that plan's Deviation #1), so it is not recorded here as a new deviation.

## Issues Encountered

None.

## Verification Results (Task 1, automated only)

- `flutter analyze lib/components/coins/view/coins_screen.dart lib/components/coins/view/coin_card_row.dart` — **No issues found**.
- `bash tool/verify_additive_boundary.sh` — **PASSED**. Check 1: `Loading` canonical importer set still matches its 19-file baseline (coins_screen.dart remains one of them, no repoint); `WalletsOverview` and `Splash` boundaries unaffected (not touched by this plan). Check 2: duplicate-class census subset of baseline. Check 3: no `WIRE-` markers in `lib/`.
- Grep gates: `extension<GWColors>()` **present** in `coin_card_row.dart`; `Duration(minutes: 1)` **present** in `coins_screen.dart`.
- Raw-value discipline: `grep -n "Colors.white\|deepBlueCardColor\|Colors.red"` across both files returns **zero matches**.
- `git status --short` after commit shows no unexpected untracked or modified files beyond this plan's two declared files (pre-existing unrelated `README.md` and `.planning/phases/05-dashboard/.continue-here.md` modifications, both left untouched and unstaged).
- `git diff --diff-filter=D --name-only HEAD~1 HEAD` — no file deletions in the commit.

**None of this constitutes the visual/behavioral verification Task 2's walk provides.**

## User Setup Required

None for Task 1. Task 2's walk requires a cold debug run on Windows: `flutter run -d windows --dart-define=GW_DEV_TOOLS=true` (pinned SDK, `CMAKE_ARGUMENTS` per the project's documented local-build recipe). Close any running Release exe first — a stale second instance can hold the Hive lock and produce a black window (05-01's documented environment finding, same failure mode applies on Windows).

## Next Phase Readiness

Task 1's code work is complete and committed (`1400128`). **This plan is not closeable until Task 2's blocking walk runs and its results (per-mode, per-criterion) are recorded here.** `SCR-01` is not claimed complete pending that walk. 05-04 onward can proceed in parallel — this plan touched only `coins_screen.dart` and `coin_card_row.dart`.

---
*Phase: 05-dashboard*
*Task 1 completed: 2026-07-20. Task 2 (blocking human-verify): PENDING.*

## Self-Check: PASSED

`lib/components/coins/view/coins_screen.dart` and `lib/components/coins/view/coin_card_row.dart` confirmed present on disk; task commit `1400128` confirmed present in `git log`.
