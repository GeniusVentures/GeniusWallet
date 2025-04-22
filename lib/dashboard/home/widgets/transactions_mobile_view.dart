import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:intl/intl.dart';

String truncateAddress(String address) {
  if (address.length > 19) {
    return "${address.substring(0, 10)}...${address.substring(address.length - 9)}";
  }
  return address;
}

class TransactionsMobileView extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionsMobileView({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        final address = isSent
            ? "To ${truncateAddress(tx.recipients.first.toAddr)}"
            : "From ${truncateAddress(tx.fromAddress)}";
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/crypto/${tx.coinSymbol.toLowerCase()}.png',
                              height: 36,
                              width: 36,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(height: 36, width: 36);
                              },
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: arrowBgColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Icon(
                                arrowIcon,
                                size: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white)),
                              Text(amount,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: amountColor)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(address,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: GeniusWalletColors.gray500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
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
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox(width: 50, height: 50),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: arrowBgColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Icon(arrowIcon, size: 12, color: Colors.black),
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
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
                _buildRow(
                    "Date",
                    DateFormat("MMMM d, y 'at' h:mm a")
                        .format(tx.timeStamp.toLocal())),
                _buildRow("Status", tx.transactionStatus.name),
                _buildRow(isSent ? "To" : "From", truncateAddress(address)),
                _buildRow("Network", tx.coinSymbol),
                _buildRow("Network Fee", "${tx.fees} ${tx.coinSymbol}"),
              ],
            ),
          ),
        ),
      ],
      footer: ElevatedButton(
        onPressed: () {
          // Open external explorer
          final url = getExplorerUrl(tx.coinSymbol, tx.hash);
          final uri = Uri.tryParse(url);

          if (uri?.scheme.startsWith('http') ?? false) {
            launchWebSite(context, uri.toString());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text(
          "View on Explorer",
          style: TextStyle(color: GeniusWalletColors.deepBlueTertiary),
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
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

String getExplorerUrl(String coinSymbol, String txHash) {
  final lowercaseSymbol = coinSymbol.toLowerCase();

  final explorerMap = {
    'eth': 'https://etherscan.io/tx/',
    'polygon': 'https://polygonscan.com/tx/',
    'matic': 'https://polygonscan.com/tx/',
    'bnb': 'https://bscscan.com/tx/',
    'arb': 'https://arbiscan.io/tx/',
    'op': 'https://optimistic.etherscan.io/tx/',
    'avax': 'https://snowtrace.io/tx/',
    'ftm': 'https://ftmscan.com/tx/',
    'sol':
        'https://solscan.io/tx/', // Solana uses different semantics but many explorers accept just tx hash
    'dot': 'https://polkadot.subscan.io/extrinsic/',
    'pol':
        'https://polygonscan.com/tx/', // assuming 'pol' is a mislabeling of 'polygon'
    'base': 'https://basescan.org/tx/',
    'zec': 'https://zcha.in/transactions/',
  };

  final baseUrl = explorerMap[lowercaseSymbol];
  if (baseUrl == null || txHash.isEmpty) return '';

  return '$baseUrl$txHash';
}
