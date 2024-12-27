import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_filters.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:timeago/timeago.dart' as timeago;

class TransactionsSlimView extends StatefulWidget {
  const TransactionsSlimView({super.key});

  @override
  TransactionsSlimViewState createState() => TransactionsSlimViewState();
}

class TransactionsSlimViewState extends State<TransactionsSlimView>
    with WidgetsBindingObserver {
  String? selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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

  String _truncateAddress(String address) {
    if (address.length > 19) {
      return address.substring(0, 10) +
          "..." +
          address.substring(address.length - 9);
    }
    return address;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final transactions = [...state.transactions];

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

      final tableColumns = [
        {
          'title': 'Transaction Hash',
          'width': 180.0,
          'rowValue': (transaction) {
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
          'rowValue': (transaction) => transaction.type.toString(),
        },
        {
          'title': 'Block',
          'width': 100.0,
          'rowValue': (transaction) => "TODO",
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
          'isCopyable': true,
        },
        {
          'title': '',
          'width': 55.0,
          'rowValue': (transaction) {
            if (transaction.transactionDirection == TransactionDirection.sent) {
              return const Icon(Icons.arrow_forward_sharp, color: Colors.green);
            } else if (transaction.transactionDirection ==
                TransactionDirection.received) {
              return const Icon(Icons.arrow_back_sharp, color: Colors.red);
            }
            return const SizedBox.shrink();
          }
        },
        {
          'title': 'To',
          'width': 230.0,
          'rowValue': (transaction) =>
              _truncateAddress(transaction.recipients.first.toAddr),
          'rowFullValue': (transaction) =>
              transaction.recipients.first.toAddr,
          'isCopyable': true,
        },
        {
          'title': 'Amount',
          'width': 150.0,
          'rowValue': (transaction) =>
              "${transaction.recipients.first.amount} ${transaction.coinSymbol}",
        },
        {
          'title': 'Fee',
          'width': 150.0,
          'rowValue': (transaction) =>
              "${transaction.fees} ${transaction.coinSymbol}",
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

          // Scrollable Table Section
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header Row
                    Container(
                      color: GeniusWalletColors.rowFilterBlue,
                      child: Row(
                        children: tableColumns.map((column) {
                          return Container(
                            width: (column['width'] as double) *
                                textScaleFactor.clamp(1.0, 1.5),
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              column['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Data Rows
                    for (var transaction in transactions)
                      Row(
                        children: tableColumns.map((column) {
                          final value =
                              (column['rowValue'] as Function)(transaction);
                          return Container(
                            width: (column['width'] as double) *
                                textScaleFactor.clamp(1.0, 1.5),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                if (value is Icon) value,
                                if (value is! Icon)
                                  Text(
                                    value.toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (column['isCopyable'] == true)
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16),
                                    onPressed: () => _copyToClipboard(
                                        (column['rowFullValue'] as Function)(
                                            transaction)),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Transactions: ${transactions.length}",
              style: const TextStyle(
                  fontSize: 16, color: GeniusWalletColors.gray500),
            ),
          ),
        ],
      );
    });
  }
}
