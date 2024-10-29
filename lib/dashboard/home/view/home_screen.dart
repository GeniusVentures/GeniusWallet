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
import 'package:genius_wallet/widgets/components/wallets_overview.g.dart';
import 'package:genius_wallet/widgets/desktop/asset_percentage_card.g.dart';
import 'package:go_router/go_router.dart';

double gridSpacing = 8;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> onRefresh() async {
      final appBloc = context.read<AppBloc>();

      // refresh the account data when swiping down in the app
      if (appBloc.state.accountStatus != AppStatus.loading) {
        appBloc.add(FetchAccount());
      }
    }

    return AppScreenView(
      handleRefresh: onRefresh,
      body: BlocBuilder<AppBloc, AppState>(builder: (context, state) {
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;
        bool is3Column = width > 1500 && height > 850;
        bool is2Column = width > 1150 && height > 500;

        if (state.subscribeToWalletStatus == AppStatus.loaded &&
            state.accountStatus == AppStatus.loaded) {
          return Center(
              child: ListView(shrinkWrap: true, children: [
            if (is3Column) ...[
              ThreeColumnDashboardView()
            ] else if (is2Column) ...[
              TwoColumnDashBoardView()
            ] else ...[
              OneColumnDashBoardView()
            ]
          ]));
        }
        if (state.subscribeToWalletStatus == AppStatus.error ||
            state.accountStatus == AppStatus.error) {
          return const Center(
            child: Text('Something went wrong!'),
          );
        }

        return const LoadingScreen();
      }),
    );
  }
}

class ThreeColumnDashboardView extends StatelessWidget {
  const ThreeColumnDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Column(children: [
          SizedBox(height: gridSpacing),
          Row(children: [
            Expanded(
                flex: 3,
                child: Column(children: [
                  SizedBox(
                      height: 400,
                      child: Row(children: [
                        Expanded(child: OverviewDashboardView()),
                        Expanded(
                            flex: 2,
                            child: Column(children: [
                              WalletDashboardView(),
                              Expanded(
                                  child: Row(children: [
                                Expanded(child: ContributionsDashboardView()),
                                Expanded(child: SendReceiveDashboardView())
                              ]))
                            ]))
                      ])),
                  SizedBox(
                      height: 480,
                      child: Row(children: [
                        Expanded(flex: 2, child: ChartDashboardView()),
                        Expanded(flex: 1, child: MarketsDashboardView())
                      ])),
                ])),
            SizedBox(
                width: 400, height: 888, child: TransactionsDashboardView())
          ])
        ]));
  }
}

class TwoColumnDashBoardView extends StatelessWidget {
  const TwoColumnDashBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Column(children: [
          SizedBox(
            height: 350,
            child: Row(children: [
              Expanded(flex: 1, child: OverviewDashboardView()),
              Expanded(
                  flex: 2,
                  child: Column(children: [
                    WalletDashboardView(),
                    Expanded(
                        child: Row(children: [
                      Expanded(child: ContributionsDashboardView()),
                      Expanded(child: SendReceiveDashboardView())
                    ]))
                  ]))
            ]),
          ),
          SizedBox(height: 400, child: TransactionsDashboardView()),
          SizedBox(
              height: 480,
              child: Row(children: [
                Expanded(flex: 2, child: ChartDashboardView()),
                Expanded(flex: 1, child: MarketsDashboardView())
              ])),
        ]));
  }
}

class OneColumnDashBoardView extends StatelessWidget {
  const OneColumnDashBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 350, child: OverviewDashboardView()),
          WalletDashboardView(),
          SizedBox(height: 400, child: TransactionsDashboardView()),
          SizedBox(height: 300, child: ContributionsDashboardView()),
          SizedBox(height: 300, child: SendReceiveDashboardView()),
          SizedBox(height: 400, child: ChartDashboardView()),
          SizedBox(height: 400, child: MarketsDashboardView()),
        ]));
  }
}

class OverviewDashboardView extends StatelessWidget {
  const OverviewDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardViewNoFlexContainer(child: BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return WalletsOverview(
          geniusApi: context.read<GeniusApi>(),
          account: state.account,
          totalBalance: WalletUtils.totalBalance(
            context.read<GeniusApi>(),
            state.wallets,
          ).toStringAsFixed(5),
          numberOfWallets: state.wallets.length.toString(),
          numberOfTransactions:
              WalletUtils.getTransactionNumber(state.wallets).toString(),
        );
      },
    ));
  }
}

class WalletDashboardView extends StatelessWidget {
  const WalletDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 120,
        child: DashboardViewNoWrapperContainer(
            child: HorizontalWalletsScrollview()));
  }
}

class MarketsDashboardView extends StatelessWidget {
  const MarketsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardViewContainer(
        child: Text('markets', style: TextStyle(color: Colors.white)));
  }
}

class TransactionsDashboardView extends StatelessWidget {
  const TransactionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardViewContainer(
        child: Text('transactions', style: TextStyle(color: Colors.white)));
  }
}

class ChartDashboardView extends StatelessWidget {
  const ChartDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardViewContainer(
        child: Text('chart', style: TextStyle(color: Colors.white)));
  }
}

class ContributionsDashboardView extends StatelessWidget {
  const ContributionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardViewContainer(
        child: Text('contributions', style: TextStyle(color: Colors.white)));
  }
}

class SendReceiveDashboardView extends StatelessWidget {
  const SendReceiveDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardViewContainer(
        child: Text('send receive', style: TextStyle(color: Colors.white)));
  }
}

class DashboardViewContainer extends StatelessWidget {
  final Widget child;
  const DashboardViewContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard))),
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Row(children: [child])
                ]))));
  }
}

class DashboardViewNoWrapperContainer extends StatelessWidget {
  final Widget child;
  const DashboardViewNoWrapperContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard))),
            child: child));
  }
}

class DashboardViewNoFlexContainer extends StatelessWidget {
  final Widget child;
  const DashboardViewNoFlexContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Container(
            decoration: const BoxDecoration(
                color: GeniusWalletColors.deepBlueCardColor,
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusCard))),
            child: Padding(padding: const EdgeInsets.all(24), child: child)));
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
                child: Wrap(
              spacing: GeniusWalletConsts.itemSpacing,
              runSpacing: GeniusWalletConsts.itemSpacing,
              children: [
                SizedBox(
                  height: 350,
                  width: MediaQuery.of(context).size.width * .55,
                  child: Wrap(
                    runSpacing: GeniusWalletConsts.itemSpacing,
                    children: [
                      const HorizontalWalletsScrollview(),
                      // TODO wire up send / receive and wallet distribution
                      // Wrap(
                      //   direction: Axis.horizontal,
                      //   spacing: GeniusWalletConsts.itemSpacing,
                      //   runSpacing: GeniusWalletConsts.itemSpacing,
                      //   children: [
                      //     const SizedBox(
                      //         height: 230, child: WalletDistribution()),
                      //     SizedBox(
                      //       height: 230,
                      //       width: 450,
                      //       child:
                      //           LayoutBuilder(builder: (context, constraints) {
                      //         return AssetPercentageCard(constraints,
                      //             ovrsend: 'Send',
                      //             ovrSendto: 'Send To',
                      //             ovrAmount: 'Amount',
                      //             ovrWallet: 'Wallet',
                      //             sendAmount: '12',
                      //             toAddress: 'asdfg',
                      //             ovrBTC: '1',
                      //             ovrReceiveBitcoin: 'Receive Bitcoin');
                      //       }),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
                // Wrap(
                //     spacing: GeniusWalletConsts.itemSpacing,
                //     runSpacing: GeniusWalletConsts.itemSpacing,
                //     // TODO: Wire the bitcoin chart here, "wallet distibution" is a empty placeholder
                //     children: [
                //       const SizedBox(
                //         height: 500,
                //         width: 700,
                //         child: WalletDistribution(),
                //       ),
                //       SizedBox(
                //         height: 500,
                //         width: 450,
                //         child: LayoutBuilder(
                //           builder: (BuildContext context,
                //               BoxConstraints constraints) {
                //             return MarketsModule(constraints);
                //           },
                //         ),
                //       )
                //     ]),
              ],
            )),
            // TODO: Wire the transactions here, "wallet distibution" is a empty placeholder
            // const SizedBox(
            //   height: 865,
            //   width: 350,
            //   child: LayoutBuilder(
            //     builder: (BuildContext context, BoxConstraints constraints) {
            //       return Transactions(constraints);
            //     },
            //   )
            // )
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
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Dashboard',
                style: TextStyle(fontSize: GeniusWalletFontSize.sectionHeader),
              ),
            );
          }),
          const SizedBox(height: 14),
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
