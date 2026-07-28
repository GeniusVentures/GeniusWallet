import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Every detail row's inset, owned here rather than by the grid, so that a row
/// which is TAPPABLE (the receipt's copy rows) can put its own hit area around
/// its padding instead of inside it.
///
/// If [GWDetailGrid] padded its children, the tappable area of a copy row would
/// stop 12px short of the cell it appears to fill, which is the kind of miss
/// nobody reports and everybody feels.
const EdgeInsets kGWDetailRowPadding = EdgeInsets.symmetric(
  horizontal: GeniusWalletConsts.space6,
  vertical: GeniusWalletConsts.space4,
);

/// A read-only label/value table: one recessed well, hairline-ruled between
/// rows.
///
/// Built for the transaction receipt (sketch 154-A's TRANSACTION / NETWORK
/// groups) at Jakub's request on 2026-07-28, after the first pass shipped the
/// rows bare and the grouping went with them.
///
/// **Why this is allowed to be a container when sketch 067 said a card is not.**
/// 067 measured a card on this panel at 1.00:1 and concluded the only
/// 1.4.11-passing edge is white 36%. That conclusion holds for what 067 was
/// looking at - a box around a FORM, whose border is part of identifying the
/// control inside it. This is a read-only table. Its hairlines carry no
/// information: every row is fully readable with the rules removed, and the
/// text inside clears AA on its own. That makes them decorative separators,
/// the same category as the drawer header's own hairline, which
/// `responsive_drawer.dart` documents as *"not a WCAG 1.4.11 graphical-object"*.
/// So `borderSubtle` is the right weight here and 36% would be wrong - it would
/// make the table's frame louder than its contents.
///
/// The fill is `surfaceSunken`: on the 156-A panel it is only 1.04:1, so it is
/// not doing the separating - the hairline is. It is there so the group reads
/// as recessed rather than raised, matching the drawer's input treatment, and
/// so the table does not read as a card floating on a card.
class GWDetailGrid extends StatelessWidget {
  const GWDetailGrid({super.key, required this.rows});

  /// Each child supplies its own [kGWDetailRowPadding]. An empty list renders
  /// nothing at all rather than an empty box - a receipt for a type with no
  /// rows in a section should not show its frame.
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: gw.surfaceSunken,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        border: Border.all(color: gw.borderSubtle, width: 1),
      ),
      // The rules run edge to edge, so without this they would paint over the
      // rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Container(height: 1, color: gw.borderSubtle),
            rows[i],
          ],
        ],
      ),
    );
  }
}
