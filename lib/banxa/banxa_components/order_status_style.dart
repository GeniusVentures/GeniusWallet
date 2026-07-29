import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The single shared 4-bucket order-status paint ladder (09-CONTEXT.md D-01,
/// 09-UI-SPEC.md Color section: "one ladder reused across order_card.dart,
/// order_details_card.dart and order_details_page.dart's banner").
///
/// This EXTENDS today's status coloring and never inverts it (09-UI-SPEC
/// Interaction rule 7): every status string that has a colour today keeps the
/// same semantic bucket.
enum OrderStatusTone { success, warning, error, neutral }

/// The 4-bucket switch on `status.toLowerCase()`. Case labels preserve the
/// branch shape of `order_card.dart`'s (pre-existing) `_getStatusColor()`.
/// The `default` arm returns [OrderStatusTone.neutral].
OrderStatusTone orderStatusTone(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return OrderStatusTone.success;
    case 'pendingpayment':
    case 'pending':
    case 'inprogress':
      return OrderStatusTone.warning;
    case 'declined':
    case 'cancelled':
    case 'expired':
    case 'failed':
      return OrderStatusTone.error;
    default:
      return OrderStatusTone.neutral;
  }
}

/// The foreground/background paint for a tone, copied verbatim from the
/// shipped `_statusPill` (`lib/dashboard/home/widgets/transaction_displays.dart`).
({Color fg, Color bg}) orderStatusPaint(OrderStatusTone tone, GWColors gw) {
  switch (tone) {
    case OrderStatusTone.success:
      return (
        fg: gw.statusSuccess,
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
      return (fg: gw.statusError, bg: gw.statusError.withValues(alpha: 0.14));
    case OrderStatusTone.neutral:
      return (fg: gw.textSecondary, bg: gw.surfaceMenu);
  }
}

/// The status pill: a live `GWColors` read, a 6px dot in the tone's
/// foreground colour, a 5px gap, then the uppercase status text in
/// `GeniusWalletTypography.labelMd` at weight 600 in the foreground colour.
/// Preserves `order_card.dart`'s existing uppercase presentation — the copy
/// is unchanged, only the paint.
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
            status.toUpperCase(),
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

/// Classifies the same three status strings `BanxaHelpers.getBannerInfo()`
/// switches on (`banxa_helpers.dart` stays byte-for-byte per D-06 — only its
/// consumer's render recipe changes here), returning null where that helper
/// would return null.
OrderStatusTone? bannerTone(String? initialStatus) {
  final s = initialStatus?.toLowerCase();
  if (s == 'cancel') {
    return OrderStatusTone.warning;
  }
  if (s == 'failure' || s == 'failed') {
    return OrderStatusTone.error;
  }
  if (s == 'success' || s == 'completed') {
    return OrderStatusTone.success;
  }
  return null;
}

/// The three-severity tinted banner container, generalising `GWErrorBanner`'s
/// recipe (`lib/components/feedback/gw_error_state.dart`): an alpha-31 tint of
/// the tone's foreground, `radiusMd`, an alpha-100 border of the same, a
/// coloured leading icon and `bodySm` text in the tone's foreground.
class OrderStatusBanner extends StatelessWidget {
  const OrderStatusBanner({required this.text, required this.tone, super.key});

  final String text;
  final OrderStatusTone tone;

  IconData get _icon {
    switch (tone) {
      case OrderStatusTone.success:
        return Icons.check_circle_outline;
      case OrderStatusTone.warning:
        return Icons.info_outline;
      case OrderStatusTone.error:
        return Icons.error_outline;
      case OrderStatusTone.neutral:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final (:fg, bg: _) = orderStatusPaint(tone, gw);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      decoration: BoxDecoration(
        color: fg.withAlpha(31),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        border: Border.all(color: fg.withAlpha(100)),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 18, color: fg),
          const SizedBox(width: GeniusWalletConsts.space4),
          Expanded(
            child: Text(
              text,
              style: GeniusWalletTypography.bodySm.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
