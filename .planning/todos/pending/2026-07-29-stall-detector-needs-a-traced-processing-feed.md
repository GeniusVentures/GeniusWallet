# The stall detector needs a traced processing feed before anyone can pick its N

**Found:** 2026-07-29, Phase 14 research.
**Type:** **backend / bloc logic, not UI.** Parked by Jakub the same day, deliberately.
**Blocks:** compute state **04 · Stalled**. Nothing else in Phase 14.

## What it is

A stall detector flips the compute status to *stalled* when the node reports the same percentage
across N consecutive polls. It is the second half of the fix for the "52.5% lie" - the first half
(deleting the determinate ring that promises it will reach 100%) is pure UI and **ships in Phase 14
regardless of this todo**.

## Why it could not be planned

The number every planning document repeats does not describe any timer in the codebase.

- `"161 polls / 40s"` works out to roughly **4 reads per second**. The trace behind it was taken at
  **250ms** intervals, by a spike, not by shipped code.
- `_processingTimer` polls `getProcessingStatus()` at **1s** - `app_bloc.dart:138`.
- The 52.5% stall is not even on that feed. It is on `getInitializationStatus()`, polled at **3s** in
  its only in-app consumer - `sgnus_connection_widget.dart:42`.

Three different intervals, and the planning docs conflate two of them.

## The best available answer, and why it is not good enough to ship

Derived from the trace rather than guessed: floor **2.5s** (10x the longest measured healthy plateau,
which was under 250ms), ceiling **9.8s** (25% of the observed 39.25s stall). Band 3 - 9.8s,
recommendation **8 seconds expressed as a duration, not a poll count**.

The hard problem: **the processing feed has never been traced at all.** The 8s figure is derived from
the *initialization* feed. Applied to processing, a job whose percentage legitimately holds for more
than ~13 minutes would be reported as stalled while it is working correctly. That trades today's lie
("it is fine") for the opposite lie ("it is stuck"), which on a paid job is arguably worse.

## What would close this

Trace `getProcessingStatus()` on a real job to establish how long a healthy percentage plateau
actually lasts. Then N follows from data instead of from an analogy with a different feed. Until
then, state 04 is not renderable honestly and Phase 14 ships **8 of 9 states**.

Related: [[2026-07-29-can-requestgeniussdkprocess-be-recalled-after-a-successful-bridge]] - the other
Phase 14 item parked as backend logic on the same day.
