import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';

import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transaction_details_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/view/transaction_information_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/detailed_transaction.g.dart';

import 'package:genius_wallet/widgets/components/export_history.g.dart';
import 'package:genius_wallet/widgets/components/transaction_counter.g.dart';
import 'package:genius_wallet/widgets/components/transaction_filter.g.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (GeniusBreakpoints.useDesktopLayout(context)) {
      return const Desktop();
    }
    return const Mobile();
  }
}

class Desktop extends StatelessWidget {
  const Desktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DesktopContainer(
      title: 'Transactions',
      child: Column(
        children: [
          const SizedBox(height: 30),
          const TransactionsAndHistoryDesktop(),
          const SizedBox(height: 50),
          SizedBox(
            height: 20,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return TransactionFilter(constraints);
              },
            ),
          ),
          const SizedBox(height: 50),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return const TransactionsListView();
            },
          ),
        ],
      ),
    );
  }
}

class Mobile extends StatelessWidget {
  const Mobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const TransactionsToggle(),
              const SizedBox(height: 30),
              const TransactionsAndHistory(),
              const SizedBox(height: 30),
              SizedBox(
                height: 30,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return DateSelector(constraints);
                  },
                ),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(builder: (context, constraints) {
                return const TransactionsListView();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionsListView extends StatelessWidget {
  const TransactionsListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        switch (state.subscribeToWalletStatus) {
          case AppStatus.loaded:
            return Wrap(direction: Axis.vertical, spacing: 20, children: [
              for (var transaction in state.transactions)
                BlocProvider(
                    create: (context) => TransactionDetailsCubit(
                          initialState: TransactionDetailsState(
                            selectedTransaction: transaction,
                          ),
                        ),
                    child: TransactionCard(currentTransaction: transaction))
            ]);
          case AppStatus.error:
            return const Center(
              child: Text('Something went wrong!'),
            );
          case AppStatus.initial:
            return Container();
          case AppStatus.loading:
            return const LoadingScreen();
        }
      },
    );
  }
}

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    Key? key,
    required this.currentTransaction,
  }) : super(key: key);

  final Transaction currentTransaction;

  @override
  Widget build(BuildContext context) {
    BuildContext mainContext = context;
    return LayoutBuilder(builder: (context, constraints) {
      return MaterialButton(
        onPressed: () {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  backgroundColor: GeniusWalletColors.deepBlueCardColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(
                          GeniusWalletConsts.borderRadiusCard))),
                  title: const Text('Transaction History',
                      textAlign: TextAlign.center),
                  content: SizedBox(
                      width: 400,
                      height: 600,
                      // Make the cubit available for this adjacent component
                      child: BlocProvider<TransactionDetailsCubit>.value(
                        value: BlocProvider.of<TransactionDetailsCubit>(
                            mainContext),
                        child: TransactionInformationScreen(
                            transaction: currentTransaction),
                      ))));
        },
        child: DetailedTransaction(
          constraints,
          ovrCoinIcon: WalletUtils.currencySymbolToImage(
            currentTransaction.coinSymbol,
          ),
          ovrTimestamp: currentTransaction.timeStamp,
          ovrTransactionArrow: currentTransaction.transactionDirection ==
                  TransactionDirection.received
              ? Image.asset('assets/images/green_arrow_right.png')
              : Image.asset('assets/images/red_arrow_left.png'),
          ovrTransactionID: currentTransaction.hash,
          ovrTransactionValue:
              '${currentTransaction.amount} ${currentTransaction.coinSymbol}',
        ),
      );
    });
  }
}

class TransactionsAndHistory extends StatelessWidget {
  const TransactionsAndHistory({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 40,
          width: 200,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return TransactionCounter(constraints);
            },
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 40,
          width: 120,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ExportHistory(constraints);
            },
          ),
        ),
      ],
    );
  }
}

class TransactionsAndHistoryDesktop extends StatelessWidget {
  const TransactionsAndHistoryDesktop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return TransactionCounter(constraints);
          },
        ),
        const Spacer(),
        SizedBox(
          height: 30,
          width: 300,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return DateSelector(constraints);
            },
          ),
        ),
        SizedBox(
          height: 40,
          width: 120,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ExportHistory(constraints);
            },
          ),
        ),
      ],
    );
  }
}

class TransactionsToggle extends StatelessWidget {
  const TransactionsToggle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Transactions',
          style: TextStyle(fontSize: 24),
        ),
        const Spacer(),
        SizedBox(
          height: 20,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return TransactionFilter(constraints);
            },
          ),
        ),
      ],
    );
  }
}
