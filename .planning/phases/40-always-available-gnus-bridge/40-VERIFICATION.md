---
phase: 40-always-available-gnus-bridge
verified: 2026-10-07T00:00:00Z
status: human_needed
score: 10/10 must-haves verified
behavior_unverified: 0
overrides_applied: 0
re_verification: false
human_verification:
  - test: "Live walk on Windows, GNUS coin page, dark and light. Select the earning wallet, then switch earning to another wallet."
    expected: "Earning wallet: Bridge enabled and opens /bridge on its GNUS coin. Right after the switch: caption 'Switching earning. Try again soon.' with Bridge disabled. Once it lands: the old wallet reads 'Only the earning wallet can bridge.' and the new earning wallet is enabled. The caption sits on one line under the action row, is readable in both modes, and does not move the other actions."
    why_human: "Needs a running node and a testnet. The testnet validator registry is blocked, so no real earning account or bridge can run. Unit and widget tests use fakes for the earning account and the balance read."
  - test: "Live walk, child and other-network cases (same session once testnet is up)."
    expected: "A child wallet under one of the user's own mains reads \"Child wallets can't bridge.\". A wallet with GNUS only on another network reads 'GNUS is on <network>. Switch network.' and the selected network does not change."
    why_human: "Child registrations come from the SDK and the other-network probe reads real RPC balances. Tests inject both."
  - test: "Tracer human check from plans 40-01 to 40-04 (all four runs skipped the interactive stop)."
    expected: "The working slice (coin page Bridge from the earning gate) looks and behaves as the UI contract describes."
    why_human: "Visual appearance and feel; every plan's executor continued past the tracer gate on the orchestrator's instruction."
---

# Phase 40: Always-available GNUS bridge Verification Report

**Phase Goal:** The user can always find Bridge on the GNUS coin page (a better home on other surfaces is a later decision); it is enabled only for the current earning wallet, otherwise disabled with a one-line reason, and the bridge refuses at submit when the gate is closed.
**Verified:** 2026-10-07
**Status:** human_needed
**Re-verification:** No, initial verification

Every code-level truth holds in the codebase and the targeted tests pass. The only open item is the live walk, which was known and is blocked on testnet. Dashboard and /assets placements are deferred by CONTEXT D-05 (revised) and are not counted.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Bridge is always shown on the GNUS coin page, never hidden | VERIFIED | `token_info_screen.dart:762-763` builds `BridgeButton` for every `isGnusPage`, no gate on presence. The old `isGnusBridgeEnabled` and `isGnusWalletConnected` are gone from `lib/`. |
| 2 | Enabled only when the Selected wallet is the wallet linked to the live earning account (`selectedSDKAccount` + `sdkAccountLinks`), never the start-up address | VERIFIED | `bridge_gate_cubit.dart` `resolveNow()` reads `app.selectedSDKAccount` and `isEarningWallet(wallet, earning, app.sdkAccountLinks)`. Lookup is earning to wallet, both sides lowercased. No import of `SGNUSConnection` in the gate files; `router.dart` no longer reads the connection stream. |
| 3 | View-only wallet, SDK account view and child wallet cannot bridge and each shows its own reason | VERIFIED | Resolver rungs `viewOnly` (via `walletCanSign`: tracking and sgnus types) and `child` (via `ownRegistrations()` scan, cached by key). Captions distinct. Accepted gap: a child of a main the user does not own is undetectable (see Gaps Summary). |
| 4 | Every disabled state shows a one-line muted caption under the button, visible without hover, exposed to screen readers, AA in both modes | VERIFIED | `BridgeReasonCaption` renders below the whole action Wrap, `maxLines: 1`, `gw.textSecondary`. `BridgeButton` Semantics carries the caption as hint. Entry-contract tests cover semantics, variants, contrast (both modes) and 264px one-line fit. No Tooltip. |
| 5 | One pure-Dart resolver owns the gate, precedence and copy; one test file pins them | VERIFIED | `bridge_gate.dart` imports no `package:flutter/`. `bridge_gate_test.dart` pins each rung beating every rung below, every caption, distinctness, no internal terms. Each caption string exists in `lib/` only in `bridge_gate.dart` (one unrelated hit of "Switching earning" in `account_drawer.dart`, different surface). |
| 6 | GNUS held only on another network disables Bridge and the reason names that network; no automatic switch | VERIFIED | `_startProbe` reads same-class networks via `Web3().balanceOf`, first positive in provider order is named. A probe result can only produce `gnusElsewhere`/`noGnus`, never `enabled` (resolver requires `gnusBalance > 0` here). Nothing in the cubit calls a network setter. Cubit tests cover naming, order, zero, failing reads, wallet switch mid-probe, overtaken re-probe. Token catalogue uses `name: "GNUS"` with addresses, so the probe finds real contracts. |
| 7 | The gate is re-read at the moment of the tap and the stale `isGnusWalletConnected` route gate is removed | VERIFIED | `openGnusBridge` calls `liveBridgeGate` then `resolveNow()` and returns without pushing when closed. `router.dart:270-276` builds `TokenInfoScreen` directly, no StreamBuilder. Test "a switch that began after the last frame stops the tap" passes. `grep isGnusWalletConnected lib/navigation lib/tokens/token_info_screen.dart` is empty; remaining hits are the legacy extra-map comments and a parity test that asserts nothing reads the flag. |
| 8 | BridgeScreen re-checks the gate before `bridgeOut` and refuses with the same reason | VERIFIED | `bridge_screen.dart:305-314` reads `liveBridgeGate(context)` before `isSubmitting` is set, toasts `gate.caption` titled "Can't bridge", returns. No cubit in scope reads `kBridgeGateUnknown` (disabled), so it fails closed. Tests: control (one burn), earning flipped with no stream event (zero burns), no gate cubit (zero burns). All pass. `/bridge` is pushed from `openGnusBridge` only. |
| 9 | Bridge opens on the Selected wallet's GNUS coin on the selected network; the Super Genius native GNUS never opens it | VERIFIED | Gate coin comes from `bridgeCoin(details.coins)` only when `coinsNetwork == selectedNetwork` and status successful; requires symbol gnus and non-empty address. `openGnusBridge` does `selectCoin(coin)` then `push('/bridge')`. Tests in `bridge_gate_test.dart` and `bridge_entry_test.dart`. |
| 10 | Scope held: no change to ComputePanel, WalletsOverview, AssetsScreen, nav destinations, or `kDashboardPanelSlotHeight`; no new route | VERIFIED | Diff `bd7af2ee..HEAD` over `lib/components`, `lib/dashboard/assets`, `nav_destinations.dart`: empty. `dashboard_screen.dart` change is a comment rewrite only. No new `GoRoute`. |

**Score:** 10/10 truths verified (0 present but behavior-unverified)

Behavior-dependent truths (earning switch, probe generation, tap-time and submit-time re-read) each have a passing test that exercises the transition, so none is downgraded to present-only.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/dashboard/bridge/bridge_gate.dart` | Pure resolver, captions, `isEarningWallet`, `bridgeCoin` | VERIFIED | 162 lines, substantive, used by cubit, entry, screen, coin page |
| `lib/dashboard/bridge/bridge_gate_cubit.dart` | Live gate with child read and probe | VERIFIED | 249 lines; provided in `main.dart:440` with `childOperations`; generation counter present |
| `lib/dashboard/bridge/bridge_entry.dart` | `BridgeButton`, `BridgeReasonCaption`, `openGnusBridge`, `liveBridgeGate` | VERIFIED | Used by coin page and BridgeScreen |
| `lib/reown/utilities.dart` | `walletCanSign` split from `canSendFrom` | VERIFIED | `canSendFrom` composes `walletCanSign` plus `canSignOn` |
| `lib/dashboard/bridge/bridge_screen.dart` | Submit-time refusal | VERIFIED | Guard at line 305 |
| Test files (gate, cubit, entry, submit gate) | Pin resolver, cubit, entry contract, refusal | VERIFIED | 55 test cases across the four files, all pass |

### Key Link Verification

| From | To | Via | Status |
|------|----|-----|--------|
| `main.dart` | `BridgeGateCubit` | `BlocProvider<BridgeGateCubit>` with `childOperations:` (line 440-446) | WIRED |
| `token_info_screen.dart` | `bridge_entry.dart` | `BridgeButton` + `openGnusBridge(context)` + `BridgeReasonCaption` | WIRED |
| `bridge_entry.dart` | cubit | `resolveNow()` in `liveBridgeGate` | WIRED |
| `bridge_screen.dart` | `bridge_entry.dart` | `liveBridgeGate(context)` before `bridgeOut` | WIRED |
| `router.dart` | `TokenInfoScreen` | direct builder, no stream | WIRED |
| cubit | `ChildOperationsCubit` | `ownRegistrations()` | WIRED |

### Data-Flow Trace (Level 4)

| Artifact | Data | Source | Real data | Status |
|----------|------|--------|-----------|--------|
| Coin page caption/button | `BridgeGateCubit.state` | `AppBloc.state` (`selectedSDKAccount`, `sdkAccountLinks`, `switchingSDKAccount`), `WalletDetailsCubit` (wallet, network, coins), `ownRegistrations()`, `Web3().balanceOf` | Yes | FLOWING |
| BridgeScreen refusal | `liveBridgeGate` | same cubit, `resolveNow()` | Yes | FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Bridge gate, cubit, entry, submit-gate tests | `flutter test test/dashboard/bridge/` | `+95: All tests passed!` | PASS |
| Bridge plus coin page tests | `flutter test test/dashboard/bridge/ test/tokens/` | `+127: All tests passed!` | PASS |
| 360px coin page, both modes | `flutter test test/banxa/buy_entry_points_test.dart` | `+7: All tests passed!` | PASS |
| Analyze bridge, tokens, navigation | `flutter analyze lib/dashboard/bridge lib/tokens lib/navigation` | `No issues found!` | PASS |

The full suite was not run here by instruction; the plan 04 summary quotes `+2465 ~6` green, which I did not re-run.

### Probe Execution

SKIPPED: the phase declares no probe scripts.

### Prohibitions

All seven are test-tier and each has wired enforcement, so none is flagged unverified.

| Prohibition | Enforcing test | Status |
|-------------|----------------|--------|
| BRDG-02: never enable Bridge for a wallet other than the earning one | `bridge_gate_test` rung tests, `isEarningWallet` group, entry test "another account earning disables Bridge" | VERIFIED |
| BRDG-05: no node, SDK or minting in any caption | `bridge_gate_test` "static captions fit one line and avoid internal terms" | VERIFIED |
| BRDG-07: no second start-up-address source of truth | grep: none in router, screen or gate files; parity test asserts no flag in the extra | VERIFIED |
| BRDG-06: never switch network or pick a chain | cubit test "names the first network holding GNUS and changes nothing"; no setter called in cubit | VERIFIED |
| BRDG-06: an RPC answer never enables Bridge | resolver test "a balance here wins whatever the probe says"; probe outcome only feeds `gnusElsewhere` | VERIFIED |
| BRDG-08: no `bridgeOut` when the gate is closed or absent | `bridge_submit_gate_test` (two refusal cases) | VERIFIED |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| BRDG-01 | 40-01, 40-04 | Always-visible Bridge on GNUS coin page, opens /bridge on Selected wallet's GNUS coin | SATISFIED | Truths 1, 9 |
| BRDG-02 | 40-01, 40-02, 40-03 | Enabled only for the live earning wallet | SATISFIED | Truth 2 |
| BRDG-03 | 40-01, 40-03 | View-only, SDK view, child cannot bridge with own reason | SATISFIED | Truth 3 (child detection limited to own mains, accepted) |
| BRDG-04 | 40-04 | One-line muted caption, no hover, screen reader, AA | SATISFIED | Truth 4 |
| BRDG-05 | 40-01 | One pure resolver owns gate, precedence, copy; one test file | SATISFIED | Truth 5 |
| BRDG-06 | 40-01, 40-03 | Other-network GNUS named, no auto switch | SATISFIED | Truth 6 |
| BRDG-07 | 40-01, 40-02 | Tap-time re-read, stale route gate removed | SATISFIED | Truth 7 |
| BRDG-08 | 40-04 | Submit-time refusal with same reason | SATISFIED | Truth 8 |

All eight IDs appear in plan frontmatter (01: 01,02,03,05,06,07; 02: 07,02; 03: 02,03,06; 04: 08,04,01) and in REQUIREMENTS.md. No orphaned requirement.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `.planning/REQUIREMENTS.md` | 221-228, 369-376 | BRDG-01..08 still `[ ]` and "Pending" | Info | Bookkeeping only; update when the phase is closed (after the walk) |
| source | n/a | TBD/FIXME/XXX in phase files | None found | Two `ponytail:` comments mark accepted ceilings, both documented |
| source | n/a | plan/phase/decision identifiers (ID gate) over `bd7af2ee..HEAD` | 0 hits | Clean |
| files | n/a | non-LF files in bridge lib/test dirs | None | Clean |

During the tokens test run, two RenderFlex overflow messages print (`gw_page_header.dart:215` at 318px, and a stat-rail detail row at `token_info_screen.dart:882` at 288px). Both come from the narrow-width range-tile and stat-rail tests, not the action row or caption, and the tests pass. Not attributed to this phase.

### Human Verification Required

1. **Live walk on Windows, earning switch.** On the GNUS coin page in dark and light, select the earning wallet (Bridge enabled, opens /bridge), switch earning (caption "Switching earning. Try again soon.", then "Only the earning wallet can bridge." for the old wallet). Why human: needs a running node and testnet; blocked on the validator registry.
2. **Live walk, child and other-network cases.** A child under an own main, and a wallet with GNUS only on another network (caption names it, network does not change). Why human: real SDK registrations and RPC balances.
3. **Tracer human check** skipped in all four plans by orchestrator instruction. Why human: visual feel of the working slice.

### Gaps Summary

No gaps. All eight requirements and all roadmap and plan truths are backed by code and passing tests.

Accepted limits, recorded so they are not rediscovered as bugs:
- A child of a main the user does not own cannot be detected, so it can still bridge. It mints to the node's own account, so no funds are misdirected (user accepted 2026-10-07; `ponytail:` in the cubit).
- A switch that lands after `bridgeOut` is called is not caught; the burn is already signed.
- The other-network probe covers only the selected network's mainnet/testnet class, so a mainnet user with GNUS only on a testnet reads "You have no GNUS to bridge."
- Probes refresh with the coins, not on a timer.

---

_Verified: 2026-10-07_
_Verifier: Claude (gsd-verifier)_
