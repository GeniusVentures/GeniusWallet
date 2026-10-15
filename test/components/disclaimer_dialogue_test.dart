import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/disclaimer_dialogue.dart';
import 'package:genius_wallet/components/inputs/gw_checkbox.dart';

import '../banxa/gw_pump.dart';

void main() {
  for (final gw in gwBothModes) {
    testWidgets('checkbox is the themed GWCheckbox and accepts', (
      tester,
    ) async {
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
      expect(box.side!.color, gw.brandPrimaryStrong);

      await tester.tap(find.byType(GWCheckbox));
      await tester.pump();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  }
}
