import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_filters.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_mobile_view.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    final isMobile = MediaQuery.of(context).size.width < 600;
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
          child: isMobile
              ? TransactionsMobileView(
                  transactions: filteredTransactions,
                )
              : _buildDesktopTableView(filteredTransactions, textScaleFactor),
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

  Widget _buildDesktopTableView(
      List<Transaction> transactions, double textScaleFactor) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(' No Transactions Found', style: TextStyle(fontSize: 20)),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isSent = tx.transactionDirection == TransactionDirection.sent;
        final label = isSent ? "Sent" : "Received";
        final amount =
            "${isSent ? '-' : '+'} ${tx.recipients.first.amount} ${tx.coinSymbol}";
        final amountColor = isSent ? Colors.white : Colors.greenAccent;
        final arrowIcon = isSent ? Icons.arrow_forward : Icons.arrow_downward;
        final arrowBgColor =
            isSent ? Colors.lightBlueAccent : Colors.greenAccent;

        return GestureDetector(
          onTap: () => _showTransactionDetails(context, tx),
          child: Card(
            color: GeniusWalletColors.deepBlueMenu,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/crypto/${tx.coinSymbol.toLowerCase()}.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: arrowBgColor,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                            ),
                            child:
                                Icon(arrowIcon, size: 12, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white)),
                            const SizedBox(width: 8),
                            Text(
                              "• ${tx.coinSymbol}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: GeniusWalletColors.gray500),
                            )
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(tx.timeStamp.toLocal()),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white60),
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(amount,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: amountColor)),
                      const SizedBox(height: 4),
                      Text("Fee: ${tx.fees} ${tx.coinSymbol}",
                          style: const TextStyle(
                              fontSize: 12, color: GeniusWalletColors.gray500)),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction tx) {
    final isSent = tx.transactionDirection == TransactionDirection.sent;
    final label = isSent ? "Sent" : "Received";
    final arrowIcon = isSent ? Icons.arrow_forward : Icons.arrow_downward;
    final arrowBgColor = isSent ? Colors.lightBlueAccent : Colors.greenAccent;
    final amountText =
        "${isSent ? '-' : '+'} ${tx.recipients.first.amount} ${tx.coinSymbol}";
    final address = isSent ? tx.recipients.first.toAddr : tx.fromAddress;

    ResponsiveDrawer.show(
      context: context,
      title: label,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/images/crypto/${tx.coinSymbol.toLowerCase()}.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(width: 60, height: 60),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: arrowBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Icon(arrowIcon, size: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            amountText,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: GeniusWalletColors.deepBlueMenu,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow("Date",
                    DateFormat("MMMM d, y 'at' h:mm a").format(tx.timeStamp)),
                _buildRow("Status", tx.transactionStatus.name),
                _buildRow(isSent ? "To" : "From", truncateAddress(address)),
                _buildRow("Network", tx.coinSymbol),
                _buildRow("Network Fee", "${tx.fees} ${tx.coinSymbol}"),
                _buildRow("Hash", truncateAddress(tx.hash)),
              ],
            ),
          ),
        ),
      ],
      footer: ElevatedButton.icon(
        onPressed: () {
          final url = getExplorerUrl(tx.coinSymbol, tx.hash);
          final uri = Uri.tryParse(url);
          if (uri?.scheme.startsWith('http') ?? false) {
            launchWebSite(context, uri.toString());
          }
        },
        icon: const Icon(Icons.open_in_new,
            color: GeniusWalletColors.deepBlueTertiary),
        label: const Text("View on Explorer"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: GeniusWalletColors.deepBlueTertiary,
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
