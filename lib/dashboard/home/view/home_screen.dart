import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_chart.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_holdings_progress_list.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/home/widgets/containers.dart';
import 'package:genius_wallet/dashboard/home/widgets/horizontal_wallets_scrollview.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/view/wallet_details_screen.dart';
import 'package:genius_wallet/widgets/components/wallets_overview.g.dart';

double gridSpacing = 8;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> onRefresh() async {
      final appBloc = context.read<AppBloc>();

      // refresh the account data / wallets when swiping down in the app
      if (appBloc.state.accountStatus != AppStatus.loading) {
        appBloc.add(FetchAccount());
        appBloc.add(SubscribeToWallets());
        // MINT TOKENS ON PULL DOWN OF APP
        //appBloc.add(FFITestEvent());
      }
    }

    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse, // Enable mouse drag for desktop
          },
        ),
        child: RefreshIndicator(
            backgroundColor: GeniusWalletColors.deepBlueTertiary,
            onRefresh: onRefresh,
            color: GeniusWalletColors.lightGreenPrimary,
            child: SafeArea(
                child: Stack(fit: StackFit.expand, children: [
              BlocBuilder<AppBloc, AppState>(builder: (context, state) {
                double width = MediaQuery.of(context).size.width;
                bool is3Column = width > 1500;
                bool is2Column = width > 1150;

                if (state.subscribeToWalletStatus == AppStatus.loaded &&
                    state.accountStatus == AppStatus.loaded) {
                  return ListView(shrinkWrap: true, children: [
                    if (is3Column) ...[
                      const ThreeColumnDashboardView()
                    ] else if (is2Column) ...[
                      const TwoColumnDashBoardView()
                    ] else ...[
                      const OneColumnDashBoardView()
                    ]
                  ]);
                }
                if (state.subscribeToWalletStatus == AppStatus.error ||
                    state.accountStatus == AppStatus.error) {
                  return const Center(
                    child: Text('Something went wrong!'),
                  );
                }

                return const LoadingScreen();
              }),
            ]))));
  }
}

class ThreeColumnDashboardView extends StatelessWidget {
  const ThreeColumnDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height - 24;
    final topRowHeight = availableHeight * .45;
    const topRowMinHeight = 300.0;
    final bottomRowHeight = availableHeight * .55;
    const bottomRowMinHeight = 380.0;
    const secondRowMinHeight = topRowMinHeight + bottomRowMinHeight;

    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Column(children: [
          SizedBox(height: gridSpacing),
          Row(children: [
            Expanded(
                flex: 3,
                child: Column(children: [
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: topRowMinHeight,
                        maxHeight: topRowHeight < topRowMinHeight
                            ? topRowMinHeight
                            : topRowHeight,
                      ),
                      child: const Row(children: [
                        Expanded(child: OverviewDashboardView()),
                        Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WalletDashboardView(),
                                  Expanded(
                                      child: Row(children: [
                                    Expanded(
                                        child: ContributionsDashboardView()),
                                    Expanded(child: SendReceiveDashboardView())
                                  ]))
                                ]))
                      ])),
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: bottomRowMinHeight,
                        maxHeight: bottomRowHeight < bottomRowMinHeight
                            ? bottomRowMinHeight
                            : bottomRowHeight,
                      ),
                      child: const Row(children: [
                        Expanded(flex: 2, child: ChartDashboardView()),
                        Expanded(flex: 1, child: MarketsDashboardView())
                      ])),
                ])),
            ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  minHeight: secondRowMinHeight,
                  maxHeight: availableHeight < secondRowMinHeight
                      ? secondRowMinHeight
                      : availableHeight,
                ),
                child: TransactionsDashboardView())
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
        child: const Column(children: [
          SizedBox(
            height: 350,
            child: Row(children: [
              Expanded(flex: 1, child: OverviewDashboardView()),
              Expanded(
                  flex: 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WalletDashboardView(),
                        Expanded(
                            child: Row(children: [
                          Expanded(child: ContributionsDashboardView()),
                          Expanded(child: SendReceiveDashboardView())
                        ]))
                      ]))
            ]),
          ),
          SizedBox(
              height: 480,
              child: Row(children: [
                Expanded(flex: 2, child: ChartDashboardView()),
                Expanded(flex: 1, child: MarketsDashboardView())
              ])),
          SizedBox(height: 600, child: TransactionsDashboardView()),
        ]));
  }
}

class OneColumnDashBoardView extends StatelessWidget {
  const OneColumnDashBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 600, child: WalletDetailsScreen()),
              SizedBox(height: 260, child: OverviewDashboardView()),
              WalletDashboardView(),
              SizedBox(height: 400, child: ChartDashboardView()),
              SizedBox(height: 480, child: MarketsDashboardView()),
              SizedBox(height: 300, child: ContributionsDashboardView()),
              SizedBox(height: 300, child: SendReceiveDashboardView()),
              SizedBox(height: 600, child: TransactionsDashboardView()),
            ]));
  }
}

class OverviewDashboardView extends StatelessWidget {
  const OverviewDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final txController = context.read<GeniusApi>().getTransactionsController();

    return DashboardScrollContainer(
      child: StreamBuilder<List<Transaction>>(
        stream: txController.stream,
        builder: (context, snapshot) {
          final controllerTransactions = snapshot.data ?? [];

          return BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              final totalTxCount =
                  WalletUtils.getTransactionNumber(state.wallets) +
                      controllerTransactions.length;

              return WalletsOverview(
                geniusApi: context.read<GeniusApi>(),
                account: state.account,
                totalBalance: WalletUtils.totalBalance(
                  context.read<GeniusApi>(),
                  state.wallets,
                ).toStringAsFixed(5),
              );
            },
          );
        },
      ),
    );
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

class TransactionsDashboardView extends StatelessWidget {
  const TransactionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScrollContainer(
        child: BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      return const TransactionsSlimView();
    }));
  }
}

class MarketsDashboardView extends StatelessWidget {
  const MarketsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CoinGeckoCoin>>(
      future: getDashboardMarketCoins(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading
        } else if (snapshot.hasError) {
          return const Center(child: Text("Failed to load market coins"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No market data available"));
        }

        // Successfully fetched coins
        return DashboardScrollContainer(
          child: DashboardMarkets(
            title: 'Markets',
            coins: snapshot.data!, // Use the fetched coin list
          ),
        );
      },
    );
  }
}

class ChartDashboardView extends StatelessWidget {
  const ChartDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewContainer(
        child: Flexible(
            child: DashboardChart(
                title: "Bitcoin Chart",
                coinGeckoCoinId: 'bitcoin',
                tokenSymbol: 'btc',
                tokenDecimals: '8')));
  }
}

class ContributionsDashboardView extends StatelessWidget {
  const ContributionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScrollContainer(
        child: DashboardHoldingsProgressList(
      holdings: {
        'BTC': 40,
        'ETH': 25,
        'USDT': 15,
        'BNB': 10,
        'XRP': 5,
        'ADA': 3,
        'DOT': 2,
      },
    ));
  }
}

class SendReceiveDashboardView extends StatelessWidget {
  const SendReceiveDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewContainer(
        child: Flexible(
            child: AutoSizeText('Send / Receive - Coming Soon',
                style: TextStyle(color: Colors.grey))));
  }
}
