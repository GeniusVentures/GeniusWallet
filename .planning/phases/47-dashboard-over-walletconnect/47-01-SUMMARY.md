---
phase: 47-dashboard-over-walletconnect
plan: 01
subsystem: gnus-bridge
tags: [walletconnect, verify]
provides: [WalletConnectHost, handleGnusRequests, gnusProposalOrigin, gnusSessionOrigin, FakeWalletKit]
status: complete
actuals: {tokens: 9300, tasks: 2, commits: 2}
key-files: {created: [lib/reown/wallet_connect_host.dart, lib/reown/gnus_wallet_connect.dart, test/reown/fake_wallet_kit.dart], modified: [lib/reown/reown_connect_button.dart, lib/main.dart]}
key-decisions: [origin is GnusOrigin.tryParse(walletconnect, metadata.url), loopback refused at proposal and request unless a dev build]
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
- Tracer gate: plans were ordered run unattended, so its verify was re-run instead of a human stop. Passed.

## Deviations
- [Rule 3] The button lost its four constructor parameters (nothing in it reads them now), so
  `responsive_overlay.dart` changed too. `supportedMethods` moved to `utilities.dart` with an `eip155Events`
  constant, so the host does not import the button.
- [Rule 1] `GnusOrigin` has no dev flag, so D-04's example (a loopback session restored in a release build)
  would still parse. The loopback-needs-dev-build rule is applied in `gnusProposalOrigin` and
  `gnusSessionOrigin`; the origin itself is still the parser's, unmodified.
- The host takes optional `walletKit` and `init` for the fake. A failed `approveSession` is followed by
  `rejectSession` (-32000 "Could not connect").

Known stubs: none. Self-Check: PASSED
