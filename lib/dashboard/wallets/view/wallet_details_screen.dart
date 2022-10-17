import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_dashboard.g.dart';
import 'package:genius_wallet/widgets/components/crypto_chart.g.dart';
import 'package:genius_wallet/widgets/components/transactions.g.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';
import 'package:genius_wallet/widgets/components/wallet_toggle.g.dart';

class WalletDetailsScreen extends StatelessWidget {
  const WalletDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        if (state.selectedWallet == null) {
          return const Center(
            child: Text('Error'),
          );
        }
        final selectedWallet = state.selectedWallet!;
        return Scaffold(
          body: AppScreenView(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    width: 80,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return BackButtonDashboard(constraints);
                      },
                    ),
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
                    height: 220,
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
