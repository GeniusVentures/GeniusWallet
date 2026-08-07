import 'package:flutter/material.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/overlay/nav_destinations.dart';
import 'package:genius_wallet/components/overlays/gw_bottom_sheet.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

/// The way into the More sheet.
///
/// Until 2026-08-07 the sheet was opened by a `More` slot on the bottom bar.
/// Sketch 182 scheme S7 took that slot for News and moved the entrance to the
/// header's hamburger, in the SAME change - the four rows below would otherwise
/// have become unreachable on the phone, Settings included.
class MoreSheet {
  MoreSheet._();

  /// Opens the sheet, with the same title the bar's `More` slot used.
  ///
  /// The title stays `More`. Renaming it belongs to the redesigned menu page,
  /// and sketch 184 is unpicked.
  static Future<void> show(BuildContext context) => GWBottomSheet.show<void>(
    context: context,
    title: 'More',
    child: const MoreSheetBody(),
  );
}

/// The More sheet's rows: every destination the bar could not hold, plus a way
/// into the accounts drawer.
///
/// Opened from the header's HAMBURGER as of 2026-08-07, not from a bar slot.
/// Its rows are DERIVED from [moreDestinations] rather than written out, so
/// changing what the bar shows changes what this sheet holds with no edit here.
///
/// Its `Accounts` row duplicates the wallet control that sits beside the
/// hamburger in the header: both reach the accounts drawer. That was already
/// true when the wallet control was a 224px pill and the entrance was a bar
/// slot, so it is not made worse by the move.
class MoreSheetBody extends StatelessWidget {
  const MoreSheetBody({super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...moreDestinations.map(
          (d) => GWSelectRow(
            leading: Icon(d.icon, size: 21, color: gw.textPrimary80),
            title: d.label,
            onTap: () {
              Navigator.of(context).pop();
              context.go(d.path);
            },
          ),
        ),
        GWSelectRow(
          leading: Icon(
            Icons.account_balance_wallet_outlined,
            size: 21,
            color: gw.textPrimary80,
          ),
          title: 'Accounts',
          subtitle: 'SDK accounts and your wallets',
          onTap: () {
            Navigator.of(context).pop();
            AccountDrawer.show(context);
          },
        ),
      ],
    );
  }
}
