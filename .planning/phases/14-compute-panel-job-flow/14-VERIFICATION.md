---
phase: 14-compute-panel-job-flow
verified: 2026-07-30T14:06:56Z
status: gaps_found
score: 1/8 must-haves verified (2 partial, 5 failed)
behavior_unverified: 0
overrides_applied: 0
gaps:
  - truth: "The dashboard's first card renders as two labelled tiles (a balance readout and a compute node)"
    status: failed
    reason: "ComputePanel (lib/dashboard/compute/compute_panel.dart) is built, unit-tested (height + contrast, 72 tests) and correct in isolation, but nothing under lib/ constructs it outside its own tests. The dashboard's first card is still WalletsOverview's original six-widget centred column."
    artifacts:
      - path: "lib/components/wallet_overview.dart"
        issue: "Still builds the pre-phase-14 _buildColumn() stack (balance display, SGNUSConnectionWidget ring, SGNUSConnectionStatusWidget text, the useMinions ToggleButtons, SubmitJobDashboardButton). No import of ComputePanel, resolveComputeState, or viewForComputeState anywhere in this file."
    missing:
      - "Execute 14-08 Task 1: replace _buildColumn's output with ComputePanel fed by resolveComputeState/viewForComputeState."
  - truth: "One status component tells the truth in all nine (eight shipped) states the node actually enters"
    status: failed
    reason: "The pure resolver (14-01) and the panel that renders it (14-07) are both complete and tested, but the dashboard still renders the two original status widgets (SGNUSConnectionWidget's determinate ring + SGNUSConnectionStatusWidget's isProcessing/processingPercentage text), which read none of AppBloc's new fields. A user opening the app today sees the exact pre-phase status display, with all of its original ambiguity (unavailable indistinguishable from idle, disconnected indistinguishable from not-linked)."
    artifacts:
      - path: "lib/components/sgnus/sgnus_connection_widget.dart"
        issue: "SGNUSConnectionWidget:89-90 still draws a CircularProgressIndicator(value: _initPercentage) from its own local polling of getInitializationStatus() - the exact 52.5%-lie site named in 14-CONTEXT.md, untouched. SGNUSConnectionStatusWidget:125-127 still renders isProcessing ? '<pct>%' : 'idle', reading none of processingFeedStatus/nodeProcessingStatus."
    missing:
      - "Delete both widgets and mount ComputePanel per 14-08 Task 2."
  - truth: "All five shipped bugs are closed at their measured sites"
    status: failed
    reason: "0 of 5 are closed in the shipped UI. See the dedicated bug-by-bug table below."
    artifacts:
      - path: "lib/components/sgnus/sgnus_connection_widget.dart:89"
        issue: "Bug 1 (the 52.5% lie) - determinate ring still drawn, unchanged."
      - path: "lib/bloc/app_bloc.dart"
        issue: "Bug 2 (the silent death) - the data-layer fix (processingFeedStatus, RetryProcessingStatus event) exists and is unit-tested, but RetryProcessingStatus is dispatched from nowhere in lib/ - grep confirms zero call sites outside the handler registration itself. The fix is real but inert."
      - path: "lib/components/job/submit_job_dashboard_button.dart:25-27"
        issue: "Bug 3 (the vanishing button) - still returns SizedBox.shrink() when the selected wallet isn't SGNUS-linked, unchanged."
      - path: "lib/components/wallet_overview.dart:143-148"
        issue: "Bug 4 (zero balance as failure) - still renders 'No funds available' in the error token, unchanged."
      - path: "lib/wallets/view/genius_balance_display.dart:81"
        issue: "Bug 5 (hardcoded Colors.white) - still hardcoded, plus the un-named third occurrence on the unit suffix at :94 (Colors.grey), unchanged. genius_balance_display.dart is still directly used by wallet_overview.dart's balance readout."
    missing:
      - "Execute 14-08 Task 2 exactly as planned - it names all five sites and the closure action for each."
  - truth: "The superseded widgets are gone, not merely unused"
    status: failed
    reason: "SGNUSConnectionWidget, SGNUSConnectionStatusWidget and SubmitJobDashboardButton all still exist as files and are all still imported and rendered by wallet_overview.dart (and, for the status widget, by two further call sites - wallets_overview.dart and wallet_information.dart, neither in this phase's fence)."
    artifacts:
      - path: "lib/components/sgnus/sgnus_connection_widget.dart"
        issue: "Not deleted; both classes it defines are live and rendered."
      - path: "lib/components/job/submit_job_dashboard_button.dart"
        issue: "Not deleted; still the dashboard's only entry point into the job flow."
    missing:
      - "14-08 Task 2's file deletions, after confirming no dangling references (two of which - wallets_overview.dart, wallet_information.dart - are outside 14-08's stated files_modified and need a decision, since 14-08's plan only names wallet_overview.dart's own SGNUSConnectionStatusWidget use)."
  - truth: "The switch-wallet and retry affordances actually do something"
    status: failed
    reason: "ComputeLink.switchWallet and ComputeLink.retry are correctly produced by the pure resolver (compute_state.dart:290 and its retry equivalent) and ComputePanel correctly exposes an onLinkTap callback for both - but no host in the shipped app supplies that callback, because ComputePanel has no host at all. Both affordances are dead code paths reachable only from tests."
    artifacts:
      - path: "lib/dashboard/compute/compute_state.dart:290"
        issue: "Produces ComputeLink.switchWallet, labelled 'Switch wallet ›' - correct, but has no consumer in lib/ outside ComputePanel's own onLinkTap parameter, which nothing supplies a real implementation to."
    missing:
      - "14-08 Task 1: wire onLinkTap's switchWallet case to AccountDrawer.show(context) (14-04, already proven callable) and the retry case to context.read<AppBloc>().add(RetryProcessingStatus())."
requirements-orphaned:
  - "CMP-01, CMP-02 (implied), CMP-03 through CMP-10 - every plan in this phase (14-01 through 14-08) declares requirements: [CMP-xx, ...] in its PLAN.md frontmatter, and every SUMMARY reports each as SATISFIED against its own file. .planning/REQUIREMENTS.md contains ZERO CMP- ids - the entire compute-panel requirement family was never written into the requirements ledger. 14-04's own SUMMARY already flagged this gap on 2026-07-30 ('the whole compute-panel requirement family is untracked in that file'); it is repeated here because it is still true and because phase 14 has no closeout plan to have caught it."
---

# Phase 14: Compute panel & job flow Verification Report

**Phase Goal:** "The dashboard's first section stops lying. The left card becomes two labelled
tiles — a balance readout and a compute node — one status component tells the truth in all nine
states the node actually enters, and requesting a processing job is a visible flow instead of a
flat form ending in a toast full of hex."

**Verified:** 2026-07-30T14:06:56Z
**Status:** gaps_found
**Closed by explicit developer instruction, with known gaps.** This report's job is to make the
gap legible, not to pass the phase — see "What it would take to ship this" below.

---

## Why this phase is being closed anyway

7 of 8 plans executed, and the work they produced is real: a pure state resolver, two new shared
components, a rewritten submit-job cubit and screen, a five-step drawer/full-screen job flow, and
a fully height- and contrast-proven compute panel widget — roughly 2,500 lines of `lib/` and 2,550
lines of tests, all green (726/726 at HEAD `cce8154`, `flutter analyze` 0, brace gate 0).

**14-08 — the integration plan — was never executed, and it is the one plan that ships any of this
to a user.** Every artifact below this line was verified directly against the codebase, not against
SUMMARY.md claims.

---

## Goal Achievement — per-clause verdict

The goal has three clauses. Each is ruled on separately, because they resolved very differently.

### Clause 1: "The left card becomes two labelled tiles"

**FAILED — as user-visible behaviour. Delivered as code.**

`ComputePanel` (`lib/dashboard/compute/compute_panel.dart`) is the twin-tile layout the goal
describes, built to spec, and proven to fit its height budget in all 8 shipped states at two
widths (`test/dashboard/compute_panel_height_test.dart`, 17/17) and to clear WCAG contrast in both
appearance modes (`test/theme/compute_contrast_test.dart`, 55/55). Both test files pass at HEAD.

But `grep -rn "ComputePanel" --include="*.dart" lib` returns **zero matches** — the only two files
that reference the class are its own two test files under `test/`. The dashboard's actual first
card is still `WalletsOverview`'s original `_buildColumn()`, unchanged from before this phase, still
importing and rendering `SGNUSConnectionWidget`, `SGNUSConnectionStatusWidget`, and
`SubmitJobDashboardButton` at `lib/components/wallet_overview.dart:167-176`.

**A user opening the app today sees exactly the same first card they saw before this phase started.**

### Clause 2: "One status component tells the truth in all nine states the node actually enters"

**FAILED — as user-visible behaviour. Delivered as code (8 of 9 states, by locked design).**

The design contract itself parks state 04 (Stalled) for this phase — its detector is backend work,
filed as a pending todo, and 14-01 correctly ships 8 `ComputeState` members, not 9, with a
`ponytail:` comment naming the parked ninth. That descoping is honoured correctly at the code
level and is not being re-litigated here.

Of the 8 states that *are* built: `resolveComputeState`/`viewForComputeState` (14-01) are pure,
tested, and pairwise-distinct by construction (`test/dashboard/compute_state_distinct_test.dart`);
`AppBloc` (14-02) genuinely carries the three-way `processingFeedStatus` split, the tri-state
`nodeProcessingStatus`, and a `RetryProcessingStatus` event that re-arms the timer. All of this is
real, not a stub — but **none of it is read by anything the dashboard renders.**

`SGNUSConnectionWidget` (still mounted) draws its own local `CircularProgressIndicator` from its
own local 3-second poll of `getInitializationStatus()` — the exact 52.5%-lie site named in
`14-CONTEXT.md`, completely untouched by 14-02's work sitting one file away in `AppBloc`.
`SGNUSConnectionStatusWidget` (also still mounted, at `wallet_overview.dart` **and** two further
call sites outside this phase's fence — `wallets_overview.dart`, `wallet_information.dart`) still
renders `isProcessing ? '<pct>%' : 'idle'` off the old boolean. Grep confirms zero references to
`processingFeedStatus`, `nodeProcessingStatus`, `processingCompletedAt`, `initPercentage`, or
`initMessage` anywhere outside `lib/bloc/` and `lib/dashboard/compute/` themselves.

**A user cannot today distinguish *unavailable* from *idle*, or *disconnected* from *not-linked* —
the two bugs this phase names as its headline repudiation fixes both still ship, unchanged.**

### Clause 3: "Requesting a processing job is a visible flow instead of a flat form ending in a toast full of hex"

**PARTIALLY VERIFIED — the more surprising result in this phase.**

`/submit_job` (`lib/navigation/router.dart:300`) is a pre-existing route, and its screen
(`lib/submit_job/view/submit_job_screen.dart`) **was rewritten by 14-06** to render the identical
`JobFlowBody`/`JobFlowFooter` five-step pair the drawer renders — the old hand-rolled flat form,
its two toast listeners, and its reset-before-toast bug are genuinely gone from that file
(confirmed by reading it directly; `resetState()` has exactly one call site, in the Close action,
after a result is already shown).

Because the dashboard's **pre-existing** `SubmitJobDashboardButton` still pushes to `/submit_job`
(`submit_job_dashboard_button.dart:36`, unchanged), **a user who taps "Create Processing Job" today
already sees the new step flow, not the old flat form** — for the narrow case where their selected
wallet happens to be the SGNUS-linked one (bug 3, the vanishing button, still gates this path for
everyone else).

What is **not** shipped: the drawer variant (`JobDrawer.show`, 14-06) that was meant to open in
place, from `ComputePanel`'s own CTA, without navigating away from the dashboard — because
`ComputePanel` has no host. And the three terminal states (including the *bridged, not processed*
hash-preservation fix, 14-05/14-06's main point) are real and reachable through `/submit_job`, but
only for users who can reach that route at all, i.e. only past bug 3.

**Net: this clause is the one piece of the phase goal a real user can partially experience today,
by accident of the button still existing — not by design of this phase's integration.**

---

## Score

| Clause | Status |
|---|---|
| Twin tiles | FAILED (code exists, unrendered) |
| Nine/eight-state status | FAILED (code exists, unrendered; old ambiguous widgets still ship) |
| Visible job-request flow | PARTIAL (new step flow ships via the old, still-buggy entry point) |

**1/8 must-haves cleanly verified** (the measured gates: analyze/brace/tests), **2 partial, 5
failed** — see the full must-haves list below, drawn from 14-08-PLAN.md's own `must_haves.truths`
(the plan that would have shipped the phase) plus the roadmap's five named bugs.

---

## The five shipped bugs — closed or not, re-checked against the tree at `cce8154`

| # | Bug | 14-CONTEXT.md site | Status | Evidence |
|---|---|---|---|---|
| 1 | The 52.5% lie (determinate ring on a stalled feed) | `sgnus_connection_widget.dart:89` | **STILL SHIPS** | `CircularProgressIndicator(value: _initPercentage, ...)` at that exact line, unchanged. The widget is still mounted at `wallet_overview.dart:167`. |
| 2 | The silent death (permanently cancelled polling timer) | `app_bloc.dart:192-195` | **DATA FIX SHIPS, BUG STILL SHIPS** | `RetryProcessingStatus`/`_onRetryProcessingStatus` exist and re-arm `_processingTimer` correctly (confirmed by reading `app_bloc.dart:314-324`) — but `grep -rn "RetryProcessingStatus(" lib/` finds zero dispatch sites. The event is registered and tested in isolation but nothing in the shipped UI ever raises it. A dead feed is still pixel-identical to an idle one on screen. |
| 3 | The vanishing button | `submit_job_dashboard_button.dart:26` | **STILL SHIPS** | `return const SizedBox.shrink();` at that exact line, unchanged. File not deleted. |
| 4 | Zero balance painted as failure | `wallet_overview.dart:143-148` | **STILL SHIPS** | `'No funds available'` string still present at that exact site, unchanged. |
| 5 | Hardcoded `Colors.white` | `genius_balance_display.dart:81` | **STILL SHIPS** | `color: widget.fontColor ?? Colors.white` at line 81, unchanged; the un-named third occurrence on the unit suffix (`Colors.grey`, line ~94) also still present. This widget is still the one `wallet_overview.dart`'s balance readout uses. |

**0 of 5 bugs are closed in the app a user runs.** Bug 2 is the one nuanced case: its data-layer
fix is real, tested, and correct — it is simply unwired, exactly as 14-08's `must_haves.truths`
anticipated ("The switch-wallet and retry affordances actually do something").

---

## Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `lib/dashboard/compute/compute_state.dart` | Pure 8-state resolver + view model | ✓ VERIFIED | Exists, pure Dart (no Flutter import), 8 members, tested (20 tests), pairwise-distinct guard passes. |
| `lib/bloc/app_bloc.dart` / `app_state.dart` / `app_event.dart` | 3-way feed status, tri-state node reading, retry event | ✓ VERIFIED (as code) / ⚠️ ORPHANED (as behaviour) | All fields and the retry handler exist and are unit-tested (`compute_feed_state_test.dart`, 7/7) — but nothing in `lib/` reads or dispatches them outside `lib/bloc/` itself. |
| `lib/components/data/gw_status_dot.dart` | Dot+label status row | ✓ VERIFIED | Built, tested (6/6), consumed by `ComputePanel` — itself unmounted. |
| `lib/components/data/gw_copy_row.dart` | Truncated-display/full-clipboard row | ✓ VERIFIED | Built, tested (5/5), consumed by `JobResultBody` (14-06) — which **is** reachable via `/submit_job`. |
| `lib/account/account_drawer.dart` (`AccountDrawer.show`) | Public drawer entry point | ✓ VERIFIED | Public, tested from a bare context (4/4 tests), ready for a caller. No caller in `wallet_overview.dart` yet. |
| `lib/submit_job/cubit/submit_job_cubit.dart` / `submit_job_state.dart` | `SubmitOutcome`, `bridgeHash`, three error channels, `<=` CTA boundary | ✓ VERIFIED | All present, 35/35 tests pass, consumed correctly by `job_steps.dart`. |
| `lib/submit_job/view/job_drawer.dart`, `job_steps.dart`, `job_step_list.dart` | Five-step flow, two hosts | ✓ VERIFIED (both hosts built) / ⚠️ PARTIAL (only one host reachable) | `JobDrawer` exists and is tested (provider-hazard, dismiss/reopen) but has zero callers in `lib/` — only `/submit_job`'s full-screen host is actually reachable. |
| `lib/dashboard/compute/compute_panel.dart` | Twin-tile panel widget | ✓ VERIFIED (as code) / ✗ MISSING (as rendered UI) | Built, 72/72 tests pass. Zero references outside its own tests. |
| `lib/components/wallet_overview.dart` | The dashboard's first card, rebuilt on the panel | ✗ NOT DONE | Still the pre-phase six-widget stack. This is 14-08's entire, unexecuted scope. |
| `test/dashboard/compute_panel_wiring_test.dart` | 14-08's own wiring test | ✗ MISSING | File does not exist. |

---

## Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| `wallet_overview.dart` | `ComputePanel` | direct render | ✗ NOT WIRED | No import, no construction. |
| `wallet_overview.dart` | `resolveComputeState`/`viewForComputeState` | resolver call feeding the panel | ✗ NOT WIRED | No import. |
| `ComputePanel.onLinkTap(switchWallet)` | `AccountDrawer.show(context)` | affordance wiring | ✗ NOT WIRED | `ComputePanel` has no host to supply this callback in the shipped app. |
| `ComputePanel.onLinkTap(retry)` | `AppBloc.add(RetryProcessingStatus())` | affordance wiring | ✗ NOT WIRED | Same — no host. |
| `ComputePanel.onNewJob` | `JobDrawer.show(context, cubit: ...)` | job-cubit ownership in the dashboard subtree | ✗ NOT WIRED | `JobDrawer` has zero callers anywhere in `lib/`. |
| `SubmitJobDashboardButton` (still shipping) | `/submit_job` route → rewritten `SubmitJobScreen` | pre-existing `context.push` | ✓ WIRED (accidentally, by 14-06's route rewrite) | This is the one link in the whole phase that is genuinely live in the running app today. |

---

## Requirements Coverage

**`.planning/REQUIREMENTS.md` contains zero `CMP-` ids.** Every one of this phase's 8 plans
declares `requirements: [CMP-xx, ...]` in its frontmatter (CMP-01 through CMP-10 collectively
appear across the eight plans), and every SUMMARY records each as `SATISFIED` — correctly, against
each plan's own file-level scope. But the ledger those SUMMARYs are meant to update was never
written to. This is not a fabrication risk to paper over: **the entire CMP- family is orphaned**,
exactly as 14-04's own SUMMARY already flagged on 2026-07-30 ("the whole compute-panel requirement
family is untracked in that file, the same gap ORG-01..05 had before Phase 23's closeout wrote
them"). Phase 14 has **no closeout plan** — no `14-09` or equivalent — which is precisely the kind
of plan that would normally reconcile `REQUIREMENTS.md` against what the phase's plans declared.
That absence is why this gap was never caught before now.

| Requirement family | Status |
|---|---|
| CMP-01 through CMP-10 | ORPHANED — declared by plans, satisfied against plan-scoped code, never entered into `REQUIREMENTS.md` |

---

## The two parked questions — dispositions re-checked

1. **The stall detector (state 04, Stalled).** Still correctly parked; `ComputeState` ships 8
   members, not 9, with the `ponytail:` comment naming the todo file
   (`.planning/todos/pending/2026-07-29-stall-detector-needs-a-traced-processing-feed.md`). This
   disposition is unaffected by 14-08 not shipping — it was never going to render regardless, since
   it needs backend tracing work outside this phase. **Disposition still accurate.**
2. **Whether `requestGeniusSDKProcess` can be re-called after a successful bridge (terminal state
   T2).** Still correctly parked; `grep -n "requestGeniusSDKProcess" lib/submit_job/cubit/submit_job_cubit.dart`
   shows exactly one call site, and `job_steps.dart`'s T2 footer renders only a Close button, with
   the parked question named in a comment at that exact switch case. **Disposition still accurate,
   and — unusually for this phase — this is one of the few pieces of the design that a user actually
   can reach today**, via the still-live `/submit_job` route.

Both dispositions hold. Neither needs revisiting because of 14-08 not executing — they were always
independent of the integration work.

---

## Anti-Patterns Found

No `TBD`/`FIXME`/`XXX` markers in any file this phase's 7 executed plans modified. The one
substantive anti-pattern is architectural rather than a code-smell: a fully-built, fully-tested
subsystem (`lib/dashboard/compute/`, parts of `lib/bloc/`, `lib/submit_job/view/job_drawer.dart`)
with no production caller — the "orphaned artifact" pattern Step 4's status table names directly.
This is not a stub (every branch renders real logic against real inputs, per every SUMMARY's
"Known Stubs: None" — independently confirmed by reading the code, not just the claim) — it is
disconnected wiring, the single most common way a phase like this fails goal-backward verification.

---

## Human Verification Required

None recorded as newly needed by this report. 14-08-PLAN.md's own `<human-check>` walk (8 items:
every state renders distinctly, the card never scrolls, the primary action's disabled reasons are
legible, switch-wallet/retry/job-run end to end, both remaining terminals, zero-balance-as-number)
was never performed, because 14-08 was never executed. It is not re-listed here as a human item
requiring resolution now — running it against unmounted code would produce no information. It
becomes relevant again only once 14-08 (or its replacement) ships.

---

## What it would take to ship this

**Exactly one plan: 14-08.** Its file already exists at
`.planning/phases/14-compute-panel-job-flow/14-08-PLAN.md`, fully specified, `depends_on: ["14-02",
"14-04", "14-06", "14-07"]` — all four of which are done. Nothing about the remaining work is
speculative; it is a mounting exercise over code that already exists, is already tested, and is
already proven to fit its height and contrast budgets.

14-08's own `must_haves.truths`, unchanged, are the exact list to re-verify once it runs:

1. **"The dashboard's first card renders the new panel, driven by real data."** — mount
   `ComputePanel` in `wallet_overview.dart`, fed by `resolveComputeState`/`viewForComputeState` and
   the bloc/stream inputs that already exist.
2. **"All five shipped bugs named in the phase context are closed at their measured sites."** —
   delete `SGNUSConnectionWidget`, `SGNUSConnectionStatusWidget`, `SubmitJobDashboardButton`, and
   the "No funds available"/`Colors.white` sites, per 14-08 Task 2's literal, already-written
   instructions.
3. **"The compute node's status is no longer drawn by a determinate ring on a feed that stops
   moving."** — a direct consequence of (2).
4. **"The switch-wallet and retry affordances actually do something."** — wire
   `ComputeLink.switchWallet` to `AccountDrawer.show(context)` (14-04, proven callable) and
   `ComputeLink.retry` to `AppBloc.add(RetryProcessingStatus())` (14-02, proven correct).
5. **"The superseded widgets are gone, not merely unused."** — the deletions in (2), plus a
   decision on the two call sites 14-08's plan does not currently name
   (`wallets_overview.dart:125`, `wallet_information.dart:106` both still construct
   `SGNUSConnectionStatusWidget`) — these are outside 14-08's stated `files_modified` and will need
   either a scope amendment or an explicit decision to leave them on the old widget.

**Additionally, outside 14-08's own scope but blocking a clean phase close:**
- Write a phase closeout that reconciles `CMP-01` through `CMP-10` into `.planning/REQUIREMENTS.md`
  — the ledger currently has none, and no other phase plan will do this retroactively.
- Decide the two call sites named in item 5 above (they were not in scope for anyone; 14-08's own
  `files_modified` names only `wallet_overview.dart`).
- Run 14-08's own `<human-check>` end-of-phase walk (8 items) once the panel is actually mounted —
  it cannot be meaningfully performed before that.

Whoever next opens the dashboard should read this section first: **a complete, tested compute panel
is sitting one plan away from shipping, and nothing about finishing it requires new design or new
research — only execution.**

---

*Verified: 2026-07-30T14:06:56Z*
*Verifier: Claude (gsd-verifier)*
