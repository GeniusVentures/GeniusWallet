---
created: 2026-07-20T11:11:57.134Z
title: Top-bar action widgets render black in light mode
area: ui
files:
  - lib/network/network_dropdown_selector.dart
  - lib/account/account_dropdown_selector.dart
  - lib/reown/reown_connect_button.dart
  - lib/components/overlay/responsive_overlay.dart:95-111
---

## Problem

Discovered during the 05-02 hero-balance walk (GW_DEV_TOOLS=true debug run, light mode).
The desktop top-bar action widgets do NOT re-skin for light appearance — they keep a dark
(black) surface fill on a light background, and some run off the right edge of the screen:

- **Network selection** (`NetworkDropdownSelector`) — black background in light mode.
- **Wallet / account selection** (`AccountDropdownSelector`) — black background in light mode.
- **GNUS / SGNUS connection** (`ReownConnectButton` / connection control) — renders black.
- **Create / processing (Submit Job)** control — renders black.

These are the real product widgets in `_buildActionRowWidgets()`
(responsive_overlay.dart:95-111) / the `_DesktopTopBar` right-hand row. The off-screen part
is compounded by the dev-tooling overflow (see
[[2026-07-20-move-dev-tooling-out-of-top-bar-into-overflow-bubble]]), but the BLACK-in-light
part is an independent re-skin regression: these widgets appear to use hardcoded dark
surface colors / static-getter reads instead of appearance-aware `GWColors` tokens, so they
never flip on a light appearance.

Distinct from [[2026-07-17-design-system-has-no-light-mode-treatment]] (which is about the
mesh/canvas BACKGROUND effects being dark-only by design) — this is the foreground chrome
controls failing to adopt light-mode surface tokens.

## Root cause (found 2026-07-20 audit — broader than "top bar")

The primary defect is THEME-LEVEL, not per-widget: `lib/theme/theme.dart`'s global
`textButtonTheme` sets `backgroundColor: GeniusWalletColors.btnFilter` — a fixed dark-navy
`const` (`Color.fromARGB(255, 19, 33, 53)`) that is NOT appearance-aware. So EVERY bare
`TextButton` in the app renders dark-navy-fill + near-black `textPrimary` ink in light mode =
dark-on-dark, illegible, and never flips against the light chrome. This is the shared cause
behind the network / SDK / account selectors, the SGNUS connection button, and Submit-Job —
not just the top bar. On top of the theme bug, individual widgets add hardcoded colors:
- `reown_connect_button.dart` — hardcoded `deepBlueCardColor` fill + `Colors.white` text +
  `Colors.greenAccent` icon + faint `Colors.red/amber/orange` alpha state tints (none flip).
- `sgnus_connection_widget.dart` (status) — `Colors.white`/`Colors.white70` text on the light
  hero → invisible (HARD FAIL).
- `submit_job_dashboard_button.dart` — hardcoded `Colors.greenAccent` icon.
- `network_dropdown_selector.dart` — `Colors.white70` empty-state text.
- `account_dropdown_selector.dart` — `Colors.redAccent` delete menu item.
Already OK: "Buy GNUS" (transparent + brand border), GNUS/Minions toggle (uses `textOnBrand`,
§3.1-safe). No control ships the raw white-on-brand §3.1 defect.

## Solution — IN PROGRESS via quick task 260720-eu9 (2026-07-20)

Root theme fix (make textButton background appearance-aware in theme.dart, fixing all bare
TextButtons app-wide) + per-widget hardcoded-color migrations to GWColors/status tokens +
convert Submit Job and Buy GNUS to branded GWButton. Verify in BOTH modes app-wide (theme
change has app-wide blast radius). WCAG AA for each control. Re-skin only; keep behavior.
