import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:intl/intl.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

class TransactionItem extends StatelessWidget {
  final Transaction tx;

  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isSent = tx.transactionDirection == TransactionDirection.sent;
    final label = isSent ? "Sent" : "Received";
    String amount;

    try {
      amount =
          "${isSent ? '-' : '+'} ${formatAmount(tx.recipients.first.amount)} ${tx.coinSymbol}";
    } on StateError {
      amount = "";
    }

    final arrowIcon = isSent ? Icons.arrow_forward : Icons.arrow_downward;
    final arrowBgColor = isSent ? Colors.lightBlueAccent : Colors.greenAccent;

    return GestureDetector(
      onTap: () => _showTransactionDetails(context, tx),
      child: Card(
        color: GeniusWalletColors.deepBlueMenu,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _buildIcon(arrowBgColor, arrowIcon),
              const SizedBox(width: 16),
              _buildDetails(label),
              _buildAmount(amount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color bgColor, IconData icon) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/crypto/${tx.coinSymbol.toLowerCase()}.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Icon(icon, size: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(String label) {
    return Expanded(
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
                    fontSize: 14, color: GeniusWalletColors.gray500),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text(
            timeago.format(tx.timeStamp.toLocal()),
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          )
        ],
      ),
    );
  }

  Widget _buildAmount(String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(amount,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 4),
        Text(
          "Fee: ${tx.fees} ${tx.coinSymbol}",
          style:
              const TextStyle(fontSize: 12, color: GeniusWalletColors.gray500),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value,
      {Color valueColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: TextStyle(color: valueColor)),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction tx) {
    final isSent = tx.transactionDirection == TransactionDirection.sent;
    final label = isSent ? "Sent" : "Received";
    final arrowIcon = isSent ? Icons.arrow_forward : Icons.arrow_downward;
    final arrowBgColor = isSent ? Colors.lightBlueAccent : Colors.greenAccent;
    final amountText =
        "${isSent ? '-' : '+'} ${formatAmount(tx.recipients.first.amount)} ${tx.coinSymbol}";
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
                _buildRow(
                    "Status",
                    tx.transactionStatus.name[0].toUpperCase() +
                        tx.transactionStatus.name.substring(1)),
                _buildRow(isSent ? "To" : "From",
                    WalletUtils.getAddressForDisplay(address)),
                _buildRow("Network", tx.coinSymbol),
                _buildRow(
                  "Network Fee",
                  "${tx.fees} ${tx.coinSymbol}",
                ),
                _buildRow("Hash", WalletUtils.getAddressForDisplay(tx.hash)),
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
}
