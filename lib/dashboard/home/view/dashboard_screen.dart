import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_scren.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/screens/loading_screen.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_chart.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/home/widgets/containers.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_wallet_details_screen.dart';
import 'package:genius_wallet/wallets/view/wallet_details_screen.dart';
import 'package:genius_wallet/components/wallets_overview.g.dart';

double gridSpacing = 8;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Delay execution until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletCubit = context.read<WalletDetailsCubit>();

      if (walletCubit.state.selectedWallet != null &&
          walletCubit.state.selectedNetwork != null) {
        walletCubit.getCoins();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    ]));
  }
}

class ThreeColumnDashboardView extends StatelessWidget {
  const ThreeColumnDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.of(context).size.height -
        GeniusWalletConsts.appBarHeight -
        18;
    final topRowHeight = availableHeight * .45;
    const topRowMinHeight = 300.0;
    final bottomRowHeight = availableHeight * .55;
    const bottomRowMinHeight = 380.0;
    const secondRowMinHeight = topRowMinHeight + bottomRowMinHeight;

    return Padding(
        padding: EdgeInsets.all(gridSpacing),
        child: Column(children: [
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
                                  Expanded(
                                      child: Row(children: [
                                    Expanded(
                                        child: ContributionsDashboardView()),
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
                child: const TransactionsDashboardView())
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
                        Expanded(
                            child: Row(children: [
                          Expanded(child: ContributionsDashboardView()),
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
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, walletState) {
      final selectedWallet = walletState.selectedWallet;
      final isSgnusWallet = selectedWallet?.walletType == WalletType.sgnus;
      if (selectedWallet != null) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              height: MediaQuery.of(context).size.height - 175,
              child: isSgnusWallet
                  ? const GeniusWalletDetailsScreen()
                  : const WalletDetailsScreen()),
        ]);
      } else {
        return const Center(
          child: Text(
            "No Wallet selected",
            style: TextStyle(fontSize: 32, color: Colors.white),
          ),
        );
      }
    });
  }
}

class OverviewDashboardView extends StatelessWidget {
  const OverviewDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScrollContainer(child: BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return WalletsOverview(
          geniusApi: context.read<GeniusApi>(),
          account: state.account,
        );
      },
    ));
  }
}

class TransactionsDashboardView extends StatelessWidget {
  const TransactionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScrollContainer(
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, walletState) {
          final selectedWallet = walletState.selectedWallet;
          final isSgnusWallet = selectedWallet?.walletType == WalletType.sgnus;

          return isSgnusWallet
              ? const SgnusTransactionsScreen()
              : const TransactionsStream();
        },
      ),
    );
  }
}

class MarketsDashboardView extends StatelessWidget {
  const MarketsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureStateWidget<List<CoinGeckoCoin>>(
      future: getDashboardMarketCoins(),
      error: const Center(child: Text("Failed to load market coins")),
      onData: (coins) {
        if (coins.isEmpty) {
          return const Center(child: Text("No market data available"));
        }
        return DashboardScrollContainer(
          child: DashboardMarkets(
            title: 'Markets',
            coins: coins,
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
  @override
  Widget build(BuildContext context) {
    return DashboardScrollContainer(
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, walletState) {
          final selectedWallet = walletState.selectedWallet;
          return StreamBuilder<SGNUSConnection>(
            stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
            builder: (context, snapshot) {
              final connection = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Flexible(
                  //     child: AutoSizeText('Holdings',
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //         style: TextStyle(color: Colors.white, fontSize: 12))),
                  Expanded(
                    child: CoinsScreen(
                      isUseDivider: true,
                      isGnusWalletConnected:
                          (connection?.walletAddress ?? false) ==
                              selectedWallet?.address,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    //     child: DashboardHoldingsProgressList(
    //   holdings: {
    //     'BTC': 40,
    //     'ETH': 25,
    //     'USDT': 15,
    //     'BNB': 10,
    //     'XRP': 5,
    //     'ADA': 3,
    //     'DOT': 2,
    //   },
    // ));
  }
}
