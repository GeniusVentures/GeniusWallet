import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/coins/assets_totals.dart';

void main() {
  test('assetsTotal / assetsDayChange fold holdings; zero balance contributes 0',
      () {
    // 0.5 BTC @ 60000 (+2%), 2 ETH @ 3000 (-1%), 0 of a 100-priced token (+5%).
    final valueHoldings = <({double balance, double price})>[
      (balance: 0.5, price: 60000.0),
      (balance: 2.0, price: 3000.0),
      (balance: 0.0, price: 100.0),
    ];
    final changeHoldings = <({double balance, double price, double pct})>[
      (balance: 0.5, price: 60000.0, pct: 2.0),
      (balance: 2.0, price: 3000.0, pct: -1.0),
      (balance: 0.0, price: 100.0, pct: 5.0),
    ];

    // 30000 + 6000 + 0
    expect(assetsTotal(valueHoldings), 36000.0);
    // 600 + (-60) + 0
    expect(assetsDayChange(changeHoldings), closeTo(540.0, 1e-9));
    // A zero-balance holding never contributes to value or change.
    expect(holdingValue(0, 100), 0);
    expect(holdingDayChange(0, 100, 5), 0);
  });
}
