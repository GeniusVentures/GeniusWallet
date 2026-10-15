import 'dart:ui' show CheckedState;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/disclaimer_dialogue.dart';
import 'package:genius_wallet/components/inputs/gw_checkbox.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import '../banxa/gw_pump.dart';

GWColors _palette(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
  return mode == GWAppearanceMode.light ? GWColors.light() : GWColors.dark();
}

Future<void> _open(
  WidgetTester tester,
  GWColors gw,
  void Function(bool) onResult, {
  String? sandboxHost,
}) async {
  await tester.pumpWidget(
    gwHost(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => onResult(
            await showDisclaimerDialog(context, sandboxHost: sandboxHost),
          ),
          child: const Text('open'),
        ),
      ),
      gw: gw,
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

GWButton _continue(WidgetTester tester) =>
    tester.widget<GWButton>(find.widgetWithText(GWButton, 'Continue'));

void main() {
  for (final mode in GWAppearanceMode.values) {
    testWidgets(
      'Continue is disabled until ticked, then accepts in ${mode.name} mode',
      (tester) async {
        final gw = _palette(mode);
        bool? result;
        await _open(tester, gw, (v) => result = v);

        final box = tester.widget<Checkbox>(
          find.descendant(
            of: find.byType(GWCheckbox),
            matching: find.byType(Checkbox),
          ),
        );
        expect(box.side!.color, gw.brandPrimaryOnSurface);
        expect(_continue(tester).onPressed, isNull);

        await tester.tap(find.byType(GWCheckbox));
        await tester.pump();
        expect(_continue(tester).onPressed, isNotNull);

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(result, isTrue);
      },
    );
  }

  testWidgets('Cancel resolves false even after ticking', (tester) async {
    bool? result;
    await _open(tester, GWColors.dark(), (v) => result = v);
    await tester.tap(find.byType(GWCheckbox));
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('sandbox note names the host and the terms are links', (
    tester,
  ) async {
    await _open(
      tester,
      GWColors.dark(),
      (_) {},
      sandboxHost: 'banxa-sandbox.com',
    );
    expect(find.text('Sandbox · banxa-sandbox.com'), findsOneWidget);
    expect(find.text('Terms of Use'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('no sandbox note by default', (tester) async {
    await _open(tester, GWColors.dark(), (_) {});
    expect(find.textContaining('Sandbox'), findsNothing);
  });

  testWidgets('tapping the label text toggles the checkbox', (tester) async {
    await _open(tester, GWColors.dark(), (_) {});
    final label = find.textContaining("I agree to Banxa's");
    final start = tester.getTopLeft(label) + const Offset(10, 8);
    await tester.tapAt(start);
    await tester.pump();
    expect(_continue(tester).onPressed, isNotNull);
    await tester.tapAt(start);
    await tester.pump();
    expect(_continue(tester).onPressed, isNull);
  });

  testWidgets('the toggle and each link are separate semantics nodes', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _open(tester, GWColors.dark(), (_) {});
    final terms = tester.getSemantics(find.text('Terms of Use'));
    final privacy = tester.getSemantics(find.text('Privacy Policy'));
    expect(terms.label, 'Terms of Use');
    expect(privacy.label, 'Privacy Policy');
    expect(terms.id, isNot(privacy.id));
    expect(terms.getSemanticsData().flagsCollection.isLink, isTrue);
    expect(privacy.getSemanticsData().flagsCollection.isLink, isTrue);
    expect(
      find.semantics.byPredicate(
        (n) =>
            n.getSemanticsData().flagsCollection.isChecked !=
                CheckedState.none &&
            n.label.contains("I agree to Banxa's"),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('scrolls on a short screen at 2x text, Continue reachable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    bool? result;
    await _open(tester, GWColors.dark(), (v) => result = v);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(GWCheckbox));
    await tester.pump();
    await tester.tap(find.byType(GWCheckbox));
    await tester.pump();
    expect(_continue(tester).onPressed, isNotNull);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
