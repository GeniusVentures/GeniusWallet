---
spike: 002
name: init-progress-polling
type: standard
validates: "Given init running in a spawned isolate, when the main isolate polls GeniusSDKGetInitializationStatus() every 200ms, then percentage advances monotonically 0→1 with non-empty messages before the isolate reports done"
verdict: PARTIAL
related: [001]
tags: [ffi, progress, splash, sgns-sdk]
---

# Spike 002: Init Progress Polling

## What This Validates

**Given** `GeniusSDKInitWithMnemonic` running in a spawned isolate,
**when** the main isolate polls `GeniusSDKGetInitializationStatus()` every 200 ms,
**then** the percentage advances monotonically toward 1.0 with non-empty stage
messages before the isolate reports completion.

This decides whether the determinate progress bar chosen during intake can actually
be fed with real data, or whether the splash has to fall back to an indeterminate
indicator.

## How to Run

Shares the harness and runs of [spike 001](../001-sdk-init-off-isolate/) — the polling
timer lives in the same instrumented `_initSDK`. Filter the log for `SPIKE002`.

## Investigation Trail

**Iteration 1 — poll during init.** A 200 ms `Timer.periodic` on the main isolate
calling `getInitializationStatus()`, started immediately after spawning the init
isolate. Expected ~40 samples across the 8 s window. Got exactly one:

```
SPIKE002 poll#1 t=8151ms pct=0.10000000149011612 msg="Migrating database (step 1 of 5): v0.2.0 -> v1.0.0"
```

One sample, arriving at the very end of the window, reporting 10%.

**Iteration 2 — control run without the SDK call.** Replaced the timer body with a
bare tick counter touching nothing native, to separate "the status call blocks" from
"the main isolate is blocked anyway". Result: `polls=0` — the timer never fired at
all. See spike 001 for the full analysis; the main isolate is frozen for the entire
native init regardless of what Dart does.

So the single sample in iteration 1 was not the timer being blocked *by* the status
call — it was the timer getting its first and only chance to run as the freeze lifted.

**Iteration 3 — poll after init returns.** The post-init calls on the main isolate
returned immediately, with no stall:

```
SPIKE001 post-init status pct=0.10 msg="Migrating database (step 1 of 5): v0.2.0 -> v1.0.0"
SPIKE001 transactionManagerState=GENIUS_TM_STATE_CREATING
```

## Results

**Verdict: PARTIAL ⚠**

Split cleanly by phase:

| Phase | Duration | Main isolate | `getInitializationStatus()` | Progress bar feasible? |
|-------|----------|--------------|------------------------------|------------------------|
| 1 — inside `GeniusSDKInit*` | ~8.2 s | **frozen** | unreachable (0–1 samples) | **No** |
| 2 — after it returns | until ready | responsive | returns instantly, real stages | **Yes** |

**Phase 1 is unreportable.** Not because the status API is unavailable, but because no
Dart code runs at all. This is a property of spike 001's finding, not of this API.

**Phase 2 is exactly what the design wanted.** `GeniusSDKInit*` returning OK leaves the
SDK at **10%**, with `transactionManagerState = GENIUS_TM_STATE_CREATING` and a
human-readable stage string of the form `"Migrating database (step 1 of 5): v0.2.0 ->
v1.0.0"`. That message is already good enough to show a user verbatim, and the
"step N of 5" structure means the percentage is real, not a fabricated animation.

**The trap this closes:** treating `GeniusSDKInit*` returning as "SDK ready". It is
not — it is the 10% mark. Any readiness gate built on the init call returning would
open the dashboard while the SDK is still migrating its database.

**Not yet established:** whether phase 2's percentage actually climbs to 1.0, how long
it takes, and whether it ever stalls. Every run so far was observed only at the instant
init returned. A follow-up spike should poll through phase 2 to completion and record
the curve — that is the input a real progress bar needs, and it is now cheap to
measure because the main isolate is responsive throughout.
