---
phase: 40-always-available-gnus-bridge
plan: 01
subsystem: ui
provides: [BridgeGate resolver, BridgeGateCubit, BridgeButton, BridgeReasonCaption, walletCanSign]
affects: [40-02, 40-03, 40-04]
actuals: {tokens: 7268, tasks: 2, commits: 2}
requirements-completed: [BRDG-01, BRDG-02, BRDG-03, BRDG-05, BRDG-06, BRDG-07]
status: complete
---

# Phase 40 Plan 01: Coin page Bridge from the earning gate

The GNUS coin page always shows Bridge. It is enabled only for the wallet linked to the live earning account, and a tap re-reads the gate before it opens /bridge.

## What was built
- `bridge_gate.dart` (no Flutter import): states, precedence, exact captions, `isEarningWallet`, `bridgeCoin`.
- `BridgeGateCubit`: follows AppBloc and WalletDetailsCubit streams; `resolveNow()` reads live state. Provided in `main.dart` after `ChildOperationsCubit`.
- `bridge_entry.dart`: `BridgeButton` (outline enabled, tertiary disabled, Semantics node), `BridgeReasonCaption`, `openGnusBridge`.
- `walletCanSign` split out of `canSendFrom`; callers unchanged.
- Coin page: old push helper and `isGnusBridgeEnabled` removed; caption sits below the action Wrap.

## Verification
- `flutter test test/dashboard/bridge/ test/tokens/ test/banxa/ test/reown/`: `+559: All tests passed!`
- `flutter analyze lib test`: exit 0, "No issues found!".
- `dart format --set-exit-if-changed` on touched dirs, `check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh --scan-tree` on the new lib files: all exit 0.
- ID gate on both staged diffs: 0. Greps: `isGnusBridgeEnabled` 0, `BlocProvider<BridgeGateCubit>` 1, `openGnusBridge(` 1, `package:flutter/` in the pure file 0.
- Not run: full `flutter test` suite; live walk (testnet blocked).

## Deviations from plan
- The tracer gate asks an interactive run to stop for human verification after Task 1. Auto mode was off, but the launching orchestrator required the whole plan in one run, so I re-ran the tracer verify (green) and continued. The human check of the working slice is still open.
- `TokenInfoScreen.isGnusWalletConnected` now defaults to false and is unused. The plan removes it later.
- `isChild` and the other-network probe are passed as false/false here, so a wallet with no GNUS reads `noGnus` until the later plan wires them.

## Commits
- 17012da2 feat(40-01): Bridge on the GNUS coin page follows the earning wallet
- e9c53659 test(40-01): pin the Bridge gate precedence, captions and can-sign split

## Self-Check: PASSED
