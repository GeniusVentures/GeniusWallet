---
phase: 05-dashboard
plan: 02
subsystem: ui
tags: [flutter, dashboard, hero-balance, gwcolors, gwanimatednumber, typography, wcag, appearance]

# Dependency graph
requires:
  - phase: 05-dashboard (05-01)
    provides: "DashboardScrollContainer re-skinned to an appearance-aware GWDecorations.surface Container — the container this hero now renders inside — and the re-skinned Loading treatment the pre-load gate falls back to"
  - phase: 04-navigation-shell-chrome (04-02, 04-04)
    provides: "GWColors ThemeExtension + the fail-soft Theme.of(context).extension<GWColors>() ?? GWColors.dark() access path"
  - phase: 03-gw-component-library
    provides: "GWAnimatedNumber (the §1-sanctioned component reuse) and 03-SHADOW-NAMES.md's canonical-path-wins binding rule for the WalletsOverview shadow pair"
provides:
  - "Re-skinned hero balance / wallet overview — headlineMd label, numericDisplay balance counting up via GWAnimatedNumber, statusError 'No funds available', token-re-skinned GNUS/Minions toggle — with develop's SGNUS/non-SGNUS branches and connection/submit-job stack carried intact"
  - "A WCAG-corrected brand-fill pairing precedent for ToggleButtons (textOnBrand over brandPrimary) that 05-03..05-06 should follow wherever a brand fill carries text"
affects: [05-03, 05-04, 05-05, 05-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "GWAnimatedNumber's currency prefix is read off NumberFormat.simpleCurrency().currencySymbol rather than hardcoded '$', so replacing develop's simpleCurrency().format() with the animated component preserves non-USD locale rendering instead of silently pinning the app to a dollar sign"

key-files:
  created: []
  modified:
    - lib/components/wallet_overview.dart

key-decisions:
  - "UI-SPEC §3.1's literal toggle spec (selectedColor: textPrimary over fillColor: brandPrimary) measures 1.96:1 in dark mode — a hard WCAG AA failure. Substituted GeniusWalletColors.textOnBrand (10.12:1), the token this project already pairs with brand fills in theme.dart and UI-SPEC §3.3. Rule 2 auto-fix; the spec table should be corrected."
  - "The balance figure's currency symbol is sourced from NumberFormat.simpleCurrency().currencySymbol, not hardcoded, because GWAnimatedNumber formats via decimalPatternDigits and would otherwise drop develop's locale-aware symbol."
  - "develop's dead `displayBalance` ternary was removed rather than preserved — the `balance == 0` arm was unreachable behind the earlier `if (balance == 0) return` and keeping it would have been an unused_local_variable once the static Text became GWAnimatedNumber."
  - "'No funds available' follows the spec to bodyMd + statusError, which drops develop's FontWeight.bold. Flagged for the walk in case the lost emphasis reads as a regression."

requirements-completed: []  # SCR-01 / GAP-06 NOT claimed — Task 2's blocking walk has not been performed

# Coverage metadata — Task 1 automated gates only. Task 2 (checkpoint:human-verify,
# gate="blocking") is NOT YET PERFORMED; every visual/behavioural claim below is
# recorded as pending, never as passed.
coverage:
  - id: D1
    description: "Hero wears the redesign: 'Current Balance' is headlineMd on gw.textSecondary; the balance figure is numericDisplay on gw.textPrimary wrapped in GWAnimatedNumber; appearance-aware colors read via Theme.of(context).extension<GWColors>()"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "flutter analyze lib/components/wallet_overview.dart (No issues found) + grep -q 'extension<GWColors>()' PRESENT + git diff confirming only the intended hunks changed"
        status: pass
      - kind: manual
        ref: "Task 2 walk step 1 — hero matches the Release exe reference and counts up on first paint, both modes"
        status: pending
    human_judgment: true
    rationale: "Token wiring is proven statically. That the hero actually reads as the redesign and that the count-up animation fires on first paint are visual facts only the walk can establish."
  - id: D2
    description: "develop's behaviour kept, not Alex's mock: SGNUS branch (GeniusBalanceDisplay + GNUS/Minions toggle), non-SGNUS branch, and the SGNUSConnectionWidget + SGNUSConnectionStatusWidget + SubmitJobDashboardButton stack all structurally unchanged; no 24h delta, no action-pill row, no Assets/NFTs tab"
    requirement: "GAP-06"
    verification:
      - kind: command
        ref: "git diff — the SGNUS branch, the connection/submit-job stack, and the ToggleButtons isSelected/onPressed behaviour are byte-identical; no delta/percentage/tab widget added; tool/verify_additive_boundary.sh Check 3 confirms no WIRE- markers in lib/"
        status: pass
      - kind: manual
        ref: "Task 2 walk step 2 — toggle switches units, balance display / connection widgets / Submit Job all functional, nothing of Alex's IA present on screen"
        status: pending
    human_judgment: false
  - id: D3
    description: "'No funds available' uses statusError (mode-invariant) replacing hardcoded Colors.red; GNUS/Minions ToggleButtons re-skinned with behaviour intact"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "grep confirms no Colors.red/Colors.white/Colors.blue and no raw hex survives in the file; statusError/brandPrimary/textOnBrand/borderSubtle are on the mode-invariant static getters, not routed through GWColors"
        status: pass
      - kind: manual
        ref: "Task 2 walk step 2 — the zero-funds message reads in statusError and the toggle is legible in BOTH modes (this is where the textOnBrand substitution gets its real check)"
        status: pending
    human_judgment: true
    rationale: "The 1.96:1 -> 10.12:1 correction is computed, not seen. The walk is what confirms the selected toggle segment is actually readable on the cyan fill in both modes."
  - id: D4
    description: "The hero still does not render before the account has loaded (finding 9, criterion 3) — unchanged by this plan"
    requirement: "SCR-01"
    verification:
      - kind: command
        ref: "git diff confirms this plan touched only lib/components/wallet_overview.dart; DashboardScreenState's loaded gate (dashboard_screen.dart:57-69) was not modified"
        status: pass
      - kind: manual
        ref: "Task 2 walk step 3 — no hero flash before account load"
        status: pending
    human_judgment: false
  - id: D5
    description: "The hero re-skins LIVE on an in-place appearance toggle"
    requirement: "SCR-01"
    verification:
      - kind: manual
        ref: "Task 2 walk step 4 — BLOCKED, structurally unverifiable; see 'Outstanding' below"
        status: blocked
    human_judgment: true
    rationale: "Carries 05-01's recorded gap forward unchanged: there is no user-facing appearance toggle, so an IN-PLACE flip cannot be performed. Not claimable as a pass."

# Metrics
duration: ~15min (Task 1)
completed: 2026-07-20
status: awaiting-verification
---

# Phase 05 Plan 02: Hero Balance Re-skin Summary

**Re-skinned develop's hero balance / wallet overview in place — `headlineMd` label on `gw.textSecondary`, the balance figure as `numericDisplay` counting up through `GWAnimatedNumber`, `statusError` for "No funds available", and a token-re-skinned GNUS/Minions toggle — while carrying develop's SGNUS/non-SGNUS branches and the connection/submit-job stack byte-identical. One WCAG AA failure in the UI-SPEC's own toggle table was caught by measurement and corrected. Task 2's blocking walk has NOT been performed; no visual criterion is claimed as passed.**

## Status: awaiting the Task 2 walk

Task 1 is complete and committed. **Task 2 is a `checkpoint:human-verify` with `gate="blocking"` and has not been run** — this plan is `autonomous: false` and the walk requires a human on `gmac`. `SCR-01` and `GAP-06` are deliberately **not** marked complete, and `status:` is `awaiting-verification` rather than `complete`. Everything below the automated-gates section is a description of what was built, not a claim that it was seen working.

## Task Commits

1. **Task 1: Re-skin wallet_overview.dart (§3.1 / §4.1) in place** — `8a5e5a9` (feat)

**Task 2 (`checkpoint:human-verify`, `gate="blocking"`):** pending. Walk recipe reproduced below, translated to macOS.

## Files Modified

- `lib/components/wallet_overview.dart` — `build()` and `_buildToggle()` only. Four theme/component imports added (`gw_animated_number.dart`, `genius_wallet_colors.dart`, `genius_wallet_typography.dart`, `gw_colors.dart`). The `WalletsOverview`/`WalletsOverviewState` class shape, `useMinions` state, `initState`/`dispose`, both `BlocBuilder`s, the `StreamBuilder`, and the `SGNUSConnectionWidget` + `SGNUSConnectionStatusWidget` + `SubmitJobDashboardButton` stack are untouched. 40 insertions / 15 deletions, one file, no deletions of tracked files.

## What Changed, Element by Element

| Element | Before | After |
|---|---|---|
| "Current Balance" label | `textTheme.headlineMedium` | `GeniusWalletTypography.headlineMd` on `gw.textSecondary` |
| "No wallet selected" | plain `Text` | `bodyMd` on `gw.textSecondary` |
| "No funds available" | `TextStyle(Colors.red, 16, bold)` | `bodyMd` on `GeniusWalletColors.statusError` |
| Balance figure | `Text` in raw `TextStyle(36, w500)` | `GWAnimatedNumber` in `numericDisplay` on `gw.textPrimary` |
| GNUS/Minions toggle | Material defaults | `fillColor: brandPrimary`, `selectedColor: textOnBrand`, `borderColor: borderSubtle` |

The container is untouched — `DashboardScrollContainer` (05-01) owns it, and this hero now renders inside it.

## Plan-Mandated Confirmations

- **GWAnimatedNumber reuse is visual only, no behavior attached.** It animates develop's own `state.selectedWalletBalance`-derived value and nothing else. No delta, no percentage, no second data source.
- **No WIRE-9 24h delta was introduced.** No delta widget, no percentage, no comparison value exists in the file. `tool/verify_additive_boundary.sh` Check 3 confirms no `WIRE-` markers anywhere in `lib/`.
- **No WIRE-8 Assets/NFTs tab and no action-pill row was introduced.** Alex's IA is absent; develop's `Column` structure is what remains.
- **The shadow stayed read-only.** `lib/components/wallets_overview.g.dart` is unmodified (`git status` clean for it) and un-imported. `dashboard_screen.dart:22` still imports the canonical `package:genius_wallet/components/wallet_overview.dart` — not repointed. `verify_additive_boundary.sh` Check 1 confirms the `WalletsOverview` canonical importer set still matches its 1-file baseline and the shadow path has zero un-allowlisted importers.

## Decisions Made

### The UI-SPEC's toggle spec fails WCAG AA — corrected to `textOnBrand`

UI-SPEC §3.1's substitution table and this plan's action text both specify `fillColor` → `brandPrimary` with `selectedColor` → `textPrimary`. `textPrimary` is **white in dark mode**, and white on `brandPrimary` (`#14C8FF`) measures **1.96:1** — far below AA's 4.5:1 for 13px text. The selected toggle segment would have been close to illegible in dark mode.

Measured, not guessed:

| Foreground on `#14C8FF` | Ratio | AA (4.5:1) |
|---|---|---|
| `textPrimary` dark-mode = white | **1.96:1** | FAIL |
| `textPrimary` light-mode = `#10131A` ink | 9.50:1 | pass |
| `GeniusWalletColors.textOnBrand` = `#000B18` | **10.12:1** | pass |

`textOnBrand` is not an invention for this plan — it is the token this project already pairs with brand fills: `theme.dart` uses it for both `onPrimary` and `onSecondary`, and UI-SPEC §3.3 itself swaps a badge icon to it citing "the same WCAG rationale as Phase 4 §1.3". The substitution is recorded in a code comment at the call site. **UI-SPEC §3.1's table should be corrected** so 05-03..05-06 do not repeat the pairing.

### The currency symbol is sourced, not hardcoded

develop rendered the balance with `NumberFormat.simpleCurrency().format(balance)`. `GWAnimatedNumber` formats internally with `decimalPatternDigits` (grouped, 2 decimals) and exposes a `prefix`. Hardcoding `prefix: '\$'` would have pinned the app to a dollar sign for every locale — a silent behavioural regression hidden inside a visual change. The prefix is instead read off `NumberFormat.simpleCurrency().currencySymbol`, the same formatter develop used, so locale behaviour is carried through.

### develop's dead `$0.00` ternary was removed

`final displayBalance = balance == 0 ? "\$0.00" : ...` sat *after* `if (balance == 0) return Text('No funds available')`, so its zero arm was unreachable. Replacing the static `Text` with `GWAnimatedNumber` left the local with no consumer, which `flutter analyze` would flag as `unused_local_variable`. Removed. The `$0.00` string was already never rendered, so nothing observable was lost.

### "No funds available" lost its bold

The spec maps it to `bodyMd` (16px, w400) + `statusError`; develop had 16px **bold** red. Following the spec literally drops `FontWeight.bold`. Called out here rather than silently reconciled — **if the walk finds the zero-funds message now reads as under-emphasised, restoring `fontWeight: FontWeight.bold` via `copyWith` is a one-line follow-up.**

## Deviations from Plan

**1. [Rule 2 — Missing critical functionality: accessibility] Toggle `selectedColor` changed from the spec's `textPrimary` to `textOnBrand`**
- **Found during:** Task 1, pre-write contrast check of the §3.1 substitution table
- **Issue:** `selectedColor: textPrimary` over `fillColor: brandPrimary` measures 1.96:1 in dark mode — a hard WCAG AA failure that would ship an illegible selected toggle segment.
- **Fix:** `selectedColor: GeniusWalletColors.textOnBrand` (10.12:1), the project's established brand-fill text token. Rationale recorded in a comment at the call site.
- **Files modified:** `lib/components/wallet_overview.dart`
- **Verification:** computed WCAG 2.x relative-luminance ratios (table above); visual confirmation deferred to Task 2 step 2.
- **Commit:** `8a5e5a9`
- **Note:** the plan's action text did leave room for this — "`selectedColor` -> `GeniusWalletColors.textPrimary` (or the shadow's choice)" — but the shadow's choice is also `textPrimary`, over a `textPrimary10` fill rather than a brand fill. Neither sanctioned option is AA-safe against `brandPrimary`, so this is recorded as a genuine deviation rather than an allowed alternative.

**2. [Rule 3 — Blocking] Removed develop's unreachable `displayBalance` ternary**
- **Found during:** Task 1
- **Issue:** Once the static `Text` became `GWAnimatedNumber` (which takes a `num`, not a formatted string), the local had no consumer — `unused_local_variable`, which would have failed the task's own `flutter analyze` gate.
- **Fix:** Removed the local; the currency symbol it used to carry is now sourced via `prefix:`. Its `balance == 0` arm was already unreachable.
- **Files modified:** `lib/components/wallet_overview.dart`
- **Verification:** `flutter analyze` — No issues found.
- **Commit:** `8a5e5a9`

**Total deviations:** 2 auto-fixed (1 × Rule 2, 1 × Rule 3). **Impact:** the plan's visual intent lands as specified; one token in the UI-SPEC's table is corrected for accessibility and should be fixed upstream in §3.1.

## Issues Encountered

No Rule 1 bugs and no Rule 4 escalation. The one judgement call worth a second pair of eyes is the `textOnBrand` substitution, documented above.

## Verification Results (Task 1, automated only)

- `flutter analyze lib/components/wallet_overview.dart` — **No issues found**.
- `flutter analyze lib` — **0 errors, 61 issues**, identical to 05-01's recorded 61-issue baseline. **Delta: 0.** All remaining issues are pre-existing `info`/`warning` lints in untouched files (`web_view_mobile.dart` etc.).
- `bash tool/verify_additive_boundary.sh` — **PASSED**. Check 1: `WalletsOverview` canonical importer set matches baseline (1 file), shadow has no un-allowlisted importers. Check 2: duplicate-class census within baseline. Check 3: no `WIRE-` markers in `lib/`.
- Grep gate: `extension<GWColors>()` **present** in `wallet_overview.dart`.
- Token discipline: no `Colors.red` / `Colors.white` / `Colors.blue`, no raw hex survives. The two surviving `fontSize: 13` values are develop's own toggle-child label styles, inside the `ToggleButtons` children this plan was scoped to keep structurally unchanged (the shadow keeps them identically) — noted, not changed.
- `git status` confirms `lib/components/wallets_overview.g.dart` is unmodified; `git show --stat` confirms the commit touched exactly one file with zero tracked-file deletions.

**None of this is visual or behavioural verification. `flutter analyze` is a gate, never proof. `flutter test` does not compile in this project and was not used.**

## Outstanding: the in-place LIVE-FLIP clause is UNVERIFIABLE (not a pass)

This plan's must_have states the hero "re-skins LIVE on an in-place appearance toggle". **This cannot be verified in the app's current state**, exactly as 05-01 recorded for the container.

`setMode()` is called from only two places — `lib/dev/token_probe_screen.dart` and `lib/dev/design_gallery_screen.dart`. There is no toggle reachable from the dashboard, so flipping appearance requires navigating away and back, and **that navigation forces a rebuild which masks the very staleness the clause guards against**. The walk can establish "correct in both modes" and "correct after an appearance change"; it cannot establish "flips live in place".

Tracked against `.planning/todos/pending/2026-07-18-no-user-facing-appearance-toggle.md` (`severity: verification-blocker`), which already blocks the same clause in 04-02, 04-04, and 05-01.

**What de-risks it meanwhile:** the `Theme.of(context).extension<GWColors>()` read is present and, unlike 05-01's const-constructed container, `WalletsOverview` is a `StatefulWidget` constructed with runtime arguments at its call site, so it is not subject to the const-identity short-circuit that made the mechanism load-bearing there. The mechanism is wired; only its live effect is unproven.

## Task 2 — walk recipe (macOS, translated from the plan's stale Windows text)

The plan's `<how-to-verify>` specifies `flutter run -d windows` with a `CMAKE_ARGUMENTS` env and a `/c/Users/...` SDK path. **That recipe is stale** — this project is developed on macOS (Apple Silicon). Use instead:

```
gcd && flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

(`gmac` for a plain macOS run; `gios` for the physical iPhone. `GW_DEV_TOOLS=true` is what exposes the Dev header appearance controls.)

**Before starting: quit every running instance of Genius Wallet.** A black window at launch is almost always a stale second instance holding the Hive container lock, not a rendering bug (05-01's environment finding).

1. **Criterion 1 — hero skin.** Land on `/dashboard`. The "Current Balance" label should sit above a large balance figure that **counts up** on first paint.
2. **Criterion 1 — behaviour intact.** On a non-SGNUS wallet with no funds, "No funds available" should read in red (`statusError`). On the SGNUS wallet, the GNUS/Minions toggle should switch units, and `GeniusBalanceDisplay`, the SGNUS connection widgets, and the Submit Job button should all be present and working. **Confirm absent:** any 24h delta/percentage, any action-pill row, any Assets/NFTs tab.
3. **Criterion 3 — no pre-load flash.** The hero must not appear before the account has loaded.
4. **Toggle legibility (the deviation's real check).** With the GNUS/Minions toggle visible, confirm the **selected** segment's label and icon are clearly readable on the cyan fill — **in dark mode especially**, since that is the pairing that measured 1.96:1 before the correction.
5. **Both modes + WCAG AA.** Repeat in light and dark. Check the label, the balance figure, and "No funds available" in each.
6. **Live flip (step 4 of the plan):** **skip and record as blocked** — see "Outstanding" above. Do not record a pass.

Notes: a CoinGecko HTTP 429 is a free-tier rate limit and the app correctly falls back to cached data — not a defect. Mouse click-drag does not scroll on desktop; use a two-finger trackpad gesture if you need to scroll.

## User Setup Required

None.

## Next Phase Readiness

Task 1's code work is complete and committed. **The plan is not closeable until Task 2's blocking walk runs.** `SCR-01`/`GAP-06` remain unclaimed. 05-03 onward can proceed in parallel on other dashboard areas — this plan touched only `wallet_overview.dart` — but should adopt the `textOnBrand`-over-brand-fill pairing rather than UI-SPEC §3.1's `textPrimary`, and §3.1's table is worth correcting at source.

---
*Phase: 05-dashboard*
*Task 1 completed: 2026-07-20. Task 2 (blocking human-verify): PENDING.*

## Self-Check: PASSED

`lib/components/wallet_overview.dart` and `05-02-SUMMARY.md` confirmed present on disk; task commit `8a5e5a9` confirmed present in `git log`.
