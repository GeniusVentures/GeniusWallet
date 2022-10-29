import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transaction_details_cubit.dart';
import 'package:genius_wallet/widgets/components/transaction_status/cancelled.g.dart';
import 'package:genius_wallet/widgets/components/transaction_status/completed.g.dart';
import 'package:genius_wallet/widgets/components/transaction_status/pending.g.dart';

class DetailedTransactionStatusCustom extends StatefulWidget {
  final Widget? child;
  DetailedTransactionStatusCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _DetailedTransactionStatusCustomState createState() =>
      _DetailedTransactionStatusCustomState();
}

class _DetailedTransactionStatusCustomState
    extends State<DetailedTransactionStatusCustom> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return BlocBuilder<TransactionDetailsCubit, TransactionDetailsState>(
        builder: (context, state) {
          switch (state.selectedTransaction.transactionStatus) {
            case TransactionStatus.pending:
              return Pending(constraints);
            case TransactionStatus.cancelled:
              return Cancelled(constraints);
            case TransactionStatus.completed:
              return Completed(constraints);
          }
        },
      );
    });
  }
}
