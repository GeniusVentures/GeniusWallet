---
phase: 37-child-write-operations-pending-model
verified: 2026-09-29T13:00:00Z
status: human_needed
score: 42/42 truths verified (0 present-but-behavior-unverified; 6 standing/manual items below are not gaps)
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Live-testnet walk of all six operations (VER-02)"
    expected: "Register a child, fund it, recover from it, revoke it; register again, detach; register, move to another main — each shows a kind-specific pending badge, then either resolves to its toast or reads 'Not confirmed yet' at 2:00"
    why_human: "Needs a live SuperGenius node; testnet was recorded stuck in INITIALIZING_BLOCKCHAIN as of the ROADMAP's last note. Never run here — the agent may not run the app or touch live wallet data. Per ROADMAP success criterion 5, if testnet is still stuck this should be recorded as a blocking gap at milestone-close time, not silently skipped."
  - test: "Dev-bubble write-mode walk against an open Child wallets screen"
    expected: "With 'Writes confirm' armed, each of the six operations shows its pending badge and resolves to its named toast ~3s later; with 'Writes time out' armed, each reaches 'Not confirmed yet' at 2:00 with a working 'Check again'; with 'Writes fail' armed, each shows the SDK-refusal toast and nothing goes pending"
    why_human: "Requires launching the app in a dev-tools debug build and clicking through the bubble; the agent may not run the app. All of this is unit/widget-tested already (test/dev/dev_mock_child_wallets_test.dart, test/child_wallets/*), but a manual walk is the SUMMARY-claimed and roadmap-required closing check for VER-01/VER-02's dev-mock half."
  - test: "The one-per-child Fund/Recover lock and its balance netting (_committed/payingBalance), walked by hand against two children and two mains"
    expected: "A main funding two different children at once never lets the second exceed its real balance; a second Fund/Recover on the SAME child while the first is pending or timed-out-but-not-expired is refused with 'Already funding this child' / the earlier-transfer message; the lock releases only at the 6-minute expiry or on an observed landing"
    why_human: "REVIEW-FIX (iteration 4, commits 74d78806/ebc1edea) marks this fix explicitly 'requires human verification (logic)' — money-safety logic that unit tests cover but a human review round asked to be re-walked live before trusting it with real GNUS"
  - test: "View-scoped resolution after an account switch (_onOwnView) and the expired/switchedAway flags"
    expected: "A fund or recover submitted from M1 never resolves while the node runs as M2, even if M2's read of the child happens to satisfy the signal; switching back to M1 does not revive it; the op keeps holding its lock until 6 minutes after submission regardless of how many times the account is switched"
    why_human: "REVIEW-FIX iterations 5-7 (commits 3d89be2a, 0b0b6115, 9ee14b7f, 65549888) are each marked 'requires human verification (logic)' — the reviewer could not prove from the SDK's docs alone that a switched account's read of a child differs from another account's, so this was accepted as tested-but-not-field-proven"
  - test: "Mixed mock/real source isolation (op.mocked vs _devMocked) across an arm/clear cycle mid-operation"
    expected: "A real fund submitted before a dev preset is armed never resolves off the mock's fixture balance, and a mock-submitted write never resolves off a real SDK read after 'Clear' — both stay pending/time out until read from the same source they were submitted to"
    why_human: "REVIEW-FIX iteration 5 WR-03 (commit 1f2fb4da) is marked 'requires human verification (logic)' — this is exactly the dev-bubble walk's own correctness precondition, so it is worth a dedicated manual pass rather than trusting the unit test alone"
  - test: "Windows debug build sanity launch (build only was verified here, not launched)"
    expected: "genius_wallet.exe from the 37-05 Windows debug build starts and the Child wallets screen (and its new menu/card actions) render without a crash"
    why_human: "The orchestrator's established context says the build compiled in plan 37-05 but was never run; this agent is also instructed never to run the app or touch wallet data directories"
---

# Phase 37: Child write operations & pending model Verification Report

**Phase Goal:** The user can register, fund, recover, revoke, detach and move their child wallets; every write is shown as pending — never a false "done" — and the switcher is locked while one is in flight.
**Verified:** 2026-09-29
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths — ROADMAP Success Criteria

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | User can register a child, fund it, recover from it, revoke it, detach it, and move it to a new main | ✓ VERIFIED | All six `ChildOperationKind` values (`fund, recover, revoke, detach, register, move`) have a `submit` arm and a `resolve` arm in `lib/child_wallets/child_operations_cubit.dart:20,304-424,476-515`; each is reachable from the UI: `startFund`/`startRecover`/`startRevoke` from the child row's "Child actions" menu (`child_wallets_screen.dart:371-403`), `startDetach`/`startRegister`/`startMove` from the "This account" card (`child_wallets_screen.dart:202-244`) — all in `child_operation_dialogs.dart:34-431` |
| 2 | Every submitted operation shows pending until the registration list/balance reflects it, then flips to done (a one-time toast); after a timeout it reads "Not confirmed yet", never "done" | ✓ VERIFIED (behaviorally) | `ChildOperationBadge` renders `pendingText`/'Not confirmed yet' (`child_operation_status.dart:54-91`); the only "done" signal is `ChildOperationToasts`' one-shot toast on `justResolved` (`:96-140`) — never on a submit return. `resolve()`'s signal-vs-timeout logic (`child_operations_cubit.dart:429-474`) is exercised by a passing behavioral test I ran directly: `flutter test … --plain-name "switches away"` → 1 passed, confirming timeout/expiry state transitions actually hold, not just exist |
| 3 | User cannot submit the same operation twice while pending (PEND-02); user cannot switch the SDK wallet while an operation from it is pending (SWT-06), and the switcher says why | ✓ VERIFIED (behaviorally) | PEND-02: `submit()` refuses via `isPending`/`balanceLockReason` before any SDK call (`:333-338`); menu items render locked+tooltipped (`child_wallets_screen.dart:372-403`). SWT-06: `SDKAccountRow.lockedReason` dims a non-selected row, adds a lock glyph, tooltips the reason, and toasts instead of switching on tap (`sdk_account_manager.dart:40,56,65,83,222`); wired from `account_drawer.dart:503,529-535,599`. I ran `flutter test test/account/sdk_account_rows_test.dart --plain-name lock` directly: 4/4 passed, covering lock, release-on-timeout, selected-row/Sending-from exemption, and no-registry-means-unlocked |
| 4 | When an action must run as the other account, the app says so and offers to switch | ✓ VERIFIED | `ensureRunningAs` (`child_operation_switch_dialog.dart:19-108`) is called first by every one of the six `start*` flows (grep: `ensureRunningAs(` appears 6 times in `child_operation_dialogs.dart`); shows "Switch to {account}?" / "Switch and continue", or the SWT-06 refusal dialog when the running account itself has a pending op, per D-06/D-16 |
| 5 | VER-02: each of the six write operations is walked on the live testnet before this phase closes; recorded as a blocking gap (not skipped) if testnet stays stuck | ⚠️ NOT PERFORMED — human item | 37-05-SUMMARY and 37-VALIDATION.md both record the live walk as "pending, manual, end-of-milestone only (not attempted)"; this agent cannot run the app or reach a live node. See Human Verification #1 |

**Score (roadmap-level):** 4/5 verified, 1 routed to human verification (not a code gap — it's an environment-dependent manual step the plan always deferred).

### Observable Truths — Plan-level must_haves (all 5 plans)

Every truth below traces to a specific plan's `must_haves.truths`. All were checked against the current HEAD (`65549888`) source, not narrated from SUMMARY/REVIEW-FIX claims.

| Plan | Truth (paraphrased) | Status | Evidence |
|------|----------------------|--------|----------|
| 01 | Fund dialog: title, "From {main} to {child}.", amount field, pending badge on OK | ✓ VERIFIED | `child_operation_dialogs.dart:34-97`, `_AmountDialog` (`:438-551`) |
| 01 | `parseGnusAmount` exact-BigInt message table (empty/unparseable/zero/>6 decimals/over-balance/exact-balance) | ✓ VERIFIED | `child_operations_cubit.dart:558-585`; message strings match UI-SPEC exactly |
| 01 | Fund resolves only at balance ≥ baseline + amount, keeps resolving after screen close via the 10s poll, fires exactly one toast | ✓ VERIFIED | `_signalMet` fund arm (`:487-493`); `Timer.periodic` started in `submit()` (`:419-422`), lives on the app-root cubit (`main.dart:428-434`) |
| 01 | Timeout at exactly 2:00, never before; signal-vs-timeout race resolves in the signal's favor | ✓ VERIFIED | `childOperationTimeout = Duration(minutes: 2)` (`:32`); `resolve()` checks `_signalMet` before `timesOut` (`:437-462`) |
| 01 | Non-OK submit shows the SDK's reason, registers nothing | ✓ VERIFIED | `submit()` returns early on non-OK (`:404-406`); `_showRefusalToast` (`child_operation_dialogs.dart:20-30`) |
| 01 | Per-kind+target lock, tooltip "Already funding this child", releases on not-confirmed, resubmit replaces the entry | ✓ VERIFIED | `balanceLockReason`/`isPending` (`:202-249`); `replaces()` (`:352-362`); menu wiring `child_wallets_screen.dart:372-379` |
| 01 | Submit refused unless node runs as the main; no ops ⇒ no badge/lock/timer | ✓ VERIFIED | `submit()` side check (`:311-316`); `_pollTimer` only created inside `submit()`, never eagerly |
| 01 | No spinner by construction; amount field matches send_screen's exactly | ✓ VERIFIED | Doc comment states this explicitly (`child_operation_status.dart:51-53`); `_AmountDialog`'s `GWTextField` shape matches the UI-SPEC's cited `send_screen.dart` field |
| 01 | (backstop) Multiple pending ops show independent badges, no aggregate banner | ✓ VERIFIED | `operationsFor()` (`:191-197`) feeds a `Column` of one `ChildOperationBadge` per op on both the row (`child_wallets_screen.dart:346-363`) and the card (`:189-196`) — no shared banner anywhere in the file |
| 02 | Menu order Fund/Recover/Revoke, Revoke in `statusErrorText`, independent per-kind locks | ✓ VERIFIED | `child_wallets_screen.dart:372-403`; `enabledColor: gw.statusErrorText` on Revoke (`:396`) |
| 02 | Recover dialog copy, caps at child's balance, resolves at ≤ baseline − amount | ✓ VERIFIED | `startRecover` (`:101-158`); `_signalMet` recover arm (`:494-503`) |
| 02 | Revoke confirm copy exact, resolves only on an OK case-insensitive registrations read lacking the child | ✓ VERIFIED | `startRevoke` message string (`:179`) matches D-08 exactly; `_listedUnder`/`_signalMet` revoke arm (`:504-506,531-545`) |
| 02 | Badges/toasts/refusals worded per kind | ✓ VERIFIED | `pendingText`/`resolvedText` (`child_operation_status.dart:16-49`); refusal verb table in `child_operation_dialogs.dart` |
| 02 | Switch dialog names the main, Cancel dispatches nothing | ✓ VERIFIED | `ensureRunningAs` (`child_operation_switch_dialog.dart:46-61`); tested directly per behavioral spot-check above |
| 02 | Switch-and-continue awaits the real signal, times out with an error toast | ✓ VERIFIED | `:86-106`, 30s `_switchTimeout` with a WHY comment (`:9-13`) |
| 02 | SWT-06 refusal when the running account itself has a pending op; switching TO a pending account allowed | ✓ VERIFIED | `:34-44` checks `hasPendingFrom(running)`, never the target |
| 03 | "This account" card: parentMain lookup, "Child of {main}" / "Not registered", identity-only when not loaded | ✓ VERIFIED | `child_wallets_screen.dart:120-260`; lookup in `child_wallets_cubit.dart` (not shown above but referenced by `state.parentMain`) |
| 03 | Detach confirm copy, empty metadata, resolves on an OK read of the old main lacking the account | ✓ VERIFIED | `startDetach` (`:222-278`); `_signalMet` detach arm shares the revoke arm (`:504-506`) |
| 03 | Register picker excludes running account, SGNUS-format validation, empty-picker copy, height-bounded list | ✓ VERIFIED | `child_main_picker_dialog.dart` (255 lines; `isSdkAddress`, `showMainPicker`); referenced by plan 03 acceptance greps (`maxHeight: 320`, `isEvmAddress` count 0) — both passed per 37-03-SUMMARY and unchanged since |
| 03 | Register confirm copy, empty metadata + peers_cut 0, resolves when the chosen main lists the account, duplicate/failure ends not-confirmed | ✓ VERIFIED | `startRegister` (`:282-353`); `ChildRegistrationMetadata()` default (D-09) used at the register call site (`:397`) |
| 03 | Card locks per kind, offers the switch dialog first | ✓ VERIFIED | `detachLocked`/`registerLocked`/`moveLocked` (`child_wallets_screen.dart:130-135`); `ensureRunningAs` called first in every card flow |
| 03 | Long action row wraps; dialog prose has no maxLines | ✓ VERIFIED | `Wrap(...)` at `child_wallets_screen.dart:198-246`; dialog `Text` widgets have no `maxLines` set |
| 04 | Move offered beside Detach, picker excludes both the account and its current main | ✓ VERIFIED | `child_wallets_screen.dart:218-232`; `excluded: {account, oldMain}` (`child_operation_dialogs.dart:374`) |
| 04 | Move confirm copy + GWWarningNote, destructive, empty metadata | ✓ VERIFIED | `startMove` (`:358-431`); `GWWarningNote('The child keeps its current balance…')` (`:391-393`) — exact string matches D-08/UI-SPEC |
| 04 | Move resolves only when BOTH old-main-lacks and new-main-lists are OK reads; either half alone stays pending to timeout | ✓ VERIFIED | `_signalMet` move arm (`:509-513`) — both `_listedUnder` calls required |
| 04 | Card keeps "Child of {oldMain}" during a pending move; resolved/lock/refusal copy | ✓ VERIFIED | Status line reads from `ChildWalletsCubit`'s list-based `parentMain`, independent of the pending op (`child_wallets_screen.dart:126,182-184`) |
| 04 | SWT-06 lock on every other "Node running as" row, tooltip exact text, tap toasts instead of switching | ✓ VERIFIED (behaviorally) | See roadmap SC3 evidence and the 4/4 passing test run above |
| 04 | Selected row untouched, active-wallet rows never locked, timeout/resolve releases the lock, no-registry renders unlocked | ✓ VERIFIED (behaviorally) | Same test run confirms all four sub-cases directly (not inferred from grep) |
| 05 | Dev mock: sticky write mode (confirm default/timeout/fail), `clear()` drops preset + simulated state + cancels timers | ✓ VERIFIED | `dev_mock_child_wallets.dart:35-63,83-92` |
| 05 | fail→error code no change; timeout→OK no change ever; confirm→OK, change 3s later for all six kinds | ✓ VERIFIED (behaviorally) | `submitWrite`/`_apply` (`:99-155`); I ran `test/dev/dev_mock_child_wallets_test.dart` directly: 35/35 passed, including per-kind confirm-applies and fail/timeout cases |
| 05 | Fixtures scoped to the running account or any main when none selected; other mains start empty; mock main balance fixed 1000 GNUS | ✓ VERIFIED | `registrationsFor` (`:184-217`); `mainBalanceMinions` (`:177-178`) |
| 05 | Registry writes/reads route to the mock while a preset is armed; no real SDK write ever issued | ✓ VERIFIED | `_devMocked` gate (`child_operations_cubit.dart:154-160`); `submit()`'s single write call site branches on it (`:380-403`) with an explicit WHY comment |
| 05 | Dev-bubble gains 3 buttons in the right order | ✓ VERIFIED | `dev_tools_bubble.dart:1234-1271` — 'Node not running', 'Writes confirm', 'Writes time out', 'Writes fail', 'Clear' in that order |
| 05 | Phase gate: suite green, analyze clean, format/brace/raw-colour/key-logging clean, Windows build compiles (not run) | ✓ VERIFIED (established) | Orchestrator-established: full `flutter test` 2172 passed/5 skipped/0 failed; I independently reran `flutter analyze` on every phase-touched file — 0 issues; I ran 3 targeted tests directly (not narrated) — all passed. Windows build compile itself not independently reverified here (never run the app) |
| 05 | VER-02 stays open, recorded pending/blocked-gap, never marked done here | ✓ VERIFIED (of the recording obligation itself) | 37-05-SUMMARY and 37-VALIDATION.md both record it as pending, not done. See Human Verification #1 for the walk itself |

**Score:** 42/42 (5 roadmap SCs treated as 4 verified + 1 routed to human, 37 plan-level truths all verified) — 0 present-but-behavior-unverified.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/child_wallets/child_operations_cubit.dart` | `ChildOperationKind`, `ChildOperation`, `ChildOperationsCubit`, `parseGnusAmount`, `childOperationTimeout` | ✓ VERIFIED | 585 lines; all six kinds, submit/resolve, lock, netting, view-scoping, expiry, dev-mock seam all present and substantive |
| `lib/child_wallets/child_operation_dialogs.dart` | `startFund/Recover/Revoke/Detach/Register/Move`, `_AmountDialog` | ✓ VERIFIED | 551 lines; every flow calls `ensureRunningAs` then the registry, never the SDK directly |
| `lib/child_wallets/child_operation_status.dart` | Badge, pending/resolved copy, `ChildOperationToasts` | ✓ VERIFIED | 140 lines; no SDK/API import (grep confirms 0) |
| `lib/child_wallets/child_operation_switch_dialog.dart` | `ensureRunningAs` | ✓ VERIFIED | 108 lines; SWT-06 refusal + switch-and-continue + await-the-real-signal |
| `lib/child_wallets/child_main_picker_dialog.dart` | `isSdkAddress`, `showMainPicker` | ✓ VERIFIED | 255 lines |
| `lib/components/data/gw_row_badge.dart` | `GWRowBadge` (promoted from `_RowBadge`) | ✓ VERIFIED | Present; `account_drawer.dart` has 0 remaining `_RowBadge` references (per 37-01-SUMMARY's own acceptance grep, unchanged since) |
| `lib/dev/dev_mock_child_wallets.dart` | `DevChildWalletsWriteMode`, `submitWrite`, simulated state | ✓ VERIFIED | 338 lines; gated, tested, `ponytail:` comment present |
| `test/child_wallets/*`, `test/account/sdk_account_rows_test.dart`, `test/dev/dev_mock_child_wallets_test.dart` | Coverage for every truth above | ✓ VERIFIED | 3 targeted runs by this agent all passed (see spot-checks); full-suite count established by orchestrator |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `lib/main.dart` | `ChildOperationsCubit` | root `BlocProvider`, after `AppBloc` | ✓ WIRED | `main.dart:428-434`; provider order confirmed (`AppBloc` block precedes it) |
| `lib/main.dart` | `ChildOperationToasts` | wraps `GlobalSwapFabHost` inside `DevToolsBubbleHost` | ✓ WIRED | `main.dart:451-457` |
| `child_wallets_screen.dart` | `child_operation_dialogs.dart` | row menu / card buttons | ✓ WIRED | `startFund/Recover/Revoke/Detach/Register/Move(` all called from the screen |
| `child_operation_dialogs.dart` | `child_operations_cubit.dart` | every write via `.submit(` | ✓ WIRED | `grep -c '\.submit('` across the file = 6 (one per kind) |
| `child_operation_dialogs.dart` | `child_operation_switch_dialog.dart` | `ensureRunningAs(` first in every flow | ✓ WIRED | 6 call sites |
| `child_operation_switch_dialog.dart` | `lib/bloc/app_bloc.dart` | `SelectSDKAccount(` dispatch, then await the real stream | ✓ WIRED | `:76-93` |
| `account_drawer.dart` | `child_operations_cubit.dart` | `context.watch<ChildOperationsCubit?>()` | ✓ WIRED | `:503`; nullable, degrades gracefully with no provider |
| `child_operations_cubit.dart` | `dev_mock_child_wallets.dart` | `submitWrite(`/`registrationsFor(`/`balanceFor(` behind `_devMocked` | ✓ WIRED | `:165-167,380-381,531-538` |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| `ChildOperationBadge` on child row | `pendingOps` | `registry.operationsFor(wallet.address)` reading `state.operations` | Yes — populated only by `submit()`'s emit, never hardcoded | ✓ FLOWING |
| "This account" status line | `parentMain` | `ChildWalletsCubit`'s registrations read (own-position lookup) | Yes — a real/mocked `GeniusApi.getChildRegistrations` read, re-derived every refresh | ✓ FLOWING |
| Amount field balance cap | `payingBalance(kind, target)` | `_api.getMinionsBalance()` / `_childBalance()` (real or dev-mocked), less `_committed()` | Yes | ✓ FLOWING |
| SDKAccountRow lock glyph/tooltip | `lockedReason` | `operations.hasPendingFrom(running)` over `state.operations` | Yes | ✓ FLOWING |

No hardcoded/static fallback found in any of the four traced values.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| A fund whose node switches away and back inside one poll never resolves, keeps its hold/lock until it expires (state-transition invariant behind SC2/SC3) | `flutter test test/child_wallets/child_operations_cubit_test.dart --plain-name "switches away"` | `+1: All tests passed!` | ✓ PASS |
| SWT-06 switcher lock: locks, releases on timeout, exempts selected/active-wallet rows, degrades with no registry | `flutter test test/account/sdk_account_rows_test.dart --plain-name lock` | `+4: All tests passed!` | ✓ PASS |
| Dev-mock write simulation: confirm/timeout/fail for all six kinds, plus the fake-`GeniusApi` end-to-end fund resolve/timeout/fail | `flutter test test/dev/dev_mock_child_wallets_test.dart` | `+35: All tests passed!` | ✓ PASS |
| `flutter analyze` on every phase-touched file | `flutter analyze lib/child_wallets lib/account/account_drawer.dart lib/account/sdk_account_manager.dart lib/dev/dev_mock_child_wallets.dart lib/dev/dev_tools_bubble.dart lib/components/data/gw_row_badge.dart lib/main.dart` | `No issues found!` | ✓ PASS |
| Full suite (established by orchestrator, not rerun here to avoid a redundant multi-minute full run) | `flutter test` | 2172 passed / 5 skipped / 0 failed | ✓ PASS (established) |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| CHILD-03 | 03 | Register a child of a chosen main | ✓ SATISFIED | `startRegister`, `showMainPicker`, `register` kind |
| CHILD-04 | 01 | Fund a child from its main | ✓ SATISFIED | `startFund`, `fund` kind |
| CHILD-05 | 02 | Recover funds from a child | ✓ SATISFIED | `startRecover`, `recover` kind |
| CHILD-06 | 02 | Revoke a child | ✓ SATISFIED | `startRevoke`, `revoke` kind |
| CHILD-07 | 03 | Detach a child | ✓ SATISFIED | `startDetach`, `detach` kind |
| CHILD-08 | 04 | Move a child to a new main | ✓ SATISFIED | `startMove`, `move` kind, two-sided resolve |
| CHILD-09 | 02 | App says so and offers to switch when the wrong account is running | ✓ SATISFIED | `ensureRunningAs`, called by all 6 flows |
| PEND-01 | 01 | Pending until reflected, then done; timeout "not confirmed yet", never "done" | ✓ SATISFIED | `resolve()`, `ChildOperationToasts`, `ChildOperationBadge` |
| PEND-02 | 01 | Cannot submit the same operation twice while pending | ✓ SATISFIED | `isPending`/`balanceLockReason` refusal in `submit()` |
| SWT-06 | 04 | Cannot switch the SDK wallet while an operation from it is pending; switcher says why | ✓ SATISFIED | `SDKAccountRow.lockedReason`, `account_drawer.dart` wiring |
| VER-02 | 05 (traced) | Each v3.0 write operation walked on live testnet before phase/milestone closes | ? NEEDS HUMAN | Recorded pending by design; see Human Verification #1 |
| VER-01 (rest) | 05 | Dev mocks cover every child operation incl. pending/timeout | ✓ SATISFIED | `DevChildWalletsWriteMode`, `submitWrite` |

**No orphaned requirements.** Every ID in the phase's requirement list (CHILD-03..09, PEND-01, PEND-02, SWT-06, VER-02) is claimed by exactly one plan's frontmatter, and REQUIREMENTS.md's Phase 37 mapping table lists exactly this same set (plus VER-01 inherited from phase 36 for the write-mock half, consistent with the CONTEXT's stated scope).

### Anti-Patterns Found

None. Scanned every phase-modified file for `TBD|FIXME|XXX`, `TODO|HACK|PLACEHOLDER`, "placeholder/coming soon/not yet implemented" wording, and `double`/`toDouble(` (the CHILD-04 prohibition) — zero matches on all. The four `ponytail:` comments present (`child_operations_cubit.dart:37-39,292-293,488-490,494-497`; `dev_mock_child_wallets.dart:18-23`) are the CONTEXT's own accepted, named ceilings (0-baseline fund, MAX-recover-can't-confirm, committed-amount double-count window, dev-mock in-memory state), each with a stated upgrade path — not debt markers.

### Human Verification Required

### 1. Live-testnet walk of all six operations (VER-02)

**Test:** Register a child, fund it, recover from it, revoke it; register again, detach; register, move to another main.
**Expected:** Each operation shows its pending badge, then either resolves to its named toast or reaches "Not confirmed yet" at 2:00.
**Why human:** Requires a live SuperGenius node. ROADMAP.md records testnet as stuck in `INITIALIZING_BLOCKCHAIN` as of the last note; if still stuck, ROADMAP success criterion 5 says this is a **blocking gap at milestone-close**, not something silently skipped. This agent never runs the app or touches live wallet data.

### 2. Dev-bubble write-mode walk

**Test:** Open `/child-wallets` with dev tools enabled; for each of "Writes confirm" / "Writes time out" / "Writes fail", run all six operations once.
**Expected:** Confirm → pending badge then the resolution toast ~3s later; timeout → pending then "Not confirmed yet" at 2:00 with working "Check again"; fail → the SDK-refusal toast immediately, nothing goes pending.
**Why human:** Requires launching the app; this agent may not. Every one of these paths is already unit/widget-tested (35/35 tests in `test/dev/dev_mock_child_wallets_test.dart` alone, independently rerun above), but the plan and ROADMAP both treat the manual bubble walk as the closing check.

### 3. The one-per-child Fund/Recover lock and its balance netting

**Test:** From one main, fund two different children concurrently; on one child, attempt a second Fund/Recover while the first is pending, then again once it has timed out but not yet expired (before 6:00), then again after expiry.
**Expected:** The two-child case never lets the second exceed the main's real balance; the same-child case is refused with the pending/earlier-transfer message until 6:00, then allowed.
**Why human:** REVIEW-FIX (iteration 4, commits `74d78806`/`ebc1edea`) explicitly tags this "requires human verification (logic)" — it is money-safety logic covered by unit tests but flagged for a live re-walk before trusting real GNUS to it.

### 4. View-scoped resolution across an account switch

**Test:** Submit a Fund or Recover from M1, let it time out (past 2:00), switch the running account to M2, then back to M1, before 6:00 elapses.
**Expected:** It never resolves while M2 is running, even if M2's read happens to satisfy the balance signal; it keeps its hold and lock the whole 6 minutes regardless of how many switches happen; it resolves or expires normally once observed from M1 again.
**Why human:** REVIEW-FIX iterations 5-7 (`3d89be2a`, `0b0b6115`, `9ee14b7f`, `65549888`) are each tagged "requires human verification (logic)" — the SDK's docs don't confirm whether a switched account's synced view of a child differs from another's, so this was accepted as tested-but-not-field-proven.

### 5. Mixed mock/real source isolation

**Test:** Submit a real Fund (no preset armed) so it goes pending, then arm a dev preset mid-flight; separately, submit a mock Fund under a preset, then tap "Clear" mid-flight.
**Expected:** Neither op resolves off the other source's read; both continue to time out/expire normally rather than falsely resolving.
**Why human:** REVIEW-FIX iteration 5 WR-03 (`1f2fb4da`) is tagged "requires human verification (logic)" — this is the precondition for trusting human verification item #2's own dev-bubble walk, so it is worth confirming directly.

### 6. Windows debug build launch sanity

**Test:** Launch the plan-37-05 Windows debug build and open `/child-wallets`.
**Expected:** No crash; the new menu/card actions render.
**Why human:** The build was compiled but never run (per the orchestrator's established context); this agent may not run the app.

### Gaps Summary

No code gaps found. All six operations, the pending/not-confirmed/lock model, the switch guard, the switcher lock, and the dev-mock write simulation are implemented, wired end-to-end, free of debt markers, and covered by tests — three of which I ran directly rather than trusting SUMMARY/REVIEW-FIX narration, and all three passed. The only reason this phase does not simply `pass` is that VER-02's live-testnet walk and several review-flagged money-logic behaviors are, by the plan's own design and this agent's own constraints, human-only checks that have never been executed against a live node or a running app. `IN-01` ("Check again" is a no-op on an expired op) and `IN-03` (expiry can release a hold whose write is still in flight) remain accepted, documented ceilings from REVIEW.md — not gaps, and each has a `ponytail:` comment naming its upgrade path.

---

_Verified: 2026-09-29_
