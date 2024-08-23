import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/transactions.g.dart';
import 'package:genius_wallet/widgets/components/wallet_information.g.dart';
import 'package:genius_wallet/widgets/components/wallet_toggle.g.dart';
import 'package:go_router/go_router.dart';

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
          isIncludeBackButton: true,
          title: state.selectedWallet?.walletName,
          child: Wrap(spacing: 20, runSpacing: 20, children: [
            BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
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
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return WalletToggle(
                              constraints,
                              ovrCoinName: selectedWallet.currencySymbol,
                              ovrWalletName: selectedWallet.walletName,
                              ovrShape: WalletUtils.currencySymbolToImage(
                                selectedWallet.currencySymbol,
                              ),
                              walletType: selectedWallet.walletType,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 240,
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return WalletInformation(constraints,
                                ovrYourbitcoinaddress:
                                    '${selectedWallet.walletType == WalletType.tracking ? 'Tracked' : 'Your'} ${selectedWallet.currencySymbol} Wallet Address',
                                ovrQuantity: selectedWallet.balance.toString(),
                                ovrCurrency: selectedWallet.currencySymbol,
                                ovrAddressField: selectedWallet.address,
                                walletType: selectedWallet.walletType);
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 370,
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Transactions(constraints);
                          },
                        ),
                      ),
                    ],
                  ));
            }),
            Container(
                width: 1000,
                height: 705,
                decoration: const BoxDecoration(
                  color: GeniusWalletColors.deepBlueCardColor,
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                ),
                child: const Center(
                  child: Text('Coming Soon'),
                ))
          ]));
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
                          ovrCoinName: selectedWallet.currencySymbol,
                          ovrWalletName: selectedWallet.walletName,
                          ovrShape: WalletUtils.currencySymbolToImage(
                            selectedWallet.currencySymbol,
                          ),
                          walletType: selectedWallet.walletType,
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
                        return WalletInformation(constraints,
                            ovrYourbitcoinaddress:
                                '${selectedWallet.walletType == WalletType.tracking ? 'Tracked' : 'Your'} ${selectedWallet.currencySymbol} Wallet Address',
                            ovrQuantity: selectedWallet.balance.toString(),
                            ovrCurrency: selectedWallet.currencySymbol,
                            ovrAddressField: selectedWallet.address,
                            walletType: selectedWallet.walletType);
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
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    MaterialButton(
                      padding: const EdgeInsets.only(
                          left: 24, top: 12, bottom: 12, right: 24),
                      color: Colors.red,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(
                              GeniusWalletConsts.borderRadiusButton))),
                      onPressed: () {
                        context
                            .read<GeniusApi>()
                            .deleteWallet(selectedWallet.address);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Wallet ${selectedWallet.walletName} deleted!')));
                        context.go('/dashboard');
                      },
                      child: const Text("Delete Wallet"),
                    )
                  ])
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
