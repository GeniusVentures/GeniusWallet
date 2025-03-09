import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_filters.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:timeago/timeago.dart' as timeago;

class TransactionsSlimView extends StatefulWidget {
  final List<Transaction> transactions;
  const TransactionsSlimView({super.key, required this.transactions});

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
    final transactions = [...widget.transactions];

    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      transactions.retainWhere((transaction) {
        if (selectedFilter == 'All') {
          return true;
        }
        if (selectedFilter == 'Escrow' &&
            transaction.type == TransactionType.escrow) {
          return true;
        }
        if (selectedFilter == 'Mint' &&
            transaction.type == TransactionType.mint) {
          return true;
        }
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

      final tableColumns = [
        {
          'title': 'Transaction Hash',
          'width': 230.0,
          'rowValue': (transaction) => _truncateAddress(transaction.hash),
          'rowFullValue': (transaction) => transaction.hash,
          'isCopyable': true
        },
        {
          'title': 'Method',
          'width': 100.0,
          'rowValue': (transaction) => transaction.type.toString()
        },
        {'title': 'Block', 'width': 100.0, 'rowValue': (transaction) => "TODO"},
        {
          'title': 'Age',
          'width': 150.0,
          'rowValue': (transaction) =>
              timeago.format(transaction.timeStamp.toLocal())
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
          'title': '',
          'width': 55.0,
          'rowValue': (transaction) =>
              transaction.transactionDirection == TransactionDirection.sent
                  ? const Icon(Icons.arrow_forward_sharp, color: Colors.green)
                  : const Icon(Icons.arrow_back_sharp, color: Colors.red)
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
              "${transaction.recipients.first.amount} ${transaction.coinSymbol}"
        },
        {
          'title': 'Fee',
          'width': 150.0,
          'rowValue': (transaction) =>
              "${transaction.fees} ${transaction.coinSymbol}"
        },
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransactionFilters(onFilterSelected: handleFilterSelected),
          const SizedBox(height: 20),

          // **Scrollable Container for Header & Data Rows**
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **Fixed Header (Doesn't Scroll Vertically)**
                  Container(
                    color: GeniusWalletColors.rowFilterBlue,
                    child: Row(
                      children: tableColumns.map((column) {
                        return Container(
                          width: (column['width'] as double) *
                              textScaleFactor.clamp(1.0, 1.5),
                          padding: const EdgeInsets.only(
                              top: 16.0, bottom: 16, left: 8),
                          child: AutoSizeText(
                            column['title'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // **Scrollable Data Rows (Scrolls Vertically)**
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.transactions.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text(
                                    ' No Transactions Found',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                )
                              ]
                            : transactions.asMap().entries.map((entry) {
                                final transaction = entry.value;
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: GeniusWalletColors
                                            .deepBlueTertiary, // ✅ Slight border between rows
                                        width: 3.0,
                                      ),
                                    ),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: tableColumns.map((column) {
                                      final value = (column['rowValue']
                                          as Function)(transaction);
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
                                            if (column['isCopyable'] == true &&
                                                (value as String).isNotEmpty)
                                              IconButton(
                                                icon: const Icon(Icons.copy,
                                                    size: 16),
                                                onPressed: () =>
                                                    _copyToClipboard(
                                                        (column['rowFullValue']
                                                                as Function)(
                                                            transaction)),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: AutoSizeText(
              maxLines: 1,
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
