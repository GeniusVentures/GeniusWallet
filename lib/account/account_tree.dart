import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet;

/// Whether a row is one of the user's own SDK accounts, or a leaf the user
/// does not own.
enum AccountRowKind { account, foreignChild }

/// One row of the flattened account tree, in render order.
class AccountTreeRow {
  const AccountTreeRow({
    required this.kind,
    required this.depth,
    this.sdkAddress,
    this.parentMain,
    this.child,
    this.hasChildren = false,
  });

  final AccountRowKind kind;
  final int depth;

  /// Set for [AccountRowKind.account] rows.
  final String? sdkAddress;

  /// Set for [AccountRowKind.foreignChild] rows: the main whose registrations
  /// named this child.
  final String? parentMain;

  /// Set for [AccountRowKind.foreignChild] rows.
  final ChildWallet? child;

  /// True when at least one row sits directly under this one.
  final bool hasChildren;
}

/// Flattens [sdkAccounts] and their [registrations] into render order.
///
/// Null [registrations] (node down, or a failed read): one depth-0 row per
/// account, in [sdkAccounts] order, no nesting.
///
/// Otherwise, walks each unclaimed own account depth-first through its
/// registrations: an own child nests one level deeper and is recursed into;
/// a child that is not one of the user's own accounts becomes a
/// [AccountRowKind.foreignChild] leaf. One visited set spans the whole walk,
/// so a cycle, a self-listing or a second main all stop at the first
/// placement -- the row never duplicates and the walk always terminates. An
/// own account no main ever lists becomes a root, in [sdkAccounts] order.
List<AccountTreeRow> buildAccountTree({
  required List<String> sdkAccounts,
  required Map<String, List<ChildWallet>>? registrations,
}) {
  if (registrations == null) {
    return [
      for (final account in sdkAccounts)
        AccountTreeRow(
          kind: AccountRowKind.account,
          depth: 0,
          sdkAddress: account,
        ),
    ];
  }

  final ownByLower = {
    for (final account in sdkAccounts) account.toLowerCase(): account,
  };
  final visited = <String>{};
  final rows = <AccountTreeRow>[];

  void walk(String account, int depth) {
    final lower = account.toLowerCase();
    if (visited.contains(lower)) {
      return;
    }
    visited.add(lower);
    final rowIndex = rows.length;
    rows.add(
      AccountTreeRow(
        kind: AccountRowKind.account,
        depth: depth,
        sdkAddress: account,
      ),
    );

    var hasChildren = false;
    for (final entry in registrations[lower] ?? const <ChildWallet>[]) {
      final childLower = entry.address.toLowerCase();
      final ownAccount = ownByLower[childLower];
      if (ownAccount != null) {
        if (visited.contains(childLower)) {
          continue;
        }
        hasChildren = true;
        walk(ownAccount, depth + 1);
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
        kind: AccountRowKind.account,
        depth: depth,
        sdkAddress: account,
        hasChildren: true,
      );
    }
  }

  for (final account in sdkAccounts) {
    walk(account, 0);
  }

  return rows;
}
