import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_balance_display.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
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
    if (!mounted) return;
    setState(() {
      savedWalletAddress = address;
    });
  }

  void _showAccountDrawer(List<Wallet> wallets) async {
    final walletCubit = context.read<WalletDetailsCubit>();
    final List<Widget> walletRows = [];
    for (int i = 0; i < wallets.length; i++) {
      walletRows.add(_buildDrawerRow(
        wallets[i],
        wallets[i].walletName == selectedWallet?.walletName,
        context,
      ));
      if (i < wallets.length - 1) {
        walletRows.add(const Divider(height: 1, color: Colors.white12));
      }
    }

    if (wallets.length < 3) {
      walletRows.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "Add more wallets to manage your assets",
            style: TextStyle(
                fontSize: 15,
                color: Colors.white54,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
      ));
    }

    final selected = await ResponsiveDrawer.show<Wallet>(
      context: context,
      title: "Your Accounts",
      children: walletRows,
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.push('/landing_screen', extra: true);
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            foregroundColor: GeniusWalletColors.deepBlueTertiary,
            shadowColor: Colors.transparent,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: GeniusWalletGradient.greenBlueGreenGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              alignment: Alignment.center,
              height: 48,
              child: const Text(
                "Add Wallet",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black, // always black
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (selected != null && selected != selectedWallet) {
      setState(() => selectedWallet = selected);
      if (widget.onAccountSelected != null) {
        widget.onAccountSelected!(selected);
      }
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

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      hoverColor: Colors.greenAccent.withOpacity(0.08),
      onTap: () => Navigator.of(context).pop(wallet),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.greenAccent
              : GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
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
                          fontWeight: FontWeight.w500),
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
                      style: TextStyle(fontSize: 12, color: subColor),
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
                      '${wallet.balance} ${wallet.balance == 1 ? "minion" : "minions"}',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if ((wallet.address ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 18, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        wallet.address,
                        style: const TextStyle(
                          color: GeniusWalletColors.gray500,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy,
                          color: GeniusWalletColors.white, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: wallet.address));
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        showAppSnackBar(context, 'Address copied to clipboard',
                            duration: const Duration(seconds: 1));
                      },
                      tooltip: "Copy address",
                    ),
                  ],
                ),
              ),
          ],
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
        color: borderColor,
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.greenAccent,
        ),
        child: Center(
          child: isWatched
              ? const Icon(Icons.remove_red_eye_outlined,
                  size: 20, color: GeniusWalletColors.deepBlueTertiary)
              : SizedBox(
                  height: 20,
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
                        height: 1.0,
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
            if (connection != null && connection.isConnected) {
              wallets.insert(
                0,
                Wallet(
                  walletName: 'Super Genius Wallet',
                  walletType: WalletType.sgnus,
                  address: connection.sgnusAddress,
                  currencySymbol: 'minions',
                  coinType: TWCoinType.TWCoinTypeEthereum,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAccountAvatar(selectedWallet!, false, 25),
                    const SizedBox(width: 8),
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
