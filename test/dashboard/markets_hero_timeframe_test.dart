// BXS-03: tapping 24H/30D/1Y re-plots a series actually fetched for that
// range; tapping 7D re-plots the bundled sparkline and spends no network
// call; a fetch that comes back empty shows a retry affordance, never a
// blank chart.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/chart/markets_hero_card.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import 'markets_fixtures.dart';

/// Records every call and returns a series of a length distinguishable from
/// the fixture's 30-point sparkline, so a test can tell "the fake series is
/// plotted" apart from "the sparkline is still plotted" by spot count alone.
class _FakeFetch {
  final List<({String coinId, int days})> calls = [];
  bool returnEmpty = false;

  Future<Map<int, double>> call(String coinId, {int days = 1}) async {
    calls.add((coinId: coinId, days: days));
    if (returnEmpty) {
      return {};
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const int n = 10; // != the fixture sparkline's 30 points.
    return {for (var i = 0; i < n; i++) now - (n - 1 - i) * 60: 100.0 + i};
  }
}

Widget _host(_FakeFetch fake) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: SingleChildScrollView(
      child: MarketsHeroCard(
        coin: marketsFixtureCoin(),
        data: marketsFixtureMarketData(),
        fetchHistoricalPrices: fake.call,
      ),
    ),
  ),
);

extension on WidgetTester {
  Future<void> pumpHeroAt(Size size, _FakeFetch fake) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.reset);
    await pumpWidget(_host(fake));
    await pump();
  }
}

void main() {
  group('BXS-03: timeframe tabs actually change the plotted series', () {
    testWidgets('tapping 30D calls the fetch with 30 days and re-plots the '
        'returned series', (tester) async {
      final fake = _FakeFetch();
      await tester.pumpHeroAt(const Size(1400, 1000), fake);

      await tester.tap(find.text('30D'));
      // Two pumps: one to rebuild with the loading state, one to let the
      // (synchronously-resolving) fake future settle and rebuild with data —
      // never pumpAndSettle, the loading indicator animates indefinitely.
      await tester.pump();
      await tester.pump();

      expect(fake.calls, hasLength(1));
      expect(fake.calls.single.coinId, 'bitcoin');
      expect(fake.calls.single.days, 30);

      final spots = tester.widget<LineChart>(find.byType(LineChart));
      expect(spots.data.lineBarsData.single.spots, hasLength(10));
    });

    testWidgets('tapping 7D never calls the fetch and re-plots the bundled '
        'sparkline', (tester) async {
      final fake = _FakeFetch();
      await tester.pumpHeroAt(const Size(1400, 1000), fake);

      // Move off the free path first, so tapping back to 7D is a real test
      // of "spends no network call" rather than a no-op on the default tab.
      await tester.tap(find.text('24H'));
      await tester.pump();
      await tester.pump();
      expect(fake.calls, hasLength(1));

      await tester.tap(find.text('7D'));
      await tester.pump();
      await tester.pump();

      // No additional call for 7D.
      expect(fake.calls, hasLength(1));

      final spots = tester.widget<LineChart>(find.byType(LineChart));
      expect(
        spots.data.lineBarsData.single.spots,
        hasLength(marketsFixtureRisingSparkline().length),
      );
    });

    testWidgets(
      'a fetch that comes back empty shows a retry affordance and no chart',
      (tester) async {
        final fake = _FakeFetch()..returnEmpty = true;
        await tester.pumpHeroAt(const Size(1400, 1000), fake);

        await tester.tap(find.text('1Y'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Retry'), findsOneWidget);
        expect(find.byType(LineChart), findsNothing);
      },
    );
  });

  group('BXS-03: the bottom-axis format is chosen from the real window', () {
    test('a ~1-day window prints clock time', () {
      expect(chooseAxisDateFormat(const Duration(hours: 20)).pattern, 'h:mm a');
    });

    test('a ~1-week window prints day and month', () {
      expect(chooseAxisDateFormat(const Duration(days: 7)).pattern, 'MMM d');
    });

    test('a ~1-year window prints month and year', () {
      expect(
        chooseAxisDateFormat(const Duration(days: 365)).pattern,
        'MMM yyyy',
      );
    });
  });
}
