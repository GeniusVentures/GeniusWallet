import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

final _dateFormat = DateFormat("MMMM d, y 'at' h:mm a");

String _capitalizeStatus(TransactionStatus status) =>
    status.name[0].toUpperCase() + status.name.substring(1);

Widget _buildRow(
  String label,
  String value, {
  Color valueColor = Colors.white,
}) {
  return Row(
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
  );
}

Widget _buildDetailsCard(List<Widget> rows) {
  return Card(
    color: GeniusWalletColors.deepBlueMenu,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(spacing: 10.0, children: rows),
    ),
  );
}

Widget _buildCoinIconWithBadge(
  String coinSymbol,
  Color bgColor,
  IconData icon, {
  double size = 40,
  double badgeSize = 22,
}) {
  return SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/crypto/${coinSymbol.toLowerCase()}.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Icon(icon, size: badgeSize * 0.55, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

class TransactionEscrowReleaseItem extends StatelessWidget {
  final Transaction tx;

  const TransactionEscrowReleaseItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerHigh,
      child: ListTile(title: Text("Completed job")),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction tx;

  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSent = tx.transactionDirection == TransactionDirection.sent;
    final label = isSent ? "Sent" : "Received";
    final amount =
        "${isSent ? '-' : '+'} ${formatAmount(tx.recipients.first.amount)} ${tx.coinSymbol}";
    final arrowIcon = isSent ? Icons.arrow_forward : Icons.arrow_downward;
    final arrowBgColor = isSent ? Colors.lightBlueAccent : Colors.greenAccent;

    return Card(
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _buildCoinIconWithBadge(
          tx.coinSymbol,
          arrowBgColor,
          arrowIcon,
        ),
        title: Row(
          children: [
            Text(label),
            Text(
              " • ${tx.coinSymbol}",
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(context),
        subtitle: Text(timeago.format(tx.timeStamp.toLocal())),
        trailing: _buildAmountTrailing(amount, cs.onSurfaceVariant),
      ),
    );
  }

  Widget _buildAmountTrailing(String amount, Color feeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(
          "Fee: ${tx.fees} ${tx.coinSymbol}",
          style: TextStyle(fontSize: 12, color: feeColor),
        ),
      ],
    );
  }

  void _showTransactionDetails(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: _buildCoinIconWithBadge(
              tx.coinSymbol,
              arrowBgColor,
              arrowIcon,
              size: 60,
              badgeSize: 24,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              amountText,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailsCard([
            _buildRow("Date", _dateFormat.format(tx.timeStamp)),
            _buildRow("Status", _capitalizeStatus(tx.transactionStatus)),
            _buildRow(
              isSent ? "To" : "From",
              WalletUtils.getAddressForDisplay(address),
            ),
            _buildRow("Network", tx.coinSymbol),
            _buildRow("Network Fee", "${tx.fees} ${tx.coinSymbol}"),
            _buildRow("Hash", WalletUtils.getAddressForDisplay(tx.hash)),
          ]),
        ],
      ),
      footer: ElevatedButton.icon(
        onPressed: () {
          final url = getExplorerUrl(tx.coinSymbol, tx.hash);
          final uri = Uri.tryParse(url);
          if (uri?.scheme.startsWith('http') ?? false) {
            launchWebSite(context, uri.toString());
          }
        },
        icon: Icon(Icons.open_in_new, color: cs.surfaceDim),
        label: const Text("View on Explorer"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          foregroundColor: cs.surfaceDim,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class TransactionPurchasedItem extends StatelessWidget {
  final Transaction tx;

  const TransactionPurchasedItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFailed = tx.transactionStatus == TransactionStatus.failed;
    final amount = isFailed
        ? currencyFormatter.format(0)
        : "+ ${currencyFormatter.format(double.tryParse(tx.recipients.first.amount) ?? 0)}";
    const arrowIcon = Icons.attach_money;
    final arrowBgColor = isFailed ? Colors.redAccent : Colors.greenAccent;
    final amountColor = isFailed ? Colors.redAccent : Colors.greenAccent;

    return Card(
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _showPurchaseTransactionDetails(context, tx),
        leading: _buildCoinIconWithBadge(
          tx.coinSymbol,
          arrowBgColor,
          arrowIcon,
        ),
        title: Row(
          children: [
            Text(
              isFailed ? "Buy - Failed" : "Buy",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isFailed ? Colors.redAccent : Colors.white,
              ),
            ),
            Text(
              " • ${tx.coinSymbol}",
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        subtitle: Text(
          timeago.format(tx.timeStamp.toLocal()),
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        trailing: _buildAmountTrailing(
          amountColor,
          amount,
          isFailed,
          cs.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildAmountTrailing(
    Color amountColor,
    String amount,
    bool isFailed,
    Color feeColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: amountColor,
          ),
        ),
        Text(
          isFailed
              ? currencyFormatter.format(0)
              : "Spent: ${currencyFormatter.format(double.tryParse(tx.fees) ?? 0)}",
          style: TextStyle(fontSize: 12, color: feeColor),
        ),
      ],
    );
  }

  void _showPurchaseTransactionDetails(BuildContext context, Transaction tx) {
    final isFailed = tx.transactionStatus == TransactionStatus.cancelled;
    final arrowBgColor = isFailed ? Colors.redAccent : Colors.greenAccent;
    final amountText = isFailed
        ? '\$0.00'
        : "+ \$${double.tryParse(tx.recipients.first.amount)?.toStringAsFixed(2) ?? '0.00'}";

    ResponsiveDrawer.show(
      context: context,
      title: isFailed ? "Buy - Failed" : "Buy",
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: _buildCoinIconWithBadge(
              tx.coinSymbol,
              arrowBgColor,
              Icons.attach_money,
              size: 50,
              badgeSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              amountText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isFailed ? Colors.redAccent : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailsCard([
            _buildRow("Date", _dateFormat.format(tx.timeStamp.toLocal())),
            _buildRow(
              "Status",
              _capitalizeStatus(tx.transactionStatus),
              valueColor: isFailed ? Colors.redAccent : Colors.white,
            ),
            _buildRow(
              "To",
              WalletUtils.getAddressForDisplay(tx.recipients.first.toAddr),
            ),
            _buildRow("Network", tx.coinSymbol),
            _buildRow("Network Fee", "${tx.fees} ${tx.coinSymbol}"),
          ]),
        ],
      ),
    );
  }
}

class TransactionSwappedItem extends StatelessWidget {
  final Transaction tx;

  const TransactionSwappedItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFailed = tx.transactionStatus == TransactionStatus.failed;
    final fromSymbol = tx.fromSymbol ?? "";
    final toSymbol = tx.toSymbol ?? "";
    final fromIcon = tx.fromIconUrl;
    final toIcon = tx.toIconUrl;
    final fromAmount = tx.fromAmount ?? "0";
    final toAmount = tx.toAmount ?? "0";

    return Card(
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          "Swapped${isFailed ? ' - Failed' : ''}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isFailed ? Colors.redAccent : Colors.white,
          ),
        ),
        subtitle: Text(timeago.format(tx.timeStamp.toLocal())),
        leading: _buildOverlappedIcons(fromIcon, toIcon, cs.surface),
        onTap: () => _showSwapTransactionDetails(context),
        trailing: _buildSwapAmounts(
          fromAmount,
          fromSymbol,
          toAmount,
          toSymbol,
          isFailed,
        ),
      ),
    );
  }

  Widget _buildOverlappedIcons(
    String? fromIconUrl,
    String? toIconUrl,
    Color cardColor,
  ) {
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
                backgroundColor: cardColor,
                backgroundImage: NetworkImage(fromIconUrl),
              ),
            ),
          if (toIconUrl != null)
            Positioned(
              left: 10,
              top: 10,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: cardColor,
                backgroundImage: NetworkImage(toIconUrl),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwapAmounts(
    String fromAmount,
    String fromSymbol,
    String toAmount,
    String toSymbol,
    bool isFailed,
  ) {
    if (isFailed) {
      return Text(
        "0 $toSymbol",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
        Text("- $fromAmount $fromSymbol", style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  void _showSwapTransactionDetails(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
      child: ListView(
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
                    backgroundColor: cs.surface,
                  ),
                if (toIcon != null)
                  Positioned(
                    left: 38,
                    top: 18,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(toIcon),
                      backgroundColor: cs.surface,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
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
          _buildDetailsCard([
            _buildRow("Date", _dateFormat.format(tx.timeStamp.toLocal())),
            _buildRow(
              "Status",
              _capitalizeStatus(tx.transactionStatus),
              valueColor: isFailed ? Colors.redAccent : Colors.white,
            ),
            _buildRow("From", "$fromAmount $fromSymbol"),
            _buildRow("To", "$toAmount $toSymbol"),
            _buildRow("Transaction Fee", "${tx.fees} $fromSymbol"),
            _buildRow("Tx Hash", tx.hash),
          ]),
        ],
      ),
    );
  }
}
