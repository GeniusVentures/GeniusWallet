import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/dashboard/transactions/sgnus_transactions_screen.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/screens/loading_screen.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/view/genius_wallet_details_screen.dart';
import 'package:genius_wallet/wallets/view/wallet_details_screen.dart';
import 'package:genius_wallet/components/wallet_overview.dart';

const double gridSpacing = 12;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
        final isDesktopLayout =
            MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium;

        if (state.subscribeToWalletStatus == AppStatus.loaded &&
            state.accountStatus == AppStatus.loaded) {
          if (isDesktopLayout) {
            return const ResponsiveDashboardView();
          }
          return const OneColumnDashBoardView();
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

class ResponsiveDashboardView extends StatelessWidget {
  const ResponsiveDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final is3Column = constraints.maxWidth > GeniusBreakpoints.xxl;

      if (is3Column) {
        return _threeColumnLayout();
      }
      return _twoColumnLayout();
    });
  }

  Widget _threeColumnLayout() {
    const topRowMinHeight = 300.0;
    const bottomRowMinHeight = 380.0;
    const totalMinHeight = topRowMinHeight + bottomRowMinHeight;

    return Padding(
      padding: EdgeInsets.all(gridSpacing / 2),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Column(children: [
            Expanded(
              flex: 45,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: topRowMinHeight),
                child: const _OverviewContributionsRow(),
              ),
            ),
            Expanded(
              flex: 55,
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(minHeight: bottomRowMinHeight),
                child: const _ChartMarketsRow(),
              ),
            ),
          ]),
        ),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
              minHeight: totalMinHeight,
            ),
            child: const TransactionsDashboardView(),
          ),
        ),
      ]),
    );
  }

  Widget _twoColumnLayout() {
    return Padding(
      padding: EdgeInsets.all(gridSpacing / 2),
      child: Column(children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300),
          child: const _OverviewContributionsRow(),
        ),
        Expanded(
          child: Row(children: [
            Expanded(
              child: Column(children: [
                const Expanded(
                  child: ChartDashboardView(),
                ),
                const Expanded(
                  child: MarketsDashboardView(),
                ),
              ]),
            ),
            const Expanded(child: TransactionsDashboardView()),
          ]),
        ),
      ]),
    );
  }
}

class _OverviewContributionsRow extends StatelessWidget {
  const _OverviewContributionsRow();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(flex: 2, child: OverviewDashboardView()),
      const Expanded(flex: 3, child: ContributionsDashboardView()),
    ]);
  }
}

class _ChartMarketsRow extends StatelessWidget {
  const _ChartMarketsRow();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(flex: 3, child: ChartDashboardView()),
      const Expanded(flex: 2, child: MarketsDashboardView()),
    ]);
  }
}

class OneColumnDashBoardView extends StatelessWidget {
  const OneColumnDashBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
          builder: (context, walletState) {
        final selectedWallet = walletState.selectedWallet;
        final isSgnusWallet = selectedWallet?.walletType == WalletType.sgnus;
        if (selectedWallet != null) {
          return SizedBox(
            height: constraints.maxHeight,
            child: isSgnusWallet
                ? const GeniusWalletDetailsScreen()
                : const WalletDetailsScreen(),
          );
        } else {
          return const Center(
            child: Text(
              "No Wallet selected",
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          );
        }
      });
    });
  }
}

class DashboardScrollContainer extends StatelessWidget {
  final Widget child;
  const DashboardScrollContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: EdgeInsets.all(gridSpacing), child: child),
    );
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
    return DashboardScrollContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            "Bitcoin Chart",
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Expanded(
            child: CryptoLiveChart(
              coinGeckoCoinId: 'bitcoin',
              tokenSymbol: 'btc',
              priceHeight: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class ContributionsDashboardView extends StatelessWidget {
  const ContributionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DashboardScrollContainer(
        child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
          builder: (context, walletState) {
            final selectedWallet = walletState.selectedWallet;
            return StreamBuilder<SGNUSConnection>(
              stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
              builder: (context, snapshot) {
                final connection = snapshot.data;
                return CoinsScreen(
                  isUseDivider: true,
                  isGnusWalletConnected: (connection?.walletAddress ?? false) ==
                      selectedWallet?.address,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
