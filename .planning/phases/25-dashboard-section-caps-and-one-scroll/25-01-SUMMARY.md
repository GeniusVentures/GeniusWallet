---
phase: 25-dashboard-section-caps-and-one-scroll
plan: 01
subsystem: dashboard
tags: [scroll, caps, view-all, ordering, rhythm, mobile]
status: complete
provides:
  - "kDashboardAssetsCap = 5, kDashboardTransactionsCap = 5, kDashboardMarketsCap = 6"
  - "GWViewAllLink in every capped section's GWSectionTitle trailing slot"
  - "Assets panel and /assets page share one comparator (GNUS pinned first)"
key-files:
  created: [lib/components/coins/assets_totals.dart, lib/dashboard/chart/dashboard_markets_util.dart, test/dashboard/dashboard_section_caps_test.dart, test/components/gw_section_title_rhythm_test.dart, test/components/assets_header_scheme_a_test.dart, test/components/gw_view_all_link_paint_test.dart]
  modified: [lib/components/coins/view/coins_screen.dart, lib/dashboard/chart/dashboard_markets.dart, lib/dashboard/home/view/dashboard_screen.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/compute/compute_panel.dart, lib/components/wallet_overview.dart, lib/components/cards/gw_section_title.dart]
metrics:
  tests_added: 33 (caps 17, title rhythm 6, assets header 5, view-all paint 5)
  completed: 2026-08-08
---

# Phase 25 Plan 01: Dashboard caps and one scroll Summary (backfilled from git)

Executed outside GSD together with plan 02; measured from merged code, not the plan.
Shipped in `7f3ee227` (one page scroll, capped sections, real Assets page), merged via PR #225
(`241ad41a`), with follow-up `0086c1f2`.

## What shipped
- Every dashboard section is capped and the PAGE is the only scroll on a phone.
- Caps: Assets 5, Transactions 5, Markets 6; each has View all in the title's trailing slot.
- GNUS is pinned first by the single comparator in `assets_sort.dart`, called by panel and page.
- Assets panel header returned to the shared `GWSectionTitle`; title gap above now equals below.

## Follow-ups after the merge
- `0086c1f2`: the "end of transactions" label only renders on the full page (`limit == null`);
  the capped panel no longer claims a 5-row list is everything.
- `eeefc6c0`, `110f4f90`: one row rhythm for Transactions/Assets/Markets, type scale restored.
- `7b2fd474`, `af287d63`: one total band shared by panel and page; holdings page reads as panels.

## Deviations from the plan
- Planned `test/components/coins/assets_ordering_test.dart` was not created; ordering is covered
  by `test/dashboard/assets_sort_test.dart` from plan 02.
- The census updates plan 02 left failing were made in `7f3ee227`.
