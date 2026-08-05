import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
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
    super.key,
  });

  String get fiat => "${order.fiatAmount} ${order.fiat}";
  String get crypto => "${order.cryptoAmount} ${order.crypto.id}";

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    try {
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime.toLocal());
    } catch (_) {
      return dateTime.toString();
    }
  }

  String _shortId(String id, {int head = 6, int tail = 4}) {
    if (id.length <= head + tail + 1) {
      return id;
    }
    return '${id.substring(0, head)}…${id.substring(id.length - tail)}';
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space2,
        vertical: GeniusWalletConsts.space4,
      ),
      child: GWCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 2.0,
          children: [
            // Top Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Order #${_shortId(order.id)}",
                    style: GeniusWalletTypography.titleLg.copyWith(
                      color: gw.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: GeniusWalletConsts.space4),
                OrderStatusPill(status: order.status),
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
              children: [
                // Expanded + Align (rather than the bare button `Row` this
                // replaces) so neither slot's natural width can overflow the
                // 300px grid tile — each half falls back to its own
                // `GWButton`'s existing label ellipsis before that happens.
                // The if/else-if/else gating on the status string is
                // unchanged (D-01); only the overflow-safety wrapper is new.
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: order.status.toLowerCase() == 'pendingpayment'
                        ? GWButton(
                            onPressed: onCompletePayment,
                            label: 'Complete Payment',
                            variant: GWButtonVariant.gradient,
                            size: GWButtonSize.sm,
                          )
                        : order.status.toLowerCase() == 'declined'
                        ? GWButton(
                            onPressed: onRetryOrder,
                            label: 'Retry Order',
                            variant: GWButtonVariant.secondary,
                            size: GWButtonSize.sm,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GWButton(
                      onPressed: onSeeDetails,
                      label: 'See Details',
                      variant: GWButtonVariant.tertiary,
                      size: GWButtonSize.sm,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const OrderInfoRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
