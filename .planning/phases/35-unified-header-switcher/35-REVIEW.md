---
phase: 35-unified-header-switcher
reviewed: 2026-09-29T00:00:00Z
depth: standard
files_reviewed: 20
files_reviewed_list:
  - lib/account/account_drawer.dart
  - lib/account/account_switcher.dart
  - lib/account/sdk_account_manager.dart
  - lib/components/data/gw_copy_row.dart
  - lib/components/overlay/responsive_overlay.dart
  - lib/reown/send_transaction_details.dart
  - lib/send/send_screen.dart
  - lib/squid_router/swap_screen.dart
  - test/account/account_drawer_network_section_test.dart
  - test/account/account_drawer_show_test.dart
  - test/account/sdk_account_delete_coupling_test.dart
  - test/account/sdk_account_rows_test.dart
  - test/account/sdk_add_account_test.dart
  - test/account/sdk_start_account_delete_test.dart
  - test/components/desktop_top_bar_text_scale_test.dart
  - test/components/drawer_padding_invariant_test.dart
  - test/components/gw_copy_row_test.dart
  - test/components/wallet_identity_test.dart
  - test/send/send_screen_test.dart
  - test/squid_router/swap_submit_test.dart
findings:
  critical: 0
  warning: 2
  info: 1
  total: 3
status: issues_found
---

# Phase 35: Code Review Report

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 20
**Status:** issues_found

## Summary

This phase merges the desktop "SDK Accounts" chip and the wallet dropdown into one
`AccountSwitcher`/`AccountDrawer` surface with two independent sections ("Sending from" /
"Node running as"), adds the D-07 "View balance" menu item, extends `GWCopyRow` with a
`caption`, and adds a wrong-account guard line to Send's review row and to the Swap screen.

The diff itself is disciplined: no new `_buildFoo()` widget helpers were introduced, no new
plan/phase/sketch identifiers were added to source or test comments, every new/changed `if`
is braced, no hardcoded colors or new color pairings were introduced, `SDKAccountManagerButton`
and `AccountDropdownSelector` were fully deleted with no dangling references, and the mnemonic
continues to be read as a `build()`-local value only (never stored on a Bloc/Cubit state class,
never logged). The two selections ("Sending from" vs "Node running as") are wired through two
independent dispatch paths (`WalletDetailsCubit.selectWallet` vs `AppBloc.add(SelectSDKAccount)`)
and I could not find a code path where tapping one row mutates the other's selection.

Two real correctness gaps were found, both traced through to a concrete, currently-untested
scenario rather than a hypothetical, plus one test-coverage gap on the new Swap "Switch ›" link.
No BLOCKER-level issue (no wrong-signer bug, no leaked secret, no new insecure pattern) was found
in the reviewed diff.

## Warnings

### WR-01: A watch-only wallet sharing the linked wallet's address is mislabeled "ACTIVE ON NODE"

**File:** `lib/account/account_drawer.dart:582-585`

**Issue:** `isActiveOnNode` is computed by comparing **address only**:

```dart
isActiveOnNode:
    activeOnNode != null &&
    w.address.toLowerCase() ==
        activeOnNode.address.toLowerCase(),
```

`activeOnNode` comes from `AppBloc.linkedWallet(...)`, which explicitly excludes
`WalletType.tracking` and `WalletType.sgnus` when resolving the wallet an SDK account is linked
to (`app_bloc.dart:779-781`). But `ownWallets` (the list this badge is computed for) includes
**tracking** wallets — only `sgnus` is filtered out (`account_drawer.dart:539-541`). The
file's own `_matchesSelected` helper already guards against exactly this by comparing address
**and** `walletType` (with a comment explaining why: "an SDK row now carries its own wallet's
name, so two rows named alike would otherwise both light up") — but that same walletType check
was not applied here.

This codebase explicitly supports a watch-only (tracking) wallet sharing an address with an
owned wallet — see `test/components/wallet_identity_test.dart`'s "deleting the watch-only row of
a key wallet address keeps the key wallet selected" and "deleting a local wallet keeps a selected
SDK account that shares its address" tests, which pin this as a real, tested scenario elsewhere
in the app. Reached that way, this drawer would show **both** the owned wallet's row and its
watch-only twin badged "ACTIVE ON NODE" simultaneously, even though `walletSDKBadge` (a few lines
above) is explicit that "Tracking and sgnus wallets never carry one" — the ACTIVE ON NODE badge
contradicts that stated invariant for the tracking row. No fund-loss or wrong-signing risk (a
tracking wallet can never be selected as the active send/swap wallet), but it directly
misinforms the user about which wallet the node is processing on, which is exactly the kind of
"two selections should never cross-contaminate" bug this phase's own design brief calls out.

**Fix:** Match on `walletType` too, the same way `_matchesSelected` does:

```dart
isActiveOnNode:
    activeOnNode != null &&
    w.walletType == activeOnNode.walletType &&
    w.address.toLowerCase() == activeOnNode.address.toLowerCase(),
```

### WR-02: Swap's new "Sending from" line has no gate against a wallet that cannot actually sign

**File:** `lib/squid_router/swap_screen.dart:1136-1184` (`_SwapFromWallet`), `:453-565`
(`_submitSwap`) — contrast with `lib/send/send_screen.dart:50-60`

**Issue:** `send_screen.dart` refuses to render a form at all when the active wallet cannot sign:

```dart
if (wallet == null || network == null || !canSendFrom(wallet, network)) {
  return const Scaffold(body: SafeArea(child: GWEmptyState(...)));
}
```

`canSendFrom` (`lib/reown/utilities.dart:24-29`) excludes `WalletType.tracking` and
`WalletType.sgnus`. `SwapScreen` has no equivalent gate anywhere in the file (confirmed: no
occurrence of `WalletType.tracking`/`WalletType.sgnus`/`canSignOn` in
`lib/squid_router/swap_screen.dart`), and `WalletDetailsCubit.getCoins()` does not special-case
tracking wallets either, so a watch-only wallet's holdings load normally and the CTA ladder can
reach `SwapCtaState.ready` for it.

The new `_SwapFromWallet` widget's doc comment explicitly frames this line as "the same
wrong-account guard Send's review row carries" — but Send's guard is backed by an early refusal
(`canSendFrom`), while Swap's is only a label with no refusal behind it. Concretely: select a
watch-only or SGNUS wallet as the active wallet (reachable via this same phase's own "View
balance" menu item for the SGNUS case), and the Swap screen will happily show "Sending from
{name} · {address}" with an enabled gradient "Swap" button; tapping it drives real calls into
`api.approve`/`api.signAndSendTransaction` for an address the app holds no signing key for. This
does not put funds at risk of going to the wrong recipient (there is no key to sign with), but it
is a materially different, and materially weaker, guarantee than the one this exact code comment
claims to provide, and the failure the user sees will be whatever raw exception/rejection the API
layer produces rather than Send's friendly "This wallet can't sign a transaction on this network."

**Fix:** Gate `SwapScreen` the same way `SendScreen` does, e.g. add a `canSendFrom`-equivalent
check (or reuse `canSendFrom` itself) in `_SwapScreenState.build`/`_buildSwapContent` and refuse
early with the same `GWEmptyState` pattern, rather than only naming the wallet in
`_SwapFromWallet`.

## Info

### IN-01: The new "Switch ›" link's navigation is not exercised by any test

**File:** `test/squid_router/swap_submit_test.dart`

**Issue:** `swap_submit_test.dart`'s `_mountReady` harness provides only `WalletDetailsCubit` and
`TransactionsCubit` (no `AppBloc`). The new test group "names the wallet the swap will spend
from" asserts the `TextButton` labelled `'Switch ›'` exists, but never taps it. `_SwapFromWallet`'s
`onPressed` calls `AccountDrawer.show(context)`, whose child (`_AccountDrawerBody`) requires both
`WalletDetailsCubit` and `BlocBuilder<AppBloc, AppState>`. In production this is fine as long as
`AppBloc` is provided above every route that can host `/swap`, but nothing in this test suite
proves the link actually opens the switcher (as opposed to, say, silently failing a
`Provider.of` lookup or throwing on tap).

**Fix:** Add a case that taps `find.text('Switch ›')` (with `AppBloc` added to the harness) and
asserts the switcher drawer opens (e.g. `find.text('Accounts')` or `find.text('SENDING FROM')`),
mirroring the coverage the account-drawer test suite already has for every other entry point.

---

_Reviewed: 2026-09-29_
_Depth: standard_
