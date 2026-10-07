---
phase: 40-always-available-gnus-bridge
reviewed: 2026-10-07T00:00:00Z
depth: standard
files_reviewed: 15
files_reviewed_list:
  - lib/dashboard/bridge/bridge_entry.dart
  - lib/dashboard/bridge/bridge_gate.dart
  - lib/dashboard/bridge/bridge_gate_cubit.dart
  - lib/dashboard/bridge/bridge_screen.dart
  - lib/dashboard/chart/markets_screen.dart
  - lib/dashboard/home/view/dashboard_screen.dart
  - lib/main.dart
  - lib/navigation/router.dart
  - lib/reown/utilities.dart
  - lib/tokens/token_info_args.dart
  - lib/tokens/token_info_screen.dart
  - test/dashboard/bridge/bridge_entry_test.dart
  - test/dashboard/bridge/bridge_gate_cubit_test.dart
  - test/dashboard/bridge/bridge_gate_test.dart
  - test/dashboard/bridge/bridge_submit_gate_test.dart
findings:
  critical: 0
  warning: 4
  info: 2
  total: 6
status: issues_found
---

# Phase 40: Code Review Report

**Reviewed:** 2026-10-07
**Depth:** standard (diff `bd7af2ee..HEAD -- lib test`, plus the callers it touches)
**Status:** issues_found

## Summary

The core gate holds up. A non-earning wallet cannot reach `bridgeOut`: the earning check runs
before any balance or network rung, is looked up earning -> wallet, and is re-read live in both
the tap handler and `_submitBridge`. The probe is correctly dropped on wallet/network change
(generation plus key), results after `close()` are ignored, all three stream subscriptions are
cancelled, and the cubit never holds key material. `tool/check_brace_style.sh` passes. No
`_buildX` helpers, raw `Colors.*`, plan/phase citations, logging or repository access from
widgets were added in the diff.

What remains is robustness: the child rung fails open, the probe and the coins-error path can
leave the gate on "Checking your GNUS balance." indefinitely, and the submit-time check does not
tie the token being burned to the coin the gate approved.

No BLOCKER found. The reachable-wrong-gate cases below all need an unusual precondition.

## Warnings

### WR-01: Child-wallet rung fails open when the registrations read is unavailable, and the miss is cached

**File:** `lib/dashboard/bridge/bridge_gate_cubit.dart:119-147` (cache key at 119-130)
**Issue:** `ownRegistrations()` returns `null` when every own account's read failed, and omits
any single main whose read failed (`child_operations_cubit.dart:219-250`). `_refreshChild`
treats `null` as "not a child" (`child = false`) and stores that under `_childKey`. D-03 says child
wallets cannot bridge, so a transient SDK read failure lets an earning child wallet through
the gate (and `_submitBridge`'s re-check, which reads the same cached value). The cached `false`
is not retried until `selectedSDKAccount`, the account list, the links, the address or the
identity of the operations state changes. The test `without a registrations read the wallet is
not a child` pins this as intended, but it is the unsafe default for a gate whose job is to
refuse.
**Fix:** Do not cache an unknown result, and treat unknown as not-bridgeable once the node is
running:
```dart
final registrations = operations.ownRegistrations();
if (registrations == null) {
  _childKey = null;      // retry on the next resolve
  return _isChild = false; // or add a BridgeGateState.checking-style rung for "unknown"
}
```
At minimum, only store `_childKey` when `registrations != null` (or `candidates.isEmpty`).

### WR-02: The other-network probe has no timeout, so one hung RPC pins the gate on "Checking"

**File:** `lib/dashboard/bridge/bridge_gate_cubit.dart:226-246`
**Issue:** `Future.wait` over every other network's `balanceOf` has no per-read or overall
timeout. `Web3.balanceOf` builds a `Web3Client(rpcUrl, Client())` with no timeout and never
disposes it (`packages/genius_api/lib/web3/web3.dart:223-260`), and it only converts thrown errors
to 0. A stalled public RPC keeps `_outcome` null, so an earning wallet with no GNUS here reads
"Checking your GNUS balance." until the OS socket gives up, and the slowest RPC gates the answer
for all of them. The result only chooses a caption, so waiting on it is not required for safety.
**Fix:** Bound each read and treat a timeout like a failed read:
```dart
_balanceOf(...)
    .timeout(const Duration(seconds: 8))
    .then<double>((v) => v, onError: (Object _) => 0.0),
```

### WR-03: A failed coins read leaves the gate on "Checking your GNUS balance." with no way out

**File:** `lib/dashboard/bridge/bridge_gate_cubit.dart:66-70` and `lib/dashboard/bridge/bridge_gate.dart:96-98`
**Issue:** `coinsReady` is true only for `coinsStatus == successful`. `WalletDetailsCubit.getCoins`
sets `WalletStatus.error` on a failed read (`wallet_details_cubit.dart:360-368,406,462`). That falls
into the `!coinsReady -> checking` rung, so an earning wallet on a failing RPC shows "Checking your
GNUS balance." permanently, while nothing is checking. The user gets neither a reason nor a retry.
**Fix:** Pass `coinsFailed: details.coinsStatus == WalletStatus.error` to the resolver and add a
state (for example `balanceUnavailable`, caption "Couldn't read your GNUS balance.") ranked above
`checking`, so the caption stops lying and the state can be tested.

### WR-04: Submit-time gate does not tie the burned token to the coin the gate approved

**File:** `lib/dashboard/bridge/bridge_screen.dart:303-325` (and `fromToken` set once at line 55)
**Issue:** `_submitBridge` re-checks `liveBridgeGate(context).enabled`, which is computed from the
live selected wallet, live network and the live GNUS coin. But the burn uses
`fromToken?.address`, captured once in `initState` from the route's `selectedCoin`, together with
the live `state.selectedNetwork` RPC and chain id. If the selected network or wallet changes while
`/bridge` is open, the gate can approve the new network's GNUS while the call burns against the old
network's contract address. Today only the burn's own checks stand between that and a wrong-contract
call. The gate was added precisely to be the last check before `bridgeOut`.
**Fix:** Refuse unless the approved coin is the one being burned, or burn the approved coin:
```dart
final coin = gate.coin;
if (!gate.enabled || coin == null || coin.address != fromToken?.address) { /* toast, return */ }
```

## Info

### IN-01: Probe snapshots `tokensByNetwork` once per coins list, so a late-loaded token list reads as "no GNUS"

**File:** `lib/dashboard/bridge/bridge_gate_cubit.dart:196-221`
**Issue:** `NetworkTokensProvider.loadTokensForNetworks` fills the map network by network and
notifies at the end. If the first probe runs before the other networks' lists are in, `probes` is
empty, `_outcome = (network: null)` is stored, and it is not recomputed until the coins list
changes. The caption then says "You have no GNUS to bridge." when GNUS sits on another network.
Narrow window at startup; it never enables Bridge.
**Fix:** Skip the probe (leave `_outcome` null) while `tokensByNetwork` is empty, and re-run
`resolveNow` when the provider notifies.

### IN-02: Network-bearing caption is truncated on narrow widths, losing the instruction

**File:** `lib/dashboard/bridge/bridge_entry.dart:79-83`
**Issue:** `maxLines: 1, softWrap: false, overflow: ellipsis` cuts "GNUS is on <Network>. Switch
network." at the end, which is the actionable half. Semantics still exposes the full text, and the
test pins this, so it is a presentation trade-off rather than a bug.
**Fix:** Allow two lines for the `gnusElsewhere` caption, or shorten it to "GNUS is on <Network>."

---

_Reviewed: 2026-10-07_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
