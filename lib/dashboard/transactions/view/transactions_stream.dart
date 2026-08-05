import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';

class TransactionsStream extends StatelessWidget {
  /// Forwarded verbatim to [TransactionsSlimView.page]: true selects the page's
  /// two-card layout (filter rail beside the list), false the dashboard panel.
  ///
  /// Defaults to false so the dashboard's `const TransactionsStream()`
  /// (`dashboard_screen.dart:366`) stays byte-unchanged. Only the
  /// `/transactions` route opts in.
  final bool page;

  const TransactionsStream({super.key, this.page = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, List<Transaction>>(
      builder: (context, transactions) {
        return TransactionsSlimView(transactions: transactions, page: page);
      },
    );
  }
}
