import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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
    // Close the drawer first so the dialog appears on the correct navigator.
    Navigator.of(context).pop();

    final controller = TextEditingController(text: wallet.walletName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Wallet'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Wallet name',
          ),
          onSubmitted: (value) => Navigator.of(ctx).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != wallet.walletName &&
        mounted) {
      context.read<AppBloc>().add(RenameWallet(wallet.address, newName));
      if (wallet.address == selectedWallet?.address) {
        setState(() {
          selectedWallet = selectedWallet!.copyWith(walletName: newName);
        });
      }
    }
  }

  Future<void> _confirmDeleteWallet(BuildContext context, Wallet wallet) async {
    // Close the drawer first so the dialog appears on the correct navigator.
    Navigator.of(context).pop();

    final appBloc = context.read<AppBloc>();

    // Guard: require at least one wallet to remain.
    if (appBloc.state.wallets.length <= 1) {
      showAppSnackBar(
        context,
        'You must keep at least one wallet.',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete wallet'),
        content: Text(
          'Are you sure you want to delete "${wallet.walletName}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      appBloc.add(DeleteWallet(wallet.address));

      // If the deleted wallet was the selected one, select another.
      if (wallet.address == selectedWallet?.address) {
        final remainingWallets = appBloc.state.wallets
            .where((w) => w.address != wallet.address)
            .toList();
        setState(() {
          selectedWallet =
              remainingWallets.isNotEmpty ? remainingWallets.first : null;
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
            return const Center(
              child: Text(
                "You have no wallets!",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            );
          }
          return ListView.separated(
            itemBuilder: (context, i) => _buildDrawerRow(wallets[i],
                wallets[i].walletName == selectedWallet?.walletName),
            itemCount: wallets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
          );
        },
      ),
      footer: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              iconSize: 28),
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
    Wallet wallet,
    bool isSelected,
  ) {
    final isWatched = wallet.walletType == WalletType.tracking;

    final textColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.white;

    final subColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.grey;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.greenAccent,
      tileColor: GeniusWalletColors.deepBlueCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () => Navigator.of(context).pop(wallet),
      leading: _buildAvatar(
        wallet,
        isSelected: isSelected,
        size: 36,
      ),
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
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: subColor,
                      fontSize: 13,
                    ),
                  ),
                )
              ],
            ),
          ],
        ],
      ),
      trailing: wallet.address.isEmpty
          ? null
          : MenuAnchor(
              builder: (context, controller, child) => IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: textColor,
                ),
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
                  leadingIcon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: wallet.address),
                    );
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
                    leadingIcon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _confirmRenameWallet(context, wallet),
                    child: const Text('Rename'),
                  ),
                if (wallet.walletType != WalletType.sgnus)
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.redAccent),
                    onPressed: () => _confirmDeleteWallet(context, wallet),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
              ],
            ),
    );
  }

  Widget _buildAvatar(Wallet wallet,
      {required bool isSelected, required double size}) {
    final isWatched = wallet.walletType == WalletType.tracking;
    return CircleAvatar(
      radius: size / 2 - 2,
      backgroundColor: Colors.greenAccent,
      child: isWatched
          ? const Icon(Icons.remove_red_eye_outlined,
              size: 20, color: GeniusWalletColors.deepBlueTertiary)
          : Image.asset(
              'assets/images/crypto/${wallet.currencySymbol.toLowerCase()}.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final wallets = state.wallets;
        if (wallets.isEmpty) {
          return const Center(
            child: Text(
              "You have no wallets!",
              style: TextStyle(fontSize: 16, color: Colors.white70),
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
            onPressed: () => _showAccountDrawer(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: [
                _buildAvatar(selectedWallet!, isSelected: false, size: 25),
                Flexible(
                  child: Text(
                    selectedWallet!.walletType == WalletType.sgnus
                        ? 'Super Genius'
                        : WalletUtils.getAddressForDisplay(
                            selectedWallet!.address),
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
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
