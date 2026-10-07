import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

final _supportUri = Uri.parse('https://support.banxa.com');

/// What an order's status means and the one step it needs. A checkout link
/// from the API only reopens in the app when it passes the trusted-host rule.
class OrderDrawerFooter extends StatelessWidget {
  const OrderDrawerFooter({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final status = order.banxaStatus;
    final resume = switch (status) {
      BanxaOrderStatus.pendingPayment => 'Complete payment',
      BanxaOrderStatus.extraVerification => 'Continue verification',
      _ => null,
    };
    final canResume =
        resume != null &&
        isTrustedCheckoutUrl(Uri.tryParse(order.orderStatusUrl) ?? Uri());
    final canRetry = switch (status) {
      BanxaOrderStatus.declined ||
      BanxaOrderStatus.expired ||
      BanxaOrderStatus.cancelled => true,
      _ => false,
    };
    final showSupport = switch (status) {
      BanxaOrderStatus.extraVerification ||
      BanxaOrderStatus.declined ||
      BanxaOrderStatus.expired ||
      BanxaOrderStatus.refunded => true,
      _ => false,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          status.description,
          textAlign: TextAlign.center,
          style: GeniusWalletTypography.bodyMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
        if (canResume) ...[
          const SizedBox(height: GeniusWalletConsts.space8),
          GWButton(
            label: resume,
            variant: GWButtonVariant.gradient,
            size: GWButtonSize.sm,
            expand: true,
            onPressed: () => _leaveAndPush(context, '/checkout', {
              'orderId': order.id,
              'checkoutUrl': order.orderStatusUrl,
            }),
          ),
        ],
        if (canRetry) ...[
          const SizedBox(height: GeniusWalletConsts.space8),
          GWButton(
            label: 'Try again',
            variant: GWButtonVariant.gradientOutline,
            size: GWButtonSize.sm,
            expand: true,
            onPressed: () => _leaveAndPush(context, '/buy', {
              'fiat': order.fiat,
              'amount': order.fiatAmount,
            }),
          ),
        ],
        if (showSupport) ...[
          const SizedBox(height: GeniusWalletConsts.space4),
          GWButton(
            label: 'Contact Banxa support',
            trailing: const Icon(Icons.open_in_new, size: 16),
            variant: GWButtonVariant.ghost,
            size: GWButtonSize.sm,
            expand: true,
            onPressed: () =>
                launchUrl(_supportUri, mode: LaunchMode.externalApplication),
          ),
        ],
      ],
    );
  }
}

// The router is read before the pop: the pop deactivates this context.
void _leaveAndPush(BuildContext context, String path, Object extra) {
  final router = GoRouter.of(context);
  Navigator.of(context).pop();
  router.push(path, extra: extra);
}
