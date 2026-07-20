---
created: 2026-07-20T11:11:57.134Z
title: Move dev tooling out of top bar into overflow bubble
area: ui
files:
  - lib/components/overlay/responsive_overlay.dart:95-111
  - lib/components/overlay/responsive_overlay.dart:179-296
  - lib/test/dev_tools_widget.dart
  - lib/dev/dev_flags.dart
---

## Problem

Discovered during the 05-02 hero-balance walk (GW_DEV_TOOLS=true debug run). The dev
affordances live INSIDE the desktop top-bar action row: `_buildActionRowWidgets()`
(responsive_overlay.dart:95-111) prepends `DevToolsWidget` (lib/test/dev_tools_widget.dart
— "Dev" label + Test transaction / Test swap / Test buy buttons + Tokens + Gallery links)
to the real action row (Network selector, SDK account manager, Account/wallet selector,
Reown connect, Buy GNUS). That extra width overflows the `_DesktopTopBar` `Row`
(mainAxisAlignment.spaceBetween) at ~1240px — confirmed RenderFlex OVERFLOWING on
`Row ← Padding ← SizedBox ← ColoredBox ← _DesktopTopBar` — pushing the real action
widgets off the right edge of the screen and corrupting every phase-05 dashboard walk.

Because the dev items steal layout space in the chrome that is itself under test, we
cannot cleanly evaluate the real top-bar widgets (wallet/network selectors, GNUS/SGNUS
connection, submit-job) while the dev tools are mounted.

## Solution

Move the dev affordances OUT of the top-bar action row into a floating, draggable
overflow **bubble** (FAB-style) overlaid on the app, so they occupy ZERO layout space in
the chrome under test:
- Collapsed state: a small draggable bubble in a corner (dev-only).
- Expanded on tap: a panel/menu exposing the current dev actions — Test transaction,
  Test swap, Test buy, Tokens (`/dev/token-probe`), Gallery (`/design_gallery`) — plus
  the appearance (light/dark) toggle, so mode-flipping during walks no longer depends on
  a top-bar row that overflows.
- Keep the existing gate: `kDebugMode && kShowDevTools` (GW_DEV_TOOLS) — never ships in
  release; remove `DevToolsWidget` from `_buildActionRowWidgets()` so the top bar holds
  only real product widgets.

Design/route via GSD before implementing (small dev-tooling change that unblocks
phase-05 walks). TBD: exact bubble placement, drag persistence, and whether the panel is
a popover vs. a bottom sheet.
