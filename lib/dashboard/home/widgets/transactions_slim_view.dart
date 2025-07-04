import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_filters.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_item.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_purchased_item.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_swapped_item.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:intl/intl.dart';

final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

class TransactionsSlimView extends StatefulWidget {
  final List<Transaction> transactions;
  final bool? isShowOnlySGNUSTransactions;

  const TransactionsSlimView(
      {super.key,
      required this.transactions,
      this.isShowOnlySGNUSTransactions});

  @override
  TransactionsSlimViewState createState() => TransactionsSlimViewState();
}

class TransactionsSlimViewState extends State<TransactionsSlimView>
    with WidgetsBindingObserver {
  String? selectedFilter = 'All';

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    setState(() {}); // Trigger rebuild on text scaling changes
  }

  void handleFilterSelected(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final filteredTransactions = List<Transaction>.from(widget.transactions);

    filteredTransactions.retainWhere((transaction) {
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Escrow' &&
          transaction.type == TransactionType.escrow) return true;
      if (selectedFilter == 'Escrow' &&
          transaction.type == TransactionType.escrowRelease) return true;
      if (selectedFilter == 'Mint' && transaction.type == TransactionType.mint)
        return true;
      if (selectedFilter == 'Received' &&
          transaction.transactionDirection == TransactionDirection.received) {
        return true;
      }
      if (selectedFilter == 'Sent' &&
          transaction.transactionDirection == TransactionDirection.sent) {
        return true;
      }
      return false;
    });

    if (widget.isShowOnlySGNUSTransactions ?? false) {
      filteredTransactions
          .retainWhere((transaction) => transaction.isSGNUS ?? false);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionFilters(onFilterSelected: handleFilterSelected),
        const SizedBox(height: 20),
        Expanded(
          child: _buildTransactionsView(filteredTransactions, textScaleFactor),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: AutoSizeText(
            maxLines: 1,
            "Transactions: ${filteredTransactions.length}",
            style: const TextStyle(
                fontSize: 16, color: GeniusWalletColors.gray500),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsView(
      List<Transaction> transactions, double textScaleFactor) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];

        if (tx.type == TransactionType.purchase) {
          return TransactionPurchasedItem(tx: tx);
        } else if (tx.type == TransactionType.swap) {
          return TransactionSwappedItem(tx: tx);
        } else {
          return TransactionItem(tx: tx);
        }
      },
    );
  }
}
