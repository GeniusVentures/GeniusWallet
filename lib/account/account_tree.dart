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

  /// The main whose registrations named this child -- set for every
  /// [AccountRowKind.foreignChild] row, and for an own ([merged]/[account])
  /// row nested at depth 1 or deeper.
  final String? parentMain;

  /// The registration entry this row was reached through -- set for every
  /// [AccountRowKind.foreignChild] row, and for a nested own row, so its menu
  /// can offer the same Fund/Recover/Revoke a foreign child's row does.
  final ChildWallet? child;

  /// True when at least one row sits directly under this one.
  final bool hasChildren;
}

bool _sameWallet(Wallet a, Wallet b) =>
    a.walletType == b.walletType &&
    a.address.toLowerCase() == b.address.toLowerCase();

/// Flattens wallets and SDK accounts into render order: each wallet merged
/// onto its linked account, own children nested depth-first under their main.
/// Every account is placed once, so cycles and second mains cannot repeat it.
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

  // An own account some other own account lists as a child waits for that
  // main to nest it, whatever order the wallets come in.
  final nestedUnderOwnMain = <String>{
    for (final entry
        in registrations?.entries ??
            const <MapEntry<String, List<ChildWallet>>>[])
      if (ownByLower.containsKey(entry.key.toLowerCase()))
        for (final child in entry.value)
          if (ownByLower.containsKey(child.address.toLowerCase()) &&
              child.address.toLowerCase() != entry.key.toLowerCase())
            child.address.toLowerCase(),
  };

  final visited = <String>{};
  final rows = <AccountTreeRow>[];

  void placeAccount(
    String account,
    int depth, {
    ChildWallet? childEntry,
    String? parentMain,
  }) {
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
        child: childEntry,
        parentMain: parentMain,
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
        placeAccount(
          ownAccount,
          depth + 1,
          childEntry: entry,
          parentMain: account,
        );
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
        child: childEntry,
        parentMain: parentMain,
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
    if (nestedUnderOwnMain.contains(account.toLowerCase())) {
      continue;
    }
    placeAccount(account, 0);
  }
  for (final account in sdkAccounts) {
    if (!nestedUnderOwnMain.contains(account.toLowerCase())) {
      placeAccount(account, 0);
    }
  }
  // A cycle leaves every member waiting on another; place what is left.
  for (final account in sdkAccounts) {
    placeAccount(account, 0);
  }

  return rows;
}

/// Filters [rows] for render, hiding every descendant of a main whose key
/// (lowercased [AccountTreeRow.sdkAddress]) is in [collapsedMains]. Relies on
/// [rows] being depth-first, so each collapsed subtree is contiguous.
List<AccountTreeRow> visibleAccountRows(
  List<AccountTreeRow> rows,
  Set<String> collapsedMains,
) {
  final visible = <AccountTreeRow>[];
  int? skipBelowDepth;
  for (final row in rows) {
    if (skipBelowDepth != null) {
      if (row.depth > skipBelowDepth) {
        continue;
      }
      skipBelowDepth = null;
    }
    visible.add(row);
    final key = row.sdkAddress?.toLowerCase();
    if (row.hasChildren && key != null && collapsedMains.contains(key)) {
      skipBelowDepth = row.depth;
    }
  }
  return visible;
}
