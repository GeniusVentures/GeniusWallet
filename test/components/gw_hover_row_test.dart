// GWHoverRow's contract, and the three defects it was extracted to close
// (2026-07-30 walk: Assets had no hover, Markets had square corners,
// Transactions had the treatment everyone should have had).
//
// The highlight itself is an ink feature - it is painted, not a widget - so it
// cannot be found in the tree. What CAN be pinned is every input that decides
// it, and those are exactly the three things that differed between the three
// lists: whether a local Material exists to paint on, what radius clips it, and
// what colour it uses instead of the theme default.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/effects/gw_hover_row.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

Widget _host({VoidCallback? onTap, GWColors? colors}) => MaterialApp(
  theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 400,
        child: GWHoverRow(
          onTap: onTap,
          child: const SizedBox(height: 56, child: Text('row')),
        ),
      ),
    ),
  ),
);

InkWell _inkOf(WidgetTester tester) =>
    tester.widget<InkWell>(find.byType(InkWell));

void main() {
  testWidgets('the highlight is rounded at radiusMd, never square', (
    tester,
  ) async {
    await tester.pumpWidget(_host(onTap: () {}));

    expect(
      _inkOf(tester).borderRadius,
      BorderRadius.circular(GeniusWalletConsts.radiusMd),
      reason:
          'a null borderRadius is what painted the Markets rows as '
          'full-bleed rectangles while Transactions painted rounded',
    );
  });

  testWidgets('it states its own hover colour instead of inheriting one', (
    tester,
  ) async {
    await tester.pumpWidget(_host(onTap: () {}));

    final gw = GWColors.dark();
    expect(
      _inkOf(tester).hoverColor,
      gw.textPrimary.withValues(alpha: kGWRowHoverAlpha),
    );

    // And it follows the appearance, because it is derived from a token that
    // does: on light it must be INK-tinted, not white-tinted, or the highlight
    // would brighten an already-white card into nothing.
    await tester.pumpWidget(_host(onTap: () {}, colors: GWColors.light()));
    expect(
      _inkOf(tester).hoverColor,
      GWColors.light().textPrimary.withValues(alpha: kGWRowHoverAlpha),
    );
  });

  testWidgets('it carries its own Material, so the ink cannot be buried', (
    tester,
  ) async {
    await tester.pumpWidget(_host(onTap: () {}));

    // The Assets bug: a ListTile paints its ink on the nearest ancestor
    // Material, and on the dashboard that ancestor sits under the panel's own
    // background. The nearest Material above the InkWell must belong to
    // GWHoverRow and must be transparent, so it stacks ON the caller's paint
    // rather than being covered by it.
    final material = tester.widget<Material>(
      find
          .ancestor(of: find.byType(InkWell), matching: find.byType(Material))
          .first,
    );
    expect(material.color, Colors.transparent);
  });

  testWidgets('a row that does nothing does not claim it does', (tester) async {
    await tester.pumpWidget(_host());

    expect(_inkOf(tester).onTap, isNull);
    expect(_inkOf(tester).mouseCursor, SystemMouseCursors.basic);
  });

  testWidgets('a tappable row takes the click cursor', (tester) async {
    await tester.pumpWidget(_host(onTap: () {}));

    expect(_inkOf(tester).mouseCursor, SystemMouseCursors.click);
  });

  testWidgets('the hit area is exactly the child, not a padded box', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_host(onTap: () => taps++));

    final rowRect = tester.getRect(find.byType(GWHoverRow));
    final childRect = tester.getRect(find.byType(Text));
    expect(rowRect.width, 400);
    expect(rowRect.height, 56);
    expect(rowRect.contains(childRect.center), isTrue);

    await tester.tap(find.byType(GWHoverRow));
    expect(taps, 1);
  });

  testWidgets('hovering does not throw and repaints in place', (tester) async {
    await tester.pumpWidget(_host(onTap: () {}));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.byType(GWHoverRow)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Geometry must not move under the pointer — a row hover that resized or
    // lifted would make a list flicker as the pointer ran down it, which is
    // the reason rows do not take the chip's "lift" response.
    expect(tester.getRect(find.byType(GWHoverRow)).height, 56);

    await gesture.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
