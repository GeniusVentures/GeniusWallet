import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

final _dateFormat = DateFormat("MMMM d, y 'at' h:mm a");

String _capitalizeStatus(TransactionStatus status) =>
    status.name[0].toUpperCase() + status.name.substring(1);

Widget _buildRow(
  BuildContext context,
  String label,
  String value, {
  Color? valueColor,
}) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GeniusWalletTypography.bodySm.copyWith(
          color: GeniusWalletColors.textPrimary70,
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: GeniusWalletTypography.bodyMd.copyWith(
            color: valueColor ?? gw.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _buildDetailsCard(BuildContext context, List<Widget> rows) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return Container(
    decoration: GWDecorations.surface(
      radius: GeniusWalletConsts.radiusMd,
      border: gw.borderSubtle,
    ),
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
              border: Border.all(
                color: GeniusWalletColors.textOnBrand,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: badgeSize * 0.55,
              color: GeniusWalletColors.textOnBrand,
            ),
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      decoration: GWDecorations.surface(
        radius: GeniusWalletConsts.radiusMd,
        border: gw.borderSubtle,
      ),
      child: const ListTile(title: Text("Completed job")),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction tx;

  const TransactionItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isSent = tx.transactionDirection == TransactionDirection.sent;
    final label = isSent ? "Sent" : "Received";
    final amount =
        "${isSent ? '-' : '+'} ${formatAmount(tx.recipients.first.amount)} ${tx.coinSymbol}";
    final arrowIcon = isSent ? Icons.arrow_forward : Icons.arrow_downward;
    final arrowBgColor =
        isSent ? Colors.lightBlueAccent : GeniusWalletColors.brandGreen;

    return Container(
      decoration: GWDecorations.surface(
        radius: GeniusWalletConsts.radiusMd,
        border: gw.borderSubtle,
      ),
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
              style: TextStyle(fontSize: 14, color: gw.textSecondary),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(context),
        subtitle: Text(timeago.format(tx.timeStamp.toLocal())),
        trailing: _buildAmountTrailing(amount, gw.textSecondary),
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isSent = tx.transactionDirection == TransactionDirection.sent;
    final label = isSent ? "Sent" : "Received";
    final arrowIcon = isSent ? Icons.arrow_forward : Icons.arrow_downward;
    final arrowBgColor =
        isSent ? Colors.lightBlueAccent : GeniusWalletColors.brandGreen;
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: gw.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailsCard(context, [
            _buildRow(context, "Date", _dateFormat.format(tx.timeStamp)),
            _buildRow(
              context,
              "Status",
              _capitalizeStatus(tx.transactionStatus),
            ),
            _buildRow(
              context,
              isSent ? "To" : "From",
              WalletUtils.getAddressForDisplay(address),
            ),
            _buildRow(context, "Network", tx.coinSymbol),
            _buildRow(context, "Network Fee", "${tx.fees} ${tx.coinSymbol}"),
            _buildRow(context, "Hash", WalletUtils.getAddressForDisplay(tx.hash)),
          ]),
        ],
      ),
      footer: GWButton(
        onPressed: () {
          final url = getExplorerUrl(tx.coinSymbol, tx.hash);
          final uri = Uri.tryParse(url);
          if (uri?.scheme.startsWith('http') ?? false) {
            launchWebSite(context, uri.toString());
          }
        },
        label: "View on Explorer",
        leading: const Icon(Icons.open_in_new),
        variant: GWButtonVariant.secondary,
        expand: true,
      ),
    );
  }
}

class TransactionPurchasedItem extends StatelessWidget {
  final Transaction tx;

  const TransactionPurchasedItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isFailed = tx.transactionStatus == TransactionStatus.failed;
    final amount = isFailed
        ? currencyFormatter.format(0)
        : "+ ${currencyFormatter.format(double.tryParse(tx.recipients.first.amount) ?? 0)}";
    const arrowIcon = Icons.attach_money;
    final arrowBgColor = isFailed
        ? GeniusWalletColors.statusError
        : GeniusWalletColors.brandGreen;
    final amountColor = isFailed
        ? GeniusWalletColors.statusError
        : GeniusWalletColors.brandGreen;

    return Container(
      decoration: GWDecorations.surface(
        radius: GeniusWalletConsts.radiusMd,
        border: gw.borderSubtle,
      ),
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
                color: isFailed
                    ? GeniusWalletColors.statusError
                    : gw.textPrimary,
              ),
            ),
            Text(
              " • ${tx.coinSymbol}",
              style: TextStyle(fontSize: 14, color: gw.textSecondary),
            ),
          ],
        ),
        subtitle: Text(
          timeago.format(tx.timeStamp.toLocal()),
          style: TextStyle(fontSize: 12, color: gw.textSecondary),
        ),
        trailing: _buildAmountTrailing(
          amountColor,
          amount,
          isFailed,
          gw.textSecondary,
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isFailed = tx.transactionStatus == TransactionStatus.cancelled;
    final arrowBgColor = isFailed
        ? GeniusWalletColors.statusError
        : GeniusWalletColors.brandGreen;
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
                color: isFailed
                    ? GeniusWalletColors.statusError
                    : gw.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailsCard(context, [
            _buildRow(
              context,
              "Date",
              _dateFormat.format(tx.timeStamp.toLocal()),
            ),
            _buildRow(
              context,
              "Status",
              _capitalizeStatus(tx.transactionStatus),
              valueColor:
                  isFailed ? GeniusWalletColors.statusError : gw.textPrimary,
            ),
            _buildRow(
              context,
              "To",
              WalletUtils.getAddressForDisplay(tx.recipients.first.toAddr),
            ),
            _buildRow(context, "Network", tx.coinSymbol),
            _buildRow(context, "Network Fee", "${tx.fees} ${tx.coinSymbol}"),
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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final isFailed = tx.transactionStatus == TransactionStatus.failed;
    final fromSymbol = tx.fromSymbol ?? "";
    final toSymbol = tx.toSymbol ?? "";
    final fromIcon = tx.fromIconUrl;
    final toIcon = tx.toIconUrl;
    final fromAmount = tx.fromAmount ?? "0";
    final toAmount = tx.toAmount ?? "0";

    return Container(
      decoration: GWDecorations.surface(
        radius: GeniusWalletConsts.radiusMd,
        border: gw.borderSubtle,
      ),
      child: ListTile(
        title: Text(
          "Swapped${isFailed ? ' - Failed' : ''}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isFailed ? GeniusWalletColors.statusError : gw.textPrimary,
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
          gw,
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
    GWColors gw,
  ) {
    if (isFailed) {
      return Text(
        "0 $toSymbol",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GeniusWalletColors.statusError,
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
            color: GeniusWalletColors.brandGreen,
          ),
        ),
        Text(
          "- $fromAmount $fromSymbol",
          style: TextStyle(fontSize: 14, color: gw.textSecondary),
        ),
      ],
    );
  }

  void _showSwapTransactionDetails(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
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
                color: isFailed
                    ? GeniusWalletColors.statusError
                    : gw.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailsCard(context, [
            _buildRow(
              context,
              "Date",
              _dateFormat.format(tx.timeStamp.toLocal()),
            ),
            _buildRow(
              context,
              "Status",
              _capitalizeStatus(tx.transactionStatus),
              valueColor:
                  isFailed ? GeniusWalletColors.statusError : gw.textPrimary,
            ),
            _buildRow(context, "From", "$fromAmount $fromSymbol"),
            _buildRow(context, "To", "$toAmount $toSymbol"),
            _buildRow(context, "Transaction Fee", "${tx.fees} $fromSymbol"),
            _buildRow(context, "Tx Hash", tx.hash),
          ]),
        ],
      ),
    );
  }
}
