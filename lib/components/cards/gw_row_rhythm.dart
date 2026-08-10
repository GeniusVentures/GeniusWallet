/// The four numbers Jakub named on 2026-08-07, walking the Transactions pilot
/// on his iPhone ("Sidney") and asking for it everywhere: from the card
/// content edge, the leading glyph is 38, the gap to the text column is 8,
/// the text column runs to 8 from the right content edge, and every rule
/// between two rows in a list sits 12 above / 1 / 12 below.
///
/// This file holds those numbers and nothing else - no widget, no
/// abstraction. `test/components/gw_row_rhythm_test.dart` MEASURES painted
/// ink against them, so a row cannot drift back to an undeclared default the
/// way Assets and Markets did (see (3) below).
///
/// Full derivation:
/// `.planning/quick/260807-v6m-dashboard-panel-bottom-inset-mirrors-the/SEPARATOR-RHYTHM-MEASURED.md`
///
/// **(1) Every spacing value here is an existing token.** [kGWRowWall],
/// [kGWRowIconToText] and [kGWRowSeparatorGap] are all named
/// [GeniusWalletConsts] entries (`space4` and `space6`) - nothing off-grid is
/// introduced by this file.
///
/// **(2) [kGWRowIconSize] (38) is the one untokened value, and it is a SIZE,
/// not a spacing.** It is Jakub's pick, taken from what the Assets row
/// (`CoinCardRow`) already shipped -
/// `buildTokenIcon(iconPath: iconPath, size: 38)` - not a new number invented
/// for this task.
///
/// **(3) These four numbers previously came from Material's default
/// two-line `ListTile` height and were undeclared anywhere in this repo.**
/// The measurement report above found Assets rendering 15.63 / 20.00 around
/// its rule and Markets rendering 13.25 / 16.75, neither of which any line in
/// this codebase chose - both were `ListTile`'s centring slack, invisible in
/// source at both the row and the divider that draws the rule. This file is
/// what stops that: one place the numbers live, and one test that measures
/// what actually renders rather than trusting source padding to predict it.
library;

import 'package:flutter/widgets.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

/// The gap from the card's inner content edge to the row's first painted
/// pixel, on every side: the leading glyph's left, and the trailing content's
/// right. `space4` (8) - see (1).
const double kGWRowWall = GeniusWalletConsts.space4;

/// The gap between the leading glyph and the text column. `space4` (8), the
/// same value as [kGWRowWall] so the row reads as one rhythm - a wall gap and
/// an internal gap that happen to differ would look like two different
/// decisions rather than one.
const double kGWRowIconToText = GeniusWalletConsts.space4;

/// The gap above a rule between two rows, and the gap below it - `space6`
/// (12). The rule's own height (1) is drawn at each call site, not held here.
///
/// `space6` is the midpoint of the app's measured [4, 20] range across the
/// three lists, sits on the 4-pt grid, and was already the shipped symmetric
/// value at `route_details_card.dart:104` and `markets_table.dart:181`/`:228`
/// before this task touched anything - a value this app had already settled
/// on, not a new one.
const double kGWRowSeparatorGap = GeniusWalletConsts.space6;

/// The leading glyph's side length. Untokened by design - see (2) above.
const double kGWRowIconSize = 38;

/// The row's own padding: [kGWRowWall] on every side horizontally,
/// [kGWRowSeparatorGap] top and bottom. Every row importing this constant
/// gets the same box; nothing about a specific row's anatomy leaks in here.
const EdgeInsets kGWRowPadding = EdgeInsets.symmetric(
  horizontal: kGWRowWall,
  vertical: kGWRowSeparatorGap,
);

/// The text column's left edge, measured from the row's own left edge.
///
/// DERIVED, never typed as a literal (it is not "54" anywhere in this file):
/// [kGWRowWall] + [kGWRowIconSize] + [kGWRowIconToText]. A future change to
/// any one term moves this - and the test that pins it - with it, instead of
/// silently going stale the way `dashboard_markets.dart`'s `contentTopInset`
/// and `transaction_displays.dart`'s class doc both did this same week.
const double kGWRowTextColumnX = kGWRowWall + kGWRowIconSize + kGWRowIconToText;
