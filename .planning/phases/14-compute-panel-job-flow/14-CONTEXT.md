# Phase 14 Context — Compute panel & job flow

**Source:** Design contract locked across sketches 016/017/018 (2026-07-22) and re-cut on the base
components in sketches **076** and **077** (2026-07-29). Written from those locked decisions rather
than a discuss-phase session, because the decisions were taken interactively the same night and
re-asking them would only risk drift.

---

## Domain

The dashboard's first card. Today it stacks six unrelated widgets in a centred column with no section
title, and between them they misreport the state of the compute node in at least five distinct ways.
Requesting a processing job is a flat form ending in a toast containing a raw hex hash.

This phase is the **canonical owner** of that card. It supersedes Phase 5's 05-01/05-02 for this
section. Balances and holdings elsewhere on the dashboard remain Phase 5's.

---

## Locked decisions — do not relitigate

### Chosen shapes

| Decision | Value | Provenance |
|---|---|---|
| Panel layout | **P1 · Twin tiles** (016-B2 rebuilt on components) | 077, chosen by Jakub 2026-07-29 |
| Status treatment | **Dot + label**, 9 states | 017-A, chosen 2026-07-22, re-affirmed in 076 |
| Job flow | **F1 · Drawer, vertical steps** | 018-A, re-affirmed in 077 |
| `/submit_job` | **Kept** as the full-screen host for deep links, rendering the same step bodies | 018-A |

### Chosen on Jakub's "go with your recommendation" — flag these if he wants to revisit

| Open question | Resolution taken | Why |
|---|---|---|
| Section label | **`GWKicker` (13px, non-dense)**, not `GWSectionTitle` | `GWSectionTitle` costs 44px and does not fit the 276px budget. Forcing it means a scroll wrapper, which this card already had to ship once (05-08 gap B1) |
| The 3px overflow | **Drop the `≈ $312.40` subline in the states where the compute bar is visible** | Those are the tallest states. Card lands ~263px instead of 279px |
| GNUS/USD unit clash | **Kept**, mitigated by the `≈ $` subline in all non-tall states | 016-B3 (fiat hero) stays the recorded fallback if the 10s SDK poll and the 60s CoinGecko poll visibly disagree in practice |
| `View transaction ›` | **Dropped** | Needs a job→tx correlation nothing provides. The height budget has ~3px, not 20 |

### Hard constraints

- **Height budget: 276px.** `maxHeight: 300` at `dashboard_screen.dart:212` minus
  `DashboardScrollContainer`'s `EdgeInsets.all(space6)`. **Anything added to the compute block breaks
  this first.**
- **`+12.4 GNUS earned` is out of scope.** No mint/job-reward aggregate exists in `genius_api` or any
  cubit. It is not a UI decision; it is missing data.
- **No ring.** A determinate ring's grammar is "this will fill up" and it cannot render *stalled* or
  *unknown* without lying — which is why the shipped UI lies. The ring survives only in the 56px
  `GWAiFab`, under the rule **no live percentage → no ring**.
- **No golden tests, no snapshot/pixel/visual-regression tooling, no `integration_test`, no `patrol`,
  no Playwright.** Declined twice by Braian, the second time after a full explanation. Ordinary
  `flutter test` cases in the existing style are fine; a harness is not.
- **No new dependencies.** Two package installs declined in a row.
- **Do not delete `GeniusWalletColors`** — demote to private primitives; `GWColors` stays semantic.
- **Rule of Three** for any extraction, unless explicitly overridden.

---

## The five shipped bugs this phase closes — all re-measured 2026-07-29 against `8ed02e78`

Braian's blocking constraint says to re-measure any count in a planning doc. Done. **All five are
alive; two of the roadmap's pointers had drifted and one named a path that does not exist.**

1. **The 52.5% lie.** `sgnus_connection_widget.dart:89` (roadmap said :85) draws a determinate ring
   from `getInitializationStatus()`. Measured over 161 polls / 40s it reaches `0.525` and never moves
   again. Needs a **stall detector** — same percentage across N consecutive polls flips the state.
2. **The silent death.** `app_bloc.dart:192-195` cancels `_processingTimer` **permanently** on any
   exception and emits `isProcessing:false`. Nothing restarts it, so a dead feed is pixel-identical
   to a healthy idle node. Needs a **`RetryProcessingStatus` event** plus a state flag separating
   *unavailable* from *idle*.
3. **The vanishing button.** `submit_job_dashboard_button.dart:26` (roadmap said :25) returns
   `SizedBox.shrink()` when the selected wallet is not the SGNUS-linked one. It holds both addresses
   and discards the information.
4. **Zero balance painted as failure.** `wallet_overview.dart:143-145` (roadmap said :141-147)
   renders `'No funds available'` in `statusError`. A wallet with no funds is not a broken wallet.
5. **Hardcoded `Colors.white`.** `lib/wallets/view/genius_balance_display.dart:81` — **the roadmap
   said `lib/components/genius_balance_display.dart:80`, a path that does not exist.** The 48px
   default is line 79. Both are fixed by moving to `GWAnimatedNumber` @ `numericDisplay` (32/40),
   which also returns 16px to the height budget.

---

## Four further code deltas found by reading the cubit — new in 076, not in 016/017/018

These are **in scope**. Three of them change what the UI must be able to render.

1. **The burned-tokens hole.** `submit_job_cubit.dart:195-218` — when `requestGeniusSDKProcess` fails
   after a **successful** `bridgeOut`, the cubit emits `processErrorMessage` and returns. **The
   `txHash` is never written to state.** The user burned GNUS, got a red toast, and has no hash.
   → The cubit must preserve the hash, and the flow needs a **third terminal state**: *bridged, not
   processed*, showing the bridge hash with a copy affordance.
2. **The success hash is unrecoverable by construction.** `submit_job_screen.dart:48-56` calls
   `resetState()` **before** raising the toast, so the screen empties and the hash lives only in a
   transient toast body. → The result must be a step in the drawer, not a toast.
3. **`isPurchaseable` is off by one and doubles as a false accusation.**
   `submit_job_screen.dart:65` — `jobCost < gnusBalance`, strictly less, so **exactly enough GNUS is
   refused**. The same flag is false when `jobCost == 0`, so "cost not yet known" renders
   *"* You do not have enough GNUS"*. → `<=`, and split cost-unknown from insufficient-funds. Show
   the shortfall as a number.
4. **The percentage goes stale and stays on screen.** `app_bloc.dart:184-191` emits the percentage
   **only while processing**; when processing stops the last value is kept.
   `isProcessing:false, processingPercentage:87.0` is reachable and permanent. → Any bar or number
   **must gate on `isProcessing`**, never on the percentage alone.

Carried, unchanged: `filePickerError` carries balance, token-info and gas-estimate failures as well
as "no file selected", all raised under the toast title **"File Picker Error"**. Three of the four
origins have nothing to do with a file picker.

---

## Components — 10 exist, 5 to build, 6 need non-UI code first

**Exists, reuse:** `GWCard` `GWKicker` `GWAnimatedNumber` `GWButton` `ResponsiveDrawer`
`GWDetailGrid` `GWWarningNote` `GWSpinner` `GWScreen` `GWPageHeader`

**Must build:** `GWStatusDot` (dot + label + optional trailing value) · `GWProgressBar` (the 4px
determinate bar; every bar in the app today is a raw `Container`) · `GWCopyRow` · `GWStepList`

**Needs non-UI code first:**
`AccountDrawer.show(context)` — the mechanism exists in full
(`AccountDropdownSelector._showAccountDrawer()` → `ResponsiveDrawer<Wallet>` → `selectWallet()`) but
is **private** and mounted only in the top-bar action row. Extract a public entry, no new UI ·
`RetryProcessingStatus` event · stall detector · txHash preserved on partial failure · split error
channels · `jobCost <= balance`.

### One spillover into Phase 23 — RESOLVED 2026-07-29

**`GWCopyRow` gains its THIRD consumer here, and Jakub approved promoting it.** Phase 23 **refused**
that extraction after re-measuring: the audit claimed 3 forks, there were 2, below the Rule of Three
floor. The bridge-hash row in the result step is the third, so the floor is now cleared on its own
terms.

**Phase 23 checkpoint — do not let this be discovered later.** Braian's refusal is being reversed,
with cause. Record it in the phase SUMMARY so the Phase 23 executor meets a decision rather than a
contradiction. Promotion only; migrating the two existing forks would break the fence into Phases 7
and 12/15 and is explicitly NOT in scope here.

---

## PARKED 2026-07-29 — backend logic, out of this phase

Jakub parked both as backlog items. **They are backend/native concerns, not UI**, and each has its
own file in `.planning/todos/pending/`. The planner must NOT plan them.

| Parked | Consequence for this phase |
|---|---|
| **The stall detector** — `2026-07-29-stall-detector-needs-a-traced-processing-feed.md`. The "161 polls / 40s" figure matches no shipped timer; three different intervals are conflated, and the processing feed has never been traced at all | **State 04 · Stalled is not renderable.** This phase ships **8 of 9 states**. The first half of the 52.5% fix — deleting the lying determinate ring — still ships, because that is pure UI |
| **Whether `requestGeniusSDKProcess` can be re-called after a successful bridge** — `2026-07-29-can-requestgeniussdkprocess-be-recalled-after-a-successful-bridge.md`. Answer lives in the native SuperGenius layer | **Terminal state T2 (*bridged, not processed*) ships INFORMATIONAL ONLY — no retry CTA.** The hash is preserved and copyable; the user is told plainly what happened. A retry button behind an unverified assumption could burn a second round of GNUS |

---

## Scope fence

**In:** the dashboard's first card; the nine compute states; the job request flow end to end
including its three terminal states; `/submit_job` re-skinned as the full-screen host; the six
non-UI code items above; the five shipped bugs.

**Out:** `/network` re-skin (its own sketch, number 023) · the `+earned` readout (no API) ·
`View transaction ›` (no job→tx correlation) · balances and holdings elsewhere on the dashboard
(Phase 5) · light-mode-only issues (a dedicated app-wide pass after dark, per the
light-verification-backlog todo) · the full de-hex of 525 raw colour references (larger than this
phase).

---

## Success criteria

1. The card renders **eight of the nine** compute states (04 · Stalled is parked with its detector),
   and **no state is pixel-identical to a different state** — specifically *unavailable* (08) must be
   distinguishable from *idle* (05). Note that research downgraded "six states free" to **four**:
   03 · Starting up and 09 · Offline have no data source reachable from the dashboard today, so they
   carry real work.
2. The card fits **276px in every one of the nine states**, measured, not estimated.
3. A job can be requested end to end from the drawer, and **each of the three terminal states is
   reachable and shows the right thing** — including *bridged, not processed*, with a copyable hash.
4. A user holding **exactly** the job cost can buy.
5. The retry link in state 08 actually re-arms the timer.
6. `flutter analyze` stays at **0**; the test suite stays green; `tool/check_brace_style.sh --count`
   stays at **0**.

## Risk summary

- **The height budget is the binding constraint** and it has ~3px of slack after the chosen label.
  Any addition breaks P1 first. `GWStatusDot`'s final metrics are the main unknown.
- Three of the nine states (*stalled*, *job complete*, *unavailable*) need new code before they can
  be rendered at all — the design cannot be verified until that code exists.
- The stall detector is a heuristic over a poll. Its N must be chosen against the measured
  161-polls/40s behaviour, not guessed.
