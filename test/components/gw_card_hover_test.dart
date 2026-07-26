import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// `GWCard.hoverLift` is the design-system hover (sketch 008 D "lift chip")
/// added so the News redesign — and every other card surface — stops
/// hand-rolling a `MouseRegion` + black scrim. The whole value of the flag is
/// the REACTION to a pointer, so this file pins that reaction, not the widget's
/// existence: on hover the card must rise 2px, strengthen its hairline and
/// deepen its shadow. It goes red if `hoverLift` is reverted to a no-op or the
/// hover no longer changes all three.

Widget _host({required bool hoverLift}) => MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: Center(
          child: GWCard(
            hoverLift: hoverLift,
            onTap: () {},
            child: const SizedBox(width: 220, height: 120),
          ),
        ),
      ),
    );

AnimatedContainer _animated(WidgetTester tester) =>
    tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));

/// 0.0 when no transform is set at all — which is the point since 2026-07-26:
/// the shared hover recipe is decorative, so GWCard sets no transform in
/// either state. The old `transform!` threw once the lift was removed.
double _liftY(WidgetTester tester) =>
    _animated(tester).transform?.getTranslation().y ?? 0.0;

Color _borderColor(WidgetTester tester) => ((_animated(tester).decoration
        as BoxDecoration)
    .border as Border)
    .top
    .color;

/// The brand tint painted OVER the card on hover (null at rest).
Color? _hoverTint(WidgetTester tester) =>
    (_animated(tester).foregroundDecoration as BoxDecoration?)?.color;

double _shadowDy(WidgetTester tester) =>
    (_animated(tester).decoration as BoxDecoration).boxShadow!.first.offset.dy;

void main() {
  testWidgets('hover paints the shared brand tint + brand hairline, no lift',
      (tester) async {
    final gw = GWColors.dark();
    await tester.pumpWidget(_host(hoverLift: true));

    // Resting: byte-identical to the pre-hoverLift GWCard — flat (no lift),
    // hairline `borderSubtle`, `elevation.card` (offset dy 4).
    expect(_liftY(tester), 0.0, reason: 'card sits flat before hover');
    expect(_borderColor(tester), gw.borderSubtle);
    expect(_shadowDy(tester), GeniusWalletElevation.card.first.offset.dy);

    // Move a synthetic mouse over the card.
    final gesture =
        await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(GWCard)));
    await tester.pump();

    // Hovered: THE app-wide recipe (sketch 044 variant 3, 2026-07-26) —
    // brand tint over the card + brand hairline, and NO geometry. The 2px
    // lift and the dialog-shadow deepening were this card's half of three
    // disagreeing hovers and are deliberately gone.
    expect(_liftY(tester), 0.0, reason: 'the card no longer rises on hover');
    expect(_borderColor(tester), GWDecorations.hoverEdge,
        reason: 'hairline goes BRAND on hover, not merely stronger');
    expect(_shadowDy(tester), GeniusWalletElevation.card.first.offset.dy,
        reason: 'shadow is hover-invariant now');
    expect(_hoverTint(tester), GWDecorations.hoverFill,
        reason: 'the brand tint is painted over the card');

    // Move the mouse away; the card settles back to rest.
    await gesture.moveTo(const Offset(-100, -100));
    await tester.pump();
    expect(_borderColor(tester), gw.borderSubtle);
    expect(_hoverTint(tester), isNull, reason: 'tint clears on exit');

    expect(tester.takeException(), isNull);
  });
}
