// Check for the drawer shell owning its body inset (2026-07-27).
//
// This reverses 07-06's explicit prohibition, so the check has to prove BOTH
// halves of the reversal: that a caller which does nothing now gets the inset
// (the transaction receipt's bug — labels touching the panel edge), and that a
// caller which owns a scrolling viewport can still opt out to zero (the half of
// the prohibition that was right).
//
// The assertions are the DELTA between the two runs rather than absolute
// coordinates, so they survive a change to the toolbar height, the hairline or
// the panel radius — any of which would move the body without making the
// padding wrong.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

const _bodyKey = Key('drawer-body');

const _body = SizedBox.expand(
  child: ColoredBox(color: Color(0xFF00FF00), key: _bodyKey),
);

/// [bodyPadding] null means the argument is OMITTED entirely — which is the
/// case the second test exists to pin, so it cannot be faked by passing the
/// default explicitly.
Future<Rect> _openAndMeasure(
  WidgetTester tester, {
  EdgeInsetsGeometry? bodyPadding,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => bodyPadding == null
                ? ResponsiveDrawer.show<void>(
                    context: context,
                    title: 'Swap Settings',
                    child: _body,
                  )
                : ResponsiveDrawer.show<void>(
                    context: context,
                    title: 'Swap Settings',
                    bodyPadding: bodyPadding,
                    child: _body,
                  ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  final rect = tester.getRect(find.byKey(_bodyKey));

  // Dismiss before returning: the drawer is a ROUTE, and a second pumpWidget
  // does not tear it down — its barrier would swallow the next tap. The panel
  // is 420 wide and right-aligned, so x=10 is barrier, not panel.
  await tester.tapAt(const Offset(10, 300));
  await tester.pumpAndSettle();
  return rect;
}

void main() {
  testWidgets('the shell insets the body by kDrawerBodyPadding', (
    tester,
  ) async {
    final zero = await _openAndMeasure(tester, bodyPadding: EdgeInsets.zero);
    final padded = await _openAndMeasure(
      tester,
      bodyPadding: kDrawerBodyPadding,
    );

    // 20 on the sides and bottom, 24 on top — the header hairline sits
    // directly above and a flat 20 read as glued to it.
    expect(padded.left - zero.left, GeniusWalletConsts.space10);
    expect(zero.right - padded.right, GeniusWalletConsts.space10);
    expect(padded.top - zero.top, GeniusWalletConsts.space12);
    expect(zero.bottom - padded.bottom, GeniusWalletConsts.space10);
  });

  testWidgets('a caller that passes nothing still gets the inset', (
    tester,
  ) async {
    // The whole point of the reversal: forgetting now produces a CORRECT
    // drawer. If this ever fails, the default has been dropped from show()
    // and seventeen unwalked drawers silently lost their padding again.
    final zero = await _openAndMeasure(tester, bodyPadding: EdgeInsets.zero);
    // `bodyPadding: null` in the helper means "pass no argument at all".
    final defaulted = await _openAndMeasure(tester);
    expect(defaulted.left - zero.left, GeniusWalletConsts.space10);
  });

  testWidgets('the close glyph sits on the title axis, and its hover circle '
      'stays inside the panel', (tester) async {
    // Walk finding 2026-07-27: the ✕ box was flush to the panel edge (padding
    // zero, 36x36 constraints), so its hover circle bled over the drawer's own
    // right edge while the title sat 20 inside on the left.
    await _openAndMeasure(tester, bodyPadding: EdgeInsets.zero);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final title = tester.getRect(find.text('Swap Settings'));
    final glyph = tester.getRect(find.byIcon(Icons.close));
    final box = tester.getRect(find.byType(IconButton));
    // Measured against the PANEL, not the screen: the desktop drawer is a
    // right-aligned 420px column, so screen coordinates are offset by 380 and
    // an absolute assertion would be measuring the wrong thing.
    final panel = tester.getRect(find.byType(AppBar));

    // Glyph to glyph, both on the same 20 axis.
    expect(title.left - panel.left, moreOrLessEquals(20, epsilon: 0.5));
    expect(panel.right - glyph.right, moreOrLessEquals(20, epsilon: 0.5));

    // And the interactive box — the thing the hover circle is drawn on —
    // never reaches the edge.
    expect(panel.right - box.right, greaterThan(0));
  });

  test('the default value is the one promoted from _SlippageForm', () {
    expect(
      kDrawerBodyPadding,
      const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space10,
        GeniusWalletConsts.space12,
        GeniusWalletConsts.space10,
        GeniusWalletConsts.space10,
      ),
    );
  });
}
