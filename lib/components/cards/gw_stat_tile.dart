import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A small uppercase label over a number: the app's stat/KPI unit.
///
/// Promoted 2026-07-28 on Jakub's explicit call, and it is worth recording that
/// it did **not** clear the usual bar. `GWKicker`, `GWSelectRow` and
/// `GWWarningNote` were each promoted on a THIRD consuming file; this had one
/// (`markets_hero_card.dart`'s private `_Stat`, four call sites) and the coin
/// page made it a second. Jakub overrode the file count on the instance count:
/// **ten uses of one two-line widget**, and the widget is small enough that a
/// component costs less than the second copy.
///
/// Values are taken VERBATIM from `_Stat`, so migrating the Markets hero moves
/// nothing on screen: `GWKicker(dense)` at 11/w600/0.6, a 3px gap, and the
/// number at `numericBody` 15/w600 with line-height 20.
///
/// **The box is NOT part of this.** On the Markets hero these sit bare inside
/// the card, separated by a hairline; on the coin page each one is inside its
/// own `GWCard`. That is composition at the call site rather than a `boxed`
/// flag, which would have been a parameter for one consumer.
///
/// Likewise there is no `footer` slot for the coin page's 24h-range bar - the
/// caller wraps this in a `Column` and puts the bar under it.
class GWStatTile extends StatelessWidget {
  const GWStatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;

  /// Overrides the number's colour - the coin page's 24h change and From ATH
  /// tiles carry `statusSuccess` / `statusError`. Null keeps `textPrimary`, so
  /// every Markets call site renders exactly what it rendered before.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GWKicker(label, dense: true),
        const SizedBox(height: 3),
        Text(
          value,
          style: GeniusWalletTypography.numericBody.copyWith(
            color: valueColor ?? gw.textPrimary,
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
