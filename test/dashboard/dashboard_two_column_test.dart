// At the two-column width (the 1440 default window) the chart owns the whole
// left column; halved with Markets it drew a flat line.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/components/gw_timeframe_segment.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

Future<void> _pumpAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Only the layout is under test. The panels' blocs and API are not
  // provided, so those panels build as error widgets; their errors are muted.
  final original = FlutterError.onError;
  FlutterError.onError = (_) {};
  try {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: const Scaffold(body: ResponsiveDashboardView()),
      ),
    );
  } finally {
    FlutterError.onError = original;
  }
}

void main() {
  testWidgets('two columns: the GNUS chart shows, the Markets panel does not', (
    tester,
  ) async {
    await _pumpAt(tester, 1440);

    expect(find.byType(ChartDashboardView), findsOneWidget);
    expect(find.byType(MarketsDashboardView), findsNothing);
    // The dashboard chart is the native token's, not Bitcoin's.
    expect(find.textContaining('Genius AI'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'the chosen range survives crossing the three-column breakpoint',
    (tester) async {
      await _pumpAt(tester, 1440);
      final original = FlutterError.onError;
      FlutterError.onError = (_) {};
      try {
        await tester.tap(find.text('1Y'));
        await tester.pump();
        // Wider than the breakpoint: the layout swaps and rebuilds the card.
        tester.view.physicalSize = const Size(1700, 900);
        await tester.pump();
      } finally {
        FlutterError.onError = original;
      }

      expect(find.byType(MarketsDashboardView), findsOneWidget);
      final segment = tester.widget<GWTimeframeSegment>(
        find.byType(GWTimeframeSegment),
      );
      expect(segment.initialIndex, 4);

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('tapping the active range again rebuilds the chart to retry', (
    tester,
  ) async {
    await _pumpAt(tester, 1440);
    Key? chartKey() =>
        tester.widget<CryptoLiveChart>(find.byType(CryptoLiveChart)).key;
    final before = chartKey();

    final original = FlutterError.onError;
    FlutterError.onError = (_) {};
    try {
      await tester.tap(find.text('1D'));
      await tester.pump();
    } finally {
      FlutterError.onError = original;
    }

    expect(chartKey(), isNot(before));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
