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

  /// Forwarded verbatim to [TransactionsSlimView.selectedFilter] and
  /// [TransactionsSlimView.onFilterChanged] - the PAGE owns the filter as of
  /// sketch 195, because its trigger sits in `GWPageHeader.trailing` above this
  /// widget.
  ///
  /// Both default to null so the dashboard's `const TransactionsStream()`
  /// (`dashboard_screen.dart`) keeps the slim view's own internal filter with
  /// no call-site edit.
  final Filters? selectedFilter;
  final ValueChanged<Filters>? onFilterChanged;

  const TransactionsStream({
    super.key,
    this.page = false,
    this.selectedFilter,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, List<Transaction>>(
      builder: (context, transactions) {
        return TransactionsSlimView(
          transactions: transactions,
          page: page,
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
        );
      },
    );
  }
}
