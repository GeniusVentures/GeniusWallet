import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

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
  /// The selection's real side effects - the [WalletDetailsCubit] update and
  /// the Hive persistence write - happen HERE, inside the entry, rather than
  /// at the call site. Every caller wants both; leaving either one at the
  /// call site would mean a caller could forget it, and forgetting the Hive
  /// write would silently stop wallet selection persisting across restarts.
  static Future<Wallet?> show(BuildContext context) async {
    final walletCubit = context.read<WalletDetailsCubit>();

    final selected = await ResponsiveDrawer.show<Wallet>(
      context: context,
      // Owns a scrolling viewport: the inset lives on the list so it scrolls
      // with the content and rows still reach the panel edge (kDrawerBodyPadding).
      bodyPadding: EdgeInsets.zero,
      title: "Your Accounts",
      child: const _AccountDrawerBody(),
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

    walletCubit.selectWallet(selected);
    await Hive.box(walletBoxName).put(selectedWalletKey, selected.address);

    return selected;
  }
}

/// The drawer's body: the row list plus the two confirm flows reachable from
/// each row's overflow menu. A `StatefulWidget` because both confirm flows
/// call `setState` and check `mounted`.
class _AccountDrawerBody extends StatefulWidget {
  const _AccountDrawerBody();

  @override
  State<_AccountDrawerBody> createState() => _AccountDrawerBodyState();
}

class _AccountDrawerBodyState extends State<_AccountDrawerBody> {
  // Seeded once from WalletDetailsCubit.state.selectedWallet - the same
  // value `selectWallet` writes, so the highlight cannot desync from the
  // selection. Kept as a local mirror (not re-read from the cubit on every
  // build) purely so the two confirm flows below can update it in place when
  // a rename/delete touches the currently-selected wallet, exactly as the
  // pre-extraction code did against its own local field.
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
    final newName = await GWDialog.show<String>(
      context: navigator.context,
      title: 'Rename Wallet',
      content: GWTextField(
        controller: controller,
        label: 'Wallet name',
        autofocus: true,
        onFieldSubmitted: (value) => navigator.pop(value.trim()),
      ),
      actions: [
        GWDialogAction(label: 'Cancel', onPressed: () => navigator.pop()),
        GWDialogAction(
          label: 'Rename',
          variant: GWButtonVariant.primary,
          onPressed: () => navigator.pop(controller.text.trim()),
        ),
      ],
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != wallet.walletName &&
        mounted) {
      appBloc.add(RenameWallet(wallet.address, newName));
      if (wallet.address == _selectedWallet?.address) {
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

    // Guard: require at least one wallet to remain.
    if (appBloc.state.wallets.length <= 1) {
      showAppSnackBar(
        navigator.context,
        'You must keep at least one wallet.',
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

    if (confirmed == true && mounted) {
      appBloc.add(DeleteWallet(wallet.address));

      // If the deleted wallet was the selected one, select another.
      if (wallet.address == _selectedWallet?.address) {
        final remainingWallets = appBloc.state.wallets
            .where((w) => w.address != wallet.address)
            .toList();
        setState(() {
          _selectedWallet = remainingWallets.isNotEmpty
              ? remainingWallets.first
              : null;
        });
      }
    }
  }

  Widget _buildDrawerRow(BuildContext context, Wallet wallet, bool isSelected) {
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
      subtitle: wallet.address.isEmpty ? null : wallet.address,
      subtitleStyle: GeniusWalletTypography.labelMd.copyWith(
        fontFamily: GeniusWalletTypography.monoFamily,
        color: gw.textSecondary,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              '${wallet.balance} ${wallet.balance == 1 ? "minion" : "minions"}',
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
                    showAppSnackBar(
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
                      color: gw.statusError,
                    ),
                    onPressed: () => _confirmDeleteWallet(context, wallet),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: gw.statusError),
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
        if (wallets.isEmpty) {
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
          return Center(
            child: Text(
              "You have no wallets!",
              style: TextStyle(fontSize: 16, color: gw.textPrimary70),
            ),
          );
        }
        // ListView.builder, not .separated: GWSelectRow carries its own
        // bottom margin, so a separator would double the gap.
        return ListView.builder(
          padding: const EdgeInsets.all(GeniusWalletConsts.space10),
          itemBuilder: (context, i) => _buildDrawerRow(
            context,
            wallets[i],
            wallets[i].walletName == _selectedWallet?.walletName,
          ),
          itemCount: wallets.length,
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
  });

  final Wallet wallet;
  final bool isSelected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isWatched = wallet.walletType == WalletType.tracking;
    return CircleAvatar(
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
  }
}
