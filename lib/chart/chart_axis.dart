import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// The chart's pure geometry rules — top-level and pure so each one can be
/// tested on its own (`test/chart/chart_axis_test.dart`). A chart-axis bug
/// looks like a working chart in every screenshot, which is exactly how the
/// y-window bug in `chartYBounds` (`crypto_live_chart.dart`) shipped in the
/// first place. Ported from `.planning/sketches/078-chart-restyle/index.html`
/// — the LOGIC, not the SVG.

/// At or above this many pixels of PLOT the frame (scheme B) earns its
/// gutters; below it the ticks crowd and the frame is dropped for the
/// axis-free fallback (scheme A). Per 078-S4 this is a RUNTIME measurement,
/// never a per-surface setting: `ChartDashboardView` has three call sites
/// under three different height regimes and the two-column one has no
/// minimum height at all, so no configuration value can express "does the
/// frame fit here".
const double kChartFrameMinHeight = 220.0;

/// The right-hand price gutter scheme B reserves for its axis labels.
const double kChartAxisGutter = 62.0;

/// The bottom row scheme B reserves for its time labels.
const double kChartTimeRowHeight = 22.0;

/// Scheme A's reserved label strip, top and bottom (078-S5). The line is
/// drawn only in the middle `plotHeight - 2 * kChartLabelBand`, so no data
/// shape can ever reach a label — the fix that replaced a plate the line
/// could still run through (see `chartBandedBounds` below).
const double kChartLabelBand = 17.0;

/// Where the below-bar area fill reaches zero alpha, as a fraction of the
/// plot height measured over `belowBarLargestRect` (top of the highest spot
/// to the plot floor) — the same box the sketch's SVG `objectBoundingBox`
/// gradient spans, so this value ports 1:1.
const double kChartFillFadeStop = 0.62;

/// The "nice" tick ladder, so the axis reads `64,250` not `64,187.4413`.
///
/// Port of `ticks()` at `index.html:553`. The ladder deliberately includes
/// the 2.5 rung: a plain 1-2-5-10 ladder jumps from 200 to 500 at norm=2.01,
/// and on a real BTC window (span 1274) that collapsed a 6-tick request into
/// 2 labels — below the 2-to-8 band the EU data-viz guide asks for. Measured
/// in the sketch's browser sweep, not guessed.
///
/// Returns the candidate multiplier whose resulting tick count is closest to
/// [want], among candidates with at least 2 values. A zero or negative span
/// returns a single value at [lo] with a step of 1, so a flat/degenerate
/// window cannot divide by zero or loop.
(List<double>, double) chartTickStep(double lo, double hi, int want) {
  final span = hi - lo;
  if (span <= 0) {
    return ([lo], 1.0);
  }

  final mag = pow(10, (log(span / want) / ln10).floorToDouble()).toDouble();
  const multipliers = [1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 10.0];

  List<double>? bestVals;
  double? bestStep;
  int? bestErr;

  for (final m in multipliers) {
    final step = m * mag;
    final vals = <double>[];
    var v = (lo / step).ceil() * step;
    for (; v <= hi + step * 1e-9; v += step) {
      vals.add(v);
    }
    if (vals.length < 2) {
      continue;
    }
    final err = (vals.length - want).abs();
    if (bestErr == null || err < bestErr) {
      bestVals = vals;
      bestStep = step;
      bestErr = err;
    }
  }

  if (bestVals == null || bestStep == null) {
    return ([lo, hi], span);
  }
  return (bestVals, bestStep);
}

/// The axis label for [value], with precision derived from the tick [step].
///
/// Port of `axisMoney()` at `index.html:534`. **Deriving precision from the
/// value's magnitude — instead of the step — is a real bug this rule exists
/// to prevent, not a style choice**: it is exactly how a stablecoin's axis
/// printed `$1.00 / $1.00 / $1.00 / $1.00` for four different prices.
String axisMoneyLabel(double value, double step) {
  final int decimals = step >= 1 ? 0 : min(8, (-log(step) / ln10).ceil() + 1);
  return NumberFormat.currency(
    symbol: '\$',
    decimalDigits: decimals,
  ).format(value);
}

/// How many bottom time labels fit, clamped to BOTH the plot width and the
/// number of samples actually on screen.
///
/// Port of the clamp at `index.html:952`. With 4 samples, 6 label slots
/// printed "6:35 PM" twice — caught by the sketch's "4 points" state.
int chartXLabelCount({required double plotWidth, required int sampleCount}) {
  return max(2, min(min(6, (plotWidth / 110).floor()), sampleCount));
}

/// How many horizontal gridlines/ticks scheme B asks for, per `index.html:938`.
int chartYTickCount(double plotHeight) =>
    max(3, min(6, (plotHeight / 76).round()));

/// Whether the plot has room for scheme B's trading frame. This is the whole
/// of scope item 078-S4: a RUNTIME rule measured off the box the chart was
/// actually handed, never a per-surface flag.
bool chartUsesFrame(double plotHeight) => plotHeight >= kChartFrameMinHeight;

/// Scheme A's reserved label gutters, expressed as a Y-window transform.
///
/// `fl_chart` has no notion of a reserved label strip, and `HorizontalLineLabel`
/// takes a text style but no background — so the gutters are built by widening
/// the Y window instead: given the plot is [plotHeight] tall and the data must
/// occupy only the middle `plotHeight - 2 * band`, this expands the window so
/// the original `lo`/`hi` land exactly [band] px inside each edge.
///
/// **This is the SECOND attempt at this defect, and the first one was wrong.**
/// An opaque plate behind the H/L labels was tried and rejected by Jakub,
/// because the line still ran through the plate — the plate merely hid that
/// stretch of the series. Hiding data behind a caption is not a fix. Reserving
/// the gutter in the Y window itself means no data shape can ever reach a
/// label, at any surface size.
(double, double) chartBandedBounds(
  (double, double) bounds,
  double plotHeight, {
  double band = kChartLabelBand,
}) {
  final (lo, hi) = bounds;
  final available = plotHeight - 2 * band;
  if (available <= 0) {
    return bounds;
  }
  final unitsPerPx = (hi - lo) / max(1, available);
  return (lo - band * unitsPerPx, hi + band * unitsPerPx);
}

/// The highest and lowest spot inside the visible `[viewMinX, viewMaxX]`
/// window — never the whole fetched series, which the chart's window is
/// only a slice of (the last 50 points of a longer fetch).
///
/// Falls back to the whole series if the window selects nothing, the same
/// way `chartYBounds` does. Returns null for an empty list or a flat series
/// (`high.y == low.y`), so the caller can skip drawing the labels entirely.
(FlSpot high, FlSpot low)? visibleExtremes(
  List<FlSpot> data, {
  double? viewMinX,
  double? viewMaxX,
}) {
  if (data.isEmpty) {
    return null;
  }

  final lo = viewMinX ?? data.first.x;
  final hi = viewMaxX ?? data.last.x;

  var visible = data.where((s) => s.x >= lo && s.x <= hi).toList();
  if (visible.isEmpty) {
    visible = data;
  }

  var high = visible.first;
  var low = visible.first;
  for (final s in visible) {
    if (s.y > high.y) {
      high = s;
    }
    if (s.y < low.y) {
      low = s;
    }
  }

  if (high.y == low.y) {
    return null;
  }
  return (high, low);
}
