---
phase: 46-in-wallet-dashboard-screen
plan: 03
subsystem: gnus-bridge
tags: [linux, walk, pending]
requires: [46-01, 46-02]
provides: []
status: partial
actuals: {tokens: 600, tasks: 0, commits: 0}
---

# Phase 46 Plan 03: Linux build and walk

Skipped by request: one combined Linux walk for phases 45-47 runs later on the slave box. No code, no rig command ran.
Every Linux row is pending, not passed.

| Step | Result | Evidence |
|---|---|---|
| Linux debug build with `GW_DEV_TOOLS=true` | P | not run |
| Dashboard export served on `:3000` | P | not run |
| 1 Entry on the Earning panel | P | widget test only (46-01) |
| 2 Loading bar, then dashboard; page finds `window.gnus` at load | P | not run |
| 3 Connect prompt above the page, page hidden | P | gate tested with a fake host (46-02) |
| 4 JOB fixture: spend confirm above the page, reject, no burn | P | not run |
| 5 My jobs and Earnings show "Not available yet" for null fields | P | not run |
| 6 External link leaves the screen on the dashboard | P | not run |
| 7 Close returns home; reopening shows no connect prompt | P | Close tested (46-02) |
| 8 Server stopped, Reload shows failed notice; Try again recovers | P | states tested with a fake host |
| 9 Hosted switch on: placeholder fails into the notice | P | start rule tested (46-02) |
| 10 File chooser on "Choose a file" | P | optional, not a requirement |
| 11 No WebKitGTK falls back to the browser | T | 46-01 Task 3 tests |

Legend: P pending walk, T test.
## What the walk must settle
- Whether a navigation the lock blocks (step 6) raises a main-frame load error and wrongly shows the failed notice.
- Whether the Linux page hides for the connect prompt and the spend confirm (steps 3 and 4).
- Whether the `Semantics` label wrapper around the Linux view disturbs the native view.

Done line D-01 (the Linux wallet opening the dashboard in-app) is not met until this walk passes. Human check: dev
build, dashboard on `:3000`, press "Jobs and earnings", approve Connect, reject one submit, light and dark, 800 and 1280 px.
