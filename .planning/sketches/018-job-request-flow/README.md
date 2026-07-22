---
sketch: 018
name: job-request-flow
question: "What does requesting a processing job look like as a flow, instead of one flat form and a toast?"
winner: "A · Drawer, vertical steps (chosen 2026-07-22; /submit_job kept as full-screen host)"
tags: [compute, job, flow, drawer, stepper, submit-job, bridge]
---

# Sketch 018: Job Request Flow

## Design Question

The flow already exists in `submit_job_cubit.dart` — file → cost → gas → bridge → process → tx hash. It has
never been *shown* as a flow. `submit_job_screen.dart` renders all of it as one flat `Scaffold`: an "Upload"
action in the app bar, a row of numbers, a raw JSON dump, a "Purchase" button, and a toast containing a hash.

**Where should it live, and what shape do the steps take?**

## How to View

```
open .planning/sketches/018-job-request-flow/index.html
```

Step through 1→5 in the toolbar, or click the buttons in the sheet itself (they advance the flow). Flip
**Not enough GNUS** to see the blocked path. The sidecar maps every step to the real call it makes.

## Variants

- **A · Drawer, vertical steps** — `ResponsiveDrawer`; completed steps collapse to a one-line summary and stay visible.
- **B · Drawer, horizontal stepper** — same surface, classic 1-2-3 bar, full body swap per step.
- **C · Full screen, progressive** — a route, all sections on one surface, later ones dimmed until reached.

## What to Look For

1. **Step 3 (Confirm)** — does the cost decided in step 2 stay visible while you are asked to spend it?
   That is A's whole argument over B.
2. **Step 4 (In flight)** — the two-operation problem. `bridgeOut()` burns the tokens, *then*
   `requestGeniusSDKProcess()` runs. If the second fails, the money is already gone.
3. **Not enough GNUS** — today this is a bare red line under a disabled button; here it is an inline block
   at the point of failure.
4. **Where the job goes when you dismiss the sheet** — it lands in the Compute panel from sketch 016.

## Findings

**1 · Two money operations, one button.** `submit_job_cubit.dart:183-217` — `bridgeOut()` returns a tx
hash, then `requestGeniusSDKProcess()` runs against that. A failure between them leaves burned tokens and
no job. The current UI shows one "Purchase" button and gives no account of this at all.

**2 · Eleven failure messages, all delivered as toasts.** Picker (3), cost (2), balance (1), bridge (1),
process (7 mapped SDK codes, `submit_job_cubit.dart:257-274`). Transient, dismissible, unrecoverable once
faded. All three variants render them inline, at the step that produced them.

**3 · The success signal is a raw transaction hash in a toast body.** `submit_job_screen.dart:48-56`.

**4 · A hardcoded 5 s wait is load-bearing.** `fetchGnusBalanceWithDelay()` — "fetching this immediately
after doing a transaction seems to return a stale value". Any result screen must not promise a fresh
balance before that lands.

**5 · The bridge destination chain is hardcoded** — `destinationChainId: 15305752297694` appears twice with
a `TODO: unhardcode`. Not a design issue, but it means the cost shown is only correct for one route.

## Recommendation

**A · Drawer with vertical steps**, with `/submit_job` kept as the same content in a full-screen host for
narrow viewports and deep links.

`ResponsiveDrawer` is already in the codebase and already used exactly this way for Receive
(`coins_screen.dart:170`) — bottom sheet on mobile, side panel on desktop, no new routes, no new navigation
state. The Compute panel stays visible behind the dim, so the progress lands where it will live from then on.

Vertical over horizontal because the steps have unequal weight: step 2 is a cost table plus an optional JSON
preview, step 3 is one sentence. Vertical lets completed steps collapse to a summary that stays on screen —
which matters when step 3 asks you to confirm spending money you decided on in step 2.
