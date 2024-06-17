import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transaction_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/transaction_status/status.dart';

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
              return Status(constraints,
                  status: 'Pending',
                  textColor: GeniusWalletColors.deepBlueTertiary,
                  color: Colors.white,
                  icon: const Icon(Icons.refresh,
                      color: GeniusWalletColors.deepBlueTertiary));
            case TransactionStatus.cancelled:
              return Status(constraints,
                  status: 'Cancelled',
                  color: GeniusWalletColors.cancelled,
                  icon: const Icon(Icons.block_flipped));
            case TransactionStatus.completed:
              return Status(constraints,
                  status: 'Completed',
                  color: GeniusWalletColors.completed,
                  icon: const Icon(Icons.check));
          }
        },
      );
    });
  }
}
