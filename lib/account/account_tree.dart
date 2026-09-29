import 'package:genius_api/genius_api.dart' show Wallet;
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet;
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;

/// What a row renders: a plain own wallet, an own wallet merged with its
/// linked SDK account, an unlinked or wallet-removed SDK account, or a child
/// the user does not own.
enum AccountRowKind { wallet, merged, account, foreignChild }

/// One row of the flattened account tree, in render order.
class AccountTreeRow {
  const AccountTreeRow({
    required this.kind,
    required this.depth,
    this.wallet,
    this.sdkAddress,
    this.parentMain,
    this.child,
    this.hasChildren = false,
  });

  final AccountRowKind kind;
  final int depth;

  /// Set for [AccountRowKind.wallet] and [AccountRowKind.merged] rows.
  final Wallet? wallet;

  /// Set for [AccountRowKind.merged] and [AccountRowKind.account] rows.
  final String? sdkAddress;

  /// Set for [AccountRowKind.foreignChild] rows: the main whose registrations
  /// named this child.
  final String? parentMain;

  /// Set for [AccountRowKind.foreignChild] rows.
  final ChildWallet? child;

  /// True when at least one row sits directly under this one.
  final bool hasChildren;
}

bool _sameWallet(Wallet a, Wallet b) =>
    a.walletType == b.walletType &&
    a.address.toLowerCase() == b.address.toLowerCase();

/// Flattens [wallets] and [sdkAccounts] (with their [registrations]) into
/// render order.
///
/// Own wallets (sgnus excluded) come first, in [wallets] order, each merged
/// onto the first SDK account in [sdkAccounts] order whose
/// `AppBloc.linkedWallet` resolves to it -- a tracking wallet never matches,
/// since [AppBloc.linkedWallet] never returns one, and a second account
/// linked to the same wallet stays unmerged. Any SDK account left unclaimed
/// follows as its own row.
///
/// Each root (a merged or unmerged account) then walks its own
/// [registrations] depth-first: an own child nests one level deeper and is
/// recursed into (rendering merged when it, too, is linked); a child that is
/// not one of the user's own accounts becomes a [AccountRowKind.foreignChild]
/// leaf. One visited set spans the whole walk, so a cycle, a self-listing or
/// a second main all stop at the first placement, and a wallet whose account
/// was already placed by nesting is not rendered again at the top level.
/// Null [registrations] (node down, or a failed read) means no root has
/// anything to walk, so every row lands at depth 0 in that same order.
List<AccountTreeRow> buildAccountTree({
  required List<Wallet> wallets,
  required List<String> sdkAccounts,
  required Map<String, SDKAccountLink> links,
  required Map<String, List<ChildWallet>>? registrations,
}) {
  final ownWallets = wallets
      .where((w) => w.walletType != WalletType.sgnus)
      .toList();
  final ownByLower = {
    for (final account in sdkAccounts) account.toLowerCase(): account,
  };

  // The first SDK account (in order) whose link resolves to each own
  // wallet -- one merge per account, first wallet wins a shared link.
  final mergedAccountForWallet = <int, String>{};
  final walletForAccount = <String, Wallet>{};
  for (var i = 0; i < ownWallets.length; i++) {
    final wallet = ownWallets[i];
    for (final account in sdkAccounts) {
      final lower = account.toLowerCase();
      if (walletForAccount.containsKey(lower)) {
        continue;
      }
      final linked = AppBloc.linkedWallet(account, links, wallets);
      if (linked != null && _sameWallet(linked, wallet)) {
        mergedAccountForWallet[i] = account;
        walletForAccount[lower] = wallet;
        break;
      }
    }
  }

  final visited = <String>{};
  final rows = <AccountTreeRow>[];

  void placeAccount(String account, int depth) {
    final lower = account.toLowerCase();
    if (visited.contains(lower)) {
      return;
    }
    visited.add(lower);
    final wallet = walletForAccount[lower];
    final rowIndex = rows.length;
    rows.add(
      AccountTreeRow(
        kind: wallet != null ? AccountRowKind.merged : AccountRowKind.account,
        depth: depth,
        sdkAddress: account,
        wallet: wallet,
      ),
    );

    var hasChildren = false;
    for (final entry in registrations?[lower] ?? const <ChildWallet>[]) {
      final childLower = entry.address.toLowerCase();
      final ownAccount = ownByLower[childLower];
      if (ownAccount != null) {
        if (visited.contains(childLower)) {
          continue;
        }
        hasChildren = true;
        placeAccount(ownAccount, depth + 1);
      } else {
        if (visited.contains(childLower)) {
          continue;
        }
        visited.add(childLower);
        hasChildren = true;
        rows.add(
          AccountTreeRow(
            kind: AccountRowKind.foreignChild,
            depth: depth + 1,
            parentMain: account,
            child: entry,
          ),
        );
      }
    }

    if (hasChildren) {
      rows[rowIndex] = AccountTreeRow(
        kind: rows[rowIndex].kind,
        depth: depth,
        sdkAddress: account,
        wallet: wallet,
        hasChildren: true,
      );
    }
  }

  for (var i = 0; i < ownWallets.length; i++) {
    final account = mergedAccountForWallet[i];
    if (account == null) {
      rows.add(
        AccountTreeRow(
          kind: AccountRowKind.wallet,
          depth: 0,
          wallet: ownWallets[i],
        ),
      );
      continue;
    }
    if (visited.contains(account.toLowerCase())) {
      // Already placed by an earlier root's nesting walk -- this wallet's
      // row IS that nested merged row, so it does not render twice.
      continue;
    }
    placeAccount(account, 0);
  }
  for (final account in sdkAccounts) {
    placeAccount(account, 0);
  }

  return rows;
}
