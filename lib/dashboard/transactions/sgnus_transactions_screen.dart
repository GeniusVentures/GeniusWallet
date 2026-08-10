import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';

class SgnusTransactionsScreen extends StatefulWidget {
  /// Forwarded verbatim to [TransactionsSlimView.page]: true selects the page's
  /// two-card layout, false the dashboard panel.
  ///
  /// Defaults to false so the dashboard's `const SgnusTransactionsScreen()`
  /// (`dashboard_screen.dart:365`) stays byte-unchanged. Only the
  /// `/transactions` route opts in.
  final bool page;

  /// Forwarded verbatim to [TransactionsSlimView.selectedFilter] and
  /// [TransactionsSlimView.onFilterChanged] - the PAGE owns the filter as of
  /// sketch 195, because its trigger sits in `GWPageHeader.trailing` above this
  /// widget.
  ///
  /// Both default to null so the dashboard's `const SgnusTransactionsScreen()`
  /// (`dashboard_screen.dart`) keeps the slim view's own internal filter with
  /// no call-site edit.
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
    final txController = context
        .read<GeniusApi>()
        .getSGNUSTransactionsController();

    return StreamBuilder<List<Transaction>>(
      stream: txController.stream,
      builder: (context, snapshot) {
        final allTx = snapshot.data ?? [];
        final sgnusTx = allTx.where((tx) => tx.isSGNUS == true).toList();

        final view = TransactionsSlimView(
          transactions: sgnusTx,
          isShowOnlySGNUSTransactions: true,
          page: widget.page,
          selectedFilter: widget.selectedFilter,
          onFilterChanged: widget.onFilterChanged,
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
