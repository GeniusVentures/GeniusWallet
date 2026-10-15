import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import '../banxa/gw_pump.dart';

void main() {
  for (final gw in gwBothModes) {
    testWidgets('fills with the well token (${identical(gw.surfaceWell, GWColors.light().surfaceWell) ? 'light' : 'dark'})', (tester) async {
      await tester.pumpWidget(
        gwHost(const GWDetailGrid(rows: [Text('row')]), gw: gw),
      );
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byType(GWDetailGrid),
          matching: find.byType(Container),
        ).first,
      );
      expect((box.decoration! as BoxDecoration).color, gw.surfaceWell);
    });
  }
}
