---
phase: 47-dashboard-over-walletconnect
plan: 03
subsystem: walletconnect
tags: [reown, sessions, signing]
provides: [unsignable-wallet refusal, session account and chain sync, canTransactFrom]
status: complete
actuals: {tokens: 9800, tasks: 3, commits: 3}
key-files: {created: [test/reown/wallet_connect_host_test.dart], modified: [lib/reown/wallet_connect_host.dart, lib/reown/handle_dapp_requests.dart, lib/reown/utilities.dart]}
key-decisions: [the wallet is read again after the connect drawer closes, a send with no from is refused]
---

# Phase 47 Plan 03: Stale and unsignable accounts

No WalletConnect session can sign for, or keep showing, an account the user is not on.
- Proposals: no wallet, a watch-only wallet or an sgnus row is rejected with UNSUPPORTED_ACCOUNTS ("The
  selected wallet cannot sign") and a toast, before Verify and before any drawer. The wallet is read again
  once the user taps Allow, so a switch made while the drawer was open cannot approve the old account.
- Switches: the host watches address, wallet type and chain id. A signable wallet gets `updateSession` on each
  session's own chains, then `accountsChanged` with `[address]`; an unsignable one sends `[]` and leaves the
  account. A network switch sends `chainChanged` to sessions that approved the chain. Passes run in order.
- Transactions: `canTransactFrom` (in `utilities.dart`) needs `from` to equal the selected wallet, that wallet
  to hold a key and the session to list it. Otherwise a drawer states why and the answer is 4100.

## Verification
- `flutter test test/reown`: 261 passed, 0 failed. `flutter analyze lib/reown test/reown` clean; brace check 0.
- Mutation: making `canTransactFrom` always true fails 5 of the 6 new transaction tests. Restored.

## Changed existing tests (no assertion touched)
`handle_dapp_requests_test.dart`: `_wallet.address` is now the `from` every `_tx()` used; `_FakeWalletKit`
holds one session listing the selected wallet; `_start` defaults `wallet` to `_wallet`, takes a `session`;
`_tx` takes a `from`. 16 tests failed before these edits.

## Deviations
- [Rule 2] The wallet is re-read after the drawer, which the plan did not ask for (a stale account is the
  failure this plan exists to stop).
- The "wallet is null" server-error branch in `handleDappRequests` is now unreachable; left as a guard.

Known stubs: none. Self-Check: PASSED
