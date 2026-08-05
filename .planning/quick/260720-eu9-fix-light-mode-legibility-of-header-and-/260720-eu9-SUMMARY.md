---
phase: quick-260720-eu9
plan: 01
subsystem: ui
tags: [flutter, theme, textbutton, wcag, header, reown, gwbutton]

requires:
  - phase: 02-design-tokens-verification-loop
    provides: GWColors ThemeExtension, GWAppearance singleton, appearance-aware GeniusWalletColors getter pattern
provides:
  - GeniusWalletColors.btnFilter converted from static const to appearance-aware static getter (root fix, flips every bare TextButton app-wide via theme.dart:258)
  - Four header controls (network selector, account delete menu, SGNUS status/spinner, Reown connect button + dialog) migrated off hardcoded Colors.*/greenAccent to GWColors/status tokens
  - SubmitJobDashboardButton and "Buy GNUS" converted to branded GWButtons (primary/secondary) with unchanged onPressed behavior
affects: [05-dashboard, any future phase touching header/top-bar controls or bare TextButton usage]

tech-stack:
  added: []
  patterns:
    - "const-context getter conversion: static const Color -> static Color get is safe when the sole consumer reads it inside a non-const closure (verified via grep before editing)"
    - "Status-tint alpha for light-surface legibility: statusError/statusWarning at withValues(alpha: 0.18), not the previous 0.1, so the tint reads on a light background"

key-files:
  created: []
  modified:
    - lib/theme/genius_wallet_colors.dart
    - lib/network/network_dropdown_selector.dart
    - lib/account/account_dropdown_selector.dart
    - lib/components/sgnus/sgnus_connection_widget.dart
    - lib/reown/reown_connect_button.dart
    - lib/components/job/submit_job_dashboard_button.dart
    - lib/components/overlay/responsive_overlay.dart

key-decisions:
  - "btnFilter's dark branch preserved byte-identical (Color.fromARGB(255, 19, 33, 53)); only the light branch is new (0xFFEFF2F6, matching surfaceMenu's light value) -- zero visual change in dark mode"
  - "reown_connect_button's AlertDialog backgroundColor reads GWColors from the dialog builder's own `ctx` (not build()'s `gw`), since the dialog is constructed inside _connect(), a different method scope than build()"
  - "Status backgroundColor tint alpha raised from 0.1 to 0.18 app-wide on the Reown button per plan instruction, so connecting/timedOut/error states stay visible on a light surface"

requirements-completed: [QUICK-260720-eu9]

coverage:
  - id: D1
    description: "btnFilter made appearance-aware: dark preserved (ARGB 255,19,33,53), light adds 0xFFEFF2F6 chip; single change flips every bare TextButton app-wide via theme.dart:258"
    requirement: "QUICK-260720-eu9"
    verification:
      - kind: other
        ref: "flutter analyze lib/theme/genius_wallet_colors.dart lib/theme/theme.dart"
        status: pass
    human_judgment: true
    rationale: "Legibility/contrast in both modes across every bare-TextButton site app-wide requires a visual human walk (Task 4, blocking checkpoint); flutter analyze only proves it compiles clean."
  - id: D2
    description: "Four header controls migrated off hardcoded Colors.*/greenAccent to GWColors/status tokens (network empty-state, account delete menu, SGNUS status text/spinner, Reown connect button + dialog + icons + snackbars)"
    requirement: "QUICK-260720-eu9"
    verification:
      - kind: other
        ref: "flutter analyze lib/network/network_dropdown_selector.dart lib/account/account_dropdown_selector.dart lib/components/sgnus/sgnus_connection_widget.dart lib/reown/reown_connect_button.dart"
        status: pass
    human_judgment: true
    rationale: "WCAG legibility of status tints and appearance-aware fills in both modes requires a human visual walk, not just a compile check."
  - id: D3
    description: "SubmitJobDashboardButton -> GWButton(primary, Icons.create leading); \"Buy GNUS\" -> GWButton(secondary); both preserve exact prior onPressed behavior"
    requirement: "QUICK-260720-eu9"
    verification:
      - kind: other
        ref: "flutter analyze lib/components/job/submit_job_dashboard_button.dart lib/components/overlay/responsive_overlay.dart"
        status: pass
    human_judgment: true
    rationale: "Visual/branding correctness (legible icon+label, correct variant styling) requires a human walk; behavior preservation was verified by reading the onPressed body unchanged, not by running the app (a debug build was already running and was not restarted)."

duration: ~20min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-eu9: Fix light-mode legibility of header and balance-area controls Summary

**Made `GeniusWalletColors.btnFilter` appearance-aware (root fix flipping every bare TextButton app-wide via theme.dart:258), migrated four header controls off hardcoded `Colors.*`/`greenAccent` to `GWColors`/status tokens, and converted SubmitJob/Buy GNUS to branded `GWButton`s.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 3 of 4 (all `type="auto"` tasks complete; Task 4 is a `checkpoint:human-verify` gate with `gate="blocking"`, intentionally NOT performed by this run)
- **Files modified:** 7

## Accomplishments
- `genius_wallet_colors.dart`: `btnFilter` converted from `static const Color` to `static Color get`, dark branch preserved exactly (`Color.fromARGB(255, 19, 33, 53)`), light branch added (`0xFFEFF2F6`). Since theme.dart:258 is the sole consumer inside a `resolveWith` closure, this single change flips every bare TextButton app-wide on appearance toggle.
- `network_dropdown_selector.dart`: empty-state "No networks available." text now reads `gw.textSecondary` instead of `Colors.white70`.
- `account_dropdown_selector.dart`: Delete menu item's icon + label color switched from `Colors.redAccent` to `GeniusWalletColors.statusError` (mode-invariant, WCAG-safe).
- `sgnus_connection_widget.dart`: `SGNUSConnectionStatusWidget`'s status text now reads `gw.textPrimary`/`gw.textSecondary` (was `Colors.white`/`Colors.white70`); the init-progress spinner now uses `GeniusWalletColors.brandPrimary` (was `Colors.greenAccent`).
- `reown_connect_button.dart` (biggest surface): idle state now uses `gw.surfaceElevated`/`gw.textPrimary`/`GeniusWalletColors.brandPrimary` (was `deepBlueCardColor`/white/greenAccent); connected+error states use `statusError`, connecting+timed-out use `statusWarning`, both at `withValues(alpha: 0.18)` tint (was 0.1, raw `Colors.redAccent`/`amber`/`orange`); the WalletConnect dialog's background now reads `GWColors.surfaceElevated` off its own builder context (was `deepBlueTertiary`); the paste/link dialog icons now use `brandPrimary` (was `lightGreenPrimary`); all three `showAppSnackBar(..., backgroundColor: Colors.red)` calls now use `GeniusWalletColors.statusError`.
- `submit_job_dashboard_button.dart`: `TextButton.icon` replaced with `GWButton(variant: primary, size: md, label: 'Create Processing Job', leading: Icon(Icons.create))`; the `greenAccent` icon color is gone (GWButton.primary supplies `textOnBrand` foreground to both label and leading icon via IconTheme). `isSelectedWalletLinkedToSGNUS` guard and exact `onPressed` body (calls `onPressed?.call()`, pushes `/submit_job`, refreshes coins) preserved verbatim.
- `responsive_overlay.dart`: "Buy GNUS" `ElevatedButton` replaced with `GWButton(variant: secondary, size: md, label: 'Buy GNUS')`, exact `context.push('/buy')` behavior preserved. No other button or the GNUS/Minions toggle touched.

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Root theme fix — make btnFilter appearance-aware** - `2f89f04` (fix)
2. **Task 2: Header controls — migrate hardcoded colors to appearance-aware / status tokens** - `fde131b` (fix)
3. **Task 3: Balance-area branded CTAs — GWButton conversions** - `6324d09` (feat)

Task 4 is a `checkpoint:human-verify` gate (`gate="blocking"`) — not a commit-producing task. Per this run's instructions, the walk was intentionally NOT performed by the executor.

## Files Created/Modified
- `lib/theme/genius_wallet_colors.dart` - `btnFilter` const→getter conversion (root fix)
- `lib/network/network_dropdown_selector.dart` - empty-state text color → `gw.textSecondary`
- `lib/account/account_dropdown_selector.dart` - Delete menu item → `statusError`
- `lib/components/sgnus/sgnus_connection_widget.dart` - status text → `gw.textPrimary`/`textSecondary`; spinner → `brandPrimary`
- `lib/reown/reown_connect_button.dart` - idle/status/dialog/icon/snackbar color migration (see Accomplishments)
- `lib/components/job/submit_job_dashboard_button.dart` - `TextButton.icon` → `GWButton(primary)`
- `lib/components/overlay/responsive_overlay.dart` - "Buy GNUS" `ElevatedButton` → `GWButton(secondary)`

## Decisions Made
- `btnFilter`'s dark branch preserved byte-identical; only the light branch is new — zero visual change in dark mode, matching the plan's explicit requirement.
- The Reown dialog's `GWColors` read uses the dialog builder's own `ctx` parameter (not `build()`'s `gw` local), because the dialog is constructed inside `_connect()`, a different method scope than `build()`.
- Status backgroundColor tint alpha raised from 0.1 to 0.18 across all four Reown status states (connected/connecting/timedOut/hasError), per plan instruction, so tints stay visible on a light surface.

## Deviations from Plan

None - plan executed exactly as written for all three auto tasks.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Outstanding

**Task 4 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been performed.** Per `260720-eu9-PLAN.md`, this is a wide blast-radius walk (the `btnFilter` change touches every bare TextButton app-wide, not just the header). Exact recipe from the plan:

1. Dashboard header/top bar (light AND dark): network selector, wallet/account trigger, GNUS/SGNUS connection widget, Submit-Job button all read clearly — no dark-navy chip with black ink in light, no illegible text. Confirm dark mode still shows the familiar ~#132135 chip (unchanged).
2. Current-balance area: "Create Processing Job" (visible only when the selected wallet is SGNUS-linked) is a branded primary GWButton with legible icon+label; "Buy GNUS" is an outlined secondary GWButton and still navigates to `/buy`.
3. Reown Connect button: idle state (Connect) reads on light; trigger Connecting/Timed-Out/Error and confirm amber/red status tints are visible on the light surface (not washed out); open the WalletConnect dialog — background flips (not dark-navy on light), paste/link icons legible.
4. SGNUS status text + spinner read in light mode (previously white-on-white).
5. Account drawer "..." menu → Delete item is legibly red in both modes.
6. App-wide TextButton regression spot-check (BOTH modes) — no regression on: onboarding (recovery_phrase / backup_phrase / verify_recovery_phrase / legal / import_security), pin_screen, disclaimer_dialogue, swap_screen + swap_settings_drawer, submit_job_screen, sdk_account_manager, bridge_screen, banxa buy/order screens, action_button, copy_button, sliding_drawer_button, desktop_container dialogs. Each bare TextButton should show the light chip in light mode and the ~#132135 chip in dark mode with legible ink.

A debug build was already running before this execution; use the dev-tools bubble's in-place light/dark toggle (`GW_DEV_TOOLS=true`) to flip appearance over any screen without navigating. Do NOT run `flutter build`/`flutter run` to re-verify — the running instance already reflects these hot-reloadable color changes once reloaded.

Resume signal: "approved" or a description of the illegible/regressed controls with mode + screen.

## Next Phase Readiness
- Code changes are analyze-clean (0 errors across all 7 files, pre-existing `use_build_context_synchronously` infos untouched) and committed (`2f89f04`, `fde131b`, `6324d09`); no blockers for continuing other work.
- The Task 4 walk should be run before considering the light-mode-legibility todo (`2026-07-20-top-bar-action-widgets-render-black-in-light-mode.md`) resolved.

---
*Quick task: 260720-eu9-fix-light-mode-legibility-of-header-and-*
*Completed: 2026-07-20*

## Self-Check: PASSED

- FOUND: lib/theme/genius_wallet_colors.dart
- FOUND: lib/network/network_dropdown_selector.dart
- FOUND: lib/account/account_dropdown_selector.dart
- FOUND: lib/components/sgnus/sgnus_connection_widget.dart
- FOUND: lib/reown/reown_connect_button.dart
- FOUND: lib/components/job/submit_job_dashboard_button.dart
- FOUND: lib/components/overlay/responsive_overlay.dart
- FOUND: .planning/quick/260720-eu9-fix-light-mode-legibility-of-header-and-/260720-eu9-SUMMARY.md
- FOUND: 2f89f04
- FOUND: fde131b
- FOUND: 6324d09
