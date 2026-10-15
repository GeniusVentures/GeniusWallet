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
        '<svg><rect fill="url(#a)"/><defs><pattern id="a"/><image href="data:image/png;base64,AA"/></defs></svg>';
    expect(() => sanitizeTokenSvg(svg), throwsFormatException);
  });

  test('CRV: a pattern filled with a bitmap falls back to the letters', () {
    const svg =
        '<svg><rect fill="url(#p)"/><defs><pattern id="p"><use xlink:href="#i"/></pattern>'
        '<image id="i" xlink:href="data:image/png;base64,AA"/></defs></svg>';
    expect(() => sanitizeTokenSvg(svg), throwsFormatException);
  });

  test('a vector logo that also embeds an image keeps drawing', () {
    const svg =
        '<svg><circle r="1"/><image href="data:image/png;base64,AA"/></svg>';
    expect(sanitizeTokenSvg(svg), svg);
  });
}
