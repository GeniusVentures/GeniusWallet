import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_filters.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:intl/intl.dart';

class TransactionsSlimView extends StatefulWidget {
  const TransactionsSlimView({super.key});

  @override
  TransactionsSlimViewState createState() => TransactionsSlimViewState();
}

class TransactionsSlimViewState extends State<TransactionsSlimView> {
  String? selectedFilter = 'All';

  void handleFilterSelected(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    const padding = 4.0;
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final transactions = [...state.transactions];
      // filter transactions
      transactions.retainWhere((transaction) {
        if (selectedFilter == 'All') {
          return true;
        } else if (selectedFilter == 'Mint' &&
            transaction.type == TransactionType.mint) {
          return true;
        } else if (selectedFilter == 'Received' &&
            transaction.transactionDirection == TransactionDirection.received) {
          return true;
        } else if (selectedFilter == 'Sent' &&
            transaction.transactionDirection == TransactionDirection.sent) {
          return true;
        }

        return false;
      });

      return Column(
        children: [
          TransactionFilters(onFilterSelected: handleFilterSelected),
          if (transactions.isEmpty)
            const Center(
                heightFactor: 5,
                child: Text(
                  'No Transactions Found',
                  style: TextStyle(fontSize: 20),
                )),
          const SizedBox(height: 16),
          Expanded(
              child: ListView.builder(
            shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Container(
                height: 80 +
                    padding *
                        2, // base height + horizontal padding * 2 for top/bottom of rows
                color: GeniusWalletColors.deepBlueCardColor,
                padding: const EdgeInsets.symmetric(vertical: padding),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: GeniusWalletColors.rowFilterBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('hh:mm MMMM dd, yyyy').format(
                                        transaction.timeStamp.toLocal()),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // TODO: add status maybe?
                                        // if (transaction.transactionStatus ==
                                        //     TransactionStatus.pending)
                                        //   const Icon(
                                        //     Icons.timer_outlined,
                                        //     color: Colors.white,
                                        //   )
                                        // else if (transaction
                                        //         .transactionStatus ==
                                        //     TransactionStatus.cancelled)
                                        //   const Icon(
                                        //     Icons.cancel_outlined,
                                        //     color: Colors.red,
                                        //   )
                                        if (transaction.type ==
                                            TransactionType.mint)
                                          const Icon(
                                            Icons.post_add,
                                            color: Colors.lightBlue,
                                          )
                                        else if (transaction
                                                .transactionDirection ==
                                            TransactionDirection.sent)
                                          const Icon(
                                            Icons.arrow_forward_sharp,
                                            color: Colors.green,
                                          )
                                        else if (transaction
                                                .transactionDirection ==
                                            TransactionDirection.received)
                                          const Icon(
                                            Icons.arrow_back_sharp,
                                            color: Colors.red,
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          transaction.amount,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction.hash,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
          const SizedBox(height: 8),
          SizedBox(
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Total Transactions: ${transactions.length.toString()}",
                    style: const TextStyle(
                        fontSize: 14, color: GeniusWalletColors.gray500),
                  )))
        ],
      );
    });
  }
}
