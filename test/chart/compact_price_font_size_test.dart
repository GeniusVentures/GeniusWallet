import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';

/// Guards the fix for the macOS drag-resize freeze: dragging the window
/// shorter used to peg a core at 100% inside skia's ParagraphCache and never
/// commit another frame, because the price font size was derived straight
/// from the available height and so produced a distinct TextStyle — a
/// distinct paragraph cache key — on every frame of the drag.
///
/// The property that matters is therefore not the exact size, it is that a
/// continuous sweep of heights collapses to few distinct sizes.
void main() {
  const priceHeight = 28.0;

  test('a drag through the compact range yields few distinct sizes', () {
    final sizes = <double>{};
    // Tenth-of-a-pixel steps across the whole compact range: finer than any
    // real drag, so a size that varied continuously would show up here as
    // hundreds of distinct values.
    for (var h = 0.0; h < priceHeight * 3.5; h += 0.1) {
      sizes.add(
        compactPriceFontSize(
          maxHeight: h,
          priceHeight: priceHeight,
          isCompact: true,
        ),
      );
    }
    expect(
      sizes.length,
      lessThanOrEqualTo(priceHeight + 1),
      reason:
          'compactPriceFontSize must snap to a bounded set of sizes; '
          'got ${sizes.length} distinct values, which is the cache-thrashing '
          'behaviour that froze the desktop app on a drag-resize',
    );
  });

  test('every compact size leaves room for its own line metrics', () {
    // Mirrors the caller's assert: priceFontSize * 1.5 <= maxHeight.
    for (var h = 0.0; h < priceHeight * 3.5; h += 0.1) {
      final size = compactPriceFontSize(
        maxHeight: h,
        priceHeight: priceHeight,
        isCompact: true,
      );
      expect(size * 1.5, lessThanOrEqualTo(h), reason: 'at maxHeight $h');
      expect(size, lessThanOrEqualTo(priceHeight));
      expect(size, greaterThanOrEqualTo(0));
    }
  });

  test('a roomy card keeps the full price size', () {
    expect(
      compactPriceFontSize(
        maxHeight: 400,
        priceHeight: priceHeight,
        isCompact: false,
      ),
      priceHeight,
    );
  });
}
