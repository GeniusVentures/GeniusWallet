import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

void main() {
  testWidgets('axis labels stay on one line at phone width', (tester) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 400,
            child: CryptoLiveChart(
              coinGeckoCoinId: 'usd-coin',
              tokenSymbol: 'usdc',
              priceHeight: 20,
              showPriceHeader: false,
              fetchHistory: (_, {days = 1}) async => {
                for (var i = 0; i < 48; i++)
                  now - (47 - i) * 1800: 0.9998 + (i % 5) * 0.0001,
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final axisLabels = find.byWidgetPredicate(
      (w) => w is Text && w.style?.fontSize == 11,
    );
    expect(axisLabels, findsWidgets);
    for (final e in axisLabels.evaluate()) {
      expect(tester.getSize(find.byWidget(e.widget)).height, lessThan(20));
    }
  });
}
