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
        '<svg><rect fill="url(#a)"/><defs><pattern id="a"><image href="data:image/png;base64,AA"/></pattern></defs></svg>';
    expect(() => sanitizeTokenSvg(svg), throwsFormatException);
  });

  test('CRV: a pattern filled with a bitmap falls back to the letters', () {
    const svg =
        '<svg xmlns:xlink="x"><rect fill="url(#p)"/><defs><pattern id="p"><use xlink:href="#i"/></pattern>'
        '<image id="i" xlink:href="data:image/png;base64,AA"/></defs></svg>';
    expect(() => sanitizeTokenSvg(svg), throwsFormatException);
  });

  test('a vector logo that also embeds an image keeps drawing', () {
    const svg =
        '<svg><circle r="1"/><image href="data:image/png;base64,AA"/></svg>';
    expect(sanitizeTokenSvg(svg), contains('<image'));
  });

  test('an unused bitmap pattern does not reject the logo', () {
    const svg =
        '<svg><circle r="1"/><defs><pattern id="a"><image href="x"/></pattern></defs></svg>';
    expect(() => sanitizeTokenSvg(svg), returnsNormally);
  });

  test('a class and an inline style merge into one style attribute', () {
    const svg =
        '<svg><style>.a{fill:red}</style><circle class="a" style="opacity:.5"/></svg>';
    final out = sanitizeTokenSvg(svg);
    expect(out, contains('style="fill:red;opacity:.5"'));
    expect(RegExp('style=').allMatches(out).length, 1);
  });

  test('a bitmap pattern used through style= or a class is rejected', () {
    const defs = '<defs><pattern id="p"><image href="x"/></pattern></defs>';
    expect(
      () => sanitizeTokenSvg('<svg>$defs<rect style="fill:url(#p)"/></svg>'),
      throwsFormatException,
    );
    expect(
      () => sanitizeTokenSvg(
        '<svg><style>.c{fill:url(#p)}</style>$defs<rect class="c"/></svg>',
      ),
      throwsFormatException,
    );
  });
}
