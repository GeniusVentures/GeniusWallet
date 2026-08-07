---
phase: 25
title: One scroll on the dashboard - capped sections with View all
status: ready-to-plan
raised_by: Jakub, 2026-08-06 live iPhone walk
blocked_by: none - quick task 260806-wys (dashboard section rhythm) LANDED 2026-08-07
scope: TWO deliverables, to be planned as two plans and executed in parallel
---

# Phase 25: one scroll on the dashboard

## The request

Jakub, 2026-08-06 live iPhone walk, reported in English:

> He dislikes that sometimes, instead of the page moving down, some section scrolls instead. For
> example in assets - show the top 5 assets by holding value in $$, and in transactions the last 5
> transactions, markets - Gnus + 4 other coins (BTC / ETH / XRP / BNB / Solana), with view all
> opening the full list, and the same in the corresponding sections. He wants a better scrolling
> feel rather than sections scrolling under him.

## Diagnosis - confirmed in code, not inferred

Every dashboard panel is a **fixed-height box containing its own scrollable**. `OneColumnDashBoardView`
(`dashboard_screen.dart`) wraps each panel in a `ConstrainedBox`, and each panel then scrolls
internally:

| Panel | Outer cap | Inner scrollable |
| --- | --- | --- |
| Compute | `kDashboardPanelSlotHeight` = 340 | `SingleChildScrollView` |
| Assets | `kDashboardPanelSlotHeight` = 340 | `SingleChildScrollView` (`coins_screen.dart:255`) |
| Chart | 350 | - |
| Markets | 350 | `ListView.separated` (`dashboard_markets.dart:71`) |
| Transactions | 400 | `ListView.builder` (`transactions_slim_view.dart:528`) |

So the page has **four independent scroll areas**. A drag that starts inside any panel is consumed by
that panel's scrollable and never reaches the page. That is exactly the reported feeling.

This also silently hides content: the Compute panel's own doc comment records that because it sits in
a `SingleChildScrollView`, exceeding its budget makes it "quietly scrollable inside its own box"
rather than throwing an overflow - which is how the CTA once dropped below the fold with no error.
Capping content and removing the inner scroll removes that whole failure mode, not just the gesture
problem.

## Target

**One scroll on the page.** Each section shows a fixed, small number of rows and hands the rest to a
full screen behind `View all`.

| Section | Show | Ordering rule |
| --- | --- | --- |
| Assets | top 5 | by holding value in USD, descending |
| Transactions | last 5 | most recent first |
| Markets | 6 | GNUS pinned first, then BTC, ETH, XRP, BNB, SOL |

`GWViewAllLink` **already exists** (`lib/components/cards/gw_view_all_link.dart`) and Markets
**already uses it** (`dashboard_markets.dart:68` -> `/markets`). Assets and Transactions need the
same affordance, so this is spreading an existing pattern rather than inventing one.

## ANSWERED 2026-08-07 - Assets `View all` goes to a new `/assets` page

The open question below was "does Assets get a full screen, and if so which one". Jakub answered
both halves: **yes**, and it is **NOT** `CoinsScreen(isDashboard: false)`.

He was shown five variants in sketch `177-assets-full-page` and picked **D, then simplified it
himself**: a search field plus **one** sort control keyed on value, tapping it toggles ascending /
descending. No name sort, no 24h sort. The full audit, both accepted costs and the one remaining
open detail live in `.planning/sketches/177-assets-full-page/README.md` and that file is required
reading for whoever plans the `/assets` half of this phase.

The two costs, repeated here because they change the shape of the work:

1. **`CoinsScreen(isDashboard: false)` is NOT reused.** That was the cheap option-1 route below and
   it is off the table - `CoinsScreen` exposes no hook for filtering or ordering and owns a 1-minute
   market-data refresh timer that must not be duplicated. The page assembles its own list from
   `CoinCardRow` plus `WalletDetailsCubit`.
2. **`GWPageHeader` ONLY on the page, with no `GWSectionTitle` under it**, or it prints "Assets"
   twice - the duplicate-title defect Jakub flagged on Transactions and parked for its own sweep.

Component audit for the simplified D: **7 reused as-is, 0 adapted, 2 new** (the route itself and the
tappable `Value ⇅` affordance).

Still open, and small enough to decide in the plan: how to order a holding that has a balance but no
market data. Proposal on file - keep it above priced rows when sorting descending, because "you own
this and we cannot price it" outranks any priced row.

<details>
<summary>Original open question, kept for the record - CONTAINS ONE FALSE CLAIM, see note</summary>

> **The option 1 below does not compile and never did.** There is no `isDashboard` parameter on
> `CoinsScreen`. Its constructor takes `onCoinSelected`, `filterCoins` and `isUseDivider`, and
> `isDashboard` is a local bool derived at `coins_screen.dart:247` as
> `widget.onCoinSelected == null`. Verified in source 2026-08-07 while planning 25-02. The
> recommendation below was therefore recommending an API that does not exist. Jakub's answer above
> supersedes it regardless, but the claim is corrected rather than left to mislead the next reader.


**Assets `View all` has no destination.** `/markets` and `/transactions` both exist as routes;
there is no `/assets`. `CoinsScreen` already takes an `isDashboard` flag and renders a full list when
false, so the screen exists in all but routing. Options:

1. Add an `/assets` route rendering `CoinsScreen(isDashboard: false)` - cheap, consistent with the
   other two sections, and the flag is already there.
2. Point it at the existing token list surface if one is a better fit.
3. No `View all` on Assets, on the grounds that a wallet with more than five funded assets is rare.

Recommendation: **option 1** - the other two sections both go to a full screen, and a rule that holds
for two of three sections but not the third is the kind of inconsistency this phase exists to remove.

</details>

## Constraints carried in

- Removing the `ConstrainedBox` caps changes what `kDashboardPanelSlotHeight` = 340 means.
  `test/dashboard/compute_panel_height_test.dart` asserts a content budget derived from it. Both must
  be updated honestly, not left stale.
- Desktop (`ResponsiveDashboardView`, `_OverviewContributionsRow`) constrains Overview and
  Contributions as one row and genuinely needs fixed heights there. **This phase is mobile-only** -
  do not flatten the desktop two-column layout.
- 4-pt spacing grid; existing tokens only.
- Dark mode first.

## Sequencing

Quick task **260806-wys** (dashboard section rhythm) **landed 2026-08-07** - `GWSectionTitle` now
takes a `contentTopInset` and every panel renders a 26pt title-to-first-ink gap. This phase is
planned against that settled geometry, so any plan that re-touches the panel files must preserve the
`contentTopInset` values already passed at each call site rather than reverting them.

**The two halves run in parallel, at Jakub's explicit instruction.** They share exactly one symbol:
the `/assets` path string. The dashboard half writes a `GWViewAllLink` pointing at it; the page half
registers it. Neither reads the other's code.

| Plan | Owns | Touches |
| --- | --- | --- |
| 25-01 dashboard caps | one page scroll, top-5 / last-5 / 6-market caps | `dashboard_screen.dart`, `coins_screen.dart`, `transactions_slim_view.dart`, `dashboard_markets.dart`, `compute_panel.dart`, `compute_panel_height_test.dart` |
| 25-02 `/assets` page | the new page and its route | new page file, the router, new test |

The router is the one file that could collide if 25-01 also tried to register the route. **It must
not** - 25-01 only emits the path string, 25-02 owns every router edit.
