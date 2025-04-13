import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';

class SgnusTransactionsScreen extends StatefulWidget {
  const SgnusTransactionsScreen({super.key});

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
      context.read<AppBloc>().add(StreamSGNUSTransactions());
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txController = context.read<GeniusApi>().getTransactionsController();

    return StreamBuilder<List<Transaction>>(
      stream: txController.stream,
      builder: (context, snapshot) {
        final allTx = snapshot.data ?? [];
        final sgnusTx = allTx.where((tx) => tx.isSGNUS == true).toList();

        return TransactionsSlimView(
          transactions: sgnusTx,
          isShowOnlySGNUSTransactions: true,
        );
      },
    );
  }
}
