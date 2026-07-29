---
sketch: 077
name: compute-interactive
question: "Three panel shapes and three flow shapes for compute — which one, and what would each cost to build?"
winner: "P1 · Twin tiles + F1 · Drawer, vertical steps (chosen 2026-07-29 by Jakub, on the recommendation below)"
depends_on: 076
tags: [compute, sgnus, submit-job, interactive, variants, inventory, phase-14]
---

# Sketch 077: Compute, interactive

Clickable companion to **076**, which holds the code analysis and the citations. This one is for
deciding. Nothing here reopens 076's findings; it offers shapes to choose between.

```
open .planning/sketches/077-compute-interactive/index.html
```

## What is clickable

- **Panel tab** — 3 variants x 9 states. Toggle the `≈ $` subline and the section label.
  The card's height is **measured in the browser on every render** and compared to the real 276px
  budget, so the OVER/fits badge is a measurement, not a claim. The red dashed line is the floor.
- **Status tab** — the 9 states. Click one and it drives the Panel tab.
- **Job flow tab** — 3 variants, step 1→5, plus two fault injectors: *Not enough GNUS* and
  *Job fails after bridge*. The second is the one worth stepping through.
- **Inventory tab** — every component and work item per variant, with counts.

## The variants

**Panel** — all three are the same information; they differ on what the card's subject is.

- **P1 · Twin tiles** — 016-B2 rebuilt. Balance and compute as siblings of equal rank. Costs 40px of
  chrome across two borders, which is the price of the equality.
- **P2 · Compute-led** — balance collapses to a flush line, compute keeps the only tile. Buys back a
  border. The balance stops looking like the subject.
- **P3 · Status strip** — balance stays the hero, compute is one strip with no tile, CTA outline on
  the same line. Tightest, and the only one with room left for `+earned` if an API ever exposes it.

**Flow** — all three render the same five steps.

- **F1 · Vertical steps** (018-A) — completed steps collapse and stay on screen.
- **F2 · Horizontal stepper** — shorter body, fits a small phone. At confirm time the cost table is
  gone unless repeated.
- **F3 · Full screen** — rebuilds the existing `/submit_job` route, no drawer. One surface, deep
  links native, but the dashboard panel is not visible behind it.

## Inventory across all six

| | |
|---|---|
| **10** | components already exist |
| **5** | would need building |
| **6** | need non-UI code before any design can show them |

**Exists:** `GWCard` `GWKicker` `GWAnimatedNumber` `GWButton` `ResponsiveDrawer` `GWDetailGrid`
`GWWarningNote` `GWSpinner` `GWScreen` `GWPageHeader`

**Must build:** `GWStatusDot` `GWProgressBar` `GWCopyRow` `GWStepList` `GWStepBar`

**Needs code first:** `AccountDrawer.show()` (exists but private) · `RetryProcessingStatus` ·
stall detector · txHash preserved on partial failure · split error channels · `jobCost <= balance`

### Two things the inventory turned up

**1 · `GWCopyRow` gets its third consumer here.** Phase 23 **refused** that extraction after
re-measuring: the audit claimed 3 forks, there were 2, below the Rule of Three floor. The bridge-hash
row in step 5 is a third. If compute ships, the refusal is worth revisiting - and that is a Phase 23
decision this sketch reaches into, so it should be said out loud rather than discovered later.

**2 · F3 is not the cheap option it looks like.** It reuses `GWScreen`, which exists - but Phase 23
**deferred the `GWScreen` sweep whole**, on the grounds that it imposes scroll, a 1200px cap,
centring, padding and a background, so adopting it *is* a layout change. Picking F3 means taking that
on for this screen.

## Recommendation

★ **P1 + F1** - 016-B2 and 018-A were chosen on their merits and the rebuild did not weaken either.

Runner-up: **P3 + F1.** P3 is genuinely tighter and the compute strip survives the height budget with
room to spare; it is the right pick if the `+earned` readout ever becomes real, because P1 has 3px
and P3 has about 30. It loses on the thing 016 round 1 already settled - the split direction, where
compute is a peer of the balance rather than a footnote under it.

Rejected: **F2.** It is the only variant that puts the cost table off-screen at the moment the user
commits money, which is precisely the failure 018-A was chosen to avoid, and this flow spends real
GNUS irreversibly.

## Open

Same three as 076, unchanged: the section label (3px), the GNUS/USD unit clash, and whether
`View transaction ›` survives without a job→tx correlation. Q1 and Q2 are coupled - the `≈ $` subline
is both the mitigation and the release valve. Toggle both in the Panel tab and watch the meter.
