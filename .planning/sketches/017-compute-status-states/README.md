---
sketch: 017
name: compute-status-states
question: "What single status component tells the truth across all nine states the compute node actually enters?"
winner: "A · Dot + label (chosen 2026-07-22; ring reserved for the 56px GWAiFab)"
tags: [compute, status, states, sgnus, processing, honesty, telemetry]
---

# Sketch 017: Compute Status — Nine Honest States

## Design Question

The shipped card carries **two** status widgets stacked on each other — `SGNUSConnectionWidget` and
`SGNUSConnectionStatusWidget` — and between them they cannot express three states the app demonstrably
enters. Two of the states they *do* render are rendered as something they are not.

**Which single status treatment can tell the truth in all nine?**

## How to View

```
open .planning/sketches/017-compute-status-states/index.html
```

Nine cells, one per state. Each shows the real trigger (from the code), the proposed rendering, and — under
the dashed line — **what the shipped app shows instead**. Switch treatment A/B/C in the toolbar.

## Variants

- **A · Dot + label** — coloured dot, one-word state, optional end value, optional bar.
- **B · Ring + %** — 54 px determinate ring with the percentage inside (the `GWAiFab` language from the design branch).
- **C · Stage bar** — four segments: Connect · Init · Ready · Job.

## What to Look For

Compare the three treatments on states **04 (stalled)** and **08 (telemetry dead)**. Those are the two
states that break B, and they are not hypothetical.

## Findings

**1 · The 52.5% lie — measured, not inferred.** `sgnus_connection_widget.dart:85` draws a determinate
`CircularProgressIndicator` from `getInitializationStatus()`. Over 161 polls across 40 s (spike 002 /
sketch 015) the value reaches `0.525` at t=10.6 s and **never changes again**. A determinate ring is a
promise the number will reach 100. This one does not.

**2 · The silent death.** `app_bloc.dart:193-196` — any exception from `getProcessingStatus()` cancels
`_processingTimer` **permanently** and emits `isProcessing:false`. Nothing ever restarts it. The UI then
shows `idle` in grey: pixel-identical to a healthy node with nothing to do (state 05 vs state 08).

**3 · The vanishing button.** `submit_job_dashboard_button.dart:25` returns `SizedBox.shrink()` when the
selected wallet is not the SGNUS-linked one. It has both addresses on hand and throws the information away
instead of rendering it.

**4 · A ring structurally cannot express "unknown" or "stalled".** Its grammar is "this will fill up". With
no value it must either spin (implies progress) or sit empty (implies 0%). This is not a taste argument —
it is why the shipped UI lies.

**5 · Contrast.** Brand `#0AAEE6` measures **3.0:1 on white** — a fail as label colour. So the *label* stays
`textPrimary` in the processing state and brand colours only the dot and the bar. Success needs the
darkened light-mode token `#07875F` (4.6:1); `#0AD89C` is 1.9:1 on white.

## Recommendation

**A · Dot + label**, with B's ring reserved for exactly one place: the off-dashboard `GWAiFab`.

A is the only treatment that can be honest in all nine states. Keep the ring where there is no room for a
label (56 px FAB), with the same rule applied: **no live percentage → no ring**, show the glyph plus a
state dot.

### Code changes this design requires

Flagged here so they land in the plan rather than surfacing mid-execution:

1. **A stall detector** — same percentage across N consecutive polls flips the state. Cheap; the poll already runs.
2. **A restartable processing timer** — today's permanent `cancel()` makes state 08's Retry impossible to
   wire. Needs an `AppBloc` event that re-arms it.
3. **The linked-wallet reason must reach the button** — it already has both addresses.
