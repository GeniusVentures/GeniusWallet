import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:genius_wallet/widgets/components/bottom_drawer/responsive_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AccountDropdownSelector extends StatefulWidget {
  final Function(Wallet selectedWallet)? onAccountSelected;
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

  void _loadSavedWallet() async {
    final box = Hive.box(walletBoxName);
    final address = box.get(selectedWalletKey);

    //print("Saved wallet address: $address");

    if (!mounted) return;
    setState(() {
      savedWalletAddress = address;
    });
  }

  void _showAccountDrawer(List<Wallet> wallets) async {
    final walletCubit = context.read<WalletDetailsCubit>();
    final selected = await ResponsiveDrawer.show<Wallet>(
        context: context,
        title: "Your Accounts",
        children: wallets.map((wallet) {
          final isSelected = wallet.walletName == selectedWallet?.walletName;
          return _buildDrawerRow(wallet, isSelected, context);
        }).toList(),
        footer: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              context.push('/landing_screen', extra: true);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              side: const BorderSide(color: Colors.transparent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: Colors.greenAccent,
              foregroundColor: GeniusWalletColors.deepBlueTertiary,
            ),
            child: const Text(
              "Add Wallet",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ));

    if (selected != null && selected != selectedWallet) {
      setState(() => selectedWallet = selected);
      if (widget.onAccountSelected != null) {
        widget.onAccountSelected!(selected);
      }

      // Update the wallet details cubit with the selected wallet
      walletCubit.selectWallet(selected);

      final box = Hive.box(walletBoxName);
      await box.put(selectedWalletKey, selected.address);
    }
  }

  Widget _buildDrawerRow(Wallet wallet, bool isSelected, BuildContext context) {
    final isWatched = wallet.walletType == WalletType.tracking;
    final textColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.white;
    final subColor =
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
              const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: _buildAccountAvatar(wallet, isSelected, 36),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  wallet.walletName,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
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
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  WalletUtils.getAddressForDisplay(wallet.address),
                  style: TextStyle(
                    fontSize: 12,
                    color: subColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              if (wallet.walletType == WalletType.sgnus)
                GeniusBalanceDisplay(
                  useMinions: true,
                  fontSize: 12,
                  isShowSuffix: true,
                  fontColor: subColor,
                )
              else
                Text(
                  '${wallet.balance} ${wallet.currencySymbol}',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          onTap: () => Navigator.of(context).pop(wallet),
        ),
      ),
    );
  }

  Widget _buildAccountAvatar(Wallet wallet, bool isSelected, double size) {
    final isWatched = wallet.walletType == WalletType.tracking;
    final borderColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.transparent;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: borderColor, // Outer ring / border effect
      ),
      padding: const EdgeInsets.all(2), // border width
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.greenAccent,
        ),
        child: Center(
          // ✅ Ensures perfect centering
          child: isWatched
              ? const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 20,
                  color: GeniusWalletColors.deepBlueTertiary,
                )
              : SizedBox(
                  height: 20, // match icon height
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      wallet.walletName.isNotEmpty
                          ? wallet.walletName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.0, // tighter vertical alignment
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            final connection = snapshot.data;
            final wallets = [...state.wallets];

            // TODO: Can we insert this wallet in genius_api?, We would need to be mindful if the connection drops though
            if (connection != null && connection.isConnected) {
              wallets.insert(
                0,
                Wallet(
                  walletName: 'Super Genius Wallet',
                  walletType: WalletType.sgnus,
                  address: connection.sgnusAddress,
                  currencySymbol: 'minions',
                  transactions: [],
                  coinType: -1,
                  balance: 0,
                ),
              );
            }

            if (wallets.isEmpty) {
              return const Center(
                child: Text("You have no wallets!",
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
              );
            }

            selectedWallet ??= wallets.firstWhere(
              (w) => w.address == savedWalletAddress,
              orElse: () => widget.initialSelected ?? wallets.first,
            );

            return GestureDetector(
              onTap: () => _showAccountDrawer(wallets),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAccountAvatar(selectedWallet!, false, 25),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        selectedWallet!.walletName,
                        style: const TextStyle(fontSize: 14),
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
      },
    );
  }
}
