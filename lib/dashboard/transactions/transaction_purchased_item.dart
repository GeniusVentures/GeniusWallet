import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:intl/intl.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:timeago/timeago.dart' as timeago;

final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

class TransactionPurchasedItem extends StatelessWidget {
  final Transaction tx;

  const TransactionPurchasedItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
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

    return Card(
      color: GeniusWalletColors.deepBlueMenu,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _showPurchaseTransactionDetails(context, tx),
        leading: _buildIcon(arrowBgColor, arrowIcon),
        title: Row(
          children: [
            Text(
              isFailed ? "Buy - Failed" : "Buy",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isFailed
                      ? GeniusWalletColors.statusError
                      : GeniusWalletColors.textPrimary),
            ),
            Text(
              " • ${tx.coinSymbol}",
              style: GeniusWalletTypography.bodyMd
                  .copyWith(color: GeniusWalletColors.textPrimary70),
            ),
          ],
        ),
        subtitle: Text(
          timeago.format(tx.timeStamp.toLocal()),
          style:
              TextStyle(fontSize: 12, color: GeniusWalletColors.textPrimary70),
        ),
        trailing: _buildAmount(amountColor, amount, isFailed),
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
              semanticLabel: tx.coinSymbol,
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
              child:
                  Icon(icon, size: 12, color: GeniusWalletColors.textOnBrand),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount(Color amountColor, String amount, bool isFailed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(amount,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: amountColor)),
        Text(
          isFailed
              ? currencyFormatter.format(0)
              : "Spent: ${currencyFormatter.format(double.tryParse(tx.fees) ?? 0)}",
          style:
              TextStyle(fontSize: 12, color: GeniusWalletColors.textPrimary70),
        )
      ],
    );
  }

  void _showPurchaseTransactionDetails(BuildContext context, Transaction tx) {
    final isFailed = tx.transactionStatus == TransactionStatus.cancelled;
    final arrowBgColor = isFailed
        ? GeniusWalletColors.statusError
        : GeniusWalletColors.brandGreen;
    final amountText = isFailed
        ? '\$0.00'
        : "+ \$${double.tryParse(tx.recipients.first.amount ?? '0')?.toStringAsFixed(2) ?? '0.00'}";

    ResponsiveDrawer.show(
      context: context,
      title: isFailed ? "Buy - Failed" : "Buy",
      children: [
        const SizedBox(height: GeniusWalletConsts.space8),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                'assets/images/crypto/${tx.coinSymbol.toLowerCase()}.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                semanticLabel: tx.coinSymbol,
                errorBuilder: (_, __, ___) =>
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
                  child: const Icon(Icons.attach_money,
                      size: 12, color: GeniusWalletColors.textOnBrand),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        Center(
          child: Text(
            amountText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isFailed
                  ? GeniusWalletColors.statusError
                  : GeniusWalletColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        Card(
          color: GeniusWalletColors.deepBlueMenu,
          shape: RoundedRectangleBorder(
              side:
                  BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(GeniusWalletConsts.space8),
            child: Column(
              children: [
                _buildRow(
                    "Date",
                    DateFormat("MMMM d, y 'at' h:mm a")
                        .format(tx.timeStamp.toLocal())),
                _buildRow(
                    "Status",
                    tx.transactionStatus.name[0].toUpperCase() +
                        tx.transactionStatus.name.substring(1),
                    valueColor: isFailed
                        ? GeniusWalletColors.statusError
                        : GeniusWalletColors.textPrimary),
                _buildRow(
                    "To",
                    WalletUtils.getAddressForDisplay(
                        tx.recipients.first.toAddr)),
                _buildRow("Network", tx.coinSymbol),
                _buildRow("Network Fee", "${tx.fees} ${tx.coinSymbol}"),
              ],
            ),
          ),
        ),
      ],
      // TODO maybe show a banxa confirmation button to launch web with orderId..
      // footer: ElevatedButton(
      //   onPressed: () {
      //     final url = getExplorerUrl(tx.coinSymbol, tx.hash);
      //     final uri = Uri.tryParse(url);
      //     if (uri?.scheme.startsWith('http') ?? false) {
      //       launchWebSite(context, uri.toString());
      //     }
      //   },
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: Colors.lightBlueAccent,
      //     shape:
      //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //     minimumSize: const Size.fromHeight(48),
      //   ),
      //   child: const Text(
      //     "View on Explorer",
      //     style: TextStyle(color: GeniusWalletColors.deepBlueTertiary),
      //   ),
      //),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: GeniusWalletColors.textPrimary70)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? GeniusWalletColors.textPrimary)),
        ],
      ),
    );
  }
}
