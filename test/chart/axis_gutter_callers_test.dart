import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every price gutter goes through the shared axisTickLabel', () {
    for (final path in [
      'lib/chart/crypto_live_chart.dart',
      'lib/dashboard/chart/markets_hero_card.dart',
    ]) {
      final src = File(path).readAsStringSync();
      expect(src, contains('axisTickLabel('), reason: path);
      expect(src, isNot(contains('axisMoneyLabel(value')), reason: path);
    }
  });
}
