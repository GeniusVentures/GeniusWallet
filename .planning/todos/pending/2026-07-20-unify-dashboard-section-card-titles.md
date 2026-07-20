---
created: 2026-07-20T13:40:00.000Z
title: Unify dashboard section/card titles (GWSectionHeader)
area: ui
files:
  - lib/dashboard/home/view/dashboard_screen.dart
  - lib/dashboard/chart/dashboard_markets.dart
---

## Problem

Found during the 05-06 transactions walk (2026-07-20). The dashboard's per-section CARD
titles are inconsistent — "different per card." From the page-title audit (quick 260720-ipg):
- DashboardMarkets embedded title → `GeniusWalletTypography.titleLg` (dashboard_markets.dart:87)
- "Bitcoin Chart" section → `Theme.of(context).textTheme.titleLarge` (dashboard_screen.dart:376,
  via AutoSizeText)
- Other dashboard sections (Overview, Contributions, Transactions) render their titles
  differently again / or not via a shared widget.

This is the SECTION-title tier (titles inside dashboard cards), distinct from the PAGE-title
tier already unified onto `GWPageHeader` (quick 260720-ipg, headlineLg). Section titles want
their own consistent structure/token (spacing, weight, size) so every dashboard card header
looks the same.

## Solution

TBD — mirror the GWPageHeader approach at the section tier: a small shared `GWSectionHeader`
(or a single agreed token, e.g. `titleLg`/sectionHeader + consistent spacing) applied to every
dashboard section card title. Decide the canonical section-title token, then migrate the
dashboard section views (Overview/Contributions/Chart/Markets/Transactions) + dashboard_markets
onto it. Do NOT touch the page-title tier (GWPageHeader). Re-skin only; keep behavior. Walk the
dashboard (desktop 2/3-col + mobile one-column) in both modes. Route via GSD. Pairs with
[[2026-07-20-surface-card-shadows-clipped]] (already fixed) and the GWPageHeader work.
