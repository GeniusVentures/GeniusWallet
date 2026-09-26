---
created: 2026-09-26T13:00:00.000Z
title: Deleting a wallet from the account drawer most likely does nothing
area: account
files:
  - lib/account/account_drawer.dart
---

## Problem

`_confirmDeleteWallet` in `lib/account/account_drawer.dart` closes the drawer before its
confirmation dialog opens, then gates the delete on `if (confirmed == true && mounted)`. The
drawer's State is disposed by the time the user confirms, so the delete is dropped.

The rename flow had the identical bug and a widget test proved it (`mounted=false`, no event
dispatched); it was fixed in PR #250. The delete path was not re-tested, so "most likely" until a
test shows it.

A second defect sits behind the first: the "pick another wallet" branch only updates the drawer's
own list, never `WalletDetailsCubit`, so fixing the `mounted` gate alone would leave the header
showing a deleted wallet.

## Fix

Dispatch the delete regardless of `mounted` (gate only local `setState`), and when the deleted
wallet was the selected one, select and persist another through the cubit/AppBloc. One widget
test through the real menu and dialog, mirroring the rename test.
