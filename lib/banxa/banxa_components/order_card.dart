import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banaxa_model.dart';
import 'package:genius_wallet/banxa/banxa_components/order_in_row.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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
        return Colors.green;
      case 'pendingpayment':
      case 'pending':
        return Colors.orange;
      case 'declined':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      color: GeniusWalletColors.deepBlueCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
            color: GeniusWalletColors.lightGreenSecondary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${_shortId(order.id)}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OrderInfoRow(label: "Fiat:", value: fiat),
            OrderInfoRow(label: "Crypto:", value: crypto),
            OrderInfoRow(label: "Payment:", value: order.paymentMethodName),
            const Divider(height: 20),
            OrderInfoRow(label: "Created:", value: formatDate(order.createdAt)),
            OrderInfoRow(label: "Updated:", value: formatDate(order.updatedAt)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (order.status.toLowerCase() == 'pendingpayment')
                  ElevatedButton(
                    onPressed: onCompletePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Complete Payment'),
                  )
                else if (order.status.toLowerCase() == 'declined')
                  OutlinedButton(
                    onPressed: onRetryOrder,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Retry Order'),
                  )
                else
                  const SizedBox.shrink(),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(120, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500),
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
