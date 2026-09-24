---
created: 2026-07-18T14:27:29.466Z
title: Account/wallet row UX polish — full-row tap, truncated address, balance formatting
area: ui
files:
  - lib/account/account_dropdown_selector.dart
---

## Problem

User feedback during the 04-04 drawer walk (2026-07-18) — three UX refinements on
the wallet/account list rows. These are user-directed display/behavior changes
(not re-skin regressions), captured here rather than folded into 04-02's
value-preserving re-skin:

1. **Whole row selectable.** Right now only the row **title** is tappable to select
   the account; the **entire row** should be the tap target for selection. BUT the
   three-dots (⋮) context menu must still work independently — don't let the
   row-tap swallow or block the ⋮ button.
2. **Truncate the address.** The cards show the full wallet address; show it
   **truncated** (e.g. 0x1234…abcd) instead.
3. **Balance/amount formatting** (the "minions" / GNUS amount). Currently
   inconsistent — sometimes "0 min", sometimes "0.0 minions". Standardize:
   - **Zero → "0 minions"** (no decimals at all).
   - **Non-zero → up to 3 decimals max** (trim trailing zeros), consistent unit
     label ("minions").

## Solution

TBD — a small UX pass on `account_dropdown_selector.dart`'s row builder
(`_buildDrawerRow`): wrap the whole row in the selection tap target while keeping
the trailing ⋮ MenuAnchor hit-testable above it; truncate the address string; and
add a shared amount-formatter (0 → "0 minions", else ≤3 decimals). Confirm the ⋮
still opens rename/delete after the row-tap change. Keep tokens/WCAG intact
([[wcag-contrast-rule]]). Relates to the padding/spacing polish todo
([[drawer-dialog-padding-spacing-polish]]).
