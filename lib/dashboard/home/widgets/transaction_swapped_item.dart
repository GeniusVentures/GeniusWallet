import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';

final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

class TransactionSwappedItem extends StatelessWidget {
  final Transaction tx;

  const TransactionSwappedItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isFailed = tx.transactionStatus == TransactionStatus.cancelled;
    final fromSymbol = tx.fromSymbol ?? "";
    final toSymbol = tx.toSymbol ?? "";
    final fromIcon = tx.fromIconUrl; // Assuming these exist on your model
    final toIcon = tx.toIconUrl;
    final fromAmount = tx.fromAmount ?? "0";
    final toAmount = tx.toAmount ?? "0";

    final amountText = isFailed
        ? "Swap Failed"
        : "$fromAmount $fromSymbol → $toAmount $toSymbol";

    return GestureDetector(
      onTap: () => _showSwapTransactionDetails(context, tx),
      child: Card(
        color: GeniusWalletColors.deepBlueMenu,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _buildOverlappedIcons(fromIcon, toIcon, isFailed),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Swapped${isFailed ? ' - Failed' : ''}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isFailed ? Colors.redAccent : Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(tx.timeStamp.toLocal()),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              _buildSwapAmounts(
                  tx, fromAmount, fromSymbol, toAmount, toSymbol, isFailed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlappedIcons(
      String? fromIconUrl, String? toIconUrl, bool isFailed) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (fromIconUrl != null)
            Positioned(
              left: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: GeniusWalletColors.deepBlueCardColor,
                backgroundImage: NetworkImage(fromIconUrl),
              ),
            ),
          if (toIconUrl != null)
            Positioned(
              left: 10,
              top: 10,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: GeniusWalletColors.deepBlueCardColor,
                backgroundImage: NetworkImage(toIconUrl),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: GeniusWalletColors.deepBlueCardColor,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwapAmounts(Transaction tx, String fromAmount, String fromSymbol,
      String toAmount, String toSymbol, bool isFailed) {
    if (isFailed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "0 $toSymbol",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.redAccent,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "+ $toAmount $toSymbol",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.greenAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "- $fromAmount $fromSymbol",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _showSwapTransactionDetails(BuildContext context, Transaction tx) {
    final isFailed = tx.transactionStatus == TransactionStatus.cancelled;
    final fromSymbol = tx.fromSymbol ?? "";
    final toSymbol = tx.toSymbol ?? "";
    final fromIcon = tx.fromIconUrl;
    final toIcon = tx.toIconUrl;
    final fromAmount = tx.fromAmount ?? "0";
    final toAmount = tx.toAmount ?? "0";

    ResponsiveDrawer.show(
      context: context,
      title: isFailed ? "Swap - Failed" : "Swap",
      children: [
        const SizedBox(height: 16),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (fromIcon != null)
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(fromIcon),
                  backgroundColor: GeniusWalletColors.deepBlueCardColor,
                ),
              if (toIcon != null)
                Positioned(
                  left: 38,
                  top: 18,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(toIcon),
                    backgroundColor: GeniusWalletColors.deepBlueCardColor,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GeniusWalletColors.deepBlueCardColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            isFailed
                ? "Swap Failed"
                : "$fromAmount $fromSymbol → $toAmount $toSymbol",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isFailed ? Colors.redAccent : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          color: GeniusWalletColors.deepBlueMenu,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow("Date",
                    "${DateFormat("MMMM d, y 'at' h:mm a").format(tx.timeStamp.toLocal())}"),
                _buildRow(
                    "Status",
                    tx.transactionStatus.name[0].toUpperCase() +
                        tx.transactionStatus.name.substring(1),
                    valueColor: isFailed ? Colors.redAccent : Colors.white),
                _buildRow("From", "$fromAmount $fromSymbol"),
                _buildRow("To", "$toAmount $toSymbol"),
                _buildRow("Transaction Fee", "${tx.fees ?? "0"} $fromSymbol"),
                _buildRow("Tx Hash", tx.hash ?? "N/A"),
              ],
            ),
          ),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: valueColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
