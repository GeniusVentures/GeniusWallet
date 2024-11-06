import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/dashboard/home/widgets/containers.dart';
import 'package:genius_wallet/dashboard/home/widgets/horizontal_wallets_scrollview.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
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
                  return Center(
                      child: ListView(shrinkWrap: true, children: [
                    if (is3Column) ...[
                      const ThreeColumnDashboardView()
                    ] else if (is2Column) ...[
                      const TwoColumnDashBoardView()
                    ] else ...[
                      const OneColumnDashBoardView()
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
            ]))));
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
          const Row(children: [
            Expanded(
                flex: 3,
                child: Column(children: [
                  SizedBox(
                      height: 400,
                      child: Row(children: [
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
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

class TransactionsDashboardView extends StatelessWidget {
  const TransactionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewNoFlexContainer(child: TransactionsSlimView());
  }
}

class MarketsDashboardView extends StatelessWidget {
  const MarketsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewContainer(
        child: Text('Markets - Coming Soon',
            style: TextStyle(color: Colors.grey)));
  }
}

class ChartDashboardView extends StatelessWidget {
  const ChartDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewContainer(
        child:
            Text('Chart - Coming Soon', style: TextStyle(color: Colors.grey)));
  }
}

class ContributionsDashboardView extends StatelessWidget {
  const ContributionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewContainer(
        child: Text('Contributions - Coming Soon',
            style: TextStyle(color: Colors.grey)));
  }
}

class SendReceiveDashboardView extends StatelessWidget {
  const SendReceiveDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardViewContainer(
        child: Text('Send / Receive - Coming Soon',
            style: TextStyle(color: Colors.grey)));
  }
}
