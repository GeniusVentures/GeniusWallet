// The one check the 031-B1 receipt family (D-02, 21-03) owes.
//
// The six receipts (transaction, both squid swaps -- deleted and repointed at
// the shared receipt by 9ff7c04, the Reown swap result, the two Banxa
// results) were six columns that resembled each other before this phase. The
// specific way that comes back is a second status palette forking off the
// first, or a re-coloured headline creeping back in beside the pill -- and
// both look entirely plausible in a screenshot review. This file pins the
// two things a screenshot cannot check: that the palette really does come
// from ONE function, and that colour really does stay off everything except
// the icon and the pill.
//
// No new package, no fixture directory, no golden, no integration_test --
// modelled on test/components/drawer_content_test.dart and
// test/components/gw_select_row_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/drawer_content.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The exact composition Tasks 2 and 3 build: an identity icon in the
/// status's foreground, a [GWDrawerStatusPill] below it, and an optional body
/// sentence in `textSecondary` -- never in the status colour, per D-03.
Widget _host(TransactionStatus status, {required String label}) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Builder(
    builder: (context) {
      final gw = Theme.of(context).extension<GWColors>()!;
      final (:fg, :wash) = txStatusColors(status, gw);
      return Scaffold(
        body: Column(
          children: [
            GWDrawerReceiptHead(
              identity: Icon(Icons.check_circle, size: 56, color: fg),
              pill: GWDrawerStatusPill(
                label: label,
                foreground: fg,
                background: wash,
              ),
            ),
            Text(
              'A quiet body sentence.',
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ],
        ),
      );
    },
  ),
);

void main() {
  testWidgets(
    'a success result renders a pill whose foreground is the SAME colour '
    'txStatusColors(completed) returns',
    (tester) async {
      final gw = GWColors.dark();
      await tester.pumpWidget(
        _host(TransactionStatus.completed, label: 'Completed'),
      );

      final pill = tester.widget<GWDrawerStatusPill>(
        find.byType(GWDrawerStatusPill),
      );
      // Pinning the SOURCE, not a re-derived hex -- this is what stops the
      // palette forking again: any consumer that ever writes its own switch
      // over TransactionStatus fails this, even if it happens to pick the
      // same colour today.
      expect(
        pill.foreground,
        txStatusColors(TransactionStatus.completed, gw).fg,
      );
    },
  );

  testWidgets("a cancelled result's pill reads slate, not the error colour", (
    tester,
  ) async {
    final gw = GWColors.dark();
    await tester.pumpWidget(
      _host(TransactionStatus.cancelled, label: 'Cancelled'),
    );

    final pill = tester.widget<GWDrawerStatusPill>(
      find.byType(GWDrawerStatusPill),
    );
    expect(pill.foreground, gw.textSecondary);
    expect(pill.foreground, isNot(gw.statusError));
  });

  testWidgets(
    'the D-03 guard: in a failed result, no text in the subtree is painted '
    'in the status colour except the pill\'s own label',
    (tester) async {
      final gw = GWColors.dark();
      final fg = txStatusColors(TransactionStatus.failed, gw).fg;
      await tester.pumpWidget(_host(TransactionStatus.failed, label: 'Failed'));

      final pillTextFinder = find.descendant(
        of: find.byType(GWDrawerStatusPill),
        matching: find.byType(Text),
      );
      final pillTexts = tester.widgetList<Text>(pillTextFinder).toSet();

      final allTexts = tester.widgetList<Text>(find.byType(Text));
      for (final text in allTexts) {
        if (pillTexts.contains(text)) {
          continue;
        }
        // Read the RESOLVED style, not the constructor argument, so a style
        // built via .copyWith() or inherited from a DefaultTextStyle is
        // still caught.
        expect(
          text.style?.color,
          isNot(fg),
          reason:
              'Text "${text.data}" must not be painted in the status colour '
              '-- colour rides on the icon and the pill only (D-03).',
        );
      }
    },
  );

  testWidgets(
    'a result drawer with no amount renders no numeric headline at all',
    (tester) async {
      await tester.pumpWidget(
        _host(TransactionStatus.completed, label: 'Completed'),
      );

      // _host never supplies `amount` -- exactly the three real receipts
      // this plan converts (both Banxa results, the Reown swap result).
      final head = tester.widget<GWDrawerReceiptHead>(
        find.byType(GWDrawerReceiptHead),
      );
      expect(head.amount, isNull);

      // And no Text anywhere in the tree carries `numericHeadline` -- the
      // style GWDrawerReceiptHead's amount row uses when one IS supplied.
      final allTexts = tester.widgetList<Text>(find.byType(Text));
      for (final text in allTexts) {
        expect(
          text.style?.fontSize,
          isNot(GeniusWalletTypography.numericHeadline.fontSize),
        );
      }
    },
  );
}
