// Pins `GWViewAllLink`'s colour decision after the 2026-08-07 revert.
//
// The link painted the brand CTA blend at rest for part of 2026-08-07. Jakub
// saw it on the phone and sent it back to grey the same day ("a z view all -
// wrocmy do starego szarego koloru jak byl"), so rest is flat `textSecondary`
// again and hover is flat `textPrimary`.
//
// This file was `gw_view_all_link_gradient_test.dart` until that revert. The
// name went with the colour: a file whose name says gradient while asserting
// there is none is exactly the stale label this codebase's comments exist to
// prevent.
//
// The assertion that earns the file is now the REGRESSION GUARD: rest must not
// be the raw brand stops. That is what stops the blend coming back a third
// time without a decision. Reading the public static rather than pixel-reading
// an opaque `Shader` is what makes the stops assertable at all - `GWKicker.style`
// is the precedent for exposing a styling decision as a public static.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

Widget _host(GWColors gw) => MaterialApp(
  theme: ThemeData.dark().copyWith(extensions: [gw]),
  home: Scaffold(
    body: Center(child: GWViewAllLink(onTap: () {})),
  ),
);

void main() {
  final GWColors dark = GWColors.dark();

  test('REST is flat textSecondary, and it is NOT the brand blend', () {
    final rest = GWViewAllLink.gradient(dark, hovered: false);

    expect(rest.colors, <Color>[dark.textSecondary, dark.textSecondary]);

    // One colour repeated, on purpose. Rest is a FLAT fill expressed through
    // the ShaderMask the widget already owns, so the two stops must be equal;
    // two different stops here would mean a blend crept back in.
    expect(
      rest.colors.first,
      rest.colors.last,
      reason:
          'rest is flat grey, so both stops must be the same colour - a real '
          'two-stop blend here is the 2026-08-07 state Jakub reverted',
    );

    // THE regression guard, and the reason this test was rewritten rather than
    // deleted when the colour went back. It changed sign: the file used to
    // assert rest EQUALS the brand stops and now asserts it never does.
    expect(
      rest.colors,
      isNot(GeniusWalletGradient.brandCta.colors),
      reason:
          'the brand blend was tried at rest on 2026-08-07 and sent back. '
          'Colour is decided; if the link reads too quiet the next lever is '
          'weight or size',
    );
  });

  test('HOVER is flat textPrimary, and REST and HOVER are not the same', () {
    final hover = GWViewAllLink.gradient(dark, hovered: true);
    final rest = GWViewAllLink.gradient(dark, hovered: false);

    expect(hover.colors, <Color>[dark.textPrimary, dark.textPrimary]);
    expect(hover.colors.first, hover.colors.last);

    // Desktop still needs two visibly different states. The 3px arrow slide is
    // asserted below; this is the colour half of the same requirement, and it
    // survived the revert unchanged because hover was always the flat one.
    expect(
      hover.colors,
      isNot(rest.colors),
      reason: 'rest and hover must not paint the same colours',
    );
  });

  test('LIGHT appearance paints the light textSecondary, still flat', () {
    // The GLOBAL flag has to move, not just the constructor, and that harness
    // fix is kept in RUNNING code here rather than demoted to a comment.
    // `GWColors.light()` does NOT hand back light values on its own: its
    // SURFACE fields read `GeniusWalletColors._surfaceElevated`, an
    // appearance-aware getter off the `GWAppearance` singleton, so under a dark
    // global it returns `#0C0E14`. The precondition below is what would fail
    // without the flip. Restored on teardown so no other file inherits a
    // flipped appearance (`theme_contrast_test.dart` is the pattern).
    GWAppearance.instance.value = GWAppearanceMode.light;
    addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);

    final GWColors light = GWColors.light();
    expect(
      light.surfaceElevated.computeLuminance(),
      greaterThan(0.5),
      reason:
          'precondition: the appearance flip must actually have taken, or this '
          'case is asserting the dark branch under a light-sounding name',
    );

    final rest = GWViewAllLink.gradient(light, hovered: false);

    // Light-mode `textSecondary` is a deliberate DIVERGENCE from the
    // mode-invariant value (`#5A606E`, 6.3:1, versus dark's `#8A8F9D`), so this
    // is a genuinely different colour and not the same constant twice.
    expect(rest.colors, <Color>[light.textSecondary, light.textSecondary]);
    expect(
      rest.colors.first,
      isNot(dark.textSecondary),
      reason:
          'light must not paint the dark grey; the link re-skins with the '
          'appearance rather than hard-coding one value',
    );
    expect(
      rest.colors.first,
      rest.colors.last,
      reason: 'light collapses to a single repeated stop, one paint path',
    );
    expect(
      rest.colors,
      isNot(GeniusWalletGradient.brandCta.colors),
      reason: 'the raw brand blend must never paint on a light surface',
    );
  });

  testWidgets('the widget still paints through ONE srcIn ShaderMask', (
    tester,
  ) async {
    await tester.pumpWidget(_host(dark));

    final masks = find.descendant(
      of: find.byType(GWViewAllLink),
      matching: find.byType(ShaderMask),
    );
    expect(masks, findsOneWidget);
    expect(tester.widget<ShaderMask>(masks).blendMode, BlendMode.srcIn);

    // The children stay opaque white so the mask has something to recolour.
    expect(
      tester.widget<Icon>(find.byIcon(Icons.arrow_right_alt)).color,
      Colors.white,
    );
  });

  testWidgets('the arrow still slides 3px right on hover', (tester) async {
    await tester.pumpWidget(_host(dark));

    // The ICON, not the AnimatedContainer around it. `AnimatedContainer`'s
    // `transform` builds a `RenderTransform` that transforms its CHILD; the
    // container's own box never moves, so measuring the container reads 0px of
    // slide however well the hover works.
    final arrow = find.byIcon(Icons.arrow_right_alt);
    final double atRest = tester.getCenter(arrow).dx;

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.byType(GWViewAllLink)));
    await tester.pumpAndSettle();

    expect(
      tester.getCenter(arrow).dx - atRest,
      moreOrLessEquals(3.0, epsilon: 0.01),
      reason:
          'the slide is the second half of the desktop hover state; the colour '
          'change alone is not the whole affordance',
    );
  });
}
