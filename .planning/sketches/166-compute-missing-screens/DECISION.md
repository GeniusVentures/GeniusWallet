# DECISION — Compute panel & job flow · APPROVED

**Status:** ✅ **APPROVED by Jakub, 2026-07-30.** Ready to plan and execute.
**Design source:** `.planning/sketches/166-compute-missing-screens/screens.html` (7 screens)
**Board picked:** `F · C + D` in `index.html`, plus the two refinements below.
**Not yet executed.** No Dart has been written for this.

> Written into the sketch directory, not `STATE.md` / `ROADMAP.md`, because a second session
> (Braian) is mid-PR on this repo. Fold into `ROADMAP.md` when that PR lands.

---

## Does NOT reopen anything

`P1 · Twin tiles` + `F1 · Drawer, vertical steps` (chosen 2026-07-29) stand. Six of Phase 14's
eight plans are executed against them and stay executed. Everything below is **additive**.

---

## 1 · Panel — board F

| Change | Detail |
|--------|--------|
| **Delete the determinate bar during `startingUp`** | The SDK's init feed stops at `0.525` forever. A determinate bar is a promise about a denominator that does not exist. The percentage **stays** as the trailing readout — a number that stops moving is self-evidently stuck in a way a bar at 52% is not. |
| **Keep the bar during `processing`** | There the denominator is real and known (`3 of 8`). The bar tells the truth, so it stays. |
| **A dead feed must say so** | `app_bloc.dart:192-195` cancels `_processingTimer` **permanently** on any exception and emits `isProcessing: false`. `compute_state.dart:48-53` documents the result: *"otherwise pixel-identical to a healthy idle node."* A dead node currently renders as **Ready**. |

Sub-line copy: **`Feed live`** / **`Feed stopped`**, with a **`Reconnect`** link on the dead branch.

**Not in scope: the ninth state (`ComputeState.stalled`).** Board B is the correct end state and is
drawn and waiting, but shipping it needs an `N`, and
`.planning/todos/pending/2026-07-29-stall-detector-needs-a-traced-processing-feed.md` shows the
`"161 polls / 40s"` figure cannot supply one — it describes a **250ms spike trace** while the
shipped timer polls at **1s** (`app_bloc.dart:138`). Un-park when the feed is traced.

## 2 · Step 4, In flight — option B

**One spinner, two named steps as a numbered list.** Not two spinners.

```
◐  Starting your job
   ① Bridging GNUS
   ② Starting the job
```

**Why B and not A/C.** The cubit emits nothing between `bridgeOut()` and
`requestGeniusSDKProcess()` — both run inside one `isBridgingTokens` window
(`job_steps.dart:275-284`). So nothing may imply per-step progress. Two spinners (A) read as two
parallel operations, which is wrong. Prose (C) gets skimmed. B names the two steps as a list the
**terminal three screens later can refer back to** — which is what makes `bridgedNotProcessed`
comprehensible when it happens.

**Follow-up, separate plan: option D.** One `emit` after `bridgeOut()` resolves buys real
sequential progress *and* makes the burned-tokens case detectable earlier. That is a cubit change
(`lib/submit_job/cubit/`), not UI work. Do not bundle it here.

## 3 · Step 5, `bridgedNotProcessed` — softened (tone version 2)

| Before | After |
|--------|-------|
| `Tokens sent, job not started` | **`Bridged · job not started yet`** |
| `GWWarningNote` box + sentence | **sentence only, no box** |
| "…is your **proof** that the transfer happened" | "Keep the transaction below." |
| `Done` | **`Get help`** + `Done` |

**Why removing the box is safe.** The alarm version said the same thing three times: a warning dot,
a warning-bordered box, and the sentence. `GWStatusDot` already carries `statusWarning`, so
`GWWarningNote` was repeating the colour, not adding information.

**What must NOT change.** The hash stays — it is the only artefact the user has. And there is still
**no `Try again`**: retrying spends a second 12.40 GNUS on a job that may already be queued.
`Get help` replaces it.

**OPEN — decide during planning:** where `Get help` routes. Support, the Feedback tab (`/logs`), or
a copied diagnostic bundle. The button is `GWButton`; only its destination is undecided.

**Unchanged:** `bridgeFailed` keeps error tone and `Try again` as primary — nothing was spent, so
retrying is free. Neither token-burning outcome prints a balance figure; both burn before the
delayed 5s refetch lands (`submit_job_cubit.dart:262, 277`), so both say *"Your balance is
updating"* instead of a number that would be wrong.

---

## What this costs: zero new widgets

| Item | Kind | Where |
|------|------|-------|
| Feed-dead flag | **bloc state** | `app_bloc.dart:192-195` — the `catch` cancels the timer; it must also set a flag |
| `Feed live` / `Feed stopped` | **copy** | renders through the existing `_SublineRow` (`compute_panel.dart:322`) |
| `Reconnect` | **copy + 1 enum member** | `_SublineRow`'s link slot already takes a `ComputeLink`; wire to `RetryProcessingStatus` |
| `Get help` destination | **routing decision** | button is `GWButton`; target undecided |

Everything else composes from components that already ship: `GWCard`, `GWKicker`, `GWStatusDot`,
`GWDetailGrid`, `GWCopyRow`, `GWWarningNote`, `GWSpinner`, `GWButton`, `GWAnimatedNumber`,
`ResponsiveDrawer`, `JobStepList`, `_ComputeProgressBar`, `_SublineRow`.

## Also settle during planning

- **Step 1's rejected-file treatment.** Two competing implementations exist: `_InlineError`
  (`job_steps.dart:437`, feature-local) and `GWWarningNote` (shared component). They say the same
  thing two ways. The sketch draws `GWWarningNote`; pick one and delete the other.
- **`RetryProcessingStatus` on repeated failure.** Boards D and F render the affordance; none
  decides whether the third tap backs off.

## Files this will touch

| File | Change |
|------|--------|
| `lib/dashboard/compute/compute_panel.dart` | bar suppressed during `startingUp`; frozen-bar rendering on the dead-feed branch |
| `lib/dashboard/compute/compute_state.dart` | dead-feed input threaded into `resolveComputeState`; one new `ComputeLink` member |
| `lib/dashboard/home/.../app_bloc.dart` | `:192-195` — the `catch` sets an observable flag, not only `cancel()` |
| `lib/submit_job/view/widgets/job_steps.dart` | `JobInFlightBody` → option B; `JobResultBody`'s `bridgedNotProcessed` branch → tone version 2 |
| `test/dashboard/compute_state_distinct_test.dart` | still passes — **no new `ComputeState` member is added** |
