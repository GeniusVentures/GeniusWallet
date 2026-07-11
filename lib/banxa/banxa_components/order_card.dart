import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banaxa_model.dart';
import 'package:genius_wallet/banxa/banxa_components/order_in_row.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onSeeDetails;
  final VoidCallback? onCompletePayment;
  final VoidCallback? onRetryOrder;
  const OrderCard({
    required this.order,
    this.onSeeDetails,
    this.onCompletePayment,
    this.onRetryOrder,
    Key? key,
  }) : super(key: key);

  String get fiat => "${order.fiatAmount} ${order.fiat}";
  String get crypto => "${order.cryptoAmount} ${order.crypto.id}";
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return GeniusWalletColors.statusSuccess;
      case 'pendingpayment':
      case 'pending':
        return GeniusWalletColors.statusWarning;
      case 'declined':
      case 'cancelled':
        return GeniusWalletColors.statusError;
      default:
        return GeniusWalletColors.textSecondary;
    }
  }

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    try {
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime.toLocal());
    } catch (_) {
      return dateTime.toString();
    }
  }

  String _shortId(String id, {int head = 6, int tail = 4}) {
    if (id.length <= head + tail + 1) return id;
    return '${id.substring(0, head)}…${id.substring(id.length - tail)}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space2,
          vertical: GeniusWalletConsts.space4),
      color: GeniusWalletColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        side: BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(GeniusWalletConsts.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: order ID + status chip (§6.6 status chip pattern).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${_shortId(order.id)}",
                  style: GeniusWalletTypography.titleMd,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GeniusWalletConsts.space4,
                      vertical: GeniusWalletConsts.space2),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(31), // ~12% per §6.6
                    borderRadius:
                        BorderRadius.circular(GeniusWalletConsts.radiusSm),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: GeniusWalletTypography.labelMd
                        .copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GeniusWalletConsts.space6),
            OrderInfoRow(label: "Fiat:", value: fiat),
            OrderInfoRow(label: "Crypto:", value: crypto),
            OrderInfoRow(label: "Payment:", value: order.paymentMethodName),
            const Divider(height: GeniusWalletConsts.space10),
            OrderInfoRow(label: "Created:", value: formatDate(order.createdAt)),
            OrderInfoRow(label: "Updated:", value: formatDate(order.updatedAt)),
            const SizedBox(height: GeniusWalletConsts.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (order.status.toLowerCase() == 'pendingpayment')
                  ElevatedButton(
                    onPressed: onCompletePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GeniusWalletColors.statusWarning,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              GeniusWalletConsts.radiusSm)),
                    ),
                    child: const Text('Complete Payment'),
                  )
                else if (order.status.toLowerCase() == 'declined')
                  OutlinedButton(
                    onPressed: onRetryOrder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GeniusWalletColors.statusError,
                      side: const BorderSide(
                          color: GeniusWalletColors.statusError),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              GeniusWalletConsts.radiusSm)),
                    ),
                    child: const Text('Retry Order'),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(width: GeniusWalletConsts.space4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(120, 44),
                    padding: const EdgeInsets.symmetric(
                        horizontal: GeniusWalletConsts.space6),
                    textStyle: GeniusWalletTypography.bodyMd
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  onPressed: onSeeDetails,
                  child: const Text('See Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
