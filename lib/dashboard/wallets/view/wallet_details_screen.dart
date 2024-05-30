import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
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
        if (GeniusBreakpoints.useDesktopLayout(context)) {
          return const Desktop();
        }
        return const Mobile();
      },
    );
  }
}

class Desktop extends StatelessWidget {
  const Desktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
      return DesktopContainer(
          title: state.selectedWallet?.walletName,
          child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
              builder: (context, state) {
            final selectedWallet = state.selectedWallet!;
            return SizedBox(
                width: 500,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ));
          }));
    });
  }
}

class Mobile extends StatelessWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final selectedWallet = state.selectedWallet!;
        return Scaffold(
          backgroundColor: GeniusWalletColors.deepBlueTertiary,
          appBar: AppBar(
            backgroundColor: GeniusWalletColors.deepBlueTertiary,
          ),
          body: AppScreenView(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
