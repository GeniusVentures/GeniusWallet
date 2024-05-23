import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/home/widgets/horizontal_wallets_scrollview.dart';
import 'package:genius_wallet/dashboard/home/widgets/wallet_distribution.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/theme/genius_wallet_text.dart';
import 'package:genius_wallet/widgets/components/markets_module.g.dart';
import 'package:genius_wallet/widgets/components/transactions.g.dart';
import 'package:genius_wallet/widgets/components/wallets_overview.g.dart';
import 'package:genius_wallet/widgets/desktop/asset_percentage_card.g.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScreenView(
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          switch (state.subscribeToWalletStatus) {
            case AppStatus.loaded:
              if (GeniusBreakpoints.useDesktopLayout(context)) {
                return const OnSuccessfulDesktop();
              }
              return const OnSuccessful();
            case AppStatus.error:
              return const Center(
                child: Text('Something went wrong!'),
              );
            case AppStatus.loading:
            default:
              return const LoadingScreen();
          }
        },
      ),
    );
  }
}

class OnSuccessfulDesktop extends StatelessWidget {
  const OnSuccessfulDesktop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.horizontalDesktopPadding,
          vertical: GeniusWalletConsts.verticalDesktopPadding),
      child: Wrap(
          spacing: GeniusWalletConsts.itemSpacing,
          runSpacing: GeniusWalletConsts.itemSpacing,
          children: [
            SizedBox(
                width: 1170,
                child: Wrap(
                  spacing: GeniusWalletConsts.itemSpacing,
                  runSpacing: GeniusWalletConsts.itemSpacing,
                  children: [
                    SizedBox(
                      height: 350,
                      width: 350,
                      child: LayoutBuilder(builder: (context, constraints) {
                        return BlocBuilder<AppBloc, AppState>(
                          builder: (context, state) {
                            return WalletsOverview(
                              constraints,
                              ovrTotalWalletBalance: WalletUtils.totalBalance(
                                context.read<GeniusApi>(),
                                state.wallets,
                              ).toString(),
                              ovrWalletCounter: state.wallets.length.toString(),
                              ovrTransactionCounter:
                                  WalletUtils.getTransactionNumber(
                                          state.wallets)
                                      .toString(),
                            );
                          },
                        );
                      }),
                    ),
                    SizedBox(
                      width: 800,
                      child: Wrap(
                        runSpacing: GeniusWalletConsts.itemSpacing,
                        children: [
                          const HorizontalWalletsScrollview(),
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: GeniusWalletConsts.itemSpacing,
                            runSpacing: GeniusWalletConsts.itemSpacing,
                            children: [
                              const SizedBox(
                                  height: 230,
                                  width: 350 - GeniusWalletConsts.itemSpacing,
                                  child: WalletDistribution()),
                              SizedBox(
                                height: 230,
                                width: 450,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return AssetPercentageCard(constraints,
                                      ovrsend: 'Send',
                                      ovrSendto: 'Send To',
                                      ovrAmount: 'Amount',
                                      ovrWallet: 'Wallet',
                                      sendAmount: '12',
                                      toAddress: 'asdfg',
                                      ovrBTC: '1',
                                      ovrReceiveBitcoin: 'Receive Bitcoin');
                                }),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Wrap(
                        spacing: GeniusWalletConsts.itemSpacing,
                        runSpacing: GeniusWalletConsts.itemSpacing,
                        // TODO: Wire the bitcoin chart here, "wallet distibution" is a empty placeholder
                        children: [
                          const SizedBox(
                            height: 500,
                            width: 700,
                            child: WalletDistribution(),
                          ),
                          SizedBox(
                            height: 500,
                            width: 450,
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return MarketsModule(constraints);
                              },
                            ),
                          )
                        ]),
                  ],
                )),
            // TODO: Wire the transactions here, "wallet distibution" is a empty placeholder
            const SizedBox(
              height: 865,
              width: 350,
              child: WalletDistribution(),
              // child: LayoutBuilder(
              //   builder: (BuildContext context, BoxConstraints constraints) {
              //     return Transactions(constraints);
              //   },
              // )
            )
          ]),
    );
  }
}

class OnSuccessful extends StatelessWidget {
  const OnSuccessful({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            if (GeniusBreakpoints.useDesktopLayout(context)) {
              return const SizedBox();
            }
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Dashboard',
                style: TextStyle(fontSize: GeniusWalletFontSize.sectionHeader),
              ),
            );
          }),
          const SizedBox(height: 14),
          SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(builder: (context, constraints) {
              return BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  return WalletsOverview(
                    constraints,
                    ovrTotalWalletBalance: WalletUtils.totalBalance(
                      context.read<GeniusApi>(),
                      state.wallets,
                    ).toString(),
                    ovrWalletCounter: state.wallets.length.toString(),
                    ovrTransactionCounter:
                        WalletUtils.getTransactionNumber(state.wallets)
                            .toString(),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(GeniusWalletText.wallets,
                    style: TextStyle(
                        fontSize: GeniusWalletFontSize.sectionHeader)),
                MaterialButton(
                  onPressed: () {
                    context.push('/landing_screen');
                  },
                  child: const Text(
                    'Add Wallet',
                    style: TextStyle(color: GeniusWalletColors.blue500),
                  ),
                ),
              ],
            ),
          ),
          const HorizontalWalletsScrollview(),
          const SizedBox(height: 14),
          SizedBox(
            height: 500,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return MarketsModule(constraints);
              },
            ),
          ),
        ],
      ),
    );
  }
}
