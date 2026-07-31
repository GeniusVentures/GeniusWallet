---
sketch: 166
name: compute-missing-screens
question: "What do the compute surfaces look like that 076/077 never covered — the stalled node, a dead feed, and the terminal where the bridge spent real tokens and the job never ran?"
winner: "F · C + D (chosen 2026-07-30 by Jakub)"
depends_on: [076, 077]
reopens: none
tags: [compute, sgnus, phase-14, stall, feed-health, submit-job, terminals, additive]
---

# Sketch 166: Compute — the missing screens

## This does NOT reopen 076/077

`P1 · Twin tiles` + `F1 · Drawer, vertical steps` were chosen by Jakub on **2026-07-29** and six of
Phase 14's eight plans are executed against them. Every board here composes **the shipped anatomy
verbatim** — kicker → 3px → status row → 4px → sub-line → 6px → bar, from
`compute_panel.dart:281-311`. What varies is only which of those slots is present and what it says.

## Design Question

`compute_state.dart:13-24` says it outright: **"Eight states, not nine."** State 04 (*Stalled*) has
no enum member, deliberately, because its threshold cannot be picked honestly yet. Meanwhile two
things on the shipped panel are demonstrably untrue:

1. **The 52.5% lie.** The SDK's init feed climbs to `0.525` and never moves. The panel keeps
   painting a *determinate* bar, which is a promise about a denominator that does not exist.
2. **The silent feed death.** `app_bloc.dart:192-195` cancels `_processingTimer` **permanently** on
   any exception and emits `isProcessing: false`. `compute_state.dart:48-53` documents the result:
   *"otherwise pixel-identical to a healthy idle node."* A dead node renders as **Ready**.

The second is the worse of the two, because the user has no reason to doubt it.

## How to View

```
open .planning/sketches/166-compute-missing-screens/index.html
```

Toolbar bottom-right has **▶ Simulate freeze** — it climbs the bar to 52.5% and stops, the way the
real SDK does, on whichever board is open. Judge each design *in motion*, not at rest.

## Boards

| # | Board | What it proposes | Needs an `N`? |
|---|-------|------------------|---------------|
| 0 | **Today** | control — both lies, side by side | — |
| A | **Last updated** | no detection at all; show when the reading last *changed* | **no** |
| B | **Ninth state** | `ComputeState.stalled`, warning dot, indeterminate bar | **yes — blocked** |
| C | **Bar deleted** | delete the determinate bar during `startingUp`; keep the number | **no** |
| D | **Feed health** | say separately what the node reports and whether we still hear it | **no** |
| E | **Terminals** | `bridgedNotProcessed` vs `bridgeFailed`, drawn so they cannot be confused | — |
| F | **★ C + D** | the shippable pair | **no** |

## Why the ninth state is not simply "the answer"

`.planning/todos/pending/2026-07-29-stall-detector-needs-a-traced-processing-feed.md` parks it, and
the reasoning holds: the *"161 polls / 40s"* figure every planning doc repeats works out to ~4
reads/second and came from a **250ms spike trace**, while the shipped `_processingTimer` polls at
**1s** (`app_bloc.dart:138`). There is no N in that number. Boards A, C, D and F are all designed to
need no threshold at all, which is what makes them shippable while the trace is still missing.

## The one thing board E must get right

`submit_job_state.dart:15-33` added `bridgedNotProcessed` because *"a single hash field cannot tell
those two outcomes apart"*. The design has to carry that distinction or the enum is pointless:

- **`bridgedNotProcessed`** — money is gone, job never ran. **Warning** tone, a hash to keep, and
  **no retry button**. Offering "Try again" here invites the user to pay twice.
- **`bridgeFailed`** — nothing was spent. **Error** tone, `Charged: Nothing` stated explicitly, and
  **Try again** is the primary action because retrying is free.

## Decision — F ✅ CHOSEN 2026-07-30

**Jakub picked board F.** Screen-by-screen walkthrough with component provenance:
`open .planning/sketches/166-compute-missing-screens/screens.html`

### Correction to board E

Board E in `index.html` drew **custom banners** for the job-flow terminals. That was wrong: the
terminals are already implemented (`job_steps.dart:342-436`) and already compose
`GWStatusDot` + `GWWarningNote` + `GWCopyRow` + `GWDetailGrid`. `screens.html` shows what is
actually there. The *distinction* board E argued for (warning + proof-hash + no retry vs error +
Try again) is correct and is what ships - only the drawing was invented.

### What F actually costs: zero new widgets

| Item | Kind | Where |
|---|---|---|
| Feed-dead flag | **bloc state** | `app_bloc.dart:192-195` - the `catch` cancels the timer and must also set a flag |
| `Feed live` / `Feed stopped` | **copy** | renders through the existing `_SublineRow` |
| `Reconnect` link | **copy + enum member** | `_SublineRow`'s link slot already takes a `ComputeLink` |

Everything else on every screen is a component that already ships.

## Recommendation (as written before the pick)

★ **Board F — C + D together.** They close both demonstrable lies and neither needs a threshold, so
they ship against the traced-feed todo instead of waiting for it. C removes the promise the app
cannot keep; D stops a dead feed from impersonating a healthy one, which is the failure a user
cannot even detect today.

**Runner-up: A · Last updated.** A timestamp is a fact rather than a judgement, and it is the
single cheapest honest thing that can be said. It loses to F only because it leaves the dead-feed
case untouched — a stamp reading "Updated 4 min ago" under the label **Ready** is still a panel
claiming the node is fine.

**Rejected for now: B · The ninth state.** Not because it is wrong — it is the correct end state,
and the indeterminate bar is the right shape once we *know* the feed stopped. It is rejected as a
*next step*, because shipping it means inventing an N that the todo says cannot yet be derived.
Un-park it when the feed is traced; the design is drawn and waiting.

## Open items this sketch does not answer

- **14-04 and 14-08** are the two Phase 14 plans with no `SUMMARY.md`. 14-04 concerns the account
  drawer (title, rows, footer, body inset); 14-08 carries a decision Jakub already made on
  2026-07-29. Neither is a compute-status question, so neither is drawn here.
- Whether `RetryProcessingStatus` should re-arm the timer once or back off on repeated failure.
  Boards B, D and F all render a `Retry`/`Reconnect` affordance; none of them decides what happens
  on the third tap.
