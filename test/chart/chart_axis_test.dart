// The chart's pure geometry rules, tested in isolation from any widget.
//
// Every case below is a rule the sketch 078 browser sweep caught as a real
// defect — a chart-axis bug looks like a working chart in every screenshot,
// which is exactly how the y-window bug (chart_y_bounds_test.dart) shipped
// in the first place. No fixtures, no mocks: these are pure functions.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/chart/chart_axis.dart';

void main() {
  group('chartTickStep - the nice-number ladder', () {
    test(
      'a real BTC window does not collapse a 6-tick request to 2 labels',
      () {
        // A plain 1-2-5-10 ladder collapsed this exact window to 2 labels in
        // the sketch's own browser sweep. The 2.5 rung is why the ladder has
        // more entries, not fewer.
        final (vals, _) = chartTickStep(63000, 64274, 6);
        expect(vals.length, greaterThan(2));
      },
    );

    test('every returned value is an exact multiple of the step and inside '
        '[lo, hi], with at least 2 of them', () {
      final (vals, step) = chartTickStep(63000, 64274, 6);
      expect(vals.length, greaterThanOrEqualTo(2));
      for (final v in vals) {
        expect(v, greaterThanOrEqualTo(63000));
        expect(v, lessThanOrEqualTo(64274));
        final multiple = v / step;
        expect(multiple, closeTo(multiple.round(), 1e-6));
      }
    });

    test('a zero span returns a single value and a step of 1, no divide by '
        'zero, no loop', () {
      final (vals, step) = chartTickStep(100, 100, 6);
      expect(vals, [100.0]);
      expect(step, 1.0);
    });
  });

  group('axisMoneyLabel - precision comes from the STEP, not the value', () {
    test('a stablecoin at different prices does not all print the same '
        'label', () {
      // The stablecoin bug: four different prices printed as \$1.00 four
      // times because precision came from the value's magnitude instead of
      // the tick step.
      final a = axisMoneyLabel(1.0004, 0.0002);
      final b = axisMoneyLabel(1.0006, 0.0002);
      expect(a, isNot(equals(b)));
    });

    test('a step >= 1 means zero decimals', () {
      expect(axisMoneyLabel(64250, 250), '\$64,250');
    });
  });

  group('chartXLabelCount - clamped to width AND to the sample count', () {
    test('4 samples never produce 6 label slots', () {
      // With 4 samples, 6 slots printed "6:35 PM" twice.
      expect(chartXLabelCount(plotWidth: 900, sampleCount: 4), 4);
    });

    test('the floor is 2, never fewer', () {
      expect(chartXLabelCount(plotWidth: 200, sampleCount: 50), 2);
    });

    test('the ceiling is 6', () {
      expect(chartXLabelCount(plotWidth: 900, sampleCount: 50), 6);
    });
  });

  group('chartUsesFrame - the whole of scope item 078-S4', () {
    test('the boundary is pinned exactly at kChartFrameMinHeight', () {
      expect(chartUsesFrame(220), isTrue);
      expect(chartUsesFrame(219.9), isFalse);
    });
  });

  group('chartYTickCount - clamped to [3, 6]', () {
    test('a short plot floors at 3', () {
      expect(chartYTickCount(76), greaterThanOrEqualTo(3));
      expect(chartYTickCount(1), 3);
    });

    test('a tall plot ceils at 6', () {
      expect(chartYTickCount(10000), 6);
    });
  });

  group('chartBandedBounds - the reserved label gutters, as a Y transform', () {
    test('a 140px plot with 17px bands widens the window so the input lo/hi '
        'land exactly `band` px inside each edge', () {
      const bounds = (100.0, 200.0);
      const plotHeight = 140.0;
      const band = 17.0;
      final (lo, hi) = chartBandedBounds(bounds, plotHeight, band: band);

      // Strictly wider than the input.
      expect(hi - lo, greaterThan(bounds.$2 - bounds.$1));

      // Mapping the original lo/hi through the returned window (top-down
      // pixel space, same convention as the sketch's `Y()`) should land them
      // `band` px inside each edge.
      double pxOf(double value) =>
          plotHeight - ((value - lo) / (hi - lo)) * plotHeight;
      expect(pxOf(bounds.$2), closeTo(band, 0.01)); // original hi -> top band
      expect(
        pxOf(bounds.$1),
        closeTo(plotHeight - band, 0.01),
      ); // original lo -> bottom band
    });

    test('a plot too short for its bands returns the input untouched', () {
      const bounds = (100.0, 200.0);
      final result = chartBandedBounds(bounds, 20, band: 17);
      expect(result, bounds);
    });
  });

  group('visibleExtremes - the window, not the whole fetched series', () {
    test(
      'a series minimum outside the view window is not the returned low',
      () {
        final data = <FlSpot>[
          const FlSpot(0, 1.0), // the global minimum, OUTSIDE the view window
          const FlSpot(50, 40.0),
          const FlSpot(51, 60.0),
          const FlSpot(52, 30.0), // the minimum INSIDE the view window
          const FlSpot(53, 55.0),
        ];
        final result = visibleExtremes(data, viewMinX: 50, viewMaxX: 53);
        expect(result, isNotNull);
        expect(result!.$2.y, 30.0);
        expect(result.$1.y, 60.0);
      },
    );

    test('an empty list returns null', () {
      expect(visibleExtremes(const []), isNull);
    });

    test('a flat series (high == low) returns null so nothing is drawn', () {
      final data = [const FlSpot(0, 5.0), const FlSpot(1, 5.0)];
      expect(visibleExtremes(data), isNull);
    });
  });
}
