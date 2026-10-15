import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  for (final mode in GWAppearanceMode.values) {
    testWidgets(
      'checkbox is the themed GWCheckbox and accepts in ${mode.name} mode',
      (tester) async {
        final gw = _palette(mode);
        bool? result;
        await tester.pumpWidget(
          gwHost(
            Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    result = await showDisclaimerDialog(context),
                child: const Text('open'),
              ),
            ),
            gw: gw,
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        final box = tester.widget<Checkbox>(
          find.descendant(
            of: find.byType(GWCheckbox),
            matching: find.byType(Checkbox),
          ),
        );
        expect(box.side!.color, gw.brandPrimaryOnSurface);
        if (mode == GWAppearanceMode.light) {
          expect(box.side!.color, const Color(0xFF0A6885));
        }

        await tester.tap(find.byType(GWCheckbox));
        await tester.pump();
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();
        expect(result, isTrue);
      },
    );
  }
}
