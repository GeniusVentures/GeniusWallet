import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
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
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// The account drawer, extracted from `AccountDropdownSelector`'s former
/// private `_showAccountDrawer` so a second surface can open it - the
/// compute panel's *not linked* state offers a switch-wallet affordance that
/// otherwise has no destination.
///
/// This is a code move, not a redesign: the drawer that opens is the same
/// drawer, with the same title, the same rows, the same footer and the same
/// body inset.
class AccountDrawer {
  /// Opens the drawer and returns the wallet the user selected, or `null` if
  /// they dismissed it without picking one.
  ///
  /// The selection's side effect - [WalletDetailsCubit.selectWallet], which
  /// also persists it across restarts - happens HERE, inside the entry, so no
  /// caller can forget it.
  ///
  /// [includeNetwork] prepends a network field and retitles the sheet, which
  /// is what the phone header's single wallet pill opens: one surface
  /// answering both "whose wallet" and "on which chain", instead of the two
  /// separate controls the phone header used to carry.
  ///
  /// It defaults to FALSE, and that default is load-bearing. Every existing
  /// caller - the compute panel's *not linked* state included - passes
  /// nothing and gets byte-identical behaviour, title included. The title is
  /// derived here rather than by the body because
  /// `test/account/account_drawer_show_test.dart` pins `find.text('Accounts')`
  /// and must stay green without being edited.
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
        label: 'Add Wallet',
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
    if (!AppBloc.canDeleteWallet(appBloc.state.wallets)) {
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
      appBloc.add(DeleteWallet(wallet.address));
    }
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
          // 24-02: which SDK account the NODE computes on is a SEPARATE state
          // from which wallet the UI is showing. `SelectSDKAccount` is
          // dispatched from exactly one place -- sdk_account_manager.dart:185 --
          // and the drawer's own tap only calls `walletCubit.selectWallet`.
          // So the check glyph and this badge can legitimately sit on different
          // rows, and before this badge existed nothing said so.
          if (isActiveOnNode) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space4,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: gw.brandSecondary.withValues(alpha: 0.12),
                border: Border.all(
                  color: gw.brandSecondary.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.radiusXs,
                ),
              ),
              child: Text(
                'ACTIVE ON NODE',
                style: GeniusWalletTypography.labelMd.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: gw.brandSecondary,
                ),
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space3),
          ],
          // `isShowSuffix: false` -- GeniusBalanceDisplay hard-codes the suffix
          // as the abbreviation "min", so with it on this row read "0 min"
          // directly above another row reading "0.0 minions". One unit, two
          // spellings, adjacent. The suffix is written here instead so both
          // branches say the same word.
          if (wallet.walletType == WalletType.sgnus) ...[
            GeniusBalanceDisplay(
              useMinions: true,
              fontSize: 12,
              fontColor: gw.textSecondary,
            ),
            Text(
              ' minions',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else
            Text(
              WalletUtils.formatMinions(wallet.balance),
              style: GeniusWalletTypography.labelMd.copyWith(
                color: gw.textSecondary,
                fontStyle: FontStyle.italic,
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
                if (wallet.walletType != WalletType.sgnus)
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
                if (wallet.walletType != WalletType.sgnus)
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

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, appState) {
        final wallets = appState.wallets;
        // The blanket "You have no wallets!" early return was removed in 24-02.
        // With two sections each owning its own empty note, it would have
        // swallowed BOTH headers -- including the one explanation the user most
        // needs when the list is short, that the node is disconnected.
        // 24-02: ONE flat list used to hold two unrelated kinds of account.
        // `app_bloc.dart:628` returns `[...sgnusWallets, ..._baseWallets]`, so
        // SDK accounts were already sorted first -- but nothing said they were
        // a different thing, and they differ in almost every way that matters:
        // unit (minions vs the network's currency), balance source (native SDK
        // vs RPC), transactions screen, and whether rename/delete are even
        // allowed. Splitting the list is the smallest change that stops the
        // drawer implying they are interchangeable.
        final sdkWallets = wallets
            .where((w) => w.walletType == WalletType.sgnus)
            .toList();
        final ownWallets = wallets
            .where((w) => w.walletType != WalletType.sgnus)
            .toList();

        // `state.sdkAccounts` is filled by `_getSDKAccountState()`, which calls
        // `api.getAvailableAccounts()` WITHOUT checking the connection.
        // `_mergeSgnusWallet()` DOES check it and returns base wallets only
        // when the node is down (app_bloc.dart:606-609). So the two lists
        // disagreeing is a precise signal: the node has accounts, but is not
        // connected right now. Without this the rows just vanish and the user
        // is told nothing.
        final nodeHasAccounts = appState.sdkAccounts.isNotEmpty;
        final nodeDisconnected = sdkWallets.isEmpty && nodeHasAccounts;

        return ListView(
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
          children: [
            // The network field, when this sheet was opened as the combined
            // wallet-and-network surface. One field rather than a list, so the
            // user's own wallets stay above the fold; it opens the same
            // searchable, Mainnet/Testnet picker the desktop selector uses.
            //
            // `_AccountSectionHeader` is reused exactly as it stands, with no
            // variant flag: this section is the same kind of thing the other
            // two are.
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
            // The SDK section appears only when it has something to SAY -
            // either real accounts, or the fact that the node dropped and took
            // them away. A user who has never run a node would otherwise get a
            // header and an empty box pushing their own wallets below the fold,
            // which is the first thing they came here for.
            if (sdkWallets.isNotEmpty || nodeDisconnected) ...[
              const _AccountSectionHeader(
                title: 'SDK Accounts',
                caption:
                    'Node accounts that earn minions for sharing your GPU. '
                    'Balances come from the SuperGenius node, and these '
                    'accounts cannot be renamed or deleted.',
              ),
              if (sdkWallets.isNotEmpty)
                ...sdkWallets.map(
                  (w) => _buildDrawerRow(
                    context,
                    w,
                    w.walletName == _selectedWallet?.walletName,
                    isActiveOnNode: w.address == appState.selectedSDKAccount,
                  ),
                )
              else
                const _AccountSectionNote(
                  text:
                      'The SuperGenius node is not connected, so its accounts '
                      'are unavailable right now.',
                ),
              const SizedBox(height: GeniusWalletConsts.space8),
            ],
            const _AccountSectionHeader(
              title: 'Your Accounts',
              caption:
                  'Wallets you created or imported. Used for swaps, sends and '
                  'everything else on-chain.',
            ),
            if (ownWallets.isNotEmpty)
              ...ownWallets.map(
                (w) => _buildDrawerRow(
                  context,
                  w,
                  w.walletName == _selectedWallet?.walletName,
                ),
              )
            else
              const _AccountSectionNote(text: 'No wallets yet.'),
          ],
        );
      },
    );
  }
}

/// The wallet avatar, shared by this drawer's rows AND
/// `AccountDropdownSelector`'s collapsed top-bar chip - both need it, and
/// Dart's file-scoped privacy means a private method can no longer serve
/// both once the drawer moved to its own file. A public widget rather than a
/// top-level function, per the house rule against `_buildFoo()` helpers.
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
