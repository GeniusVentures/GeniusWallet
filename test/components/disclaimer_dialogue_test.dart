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
}
