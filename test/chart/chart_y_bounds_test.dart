// The check the flat chart owes.
//
// A y-window bug is invisible: the chart renders, the line is the right colour,
// the numbers above it are correct, and it looks like a coin that simply did
// not move. The only thing that says otherwise is asking what the scale was
// computed from.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';

void main() {
  group('chartYBounds - the ruler comes from the VISIBLE slice', () {
    test('a price crash outside the view does not flatten what is inside it', () {
      // GNUS's actual shape on 2026-07-28: -98.53% from its all-time high, and
      // the default view is the last 50 points. Points 0..49 are the old high,
      // 50..99 are today's range.
      final data = <FlSpot>[
        for (int i = 0; i < 50; i++) FlSpot(i.toDouble(), 45.0),
        for (int i = 50; i < 100; i++)
          FlSpot(i.toDouble(), 0.65 + (i % 3) * 0.07),
      ];

      final (lo, hi) = chartYBounds(data, viewMinX: 50, viewMaxX: 99);

      // The old code reduced over the WHOLE series, giving ~0.65..45 - so
      // today's 0.65-0.79 range occupied the bottom 0.3% of the card.
      expect(hi, lessThan(1.0));
      expect(lo, greaterThan(0.5));

      // And the visible span genuinely fills the window: 8% headroom each side
      // leaves the data occupying ~86% of the height.
      const visibleSpan = 0.79 - 0.65;
      expect((hi - lo) / visibleSpan, closeTo(1.16, 0.01));
    });

    test('no view window falls back to the whole series', () {
      final data = [const FlSpot(0, 10), const FlSpot(1, 20)];
      final (lo, hi) = chartYBounds(data);
      expect(lo, closeTo(10 - 0.8, 0.001));
      expect(hi, closeTo(20 + 0.8, 0.001));
    });

    test('a flat slice still gets a window instead of dividing by zero', () {
      // Every chart between the first paint and the second live tick.
      final data = [const FlSpot(0, 3.0), const FlSpot(1, 3.0)];
      final (lo, hi) = chartYBounds(data);
      expect(hi, greaterThan(lo));
      // Centred on the value, so the line sits mid-card rather than on an edge.
      expect((lo + hi) / 2, closeTo(3.0, 0.0001));
    });

    test('a flat slice at zero does not produce a zero-height window', () {
      // `value * 0.01` is 0 here, which would have been the same bug again.
      final data = [const FlSpot(0, 0), const FlSpot(1, 0)];
      final (lo, hi) = chartYBounds(data);
      expect(hi - lo, greaterThan(0));
    });

    test('an empty series does not throw out of reduce', () {
      expect(chartYBounds(const []), (0.0, 1.0));
    });
  });
}
