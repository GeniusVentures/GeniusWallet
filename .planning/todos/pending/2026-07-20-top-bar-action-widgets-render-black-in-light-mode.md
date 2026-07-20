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

## Solution

TBD — audit each widget's surface/background color source and migrate the hardcoded dark
fill to the appearance-aware token path (`Theme.of(context).extension<GWColors>()` surface
fields, per the 04-02 / 04-04 discipline), so they flip live on an appearance toggle. Verify
in both modes on a live flip. Keep develop's behavior; re-skin only. Confirm WCAG AA in light
mode for each control after the fix. Route via GSD before implementing.
