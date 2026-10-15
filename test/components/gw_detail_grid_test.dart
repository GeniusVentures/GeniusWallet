import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
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
    testWidgets('fills with the well token in ${mode.name} mode', (
      tester,
    ) async {
      final gw = _palette(mode);
      await tester.pumpWidget(
        gwHost(const GWDetailGrid(rows: [Text('row')]), gw: gw),
      );
      final box = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(GWDetailGrid),
              matching: find.byType(Container),
            )
            .first,
      );
      final fill = (box.decoration! as BoxDecoration).color;
      expect(fill, gw.surfaceWell);
      if (mode == GWAppearanceMode.light) {
        expect(fill, const Color(0xFFEFF2F6));
      }
    });
  }
}
