import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/token_svg.dart';

void main() {
  test('inlines CSS class fills so USDC keeps its blue disc', () {
    const svg =
        '<svg><style>.st0{fill:#2775CA;}</style><circle class="st0" r="1"/></svg>';
    final out = sanitizeTokenSvg(svg);
    expect(out, contains('style="fill:#2775CA;"'));
    expect(out, isNot(contains('class="st0"')));
  });

  test('rejects an SVG that only wraps a bitmap so the letters show', () {
    const svg =
        '<svg><defs><image id="a" href="data:image/png;base64,AA"/></defs></svg>';
    expect(() => sanitizeTokenSvg(svg), throwsFormatException);
  });
}
