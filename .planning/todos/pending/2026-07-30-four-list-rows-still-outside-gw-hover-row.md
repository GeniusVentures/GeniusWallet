---
created: 2026-07-30T00:00:00.000Z
title: Four tappable list rows are still outside GWHoverRow
area: ui
files:
  - lib/submit_job/view/widgets/job_step_list.dart:161
  - lib/account/sdk_account_manager.dart:710
  - lib/logs/submit_logs_screen.dart:661
  - lib/dashboard/bridge/bridge_screen.dart:824
---

## Problem

`GWHoverRow` (2026-07-30) unified the row hover across the five lists Jakub named: Transactions,
the Markets page table, the dashboard Markets panel, Assets, and `GWTokenRow`. A sweep of every
`ListTile` with an `onTap` and every bare `InkWell` in `lib/` turned up **four more tappable rows**
that were deliberately left alone as outside that scope.

They carry the same two defects the sweep was created to fix:

| File | Defect |
|---|---|
| `job_step_list.dart:161` | bare `InkWell(onTap:, child:)`, **no `borderRadius`** - square highlight |
| `sdk_account_manager.dart:710` | bare `InkWell`, same |
| `submit_logs_screen.dart:661` | bare `InkWell`, same |
| `bridge_screen.dart:824` | `ListTile` with `onTap` - the **buried-ink** trap: a `ListTile` paints its highlight on the nearest ANCESTOR `Material`, so if that ancestor sits under a painted panel background the hover is invisible, which is exactly why Assets and the dashboard Markets panel appeared to have no hover at all |

Everything else the sweep matched is a button, card, checkbox or switch - those have their own
affordances and `GWHoverRow` would be wrong there.

## Solution

Wrap each in `GWHoverRow` and drop the local `InkWell`/`ListTile.onTap`. The component brings its
own transparent `Material`, `radiusMd`, click cursor and the 6% `kGWRowHoverAlpha` highlight.

**Check the `ListTile` case by eye, not by test**: whether its ink was buried depends on what the
caller paints, and only `bridge_screen.dart:824` is a `ListTile` here.

## Not in scope of this todo

`GWHoverable` (Phase 23-05) is builder-style state plumbing that hands the caller a `bool` - it
composes with `GWHoverRow` rather than replacing it.
