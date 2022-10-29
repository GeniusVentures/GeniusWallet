import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/wallets_overview/wallets_overview_cubit.dart';
import 'package:genius_wallet/app/bloc/wallets_overview/wallets_overview_state.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transaction_details_cubit.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/detailed_transaction.g.dart';
import 'package:genius_wallet/widgets/components/export_history.g.dart';
import 'package:genius_wallet/widgets/components/genius_appbar.g.dart';
import 'package:genius_wallet/widgets/components/transaction_counter.g.dart';
import 'package:genius_wallet/widgets/components/transaction_filter.g.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GeniusAppbar(constraints);
                  },
                ),
              ),
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
              const TransactionsListView(),
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
    return BlocBuilder<WalletsOverviewCubit, WalletsOverviewState>(
      builder: (context, state) {
        switch (state.fetchTransactionsStatus) {
          case WalletsOverviewStatus.success:
            return Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final currentTransaction = state.transactions[index];
                  return SizedBox(
                    height: 190,
                    width: 320,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return BlocProvider(
                          create: (context) => TransactionDetailsCubit(
                            initialState: TransactionDetailsState(
                              selectedTransaction: currentTransaction,
                            ),
                          ),
                          child: DetailedTransaction(
                            constraints,
                            ovrCoinIcon: WalletUtils.currencySymbolToImage(
                              currentTransaction.coinSymbol,
                            ),
                            ovrTimestamp: currentTransaction.timeStamp,
                            ovrTransactionArrow:
                                currentTransaction.transactionDirection ==
                                        TransactionDirection.received
                                    ? Image.asset(
                                        'assets/images/green_arrow_right.png')
                                    : Image.asset(
                                        'assets/images/red_arrow_left.png'),
                            ovrTransactionID: currentTransaction.hash,
                            ovrTransactionValue:
                                '${currentTransaction.amount} ${currentTransaction.coinSymbol}',
                          ),
                        );
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemCount: state.transactions.length,
              ),
            );
          case WalletsOverviewStatus.error:
            return const Center(
              child: Text('Something went wrong!'),
            );
          case WalletsOverviewStatus.initial:
            context.read<WalletsOverviewCubit>().fetchTransactions();
            return Container();
          case WalletsOverviewStatus.loading:
            return const LoadingScreen();
        }
      },
    );
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
          width: 150,
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
