import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/screens/loading_screen.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transaction_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/detailed_transaction.g.dart';
import 'package:genius_wallet/widgets/components/export_history.g.dart';
import 'package:genius_wallet/widgets/components/transaction_counter.g.dart';
import 'package:genius_wallet/widgets/components/transaction_filter.g.dart';
import 'package:go_router/go_router.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

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
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        switch (state.subscribeToWalletStatus) {
          case AppStatus.loaded:
            return Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final currentTransaction = state.transactions[index];
                  return SizedBox(
                    height: 190,
                    width: 320,
                    child: BlocProvider(
                      create: (context) => TransactionDetailsCubit(
                        initialState: TransactionDetailsState(
                          selectedTransaction: currentTransaction,
                        ),
                      ),
                      child: TransactionCard(
                          currentTransaction: currentTransaction),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemCount: state.transactions.length,
              ),
            );
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
    return LayoutBuilder(builder: (context, constraints) {
      return MaterialButton(
        onPressed: () {
          context.push(
            '/transactions/${currentTransaction.hash}',
            extra: context.read<TransactionDetailsCubit>(),
          );
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
