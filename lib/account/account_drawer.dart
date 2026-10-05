import 'dart:math' show min;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_tree.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operation_dialogs.dart'
    show startFund, startRecover, startRevoke;
import 'package:genius_wallet/child_wallets/child_operation_status.dart'
    show ChildOperationBadge;
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet;
import 'package:genius_wallet/child_wallets/child_wallets_screen.dart'
    show ChildWalletRow;
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/data/gw_row_badge.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/overlays/gw_menu_item.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dev/dev_flags.dart' show kShowDevTools;
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:local_secure_storage/local_secure_storage.dart'
    show SDKAccountLink;
import 'package:provider/provider.dart';

/// The account switcher: one "Accounts" list. Tapping a row selects it for
/// sends and swaps; running the node as it is a separate menu action -
/// changing one never touches the other.
class AccountDrawer {
  /// Opens the switcher and returns the picked wallet, selecting it via
  /// [WalletDetailsCubit] before returning - the entry itself selects the
  /// wallet, so no caller can forget to.
  static Future<Wallet?> show(
    BuildContext context, {
    bool includeNetwork = false,
  }) async {
    final walletCubit = context.read<WalletDetailsCubit>();

    // Read at the CALL SITE, before the route is pushed, and passed in as a
    // plain list. `ResponsiveDrawer.show` pushes on the root navigator, so a
    // provider read from inside the pushed route resolves against a different
    // subtree; this also makes the body a pure function of its inputs, which
    // is what lets a test seed it. Same shape `_showNetworkDrawer` already
    // uses, where `networks` is passed in rather than read from within.
    final networks = includeNetwork
        ? Provider.of<NetworkProvider>(context, listen: false).networks
        : const <Network>[];
    // Correct on a cold start with no new resolver: `app_bloc.dart:112-121`
    // resolves this from the same two Hive keys and seeds it through
    // `loadInitial` before the first frame.
    final currentNetwork = includeNetwork
        ? walletCubit.state.selectedNetwork
        : null;

    final selected = await ResponsiveDrawer.show<Wallet>(
      context: context,
      // Owns a scrolling viewport: the inset lives on the list so it scrolls
      // with the content and rows still reach the panel edge (kDrawerBodyPadding).
      bodyPadding: EdgeInsets.zero,
      title: includeNetwork ? "Wallet and network" : "Accounts",
      child: _AccountDrawerBody(
        networks: networks,
        currentNetwork: currentNetwork,
      ),
      // Inset removed: the shell supplies it now (kDrawerFooterPadding), and
      // its 20 replaces this file's hand-typed 16.
      // GWButton, not a raw `FilledButton.icon` with an inline fontSize 18 and
      // iconSize 28 (sketch 068-A). Gradient because adding a wallet is the
      // panel's only action and it is a commitment.
      footer: GWButton(
        label: 'Add wallet',
        leading: const Icon(Icons.add),
        variant: GWButtonVariant.gradient,
        size: GWButtonSize.sm,
        expand: true,
        onPressed: () => context.push('/landing_screen', extra: true),
      ),
    );

    if (selected == null) {
      return null;
    }

    await walletCubit.selectWallet(selected);

    return selected;
  }
}

/// Whether an own-wallet row has an SDK account, and if not, whether one is
/// still on its way.
enum WalletSDKBadge {
  /// Tracking and sgnus rows, or an own wallet the SDK is running without
  /// ever having linked.
  none,

  /// [links] holds an entry whose wallet address matches this one.
  linked,

  /// No link yet, but the SDK is not running to make one - not a permanent
  /// "no", just not yet.
  pending,
}

/// Resolves [wallet]'s badge from the link map. Tracking and sgnus
/// wallets never carry one - the SDK section already says which of THEM has
/// the link, via `sdk_account_manager.dart`'s row naming.
WalletSDKBadge walletSDKBadge(
  Wallet wallet,
  Map<String, SDKAccountLink> links, {
  required bool sdkRunning,
}) {
  if (wallet.walletType == WalletType.tracking ||
      wallet.walletType == WalletType.sgnus) {
    return WalletSDKBadge.none;
  }
  final address = wallet.address.toLowerCase();
  final isLinked = links.values.any((link) => link.walletAddress == address);
  if (isLinked) {
    return WalletSDKBadge.linked;
  }
  return sdkRunning ? WalletSDKBadge.none : WalletSDKBadge.pending;
}

/// The sgnus wallet [sdkAddress]'s "View balance" menu item selects, or null
/// when the SDK has none linked - the same lowercased-address match
/// [walletSDKBadge] uses.
Wallet? _sgnusWalletFor(String sdkAddress, List<Wallet> wallets) {
  final address = sdkAddress.toLowerCase();
  for (final wallet in wallets) {
    if (wallet.walletType == WalletType.sgnus &&
        wallet.address.toLowerCase() == address) {
      return wallet;
    }
  }
  return null;
}

/// The drawer's body: the row list plus the two confirm flows reachable from
/// each row's overflow menu. A `StatefulWidget` because the rename flow calls
/// `setState` and checks `mounted`.
class _AccountDrawerBody extends StatefulWidget {
  const _AccountDrawerBody({this.networks = const [], this.currentNetwork});

  /// Empty for every caller that does not ask for the network field, which
  /// is what makes the section vanish rather than render an empty header.
  final List<Network> networks;
  final Network? currentNetwork;

  @override
  State<_AccountDrawerBody> createState() => _AccountDrawerBodyState();
}

class _AccountDrawerBodyState extends State<_AccountDrawerBody> {
  // Seeded once from WalletDetailsCubit.state.selectedWallet - the same
  // value `selectWallet` writes, so the highlight cannot desync from the
  // selection. Kept as a local mirror (not re-read from the cubit on every
  // build) purely so the rename flow below can update it in place when a
  // rename touches the currently-selected wallet.
  Wallet? _selectedWallet;

  /// The last key [_registrations] was read for -- see [_updateRegistrations].
  Object? _registrationsKey;

  /// Every own account's registered children; null while the node is down
  /// with no dev preset armed, or after a failed read. Re-read only when
  /// [_updateRegistrations]'s key changes: each read is a costly FFI call.
  Map<String, List<ChildWallet>>? _registrations;

  /// Mains hidden by a chevron tap, keyed by lowercased `sdkAddress`. Lives
  /// for this open only -- a fresh `State` on the next open starts empty,
  /// i.e. every main expanded.
  final Set<String> _collapsedMains = {};

  @override
  void initState() {
    super.initState();
    if (kDebugMode && kShowDevTools) {
      // Removed in dispose() below, under the identical gate, so a listener
      // never outlives this State -- same idiom as ChildWalletsCubit's own
      // preset listener. Just a setState: the keyed read in build() already
      // picks up the new preset value once this repaints.
      DevMockChildWallets.instance.preset.addListener(_onPresetChanged);
    }
  }

  @override
  void dispose() {
    if (kDebugMode && kShowDevTools) {
      DevMockChildWallets.instance.preset.removeListener(_onPresetChanged);
    }
    super.dispose();
  }

  void _onPresetChanged() => setState(() {});

  void _toggleCollapse(String key) {
    setState(() {
      if (!_collapsedMains.remove(key)) {
        _collapsedMains.add(key);
      }
    });
  }

  void _updateRegistrations(
    AppState appState,
    ChildOperationsCubit? operations,
  ) {
    final key = (
      appState.selectedSDKAccount,
      appState.sdkAccounts.join(','),
      operations?.state,
      DevMockChildWallets.instance.preset.value,
      // Bloc state keeps the same list/map instance across an emit that
      // doesn't touch it, so identity here still catches a rename or a
      // link change without a per-build deep compare.
      appState.wallets,
      appState.sdkAccountLinks,
    );
    if (key == _registrationsKey) {
      return;
    }
    _registrationsKey = key;
    _registrations = operations?.ownRegistrations();
  }

  Future<void> _confirmRenameWallet(BuildContext context, Wallet wallet) async {
    final appBloc = context.read<AppBloc>();
    // Capture the ROOT navigator before closing the drawer: closing the drawer
    // deactivates `context`, so the dialog (pushed on the root navigator by
    // GWDialog.show) and its action pops must go through this stable
    // NavigatorState, not the now-defunct outer `context`.
    final navigator = Navigator.of(context, rootNavigator: true);
    // Close the drawer first so the dialog appears on the correct navigator.
    Navigator.of(context).pop();

    final controller = TextEditingController(text: wallet.walletName);
    final formKey = GlobalKey<FormState>();
    void submit() {
      if (formKey.currentState!.validate()) {
        navigator.pop(controller.text.trim());
      }
    }

    final newName = await GWDialog.show<String>(
      context: navigator.context,
      title: 'Rename Wallet',
      content: Form(
        key: formKey,
        child: GWTextField(
          controller: controller,
          label: 'Wallet name',
          autofocus: true,
          validator: walletNameError,
          onFieldSubmitted: (_) => submit(),
        ),
      ),
      actions: [
        GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop()),
        GWDialogAction(
          label: 'Rename',
          variant: GWButtonVariant.primary,
          onPressed: submit,
        ),
      ],
    );

    // Not gated on `mounted`: the drawer was popped above, so by the time the
    // user confirms this State is usually disposed and the rename would be lost.
    if (newName != null && newName.isNotEmpty && newName != wallet.walletName) {
      appBloc.add(RenameWallet(wallet.address, newName));
      if (mounted && wallet.address == _selectedWallet?.address) {
        setState(() {
          _selectedWallet = _selectedWallet!.copyWith(walletName: newName);
        });
      }
    }
  }

  Future<void> _confirmDeleteWallet(BuildContext context, Wallet wallet) async {
    final appBloc = context.read<AppBloc>();
    // Capture the ROOT navigator before closing the drawer: closing the drawer
    // deactivates `context`, so the dialog (pushed on the root navigator by
    // GWDialog.show) and its action pops must go through this stable
    // NavigatorState, not the now-defunct outer `context`.
    final navigator = Navigator.of(context, rootNavigator: true);
    // Close the drawer first so the dialog appears on the correct navigator.
    Navigator.of(context).pop();

    // Guard: at least one of the user's own wallets must remain; SDK accounts
    // do not count (the bloc enforces the same rule).
    if (!AppBloc.canDeleteWallet(
      appBloc.state.wallets,
      deletingWatchOnly: wallet.walletType == WalletType.tracking,
    )) {
      showToast(
        navigator.context,
        'You must keep at least one wallet.',
        type: ToastType.warning,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // This is a PURE re-skin of develop's existing confirmation dialog
    // (D-06 resolved to "already confirms" -- the sanctioned-exception
    // clause does NOT fire). Copy is preserved verbatim.
    final confirmed = await GWDialog.show<bool>(
      context: navigator.context,
      title: 'Delete wallet',
      // No `\n\n`. GWDialog owns the vertical rhythm - space4 title→message,
      // space8 →content, space10 →actions - and a hand-typed double break
      // inside the string opened a gap wider than any of them, which is why
      // this dialog read as spaced differently from every other one. Two
      // sentences, one paragraph; the component does the spacing.
      message:
          'This removes "${wallet.walletName}" from the app. If you have no '
          'copy of its recovery phrase, the wallet cannot be restored.',
      actions: [
        GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop(false)),
        GWDialogAction(
          label: 'Delete',
          // Mode-invariant statusError destructive fill -- never
          // Colors.red/redAccent, never routed through GWColors.
          variant: GWButtonVariant.destructive,
          onPressed: () => navigator.pop(true),
        ),
      ],
    );

    // Not gated on `mounted`: the drawer was popped above, so by the time the
    // user confirms this State is usually disposed and the delete would be
    // lost. AppBloc selects the replacement wallet when this one was selected.
    if (confirmed == true) {
      appBloc.add(
        DeleteWallet(
          wallet.address,
          watchOnly: wallet.walletType == WalletType.tracking,
        ),
      );
    }
  }

  /// True when [wallet] is the selected row. Matched on lowercased address
  /// AND wallet type, not name: an SDK row carries its wallet's name, so two
  /// rows named alike would otherwise both light up.
  bool _matchesSelected(Wallet wallet) {
    final selected = _selectedWallet;
    if (selected == null) {
      return false;
    }
    return wallet.address.toLowerCase() == selected.address.toLowerCase() &&
        wallet.walletType == selected.walletType;
  }

  /// True when [network] is the one the app is currently reading balances
  /// from. Matched on `chainId` AND `rpcUrl` because `networks.json` ships
  /// mainnet/testnet pairs that share neither reliably on their own.
  bool _isCurrent(Network network) =>
      network.chainId == widget.currentNetwork?.chainId &&
      network.rpcUrl == widget.currentNetwork?.rpcUrl;

  void _selectNetwork(BuildContext context, Network network) {
    // Already there: no emit, no Hive write, and above all no toast
    // announcing a switch that did not happen.
    if (_isCurrent(network)) {
      return;
    }

    // Capture the ROOT navigator BEFORE popping, exactly as the two confirm
    // flows above do: popping deactivates `context`, and the toast needs a
    // context that still resolves an Overlay afterwards.
    final navigator = Navigator.of(context, rootNavigator: true);
    final walletCubit = context.read<WalletDetailsCubit>();
    Navigator.of(context).pop();

    NetworkSelection.apply(
      context: navigator.context,
      walletCubit: walletCubit,
      network: network,
    );
  }

  Future<void> _pickNetwork(BuildContext context) async {
    final picked = await NetworkPicker.show(
      context,
      networks: widget.networks,
      current: widget.currentNetwork,
    );
    if (picked == null || !context.mounted) {
      return;
    }
    _selectNetwork(context, picked);
  }

  /// True when [row]'s target (its own wallet, or its account's sgnus
  /// wallet, the one "View balance" opens) is the active wallet. Never
  /// compared against the SDK selection.
  bool _rowSelected(AccountTreeRow row, List<Wallet> wallets) {
    final target =
        row.wallet ??
        (row.sdkAddress != null
            ? _sgnusWalletFor(row.sdkAddress!, wallets)
            : null);
    return target != null && _matchesSelected(target);
  }

  bool _rowOnNode(AccountTreeRow row, String? runningAccount) =>
      row.sdkAddress != null &&
      runningAccount != null &&
      row.sdkAddress!.toLowerCase() == runningAccount.toLowerCase();

  bool _rowIsStart(AccountTreeRow row, String? defaultAccountLower) =>
      row.sdkAddress != null &&
      defaultAccountLower != null &&
      row.sdkAddress!.toLowerCase() == defaultAccountLower;

  @override
  Widget build(BuildContext context) {
    // Read it instead from WalletDetailsCubit.state.selectedWallet - the
    // cubit is the same value `selectWallet` writes, so the highlight cannot
    // desync from the selection. See the field doc above for why this is
    // seeded once rather than watched.
    _selectedWallet ??= context.read<WalletDetailsCubit>().state.selectedWallet;

    // Nullable: the registry is provided once, at the app root, above the
    // router -- a host that never wires it (an older test harness, a screen
    // outside that subtree) simply has nothing pending to lock.
    final operations = context.watch<ChildOperationsCubit?>();

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        _updateRegistrations(appState, operations);
        final defaultAccount = appState.defaultSDKAccount?.toLowerCase();
        // A pending child operation submitted from the running account locks
        // every OTHER row's "Earn with this account" -- selecting a wallet for
        // sends/swaps is never touched by this.
        final running = appState.selectedSDKAccount;
        final switching = appState.switchingSDKAccount;
        final lockedReason =
            operations != null &&
                running != null &&
                operations.hasPendingFrom(running)
            ? 'Waiting for a child operation from ${operations.labelFor(running)} '
                  'to confirm'
            : null;
        // One tree, one row per account: each own wallet, its merged SDK
        // account when it has one, and any unlinked or wallet-removed
        // account, in render order.
        final treeRows = buildAccountTree(
          wallets: appState.wallets,
          sdkAccounts: appState.sdkAccounts,
          links: appState.sdkAccountLinks,
          registrations: _registrations,
        );
        // Full tree for the empty check and for indenting by its real
        // depth; filtered only for what actually renders, so collapsing a
        // main never changes what "No wallets yet." means.
        final visibleRows = visibleAccountRows(treeRows, _collapsedMains);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            GeniusWalletConsts.space10 / 2,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
            GeniusWalletConsts.space10,
          ),
          children: [
            // The network field, when this sheet was opened as the combined
            // wallet-and-network surface. One field rather than a list, so the
            // user's own wallets stay above the fold; it opens the same
            // searchable, Mainnet/Testnet picker the desktop selector uses.
            if (widget.networks.isNotEmpty) ...[
              const _AccountSectionHeader(
                title: 'Network',
                caption: 'Which chain the balances below are read from.',
              ),
              NetworkSelectField(
                network: widget.currentNetwork,
                onTap: () => _pickNetwork(context),
              ),
              const SizedBox(height: GeniusWalletConsts.space8),
            ],
            // The drawer's own title already says "Accounts" when there is
            // no Network section above to tell apart.
            _AccountSectionHeader(
              title: widget.networks.isNotEmpty ? 'Accounts' : null,
              caption:
                  'Tap an account to use it as your wallet for transfers and '
                  'swaps. Use its menu to earn with it.',
            ),
            if (treeRows.isEmpty)
              const _AccountSectionNote(text: 'No wallets yet.'),
            ...visibleRows.map(
              (row) => Padding(
                padding: EdgeInsets.only(
                  left: min(row.depth, 2) * GeniusWalletConsts.space6,
                ),
                child: row.kind == AccountRowKind.foreignChild
                    ? ChildWalletRow(
                        wallet: row.child!,
                        mainAddress: row.parentMain!,
                      )
                    : _AccountRowTile(
                        row: row,
                        selected: _rowSelected(row, appState.wallets),
                        // The pending target says so instead of Earning, even
                        // if a read already names it, until the switch settles.
                        switching: _rowOnNode(row, switching),
                        switchPending: switching != null,
                        onNode:
                            !_rowOnNode(row, switching) &&
                            _rowOnNode(row, running),
                        isStartAccount: _rowIsStart(row, defaultAccount),
                        sdkBadge: row.kind == AccountRowKind.wallet
                            ? walletSDKBadge(
                                row.wallet!,
                                appState.sdkAccountLinks,
                                sdkRunning: appState.defaultSDKAccount != null,
                              )
                            : WalletSDKBadge.none,
                        balanceWallet: row.sdkAddress != null
                            ? _sgnusWalletFor(row.sdkAddress!, appState.wallets)
                            : null,
                        lockedReason: lockedReason,
                        registrations: _registrations,
                        onRename: _confirmRenameWallet,
                        onDeleteWallet: _confirmDeleteWallet,
                        expanded: row.hasChildren
                            ? !_collapsedMains.contains(
                                row.sdkAddress!.toLowerCase(),
                              )
                            : null,
                        onToggle: row.hasChildren
                            ? () =>
                                  _toggleCollapse(row.sdkAddress!.toLowerCase())
                            : null,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One row of the "Accounts" tree: an own wallet, one merged with its
/// linked SDK account, or an unlinked SDK account ([ChildWalletRow] draws
/// children). The mnemonic is read only for the on-node row, never stored.
class _AccountRowTile extends StatelessWidget {
  const _AccountRowTile({
    required this.row,
    required this.selected,
    required this.onNode,
    required this.switching,
    required this.switchPending,
    required this.isStartAccount,
    required this.sdkBadge,
    required this.balanceWallet,
    required this.lockedReason,
    required this.registrations,
    required this.onRename,
    required this.onDeleteWallet,
    required this.expanded,
    required this.onToggle,
  });

  final AccountTreeRow row;
  final bool selected;
  final bool onNode;

  /// The node was asked to run as this row and has not confirmed it yet.
  final bool switching;

  /// Any earning switch is still in flight, so the node's account may not
  /// match any row's tag yet.
  final bool switchPending;
  final bool isStartAccount;
  final WalletSDKBadge sdkBadge;

  /// The linked sgnus wallet this row's "View balance" menu item selects, or
  /// null when the account has none. Only set for merged/account rows.
  final Wallet? balanceWallet;

  /// Non-null while a child operation submitted from the running account is
  /// still pending -- "Earn with this account" refuses every row but the running
  /// one with this as the reason. Never locks a row tap.
  final String? lockedReason;

  /// The drawer's cached [ChildOperationsCubit.ownRegistrations] read.
  final Map<String, List<ChildWallet>>? registrations;

  final void Function(BuildContext context, Wallet wallet) onRename;
  final void Function(BuildContext context, Wallet wallet) onDeleteWallet;

  /// Null for a leaf (no chevron at all); otherwise whether this main's
  /// children currently show.
  final bool? expanded;

  /// Flips [expanded]. Null exactly when [expanded] is null.
  final VoidCallback? onToggle;

  /// True only for a row carrying an SDK account that is not the one
  /// currently running -- the one condition "Earn with this account" refuses.
  bool get _locked => row.sdkAddress != null && lockedReason != null && !onNode;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this row to rebuild on a live appearance toggle while the drawer stays
    // open.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final appBloc = context.read<AppBloc>();
    // Nullable for the same reason the drawer body's own read is: a host
    // that never provides the registry has nothing pending to lock or show.
    final operations = context.watch<ChildOperationsCubit?>();
    final wallet = row.wallet;
    final sdkAddress = row.sdkAddress;
    final isWatched = wallet?.walletType == WalletType.tracking;
    final locked = _locked;
    // A nested own account is reached only through another main's
    // registrations, so depth >= 1 with a child entry is exactly that case --
    // a top-level row never carries one.
    final isNestedOwn = row.depth >= 1 && row.child != null;
    final pendingOps = isNestedOwn && operations != null
        ? operations.operationsFor(sdkAddress!)
        : const <ChildOperation>[];

    final title = wallet != null
        ? wallet.walletName
        : AppBloc.sdkAccountName(
            sdkAddress!,
            appBloc.state.sdkAccountLinks,
            appBloc.state.wallets,
          );
    final addressText = wallet?.address ?? sdkAddress!;
    final anyTag =
        selected ||
        onNode ||
        switching ||
        (sdkBadge != WalletSDKBadge.none && !onNode);

    final tile = GWSelectRow(
      selected: selected,
      // Tapping any row picks it for sends/swaps -- never the node account.
      // An account row with no linked sgnus wallet yet is a no-op.
      onTap: () {
        final target =
            wallet ??
            (sdkAddress != null
                ? _sgnusWalletFor(sdkAddress, appBloc.state.wallets)
                : null);
        if (target != null) {
          Navigator.of(context).pop(target);
        }
      },
      leading: _RowLeading(
        wallet: wallet,
        selected: selected,
        onNode: onNode,
        locked: locked,
        expanded: expanded,
        onToggle: onToggle,
      ),
      title: title,
      titleStyle: locked
          ? GeniusWalletTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              // 80%, not 70% -- a locked row can also be selected, and the
              // selection tint behind it eats into the 3:1 floor 70% only
              // clears on the bare panel background.
              color: gw.textSecondary.withValues(alpha: 0.8),
            )
          : null,
      subtitle:
          WalletUtils.getAddressForDisplay(addressText) +
          (isStartAccount ? ' · Default account' : ''),
      subtitleStyle: GeniusWalletTypography.labelMd.copyWith(
        fontFamily: GeniusWalletTypography.monoFamily,
        color: locked
            ? gw.textSecondary.withValues(alpha: 0.8)
            : gw.textSecondary,
      ),
      titleTrailing: anyTag
          ? Wrap(
              spacing: GeniusWalletConsts.space3,
              runSpacing: GeniusWalletConsts.space2,
              children: [
                // A plain wallet's link status drops once Earning shows (a row
                // on node is always linked), and "Setting up" drops beside
                // Selected so two long labels never crowd out the name.
                if (row.kind == AccountRowKind.wallet &&
                    sdkBadge != WalletSDKBadge.none &&
                    !onNode &&
                    !(selected && sdkBadge == WalletSDKBadge.pending))
                  GWRowBadge(
                    label: sdkBadge == WalletSDKBadge.linked
                        ? 'Can earn'
                        : 'Setting up',
                    color: sdkBadge == WalletSDKBadge.linked
                        ? gw.brandPrimaryBadgeText
                        : gw.statusWarningText,
                  ),
                if (selected)
                  GWRowBadge(
                    label: 'Selected',
                    color: gw.brandPrimaryBadgeText,
                  ),
                if (onNode)
                  GWRowBadge(label: 'Earning', color: gw.statusSuccessText),
                if (switching)
                  GWRowBadge(label: 'Switching…', color: gw.statusWarningText),
              ],
            )
          : null,
      // An account row with no wallet of its own shows no balance here;
      // "View balance" is its menu's own item.
      subtitleTrailing: wallet != null
          ? Text(
              WalletUtils.formatMinions(wallet.balance),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            )
          : null,
      trailing: isWatched || locked
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWatched)
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: gw.textSecondary,
                  ),
                if (isWatched && locked)
                  const SizedBox(width: GeniusWalletConsts.space3),
                if (locked)
                  Icon(Icons.lock_outline, size: 14, color: gw.textSecondary),
              ],
            )
          : null,
      action: row.kind == AccountRowKind.wallet && wallet!.address.isEmpty
          ? null
          : _RowMenu(tile: this, operations: operations),
    );

    final result = locked ? Tooltip(message: lockedReason, child: tile) : tile;
    if (pendingOps.isEmpty) {
      return result;
    }
    // Under the tile, inside the same indent: the outer Padding this row
    // already sits in (account_drawer.dart's ListView) applies to this whole
    // Column, not just the tile above.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        result,
        Padding(
          padding: const EdgeInsets.only(
            left: GeniusWalletConsts.space6,
            bottom: GeniusWalletConsts.space4,
          ),
          child: Wrap(
            spacing: GeniusWalletConsts.space2,
            runSpacing: GeniusWalletConsts.space2,
            children: [
              for (final op in pendingOps)
                ChildOperationBadge(
                  op: op,
                  labelFor: operations!.labelFor,
                  onCheckAgain: operations.resolve,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The wallet avatar, shared by this drawer's rows and the desktop chip - a
/// public widget rather than a `_buildFoo()` helper, per the house rule.
///
/// `isSelected` is accepted for parity with the pre-extraction signature but
/// unused in the body, exactly as it was before this move.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({
    super.key,
    required this.wallet,
    required this.isSelected,
    required this.size,
    this.networkIconPath,
  });

  final Wallet wallet;
  final bool isSelected;
  final double size;

  /// Optional network badge, for the phone header's wallet pill.
  ///
  /// Defaults to null, and when it is null this widget returns TODAY'S EXACT
  /// `CircleAvatar` with no `Stack` and no wrapper. The drawer rows above pass
  /// nothing and must not change by a pixel; that is the whole contract of
  /// this parameter.
  final String? networkIconPath;

  @override
  Widget build(BuildContext context) {
    final isWatched = wallet.walletType == WalletType.tracking;
    final avatar = CircleAvatar(
      radius: size / 2 - 2,
      backgroundColor: context.gw.brandPrimaryStrong,
      child: isWatched
          ? Icon(
              Icons.remove_red_eye_outlined,
              size: 20,
              color: context.gw.textOnBrand,
            )
          : Image.asset(
              'assets/images/crypto/${wallet.currencySymbol.toLowerCase()}.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
    );

    if (networkIconPath == null) {
      return avatar;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(child: avatar),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              // A 2px ring of the bar colour. This is a STROKE, not layout
              // spacing, so it does not owe the 4-pt grid anything - the same
              // reasoning `GWControlTrack`'s `EdgeInsets.all(3)` well padding
              // already rests on. A 4px ring on a 16px badge would leave an
              // 8px icon, which is below the point of drawing a network icon
              // at all.
              //
              // The ring does real work: it measures 3.35:1 against Base
              // (#0052FF) and 3.66:1 against Polygon (#8247E5), so the badge
              // is separated from both the avatar beneath it and the bar
              // behind it by an edge that clears 1.4.11 on its own.
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: context.gw.surfaceElevated,
                shape: BoxShape.circle,
              ),
              // Decorative, deliberately. The badge is a change-detector -
              // "the chain moved" - and is not asked to be an identifier. The
              // chain is NAMED in the pill's accessible label at zero taps and
              // as chip text at one.
              child: ClipOval(
                child: Image.asset(
                  networkIconPath!,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A section label plus one sentence of explanation, above a group of account
/// rows.
///
/// A `StatelessWidget` rather than a `_buildHeader()` helper: AGENTS.md's rule,
/// and the practical half of it applies here - this is `const`-constructible at
/// both call sites, which a helper method never is.
class _AccountSectionHeader extends StatelessWidget {
  const _AccountSectionHeader({this.title, required this.caption});

  final String? title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read registering the InheritedWidget dependency, so a live
    // appearance toggle repaints this while the drawer stays open (04-02 D-02).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space4,
        GeniusWalletConsts.space4,
        GeniusWalletConsts.space4,
        GeniusWalletConsts.space6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!.toUpperCase(),
              style: GeniusWalletTypography.labelMd.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: gw.textSecondary,
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space2),
          ],
          Text(
            caption,
            // textPrimary80, not textPrimary38: this sentence is the only place
            // the app ever explains what an SDK account IS. 12.4:1 against the
            // panel, where 38% would have been 3.5:1 and unreadable.
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textPrimary80,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stands in for a section's rows when it has none.
class _AccountSectionNote extends StatelessWidget {
  const _AccountSectionNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GeniusWalletConsts.space10),
      decoration: BoxDecoration(
        color: gw.surfaceSunken,
        border: Border.all(color: gw.borderSubtle),
        borderRadius: BorderRadius.circular(
          GeniusWalletConsts.borderRadiusCard,
        ),
      ),
      child: Text(
        text,
        style: GeniusWalletTypography.bodySm.copyWith(color: gw.textPrimary80),
      ),
    );
  }
}

/// The avatar, or an account icon, with a chevron ahead of it on a main. A
/// leaf has no chevron at all, so its left edge does not move.
class _RowLeading extends StatelessWidget {
  const _RowLeading({
    required this.wallet,
    required this.selected,
    required this.onNode,
    required this.locked,
    required this.expanded,
    required this.onToggle,
  });

  final Wallet? wallet;
  final bool selected;
  final bool onNode;
  final bool locked;
  final bool? expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final wallet = this.wallet;
    final content = wallet != null
        ? AccountAvatar(wallet: wallet, isSelected: selected, size: 36)
        : Icon(
            Icons.account_balance_wallet,
            size: 20,
            color: locked
                ? gw.textSecondary.withValues(alpha: 0.8)
                : (onNode ? gw.brandPrimaryStrong : gw.textSecondary),
          );
    final isExpanded = expanded;
    if (isExpanded == null) {
      return content;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isExpanded ? Icons.expand_more : Icons.chevron_right,
            size: 18,
          ),
          iconSize: 18,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          padding: EdgeInsets.zero,
          color: gw.textSecondary,
          tooltip: isExpanded ? 'Hide children' : 'Show children',
          onPressed: onToggle,
        ),
        const SizedBox(width: GeniusWalletConsts.space2),
        content,
      ],
    );
  }
}

/// The row's options menu: wallet rows copy, rename and delete; rows with an
/// SDK account add earning, phrase and child items, and Fund, Recover and
/// Revoke when nested under another own main.
class _RowMenu extends StatelessWidget {
  const _RowMenu({required this.tile, required this.operations});

  final _AccountRowTile tile;
  final ChildOperationsCubit? operations;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final appBloc = context.read<AppBloc>();
    // No local `MenuStyle` -- see `theme.dart`'s menuTheme/menuButtonTheme.
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        icon: Icon(Icons.more_vert, size: 20, color: gw.textSecondary),
        tooltip: 'Account options',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: _items(context, gw, appBloc),
    );
  }

  List<Widget> _items(BuildContext context, GWColors gw, AppBloc appBloc) {
    final operations = this.operations;
    final row = tile.row;
    final wallet = row.wallet;
    if (row.kind == AccountRowKind.wallet) {
      final own = wallet!;
      return [
        GWMenuItem(
          icon: Icons.copy,
          label: 'Copy address',
          onPressed: () => _copyAddress(context, own.address),
        ),
        GWMenuItem(
          icon: Icons.edit_outlined,
          label: 'Rename',
          onPressed: () => tile.onRename(context, own),
        ),
        GWMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          color: gw.statusErrorText,
          onPressed: () => tile.onDeleteWallet(context, own),
        ),
      ];
    }

    // merged or account: every row carrying an SDK account.
    final sdkAddress = row.sdkAddress!;
    // The SDK only exposes the running account's phrase, and mid-switch that
    // may already be another row's, so nothing account-bound is offered then.
    final settled = tile.onNode && !tile.switchPending;
    // The phrase is read only when Copy or Show is tapped, never on build.
    final can = sdkRowActions(
      isSelected: settled,
      hasMnemonic: true,
      isStartAccount: tile.isStartAccount,
    );
    final deleteLock = tile.switchPending
        ? 'Wait for the earning switch to finish'
        : operations?.deleteLockReason(sdkAddress, tile.registrations);

    return [
      GWMenuItem(
        icon: Icons.dns_outlined,
        label: 'Earn with this account',
        lockedReason: tile._locked
            ? tile.lockedReason
            : (tile.switchPending && !tile.onNode && !tile.switching
                  ? 'Wait for the earning switch to finish'
                  : null),
        onPressed:
            tile.onNode || tile.switching || tile.switchPending || tile._locked
            ? null
            : () {
                context.read<AppBloc>().add(SelectSDKAccount(sdkAddress));
                showToast(
                  context,
                  'Switching earning…',
                  duration: const Duration(seconds: 1),
                );
              },
      ),
      GWMenuItem(
        icon: Icons.copy,
        label: 'Copy address',
        onPressed: () => _copyAddress(context, wallet?.address ?? sdkAddress),
      ),
      if (row.kind == AccountRowKind.merged)
        GWMenuItem(
          icon: Icons.edit_outlined,
          label: 'Rename',
          onPressed: () => tile.onRename(context, wallet!),
        ),
      GWMenuItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'View balance',
        onPressed: tile.balanceWallet != null
            ? () => Navigator.of(context).pop(tile.balanceWallet)
            : null,
      ),
      GWMenuItem(
        icon: Icons.edit_location_alt,
        label: 'Set payout address',
        onPressed: can.payout
            ? () => showSetPayoutAddressDialog(context)
            : null,
      ),
      GWMenuItem(
        icon: Icons.numbers,
        label: 'Copy recovery phrase',
        onPressed: can.phrase
            ? () {
                final mnemonic = appBloc.selectedAccountMnemonic();
                if (mnemonic == null) {
                  showToast(context, 'This account has no recovery phrase');
                  return;
                }
                copyRecoveryPhrase(context, mnemonic);
              }
            : null,
      ),
      GWMenuItem(
        icon: Icons.qr_code,
        label: 'Show recovery QR',
        onPressed: can.qr
            ? () {
                final mnemonic = appBloc.selectedAccountMnemonic();
                if (mnemonic == null) {
                  showToast(context, 'This account has no recovery phrase');
                  return;
                }
                showRecoveryQr(context, mnemonic);
              }
            : null,
      ),
      GWMenuItem(
        icon: Icons.account_tree,
        label: 'Child wallets',
        onPressed: can.childWallets
            ? () {
                final router = GoRouter.of(context);
                Navigator.of(context).pop();
                router.push('/child-wallets', extra: sdkAddress);
              }
            : null,
      ),
      const Divider(height: 9, indent: 12, endIndent: 12),
      if (row.kind == AccountRowKind.merged)
        GWMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete wallet',
          color: gw.statusErrorText,
          onPressed: () => tile.onDeleteWallet(context, wallet!),
        ),
      GWMenuItem(
        icon: Icons.delete_outline,
        label: 'Delete account',
        color: gw.statusErrorText,
        lockedReason: deleteLock,
        onPressed: !tile.onNode && can.delete && deleteLock == null
            ? () => confirmDeleteSDKAccount(context, sdkAddress)
            : null,
      ),
      // Nested under another own main: the kind's own items above are
      // unchanged by depth, and every other child of this same main gets the
      // identical block -- only one `startRevoke(` call site in this file.
      if (row.depth >= 1 && row.child != null && operations != null) ...[
        const Divider(height: 9, indent: 12, endIndent: 12),
        GWMenuItem(
          icon: Icons.arrow_upward,
          label: 'Fund',
          lockedReason: operations.lockReason(sdkAddress),
          onPressed: operations.lockReason(sdkAddress) != null
              ? null
              : () => startFund(
                  context,
                  child: row.child!,
                  mainAddress: row.parentMain!,
                ),
        ),
        GWMenuItem(
          icon: Icons.arrow_downward,
          label: 'Recover',
          lockedReason: operations.lockReason(sdkAddress),
          onPressed: operations.lockReason(sdkAddress) != null
              ? null
              : () => startRecover(
                  context,
                  child: row.child!,
                  mainAddress: row.parentMain!,
                ),
        ),
        GWMenuItem(
          icon: Icons.link_off,
          label: 'Revoke',
          lockedReason: operations.lockReason(sdkAddress),
          color: gw.statusErrorText,
          onPressed: operations.lockReason(sdkAddress) != null
              ? null
              : () => startRevoke(
                  context,
                  child: row.child!,
                  mainAddress: row.parentMain!,
                ),
        ),
      ],
    ];
  }

  void _copyAddress(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
    showToast(
      context,
      'Address copied to clipboard',
      duration: const Duration(seconds: 1),
    );
  }
}
