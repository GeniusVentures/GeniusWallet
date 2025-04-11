import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/bottom_drawer/responsive_drawer.dart';

class AccountDropdownSelector extends StatefulWidget {
  final Function(Wallet selectedWallet) onAccountSelected;
  final Wallet? initialSelected;

  const AccountDropdownSelector({
    super.key,
    required this.onAccountSelected,
    this.initialSelected,
  });

  @override
  State<AccountDropdownSelector> createState() =>
      _AccountDropdownSelectorState();
}

class _AccountDropdownSelectorState extends State<AccountDropdownSelector> {
  late Wallet selectedWallet;

  @override
  void initState() {
    super.initState();
    // selectedWallet initialized in build once state is available
  }

  void _showAccountDrawer(List<Wallet> wallets) async {
    final selected = await ResponsiveDrawer.show<Wallet>(
      context: context,
      title: "Your Accounts",
      children: wallets.map((wallet) {
        final isSelected = wallet.walletName == selectedWallet.walletName;
        return _buildDrawerRow(wallet, isSelected, context);
      }).toList(),
    );

    if (selected != null && selected != selectedWallet) {
      setState(() => selectedWallet = selected);
      widget.onAccountSelected(selected);
    }
  }

  Widget _buildDrawerRow(Wallet wallet, bool isSelected, BuildContext context) {
    final isWatched = wallet.walletType == WalletType.tracking;
    final textColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.white;
    final balanceColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.grey;
    final trailingIconColor = isWatched
        ? (isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.white)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent
              : GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildAccountAvatar(wallet, isSelected),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  wallet.walletName,
                  style: TextStyle(fontSize: 16, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isWatched)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.remove_red_eye_outlined,
                      size: 16, color: trailingIconColor),
                ),
            ],
          ),
          subtitle: Text(
            '${wallet.balance} ${wallet.currencySymbol}',
            style: TextStyle(color: balanceColor),
          ),
          onTap: () => Navigator.of(context).pop(wallet),
        ),
      ),
    );
  }

  Widget _buildAccountAvatar(Wallet wallet, bool isSelected) {
    final isWatched = wallet.walletType == WalletType.tracking;
    final borderColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.greenAccent,
        border: Border.all(color: borderColor, width: 2),
      ),
      width: 35,
      height: 35,
      alignment: Alignment.center,
      child: isWatched
          ? const Icon(Icons.remove_red_eye_outlined,
              size: 20, color: GeniusWalletColors.deepBlueTertiary)
          : Text(
              wallet.walletName.isNotEmpty
                  ? wallet.walletName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        if (state.wallets.isEmpty) {
          return const Center(
            child: Text(
              "You have no wallets!",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          );
        }

        selectedWallet = widget.initialSelected ?? state.wallets.first;

        return GestureDetector(
          onTap: () => _showAccountDrawer(state.wallets),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAccountAvatar(selectedWallet, false),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    selectedWallet.walletName,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        );
      },
    );
  }
}
