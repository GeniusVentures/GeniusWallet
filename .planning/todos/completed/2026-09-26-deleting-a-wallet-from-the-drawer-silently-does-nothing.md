---
created: 2026-09-26
title: Deleting a wallet from the drawer silently does nothing
area: account
files:
  - lib/account/account_drawer.dart
  - lib/bloc/app_bloc.dart
  - test/components/wallet_identity_test.dart
---

## Problem

`_confirmDeleteWallet` pops the drawer before its confirmation dialog opens, then gated the delete
on `if (confirmed == true && mounted)`. The drawer's State is disposed by the time the user
confirms, so the `DeleteWallet` event was never dispatched. Separately, when the deleted wallet was
the selected one, only the drawer's local list was updated, never `WalletDetailsCubit`, so the
header could keep showing a deleted wallet. Same shape as the rename bug fixed in PR #250.

## Closed 2026-09-26

- The drawer dispatches `DeleteWallet` regardless of `mounted` and no longer touches its own
  (already disposed) selection mirror.
- `AppBloc._onDeleteWallet` replaces a deleted selection with the first remaining wallet through
  `WalletDetailsCubit.selectWallet` and persists it to `selectedWalletKey`, the same two steps a
  drawer switch performs. The drawer's existing "You must keep at least one wallet." guard remains
  the empty-state handling.
- Tests in `test/components/wallet_identity_test.dart` (group "deleting from the drawer") drive the
  real drawer menu and dialog: the selected-wallet delete failed before the fix (`deleteWallet`
  never called) and now asserts the API delete, the new cubit selection and the Hive write; the
  last-wallet test pins the guard.
