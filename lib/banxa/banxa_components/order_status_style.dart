import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The single shared 4-bucket order-status paint ladder, reused by every
/// order surface so a status reads the same colour everywhere.
enum OrderStatusTone { success, warning, error, neutral }

/// The paint bucket for a Banxa status string; anything unrecognised is
/// [OrderStatusTone.neutral].
OrderStatusTone orderStatusTone(String status) =>
    BanxaOrderStatus.parse(status).tone;

/// The foreground/background paint for a tone, copied verbatim from the
/// shipped `_statusPill` (`lib/dashboard/home/widgets/transaction_displays.dart`).
({Color fg, Color bg}) orderStatusPaint(OrderStatusTone tone, GWColors gw) {
  switch (tone) {
    case OrderStatusTone.success:
      return (
        // Foreground is statusSuccessText, NOT statusSuccess: the latter is
        // fill-tuned and reads under 3:1 as label text on its own light-mode
        // wash. The wash stays statusSuccess -- it IS a fill.
        fg: gw.statusSuccessText,
        bg: gw.statusSuccess.withValues(alpha: 0.14),
      );
    case OrderStatusTone.warning:
      return (
        // Foreground is statusWarningText, NOT statusWarning: the latter is
        // fill-tuned (~1.6:1 on a light canvas) and was invisible as pill
        // text in light mode. The wash stays statusWarning -- it IS a fill,
        // which is exactly what that token is for.
        fg: gw.statusWarningText,
        bg: gw.statusWarning.withValues(alpha: 0.16),
      );
    case OrderStatusTone.error:
      // Foreground is statusErrorText, NOT statusError -- same fill-vs-label
      // split as the success arm above.
      return (
        fg: gw.statusErrorText,
        bg: gw.statusError.withValues(alpha: 0.14),
      );
    case OrderStatusTone.neutral:
      return (fg: gw.textSecondary, bg: gw.surfaceMenu);
  }
}

/// The status pill: a live `GWColors` read, a 6px dot in the tone's
/// foreground colour, a 5px gap, then the uppercase status text in
/// `GeniusWalletTypography.labelMd` at weight 600 in the foreground colour.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final tone = orderStatusTone(status);
    final (:fg, :bg) = orderStatusPaint(tone, gw);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            BanxaOrderStatus.parse(status).label.toUpperCase(),
            style: GeniusWalletTypography.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
