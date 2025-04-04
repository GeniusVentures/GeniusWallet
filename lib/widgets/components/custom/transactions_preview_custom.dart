import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/formatters.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/widgets/components/transaction_card.g.dart';

class TransactionsPreviewCustom extends StatefulWidget {
  final Widget? child;
  TransactionsPreviewCustom({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  _TransactionsPreviewCustomState createState() =>
      _TransactionsPreviewCustomState();
}

class _TransactionsPreviewCustomState extends State<TransactionsPreviewCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
      if (state.selectedWallet == null ||
          state.selectedWallet!.transactions.isEmpty) {
        return Container(
          alignment: Alignment.center,
          child: const Text('No Transactions detected.'),
        );
      }
      final transactions = state.selectedWallet!.transactions;
      return ListView.separated(
        itemBuilder: (context, index) {
          final currentTransaction = transactions[index];
          return SizedBox(
            height: 55,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return TransactionCard(
                  constraints,
                  ovrTimestamp:
                      dateFormatter.format(currentTransaction.timeStamp),
                  ovrTransactionQuantity:
                      currentTransaction.recipients.first.amount,
                  ovrTransactionID: currentTransaction.recipients.first.toAddr,
                );
              },
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 18);
        },
        itemCount: transactions.length > 3 ? 3 : transactions.length,
      );
    });
  }
}
