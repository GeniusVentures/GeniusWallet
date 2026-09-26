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

/// The desktop top bar's wallet chip. It shows the selection held by
/// [WalletDetailsCubit], like the header pill, so a change made anywhere
/// (a delete included) reaches it.
class AccountDropdownSelector extends StatelessWidget {
  const AccountDropdownSelector({super.key});

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
        return Tooltip(
          message: "Select wallet",
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
                      selectedWallet.walletType == WalletType.sgnus
                          ? 'Super Genius'
                          : WalletUtils.getAddressForDisplay(
                              selectedWallet.address,
                            ),
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
