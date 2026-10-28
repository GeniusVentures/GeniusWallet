---
phase: 47-dashboard-over-walletconnect
plan: 01
subsystem: gnus-bridge
tags: [walletconnect, reown, verify, gnus_rpc]
requires: [GnusRpcHandler, GnusOrigin with the walletconnect transport]
provides: [WalletConnectHost, handleGnusRequests, gnusProposalOrigin, gnusSessionOrigin, FakeWalletKit]
status: complete
actuals: {tokens: 9300, tasks: 2, commits: 2}
key-files:
  created: [lib/reown/wallet_connect_host.dart, lib/reown/gnus_wallet_connect.dart, test/reown/fake_wallet_kit.dart, test/reown/gnus_wallet_connect_test.dart]
  modified: [lib/reown/reown_connect_button.dart, lib/reown/handle_dapp_requests.dart, lib/reown/utilities.dart, lib/main.dart, lib/components/overlay/responsive_overlay.dart]
key-decisions: [origin is GnusOrigin.tryParse(walletconnect, metadata.url) with no normalisation, loopback is refused at proposal and at request unless a dev build]
---

# Phase 47 Plan 01: gnus_* over WalletConnect

An app-level `WalletConnectHost` (provided in `main.dart`, started at launch off mobile) owns the proposal
and request listeners. `gnus_*` session requests go to `GnusRpcHandler.handle` with a `walletconnect`
origin and are answered once. A gnus proposal is approved only for a Verify-VALID page.

## Baseline (before the first change)
`flutter test`: 3118 passed, 10 skipped, 0 failed.

## Verification
- `flutter test test/reown test/gnus_bridge`: 573 passed, 0 failed. `flutter analyze lib/reown test/reown` clean.
- Mutation: dropping the gnus skip in `handleDappRequests` fails the drawer test; accepting UNKNOWN in
  release fails 5 tests. Both restored.
- Tracer gate: the user ordered all five plans run unattended, so the tracer's verify was re-run instead of
  stopping for a human check. It passed.

## Deviations
- [Rule 3] The button lost its four constructor parameters (nothing in it reads them now), so
  `responsive_overlay.dart` changed too. `supportedMethods` moved to `utilities.dart` with an `eip155Events`
  constant, so the host does not import the button.
- [Rule 1] `GnusOrigin` has no dev flag, so D-04's example (a loopback session restored in a release build)
  would still parse. The loopback-needs-dev-build rule is applied in `gnusProposalOrigin` and
  `gnusSessionOrigin`; the origin itself is still the parser's, unmodified.
- The host takes optional `walletKit` and `init` so a test can pass the fake. `FakeWalletKit` imports
  `IExpirer` from reown_core (not re-exported), with a lint ignore.
- A failed `approveSession` is followed by `rejectSession` with code -32000 "Could not connect".

## Known stubs
None.

## Self-Check: PASSED
