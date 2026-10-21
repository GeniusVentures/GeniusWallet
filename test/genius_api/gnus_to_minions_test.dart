import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';

void main() {
  test('converts whole and decimal GNUS to Minions', () {
    expect(gnusToMinions('5'), 5000000);
    expect(gnusToMinions('1.5'), 1500000);
    expect(gnusToMinions('0.000001'), 1);
    expect(gnusToMinions('.25'), 250000);
  });

  test('rejects amounts the mint cannot represent exactly', () {
    expect(gnusToMinions(''), isNull);
    expect(gnusToMinions('0'), isNull);
    expect(gnusToMinions('-1'), isNull);
    expect(gnusToMinions('1.0000001'), isNull);
    expect(gnusToMinions('1,5'), isNull);
  });
}
