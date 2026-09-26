---
phase: 14-compute-panel-job-flow
verified: 2026-09-26T11:51:25Z
status: human_needed
score: 6/7 must-haves verified
behavior_unverified: 1
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 1/8
  gaps_closed:
    - "The dashboard's first card renders as two labelled tiles (a balance readout and a compute node)"
    - "One status component tells the truth in all nine (eight shipped) states the node actually enters"
    - "All five shipped bugs are closed at their measured sites"
    - "The superseded widgets are gone, not merely unused"
    - "The switch-wallet and retry affordances actually do something (retry half; switch-wallet is wired but behaviour-unverified)"
  gaps_remaining: []
  regressions: []
behavior_unverified_items:
  - truth: "The switch-wallet affordance actually does something"
    test: "Select a wallet that is not the SGNUS-linked one; tap 'Switch wallet ›' on the compute tile; pick the linked wallet in the drawer"
    expected: "Account drawer opens; after choosing, the card rebuilds to the linked state and the 'New processing job' CTA enables"
    why_human: "wallet_overview.dart:112 calls AccountDrawer.show, but no test taps the link; the wiring test covers state resolution and Reconnect only"
human_verification:
  - test: "14-08's 8-item human-check walk (never performed, per 14-08-SUMMARY): each of the 8 states renders distinctly; card never scrolls/clips at 1.0 text scale; CTA present-but-disabled with a legible reason; switch-wallet opens the drawer; Reconnect revives the unavailable state visually; a job runs end to end from the card via the drawer; both remaining terminals render; a zero balance shows as 0"
    expected: "All 8 items hold in the running app, in both appearance modes"
    why_human: "Drawer opening from the card (AccountDrawer.show, JobDrawer.show, /network push) and a real SDK job are not exercised by any widget test"
  - test: "On the 'Bridged · job not started yet' terminal, tap 'Get help'"
    expected: "Feedback tab (/logs) opens with the failure and bridge hash prefilled, and sends"
    why_human: "14-09-SUMMARY records the router tap-through as untested (hermetic host has no GoRouter)"
requirements-orphaned:
  - "STILL TRUE. .planning/REQUIREMENTS.md contains 0 'CMP-' ids (grep -c = 0). Plans 14-01..14-09 declare CMP-01..CMP-10; the ledger was never written. Not edited here."
---

# Phase 14: Compute panel & job flow — Re-verification

**Goal:** The dashboard's first section stops lying: two labelled tiles, one status component that
tells the truth in every state the node enters, and a visible job-request flow.
**Verified:** 2026-09-26T11:51:25Z against `develop` @ `e100e435`
**Status:** human_needed — every code gap from 2026-07-30 is closed; the 14-08 human walk has never run.

## Previous gaps, re-checked

| # | Previous gap | Now | Evidence |
|---|---|---|---|
| 1 | ComputePanel unmounted | CLOSED | `dashboard_screen.dart:435` mounts `WalletsOverview` (imported from `components/wallet_overview.dart`, line 17), which returns `ComputePanel` at `wallet_overview.dart:248`, fed by `resolveComputeState` (:225) / `viewForComputeState` (:238) from `AppBloc`, `WalletDetailsCubit` and the SGNUS stream (:203-213). |
| 2 | Old status widgets still render | CLOSED | `grep SGNUSConnectionWidget\|SGNUSConnectionStatusWidget` over `lib/` and `test/`: 0 hits. Status comes from the one panel; 8 states, stall (state 04) still parked by design. |
| 3a | Bug 1 — 52.5% ring | CLOSED | `sgnus_connection_widget.dart` deleted (commit `8c172866`, 2026-07-31). `compute_state.dart:262` — bar only for `processing`; `startingUp` shows a percentage, no bar (14-09). |
| 3b | Bug 2 — silent death | CLOSED | Handler `app_bloc.dart:58,430`; dispatched from `wallet_overview.dart:124` via `ComputeLink.reconnect` (renamed from `retry` by 14-09). Behavioural test passes (below). |
| 3c | Bug 3 — vanishing button | CLOSED | `submit_job_dashboard_button.dart` deleted (`8c172866`). CTA is always rendered, disabled via `view.ctaEnabled` (`compute_panel.dart:161`); the not-linked reason plus `switchWallet` link come from `compute_state.dart:300`. |
| 3d | Bug 4 — zero as failure | CLOSED | Balance renders through `GWAnimatedNumber` in `gw.textPrimary` with no zero branch (`compute_panel.dart:316`). "No funds available" survives only in `wallets_overview.dart:88` and `wallet_information.dart:90`, dead shadow files imported only by the dev canary (`lib/dev/generated_closure_canary.dart:64,66`). |
| 3e | Bug 5 — hardcoded Colors.white | CLOSED at the named site (as 14-08 planned) | The dashboard no longer uses `GeniusBalanceDisplay`. The `?? Colors.white` / `?? Colors.grey` fallbacks at `genius_balance_display.dart:81,94` remain; the one live caller (`account_drawer.dart:375`) passes `fontColor: gw.textSecondary`, so no shipped screen hits them. Info only. |
| 4 | Superseded widgets not deleted | CLOSED | Both files deleted in `8c172866`; `lib/components/sgnus/` no longer exists. The two outside-fence call sites are gone too. `SubmitJobButton` (`components/job/submit_job_button.dart`) is a different widget, used only by the dead `wallet_information.dart`. |
| 5 | switchWallet / retry dead | Retry CLOSED; switch-wallet WIRED, BEHAVIOUR UNVERIFIED | `onLinkTap` supplied at `wallet_overview.dart:269`; `chooseWallet`/`switchWallet` → `AccountDrawer.show` (:112), `seeNodeStatus` → `/network` (:114), `reconnect` → `RetryProcessingStatus` (:124). `JobDrawer.show` is called from `onNewJob` (:271), with the cubit owned by this subtree (:60, disposed :134). |
| — | CMP ids orphaned | STILL TRUE | `grep -c CMP- .planning/REQUIREMENTS.md` = 0. Not edited (out of scope). |

## Must-have truths (14-08's list plus the goal's job-flow clause)

| # | Truth | Status |
|---|---|---|
| 1 | First card renders the panel on real data | VERIFIED — wiring test drives the real `WalletsOverview` |
| 2 | One status component, truthful across the 8 shipped states | VERIFIED — compute_state + distinct tests |
| 3 | All five bugs closed at their measured sites | VERIFIED (table above) |
| 4 | No determinate ring on a feed that stops moving | VERIFIED — `compute_state.dart:262`; scale test passes |
| 5 | Switch-wallet and retry affordances do something | PRESENT_BEHAVIOR_UNVERIFIED — retry proven by test; switch-wallet only by presence |
| 6 | Superseded widgets are gone | VERIFIED |
| 7 | Job request is a visible flow, opened from the card | VERIFIED as wiring (`wallet_overview.dart:271`); running it end to end is a human item |

## Behavioural spot-check

`flutter test` (pinned SDK at `../flutter/flutter/bin`) on `compute_panel_wiring_test`, `compute_state_test`,
`compute_state_distinct_test`, `compute_feed_state_test` and `compute_panel_height_test`: **61/61 passed, exit 0**.
The wiring tests cover: disconnected → "Disconnected" (not "Not linked"), address mismatch → "Not linked",
and a tap on "Reconnect ›" moves `processingFeedStatus` from `unavailable` to `neverTicked`.
The full suite, analyze and the brace gate were not run.

## Warnings (not blocking)

- **Plan and spec IDs cited in source**, against AGENTS.md's "never cite plan numbers" rule. Counted by grep:
  `compute_panel.dart` 25, `job_steps.dart` 14, `wallet_overview.dart` 6, `compute_state.dart` 6,
  `job_drawer.dart` 1, `app_bloc.dart` 1. No `TBD`/`FIXME`/`XXX` markers.
- `fiatSubline: ''` (`wallet_overview.dart:266`): the panel has no GNUS/USD price feed, so there is no
  fiat line. This is a known stub recorded in 14-08.
- The `ROADMAP.md` Phase 14 section (around line 760) still describes the 2026-07-30 gaps. It is stale
  and was not edited here.

## Gaps Summary

No code gaps remain. To close the phase, a human needs to run 14-08's 8-item walk and the Get help
tap-through (14-09). Separately, a closeout should write CMP-01..CMP-10 into `REQUIREMENTS.md`.

*Verifier: Claude (gsd-verifier), re-verification*
