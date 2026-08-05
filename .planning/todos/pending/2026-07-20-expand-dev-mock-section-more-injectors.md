---
created: 2026-07-20T12:10:00.000Z
title: Expand dev Mock section — transactions and more test-data injectors
area: ui
files:
  - lib/dev/dev_mock_holdings.dart
  - lib/dev/dev_tools_bubble.dart
  - lib/test/dev_overrides.dart
---

## Problem

The dev-tools bubble now has a Mock section that injects mock holdings (coins + market
data) so the dashboard can be walked with a non-empty wallet (quick task 260720-cw8). The
developer wants to keep growing this: add **mock transactions** and "whatever we can" —
any test data that lets a screen be exercised without live/on-chain state — into the same
Mock section, added incrementally as we start testing each screen.

Existing seams to reuse: `lib/test/dev_overrides.dart` already has fake-transaction
injectors (`addFakeSGNUSTransactions`, `addFakeWalletCubitTransactions`,
`addFakeWalletTransactions`, `getFakeTransaction`) and `lib/test/test_transaction_button.dart`
adds one fake transaction. These are the transaction analog of DevMockHoldings — wire them
into the Mock section as scenario buttons (e.g. "Mock transactions", empty/loading/error
states) as the transactions screen (05-06) comes up for walking.

## Solution

TBD — incremental. As each dashboard/screen phase is walked, add a dev-only mock scenario
button to the bubble's Mock section for it:
- Transactions: reuse dev_overrides fake-transaction injectors → a "Mock transactions"
  button (and empty/error variants) for the 05-06 transactions screen.
- Other candidates: mock swap/bridge quotes, mock markets data, mock news feed, mock
  connection states — whatever unblocks walking a screen offline.
Keep everything gated `kDebugMode && kShowDevTools`, fixtures in lib/dev/, real path
untouched. Fold new buttons into the sectioned bubble layout (see
[[2026-07-20-move-dev-tooling-out-of-top-bar-into-overflow-bubble]] follow-up: sectionized
dev bubble). Pairs with the light-mode fix for the bubble controls.
