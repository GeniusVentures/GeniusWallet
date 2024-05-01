import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/back_button_dashboard.g.dart';
import 'package:genius_wallet/widgets/components/crypto_chart.g.dart';
import 'package:genius_wallet/widgets/components/transactions.g.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';
import 'package:genius_wallet/widgets/components/wallet_toggle.g.dart';

class WalletDetailsScreen extends StatelessWidget {
  const WalletDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        if (state.selectedWallet == null) {
          return const Center(
            child: Text('Error'),
          );
        }
        final selectedWallet = state.selectedWallet!;
        return Scaffold(
          backgroundColor: GeniusWalletColors.deepBlueTertiary,
          body: AppScreenView(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return BackButtonDashboard(constraints);
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 40,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return WalletToggle(
                          constraints,
                          ovrCoinName: selectedWallet.currencyName,
                          ovrWalletName: selectedWallet.walletName,
                          ovrShape: WalletUtils.currencySymbolToImage(
                            selectedWallet.currencySymbol,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 240,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return WalletInformation(
                          constraints,
                          ovrYourbitcoinaddress:
                              'Your ${selectedWallet.currencyName} Wallet Address',
                          ovrQuantity: selectedWallet.balance.toString(),
                          ovrCurrency: selectedWallet.currencySymbol,
                          ovrAddressField: selectedWallet.address,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 370,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Transactions(constraints);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 720,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return CryptoChart(constraints);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
