// The 1H/1D/1W/1M/1Y segment must change the range the chart asks for and
// plots — it shipped once as a chip that moved and changed nothing.
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Records each requested day count and answers with 48 half-hourly points
/// ending now, so a 1H window keeps exactly 3 of them and 1D keeps all 48.
class _FakeFetch {
  final List<int> days = [];

  Future<Map<int, double>> call(String coinId, {int days = 1}) async {
    this.days.add(days);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return {for (var i = 0; i < 48; i++) now - (47 - i) * 1800: 100.0 + i};
  }
}

Widget _host(_FakeFetch fake, {bool ownHeader = true, int rangeIndex = 1}) =>
    MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 400,
          child: CryptoLiveChart(
            coinGeckoCoinId: 'bitcoin',
            tokenSymbol: 'btc',
            // The test font draws every glyph a full em wide; 20 keeps
            // the price inside the price glow's 280px OverflowBox.
            priceHeight: 20,
            showPriceHeader: !ownHeader,
            rangeIndex: rangeIndex,
            fetchHistory: fake.call,
          ),
        ),
      ),
    );

Widget _chart(_FakeFetch fake) => CryptoLiveChart(
  coinGeckoCoinId: 'bitcoin',
  tokenSymbol: 'btc',
  priceHeight: 20,
  showPriceHeader: false,
  fetchHistory: fake.call,
);

int _plottedSpots(WidgetTester tester) => tester
    .widget<LineChart>(find.byType(LineChart))
    .data
    .lineBarsData
    .first
    .spots
    .length;

void main() {
  testWidgets('a range still loading shows the spinner, not a flat line', (
    tester,
  ) async {
    final pending = Completer<Map<int, double>>();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: CryptoLiveChart(
              coinGeckoCoinId: 'bitcoin',
              tokenSymbol: 'btc',
              priceHeight: 20,
              showPriceHeader: false,
              fetchHistory: (_, {days = 1}) => pending.future,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    pending.complete({now - 60: 1.0, now: 2.0});
    await tester.pump();
    await tester.pump();
    expect(find.byType(Loading), findsNothing);
  });

  testWidgets('an older answer for the same range cannot overwrite a newer '
      'request', (tester) async {
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final calls = <Completer<Map<int, double>>>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 400,
            child: CryptoLiveChart(
              coinGeckoCoinId: 'bitcoin',
              tokenSymbol: 'btc',
              priceHeight: 20,
              showPriceHeader: false,
              fetchHistory: (_, {days = 1}) {
                final c = Completer<Map<int, double>>();
                calls.add(c);
                return c.future;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // 1D (initial) -> 1Y -> 1D again: two 1D requests are now in flight.
    await tester.tap(find.text('1Y'));
    await tester.pump();
    await tester.tap(find.text('1D'));
    await tester.pump();
    expect(calls, hasLength(3));

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    calls.first.complete({now - 60: 1.0, now: 2.0});
    await tester.pump();
    await tester.pump();
    expect(find.byType(LineChart), findsNothing);
    expect(find.byType(Loading), findsOneWidget);

    calls.last.complete({now - 60: 3.0, now: 4.0});
    await tester.pump();
    await tester.pump();
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('a layout swap that rebuilds the chart keeps the chosen range', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final fake = _FakeFetch();
    Widget host({required bool wide}) => MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        // A different parent type per branch, as a responsive swap does.
        body: wide
            ? Row(children: [Expanded(child: _chart(fake))])
            : Column(children: [Expanded(child: _chart(fake))]),
      ),
    );

    await tester.pumpWidget(host(wide: false));
    await tester.pump();
    await tester.tap(find.text('1Y'));
    await tester.pump();
    await tester.pump();
    expect(fake.days.last, 365);

    await tester.pumpWidget(host(wide: true));
    await tester.pump();
    expect(fake.days.last, 365);
  });

  testWidgets('tapping a tab re-fetches and re-plots that range', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final fake = _FakeFetch();

    await tester.pumpWidget(_host(fake));
    await tester.pump();
    expect(fake.days, [1]);
    expect(_plottedSpots(tester), 48);

    await tester.tap(find.text('1Y'));
    await tester.pump();
    await tester.pump();
    expect(fake.days.last, 365);

    await tester.tap(find.text('1H'));
    await tester.pump();
    await tester.pump();
    expect(fake.days.last, 1);
    expect(_plottedSpots(tester), 3);
  });

  testWidgets('a host-owned segment drives the range through rangeIndex', (
    tester,
  ) async {
    final fake = _FakeFetch();

    await tester.pumpWidget(_host(fake, ownHeader: false));
    await tester.pump();
    await tester.pumpWidget(_host(fake, ownHeader: false, rangeIndex: 3));
    await tester.pump();

    expect(fake.days, [1, 30]);
  });
}
