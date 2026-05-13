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

  Future<void> _showAccountDrawer(List<Wallet> wallets) async {
    final walletCubit = context.read<WalletDetailsCubit>();

    final selected = await ResponsiveDrawer.show<Wallet>(
      context: context,
      title: "Your Accounts",
      child: ListView.builder(
        itemBuilder: (context, i) => _buildDrawerRow(wallets[i],
            isSelected: wallets[i].walletName == selectedWallet?.walletName),
        itemCount: wallets.length,
      ),
      footer: _AddWalletButton(
        onPressed: () => context.push('/landing_screen', extra: true),
      ),
    );

    if (selected == null || selected == selectedWallet) return;

    setState(() => selectedWallet = selected);
    widget.onAccountSelected?.call(selected);
    walletCubit.selectWallet(selected);
    await Hive.box(walletBoxName).put(selectedWalletKey, selected.address);
  }

  Widget _buildDrawerRow(
    Wallet wallet, {
    required bool isSelected,
  }) {
    final isWatched = wallet.walletType == WalletType.tracking;

    final textColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.white;

    final subColor =
        isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.grey;

    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.greenAccent,
      tileColor: GeniusWalletColors.deepBlueCardColor,
      hoverColor: Colors.greenAccent.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
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
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    WalletUtils.getAddressForDisplay(wallet.address),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: subColor,
                    ),
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
            if (wallet.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
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
                    tooltip: 'Copy address',
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: GeniusWalletColors.white,
                    ),
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
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Wallet wallet,
      {required bool isSelected, required double size}) {
    final isWatched = wallet.walletType == WalletType.tracking;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor:
          isSelected ? GeniusWalletColors.deepBlueTertiary : Colors.transparent,
      child: CircleAvatar(
        radius: size / 2 - 2,
        backgroundColor: Colors.greenAccent,
        child: isWatched
            ? const Icon(Icons.remove_red_eye_outlined,
                size: 20, color: GeniusWalletColors.deepBlueTertiary)
            : Text(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SGNUSConnection>(
      stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
      builder: (context, snapshot) {
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            final wallets = [...state.wallets];
            final connection = snapshot.data;
            if (connection?.isConnected == true) {
              wallets.insert(
                0,
                Wallet(
                  walletName: 'Super Genius Wallet',
                  walletType: WalletType.sgnus,
                  address: connection!.sgnusAddress,
                  currencySymbol: 'minions',
                  coinType: TWCoinType.TWCoinTypeEthereum,
                  balance: 0,
                ),
              );
            }
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
            return Material(
              child: InkWell(
                borderRadius: BorderRadius.circular(14.0),
                onTap: () => _showAccountDrawer(wallets),
                child: Ink(
                  decoration: BoxDecoration(
                      color: GeniusWalletColors.deepBlueSecondary),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.0,
                    children: [
                      _buildAvatar(selectedWallet!,
                          isSelected: false, size: 25),
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
              ),
            );
          },
        );
      },
    );
  }
}

class _AddWalletButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddWalletButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
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
          child: const SizedBox.expand(
            child: Center(
              child: Text(
                "Add Wallet",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
