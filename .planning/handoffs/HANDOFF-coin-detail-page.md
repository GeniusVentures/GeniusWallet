# HANDOFF — coin-detail-page sketch (design session)

**Date:** 2026-07-23
**Role:** DESIGN session (no git, no `lib/`, no `flutter run` touched)
**Topic:** redesign of the `/token-info` coin detail page

## What this session did

Sketched the **coin detail page** (`lib/tokens/token_info_screen.dart`) — the screen you reach by
tapping a card on Markets. Jakub gave a screenshot of the current page and free rein on layout, with
one constraint: **reuse today's data/widgets, no logic change.**

Produced **Sketch 104 · coin-detail-page** — one HTML file, four full-page structure variants, all
verified rendering + interactive in Chrome (chart hover/zoom/pan, live Convert calc, Dark/Light,
Phone/Tablet/Full).

## Deliverables (working tree only — NOT committed)

- `.planning/sketches/104-coin-detail-page/index.html` — 4 variants (A/B/C/D)
- `.planning/sketches/104-coin-detail-page/README.md` — question, grounding table, findings, open decisions
- `.planning/sketches/MANIFEST.md` — appended the row 104 (⚠️ see note below)

## The four variants

- **A · Faithful cleanup** — today's 2-panel split made coherent; identity beside the hero price;
  actions boxed; chart gets a header. Smallest port.
- **B · Exchange header** — full-width identity + price + inline key-stats strip; full-width chart; actions/Info/Convert below.
- **C · Identity rail** — fixed left rail (identity + price + vertical actions + Convert) + biggest chart; stats strip under it.
- **D · Unified stack** — one centered card column; = the mobile layout too. Kills the dead space.

**Pick is PENDING** — Jakub has not chosen. `winner: null` in the README.

## Real bug found (worth a fix regardless of which layout wins)

The current % pill can show a **positive number in a red pill** (visible in Jakub's screenshot:
`+0.21%` on red). Cause: pill **color** tracks `_latestPrice vs _oldestPrice`
(`crypto_live_chart.dart:234`) while the **number** tracks `_displayPrice` (hovered) vs open
(`:342`) — they disagree on hover. Every sketch variant ties color to the same value as the sign.

## Open decisions for the pick

1. **A / B / C / D** as the page structure (A cheapest; C/D best remove the wasted chart space).
2. **Timeframe tabs (1H/1D/1W/ALL)** are drawn but *visual-only* — real ones need range fetching
   (a data change), following the **sketch 006** direction. Keep zoom/pan only, or build timeframes?

## ⚠️ Concurrency note

While appending the 104 row, the harness reported `MANIFEST.md` **had changed on disk since I read
it** — another session was likely editing it in parallel. My edit anchored on the unique `103` row
and applied cleanly. No commit was made, so there is nothing to un-collide at git level, but whoever
commits MANIFEST next should eyeball the 104 row is intact.

## Suggested next step

`/gsd-sketch` idea-mode is done for this topic. Once Jakub picks A/B/C/D (± timeframe decision),
this is ready for `/gsd-plan-phase` as a coin-detail-page redesign phase. The %-pill fix can ride
along or ship as a standalone quick fix.
