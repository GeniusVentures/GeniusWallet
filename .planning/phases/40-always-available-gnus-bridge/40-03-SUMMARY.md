---
phase: 40-always-available-gnus-bridge
plan: 03
subsystem: ui
provides: [child detection in BridgeGateCubit, other-network GNUS probe, GnusBalanceRead]
key-decisions:
  - "Child detection scans only the user's own mains (foreign-main children undetectable): accepted by user 2026-10-07"
  - "Only networks of the selected network's mainnet/testnet class are probed; results refresh with the coins, never on a timer"
actuals: {tokens: 5650, tasks: 2, commits: 2}
requirements-completed: [BRDG-02, BRDG-03, BRDG-06]
status: complete
---

# Phase 40 Plan 03: Child status and other-network GNUS probe

BridgeGateCubit now knows whether the Selected wallet is a child and which other network holds its GNUS, so the coin page caption says why Bridge is off. Neither answer can enable Bridge.

## What was built
- Child read: `ChildOperationsCubit.ownRegistrations()` is cached behind a key (earning account, own accounts, links, Selected wallet, child-operations state) and re-read only when the key changes. A null read means not a child.
- Probe: when every rung above the other-network rung passes and the selected network has no GNUS, one balance read per same-class network. First positive in networks.json order is named; failures count as zero.
- A `_probeGeneration` counter drops results from an older wallet, network or coins refresh. A new coins list instance re-probes and the previous outcome shows until it lands. Other state emits keep the same list and read nothing.
- `main.dart` passes `childOperations`; the `GnusBalanceRead` seam defaults to `Web3().balanceOf`.

## Accepted gap
A child of a main the user does not own cannot be detected (the SDK has no by-child query), so it can still bridge. It mints to the node's own account, so no funds are misdirected. Marked with a `ponytail:` comment in the cubit.

## Verification
- `flutter test test/dashboard/bridge/`: `+85: All tests passed!`; `test/dashboard/ test/tokens/ test/banxa/ test/child_wallets/`: `+982: All tests passed!`.
- `flutter analyze lib test`: exit 0, "No issues found!". `dart format --set-exit-if-changed` on touched files, `check_brace_style.sh`, `check_no_new_key_logging.sh --scan-tree` on the cubit: exit 0.
- ID gate on both staged diffs: 0. `childOperations:` in main.dart 1, `_probeGeneration` 4, `ponytail:` 2.
- Not run: full `flutter test` suite; live walk. The dev mock-holdings skip needs `GW_DEV_TOOLS`, so tests only prove `mockMode` alone never suppresses a probe.

## Deviations from plan
- Tracer gate: an interactive run stops for human verify after Task 1. The launching orchestrator required the whole phase in one run, so I re-ran the tracer verify (green, 71 tests) and continued. The human check stays open.

## Commits
- d3b30c21 feat(40-03): Bridge gate detects a child wallet under another own main
- 3b98a3d6 feat(40-03): name the other network holding GNUS in the Bridge caption

## Self-Check: PASSED
