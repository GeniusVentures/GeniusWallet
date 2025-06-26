import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/banxa/buy_gnus_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class DesktopTopBarLeftMenu extends StatelessWidget {
  const DesktopTopBarLeftMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final geniusApi = context.read<GeniusApi>();
    final WalletDetailsCubit walletDetailsCubit =
        context.read<WalletDetailsCubit>();

    final TransactionsCubit transactionsCubit =
        context.read<TransactionsCubit>();

    return Container(
      height: GeniusWalletConsts.appBarHeight,
      color: GeniusWalletColors.deepBlueTertiary,
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Account Dropdown only
          const Row(children: [
            SizedBox(width: 8),
            SizedBox(width: 155, child: AccountDropdownSelector()),
          ]),
          // Right side - Network, Connect Button, and Buy Button
          Row(children: [
            const NetworkDropdownSelector(),
            const SizedBox(width: 8),
            ReownConnectButton(
                walletAddress:
                    walletDetailsCubit.state.selectedWallet?.address ?? "",
                geniusApi: geniusApi,
                walletDetailsCubit: walletDetailsCubit,
                transactionsCubit: transactionsCubit),
            const SizedBox(width: 8),
            BuyGnusButton(
              userEmail: '',
              walletAddress:
                  walletDetailsCubit.state.selectedWallet?.address ?? "",
            ),
            const SizedBox(width: 8),
          ])
        ],
      ),
    );
  }
}
