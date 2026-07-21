import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class AccountDropdownSelector extends StatefulWidget {
  final ValueChanged<Wallet>? onAccountSelected;
  final Wallet? initialSelected;

  const AccountDropdownSelector({
    super.key,
    this.onAccountSelected,
    this.initialSelected,
  });

  @override
  State<AccountDropdownSelector> createState() =>
      _AccountDropdownSelectorState();
}

class _AccountDropdownSelectorState extends State<AccountDropdownSelector> {
  Wallet? selectedWallet;
  String? savedWalletAddress;

  @override
  void initState() {
    super.initState();
    _loadSavedWallet();
  }

  Future<void> _loadSavedWallet() async {
    final address = Hive.box(walletBoxName).get(selectedWalletKey);
    if (!mounted) return;
    setState(() => savedWalletAddress = address);
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
        GWDialogAction(
          label: 'Cancel',
          onPressed: () => navigator.pop(),
        ),
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
      if (wallet.address == selectedWallet?.address) {
        setState(() {
          selectedWallet = selectedWallet!.copyWith(walletName: newName);
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
      message: 'Are you sure you want to delete "${wallet.walletName}"?\n\n'
          'This action cannot be undone.',
      actions: [
        GWDialogAction(
          label: 'Cancel',
          onPressed: () => navigator.pop(false),
        ),
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
      if (wallet.address == selectedWallet?.address) {
        final remainingWallets = appBloc.state.wallets
            .where((w) => w.address != wallet.address)
            .toList();
        setState(() {
          selectedWallet = remainingWallets.isNotEmpty
              ? remainingWallets.first
              : null;
        });
      }
    }
  }

  Future<void> _showAccountDrawer() async {
    final walletCubit = context.read<WalletDetailsCubit>();

    final selected = await ResponsiveDrawer.show<Wallet>(
      context: context,
      title: "Your Accounts",
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, appState) {
          final wallets = appState.wallets;
          if (wallets.isEmpty) {
            final gw =
                Theme.of(context).extension<GWColors>() ?? GWColors.dark();
            return Center(
              child: Text(
                "You have no wallets!",
                style: TextStyle(fontSize: 16, color: gw.textPrimary70),
              ),
            );
          }
          return ListView.separated(
            itemBuilder: (context, i) => _buildDrawerRow(
              context,
              wallets[i],
              wallets[i].walletName == selectedWallet?.walletName,
            ),
            itemCount: wallets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
          );
        },
      ),
      footer: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            iconSize: 28,
          ),
          onPressed: () => context.push('/landing_screen', extra: true),
          icon: const Icon(Icons.add),
          label: const Text("Add Wallet"),
        ),
      ),
    );

    if (selected == null || selected == selectedWallet) return;

    setState(() => selectedWallet = selected);
    widget.onAccountSelected?.call(selected);
    walletCubit.selectWallet(selected);
    await Hive.box(walletBoxName).put(selectedWalletKey, selected.address);
  }

  Widget _buildDrawerRow(
    BuildContext context,
    Wallet wallet,
    bool isSelected,
  ) {
    // Fail-soft read: registers the InheritedWidget dependency (on the
    // per-row context passed in from the drawer's own itemBuilder, NOT the
    // widget-level this.context) that forces this row to rebuild on a live
    // appearance toggle while the drawer stays open (04-02 D-02).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final isWatched = wallet.walletType == WalletType.tracking;

    // Selected-row text/icons stay on the mode-invariant on-brand token
    // (WCAG-safe against the brandPrimary fill); unselected rows read the
    // appearance-aware primary/secondary text tokens.
    final textColor =
        isSelected ? GeniusWalletColors.textOnBrand : gw.textPrimary;

    final subColor =
        isSelected ? GeniusWalletColors.textOnBrand : gw.textSecondary;

    return ListTile(
      selected: isSelected,
      selectedTileColor: GeniusWalletColors.brandPrimaryStrong,
      tileColor: gw.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => Navigator.of(context).pop(wallet),
      leading: _buildAvatar(wallet, isSelected: isSelected, size: 36),
      title: Row(
        children: [
          Flexible(
            child: Text(
              wallet.walletName,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isWatched)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.remove_red_eye_outlined,
                size: 16,
                color: textColor,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3.0,
        children: [
          Row(
            children: [
              if (wallet.walletType == WalletType.sgnus)
                GeniusBalanceDisplay(
                  useMinions: true,
                  fontSize: 12,
                  isShowSuffix: true,
                  fontColor: subColor,
                )
              else
                Text(
                  '${wallet.balance} ${wallet.balance == 1 ? "minion" : "minions"}',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          if (wallet.address.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    wallet.address,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: subColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: wallet.address.isEmpty
          ? null
          : MenuAnchor(
              // Explicit menuStyle: the reconciled theme no longer supplies
              // menuTheme, so an un-styled MenuAnchor container reverts to
              // stock Material 3 (04-RESEARCH Pitfall 5).
              style: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(gw.surfaceElevated),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(GeniusWalletConsts.radiusLg),
                  ),
                ),
              ),
              builder: (context, controller, child) => IconButton(
                icon: Icon(Icons.more_vert, size: 20, color: textColor),
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
                  leadingIcon: Icon(Icons.copy, size: 20, color: gw.textPrimary),
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
                    leadingIcon: Icon(Icons.edit_outlined,
                        size: 20, color: gw.textPrimary),
                    style: MenuItemButton.styleFrom(
                      foregroundColor: gw.textPrimary,
                    ),
                    onPressed: () => _confirmRenameWallet(context, wallet),
                    child: const Text('Rename'),
                  ),
                if (wallet.walletType != WalletType.sgnus)
                  MenuItemButton(
                    leadingIcon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: GeniusWalletColors.statusError,
                    ),
                    onPressed: () => _confirmDeleteWallet(context, wallet),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: GeniusWalletColors.statusError),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAvatar(
    Wallet wallet, {
    required bool isSelected,
    required double size,
  }) {
    final isWatched = wallet.walletType == WalletType.tracking;
    return CircleAvatar(
      radius: size / 2 - 2,
      backgroundColor: GeniusWalletColors.brandPrimaryStrong,
      child: isWatched
          ? const Icon(
              Icons.remove_red_eye_outlined,
              size: 20,
              color: GeniusWalletColors.textOnBrand,
            )
          : Image.asset(
              'assets/images/crypto/${wallet.currencySymbol.toLowerCase()}.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final wallets = state.wallets;
        if (wallets.isEmpty) {
          final gw =
              Theme.of(context).extension<GWColors>() ?? GWColors.dark();
          return Center(
            child: Text(
              "You have no wallets!",
              style: TextStyle(fontSize: 16, color: gw.textPrimary70),
            ),
          );
        }
        selectedWallet ??= wallets.firstWhere(
          (w) => w.address == savedWalletAddress,
          orElse: () => widget.initialSelected ?? wallets.first,
        );
        return Tooltip(
          message: "Select wallet",
          child: TextButton(
            style: navContextChipStyle(context),
            onPressed: () => _showAccountDrawer(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: GeniusWalletConsts.space4,
              children: [
                _buildAvatar(selectedWallet!, isSelected: false, size: 25),
                if (MediaQuery.sizeOf(context).width >= GeniusBreakpoints.small)
                  Text(
                    selectedWallet!.walletType == WalletType.sgnus
                        ? 'Super Genius'
                        : WalletUtils.getAddressForDisplay(
                            selectedWallet!.address,
                          ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }
}
