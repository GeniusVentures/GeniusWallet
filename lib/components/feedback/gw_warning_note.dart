import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A bordered amber note: "this is fine, but read it before you continue".
///
/// Promoted 2026-07-28 on its third consumer, the same test [GWKicker] and
/// [GWSelectRow] were held to. The first was `crypto_address_qr.dart`'s
/// network-mismatch note (sketch 034-A2); the second and third are the SDK
/// drawer's recovery-phrase field and recovery QR.
///
/// **The colour is the reason this is a component and not a Row.**
/// `GeniusWalletColors.statusWarning` (#FFC42E) is a FILL-tuned token: about
/// 13:1 on the dark canvas and roughly **1.6:1 on white**, so used as an icon
/// or a border on a light surface it simply is not there.
/// `crypto_address_qr.dart` hit that first and worked out the answer - a
/// darkened amber at ~7.1:1 on white. That value now lives in one place instead
/// of being re-derived, or worse, not re-derived.
///
/// ponytail: the darkened light-mode amber is a LOCAL constant rather than a
/// `gw.statusWarning` token, matching the note the original consumer left.
/// Ceiling: any other consumer of `statusWarning` as a foreground still fails
/// on light. Upgrade path: an appearance-aware `gw.statusWarning` getter
/// mirroring `gw.statusSuccess`/`gw.statusError`, after which this folds into
/// it - which is also what `transaction_displays.dart`'s status pill is waiting
/// for.
class GWWarningNote extends StatelessWidget {
  const GWWarningNote(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final amber = GWAppearance.isLight
        ? const Color(0xFF92400E) // ~7.1:1 on white
        : GeniusWalletColors.statusWarning; // ~13:1 on the dark canvas

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space6,
        vertical: GeniusWalletConsts.space4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: amber.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: amber),
          const SizedBox(width: GeniusWalletConsts.space4),
          // Flexible, not Expanded: the QR note is a `mainAxisSize.min` Row in
          // a Column that shrink-wraps, and Expanded would demand a bounded
          // width the caller does not always have.
          Flexible(
            child: Text(
              message,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
