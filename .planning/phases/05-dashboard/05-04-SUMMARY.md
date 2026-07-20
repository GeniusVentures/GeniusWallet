---
phase: 05-dashboard
plan: 04
subsystem: ui
tags: [flutter, dashboard, markets, gwcolors, gwtextfield, gwdecorations, appearance]

# Dependency graph
requires:
  - phase: 05-dashboard (05-01)
    provides: "Re-skinned canonical Loading (markets_search_bar is one of its 19 importers) and the GWDecorations.surface / GWColors.extension() access-path pattern this plan applies to the grid cards"
  - phase: 05-dashboard (05-03)
    provides: "The token-discipline precedent (border: parameter binding, GeniusWalletTypography copyWith(color: gw.*)) this plan follows for markets_screen.dart and dashboard_markets.dart"
  - phase: 04-navigation-shell-chrome (04-02, 04-04)
    provides: "GWColors ThemeExtension + the fail-soft Theme.of(context).extension<GWColors>() ?? GWColors.dark() access path"
  - phase: 03-gw-component-library
    provides: "GWTextField, GWDecorations.surface"
provides:
  - "Re-skinned markets surface chrome: MarketsScreen heading/grid/error text, MarketSearchBar (GWTextField), DashboardMarkets title/divider -- with develop's cached-futures + retry wiring (finding 8) and null-safe icon fallback (finding 30) unchanged"
affects: [05-05, 05-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "markets_screen.dart's FutureStateWidget error slots keep a token-styled Text (GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary)) rather than swapping to GWErrorState(onRetry: ...) -- GWErrorState's own onRetry would render a SECOND GWButton alongside FutureStateWidget's own auto-appended retry button (custom_future_builder.dart's Column always appends a GWButton when onRetry != null, regardless of the custom error: widget supplied), which would be a double-retry-button regression. The plan's own fallback clause ('or, if GWErrorState does not fit, token the error text') anticipated exactly this."
    - "markets_search_bar.dart's raw TextField -> GWTextField is a direct mechanical swap; GWTextField owns its own brandPrimary 2px focus border and gw.surfaceElevated fill internally, so no per-call-site border/fill styling survives"

key-files:
  created: []
  modified:
    - lib/dashboard/chart/markets_screen.dart
    - lib/dashboard/chart/markets_search_bar.dart
    - lib/dashboard/chart/dashboard_markets.dart

key-decisions:
  - "GWErrorState was NOT used for markets_screen.dart's two FutureStateWidget error slots. Investigating custom_future_builder.dart showed it ALREADY appends its own GWButton('Retry') beneath whatever `error:` widget is supplied, whenever `onRetry != null` -- true today for both slots (finding 8's existing wiring). Passing GWErrorState(onRetry: _retryCoins) as the `error:` widget would add a SECOND, redundant retry button (GWErrorState's own GWButton plus FutureStateWidget's auto-appended one). The plan's action text names this exact fallback ('or, if GWErrorState does not fit, token the error text to GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary)') -- taken here, with `onRetry` passed to FutureStateWidget only, never touched."
  - "dashboard_markets.dart's actual pre-edit state did not match the plan's read_first assumption (AutoSizeText/GeniusWalletFontSize.sectionHeader raw TextStyle heading, Container(height 2, deepBlueTertiary) divider). The FILE ON DISK already used Theme.of(context).textTheme.titleLarge for the title (no raw color) and Material's default Divider() (no raw color either) -- likely drifted since the UI-SPEC's research pass. Applied the SAME INTENT the plan specifies (typography-token heading, hairline gw.borderSubtle divider) to the actual code rather than the stale read_first text: Text(...) -> GeniusWalletTypography.titleLg.copyWith(color: gw.textPrimary); Divider() -> Container(height: 1, color: gw.borderSubtle)."
  - "Missing-data placeholder's debug text (coin.symbol/coin.id) was also token-styled (GeniusWalletTypography.bodySm.copyWith(color: gw.textPrimary)) even though the plan's action text only named the Container's fill color -- the raw `TextStyle(color: Colors.white)` on that Text would otherwise survive and violate SS7's zero-raw-Colors.white gate."

requirements-completed: []  # SCR-01 NOT marked complete -- Task 2's blocking human-verify walk has NOT been performed. See 'Outstanding' below.

# Coverage metadata -- Task 1 (auto, code re-skin) automated gates only.
# Task 2 (checkpoint:human-verify, gate="blocking") is NOT YET PERFORMED; every
# visual/behavioural claim below is recorded as pending, never as passed.
coverage:
  - id: D1
    description: "markets_screen.dart wears the redesign: headlineLg heading on gw.textPrimary, GWDecorations.surface grid cards, token-styled error text in both FutureStateWidget error slots, statusError-tinted missing-data placeholder"
    requirement: "SCR-01"
    verification:
      - kind: other
        ref: "flutter analyze lib/dashboard/chart/markets_screen.dart lib/dashboard/chart/markets_search_bar.dart lib/dashboard/chart/dashboard_markets.dart -- No issues found; grep -q 'extension<GWColors>()' PRESENT in markets_screen.dart; grep for Colors.white/grey[N]/deepBlueTertiary/lightGreenPrimary/Colors.red -- zero matches across all three files"
        status: pass
      - kind: manual_procedural
        ref: "Task 2 walk -- NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "Token wiring and the grep/analyze gates are proven statically. That the markets grid actually reads as the redesign, matches the Release exe reference, and both error/empty states render correctly are visual facts only the walk can establish."
  - id: D2
    description: "markets_search_bar.dart's raw TextField replaced by GWTextField ('Search Coins...', search prefix, brandPrimary focus border); re-skinned Loading suffix spinner kept"
    requirement: "SCR-01"
    verification:
      - kind: other
        ref: "flutter analyze -- No issues found; git diff confirms the Loading() suffix call is untouched; grep confirms 'Search Coins...' copy verbatim"
        status: pass
      - kind: manual_procedural
        ref: "Task 2 walk step 2 (search field focus border, suffix spinner while resolving) -- NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "GWTextField's focus-border and fill styling are code-verified present (component contract, not re-derived here) but the actual rendered focus ring and spinner timing are visual/behavioural facts only the walk can confirm."
  - id: D3
    description: "develop's finding-8 retry wiring (_retryCoins/_retryMarketData -> FutureStateWidget.onRetry) is untouched; a failed fetch surfaces a working retry, never an endless spinner"
    requirement: "SCR-01"
    verification:
      - kind: other
        ref: "git diff shows _retryCoins/_retryMarketData function bodies byte-identical; grep -n '_retryCoins|_retryMarketData|onRetry:' confirms both onRetry: call sites still wired to the same functions post-edit"
        status: pass
      - kind: manual_procedural
        ref: "Task 2 walk step 3 (criterion 3, forced fetch failure + retry press) -- NOT YET PERFORMED"
        status: unknown
    human_judgment: true
    rationale: "The wiring is statically proven unchanged (diff + re-read), but that a forced failure actually surfaces the retry button and that pressing it re-issues the fetch are runtime facts only the walk can observe."
  - id: D4
    description: "No letter-avatar introduced for empty/missing coin symbols (finding 30); develop's null-safe icon path preserved"
    requirement: "SCR-01"
    verification:
      - kind: other
        ref: "git diff shows no new icon-fallback/avatar code added anywhere in the three files; CryptoSparkLineChart's iconPath call site (data.imageUrl) is byte-identical"
        status: pass
      - kind: manual_procedural
        ref: "Task 2 walk step 4 (criterion 5, empty-symbol coin renders without overflow/crash) -- NOT YET PERFORMED"
        status: unknown
    human_judgment: false

# Metrics
duration: ~25min (Task 1)
completed: 2026-07-20
status: blocked
---

# Phase 05 Plan 04: Markets Surface Re-skin Summary

**Re-skinned develop's markets surface in place -- `markets_screen.dart`'s heading (headlineLg), grid cards (GWDecorations.surface), and both FutureStateWidget error slots (token-styled text, no GWErrorState to avoid a double-retry-button regression); `markets_search_bar.dart`'s raw TextField replaced by GWTextField; `dashboard_markets.dart`'s title/divider aligned to typography/border tokens -- while verifying finding 8's cached-futures + retry wiring and finding 30's null-safe icon fallback are untouched. Task 1 (re-skin) is committed. Task 2's blocking `checkpoint:human-verify` walk has NOT been performed -- no visual/behavioral criterion is claimed as passed.**

## Status: Task 1 COMPLETE -- Task 2 walk PENDING (blocking checkpoint)

Task 1 committed as `0c5d727`. **Task 2's blocking `checkpoint:human-verify` has NOT been performed by this executor** -- per this plan's explicit instruction, the walk is not run here. `SCR-01` is NOT claimed complete; `status: blocked` pending the human walk.

## Performance

- **Duration:** ~25 min (Task 1)
- **Completed:** 2026-07-20 (Task 1 only)
- **Tasks:** 1 of 2 (Task 2 is the blocking checkpoint, intentionally not executed)
- **Files modified:** 3

## Accomplishments

- **`markets_screen.dart`'s "Markets" heading** -- raw `TextStyle(fontSize: 32, w500, Colors.white)` -> `GeniusWalletTypography.headlineLg.copyWith(color: gw.textPrimary)` (UI-SPEC §4.3's explicit typography-token upgrade over Alex's own raw-32/w500-via-token-color choice).
- **Grid cards** -- `Card(clipBehavior: hardEdge, child: CryptoSparkLineChart(...))` -> `Container(decoration: GWDecorations.surface(radius: GeniusWalletConsts.radiusMd), clipBehavior: hardEdge, child: ...)`.
- **Both FutureStateWidget error slots** (coins-level and market-data-level) -- raw `TextStyle(color: Colors.white)` -> `GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary)`. The pre-existing `onRetry: _retryCoins` / `onRetry: _retryMarketData` wiring is untouched; `custom_future_builder.dart`'s own logic already appends a `GWButton('Retry')` beneath the error widget whenever `onRetry != null` -- confirmed unchanged by re-read.
- **Missing-data debug placeholder** -- `Container(color: Colors.red, ...)` -> `Container(color: GeniusWalletColors.statusError.withAlpha(100), ...)`, its text also token-styled (`GeniusWalletTypography.bodySm.copyWith(color: gw.textPrimary)`) to close the `Colors.white` survivor the plan's action text didn't explicitly call out.
- **The two "No market data available" empty-state texts** (coins-empty and marketData-empty branches) -- also re-tokened from raw `Colors.white` to `gw.textSecondary`, closing a §7 zero-raw-Colors.white survivor the plan's per-element table didn't separately enumerate.
- **`markets_search_bar.dart`'s raw `TextField`** -- replaced wholesale by `GWTextField(hint: 'Search Coins...', prefix: Icon(Icons.search, color: gw.textSecondary), suffix: ...)`. GWTextField owns its own `brandPrimary` 2px focus border and `gw.surfaceElevated` fill internally -- no manual border/fill styling survives. The `Loading()` suffix spinner (re-skinned by 05-01) and the clear-icon suffix logic are preserved, both re-tokened from `Colors.white` to `gw.textSecondary`.
- **`dashboard_markets.dart`'s title and divider** -- title `Theme.of(context).textTheme.titleLarge` -> `GeniusWalletTypography.titleLg.copyWith(color: gw.textPrimary)`; divider `Divider()` -> `Container(height: 1, color: gw.borderSubtle)` hairline, matching §4.2's precedent weight.
- **Findings 8 and 30 re-read and confirmed unregressed** after the edit, per UI-SPEC §2.1's standing discipline (see "Plan-Mandated Confirmations" below).

## Task Commits

1. **Task 1: Re-skin markets_screen.dart + markets_search_bar.dart + dashboard_markets.dart (§4.3)** -- `0c5d727` (feat)

**Task 2 (`checkpoint:human-verify`, `gate="blocking"`):** PENDING. Not performed by this executor -- per this plan's explicit instruction to stop at the checkpoint.

## Files Modified

- `lib/dashboard/chart/markets_screen.dart` (see per-element table below). Imports added: `theme/genius_wallet_colors.dart`, `theme/genius_wallet_consts.dart`, `theme/genius_wallet_decorations.dart`, `theme/genius_wallet_typography.dart`, `theme/gw_colors.dart`. `_retryCoins`/`_retryMarketData` bodies and their `onRetry:` bindings at (now) `:103`/`:130` are byte-identical to pre-edit `:97`/`:120` (line numbers shifted only due to the added import lines).
- `lib/dashboard/chart/markets_search_bar.dart`: `TextField` -> `GWTextField`; import swap `theme/genius_wallet_colors.dart` (no longer needed, only consumer was the removed `lightGreenPrimary` focus border) -> `components/inputs/gw_text_field.dart` + `theme/gw_colors.dart`. Debounce/search/coin-tap logic (`_onSearchChanged`, `_onCoinTap`) untouched.
- `lib/dashboard/chart/dashboard_markets.dart`: title and divider tokened (see key-decisions for the read_first-vs-actual-code note). `_future`/`_retry`/`FutureStateWidget` wiring untouched; its own `error:`/onData empty-state `Text`s were left as-is (no raw color present, not named in the plan's per-file action list).

## Element-by-Element (per UI-SPEC §4.3)

| Element | Before | After |
|---|---|---|
| "Markets" heading | `TextStyle(fontSize: 32, w500, Colors.white)` | `GeniusWalletTypography.headlineLg.copyWith(color: gw.textPrimary)` |
| Search icon button | plain `IconButton` | unchanged (icon-only affordance is fine as-is) |
| Grid card | `Card(clipBehavior: hardEdge)` | `Container(decoration: GWDecorations.surface(radius: radiusMd), clipBehavior: hardEdge)` |
| Coins-level error text | `TextStyle(color: Colors.white)` | `GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary)` |
| Market-data-level error text | `TextStyle(color: Colors.white)` | `GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary)` |
| Both "No market data available" texts | `TextStyle(color: Colors.white)` | `GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary)` |
| Missing-data placeholder fill | `Colors.red` | `GeniusWalletColors.statusError.withAlpha(100)` |
| Missing-data placeholder text | `TextStyle(color: Colors.white)` | `GeniusWalletTypography.bodySm.copyWith(color: gw.textPrimary)` |
| Market search field | raw `TextField` (Colors.white text, grey[900] fill, white24/38 borders, lightGreenPrimary focus) | `GWTextField(hint: 'Search Coins...', prefix: Icon(Icons.search))` |
| Search suffix spinner | `Loading()` in a `Padding` | unchanged (re-skinned automatically by 05-01) |
| `DashboardMarkets` title | `Theme.of(context).textTheme.titleLarge` | `GeniusWalletTypography.titleLg.copyWith(color: gw.textPrimary)` |
| `DashboardMarkets` divider | `Divider()` (Material default) | `Container(height: 1, color: gw.borderSubtle)` |

## Plan-Mandated Confirmations

- **Finding 8's retry wiring is unchanged.** `_retryCoins`/`_retryMarketData` function bodies are byte-identical; both `onRetry:` bindings on the two `FutureStateWidget`s still point to the same functions (confirmed via `grep -n '_retryCoins|_retryMarketData|onRetry:'` post-edit). No plumbing was touched -- only the `error:` slot's `Text` styling.
- **No Alex letter-avatar was introduced (finding 30).** No new icon-fallback/avatar code was added anywhere in the diff; `CryptoSparkLineChart`'s `iconPath: data.imageUrl` call site is byte-identical.
- **`GWErrorState` was deliberately NOT used** for the two `markets_screen.dart` error slots (see key-decisions) -- would have produced a double-retry-button bug. Token-styled `Text` was used instead, matching the plan's own named fallback.
- **Copy preserved verbatim:** "Search Coins...", "Failed to load market coins", "Failed to load market data", "No market data available" (×2 sites) -- confirmed via `grep` across all three files, zero rephrasing.
- **No `Colors.white`/`Colors.grey[N]`/`deepBlueTertiary`/`lightGreenPrimary`/`Colors.red` survives** in any of the three files -- confirmed via grep, zero matches.

## LIVE-FLIP Clause -- Explicitly NOT Claimed Passed

Per this plan's binding constraint, the appearance-aware `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` reads added to all three files (heading, grid card border via `GWDecorations.surface`, error text, search field, title, divider) are **implemented**, not **observed live**. The access-path mechanism is identical to the one 05-01/05-02/05-03 already established and (for 05-03) verified live via the dev-tools bubble appearance toggle -- so the mechanism itself is de-risked by precedent -- but this executor did not run the app and did not observe the flip. This criterion is recorded as **pending-walk**.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1/2 -- Token discipline] Tokened the two "No market data available" empty-state texts and the missing-data placeholder's debug text**
- **Found during:** Task 1
- **Issue:** The plan's per-element table (§4.3) named the heading, grid card, error-slot text, and missing-data placeholder FILL, but not the two empty-state `Text`s (both raw `TextStyle(color: Colors.white)`) or the missing-data placeholder's own `Text` style. Left as-is, these would violate §7's "zero `Colors.white`... survives in any file this phase touches" gate.
- **Fix:** Re-tokened all three to `GeniusWalletTypography.bodyMd`/`bodySm.copyWith(color: gw.textSecondary/textPrimary)` respectively, matching the same token discipline applied to the adjacent error-slot text.
- **Files modified:** `lib/dashboard/chart/markets_screen.dart`
- **Verification:** `grep -n "Colors.white"` across all three files returns zero matches; `flutter analyze` clean.
- **Committed in:** `0c5d727` (Task 1 commit)

**2. [Rule 1 -- Plan-vs-reality drift] `dashboard_markets.dart`'s read_first description did not match the file on disk**
- **Found during:** Task 1
- **Issue:** The plan's `read_first` claimed `dashboard_markets.dart` used `AutoSizeText(title, style: TextStyle(fontSize: GeniusWalletFontSize.sectionHeader, color: textPrimary))` for the title and `Container(height: 2, color: deepBlueTertiary)` for the divider. The actual file used `Text(widget.title!, style: Theme.of(context).textTheme.titleLarge)` (already theme-token-resolved, no raw color) and a plain Material `Divider()` (no raw color either) -- neither matches the plan's described "before" state.
- **Fix:** Applied the SAME visual intent the plan's action text specifies (typography-token heading, hairline `borderSubtle` divider) to the actual code rather than attempting to match a stale description: `Theme.of(context).textTheme.titleLarge` -> `GeniusWalletTypography.titleLg.copyWith(color: gw.textPrimary)`; `Divider()` -> `Container(height: 1, color: gw.borderSubtle)`.
- **Files modified:** `lib/dashboard/chart/dashboard_markets.dart`
- **Verification:** `flutter analyze` clean; no raw color survives.
- **Committed in:** `0c5d727` (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1/2, token-discipline completions consistent with the plan's own §7 gate). **Impact:** none on the plan's intent -- both closures make the re-skin MORE complete against §7's zero-raw-value gate than the plan's per-element table alone specified; neither touches behavior, structure, or copy.

## Issues Encountered

**`tool/verify_additive_boundary.sh` Check 2 fails on a PRE-EXISTING, unrelated duplicate class name.** `_Section` is declared in both `lib/dev/dev_tools_bubble.dart` and `lib/dev/design_gallery_screen.dart` -- neither file is touched by this plan (or any 05-* dashboard plan). Root-caused to prior unrelated quick-task commits (`c29fa0d`, `ddd9978`, `2c1527f`, 2026-07-20 dev-tools-bubble work). Checks 1 (shadow import boundary) and 3 (WIRE- tripwire) -- the checks actually relevant to this plan's scope -- both PASS. Logged to `.planning/phases/05-dashboard/deferred-items.md` per the SCOPE BOUNDARY rule rather than fixed here. **This file is currently untracked** -- left for the orchestrator's docs commit alongside this SUMMARY, since it documents a cross-plan pre-existing condition, not this plan's own deliverable.

## Verification Results (Task 1, automated only)

- `flutter analyze lib/dashboard/chart/markets_screen.dart lib/dashboard/chart/markets_search_bar.dart lib/dashboard/chart/dashboard_markets.dart` -- **No issues found**.
- `bash tool/verify_additive_boundary.sh` -- Check 1 (shadow import boundary, `Loading`/`Splash`/`WalletsOverview`) **PASSED**; Check 3 (WIRE- tripwire) **PASSED**; Check 2 **FAILED on a pre-existing, unrelated `_Section` duplicate class name** in `lib/dev/` files this plan does not touch (see "Issues Encountered").
- Grep gate: `extension<GWColors>()` **present** in `markets_screen.dart`.
- Raw-value discipline: `grep -n "Colors.white\|Colors.grey\[\|deepBlueTertiary\|lightGreenPrimary\|Colors.red\b"` across all three files returns **zero matches**.
- Copy-verbatim grep: "Search Coins...", "Failed to load market coins", "Failed to load market data", "No market data available" all present, unchanged, across the three files.
- `_retryCoins`/`_retryMarketData` wiring re-read: both functions byte-identical, both `onRetry:` bindings unchanged.
- `git diff --diff-filter=D --name-only HEAD~1 HEAD` -- no file deletions in the Task 1 commit.
- `git status --short` after commit -- only the plan's three declared files staged/committed; pre-existing unrelated `README.md` modification left untouched and unstaged; new `.planning/phases/05-dashboard/deferred-items.md` left untracked for the orchestrator's docs commit.

**None of this constitutes the visual/behavioral verification Task 2's walk provides.**

## User Setup Required

None for Task 1. Task 2's blocking walk requires a cold debug run on **Windows** (this machine): `flutter run -d windows --dart-define=GW_DEV_TOOLS=true` (pinned Flutter SDK on PATH at `/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, `CMAKE_ARGUMENTS` per the project's documented local-build recipe). Close any running Release exe first -- a stale second instance can hold the Hive lock and produce a black window (05-01's documented environment finding, same failure mode applies here).

## Next Phase Readiness

Task 1's code work is complete and committed (`0c5d727`). **This plan is not closeable until Task 2's blocking walk runs and its results (per-mode, per-criterion) are recorded here.** `SCR-01` is not claimed complete pending that walk. 05-05/05-06 can proceed independently -- this plan touched only `markets_screen.dart`, `markets_search_bar.dart`, and `dashboard_markets.dart`.

---
*Phase: 05-dashboard*
*Task 1 completed: 2026-07-20. Task 2 (blocking human-verify): PENDING.*

## Self-Check: PASSED

`lib/dashboard/chart/markets_screen.dart`, `lib/dashboard/chart/markets_search_bar.dart`, and `lib/dashboard/chart/dashboard_markets.dart` confirmed present on disk; task commit `0c5d727` confirmed present in `git log`.
