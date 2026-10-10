// Check for GWPageHeader's `centered` branch (added 2026-07-26 for the two
// focused-form tabs, Swap and Feedback).
//
// The failure this guards against is the one the old hand-rolled swap header
// had: a title "centred" by balancing a 24px SizedBox against a 48px
// IconButton, i.e. off-centre by 12px and nobody could say why. So the
// assertion is arithmetic on the laid-out geometry, not a golden.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';

/// Captured from inside the pumped tree, so the left-aligned expectation below
/// reads the SAME inset the component applies at the SAME breakpoint instead of
/// restating a number that could silently disagree with it.
late double _inset;

Widget _host({required bool centered, Widget? trailing}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 600,
        child: Builder(
          builder: (context) {
            _inset = gwPageHeaderContentInset(context);
            return GWPageHeader(
              title: 'Swap',
              subtitle: 'Trade any token across chains',
              centered: centered,
              trailing: trailing,
            );
          },
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('centered title centres on the column, trailing pins right', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        centered: true,
        trailing: const IconButton(onPressed: null, icon: Icon(Icons.tune)),
      ),
    );

    final column = tester.getRect(find.byType(GWPageHeader));
    final title = tester.getRect(find.text('Swap'));
    final subtitle = tester.getRect(find.text('Trade any token across chains'));
    final trailing = tester.getRect(find.byType(IconButton));

    // Off-centre by even half a hit target is the bug this file exists for.
    expect(title.center.dx, moreOrLessEquals(column.center.dx, epsilon: 0.5));
    expect(
      subtitle.center.dx,
      moreOrLessEquals(column.center.dx, epsilon: 0.5),
    );
    expect(trailing.right, moreOrLessEquals(column.right, epsilon: 0.5));
    // The trailing widget must not steal width from the centring.
    expect(title.center.dx, lessThan(trailing.left));
  });

  testWidgets("with a subtitle, a centred trailing sits on the title's centre "
      'line', (tester) async {
    await tester.pumpWidget(
      _host(
        centered: true,
        trailing: const SizedBox(
          key: Key('glyph'),
          width: 48,
          height: 32,
          child: Icon(Icons.tune),
        ),
      ),
    );

    final column = tester.getRect(find.byType(GWPageHeader));
    final title = tester.getRect(find.text('Swap'));
    final trailing = tester.getRect(find.byKey(const Key('glyph')));

    // Centred on the whole identity block (title + gap + subtitle) it sat
    // 22px below the title's own centre on the phone Swap header.
    expect(trailing.center.dy, moreOrLessEquals(title.center.dy, epsilon: 0.5));
    // And the glyph did not buy that by pulling the title off the column's
    // centre, or off the column's right edge.
    expect(title.center.dx, moreOrLessEquals(column.center.dx, epsilon: 0.5));
    expect(trailing.right, moreOrLessEquals(column.right, epsilon: 0.5));
  });

  testWidgets('a 32-tall trailing does not grow the header', (tester) async {
    await tester.pumpWidget(_host(centered: true));
    final bare = tester.getSize(find.byType(GWPageHeader)).height;

    await tester.pumpWidget(
      _host(
        centered: true,
        trailing: const SizedBox(
          width: 48,
          height: 32,
          child: Icon(Icons.tune),
        ),
      ),
    );

    // The title line is 32 tall, so a 48x32 box rides inside it. A 48-tall one
    // would make the line 48 and the header 16 taller.
    expect(tester.getSize(find.byType(GWPageHeader)).height, bare);
  });

  testWidgets('default stays left-aligned for the content tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_host(centered: false));

    final column = tester.getRect(find.byType(GWPageHeader));
    final title = tester.getRect(find.text('Swap'));
    final subtitle = tester.getRect(find.text('Trade any token across chains'));

    // `+ _inset` since 2026-08-08 (Jakub, walking `/assets` scheme C): the
    // left-aligned form insets its identity row by `gwPageHeaderContentInset`
    // so a page title heads the page's CONTENT column rather than its
    // container. The centred form above is deliberately NOT inset, and that
    // asymmetry is the thing these two cases together now pin.
    expect(title.left, moreOrLessEquals(column.left + _inset, epsilon: 0.5));
    expect(subtitle.left, moreOrLessEquals(column.left + _inset, epsilon: 0.5));
  });
}
