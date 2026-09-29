import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The desktop top bar's one account chip. Names the active wallet, from
/// [WalletDetailsCubit] like the header pill, and opens the drawer where
/// both the wallet and the node's SDK account are chosen.
class AccountSwitcher extends StatelessWidget {
  const AccountSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final wallets = state.wallets;
        if (wallets.isEmpty) {
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
          return Center(
            child: Text(
              "You have no wallets!",
              style: TextStyle(fontSize: 16, color: gw.textPrimary70),
            ),
          );
        }
        final selectedWallet =
            context.watch<WalletDetailsCubit>().state.selectedWallet ??
            wallets.first;
        // Every SDK account shares one generic name, so its address is what
        // tells them apart.
        final label =
            selectedWallet.walletType == WalletType.sgnus ||
                selectedWallet.walletName.isEmpty
            ? WalletUtils.getAddressForDisplay(selectedWallet.address)
            : selectedWallet.walletName;
        final selectedSDKAccount = state.selectedSDKAccount;
        final nodeStatus = selectedSDKAccount != null
            ? 'Node running as ${AppBloc.sdkAccountName(selectedSDKAccount, state.sdkAccountLinks, state.wallets)}'
            : 'Node not running';
        return Tooltip(
          message: 'Sending from $label · $nodeStatus',
          child: TextButton(
            style: navContextChipStyle(context),
            onPressed: () => AccountDrawer.show(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: GeniusWalletConsts.space4,
              children: [
                AccountAvatar(
                  wallet: selectedWallet,
                  isSelected: false,
                  size: 25,
                ),
                if (MediaQuery.sizeOf(context).width >= GeniusBreakpoints.small)
                  // Flexible: the desktop bar squeezes this label before it
                  // lets the row overflow.
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
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
