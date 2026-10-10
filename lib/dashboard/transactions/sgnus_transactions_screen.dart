import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/sgnus_transactions_cubit.dart';

class SgnusTransactionsScreen extends StatefulWidget {
  /// Forwarded verbatim to [TransactionsSlimView.page]: true selects the page's
  /// two-card layout, false the dashboard panel.
  ///
  /// Defaults to false so the dashboard's `const SgnusTransactionsScreen()`
  /// (`dashboard_screen.dart:365`) stays byte-unchanged. Only the
  /// `/transactions` route opts in.
  final bool page;

  /// Forwarded to [TransactionsSlimView.selectedFilter] and
  /// [TransactionsSlimView.onFilterChanged]. Both null on the dashboard, whose
  /// panel keeps its own filter.
  final Filters? selectedFilter;
  final ValueChanged<Filters>? onFilterChanged;

  const SgnusTransactionsScreen({
    super.key,
    this.page = false,
    this.selectedFilter,
    this.onFilterChanged,
  });

  @override
  State<SgnusTransactionsScreen> createState() =>
      _SgnusTransactionsScreenState();
}

class _SgnusTransactionsScreenState extends State<SgnusTransactionsScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();

    // Start polling every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      context.read<AppBloc>().add(StartSGNUSTransactionsStream());
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SgnusTransactionsCubit, List<Transaction>>(
      builder: (context, allTx) {
        final sgnusTx = allTx.where((tx) => tx.isSGNUS == true).toList();

        final view = BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, ordersState) => TransactionsSlimView(
            transactions: sgnusTx,
            isShowOnlySGNUSTransactions: true,
            page: widget.page,
            buyOrders: ordersState.orders?.orders ?? const [],
            buyOrdersStatus: ordersState.status,
            onRetryBuyOrders: () =>
                unawaited(context.read<OrdersCubit>().fetchOrders()),
            selectedFilter: widget.selectedFilter,
            onFilterChanged: widget.onFilterChanged,
          ),
        );

        // The page frame already centres, and its branch sits in an `Expanded`
        // inside a stretched Column — a second `Center` there would shrink-wrap
        // the two cards to their intrinsic width and undo that `Expanded`.
        // Written as a conditional rather than deleted outright so the
        // dashboard's SGNUS panel keeps the exact tree it has today.
        return widget.page ? view : Center(child: view);
      },
    );
  }
}
