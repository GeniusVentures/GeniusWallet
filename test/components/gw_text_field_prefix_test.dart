import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import '../banxa/gw_pump.dart';

/// 260731-vty: `GWTextField`'s two leading slots, pinned by GEOMETRY.
///
/// `GWTextField` used to route its one `prefix` parameter into Material's
/// `prefixIcon` slot, which is vertically CENTRED inside a 48x48 minimum box.
/// That is right for an icon and wrong for text: the Buy GNUS hero's `$` sat
/// in a 48px gutter, off the digits' baseline. The slot is now split -
/// `leadingIcon` keeps the gutter, `prefix` means what Material's own
/// `InputDecoration.prefix` means (inline, baseline-laid-out, content-sized).
///
/// The measurement discipline here is the point of the file. Claim A's
/// literals were measured against UNCHANGED `gw_text_field.dart` and pumped
/// before a single line of `lib/` was touched, because a regression guard
/// written after the change proves nothing. Claims B, C and D were run in the
/// same pre-change state and all three FAILED there, with the real numbers
/// recorded in `260731-vty-SUMMARY.md`.
///
/// `gwHost` is imported from `test/banxa/` rather than re-declared: it is
/// three lines and already the repo's shared two-mode pump wrapper, and a
/// second copy would be the thing that drifts.
void main() {
  /// The hero field as `BanxaBuyForm` builds it, minus the screen: the
  /// `numericHeadline` type step, a seeded amount, and a BARE `Text` in the
  /// prefix slot. Bare is load-bearing - the component supplies the type step
  /// and the colour now, so a restated `style:` here would test the call site
  /// instead of the component.
  Widget heroField(TextEditingController controller) => Align(
    alignment: Alignment.topLeft,
    child: SizedBox(
      width: 320,
      child: GWTextField(
        controller: controller,
        textStyle: GeniusWalletTypography.numericHeadline,
        prefix: const Text('\$'),
      ),
    ),
  );

  Future<TextEditingController> pumpHero(WidgetTester tester) async {
    final controller = TextEditingController(text: '500.00');
    addTearDown(controller.dispose);
    await tester.pumpWidget(gwHost(heroField(controller)));
    await tester.pump();
    return controller;
  }

  testWidgets(
    'VTY-02 REGRESSION: GWSearchField geometry is byte-identical to the '
    'numbers measured before the split',
    (tester) async {
      // Both literals below were printed by this exact test body running
      // against UNCHANGED `gw_text_field.dart` on 2026-07-31, before the
      // `prefix` -> `leadingIcon` rename existed. They are not derived,
      // rounded or predicted - they are what the pre-change tree rendered.
      await tester.pumpWidget(
        gwHost(
          const Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 320, child: GWSearchField()),
          ),
        ),
      );
      await tester.pump();

      // 48x48, because `InputDecoration.prefixIcon` wraps its child in a
      // `ConstrainedBox` with a `kMinInteractiveDimension` minimum - which
      // forces its way through `Icon`'s own tight 20px `SizedBox`. That
      // gutter is exactly what `leadingIcon` must keep.
      expect(
        tester.getRect(find.byIcon(Icons.search)),
        const Rect.fromLTRB(1.0, 5.0, 49.0, 53.0),
      );
      expect(
        tester.getRect(find.byType(EditableText)),
        const Rect.fromLTRB(53.0, 17.0, 299.0, 41.0),
      );
    },
  );

  testWidgets(
    'VTY-01 CLAIM B: the hero symbol is content-sized, not gutter-sized',
    (tester) async {
      await pumpHero(tester);

      // 48.0 before the split (measured), because the symbol was a `Text` in
      // an icon gutter. 24.25 after it - the plan predicted this would land
      // "comfortably under 24" and it does not: Inter's `$` advance at a 24px
      // type step is slightly WIDER than the em. The threshold is 30, which
      // still falsifies the 48px gutter outright while leaving the real glyph
      // its measured 5.75px of headroom.
      expect(tester.getRect(find.text('\$')).width, lessThan(30));
    },
  );

  testWidgets(
    'VTY-01 CLAIM C: the symbol and the digits share a top edge and a height',
    (tester) async {
      await pumpHero(tester);

      final symbol = tester.getRect(find.text('\$'));
      final input = tester.getRect(find.byType(EditableText));

      // Why this is a BASELINE proof and not a weaker stand-in for one:
      // `RenderBox.getDistanceToBaseline` asserts on the `PipelineOwner` and
      // throws when called from a settled widget test, so the baseline cannot
      // be read directly. Two text boxes carrying an identical `TextStyle`
      // place their alphabetic baseline at an identical offset below their
      // own top edge. Equal tops, plus equal heights, plus claim D's style
      // equality, is therefore exactly a shared baseline.
      //
      // Before the split: symbol top 8.0 against input top 16.0, symbol
      // height 48.0 against input height 32.0. Both halves failed.
      expect(symbol.top, closeTo(input.top, 1.0));
      expect(symbol.height, closeTo(input.height, 1.0));
    },
  );

  testWidgets(
    'VTY-04 CLAIM D: the component supplies the prefix type step and colour',
    (tester) async {
      await pumpHero(tester);

      // The fully merged span style, which is the only honest probe once the
      // call site stops passing its own `style:`.
      final symbol = tester
          .renderObject<RenderParagraph>(find.text('\$'))
          .text
          .style;
      final input = tester
          .widget<EditableText>(find.byType(EditableText))
          .style;

      expect(symbol, isNotNull);
      expect(symbol!.fontSize, input.fontSize);
      expect(symbol.height, input.height);
      expect(symbol.fontWeight, input.fontWeight);
      expect(symbol.fontFamily, input.fontFamily);
      expect(symbol.color, GWColors.dark().textSecondary);

      // NOT asserted: `letterSpacing`. `numericHeadline` leaves it unset and
      // the two texts inherit it from different ancestors, so an equality
      // there would be a claim about ambient theme wiring rather than about
      // this fix.
    },
  );

  testWidgets(
    'VTY-01: leadingIcon still gets the 48px gutter, on the same widget',
    (tester) async {
      // The other half of the split, stated as its own claim so the two slots
      // cannot quietly collapse back into one behaviour.
      await tester.pumpWidget(
        gwHost(
          const Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              child: GWTextField(
                leadingIcon: Icon(Icons.search, size: 20),
                hint: 'Search',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.getRect(find.byIcon(Icons.search)).width, 48.0);
      expect(tester.getRect(find.byIcon(Icons.search)).height, 48.0);
    },
  );

  testWidgets(
    'the inline prefix is FADED, never unmounted, so revealing it costs no '
    'layout',
    (tester) async {
      // Material hides the inline prefix while the field is empty and
      // unfocused. This project ACCEPTS that (a lone `$` over an empty field
      // reads as a stuck placeholder), and the acceptance is only safe
      // because opacity is not layout - the box stays reserved, so the card's
      // height cannot move when the first digit lands. That is the same
      // invariant `buy_form_layout_test.dart`'s VTY-03 pair rides on, pinned
      // here at the component instead of the screen.
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        gwHost(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              child: GWTextField(
                controller: controller,
                textStyle: GeniusWalletTypography.numericHeadline,
                prefix: const Text('\$'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // `AnimatedOpacity`, not `FadeTransition`: the symbol has exactly ONE
      // `AnimatedOpacity` ancestor and FIVE `FadeTransition` ancestors, so
      // only the former identifies the affix's own fade unambiguously.
      final fade = find.ancestor(
        of: find.text('\$'),
        matching: find.byType(AnimatedOpacity),
      );
      expect(fade, findsOneWidget);

      final emptyRect = tester.getRect(find.text('\$'));
      expect(tester.widget<AnimatedOpacity>(fade).opacity, 0.0);

      controller.text = '500.00';
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(tester.widget<AnimatedOpacity>(fade).opacity, 1.0);
      // The load-bearing half: the glyph occupied the same rect the whole
      // time, invisible or not.
      expect(tester.getRect(find.text('\$')), emptyRect);
    },
  );
}
