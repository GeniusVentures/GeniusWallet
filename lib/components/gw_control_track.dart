import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The shared control-track CONTAINER (`.planning/codebase/CONVENTIONS.md`,
/// "Control track"): a pill-shaped, recessed well holding a row of small
/// chips - a segmented control or a filter bar. The recipe is fixed and
/// documented there - `surfaceSunken` fill, a `borderSubtle` hairline,
/// `radiusPill`, `EdgeInsets.all(3)` track padding, `SizedBox(width: 2)`
/// between children - "partial adoption reads as a different design language
/// on the same screen."
///
/// This is now the SINGLE place those five values live. Four consumers:
/// [GWTimeframeSegment] (`gw_timeframe_segment.dart`), `_TransactionFilterBar`
/// (`transactions_slim_view.dart`), the Buy GNUS "Your orders" filter
/// track (`banxa_buy_screen.dart`), and the Compute panel's balance unit
/// track (`_UnitTrack` in `compute_panel.dart`, `260731-kc5`). Converging
/// all four onto one container is what turns CONVENTIONS.md's "they change
/// together" pairing rule from a comment into something the compiler
/// enforces - editing this file is now the only way to move any of the five
/// values, so the four tracks cannot drift apart by editing one file the
/// way the first two already had.
///
/// This widget owns geometry ONLY. It does not know what a "chip" is, does
/// not take a selected index, and does not add a variant flag - each
/// consumer keeps owning its own chip widgets and selection logic. A caller
/// that needs a non-chip child (the transactions bar's vertical divider, its
/// overflow trigger) passes it as an ordinary child; this widget interleaves
/// the 2px gap between every adjacent pair regardless of what they are.
class GWControlTrack extends StatelessWidget {
  const GWControlTrack({required this.children, super.key});

  /// The track's contents, in order. A 2px gap is inserted between every
  /// adjacent pair - never before the first child or after the last.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency so the track
    // re-skins on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: gw.surfaceSunken,
        border: Border.all(color: gw.borderSubtle),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            children[i],
          ],
        ],
      ),
    );
  }
}
