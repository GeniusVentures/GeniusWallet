import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this to access Clipboard functionality
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_filters.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  // Helper function to truncate address to first 10 and last 9 characters
  String _truncateAddress(String address) {
    if (address.length > 19) {
      return address.substring(0, 10) +
          "..." +
          address.substring(address.length - 9);
    }
    return address; // If the address is short, return it as is
  }

  // Function to copy transaction hash to clipboard
  void _copyToClipboard(String transactionHash) {
    Clipboard.setData(ClipboardData(text: transactionHash));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction Hash copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final transactions = [...state.transactions];

      // Filter transactions
      transactions.retainWhere((transaction) {
        if (selectedFilter == 'All') return true;
        if (selectedFilter == 'Mint' &&
            transaction.type == TransactionType.mint) return true;
        if (selectedFilter == 'Received' &&
            transaction.transactionDirection == TransactionDirection.received)
          return true;
        if (selectedFilter == 'Sent' &&
            transaction.transactionDirection == TransactionDirection.sent)
          return true;
        return false;
      });

      // Define the table structure (headers, widths, and row data keys)
      final tableColumns = [
        {
          'title': 'Transaction Hash',
          'width': 180.0,
          'rowValue': (transaction) {
            // Truncate the transaction hash if it's too long
            String hash = transaction.hash;
            if (hash.length > 10) {
              return hash.substring(0, 10) + '...';
            }
            return hash;
          },
          'rowFullValue': (transaction) => transaction.hash,
          'isCopyable': true,
        },
        {
          'title': 'Method',
          'width': 100.0,
          'rowValue': (transaction) => transaction.type.toString()
        },
        {
          'title': 'Block',
          'width': 100.0,
          'rowValue': (transaction) => "TODO", // Placeholder for Block Number
        },
        {
          'title': 'Age',
          'width': 150.0,
          'rowValue': (transaction) =>
              timeago.format(transaction.timeStamp.toLocal()),
        },
        {
          'title': 'From',
          'width': 225.0,
          'rowValue': (transaction) =>
              _truncateAddress(transaction.fromAddress),
          'rowFullValue': (transaction) => transaction.fromAddress,
          'isCopyable': true
        },
        {
          'title': '', // Empty title for the arrow column
          'width': 55.0, // Width for the arrow column
          'rowValue': (transaction) {
            // Determine the icon based on the transaction direction
            if (transaction.transactionDirection == TransactionDirection.sent) {
              return const Icon(
                Icons.arrow_forward_sharp,
                color: Colors.green,
              );
            } else if (transaction.transactionDirection ==
                TransactionDirection.received) {
              return const Icon(
                Icons.arrow_back_sharp,
                color: Colors.red,
              );
            }
            return const SizedBox.shrink(); // If no direction, return nothing
          },
        },
        {
          'title': 'To',
          'width': 230.0,
          'rowValue': (transaction) =>
              _truncateAddress(transaction.recipients.first.toAddr),
          'rowFullValue': (transaction) => transaction.recipients.first.toAddr,
          'isCopyable': true
        },
        {
          'title': 'Amount',
          'width': 150.0,
          'rowValue': (transaction) =>
              "${double.tryParse(transaction.recipients.first.amount)?.toStringAsFixed(5) ?? transaction.recipients.first.amount} ${transaction.coinSymbol}",
        },
        {
          'title': 'Fee',
          'width': 150.0,
          'rowValue': (transaction) =>
              "${double.tryParse(transaction.fees)?.toStringAsFixed(5) ?? transaction.fees} ${transaction.coinSymbol}",
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransactionFilters(onFilterSelected: handleFilterSelected),
          if (transactions.isEmpty)
            const Center(
              heightFactor: 5,
              child: Text(
                'No Transactions Found',
                style: TextStyle(fontSize: 20),
              ),
            ),
          const SizedBox(height: 16),
          // Table with horizontal scrolling for both header and rows
          Expanded(
            child: transactions.isEmpty
                ? const SizedBox() // Empty state
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical, // Vertical scroll for rows
                    child: Column(
                      children: [
                        // Table with horizontal scrolling for both header and rows
                        SingleChildScrollView(
                          scrollDirection: Axis
                              .horizontal, // Horizontal scroll for both header and rows
                          child: Column(
                            children: [
                              // Header Row (Fixed, inside horizontal scroll)
                              Container(
                                color: GeniusWalletColors.rowFilterBlue,
                                child: Row(
                                  children: [
                                    for (var column in tableColumns)
                                      Container(
                                        width: column['width'] as double,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          column['title'] as String,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Data Rows (Scrollable horizontally with fixed header)
                              for (var transaction in transactions)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            GeniusWalletColors.rowFilterBlue),
                                  ),
                                  child: Row(
                                    children: [
                                      for (var column in tableColumns)
                                        Container(
                                          width: column['width'] as double,
                                          padding: const EdgeInsets.all(8.0),
                                          child: column['rowValue'] !=
                                                  null // Ensure rowValue is non-null
                                              ? Row(children: [
                                                  (column['rowValue']
                                                              as Function(
                                                                  dynamic))(
                                                          transaction) is Icon
                                                      ? (column['rowValue']
                                                              as Function(
                                                                  dynamic))(
                                                          transaction) // If the rowValue is an Icon, display it
                                                      : SelectableText(
                                                          (column['rowValue']
                                                                  as Function(
                                                                      dynamic))(
                                                              transaction) as String,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                  // Check if copy button is needed
                                                  if (column.containsKey(
                                                          'isCopyable') &&
                                                      column['isCopyable'] ==
                                                          true)
                                                    IconButton(
                                                      padding: EdgeInsets.only(
                                                          left: 4),
                                                      constraints:
                                                          BoxConstraints(),
                                                      icon: const Icon(
                                                          Icons.copy,
                                                          size: 16),
                                                      onPressed: () =>
                                                          _copyToClipboard((column[
                                                                      'rowFullValue']
                                                                  as Function(
                                                                      dynamic))(
                                                              transaction) as String),
                                                    ),
                                                ])
                                              : const SizedBox
                                                  .shrink(), // If rowValue is null, render nothing
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }
}
