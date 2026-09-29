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
        size: GWButtonSize.lg,
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

  /// Every own account's registered children, or null while the node is down
  /// and no dev preset is armed, or a read failed. Read once per open and
  /// again only when [_updateRegistrations]'s key actually changes, never on
  /// every rebuild -- an FFI call per own account is too costly to repeat on
  /// every frame this drawer paints.
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

  /// True when [wallet] is the row highlighted as selected. Matched on
  /// lowercased address AND wallet type, not name - an SDK row now carries
  /// its own wallet's name, so two rows named alike would otherwise
  /// both light up.
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

  /// True when [row]'s selection target (its own wallet, or its account's
  /// sgnus wallet) matches the active wallet -- never the SDK selection: a
  /// wallet-kind row IS its wallet, a merged row's identity is still its
  /// wallet, and an account row's identity is the sgnus wallet its menu's
  /// "View balance" already resolves.
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
        // every OTHER row's "Run node as this" -- selecting a wallet for
        // sends/swaps is never touched by this.
        final running = appState.selectedSDKAccount;
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
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
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
            const _AccountSectionHeader(
              title: 'Accounts',
              caption:
                  'Tap to send, swap and see balances from an account. Use '
                  'the menu to run the node as one.',
            ),
            // Registrations could not be read (node down, or the read
            // failed) -- the list below still renders, flat, with this as
            // the one honest note rather than a second, silently-empty
            // section.
            if (_registrations == null)
              const _AccountSectionNote(
                text: 'Child wallets show while the node is running.',
              ),
            if (treeRows.isEmpty)
              const _AccountSectionNote(text: 'No wallets yet.'),
            ...visibleRows.map(
              (row) => Padding(
                padding: EdgeInsets.only(
                  left: min(row.depth, 2) * GeniusWalletConsts.space12,
                ),
                child: row.kind == AccountRowKind.foreignChild
                    ? ChildWalletRow(
                        wallet: row.child!,
                        mainAddress: row.parentMain!,
                      )
                    : _AccountRowTile(
                        row: row,
                        selected: _rowSelected(row, appState.wallets),
                        onNode: _rowOnNode(row, running),
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
            const SizedBox(height: GeniusWalletConsts.space8),
            Align(
              alignment: Alignment.centerLeft,
              child: GWButton(
                label: 'Add from phrase or key',
                variant: GWButtonVariant.secondary,
                size: GWButtonSize.sm,
                onPressed: () => showAddSdkAccountDialog(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One row of the merged "Accounts" tree: a plain own wallet, an own wallet
/// merged with its linked SDK account, or an unlinked/wallet-removed SDK
/// account. A foreign child never reaches this widget - it renders as a
/// [ChildWalletRow] instead. The mnemonic it reads stays a build-local, never
/// a field, and only for the row that is actually on node.
class _AccountRowTile extends StatelessWidget {
  const _AccountRowTile({
    required this.row,
    required this.selected,
    required this.onNode,
    required this.isStartAccount,
    required this.sdkBadge,
    required this.balanceWallet,
    required this.lockedReason,
    required this.onRename,
    required this.onDeleteWallet,
    required this.expanded,
    required this.onToggle,
  });

  final AccountTreeRow row;
  final bool selected;
  final bool onNode;
  final bool isStartAccount;
  final WalletSDKBadge sdkBadge;

  /// The linked sgnus wallet this row's "View balance" menu item selects, or
  /// null when the account has none. Only set for merged/account rows.
  final Wallet? balanceWallet;

  /// Non-null while a child operation submitted from the running account is
  /// still pending -- "Run node as this" refuses every row but the running
  /// one with this as the reason. Never locks a row tap.
  final String? lockedReason;

  final void Function(BuildContext context, Wallet wallet) onRename;
  final void Function(BuildContext context, Wallet wallet) onDeleteWallet;

  /// Null for a leaf (no chevron at all); otherwise whether this main's
  /// children currently show.
  final bool? expanded;

  /// Flips [expanded]. Null exactly when [expanded] is null.
  final VoidCallback? onToggle;

  /// True only for a row carrying an SDK account that is not the one
  /// currently running -- the one condition "Run node as this" refuses.
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
        selected || onNode || (sdkBadge != WalletSDKBadge.none && !onNode);
    // Only a nested row's own indent actually eats into the row's width
    // budget -- a depth-0 row always has room, so it keeps the exact,
    // unwrapped layout every existing screenshot and test already expects.
    final nested = row.depth >= 1;

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
      leading: _leading(gw, wallet, locked),
      title: title,
      titleStyle: locked
          ? GeniusWalletTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: gw.textSecondary.withValues(alpha: 0.5),
            )
          : null,
      subtitle:
          WalletUtils.getAddressForDisplay(addressText) +
          (isStartAccount ? ' · Default account' : ''),
      subtitleStyle: GeniusWalletTypography.labelMd.copyWith(
        fontFamily: GeniusWalletTypography.monoFamily,
        color: locked
            ? gw.textSecondary.withValues(alpha: 0.5)
            : gw.textSecondary,
      ),
      trailing: nested
          ? _nestedTrailing(gw, wallet, anyTag, onNode, isWatched, locked)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A plain wallet's own link status - suppressed once On node
                // shows below, since a row that is on node is always linked
                // and the two would otherwise say the same thing twice. "SDK
                // PENDING" ALSO drops once Selected shows: at phone width the
                // two longer labels together do not fit next to a name and
                // address; "SDK" alone is short enough to keep.
                if (row.kind == AccountRowKind.wallet &&
                    sdkBadge != WalletSDKBadge.none &&
                    !onNode &&
                    !(selected && sdkBadge == WalletSDKBadge.pending)) ...[
                  GWRowBadge(
                    label: sdkBadge == WalletSDKBadge.linked
                        ? 'SDK'
                        : 'SDK PENDING',
                    color: sdkBadge == WalletSDKBadge.linked
                        ? gw.brandPrimaryBadgeText
                        : gw.statusWarningText,
                  ),
                  const SizedBox(width: GeniusWalletConsts.space3),
                ],
                // Two independent tags, either or both: which wallet sends
                // and swaps, and which account the node computes on.
                if (selected) ...[
                  GWRowBadge(
                    label: 'Selected',
                    color: gw.brandPrimaryBadgeText,
                  ),
                  const SizedBox(width: GeniusWalletConsts.space3),
                ],
                if (onNode) ...[
                  GWRowBadge(label: 'On node', color: gw.statusSuccessText),
                  const SizedBox(width: GeniusWalletConsts.space3),
                ],
                // Capped and ellipsised ONLY once a tag is in play -
                // unbadged rows keep their exact pre-existing size. An
                // account row with no wallet of its own shows no balance
                // here; "View balance" is its menu's own item.
                if (wallet != null)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: anyTag ? 48 : double.infinity,
                    ),
                    child: Text(
                      WalletUtils.formatMinions(wallet.balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: GeniusWalletTypography.labelMd.copyWith(
                        color: gw.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (isWatched) ...[
                  const SizedBox(width: GeniusWalletConsts.space3),
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 16,
                    color: gw.textSecondary,
                  ),
                ],
                if (locked) ...[
                  const SizedBox(width: GeniusWalletConsts.space3),
                  Icon(Icons.lock_outline, size: 14, color: gw.textSecondary),
                ],
              ],
            ),
      action: _menu(context, gw, appBloc, operations),
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

  /// The avatar, or an account icon, with a chevron ahead of it when this row
  /// is a main -- absent, not merely hidden, on a leaf, so a leaf's left edge
  /// does not move.
  Widget _leading(GWColors gw, Wallet? wallet, bool locked) {
    final content = wallet != null
        ? AccountAvatar(wallet: wallet, isSelected: selected, size: 36)
        : Icon(
            Icons.account_balance_wallet,
            size: 20,
            color: locked
                ? gw.textSecondary.withValues(alpha: 0.5)
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

  /// [trailing] for a nested row (depth >= 1): its own indent already spends
  /// part of the row's width budget, and its own Fund/Recover/Revoke menu
  /// items live one level deeper still, so at phone width both tags plus a
  /// balance can genuinely not fit on one line. Width-
  /// capped and wrapping here -- unlike the depth-0 case above, which never
  /// gets this tight and keeps its plain, unwrapped Row.  A nested row is
  /// always [AccountRowKind.merged] or [AccountRowKind.account] (registered
  /// children are only ever own SDK accounts), so it never carries the SDK
  /// badge a plain wallet row does.
  Widget _nestedTrailing(
    GWColors gw,
    Wallet? wallet,
    bool anyTag,
    bool onNode,
    bool isWatched,
    bool locked,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (anyTag)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 62),
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: GeniusWalletConsts.space3,
              runSpacing: GeniusWalletConsts.space2,
              children: [
                if (selected)
                  GWRowBadge(
                    label: 'Selected',
                    color: gw.brandPrimaryBadgeText,
                  ),
                if (onNode)
                  GWRowBadge(label: 'On node', color: gw.statusSuccessText),
                if (wallet != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 48),
                    child: Text(
                      WalletUtils.formatMinions(wallet.balance),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: GeniusWalletTypography.labelMd.copyWith(
                        color: gw.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          )
        else if (wallet != null)
          // A childless-of-own-accounts row still reaches here at depth >=
          // 1 without a tag; a chevron main's own indent plus chevron alone
          // is enough to need the same cap.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 48),
            child: Text(
              WalletUtils.formatMinions(wallet.balance),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (isWatched) ...[
          const SizedBox(width: GeniusWalletConsts.space3),
          Icon(
            Icons.remove_red_eye_outlined,
            size: 16,
            color: gw.textSecondary,
          ),
        ],
        if (locked) ...[
          const SizedBox(width: GeniusWalletConsts.space3),
          Icon(Icons.lock_outline, size: 14, color: gw.textSecondary),
        ],
      ],
    );
  }

  /// wallet: Copy address, Rename, Delete, unchanged. merged/account: "Run
  /// node as this" plus the four gated SDK items, plus Delete
  /// wallet/account, plus -- when nested under another own main --
  /// Fund/Recover/Revoke after a divider.
  Widget? _menu(
    BuildContext context,
    GWColors gw,
    AppBloc appBloc,
    ChildOperationsCubit? operations,
  ) {
    // No local `MenuStyle` -- see `theme.dart`'s menuTheme/menuButtonTheme.
    Widget anchor(List<Widget> items) => MenuAnchor(
      builder: (context, controller, child) => IconButton(
        icon: Icon(Icons.more_vert, size: 20, color: gw.textSecondary),
        tooltip: 'Account options',
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: items,
    );

    final wallet = row.wallet;
    if (row.kind == AccountRowKind.wallet) {
      if (wallet!.address.isEmpty) {
        return null;
      }
      return anchor([
        GWMenuItem(
          icon: Icons.copy,
          label: 'Copy address',
          onPressed: () => _copyAddress(context, wallet.address),
        ),
        GWMenuItem(
          icon: Icons.edit_outlined,
          label: 'Rename',
          onPressed: () => onRename(context, wallet),
        ),
        GWMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          color: gw.statusErrorText,
          onPressed: () => onDeleteWallet(context, wallet),
        ),
      ]);
    }

    // merged or account: every row carrying an SDK account.
    final sdkAddress = row.sdkAddress!;
    // The SDK only exposes the SELECTED (on node) account's phrase, so the
    // mnemonic is read only when this row is that one.
    final mnemonic = onNode ? appBloc.api.getSelectedAccountMnemonic() : null;
    final can = sdkRowActions(
      isSelected: onNode,
      hasMnemonic: mnemonic != null,
      isStartAccount: isStartAccount,
    );

    return anchor([
      GWMenuItem(
        icon: Icons.dns_outlined,
        label: 'Run node as this',
        lockedReason: _locked ? lockedReason : null,
        onPressed: onNode || _locked
            ? null
            : () {
                context.read<AppBloc>().add(SelectSDKAccount(sdkAddress));
                showToast(
                  context,
                  'SDK account selected',
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
          onPressed: () => onRename(context, wallet!),
        ),
      GWMenuItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'View balance',
        onPressed: balanceWallet != null
            ? () => Navigator.of(context).pop(balanceWallet)
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
            ? () => copyRecoveryPhrase(context, mnemonic!)
            : null,
      ),
      GWMenuItem(
        icon: Icons.qr_code,
        label: 'Show recovery QR',
        onPressed: can.qr ? () => showRecoveryQr(context, mnemonic!) : null,
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
          onPressed: () => onDeleteWallet(context, wallet!),
        ),
      GWMenuItem(
        icon: Icons.delete_outline,
        label: 'Delete account',
        color: gw.statusErrorText,
        onPressed: can.delete
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
          lockedReason: operations.balanceLockReason(sdkAddress),
          onPressed: operations.balanceLockReason(sdkAddress) != null
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
          lockedReason: operations.balanceLockReason(sdkAddress),
          onPressed: operations.balanceLockReason(sdkAddress) != null
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
          lockedReason:
              operations.isPending(ChildOperationKind.revoke, sdkAddress)
              ? 'Already revoking this child'
              : null,
          color: gw.statusErrorText,
          onPressed: operations.isPending(ChildOperationKind.revoke, sdkAddress)
              ? null
              : () => startRevoke(
                  context,
                  child: row.child!,
                  mainAddress: row.parentMain!,
                ),
        ),
      ],
    ]);
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
  const _AccountSectionHeader({required this.title, required this.caption});

  final String title;
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
          Text(
            title.toUpperCase(),
            style: GeniusWalletTypography.labelMd.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space2),
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
