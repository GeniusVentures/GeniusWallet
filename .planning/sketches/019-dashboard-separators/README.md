---
sketch: 019
name: dashboard-separators
question: "Should the header rule Phase 12 gave Transactions exist, and if so on which panels?"
winner: "B"
tags: [dashboard, separators, consistency, chrome]
---

# Sketch 019: Dashboard Separators

## The audit reframes the question
Row separators are **not** missing anywhere. Assets, Markets and Transactions all already draw a 1px
`borderSubtle` hairline between rows. The only dashboard-wide difference is the **rule under the
panel header**, which Transactions gained in Phase 12 and no other panel has.

| Panel | Row separator | Header rule | Source |
|---|---|---|---|
| Assets | yes — `Divider(1, borderSubtle)` | no | `coins_screen.dart:313` |
| Markets | yes — `Container(height: 1)` | no | `dashboard_markets.dart:73` |
| Transactions | yes — `Divider(1, borderSubtle)` | **yes** (Phase 12) | `transactions_slim_view.dart:210` |
| Current Balance | n/a — no list | no | `wallet_overview.dart` |
| Bitcoin chart | n/a — no list | no | `dashboard_screen.dart` |

**Second finding:** Markets draws its row line with `Container(height: 1)` while Assets and
Transactions use `Divider`. Same pixel, two widgets — worth unifying whichever version wins.

## Variants
- **A · Rule on every panel** — total uniformity. Costs: the rule appears under headers with nothing
  to separate (Current Balance has no list; the chart is one continuous graphic), and spends ~9px of
  height on five panels where panel height is the scarce resource.
- **B · No rule anywhere ★ CHOSEN 2026-07-22** — reverts Transactions; zero net change from what shipped. Cheapest.
  Costs: the Transactions header carries a filter bar and a live count, and they would float above
  the rows they govern with nothing marking where the header ends.
- **C · Rule only where content scrolls beneath a fixed header** (was my recommendation; not taken) — the rule becomes
  functional rather than decorative: it marks the boundary content passes under while scrolling.
  Assets, Markets, Transactions scroll → rule. Current Balance and the chart do not → no rule. The
  presence of the rule then *means* something. Costs: not uniform at a glance; the rule has to be
  understood rather than merely seen.

## What to Look For
- With **A**, look at Current Balance and the chart: does the rule under those headers read as
  deliberate, or as a line with nothing to do?
- With **B**, look at the Transactions header: do the filter chips and the list read as one
  undifferentiated block?
- With **C**, scan the three-column layout: does the mixed treatment read as considered, or as an
  oversight on the two panels that lack it?

## Outcome (2026-07-22)
**B chosen and implemented.** The header rule was removed from `transactions_slim_view.dart`; the
panel now goes straight from `GWSectionTitle` to its list like Assets and Markets. Rationale that
beat my own recommendation of C: C's rule only *means* something once a user learns it, whereas B is
a deletion — and `CLAUDE.md` says "deletion over addition, boring over clever".

Spacing was re-measured rather than eyeballed while implementing:
- title → first day label = **24px**, matching Assets/Markets (`GWSectionTitle`'s space8 + the
  space4 a `GWTokenRow` carries but a day label does not).
- above later day labels = **32px**, deliberately double the 16px between two rows inside one day.
  At the previous space8 a day boundary measured 24 — identical to the title→content gap — so day
  blocks did not read as separated.

**Still open from this audit:** Markets draws its row line with `Container(height: 1)`
(`dashboard_markets.dart:73`) while Assets and Transactions use `Divider`. Same pixel, two widgets.
One-line change, not yet made.
