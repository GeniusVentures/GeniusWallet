// The drawer footer's bottom inset is CAPPED, and stays capped (2026-08-07).
//
// The defect this pins: the footer paid the bottom safe-area inset twice over.
// `showModalBottomSheet(useSafeArea: true)` resolves to `SafeArea(bottom:
// false, ...)` in the pinned SDK, so the route neither consumed the bottom
// padding nor stripped it from the MediaQuery; the full 34pt then reached the
// shell's own `SafeArea(top: false)` around the footer, which consumed all of
// it on top of `kDrawerFooterPadding`'s 20. That produced 20 above the button
// and 54 below it. Reported live by Jakub on his iPhone.
//
// Nothing in `test/` covered this. `drawer_padding_invariant_test.dart` asserts
// the call-site census and each site's `bodyPadding` argument; it pumps no
// widget and reads no footer code, so it neither catches this nor needed
// editing. This file is that missing gate.
//
// The assertions are GEOMETRY (`tester.getRect`) rather than reads of a
// Padding widget's fields, so they survive a refactor that moves the inset
// between widgets - including the one that would matter most here, putting the
// SafeArea back. Verified to FAIL against the pre-fix shell before it shipped:
// 54, 20 and 32 measured where 40, 20 and 32 are asserted.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

const _footerChildKey = Key('drawer-footer-child');

/// Stands in for the `lg` button every single-action drawer footer ships.
const _footer = SizedBox(
  key: _footerChildKey,
  height: 56,
  width: double.infinity,
);

/// The top rule the shell paints above the footer. `Container` folds a
/// `BoxDecoration`'s border dimensions into its own padding, so the 1px rule
/// shows up in the measured gap above the child. Asserting it explicitly is
/// what makes the "above" numbers below exact rather than approximate.
const double _kTopRuleWidth = 1.0;

/// What the footer measures, in one shape.
typedef _FooterMetrics = ({
  /// Space between the footer child's BOTTOM edge and the bottom of the
  /// drawer's own Scaffold - the screen's bottom edge on the mobile sheet.
  /// Anchoring here rather than on the footer Container is deliberate: it is
  /// the gap the user actually sees, and it reads the same whether the inset
  /// lives in a padding, in a SafeArea or in a SizedBox. Anchoring on the
  /// Container would have measured 20 both before and after the fix, because
  /// the old SafeArea sat OUTSIDE it.
  double below,

  /// Space between the footer band's top edge and the footer child's top edge.
  double above,

  /// Whether the top rule is still specified.
  bool hasTopRule,
});

Future<_FooterMetrics> _openAndMeasure(
  WidgetTester tester, {
  required double viewPaddingBottom,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ResponsiveDrawer.show<void>(
              context: context,
              title: 'Transaction',
              footer: _footer,
              child: const SizedBox(height: 120),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();

  final childRect = tester.getRect(find.byKey(_footerChildKey));
  final band = find
      .ancestor(
        of: find.byKey(_footerChildKey),
        matching: find.byType(Container),
      )
      .first;
  final bandRect = tester.getRect(band);
  final scaffoldRect = tester.getRect(
    find
        .ancestor(
          of: find.byKey(_footerChildKey),
          matching: find.byType(Scaffold),
        )
        .first,
  );
  final decoration =
      tester.widget<Container>(band).decoration as BoxDecoration?;

  // Dismiss via the root navigator, as the sibling mobile-sheet test does: an
  // `isScrollControlled` sheet leaves no dependable barrier strip to tap blind.
  final rootContext = tester.element(find.text('open'));
  Navigator.of(rootContext, rootNavigator: true).pop();
  await tester.pumpAndSettle();

  return (
    below: scaffoldRect.bottom - childRect.bottom,
    above: childRect.top - bandRect.top,
    hasTopRule: decoration?.border != null,
  );
}

/// Puts the test on a phone-sized surface WITH a bottom safe-area inset.
///
/// Two details are load-bearing and were both established by measurement.
///
/// 1. The size goes on `tester.view.physicalSize`, not
///    `tester.binding.setSurfaceSize`. Only the former moves
///    `MediaQuery.sizeOf`, which is what `ResponsiveDrawer.show()` reads to
///    choose between `showModalBottomSheet` and `showDialog`. With
///    `setSurfaceSize` the surface stayed 800x600 and the drawer silently took
///    the DESKTOP branch - whose route wraps everything in a full `SafeArea`
///    that eats the bottom inset, so the defect could not reproduce at all.
/// 2. The inset goes on the VIEW, not on a `MediaQuery` inserted in the tree.
///    A `MediaQuery` placed via `MaterialApp.builder` reaches the home route
///    but NOT the bottom-sheet route, which was measured returning
///    `EdgeInsets.zero` in the footer while the button above it saw 34.
///
/// `FakeViewPadding` is in PHYSICAL pixels, hence the devicePixelRatio scaling.
/// `padding` is set alongside `viewPadding` because the shell reads
/// `viewPaddingOf` while a `SafeArea` reads `paddingOf`; with the keyboard
/// closed a real device reports both the same, so setting both is what lets
/// this test fail honestly against the old SafeArea implementation.
void _asPhoneWithInset(WidgetTester tester, double bottom) {
  final dpr = tester.view.devicePixelRatio;
  tester.view.physicalSize = Size(400 * dpr, 800 * dpr);
  tester.view.viewPadding = FakeViewPadding(bottom: bottom * dpr);
  tester.view.padding = FakeViewPadding(bottom: bottom * dpr);
  addTearDown(tester.view.reset);
}

void main() {
  group('the drawer footer caps the bottom safe-area inset', () {
    testWidgets('34pt device: 40 below the child, not the raw 54', (
      tester,
    ) async {
      _asPhoneWithInset(tester, 34);

      final m = await _openAndMeasure(tester, viewPaddingBottom: 34);

      // 20 design inset + 20 capped clearance. Pre-fix this measured 54, which
      // is the number this case exists to reject.
      expect(
        m.below,
        GeniusWalletConsts.space10 + kMaxBottomSafeInset,
        reason:
            'the raw 34pt inset must be capped at kMaxBottomSafeInset, not '
            'reserved whole',
      );
      expect(m.above, GeniusWalletConsts.space10 + _kTopRuleWidth);
      expect(m.hasTopRule, isTrue);
    });

    testWidgets('0pt device: 20 below, unchanged from before the cap', (
      tester,
    ) async {
      _asPhoneWithInset(tester, 0);

      final m = await _openAndMeasure(tester, viewPaddingBottom: 0);

      // A device with no home indicator reports 0 and must be untouched.
      expect(m.below, GeniusWalletConsts.space10);
      expect(m.above, GeniusWalletConsts.space10 + _kTopRuleWidth);
      expect(m.hasTopRule, isTrue);
    });

    testWidgets('12pt device: 32 below - the cap removes and never adds', (
      tester,
    ) async {
      _asPhoneWithInset(tester, 12);

      final m = await _openAndMeasure(tester, viewPaddingBottom: 12);

      // Under the cap, so the whole inset is honoured: 20 + 12. This is the
      // case that catches a "fix" written as max() or as a flat 20.
      expect(m.below, GeniusWalletConsts.space10 + 12);
      expect(m.above, GeniusWalletConsts.space10 + _kTopRuleWidth);
      expect(m.hasTopRule, isTrue);
    });
  });

  test('the cap is the tab bar\'s value, shared rather than copied', () {
    // The whole point of promoting the constant out of `responsive_overlay.dart`
    // was that the tab bar and the drawer footer cannot drift. `grep -rn
    // "_kMaxBottomInset" lib` returning nothing is the other half of that
    // check; this pins the value both surfaces now agree on.
    expect(kMaxBottomSafeInset, GeniusWalletConsts.space10);
  });
}
