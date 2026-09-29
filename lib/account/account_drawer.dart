import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/data/gw_row_badge.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
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

/// The account switcher: two independent selections, "Sending from" and
/// "Node running as" - changing one never touches the other.
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

  Widget _buildDrawerRow(
    BuildContext context,
    Wallet wallet,
    bool isSelected, {
    bool isActiveOnNode = false,
    WalletSDKBadge sdkBadge = WalletSDKBadge.none,
  }) {
    // Fail-soft read: registers the InheritedWidget dependency (on the
    // per-row context passed in from the drawer's own itemBuilder, NOT the
    // widget-level this.context) that forces this row to rebuild on a live
    // appearance toggle while the drawer stays open (04-02 D-02).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final isWatched = wallet.walletType == WalletType.tracking;

    // Sketch 068-A. This row used to paint selection as
    // `selectedTileColor: brandPrimaryStrong` -- a FLAT brand fill, the one
    // thing `drawers-final`'s global accent rule forbids and which quick
    // 260721-0ze swept out of the rest of the app. This row was missed. It also
    // needed two on-brand text colours to stay legible ON that fill; with the
    // gradient tint underneath, ordinary text tokens read fine and both are
    // gone.
    //
    // The shape follows the token row: identity on the LEFT (name over
    // address), value on the RIGHT (balance). The address moved from a
    // `SelectableText` to the subtitle -- select-to-copy inside a tappable row
    // fights the tap, and the overflow menu's "Copy address" is the real path.
    return GWSelectRow(
      selected: isSelected,
      onTap: () => Navigator.of(context).pop(wallet),
      leading: AccountAvatar(wallet: wallet, isSelected: isSelected, size: 36),
      title: wallet.walletName,
      subtitle: wallet.address.isEmpty
          ? null
          : WalletUtils.getAddressForDisplay(wallet.address),
      subtitleStyle: GeniusWalletTypography.labelMd.copyWith(
        fontFamily: GeniusWalletTypography.monoFamily,
        color: gw.textSecondary,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Which of the user's OWN wallets has an SDK account, at a
          // glance. Suppressed when ACTIVE ON NODE already shows below - a
          // row that IS the node's active account is always linked, so the
          // two badges would otherwise stack on the same row and say the
          // same thing twice.
          if (sdkBadge != WalletSDKBadge.none && !isActiveOnNode) ...[
            GWRowBadge(
              label: sdkBadge == WalletSDKBadge.linked ? 'SDK' : 'SDK PENDING',
              color: sdkBadge == WalletSDKBadge.linked
                  ? gw.brandPrimaryOnSurface
                  : gw.statusWarningText,
            ),
            const SizedBox(width: GeniusWalletConsts.space3),
          ],
          // Which SDK account the NODE computes on is a SEPARATE state from
          // which wallet the UI is showing, so the check glyph and this
          // badge can legitimately sit on different rows.
          if (isActiveOnNode) ...[
            GWRowBadge(label: 'ACTIVE ON NODE', color: gw.brandSecondary),
            const SizedBox(width: GeniusWalletConsts.space3),
          ],
          // Capped and ellipsised ONLY once a badge is in play - the SDK
          // pill is new width this row never carried before, and this is
          // the one part of the row allowed to give ground for it.
          // Unbadged rows keep their exact pre-existing size.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: sdkBadge == WalletSDKBadge.none ? double.infinity : 48,
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
        ],
      ),
      action: wallet.address.isEmpty
          ? null
          // No local `MenuStyle` -- see `theme.dart`'s menuTheme/menuButtonTheme.
          : MenuAnchor(
              builder: (context, controller, child) => IconButton(
                icon: Icon(Icons.more_vert, size: 20, color: gw.textSecondary),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              ),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: Icon(
                    Icons.copy,
                    size: 20,
                    color: gw.textPrimary,
                  ),
                  style: MenuItemButton.styleFrom(
                    foregroundColor: gw.textPrimary,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: wallet.address));
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                    showToast(
                      context,
                      'Address copied to clipboard',
                      duration: const Duration(seconds: 1),
                    );
                  },
                  child: const Text('Copy address'),
                ),
                MenuItemButton(
                  leadingIcon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: gw.textPrimary,
                  ),
                  style: MenuItemButton.styleFrom(
                    foregroundColor: gw.textPrimary,
                  ),
                  onPressed: () => _confirmRenameWallet(context, wallet),
                  child: const Text('Rename'),
                ),
                MenuItemButton(
                  leadingIcon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: gw.statusErrorText,
                  ),
                  onPressed: () => _confirmDeleteWallet(context, wallet),
                  child: Text(
                    'Delete',
                    style: TextStyle(color: gw.statusErrorText),
                  ),
                ),
              ],
            ),
    );
  }

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
        // Two independent selections, never one flat list: which wallet sends
        // and swaps, and which account the node computes on. sgnus rows carry
        // no selection of their own here - their balance is reached from the
        // linked SDK row's own menu instead.
        final ownWallets = appState.wallets
            .where((w) => w.walletType != WalletType.sgnus)
            .toList();
        final sdkAccounts = appState.sdkAccounts;
        final defaultAccount = appState.defaultSDKAccount?.toLowerCase();
        // The own wallet the node currently computes on, if any - resolved
        // once per build rather than per row.
        final activeOnNode = appState.selectedSDKAccount == null
            ? null
            : AppBloc.linkedWallet(
                appState.selectedSDKAccount!,
                appState.sdkAccountLinks,
                appState.wallets,
              );
        // A pending child operation submitted from the running account locks
        // every OTHER row -- active-wallet ("Sending from") switching above
        // is never touched by this.
        final running = appState.selectedSDKAccount;
        final lockedReason =
            operations != null &&
                running != null &&
                operations.hasPendingFrom(running)
            ? 'Waiting for a child operation from ${operations.labelFor(running)} '
                  'to confirm'
            : null;

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
              title: 'Sending from',
              caption: 'Sends, swaps and balances use this wallet.',
            ),
            if (ownWallets.isNotEmpty)
              ...ownWallets.map(
                (w) => _buildDrawerRow(
                  context,
                  w,
                  _matchesSelected(w),
                  isActiveOnNode:
                      activeOnNode != null &&
                      w.walletType == activeOnNode.walletType &&
                      w.address.toLowerCase() ==
                          activeOnNode.address.toLowerCase(),
                  sdkBadge: walletSDKBadge(
                    w,
                    appState.sdkAccountLinks,
                    sdkRunning: appState.defaultSDKAccount != null,
                  ),
                ),
              )
            else
              const _AccountSectionNote(text: 'No wallets yet.'),
            const SizedBox(height: GeniusWalletConsts.space8),
            const _AccountSectionHeader(
              title: 'Node running as',
              caption: 'The GNUS node processes and earns as this account.',
            ),
            // Never vanishes: a disconnected node and a connected-but-empty
            // node are two different facts, each said in words rather than
            // left as an absent section.
            if (sdkAccounts.isNotEmpty)
              ...sdkAccounts.map(
                (account) => SDKAccountRow(
                  address: account,
                  name: AppBloc.sdkAccountName(
                    account,
                    appState.sdkAccountLinks,
                    appState.wallets,
                  ),
                  isSelected: account == appState.selectedSDKAccount,
                  isStartAccount: account.toLowerCase() == defaultAccount,
                  balanceWallet: _sgnusWalletFor(account, appState.wallets),
                  lockedReason: lockedReason,
                ),
              )
            else
              _AccountSectionNote(
                text: appState.defaultSDKAccount == null
                    ? 'Node not running'
                    : 'No SDK accounts yet',
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
